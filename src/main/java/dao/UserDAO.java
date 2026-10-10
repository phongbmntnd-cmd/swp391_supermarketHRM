package dao;

import context.DBContext;
import model.Role;
import model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /**
     * Hàm kiểm tra thông tin đăng nhập
     */
    public User checkLogin(String username, String password) {
        String sql = "SELECT u.id, u.username, u.email, u.status, u.expiration_date, u.is_first_login, "
                + "r.id AS role_id, r.name AS role_name, r.description AS role_desc, "
                + "ep.full_name, ep.phone, ep.home_branch_id "
                + "FROM users u "
                + "JOIN roles r ON u.role_id = r.id "
                + "LEFT JOIN employee_profiles ep ON u.id = ep.user_id "
                + "WHERE u.username = ? AND u.password_hash = ? AND u.status = 'ACTIVE'";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role role = new Role();
                    role.setId(rs.getInt("role_id"));
                    role.setName(rs.getString("role_name"));
                    role.setDescription(rs.getString("role_desc"));

                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setStatus(rs.getString("status"));
                    user.setExpirationDate(rs.getTimestamp("expiration_date"));
                    user.setFirstLogin(rs.getBoolean("is_first_login"));

                    user.setRole(role);

                    user.setFullName(rs.getString("full_name"));
                    user.setPhone(rs.getString("phone"));
                    user.setHomeBranchId(rs.getInt("home_branch_id"));

                    return user;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiểm tra username đã tồn tại chưa
     */
    public boolean isUsernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra email đã tồn tại chưa
     */
    public boolean isEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM users WHERE TRIM(email) = TRIM(?)";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean changePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password_hash = ?, is_first_login = 0 WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String generateNextCode(String rolePrefix) {
        String sql = "SELECT username FROM users WHERE username LIKE ? ORDER BY id DESC LIMIT 1";
        int nextNumber = 1;

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rolePrefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String maxCode = rs.getString("username");
                    String numberPart = maxCode.replace(rolePrefix, "");
                    nextNumber = Integer.parseInt(numberPart) + 1;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return String.format("%s%03d", rolePrefix, nextNumber);
    }

    public User getUserById(int userId) {
        String sql = "SELECT u.id, u.username, u.email, u.status, u.role_id, "
                + "ep.home_branch_id, ep.full_name, ep.employee_type, "
                + "r.name AS role_name "
                + "FROM users u "
                + "JOIN roles r ON u.role_id = r.id "
                + "LEFT JOIN employee_profiles ep ON u.id = ep.user_id "
                + "WHERE u.id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setStatus(rs.getString("status"));
                    user.setHomeBranchId(rs.getInt("home_branch_id"));
                    user.setFullName(rs.getString("full_name"));

                    Role role = new Role();
                    role.setId(rs.getInt("role_id"));
                    role.setName(rs.getString("role_name"));
                    user.setRole(role);

                    return user;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int getUserRoleId(int userId) {
        String sql = "SELECT role_id FROM users WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("role_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public String getUserStatus(int userId) {
        String sql = "SELECT status FROM users WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getUserBranchId(int userId) {
        String sql = "SELECT home_branch_id FROM employee_profiles WHERE user_id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("home_branch_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<User> getUsersByBranch(int branchId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.id, u.username, u.email, u.status, ep.full_name, ep.phone "
                   + "FROM users u LEFT JOIN employee_profiles ep ON u.id = ep.user_id "
                   + "WHERE ep.home_branch_id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setFullName(rs.getString("full_name"));
                    u.setEmail(rs.getString("email"));
                    u.setPhone(rs.getString("phone"));
                    u.setStatus(rs.getString("status"));
                    list.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateUserStatusWithAudit(
            int userId, String newStatus,
            String auditAction, int actorId, String description) {

        String sqlUpdateStatus = "UPDATE users SET status = ? WHERE id = ?";
        String sqlInsertAudit = "INSERT INTO audit_logs (action, actor_id, target_user_id, description) VALUES (?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateStatus);
            psUpdate.setString(1, newStatus);
            psUpdate.setInt(2, userId);
            int rowsUpdated = psUpdate.executeUpdate();

            if (rowsUpdated == 0) {
                conn.rollback();
                return false;
            }

            PreparedStatement psAudit = conn.prepareStatement(sqlInsertAudit);
            psAudit.setString(1, auditAction);
            psAudit.setInt(2, actorId);
            psAudit.setInt(3, userId);
            psAudit.setString(4, description);
            psAudit.executeUpdate();

            conn.commit();
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (Exception e) { e.printStackTrace(); }
            }
        }
    }
}