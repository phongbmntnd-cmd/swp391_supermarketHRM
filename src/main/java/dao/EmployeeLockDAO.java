package dao;

import context.DBContext;
import model.EmployeeLock;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng employee_locks
 */
public class EmployeeLockDAO {

    /**
     * Tạo lock record mới
     * @param userId User bị lock
     * @param lockedBy Store Manager thực hiện lock
     * @param reason Lý do lock
     * @return true nếu thành công
     */
    public boolean createLock(int userId, int lockedBy, String reason) {
        String sql = "INSERT INTO employee_locks (user_id, locked_by, reason, is_active) VALUES (?, ?, ?, TRUE)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, lockedBy);
            ps.setString(3, reason);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Unlock - đánh dấu lock record là inactive và cập nhật unlocked_by
     * @param userId User được unlock
     * @param unlockedBy Store Manager thực hiện unlock
     * @return true nếu thành công
     */
    public boolean unlock(int userId, int unlockedBy) {
        String sql = "UPDATE employee_locks SET is_active = FALSE, unlocked_by = ?, unlocked_at = CURRENT_TIMESTAMP "
                   + "WHERE user_id = ? AND is_active = TRUE";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, unlockedBy);
            ps.setInt(2, userId);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra user có đang bị lock không
     * @param userId User ID
     * @return true nếu đang bị lock
     */
    public boolean isLocked(int userId) {
        String sql = "SELECT COUNT(*) FROM employee_locks WHERE user_id = ? AND is_active = TRUE";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy lock record hiện tại của user
     * @param userId User ID
     * @return EmployeeLock object hoặc null
     */
    public EmployeeLock getActiveLock(int userId) {
        String sql = "SELECT el.id, el.user_id, el.locked_by, el.unlocked_by, el.reason, el.locked_at, el.unlocked_at, el.is_active, "
                   + "locked_ep.full_name AS locked_by_name, "
                   + "IFNULL(unlocked_ep.full_name, '') AS unlocked_by_name, "
                   + "user_ep.full_name AS user_name "
                   + "FROM employee_locks el "
                   + "JOIN employee_profiles locked_ep ON el.locked_by = locked_ep.user_id "
                   + "LEFT JOIN employee_profiles unlocked_ep ON el.unlocked_by = unlocked_ep.user_id "
                   + "JOIN employee_profiles user_ep ON el.user_id = user_ep.user_id "
                   + "WHERE el.user_id = ? AND el.is_active = TRUE";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToLock(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy lịch sử lock của user
     * @param userId User ID
     * @return Danh sách EmployeeLock
     */
    public List<EmployeeLock> getLockHistory(int userId) {
        List<EmployeeLock> list = new ArrayList<>();
        String sql = "SELECT el.id, el.user_id, el.locked_by, el.unlocked_by, el.reason, el.locked_at, el.unlocked_at, el.is_active, "
                   + "locked_ep.full_name AS locked_by_name, "
                   + "IFNULL(unlocked_ep.full_name, '') AS unlocked_by_name, "
                   + "user_ep.full_name AS user_name "
                   + "FROM employee_locks el "
                   + "JOIN employee_profiles locked_ep ON el.locked_by = locked_ep.user_id "
                   + "LEFT JOIN employee_profiles unlocked_ep ON el.unlocked_by = unlocked_ep.user_id "
                   + "JOIN employee_profiles user_ep ON el.user_id = user_ep.user_id "
                   + "WHERE el.user_id = ? "
                   + "ORDER BY el.locked_at DESC";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLock(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiểm tra bảng employee_locks có tồn tại không
     * @return true nếu bảng tồn tại
     */
    public boolean isTableExists() {
        String sql = "SELECT COUNT(*) FROM information_schema.tables "
                   + "WHERE table_schema = 'swp391_supermarket' AND table_name = 'employee_locks'";
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
     * Lấy danh sách nhân viên bị khóa của 1 branch (phân trang)
     * @param branchId Branch ID
     * @param search Từ khóa tìm kiếm
     * @param offset Vị trí bắt đầu
     * @param limit Số lượng limit
     * @return Danh sách EmployeeLock
     */
    public List<EmployeeLock> getLockedEmployeesByBranch(int branchId, String search, int offset, int limit) {
        List<EmployeeLock> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT el.id, el.user_id, el.locked_by, el.unlocked_by, el.reason, el.locked_at, el.unlocked_at, el.is_active, ");
        sql.append("locked_ep.full_name AS locked_by_name, ");
        sql.append("IFNULL(unlocked_ep.full_name, '') AS unlocked_by_name, ");
        sql.append("user_ep.full_name AS user_name, ");
        sql.append("u.username, u.email, u.status, user_ep.phone ");
        sql.append("FROM employee_locks el ");
        sql.append("JOIN employee_profiles user_ep ON el.user_id = user_ep.user_id ");
        sql.append("JOIN users u ON el.user_id = u.id ");
        sql.append("JOIN employee_profiles locked_ep ON el.locked_by = locked_ep.user_id ");
        sql.append("LEFT JOIN employee_profiles unlocked_ep ON el.unlocked_by = unlocked_ep.user_id ");
        sql.append("WHERE el.is_active = TRUE AND user_ep.home_branch_id = ? ");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (user_ep.full_name LIKE ? OR u.username LIKE ? OR u.email LIKE ?) ");
        }
        
        sql.append("ORDER BY el.locked_at DESC LIMIT ? OFFSET ?");
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setInt(paramIndex++, branchId);
            
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLockWithUser(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số nhân viên bị khóa của 1 branch
     * @param branchId Branch ID
     * @param search Từ khóa tìm kiếm
     * @return Số lượng
     */
    public int countLockedEmployeesByBranch(int branchId, String search) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM employee_locks el ");
        sql.append("JOIN employee_profiles user_ep ON el.user_id = user_ep.user_id ");
        sql.append("JOIN users u ON el.user_id = u.id ");
        sql.append("WHERE el.is_active = TRUE AND user_ep.home_branch_id = ? ");
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (user_ep.full_name LIKE ? OR u.username LIKE ? OR u.email LIKE ?) ");
        }
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setInt(paramIndex++, branchId);
            
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Map ResultSet to EmployeeLock với thông tin user bổ sung
     */
    private EmployeeLock mapResultSetToLockWithUser(ResultSet rs) throws Exception {
        EmployeeLock lock = mapResultSetToLock(rs);
        lock.setUsername(rs.getString("username"));
        lock.setEmail(rs.getString("email"));
        lock.setPhone(rs.getString("phone"));
        return lock;
    }

    /**
     * Map ResultSet to EmployeeLock
     */
    private EmployeeLock mapResultSetToLock(ResultSet rs) throws Exception {
        EmployeeLock lock = new EmployeeLock();
        lock.setId(rs.getInt("id"));
        lock.setUserId(rs.getInt("user_id"));
        lock.setLockedBy(rs.getInt("locked_by"));
        
        int unlockedBy = rs.getInt("unlocked_by");
        if (!rs.wasNull()) {
            lock.setUnlockedBy(unlockedBy);
        }
        
        lock.setReason(rs.getString("reason"));
        lock.setLockedAt(rs.getTimestamp("locked_at"));
        lock.setUnlockedAt(rs.getTimestamp("unlocked_at"));
        lock.setActive(rs.getBoolean("is_active"));
        
        lock.setLockedByName(rs.getString("locked_by_name"));
        lock.setUnlockedByName(rs.getString("unlocked_by_name"));
        lock.setUserName(rs.getString("user_name"));
        
        return lock;
    }
}
