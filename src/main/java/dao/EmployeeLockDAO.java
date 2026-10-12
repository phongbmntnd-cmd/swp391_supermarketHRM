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

    /** Cache để không kiểm tra nhiều lần trong 1 request */
    private static boolean tableExistsChecked = false;

    /**
     * Tạo lock record mới
     * @param userId User bị lock
     * @param lockedBy Store Manager thực hiện lock
     * @param reason Lý do lock
     * @return true nếu thành công
     */
    public boolean createLock(int userId, int lockedBy, String reason) {
        // Đảm bảo bảng tồn tại trước khi insert
        ensureTableExists();
        String sql = "INSERT INTO employee_locks (user_id, locked_by, reason, is_active) VALUES (?, ?, ?, TRUE)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, lockedBy);
            ps.setString(3, reason);

            int rows = ps.executeUpdate();
            System.out.println("[EmployeeLockDAO] createLock userId=" + userId + " lockedBy=" + lockedBy + " rows=" + rows);
            return rows > 0;
        } catch (Exception e) {
            System.out.println("[EmployeeLockDAO] createLock ERROR: " + e.getMessage());
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
        ensureTableExists();
        String sql = "UPDATE employee_locks SET is_active = FALSE, unlocked_by = ?, unlocked_at = CURRENT_TIMESTAMP "
                   + "WHERE user_id = ? AND is_active = TRUE";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, unlockedBy);
            ps.setInt(2, userId);

            int rows = ps.executeUpdate();
            System.out.println("[EmployeeLockDAO] unlock userId=" + userId + " unlockedBy=" + unlockedBy + " rows=" + rows);
            return rows > 0;
        } catch (Exception e) {
            System.out.println("[EmployeeLockDAO] unlock ERROR: " + e.getMessage());
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
     * Tự động tạo bảng employee_locks nếu chưa tồn tại.
     * An toàn: dùng IF NOT EXISTS, không phá dữ liệu cũ.
     */
    public synchronized void ensureTableExists() {
        if (tableExistsChecked) {
            return;
        }
        boolean exists = isTableExists();
        if (!exists) {
            String createSql = "CREATE TABLE IF NOT EXISTS employee_locks ("
                    + "  id INT NOT NULL AUTO_INCREMENT,"
                    + "  user_id INT NOT NULL,"
                    + "  locked_by INT NOT NULL,"
                    + "  unlocked_by INT DEFAULT NULL,"
                    + "  reason TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,"
                    + "  locked_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,"
                    + "  unlocked_at TIMESTAMP NULL DEFAULT NULL,"
                    + "  is_active TINYINT(1) DEFAULT 1,"
                    + "  PRIMARY KEY (id),"
                    + "  KEY idx_user (user_id),"
                    + "  KEY idx_locked_by (locked_by),"
                    + "  KEY idx_locked_at (locked_at),"
                    + "  KEY idx_is_active (is_active),"
                    + "  KEY idx_user_active (user_id, is_active),"
                    + "  KEY fk_unlock_by (unlocked_by),"
                    + "  CONSTRAINT fk_lock_by FOREIGN KEY (locked_by) REFERENCES users(id) ON DELETE CASCADE,"
                    + "  CONSTRAINT fk_lock_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,"
                    + "  CONSTRAINT fk_unlock_by FOREIGN KEY (unlocked_by) REFERENCES users(id) ON DELETE SET NULL"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";
            try (Connection conn = new DBContext().getConnection();
                 PreparedStatement ps = conn.prepareStatement(createSql)) {
                ps.execute();
                System.out.println("[EmployeeLockDAO] Đã tự động tạo bảng employee_locks");
            } catch (Exception e) {
                System.out.println("[EmployeeLockDAO] ensureTableExists ERROR: " + e.getMessage());
                e.printStackTrace();
            }
        }
        tableExistsChecked = true;
    }

    /**
     * Lấy danh sách nhân viên bị khóa của 1 branch (phân trang)
     * @param branchId Branch ID
     * @param search Từ khóa tìm kiếm (tên, username, email, SĐT)
     * @param reasonSearch Từ khóa tìm kiếm lý do (optional)
     * @param lockedBySearch Từ khóa tìm kiếm người khóa (optional)
     * @param offset Vị trí bắt đầu
     * @param limit Số lượng limit
     * @return Danh sách EmployeeLock
     */
    public List<EmployeeLock> getLockedEmployeesByBranch(int branchId, String search, String reasonSearch, String lockedBySearch, int offset, int limit) {
        List<EmployeeLock> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT el.id, el.user_id, el.locked_by, el.unlocked_by, el.reason, el.locked_at, el.unlocked_at, el.is_active, ");
        sql.append("locked_ep.full_name AS locked_by_name, ");
        sql.append("IFNULL(unlocked_ep.full_name, '') AS unlocked_by_name, ");
        sql.append("user_ep.full_name AS user_name, ");
        sql.append("u.username, u.email, u.status, user_ep.phone, ");
        sql.append("IFNULL(p.title, '') AS position_name, ");
        sql.append("IFNULL(d.name, '') AS department_name, ");
        sql.append("IFNULL(user_ep.employee_type, '') AS employee_type ");
        sql.append("FROM employee_locks el ");
        sql.append("JOIN employee_profiles user_ep ON el.user_id = user_ep.user_id ");
        sql.append("JOIN users u ON el.user_id = u.id ");
        sql.append("JOIN employee_profiles locked_ep ON el.locked_by = locked_ep.user_id ");
        sql.append("LEFT JOIN employee_profiles unlocked_ep ON el.unlocked_by = unlocked_ep.user_id ");
        sql.append("LEFT JOIN positions p ON user_ep.position_id = p.id ");
        sql.append("LEFT JOIN departments d ON user_ep.department_id = d.id ");
        sql.append("WHERE el.is_active = TRUE AND user_ep.home_branch_id = ? ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (user_ep.full_name LIKE ? OR u.username LIKE ? OR u.email LIKE ? OR user_ep.phone LIKE ?) ");
        }
        if (reasonSearch != null && !reasonSearch.trim().isEmpty()) {
            sql.append("AND el.reason LIKE ? ");
        }
        if (lockedBySearch != null && !lockedBySearch.trim().isEmpty()) {
            sql.append("AND locked_ep.full_name LIKE ? ");
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
                ps.setString(paramIndex++, searchPattern);
            }
            if (reasonSearch != null && !reasonSearch.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + reasonSearch.trim() + "%");
            }
            if (lockedBySearch != null && !lockedBySearch.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + lockedBySearch.trim() + "%");
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
     * @param reasonSearch Từ khóa tìm kiếm lý do
     * @param lockedBySearch Từ khóa tìm kiếm người khóa
     * @return Số lượng
     */
    public int countLockedEmployeesByBranch(int branchId, String search, String reasonSearch, String lockedBySearch) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM employee_locks el ");
        sql.append("JOIN employee_profiles user_ep ON el.user_id = user_ep.user_id ");
        sql.append("JOIN users u ON el.user_id = u.id ");
        sql.append("JOIN employee_profiles locked_ep ON el.locked_by = locked_ep.user_id ");
        sql.append("WHERE el.is_active = TRUE AND user_ep.home_branch_id = ? ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (user_ep.full_name LIKE ? OR u.username LIKE ? OR u.email LIKE ? OR user_ep.phone LIKE ?) ");
        }
        if (reasonSearch != null && !reasonSearch.trim().isEmpty()) {
            sql.append("AND el.reason LIKE ? ");
        }
        if (lockedBySearch != null && !lockedBySearch.trim().isEmpty()) {
            sql.append("AND locked_ep.full_name LIKE ? ");
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
                ps.setString(paramIndex++, searchPattern);
            }
            if (reasonSearch != null && !reasonSearch.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + reasonSearch.trim() + "%");
            }
            if (lockedBySearch != null && !lockedBySearch.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + lockedBySearch.trim() + "%");
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
        try {
            lock.setPositionName(rs.getString("position_name"));
            lock.setDepartmentName(rs.getString("department_name"));
            lock.setEmployeeType(rs.getString("employee_type"));
        } catch (java.sql.SQLException ignore) {
            // backward compatibility if columns not yet added
        }
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
