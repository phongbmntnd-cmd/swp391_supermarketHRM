package dao;

import context.DBContext; // Nhớ import class DBContext dùng để kết nối database của nhóm bạn
import model.Role;
import model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    /**
     * Hàm kiểm tra thông tin đăng nhập
     *
     * @param username Tên đăng nhập
     * @param password Mật khẩu
     * @return Đối tượng User nếu đúng tài khoản/mật khẩu, ngược lại trả về null
     */
    public User checkLogin(String username, String password) {
    String sql = "SELECT u.id, u.username, u.email, u.status, u.expiration_date, u.is_first_login, "
               + "r.id AS role_id, r.name AS role_name, r.description AS role_desc, "
               + "ep.full_name, ep.phone, ep.home_branch_id "
               + "FROM users u "
               + "JOIN roles r ON u.role_id = r.id "
               + "LEFT JOIN employee_profiles ep ON u.id = ep.user_id "
               + "WHERE u.username = ? AND u.password_hash = ? AND u.status = 'ACTIVE'";

    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, username);
        ps.setString(2, password);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                // 1. Khởi tạo đối tượng Role
                Role role = new Role();
                role.setId(rs.getInt("role_id"));
                role.setName(rs.getString("role_name"));
                role.setDescription(rs.getString("role_desc"));

                // 2. Khởi tạo đối tượng User
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setStatus(rs.getString("status"));
                user.setExpirationDate(rs.getTimestamp("expiration_date"));
                user.setFirstLogin(rs.getBoolean("is_first_login"));

                // Gán Role vào User
                user.setRole(role);

                // Lấy thông tin từ employee_profiles
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
     * Hàm tạo tài khoản và hồ sơ nhân viên trong 1 Transaction
     */
    public boolean createUserWithProfile(
            String username, String email, int roleId, String expirationDate,
            String fullName, String phone, String identityCard,
            int homeBranchId, int positionId, int departmentId, String employeeType) {

        String sqlUser = "INSERT INTO users (username, password_hash, email, status, expiration_date, role_id, is_first_login) "
                + "VALUES (?, '123456', ?, 'ACTIVE', ?, ?, 1)";

        String sqlProfile = "INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Chèn vào bảng users
            PreparedStatement psUser = conn.prepareStatement(sqlUser, PreparedStatement.RETURN_GENERATED_KEYS);
            psUser.setString(1, username);
            psUser.setString(2, (email == null || email.trim().isEmpty()) ? null : email.trim());

            if (expirationDate != null && !expirationDate.isEmpty()) {
                psUser.setString(3, expirationDate + " 23:59:59");
            } else {
                psUser.setNull(3, java.sql.Types.TIMESTAMP);
            }

            psUser.setInt(4, roleId);

            int affectedRows = psUser.executeUpdate();
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }

            // Lấy ID vừa được tạo
            int generatedUserId = 0;
            try (ResultSet generatedKeys = psUser.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    generatedUserId = generatedKeys.getInt(1);
                } else {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Chèn vào bảng employee_profiles
            PreparedStatement psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setInt(1, generatedUserId);
            psProfile.setString(2, fullName);
            psProfile.setString(3, phone);
            psProfile.setString(4, identityCard);
            psProfile.setInt(5, homeBranchId);
            psProfile.setInt(6, positionId);
            psProfile.setInt(7, departmentId);
            psProfile.setString(8, employeeType);

            psProfile.executeUpdate();

            conn.commit(); // Hoàn tất Transaction
            return true;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
    // Kiểm tra trùng Username

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

// Kiểm tra trùng Email (Chỉ check khi email không rỗng)
    public boolean isEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM users WHERE email = ?";
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

// Kiểm tra trùng Số CCCD/CMND
    public boolean isIdentityCardExists(String identityCard) {
        String sql = "SELECT 1 FROM employee_profiles WHERE identity_card = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, identityCard);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Đổi mật khẩu và cập nhật is_first_login về 0
     */
    public boolean changePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password_hash = ?, is_first_login = 0 WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPassword); // Nếu có dùng Mã hóa (BCrypt/MD5) thì mã hóa ở đây
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
