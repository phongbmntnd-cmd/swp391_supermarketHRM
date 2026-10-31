package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO hỗ trợ Store Manager khi duyệt đơn nghỉ phép.
 *
 * Mục tiêu: cho Store Manager thấy ngay ca nào bị ảnh hưởng và ca đó
 * có đang thiếu người hay không, để chủ động điều người cover - đúng
 * cách vận hành thực tế của siêu thị.
 */
public class LeaveCoverageDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    /**
     * Kiểm tra tình trạng nhân sự cho các ca bị nghỉ của một đơn.
     *
     * Với mỗi ca (ngày + shift), trả về:
     *   requiredCount : số người cần có (theo shift_requirements)
     *   assignedCount : số người đang được xếp ca đó
     *   onLeaveCount  : số người đang nghỉ trong đơn này
     *   missing       : required - assigned (sau khi trừ người nghỉ)
     *   warning       : true nếu thiếu người
     *
     * @param branchId     chi nhánh
     * @param requestId    đơn nghỉ
     * @return danh sách theo ca
     */
    public List<Map<String, Object>> getCoverageStatus(
            int branchId, int requestId) {

        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT lrs.work_date AS workDate, "
                + "lrs.shift_id AS shiftId, "
                + "COALESCE(lrs.shift_name, s.name) AS shiftName, "
                + "lrs.hours, "
                + "COALESCE(req.required_count, 0) AS requiredCount, "
                + "(SELECT COUNT(*) FROM shift_schedules x "
                + " WHERE x.shift_id = lrs.shift_id "
                + "   AND x.work_date = lrs.work_date "
                + "   AND x.branch_id = ? "
                + "   AND x.status IN ('PUBLISHED', 'ON_LEAVE')) "
                + "  AS assignedCount, "
                + "(SELECT COUNT(*) FROM shift_schedules x "
                + " WHERE x.shift_id = lrs.shift_id "
                + "   AND x.work_date = lrs.work_date "
                + "   AND x.branch_id = ? "
                + "   AND x.status = 'ON_LEAVE') AS onLeaveCount, "
                + "(SELECT COUNT(*) FROM open_shifts o "
                + " WHERE o.shift_id = lrs.shift_id "
                + "   AND o.work_date = lrs.work_date "
                + "   AND o.branch_id = ? "
                + "   AND o.status = 'OPEN') AS openShiftCount "
                + "FROM leave_request_shifts lrs "
                + "LEFT JOIN shifts s ON s.id = lrs.shift_id "
                + "LEFT JOIN shift_requirements req "
                + "  ON req.shift_id = lrs.shift_id "
                + " AND req.work_date = lrs.work_date "
                + " AND req.branch_id = ? "
                + " AND req.position_id = ( "
                + "     SELECT COALESCE(ss.position_id, ep.position_id) "
                + "     FROM shift_schedules ss "
                + "     JOIN employee_profiles ep ON ep.user_id = ss.user_id "
                + "     WHERE ss.user_id = ( "
                + "         SELECT user_id FROM leave_requests "
                + "         WHERE id = lrs.leave_request_id) "
                + "       AND ss.shift_id = lrs.shift_id "
                + "       AND ss.work_date = lrs.work_date "
                + "     LIMIT 1) "
                + "WHERE lrs.leave_request_id = ? "
                + "ORDER BY lrs.work_date, s.start_time";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setInt(2, branchId);
            ps.setInt(3, branchId);
            ps.setInt(4, branchId);
            ps.setInt(5, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    int required = rs.getInt("requiredCount");
                    int assigned = rs.getInt("assignedCount");
                    int onLeave = rs.getInt("onLeaveCount");
                    int openShifts = rs.getInt("openShiftCount");

                    // Số người còn thiếu = yêu cầu - (đã xếp - đang nghỉ)
                    int missing = required - (assigned - onLeave);
                    if (missing < 0) {
                        missing = 0;
                    }

                    row.put("workDate", rs.getDate("workDate"));
                    row.put("shiftId", rs.getInt("shiftId"));
                    row.put("shiftName", rs.getString("shiftName"));
                    row.put("hours", rs.getDouble("hours"));
                    row.put("requiredCount", required);
                    row.put("assignedCount", assigned);
                    row.put("onLeaveCount", onLeave);
                    row.put("openShiftCount", openShifts);
                    row.put("missingCount", missing);
                    row.put("warning", required > 0 && missing > 0);

                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave coverage status", e);
        }

        return result;
    }

    /**
     * Tổng hợp cảnh báo cho một đơn.
     * Trả về chuỗi mô tả (rỗng nếu không có vấn đề).
     */
    public String getCoverageWarning(int branchId, int requestId) {
        List<Map<String, Object>> rows =
                getCoverageStatus(branchId, requestId);

        int warnCount = 0;
        StringBuilder sb = new StringBuilder();

        for (Map<String, Object> row : rows) {
            if (!Boolean.TRUE.equals(row.get("warning"))) {
                continue;
            }
            warnCount++;
            if (warnCount <= 3) {
                sb.append(row.get("workDate"))
                  .append(" - ")
                  .append(row.get("shiftName"))
                  .append(" (thiếu ")
                  .append(row.get("missingCount"))
                  .append(" người)");
                if (warnCount < 3) {
                    sb.append("; ");
                }
            }
        }

        if (warnCount == 0) {
            return "";
        }

        if (warnCount > 3) {
            sb.append(" và ").append(warnCount - 3).append(" ca khác");
        }

        return "Sau khi duyệt, " + warnCount
                + " ca sẽ thiếu người: " + sb + ".";
    }
}
