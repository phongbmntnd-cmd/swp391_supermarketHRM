package dao;

import context.DBContext;
import java.sql.*;
import java.util.*;

public class LeaveBalanceDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    // Lấy quota nghỉ phép của nhân viên trong năm hiện tại
    public List<Map<String, Object>> getMyBalances(int userId, int year) {
        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT lb.id, lb.user_id AS userId, "
                + "lb.leave_type_id AS leaveTypeId, "
                + "lt.code AS leaveTypeCode, "
                + "lt.name AS leaveTypeName, "
                + "lb.year, lb.total_days AS totalDays, "
                + "lb.used_days AS usedDays, "
                + "(lb.total_days - lb.used_days) AS remainingDays, "
                + "lt.paid_leave AS paidLeave "
                + "FROM leave_balances lb "
                + "JOIN leave_types lt ON lt.id = lb.leave_type_id "
                + "WHERE lb.user_id = ? AND lb.year = ? "
                + "ORDER BY lt.id";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, year);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("userId", rs.getInt("userId"));
                    row.put("leaveTypeId", rs.getInt("leaveTypeId"));
                    row.put("leaveTypeCode", rs.getString("leaveTypeCode"));
                    row.put("leaveTypeName", rs.getString("leaveTypeName"));
                    row.put("year", rs.getInt("year"));
                    row.put("totalDays", rs.getInt("totalDays"));
                    row.put("usedDays", rs.getInt("usedDays"));
                    row.put("remainingDays", rs.getInt("remainingDays"));
                    row.put("paidLeave", rs.getBoolean("paidLeave"));
                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave balances", e);
        }

        return result;
    }

    // Lấy số ngày đã nghỉ theo loại trong năm (cho kiểm tra quota)
    public int getUsedDaysByType(int userId, int leaveTypeId, int year) {
        String sql = "SELECT COALESCE(SUM(lr.total_days), 0) AS used "
                + "FROM leave_requests lr "
                + "WHERE lr.user_id = ? "
                + "AND lr.leave_type_id = ? "
                + "AND YEAR(lr.start_date) = ? "
                + "AND lr.status IN ('PENDING', 'APPROVED')";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, year);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("used");
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot count used days", e);
        }

        return 0;
    }

    // Lấy tổng quota (total_days) của một loại nghỉ trong năm.
    // Trả về 0 nếu chưa được cấp quota (khi đó không giới hạn).
    public int getTotalDays(int userId, int leaveTypeId, int year) {
        String sql = "SELECT total_days FROM leave_balances "
                + "WHERE user_id = ? AND leave_type_id = ? AND year = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, year);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_days");
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave balance", e);
        }

        return 0;
    }

    // Lấy số ngày đã dùng (đếm cả đơn PENDING và APPROVED)
    // để kiểm tra quota khi nhân viên tạo đơn.
    public int getUsedDays(int userId, int leaveTypeId, int year) {
        String sql = "SELECT COALESCE(SUM(lr.total_days), 0) AS used "
                + "FROM leave_requests lr "
                + "WHERE lr.user_id = ? "
                + "AND lr.leave_type_id = ? "
                + "AND YEAR(lr.start_date) = ? "
                + "AND lr.status IN ('PENDING', 'APPROVED')";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, year);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("used");
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot count used days", e);
        }

        return 0;
    }

    // Cập nhật số ngày đã dùng sau khi duyệt đơn
    public boolean updateUsedDays(int userId, int leaveTypeId, int year, int days) {
        String sql = "UPDATE leave_balances "
                + "SET used_days = used_days + ? "
                + "WHERE user_id = ? AND leave_type_id = ? AND year = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, days);
            ps.setInt(2, userId);
            ps.setInt(3, leaveTypeId);
            ps.setInt(4, year);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot update used days", e);
        }
    }

    // Trừ lại số ngày khi hủy đơn
    public boolean subtractUsedDays(int userId, int leaveTypeId, int year, int days) {
        String sql = "UPDATE leave_balances "
                + "SET used_days = GREATEST(0, used_days - ?) "
                + "WHERE user_id = ? AND leave_type_id = ? AND year = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, days);
            ps.setInt(2, userId);
            ps.setInt(3, leaveTypeId);
            ps.setInt(4, year);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot subtract used days", e);
        }
    }
}
