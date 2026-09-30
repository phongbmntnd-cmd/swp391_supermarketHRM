package dao;

import context.DBContext; // Nhớ import class DBContext dùng để kết nối database của nhóm bạn
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

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

    // Kiểm tra trùng Số điện thoại
    public boolean isPhoneExists(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM employee_profiles WHERE phone = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
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

    /**
     * Sinh mã nhân viên tiếp theo theo tiền tố (NV, QL, HR)
     *
     * @param rolePrefix Tiền tố mã (NV, QL, HR)
     * @return Mã tiếp theo dạng NV001, QL001, HR001
     */
    public String generateNextCode(String rolePrefix) {
        String sql = "SELECT username FROM users WHERE username LIKE ? ORDER BY id DESC LIMIT 1";
        int nextNumber = 1;

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rolePrefix + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String maxCode = rs.getString("username");
                    // Lấy phần số phía sau tiền tố (VD: "NV005" lấy ra "005" -> chuyển thành số 5)
                    String numberPart = maxCode.replace(rolePrefix, "");
                    nextNumber = Integer.parseInt(numberPart) + 1;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Định dạng lại thành 3 chữ số (VD: 1 thành "001", kết hợp với tiền tố thành "NV001")
        return String.format("%s%03d", rolePrefix, nextNumber);
    }

    // =====================================================
    // CÁC METHOD MỚI CHO ĐẠT 2 - STORE MANAGER
    // =====================================================
    /**
     * Tìm User theo ID
     *
     * @param userId User ID
     * @return User object hoặc null nếu không tìm thấy
     */
    public model.User getUserById(int userId) {
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
                    model.User user = new model.User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setStatus(rs.getString("status"));
                    user.setHomeBranchId(rs.getInt("home_branch_id"));
                    user.setFullName(rs.getString("full_name"));

                    model.Role role = new model.Role();
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

    /**
     * Lấy Role ID của User
     *
     * @param userId User ID
     * @return Role ID hoặc -1 nếu không tìm thấy
     */
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

    /**
     * Lấy Status của User
     *
     * @param userId User ID
     * @return Status string hoặc null nếu không tìm thấy
     */
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

    /**
     * Cập nhật Status của User (dùng cho Lock/Unlock)
     *
     * @param userId User ID
     * @param newStatus Status mới (ACTIVE, EMERGENCY_LOCKED)
     * @return true nếu thành công
     */
    public boolean updateUserStatus(int userId, String newStatus) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Khóa khẩn cấp tài khoản nhân viên (giữ để tương thích ngược)
     *
     * @param userId User ID
     * @param status Trạng thái (LOCKED, ACTIVE, ...)
     * @return true nếu thành công
     */
    public boolean updateStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status); // Truyền vào "LOCKED"
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy Branch ID của User từ employee_profiles
     *
     * @param userId User ID
     * @return Branch ID hoặc -1 nếu không tìm thấy
     */
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

    /**
     * Lấy danh sách nhân viên theo mã chi nhánh
     *
     * @param branchId Branch ID
     * @return Danh sách User
     */
    public List<User> getUsersByBranch(int branchId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE home_branch_id = ?";
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
                    u.setStatus(rs.getString("status")); // ACTIVE, LOCKED, ...
                    list.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Cập nhật trạng thái user với Transaction Dùng cho Emergency Lock/Unlock
     * với Audit Log
     *
     * @param userId User ID cần cập nhật
     * @param newStatus Status mới (ACTIVE, EMERGENCY_LOCKED)
     * @param auditAction Action audit (EMERGENCY_LOCK, EMERGENCY_UNLOCK)
     * @param actorId ID người thực hiện
     * @param description Mô tả cho audit log
     * @return true nếu thành công
     */
    public boolean updateUserStatusWithAudit(
            int userId, String newStatus,
            String auditAction, int actorId, String description) {

        String sqlUpdateStatus = "UPDATE users SET status = ? WHERE id = ?";
        String sqlInsertAudit = "INSERT INTO audit_logs (action, actor_id, target_user_id, description) VALUES (?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            // 1. Update user status
            PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateStatus);
            psUpdate.setString(1, newStatus);
            psUpdate.setInt(2, userId);
            int rowsUpdated = psUpdate.executeUpdate();

            if (rowsUpdated == 0) {
                conn.rollback();
                return false;
            }

            // 2. Insert audit log
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

    public void deleteUser(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    public List getAllUsers() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    public void addUser(String tenDangNhap, String matKhau, int vaiTroId, int coSoId) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
