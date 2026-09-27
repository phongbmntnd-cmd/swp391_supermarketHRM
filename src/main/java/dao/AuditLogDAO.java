package dao;

import context.DBContext;
import model.AuditLog;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng audit_logs
 */
public class AuditLogDAO {

    /**
     * Ghi log khi thực hiện Lock/Unlock
     * @param action Action (EMERGENCY_LOCK, EMERGENCY_UNLOCK)
     * @param actorId Người thực hiện (Store Manager)
     * @param targetUserId User bị ảnh hưởng
     * @param description Mô tả thêm (lý do)
     * @return true nếu thành công
     */
    public boolean insertLog(String action, int actorId, int targetUserId, String description) {
        String sql = "INSERT INTO audit_logs (action, actor_id, target_user_id, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, action);
            ps.setInt(2, actorId);
            ps.setInt(3, targetUserId);
            ps.setString(4, description);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy lịch sử audit log của một user
     * @param userId User ID
     * @return Danh sách AuditLog
     */
    public List<AuditLog> getLogsByUserId(int userId) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.id, al.action, al.actor_id, al.target_user_id, al.description, al.created_at, "
                   + "actor_ep.full_name AS actor_name, target_ep.full_name AS target_name "
                   + "FROM audit_logs al "
                   + "JOIN employee_profiles actor_ep ON al.actor_id = actor_ep.user_id "
                   + "JOIN employee_profiles target_ep ON al.target_user_id = target_ep.user_id "
                   + "WHERE al.target_user_id = ? OR al.actor_id = ? "
                   + "ORDER BY al.created_at DESC";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = mapResultSetToLog(rs);
                    list.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy lịch sử audit log trong một branch
     * @param branchId Branch ID
     * @return Danh sách AuditLog
     */
    public List<AuditLog> getLogsByBranchId(int branchId) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.id, al.action, al.actor_id, al.target_user_id, al.description, al.created_at, "
                   + "actor_ep.full_name AS actor_name, target_ep.full_name AS target_name "
                   + "FROM audit_logs al "
                   + "JOIN employee_profiles actor_ep ON al.actor_id = actor_ep.user_id "
                   + "JOIN employee_profiles target_ep ON al.target_user_id = target_ep.user_id "
                   + "WHERE actor_ep.home_branch_id = ? OR target_ep.home_branch_id = ? "
                   + "ORDER BY al.created_at DESC";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, branchId);
            ps.setInt(2, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = mapResultSetToLog(rs);
                    list.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiểm tra bảng audit_logs có tồn tại không
     * @return true nếu bảng tồn tại
     */
    public boolean isTableExists() {
        String sql = "SELECT COUNT(*) FROM information_schema.tables "
                   + "WHERE table_schema = 'swp391_supermarket' AND table_name = 'audit_logs'";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Map ResultSet to AuditLog
     */
    private AuditLog mapResultSetToLog(ResultSet rs) throws Exception {
        AuditLog log = new AuditLog();
        log.setId(rs.getInt("id"));
        log.setAction(rs.getString("action"));
        log.setActorId(rs.getInt("actor_id"));
        log.setTargetUserId(rs.getInt("target_user_id"));
        log.setDescription(rs.getString("description"));
        log.setCreatedAt(rs.getTimestamp("created_at"));
        log.setActorName(rs.getString("actor_name"));
        log.setTargetUserName(rs.getString("target_name"));
        return log;
    }
}
