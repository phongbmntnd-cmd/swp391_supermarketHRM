package dao;

import context.DBContext;
import model.LeaveRequestShift;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO cho bảng leave_request_shifts - chi tiết ca làm việc bị ảnh hưởng
 * bởi mỗi đơn nghỉ phép.
 *
 * Đây là phần "C" của mô hình "C trên nền B":
 *   - Mỗi đơn nghỉ gắn với danh sách ca cụ thể.
 *   - Khi duyệt, các ca đó được chuyển sang ON_LEAVE và đưa vào
 *     open_shifts để tìm người cover.
 */
public class LeaveShiftDetailDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    /**
     * Chèn danh sách ca chi tiết cho một đơn nghỉ.
     * Dùng kèm Connection để nằm chung transaction với việc tạo đơn.
     */
    public void insertDetails(
            Connection c,
            int leaveRequestId,
            List<LeaveRequestShift> details) throws Exception {

        if (details == null || details.isEmpty()) {
            return;
        }

        String sql = "INSERT INTO leave_request_shifts "
                + "(leave_request_id, work_date, shift_id, shift_name, hours) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            for (LeaveRequestShift d : details) {
                ps.setInt(1, leaveRequestId);
                ps.setDate(2, d.getWorkDate());
                ps.setInt(3, d.getShiftId());
                if (d.getShiftName() == null || d.getShiftName().trim().isEmpty()) {
                    ps.setNull(4, Types.VARCHAR);
                } else {
                    ps.setString(4, d.getShiftName().trim());
                }
                ps.setDouble(5, d.getHours());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    /**
     * Lấy danh sách ca chi tiết của một đơn nghỉ.
     */
    public List<LeaveRequestShift> getByRequestId(int leaveRequestId) {
        List<LeaveRequestShift> list = new ArrayList<>();

        String sql = "SELECT lrs.id, lrs.leave_request_id AS leaveRequestId, "
                + "lrs.work_date AS workDate, lrs.shift_id AS shiftId, "
                + "lrs.shift_name AS shiftName, lrs.hours, "
                + "TIME_FORMAT(s.start_time, '%H:%i') AS startTime, "
                + "TIME_FORMAT(s.end_time, '%H:%i') AS endTime, "
                + "COALESCE(ss.position_id, 0) AS positionId "
                + "FROM leave_request_shifts lrs "
                + "LEFT JOIN shifts s ON s.id = lrs.shift_id "
                + "LEFT JOIN shift_schedules ss "
                + "  ON ss.user_id = (SELECT user_id FROM leave_requests "
                + "                   WHERE id = lrs.leave_request_id) "
                + " AND ss.shift_id = lrs.shift_id "
                + " AND ss.work_date = lrs.work_date "
                + "WHERE lrs.leave_request_id = ? "
                + "ORDER BY lrs.work_date, s.start_time";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, leaveRequestId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave request shift details", e);
        }

        return list;
    }

    /**
     * Lấy danh sách ca chi tiết cho nhiều đơn cùng lúc, gom theo
     * leaveRequestId để tránh N+1 query khi hiển thị danh sách.
     */
    public Map<Integer, List<LeaveRequestShift>> getByRequestIds(
            List<Integer> requestIds) {

        Map<Integer, List<LeaveRequestShift>> result = new LinkedHashMap<>();

        if (requestIds == null || requestIds.isEmpty()) {
            return result;
        }

        for (Integer id : requestIds) {
            result.put(id, new ArrayList<>());
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < requestIds.size(); i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }

        String sql = "SELECT lrs.id, lrs.leave_request_id AS leaveRequestId, "
                + "lrs.work_date AS workDate, lrs.shift_id AS shiftId, "
                + "lrs.shift_name AS shiftName, lrs.hours, "
                + "TIME_FORMAT(s.start_time, '%H:%i') AS startTime, "
                + "TIME_FORMAT(s.end_time, '%H:%i') AS endTime "
                + "FROM leave_request_shifts lrs "
                + "LEFT JOIN shifts s ON s.id = lrs.shift_id "
                + "WHERE lrs.leave_request_id IN (" + placeholders + ") "
                + "ORDER BY lrs.work_date, s.start_time";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            for (int i = 0; i < requestIds.size(); i++) {
                ps.setInt(i + 1, requestIds.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LeaveRequestShift d = mapRow(rs);
                    List<LeaveRequestShift> bucket =
                            result.get(d.getLeaveRequestId());
                    if (bucket != null) {
                        bucket.add(d);
                    }
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave request shift details", e);
        }

        return result;
    }

    /**
     * Tổng giờ nghỉ của một đơn, đọc trực tiếp từ bảng chi tiết.
     */
    public double getTotalHoursByRequestId(int leaveRequestId) {
        String sql = "SELECT COALESCE(SUM(hours), 0) FROM leave_request_shifts "
                + "WHERE leave_request_id = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, leaveRequestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot sum leave request shift hours", e);
        }

        return 0;
    }

    /**
     * Xóa chi tiết ca của một đơn (dùng khi hủy đơn đã duyệt,
     * hoặc khi rollback).
     */
    public void deleteByRequestId(int leaveRequestId) {
        String sql = "DELETE FROM leave_request_shifts "
                + "WHERE leave_request_id = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, leaveRequestId);
            ps.executeUpdate();

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot delete leave request shift details", e);
        }
    }

    private LeaveRequestShift mapRow(ResultSet rs) throws Exception {
        LeaveRequestShift d = new LeaveRequestShift();
        d.setId(rs.getInt("id"));
        d.setLeaveRequestId(rs.getInt("leaveRequestId"));
        d.setWorkDate(rs.getDate("workDate"));
        d.setShiftId(rs.getInt("shiftId"));
        d.setShiftName(rs.getString("shiftName"));
        d.setHours(rs.getDouble("hours"));
        d.setStartTime(rs.getString("startTime"));
        d.setEndTime(rs.getString("endTime"));
        try {
            d.setPositionId(rs.getInt("positionId"));
        } catch (Exception ignore) {
            // Cột positionId không tồn tại trong một số truy vấn -> bỏ qua
        }
        return d;
    }
}
