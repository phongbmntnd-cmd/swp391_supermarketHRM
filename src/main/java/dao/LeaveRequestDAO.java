package dao;

import context.DBContext;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;

public class LeaveRequestDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    private List<Map<String, Object>> queryList(String sql, Object... params) {
        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();

                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= md.getColumnCount(); i++) {
                        row.put(md.getColumnLabel(i), rs.getObject(i));
                    }
                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave requests", e);
        }

        return result;
    }

    /**
     * Chạy câu truy vấn trả về 1 giá trị số nguyên (COUNT, SUM...).
     * Trả về 0 nếu có lỗi để giao diện không bị vỡ.
     */
    private int countScalar(String sql, Object... params) {
        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot count leave requests", e);
        }

        return 0;
    }

    // 1. Employee: Lịch sử đơn nghỉ phép của mình
    public List<Map<String, Object>> getMyRequests(int userId) {
        String sql = "SELECT lr.id, lr.start_date AS startDate, "
                + "lr.end_date AS endDate, lr.total_days AS totalDays, "
                + "lt.code AS leaveTypeCode, "
                + "lt.name AS leaveTypeName, "
                + "lr.reason, lr.status, lr.manager_response AS managerResponse, "
                + "lr.created_at AS createdAt, "
                + "lr.reviewed_at AS reviewedAt "
                + "FROM leave_requests lr "
                + "JOIN leave_types lt ON lt.id = lr.leave_type_id "
                + "WHERE lr.user_id = ? "
                + "ORDER BY lr.created_at DESC";

        return queryList(sql, userId);
    }

    // 1b. Employee: Đếm số đơn nghỉ phép đang chờ duyệt của tôi
    public int countMyPendingRequests(int userId) {
        return countScalar(
            "SELECT COUNT(*) FROM leave_requests "
            + "WHERE user_id = ? AND status = 'PENDING'",
            userId
        );
    }

    // 1c. Store Manager: Đếm số đơn nghỉ phép đang chờ duyệt của chi nhánh
    public int countBranchPendingRequests(int branchId) {
        return countScalar(
            "SELECT COUNT(*) FROM leave_requests lr "
            + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
            + "WHERE ep.home_branch_id = ? AND lr.status = 'PENDING'",
            branchId
        );
    }

    // 2. Employee: Tạo đơn nghỉ phép
    public boolean createRequest(
            int userId,
            int leaveTypeId,
            LocalDate startDate,
            LocalDate endDate,
            int totalDays,
            String reason) throws Exception {

        String sql = "INSERT INTO leave_requests "
                + "(user_id, leave_type_id, start_date, end_date, "
                + "total_days, reason, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'PENDING')";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setDate(3, java.sql.Date.valueOf(startDate));
            ps.setDate(4, java.sql.Date.valueOf(endDate));
            ps.setInt(5, totalDays);
            ps.setString(6, reason);

            return ps.executeUpdate() > 0;
        }
    }

    // 3. Employee: Hủy đơn nghỉ phép của mình (chỉ khi PENDING)
    public boolean cancelMyRequest(int requestId, int userId) {
        String sql = "UPDATE leave_requests "
                + "SET status = 'CANCELLED' "
                + "WHERE id = ? AND user_id = ? AND status = 'PENDING'";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot cancel leave request", e);
        }
    }

    // 4. Store Manager: Đơn nghỉ phép của chi nhánh
    public List<Map<String, Object>> getBranchRequests(int branchId) {
        String sql = "SELECT lr.id, lr.user_id AS userId, "
                + "ep.full_name AS userName, "
                + "lt.code AS leaveTypeCode, "
                + "lt.name AS leaveTypeName, "
                + "lr.start_date AS startDate, "
                + "lr.end_date AS endDate, "
                + "lr.total_days AS totalDays, "
                + "lr.reason, lr.status, "
                + "lr.manager_response AS managerResponse, "
                + "lr.created_at AS createdAt, "
                + "lr.reviewed_at AS reviewedAt "
                + "FROM leave_requests lr "
                + "JOIN users u ON u.id = lr.user_id "
                + "JOIN employee_profiles ep ON ep.user_id = u.id "
                + "JOIN leave_types lt ON lt.id = lr.leave_type_id "
                + "WHERE ep.home_branch_id = ? "
                + "ORDER BY lr.created_at DESC";

        return queryList(sql, branchId);
    }

    // 5. Store Manager: Duyệt / Từ chối đơn - CÓ TRANSACTION + FOR UPDATE
    public boolean review(
            int requestId,
            int branchId,
            boolean approve,
            String responseText,
            int reviewerId) throws Exception {

        Connection c = null;
        try {
            c = connect();
            c.setAutoCommit(false);

            // Khóa dòng của leave_request trong transaction này
            String lockSql = "SELECT lr.user_id AS userId, "
                    + "ep.home_branch_id AS branchId, "
                    + "lr.leave_type_id AS leaveTypeId, "
                    + "lr.start_date AS startDate, "
                    + "lr.end_date AS endDate, "
                    + "lr.total_days AS totalDays, "
                    + "lr.status "
                    + "FROM leave_requests lr "
                    + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
                    + "WHERE lr.id = ? "
                    + "FOR UPDATE";

            int userId;
            int reqBranchId;
            int leaveTypeId;
            java.sql.Date startDate;
            java.sql.Date endDate;
            int totalDays;
            String status;
            int year;

            try (PreparedStatement ps = c.prepareStatement(lockSql)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        c.rollback();
                        return false;
                    }

                    status = rs.getString("status");
                    userId = rs.getInt("userId");
                    reqBranchId = rs.getInt("branchId");
                    leaveTypeId = rs.getInt("leaveTypeId");
                    startDate = rs.getDate("startDate");
                    endDate = rs.getDate("endDate");
                    totalDays = rs.getInt("totalDays");
                    year = startDate.toLocalDate().getYear();
                }
            }

            if (!"PENDING".equals(status) || reqBranchId != branchId) {
                c.rollback();
                return false;
            }

            // Nếu duyệt: kiểm tra quota còn đủ không
            if (approve && !hasEnoughBalance(
                    c, userId, leaveTypeId, totalDays, year)) {
                c.rollback();
                return false;
            }

            // Cập nhật đơn
            String updateSql = "UPDATE leave_requests "
                    + "SET status = ?, manager_response = ?, "
                    + "reviewed_by = ?, reviewed_at = CURRENT_TIMESTAMP "
                    + "WHERE id = ? AND status = 'PENDING'";

            try (PreparedStatement ps = c.prepareStatement(updateSql)) {
                ps.setString(1, approve ? "APPROVED" : "REJECTED");
                ps.setString(2, responseText);
                ps.setInt(3, reviewerId);
                ps.setInt(4, requestId);

                if (ps.executeUpdate() != 1) {
                    c.rollback();
                    return false;
                }
            }

            // Nếu duyệt: cập nhật ca làm việc + trừ quota
            if (approve) {
                markSchedulesAsLeave(c, userId, startDate, endDate);

                String updateBalance = "UPDATE leave_balances "
                        + "SET used_days = used_days + ? "
                        + "WHERE user_id = ? AND leave_type_id = ? "
                        + "AND year = ? "
                        + "AND total_days > 0";

                try (PreparedStatement ps = c.prepareStatement(updateBalance)) {
                    ps.setInt(1, totalDays);
                    ps.setInt(2, userId);
                    ps.setInt(3, leaveTypeId);
                    ps.setInt(4, year);
                    ps.executeUpdate();
                }
            }

            c.commit();
            return true;

        } catch (Exception e) {
            if (c != null) {
                try {
                    c.rollback();
                } catch (SQLException re) {
                    // ignore
                }
            }
            throw e;
        } finally {
            if (c != null) {
                try {
                    c.setAutoCommit(true);
                    c.close();
                } catch (SQLException e) {
                    // ignore
                }
            }
        }
    }

    // 6. Đánh dấu ca làm việc trong khoảng nghỉ thành "ON_LEAVE"
    // (MySQL không hỗ trợ UPDATE...LIMIT trong mọi version)
    private void markSchedulesAsLeave(
            Connection c,
            int userId,
            java.sql.Date startDate,
            java.sql.Date endDate) throws SQLException {

        String sql = "UPDATE shift_schedules "
                + "SET status = 'ON_LEAVE' "
                + "WHERE user_id = ? "
                + "AND status = 'PUBLISHED' "
                + "AND work_date BETWEEN ? AND ?";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, startDate);
            ps.setDate(3, endDate);
            ps.executeUpdate();
        }
    }

    // 7. Kiểm tra quota còn đủ để duyệt đơn hay không.
    // - Không có dòng balance cho user/loại nghỉ/năm => chưa được cấp quota,
    //   coi như không giới hạn (khớp với logic kiểm tra lúc tạo đơn).
    // - Nếu có dòng balance thì total_days là trần cứng: KHÔNG được vượt.
    private boolean hasEnoughBalance(
            Connection c,
            int userId,
            int leaveTypeId,
            int totalDays,
            int year) throws SQLException {

        String sql = "SELECT total_days, used_days "
                + "FROM leave_balances "
                + "WHERE user_id = ? AND leave_type_id = ? AND year = ? "
                + "FOR UPDATE";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, year);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    // Chưa cấp quota => không giới hạn.
                    // UPDATE used_days sau đó không khớp dòng nào => no-op.
                    return true;
                }

                int total = rs.getInt("total_days");
                int used = rs.getInt("used_days");

                // total_days = 0 nghĩa là loại nghỉ không giới hạn
                // (ví dụ nghỉ không lương) -> vẫn duyệt, nhưng không
                // phải trừ quota vì total = 0.
                if (total <= 0) {
                    return true;
                }

                return (used + totalDays) <= total;
            }
        }
    }

    // 8. Mô tả lý do duyệt/từ chối thất bại để hiển thị cho Store Manager.
    public String getReviewFailureReason(
            int requestId,
            int branchId,
            boolean approve) {

        String sql = "SELECT lr.status, lr.total_days, "
                + "ep.home_branch_id AS branchId, "
                + "lr.leave_type_id AS leaveTypeId, "
                + "YEAR(lr.start_date) AS leaveYear "
                + "FROM leave_requests lr "
                + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
                + "WHERE lr.id = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return "Không tìm thấy đơn nghỉ phép này.";
                }

                String status = rs.getString("status");
                int reqBranchId = rs.getInt("branchId");
                int leaveTypeId = rs.getInt("leaveTypeId");
                int leaveYear = rs.getInt("leaveYear");
                int totalDays = rs.getInt("total_days");

                if (reqBranchId != branchId) {
                    return "Đơn này không thuộc chi nhánh của bạn.";
                }

                if (!"PENDING".equals(status)) {
                    return "Đơn đã được xử lý (trạng thái: "
                        + status + ").";
                }

                if (approve) {
                    int total = 0;
                    int used = 0;

                    String balSql = "SELECT total_days, used_days "
                            + "FROM leave_balances "
                            + "WHERE user_id = (SELECT user_id "
                            + "FROM leave_requests WHERE id = ?) "
                            + "AND leave_type_id = ? AND year = ?";

                    try (PreparedStatement bps =
                            c.prepareStatement(balSql)) {
                        bps.setInt(1, requestId);
                        bps.setInt(2, leaveTypeId);
                        bps.setInt(3, leaveYear);

                        try (ResultSet brs = bps.executeQuery()) {
                            if (brs.next()) {
                                total = brs.getInt("total_days");
                                used = brs.getInt("used_days");
                            }
                        }
                    }

                    if (total > 0 && used + totalDays > total) {
                        return "Nhân viên đã vượt quota: còn "
                            + Math.max(0, total - used)
                            + " ngày nhưng đơn này dùng "
                            + totalDays + " ngày.";
                    }
                }

                return "Không thể thực hiện. Vui lòng kiểm tra lại "
                    + "trạng thái đơn.";
            }

        } catch (Exception e) {
            return "Không thể thực hiện. Vui lòng kiểm tra lại trạng thái đơn.";
        }
    }
}