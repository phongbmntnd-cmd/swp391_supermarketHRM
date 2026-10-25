package dao;

import context.DBContext;
import java.sql.*;
import java.util.*;

/**
 * DAO cho bảng leave_balances.
 *
 * Mô hình "C trên nền B": đơn vị đo chuẩn là GIỜ.
 *   - total_hours / used_hours : đơn vị chính, dùng để kiểm tra quota.
 *   - total_days / used_days   : giữ lại để tương thích ngược & lịch sử.
 *
 * Các hàm cũ (getTotalDays, getUsedDays, updateUsedDays...) vẫn được giữ
 * nguyên để không phá vỡ code đang chạy; các hàm mới dùng h suffix Hours.
 */
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
                + "COALESCE(lb.total_hours, lb.total_days * ep.standard_hours_per_day) "
                + "  AS totalHours, "
                + "COALESCE(lb.used_hours, lb.used_days * ep.standard_hours_per_day) "
                + "  AS usedHours, "
                + "GREATEST(0, COALESCE(lb.total_hours, "
                + "  lb.total_days * ep.standard_hours_per_day) "
                + "  - COALESCE(lb.used_hours, "
                + "  lb.used_days * ep.standard_hours_per_day)) AS remainingHours, "
                + "GREATEST(0, lb.total_days - lb.used_days) AS remainingDays, "
                + "lt.paid_leave AS paidLeave "
                + "FROM leave_balances lb "
                + "JOIN leave_types lt ON lt.id = lb.leave_type_id "
                + "JOIN employee_profiles ep ON ep.user_id = lb.user_id "
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
                    row.put("totalHours", rs.getDouble("totalHours"));
                    row.put("usedHours", rs.getDouble("usedHours"));
                    row.put("remainingHours", rs.getDouble("remainingHours"));
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

    /**
     * Tổng hợp thời gian nghỉ theo TỪNG LOẠI nghỉ phép của chi nhánh.
     *
     * <h3>Công thức</h3>
     * <ul>
     *   <li><b>Đã duyệt</b>: tổng giờ của các đơn APPROVED.</li>
     *   <li><b>Chờ duyệt</b>: tổng giờ của các đơn PENDING (đã đặt chỗ,
     *       SM cần thấy để biết tải trọng sắp tới).</li>
     *   <li><b>Tổng</b> = đã duyệt + chờ duyệt.</li>
     * </ul>
     *
     * @param branchId chi nhánh
     * @param year     năm tính (theo năm của start_date)
     * @return danh sách map: leaveTypeId, leaveTypeCode, leaveTypeName,
     *         paidLeave, approvedHours, pendingHours, totalHours,
     *         requestCount, employeeCount
     */
    public List<Map<String, Object>> getBranchLeaveSummary(
            int branchId, int year) {

        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT lt.id AS leaveTypeId, "
                + "lt.code AS leaveTypeCode, "
                + "lt.name AS leaveTypeName, "
                + "lt.paid_leave AS paidLeave, "
                + "COALESCE(SUM(CASE WHEN lr.status = 'APPROVED' "
                + "  THEN COALESCE(lr.total_hours, 0) ELSE 0 END), 0) "
                + "  AS approvedHours, "
                + "COALESCE(SUM(CASE WHEN lr.status = 'PENDING' "
                + "  THEN COALESCE(lr.total_hours, 0) ELSE 0 END), 0) "
                + "  AS pendingHours, "
                + "COUNT(*) AS requestCount, "
                + "COUNT(DISTINCT lr.user_id) AS employeeCount "
                + "FROM leave_requests lr "
                + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
                + "JOIN leave_types lt ON lt.id = lr.leave_type_id "
                + "WHERE ep.home_branch_id = ? "
                + "AND YEAR(lr.start_date) = ? "
                + "AND lr.status IN ('APPROVED', 'PENDING') "
                + "GROUP BY lt.id, lt.code, lt.name, lt.paid_leave "
                + "ORDER BY lt.id";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setInt(2, year);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("leaveTypeId",
                            rs.getInt("leaveTypeId"));
                    row.put("leaveTypeCode",
                            rs.getString("leaveTypeCode"));
                    row.put("leaveTypeName",
                            rs.getString("leaveTypeName"));
                    row.put("paidLeave",
                            rs.getBoolean("paidLeave"));

                    double approved =
                            rs.getDouble("approvedHours");
                    double pending =
                            rs.getDouble("pendingHours");

                    row.put("approvedHours", approved);
                    row.put("pendingHours", pending);
                    row.put("totalHours", approved + pending);
                    row.put("requestCount",
                            rs.getInt("requestCount"));
                    row.put("employeeCount",
                            rs.getInt("employeeCount"));

                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load branch leave summary", e);
        }

        return result;
    }

    /**
     * Tổng hợp thời gian nghỉ của MỘT nhân viên theo từng loại nghỉ.
     *
     * <h3>Công thức</h3>
     * <ul>
     *   <li><b>Đã duyệt</b>: tổng giờ của các đơn APPROVED.</li>
     *   <li><b>Chờ duyệt</b>: tổng giờ của các đơn PENDING.</li>
     *   <li><b>Tổng</b> = đã duyệt + chờ duyệt (tổng thời gian đã
     *       đặt chỗ trong năm).</li>
     *   <li><b>Từ chối / Hủy</b>: thống kê riêng, không tính vào tổng.</li>
     * </ul>
     *
     * @param userId nhân viên
     * @param year   năm (theo năm của start_date)
     * @return danh sách map: leaveTypeId, leaveTypeCode, leaveTypeName,
     *         approvedHours, pendingHours, totalHours,
     *         rejectedHours, cancelledHours, requestCount
     */
    public List<Map<String, Object>> getUserLeaveTimeSummary(
            int userId, int year) {

        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT lt.id AS leaveTypeId, "
                + "lt.code AS leaveTypeCode, "
                + "lt.name AS leaveTypeName, "
                + "COALESCE(SUM(CASE WHEN lr.status = 'APPROVED' "
                + "  THEN COALESCE(lr.total_hours, 0) ELSE 0 END), 0) "
                + "  AS approvedHours, "
                + "COALESCE(SUM(CASE WHEN lr.status = 'PENDING' "
                + "  THEN COALESCE(lr.total_hours, 0) ELSE 0 END), 0) "
                + "  AS pendingHours, "
                + "COALESCE(SUM(CASE WHEN lr.status = 'REJECTED' "
                + "  THEN COALESCE(lr.total_hours, 0) ELSE 0 END), 0) "
                + "  AS rejectedHours, "
                + "COALESCE(SUM(CASE WHEN lr.status = 'CANCELLED' "
                + "  THEN COALESCE(lr.total_hours, 0) ELSE 0 END), 0) "
                + "  AS cancelledHours, "
                + "COUNT(*) AS requestCount "
                + "FROM leave_requests lr "
                + "JOIN leave_types lt ON lt.id = lr.leave_type_id "
                + "WHERE lr.user_id = ? "
                + "AND YEAR(lr.start_date) = ? "
                + "GROUP BY lt.id, lt.code, lt.name "
                + "ORDER BY lt.id";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, year);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("leaveTypeId",
                            rs.getInt("leaveTypeId"));
                    row.put("leaveTypeCode",
                            rs.getString("leaveTypeCode"));
                    row.put("leaveTypeName",
                            rs.getString("leaveTypeName"));

                    double approved =
                            rs.getDouble("approvedHours");
                    double pending =
                            rs.getDouble("pendingHours");

                    row.put("approvedHours", approved);
                    row.put("pendingHours", pending);
                    row.put("totalHours", approved + pending);
                    row.put("rejectedHours",
                            rs.getDouble("rejectedHours"));
                    row.put("cancelledHours",
                            rs.getDouble("cancelledHours"));
                    row.put("requestCount",
                            rs.getInt("requestCount"));

                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave time summary", e);
        }

        return result;
    }

    // ============================================================
    // PHẦN MỚI - đơn vị GIỜ (mô hình "C trên nền B")
    // ============================================================

    /**
     * Lấy tổng quota giờ của một loại nghỉ trong năm.
     * Trả về 0 nếu chưa được cấp quota (khi đó không giới hạn).
     */
    public double getTotalHours(int userId, int leaveTypeId, int year) {
        String sql = "SELECT COALESCE(lb.total_hours, "
                + "lb.total_days * ep.standard_hours_per_day) AS totalHours "
                + "FROM leave_balances lb "
                + "JOIN employee_profiles ep ON ep.user_id = lb.user_id "
                + "WHERE lb.user_id = ? AND lb.leave_type_id = ? "
                + "AND lb.year = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, year);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("totalHours");
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave balance hours", e);
        }

        return 0;
    }

    /**
     * Lấy số giờ đã dùng của một loại nghỉ trong năm.
     *
     * <h3>Quy ước "đã cam kết"</h3>
     * Số giờ đã dùng = giờ đã trừ trong balance (đơn APPROVED)
     *              + giờ của các đơn đang PENDING (đã đặt chỗ).
     *
     * Việc tính cả đơn PENDING giúp chặn sớm tình trạng nhân viên
     * tạo nhiều đơn PENDING rồi mới bị chặn khi duyệt. Hàm này được
     * dùng GIỐNG NHAU ở cả hai nơi (lúc tạo đơn và lúc duyệt) để tránh
     * mâu thuẫn giữa hai mốc kiểm tra.
     *
     * @param excludeRequestId id đơn cần loại khỏi phần PENDING
     *                         (dùng khi duyệt chính đơn đó),
     *                         truyền -1 nếu không loại đơn nào
     */
    public double getUsedHours(int userId, int leaveTypeId, int year) {
        return getUsedHours(userId, leaveTypeId, year, -1);
    }

    public double getUsedHours(int userId, int leaveTypeId, int year,
            int excludeRequestId) {

        String sql = "SELECT "
                + "COALESCE((SELECT lb.used_hours FROM leave_balances lb "
                + "  WHERE lb.user_id = ? AND lb.leave_type_id = ? "
                + "  AND lb.year = ?), 0) "
                + "+ COALESCE((SELECT SUM(lr.total_hours) FROM leave_requests lr "
                + "  WHERE lr.user_id = ? "
                + "  AND lr.leave_type_id = ? "
                + "  AND YEAR(lr.start_date) = ? "
                + "  AND lr.status = 'PENDING' "
                + "  AND (? < 0 OR lr.id <> ?)), 0) AS used";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, year);
            ps.setInt(4, userId);
            ps.setInt(5, leaveTypeId);
            ps.setInt(6, year);
            ps.setInt(7, excludeRequestId);
            ps.setInt(8, excludeRequestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("used");
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot count used hours", e);
        }

        return 0;
    }

    /**
     * Cộng giờ đã dùng sau khi duyệt đơn.
     */
    public boolean updateUsedHours(
            int userId, int leaveTypeId, int year, double hours) {
        return adjustUsedHours(userId, leaveTypeId, year, hours, false);
    }

    /**
     * Trừ lại giờ đã dùng khi hủy đơn đã duyệt.
     */
    public boolean subtractUsedHours(
            int userId, int leaveTypeId, int year, double hours) {
        return adjustUsedHours(userId, leaveTypeId, year, hours, true);
    }

    private boolean adjustUsedHours(
            int userId,
            int leaveTypeId,
            int year,
            double hours,
            boolean subtract) {

        if (hours <= 0) {
            return false;
        }

        // used_days được cập nhật theo tỷ lệ để giữ cho tương thích
        // ngược: days = hours / standard_hours_per_day
        String sql = "UPDATE leave_balances lb "
                + "JOIN employee_profiles ep ON ep.user_id = lb.user_id "
                + "SET lb.used_hours = GREATEST(0, "
                + "  COALESCE(lb.used_hours, 0) "
                + "  + IF(?, -?, ?)), "
                + "lb.used_days = GREATEST(0, lb.used_days + IF(?, "
                + "  -FLOOR(? / ep.standard_hours_per_day), "
                + "  FLOOR(? / ep.standard_hours_per_day))) "
                + "WHERE lb.user_id = ? AND lb.leave_type_id = ? "
                + "AND lb.year = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            int sign = subtract ? -1 : 1;
            ps.setInt(1, sign);
            ps.setDouble(2, hours);
            ps.setDouble(3, hours);
            ps.setInt(4, sign);
            ps.setDouble(5, hours);
            ps.setDouble(6, hours);
            ps.setInt(7, userId);
            ps.setInt(8, leaveTypeId);
            ps.setInt(9, year);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot adjust used hours", e);
        }
    }
}
