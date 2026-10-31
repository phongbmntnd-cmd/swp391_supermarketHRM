package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO phụ trợ cho luồng nghỉ phép theo ca (phần "C").
 *
 * Cung cấp danh sách ca mà nhân viên có thể chọn để xin nghỉ:
 *   - Ca đã được xếp (PUBLISHED) trong tuần -> nhân viên tick để nghỉ.
 *   - Nếu tuần chưa có lịch -> dựng danh sách ca theo ca cố định
 *     (employee_profiles.shift_type) để nhân viên vẫn gửi được đơn;
 *     khi lịch được publish, hệ thống sẽ khớp lại.
 */
public class LeaveShiftOptionDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    /**
     * Lấy định nghĩa tất cả các ca trong hệ thống kèm thời lượng.
     *
     * Dùng để hiển thị thông tin "Ca Sáng = 5 giờ (07:00-12:00)" trong
     * phần quy định, giúp nhân viên hiểu 1 ca nghỉ được tính bao nhiêu
     * giờ khi quota đơn vị là giờ.
     *
     * @return danh sách map: shiftId, shiftName, startTime, endTime, hours
     */
    public List<Map<String, Object>> getShiftDefinitions() {
        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT id AS shiftId, name AS shiftName, "
                + "TIME_FORMAT(start_time, '%H:%i') AS startTime, "
                + "TIME_FORMAT(end_time, '%H:%i') AS endTime, "
                + "TIMESTAMPDIFF(MINUTE, start_time, end_time) AS minutes "
                + "FROM shifts ORDER BY start_time, id";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("shiftId", rs.getInt("shiftId"));
                row.put("shiftName", rs.getString("shiftName"));
                row.put("startTime", rs.getString("startTime"));
                row.put("endTime", rs.getString("endTime"));
                row.put("minutes", rs.getInt("minutes"));
                row.put("hours", rs.getInt("minutes") / 60.0);
                result.add(row);
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load shift definitions", e);
        }

        return result;
    }

    /**
     * Lấy các ca đã XẾP của nhân viên trong khoảng ngày.
     *
     * <h3>Vì sao lấy cả DRAFT?</h3>
     * Store Manager xếp ca theo tuần rồi mới publish. Trong khoảng
     * giữa lúc xếp và lúc publish, ca của nhân viên có trạng thái
     * {@code DRAFT}. Nếu bỏ qua {@code DRAFT} thì màn hình "Chọn ca
     * muốn nghỉ" sẽ hiện ca CỐ ĐỊNH (dự kiến) cho những ngày đó,
     * lệch với lịch thật mà Store đang xếp -> nhân viên tick sai ca.
     *
     * <p>Do đó lấy cả {@code DRAFT}, {@code PUBLISHED} và
     * {@code ON_LEAVE}. Bỏ qua {@code CANCELLED} (ca đã bị hủy thì
     * không phải ca nhân viên đi làm).
     *
     * @return mỗi phần tử gồm: workDate, shiftId, shiftName, hours,
     *         startTime, endTime, status, published, onLeave
     */
    public List<Map<String, Object>> getAssignedShifts(
            int userId,
            java.time.LocalDate from,
            java.time.LocalDate to) {

        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT ss.work_date AS workDate, "
                + "ss.shift_id AS shiftId, s.name AS shiftName, "
                + "TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time) AS minutes, "
                + "TIME_FORMAT(s.start_time, '%H:%i') AS startTime, "
                + "TIME_FORMAT(s.end_time, '%H:%i') AS endTime, "
                + "ss.status "
                + "FROM shift_schedules ss "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "WHERE ss.user_id = ? "
                + "AND ss.work_date BETWEEN ? AND ? "
                + "AND ss.status IN ('DRAFT', 'PUBLISHED', 'ON_LEAVE') "
                + "ORDER BY ss.work_date, s.start_time";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(from));
            ps.setDate(3, java.sql.Date.valueOf(to));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("status");

                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("workDate", rs.getDate("workDate"));
                    row.put("shiftId", rs.getInt("shiftId"));
                    row.put("shiftName", rs.getString("shiftName"));
                    row.put("minutes", rs.getInt("minutes"));
                    row.put("hours", rs.getInt("minutes") / 60.0);
                    row.put("startTime", rs.getString("startTime"));
                    row.put("endTime", rs.getString("endTime"));
                    row.put("status", status);
                    row.put("published", "PUBLISHED".equals(status));
                    row.put("onLeave", "ON_LEAVE".equals(status));
                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load assigned shifts", e);
        }

        return result;
    }

    /**
     * Kiểm tra tuần đã được publish lịch hay chưa.
     * Part-time cần biết điều này vì ca đã publish thì phải báo trước
     * nhiều hơn để kịp tìm người cover.
     */
    public boolean isWeekPublished(int branchId,
            java.time.LocalDate monday) {

        String sql = "SELECT COUNT(*) FROM shift_schedules "
                + "WHERE branch_id = ? "
                + "AND status = 'PUBLISHED' "
                + "AND work_date BETWEEN ? AND ?";

        java.time.LocalDate sunday = monday.plusDays(6);

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setDate(2, java.sql.Date.valueOf(monday));
            ps.setDate(3, java.sql.Date.valueOf(sunday));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot check published week", e);
        }

        return false;
    }

    /**
     * Tuần đã được publish ĐẦY ĐỦ chưa?
     *
     * <h3>Vì sao cần phân biệt?</h3>
     * Lịch có thể được publish theo từng phần: một số ngày đã
     * {@code PUBLISHED}, số ngày khác còn {@code DRAFT}. Nếu chỉ
     * kiểm tra "có ít nhất 1 ca PUBLISHED" thì header sẽ báo "lịch đã
     * được xếp" trong khi thực tế phần lớn tuần chưa publish ->
     * gây hiểu nhầm cho nhân viên.
     *
     * @return true nếu tuần KHÔNG còn dòng {@code DRAFT} nào
     */
    public boolean isWeekFullyPublished(int branchId,
            java.time.LocalDate monday) {

        String sql = "SELECT COUNT(*) FROM shift_schedules "
                + "WHERE branch_id = ? "
                + "AND status = 'DRAFT' "
                + "AND work_date BETWEEN ? AND ?";

        java.time.LocalDate sunday = monday.plusDays(6);

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setDate(2, java.sql.Date.valueOf(monday));
            ps.setDate(3, java.sql.Date.valueOf(sunday));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot check published week", e);
        }

        return false;
    }

    /**
     * Lấy các ca hợp lệ cho nhân viên part-time khi chưa có lịch publish.
     *
     * Dựa trên ca cố định trong employee_profiles.shift_type:
     *   PT_FIXED_MORNING   -> ca có chứa "sáng"
     *   PT_FIXED_AFTERNOON -> ca có chứa "chiều"
     *   PT_FIXED_EVENING   -> ca có chứa "tối"
     * Nếu không có ca cố định -> trả về tất cả ca ngắn (không phải ca
     * full-time).
     */
    public List<Map<String, Object>> getFixedShiftOptions(String shiftType) {
        return getFixedShiftOptions(shiftType, null, null, false);
    }

    /**
     * Biến thể sinh ca theo từng NGÀY trong khoảng [from, to].
     *
     * Dùng cho part-time khi lịch tuần chưa được publish: nhân viên
     * vẫn tick được đúng ca/ngày muốn nghỉ. Khi lịch được publish,
     * hệ thống sẽ khớp lại theo (ngày, ca).
     */
    public List<Map<String, Object>> getFixedShiftOptions(
            String shiftType,
            java.time.LocalDate from,
            java.time.LocalDate to) {
        return getFixedShiftOptions(shiftType, from, to, true);
    }

    public List<Map<String, Object>> getFixedShiftOptions(
            String shiftType,
            java.time.LocalDate from,
            java.time.LocalDate to,
            boolean perDay) {

        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT id AS shiftId, name AS shiftName, "
                + "TIME_FORMAT(start_time, '%H:%i') AS startTime, "
                + "TIME_FORMAT(end_time, '%H:%i') AS endTime, "
                + "TIMESTAMPDIFF(MINUTE, start_time, end_time) AS minutes "
                + "FROM shifts ORDER BY start_time";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String name = rs.getString("shiftName");
                String lower = name == null ? "" : name.toLowerCase();

                if (!matchesFixedShift(lower, shiftType)) {
                    continue;
                }

                Map<String, Object> row = new LinkedHashMap<>();
                row.put("shiftId", rs.getInt("shiftId"));
                row.put("shiftName", name);
                row.put("startTime", rs.getString("startTime"));
                row.put("endTime", rs.getString("endTime"));
                row.put("minutes", rs.getInt("minutes"));
                row.put("hours", rs.getInt("minutes") / 60.0);
                result.add(row);
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load fixed shift options", e);
        }

        if (!perDay || from == null || to == null) {
            return result;
        }

        // Nhân bản danh sách ca theo từng ngày trong khoảng.
        List<Map<String, Object>> expanded = new ArrayList<>();
        for (java.time.LocalDate d = from;
             !d.isAfter(to);
             d = d.plusDays(1)) {

            for (Map<String, Object> base : result) {
                Map<String, Object> row = new LinkedHashMap<>(base);
                row.put("workDate", java.sql.Date.valueOf(d));
                expanded.add(row);
            }
        }

        return expanded;
    }

    /**
     * Kiểm tra một ca có khớp với ca cố định của part-time không.
     */
    private boolean matchesFixedShift(String shiftNameLower, String shiftType) {

        // Ca full-time (07:00-17:00 / 12:00-22:00) không dành cho part-time
        if (shiftNameLower.contains("full")) {
            return false;
        }

        if (shiftType == null || shiftType.trim().isEmpty()) {
            // Không có ca cố định -> cho phép mọi ca ngắn
            return true;
        }

        String t = shiftType.trim().toUpperCase();

        if ("PT_FIXED_MORNING".equals(t)) {
            return shiftNameLower.contains("sáng")
                    || shiftNameLower.contains("sang");
        }
        if ("PT_FIXED_AFTERNOON".equals(t)) {
            return shiftNameLower.contains("chiều")
                    || shiftNameLower.contains("chieu");
        }
        if ("PT_FIXED_EVENING".equals(t)) {
            return shiftNameLower.contains("tối")
                    || shiftNameLower.contains("toi");
        }

        return true;
    }
}
