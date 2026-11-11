package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.LinkedHashMap;

public class RecruitmentRequestDAO {

    // SM tạo đề xuất tuyển dụng nhân sự
    public boolean createRequest(
            int branchId,
            int requestedBy,
            int positionId,
            int quantity,
            String employmentType,
            String shiftType,
            LocalDate targetDate,
            String reason) throws SQLException {

        if (branchId <= 0 || requestedBy <= 0
                || positionId <= 0 || quantity <= 0
                || quantity > 100
                || (!"FULL_TIME".equals(employmentType)
                && !"PART_TIME".equals(employmentType))
                || shiftType == null || shiftType.trim().isEmpty()
                || targetDate == null
                || targetDate.isBefore(LocalDate.now())
                || reason == null || reason.trim().isEmpty()) {
            return false;
        }

        String sql
                = "INSERT INTO recruitment_requests "
                + "(branch_id, requested_by, position_id, "
                + "quantity, employment_type, shift_type, "
                + "target_date, reason, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setInt(2, requestedBy);
            ps.setInt(3, positionId);
            ps.setInt(4, quantity);
            ps.setString(5, employmentType);
            ps.setString(6, shiftType);
            ps.setDate(7, Date.valueOf(targetDate));
            ps.setString(8, reason.trim());

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException(
                    "Không thể tạo đề xuất tuyển dụng", e);
        }
    }

    /**
     * Phương thức đọc dữ liệu data hiển thị lịch sử đề xuất tuyển dụng.
     *
     * @param branchId
     * @return
     * @throws SQLException
     */
    public List<Map<String, Object>> getByBranch(int branchId)
            throws SQLException {

        List<Map<String, Object>> requests = new ArrayList<>();

        String sql = "SELECT rr.id, rr.branch_id, "
                + "rr.position_id, p.title AS positionTitle, "
                + "rr.quantity, "
                + "rr.employment_type AS employmentType, "
                + "rr.shift_type AS shiftType, "
                + "rr.target_date AS targetDate, "
                + "rr.reason, rr.status, "
                + "rr.hr_note AS hrNote, "
                + "rr.created_at AS createdAt "
                + "FROM recruitment_requests rr "
                + "JOIN positions p ON p.id = rr.position_id "
                + "WHERE rr.branch_id = ? "
                + "ORDER BY rr.created_at DESC, rr.id DESC";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, branchId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    row.put("id", rs.getInt("id"));
                    row.put("positionTitle",
                            rs.getString("positionTitle"));
                    row.put("quantity", rs.getInt("quantity"));
                    row.put("employmentType",
                            rs.getString("employmentType"));
                    row.put("shiftType",
                            rs.getString("shiftType"));
                    row.put("targetDate",
                            rs.getDate("targetDate"));
                    row.put("reason", rs.getString("reason"));
                    row.put("status", rs.getString("status"));
                    row.put("hrNote", rs.getString("hrNote"));
                    row.put("createdAt",
                            rs.getTimestamp("createdAt"));

                    requests.add(row);
                }
            }

        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException(
                    "Không thể lấy lịch sử đề xuất tuyển dụng.", e);
        }

        return requests;
    }

    public List<Map<String, Object>> getAllRequests()
            throws SQLException {

        List<Map<String, Object>> requests = new ArrayList<>();

        String sql = "SELECT rr.id, rr.branch_id AS branchId, "
                + "b.name AS branchName, "
                + "p.title AS positionTitle, "
                + "rr.quantity, "
                + "rr.employment_type AS employmentType, "
                + "rr.shift_type AS shiftType, "
                + "rr.target_date AS targetDate, "
                + "rr.reason, rr.status, "
                + "rr.hr_note AS hrNote, "
                + "rr.created_at AS createdAt "
                + "FROM recruitment_requests rr "
                + "JOIN branches b ON b.id = rr.branch_id "
                + "JOIN positions p ON p.id = rr.position_id "
                + "ORDER BY CASE WHEN rr.status = 'PENDING' THEN 0 ELSE 1 END, "
                + "rr.created_at DESC, rr.id DESC";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();

                row.put("id", rs.getInt("id"));
                row.put("branchId", rs.getInt("branchId"));
                row.put("branchName", rs.getString("branchName"));
                row.put("positionTitle", rs.getString("positionTitle"));
                row.put("quantity", rs.getInt("quantity"));
                row.put("employmentType", rs.getString("employmentType"));
                row.put("shiftType", rs.getString("shiftType"));
                row.put("targetDate", rs.getDate("targetDate"));
                row.put("reason", rs.getString("reason"));
                row.put("status", rs.getString("status"));
                row.put("hrNote", rs.getString("hrNote"));
                row.put("createdAt", rs.getTimestamp("createdAt"));

                requests.add(row);
            }

        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException(
                    "Không thể tải danh sách đề xuất tuyển dụng.", e);
        }

        return requests;
    }

    public boolean reviewRequest(
            int requestId,
            int reviewerId,
            boolean approved,
            String hrNote) throws SQLException {

        if (requestId <= 0 || reviewerId <= 0) {
            return false;
        }

        // Nếu từ chối thì bắt buộc phải có lý do
        if (!approved && (hrNote == null || hrNote.trim().isEmpty())) {
            return false;
        }

        if (hrNote != null && hrNote.length() > 2000) {
            return false;
        }

        String sql = "UPDATE recruitment_requests "
                + "SET status = ?, "
                + "reviewed_by = ?, "
                + "reviewed_at = CURRENT_TIMESTAMP, "
                + "hr_note = ? "
                + "WHERE id = ? AND status = 'PENDING'";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, approved ? "APPROVED" : "REJECTED");
            ps.setInt(2, reviewerId);
            ps.setString(3, hrNote == null ? null : hrNote.trim());
            ps.setInt(4, requestId);

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException(
                    "Không thể duyệt đề xuất tuyển dụng.", e);
        }
    }

    public Map<String, Object> getApprovedRequestById(int requestId)
            throws SQLException {

        String sql = "SELECT rr.id, rr.branch_id AS branchId, "
                + "rr.position_id AS positionId, "
                + "p.department_id AS departmentId, "
                + "rr.employment_type AS employmentType, "
                + "rr.shift_type AS shiftType, "
                + "rr.target_date AS targetDate "
                + "FROM recruitment_requests rr "
                + "JOIN positions p ON p.id = rr.position_id "
                + "WHERE rr.id = ? AND rr.status = 'APPROVED'";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> result = new LinkedHashMap<>();

                    result.put("id", rs.getInt("id"));
                    result.put("branchId", rs.getInt("branchId"));
                    result.put("positionId", rs.getInt("positionId"));
                    result.put("departmentId", rs.getInt("departmentId"));
                    result.put("employmentType",
                            rs.getString("employmentType"));
                    result.put("shiftType",
                            rs.getString("shiftType"));
                    result.put("targetDate",
                            rs.getDate("targetDate"));

                    return result;
                }
            }

        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException(
                    "Không thể lấy thông tin đề xuất tuyển dụng.", e);
        }

        return null;
    }

}
