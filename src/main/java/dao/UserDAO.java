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
     * @param username Tên đăng nhập
     * @param password Mật khẩu
     * @return Đối tượng User nếu đúng tài khoản/mật khẩu, ngược lại trả về null
     */
    public User checkLogin(String username, String password) {
        // Query JOIN 3 bảng: users, roles, employee_profiles
        String sql = "SELECT u.id, u.username, u.email, u.status, u.expiration_date, u.is_first_login, " +
                     "r.id AS role_id, r.name AS role_name, r.description AS role_desc, " +
                     "ep.full_name, ep.phone, ep.home_branch_id " +
                     "FROM users u " +
                     "JOIN roles r ON u.role_id = r.id " +
                     "LEFT JOIN employee_profiles ep ON u.id = ep.user_id " +
                     "WHERE u.username = ? AND u.password_hash = ? AND u.status = 'ACTIVE'";

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

                    // 2. Khởi tạo đối tượng User và map dữ liệu từ ResultSet
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setStatus(rs.getString("status"));
                    user.setExpirationDate(rs.getTimestamp("expiration_date"));
                    user.setFirstLogin(rs.getBoolean("is_first_login"));
                    
                    // Gán Role vào User
                    user.setRole(role);

                    // Lấy các thông tin từ bảng employee_profiles
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
}