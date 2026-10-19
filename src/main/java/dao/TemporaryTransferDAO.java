package dao;

import context.DBContext;
import model.TemporaryTransfer;
import model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TemporaryTransferDAO {

    /**
     * Tạo mới một đề xuất điều chuyển nhân sự
     */
    public boolean insertTransferProposal(TemporaryTransfer transfer) {
        String sql = "INSERT INTO temporary_transfers (requester_id, destination_store_id, source_store_id, "
                   + "position_id, shift_id, work_date, required_count, reason, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING_MANAGER')";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, transfer.getRequesterId());
            ps.setInt(2, transfer.getDestinationStoreId());
            ps.setInt(3, transfer.getSourceStoreId());
            ps.setInt(4, transfer.getPositionId());
            ps.setInt(5, transfer.getShiftId());
            ps.setDate(6, transfer.getWorkDate());
            ps.setInt(7, transfer.getRequiredCount());
            ps.setString(8, transfer.getReason());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách các đề xuất điều chuyển theo cơ sở
     */
    public List<TemporaryTransfer> getTransfersByStore(int storeId, boolean isSourceStore) {
        List<TemporaryTransfer> list = new ArrayList<>();
        String condition = isSourceStore ? "t.source_store_id = ?" : "t.destination_store_id = ?";
        
        String sql = "SELECT t.*, ep_req.full_name AS requester_name, "
                   + "b1.name AS destination_store_name, b2.name AS source_store_name, "
                   + "p.title AS position_name, s.name AS shift_name, ep_emp.full_name AS employee_name "
                   + "FROM temporary_transfers t "
                   + "LEFT JOIN employee_profiles ep_req ON t.requester_id = ep_req.user_id "
                   + "JOIN branches b1 ON t.destination_store_id = b1.id "
                   + "JOIN branches b2 ON t.source_store_id = b2.id "
                   + "JOIN positions p ON t.position_id = p.id "
                   + "JOIN shifts s ON t.shift_id = s.id "
                   + "LEFT JOIN employee_profiles ep_emp ON t.employee_id = ep_emp.user_id "
                   + "WHERE " + condition + " ORDER BY t.created_at DESC";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, storeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TemporaryTransfer t = new TemporaryTransfer();
                    t.setId(rs.getInt("id"));
                    t.setRequesterId(rs.getInt("requester_id"));
                    t.setDestinationStoreId(rs.getInt("destination_store_id"));
                    t.setSourceStoreId(rs.getInt("source_store_id"));
                    t.setPositionId(rs.getInt("position_id"));
                    t.setShiftId(rs.getInt("shift_id"));
                    t.setWorkDate(rs.getDate("work_date"));
                    t.setRequiredCount(rs.getInt("required_count"));
                    
                    int empId = rs.getInt("employee_id");
                    if (!rs.wasNull()) {
                        t.setEmployeeId(empId);
                    }
                    
                    t.setReason(rs.getString("reason"));
                    t.setRejectReason(rs.getString("reject_reason"));
                    t.setStatus(rs.getString("status"));
                    t.setCreatedAt(rs.getTimestamp("created_at"));
                    t.setUpdatedAt(rs.getTimestamp("updated_at"));

                    // Gán các giá trị hiển thị tên
                    t.setRequesterName(rs.getString("requester_name") != null ? rs.getString("requester_name") : "Manager");
                    t.setDestinationStoreName(rs.getString("destination_store_name"));
                    t.setSourceStoreName(rs.getString("source_store_name"));
                    t.setPositionName(rs.getString("position_name"));
                    t.setShiftName(rs.getString("shift_name"));
                    t.setEmployeeName(rs.getString("employee_name"));

                    list.add(t);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách nhân viên thuộc cơ sở để Store Manager cử đi hỗ trợ
     */
    public List<User> getEmployeesByBranch(int branchId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.id, u.username, ep.full_name, p.title AS position_name "
                   + "FROM users u "
                   + "JOIN employee_profiles ep ON u.id = ep.user_id "
                   + "LEFT JOIN positions p ON ep.position_id = p.id "
                   + "WHERE ep.home_branch_id = ? AND u.status = 'ACTIVE'";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setFullName(rs.getString("full_name"));
                    u.setPositionName(rs.getString("position_name"));
                    list.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Phê duyệt yêu cầu điều chuyển
     */
    public boolean approveTransfer(int requestId, int employeeId) {
        String sql = "UPDATE temporary_transfers SET status = 'APPROVED', employee_id = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Từ chối yêu cầu điều chuyển
     */
    public boolean rejectTransfer(int requestId) {
        String sql = "UPDATE temporary_transfers SET status = 'REJECTED', updated_at = NOW() WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}