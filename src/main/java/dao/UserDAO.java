package dao;

import context.DBContext;
import model.Candidate;
import model.Role;
import model.User;
import model.RecruitmentProposal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
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
     * Hàm tạo tài khoản và hồ sơ nhân viên cơ bản
     */
    public boolean createUserWithProfile(
            String username, String email, int roleId, String expirationDate,
            String fullName, String phone, String identityCard,
            int homeBranchId, int positionId, int departmentId, String employeeType, String shiftType) {

        return createUserWithProfileAndApproveProposal(username, email, roleId, expirationDate,
                fullName, phone, identityCard, homeBranchId, positionId, departmentId,
                employeeType, shiftType, -1, -1);
    }

    /**
     * Hàm tạo tài khoản, hồ sơ nhân viên VÀ tự động cập nhật đề xuất tuyển dụng
     * thành APPROVED trong 1 Transaction
     */
    public boolean createUserWithProfileAndApproveProposal(
            String username, String email, int roleId, String expirationDate,
            String fullName, String phone, String identityCard,
            int homeBranchId, int positionId, int departmentId,
            String employeeType, String shiftType, int proposalId, int hrUserId) {

        // 1. Chèn vào bảng users (quản lý đăng nhập + ngày hết hạn tài khoản nếu có)
        String sqlUser = "INSERT INTO users (username, password_hash, email, status, expiration_date, role_id, is_first_login) "
                + "VALUES (?, '123456', ?, 'ACTIVE', ?, ?, 1)";

        // 2. Chèn vào bảng employee_profiles
        String sqlProfile = "INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        // 3. Cập nhật trạng thái đề xuất
        String sqlApproveProposal = "UPDATE recruitment_proposals "
                + "SET status = 'APPROVED', approved_by = ?, hr_note = 'Đã phê duyệt và cấp tài khoản thành công.', updated_at = NOW() "
                + "WHERE id = ? AND status = 'PENDING'";

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // --- 1. INSERT USERS ---
            PreparedStatement psUser = conn.prepareStatement(sqlUser, PreparedStatement.RETURN_GENERATED_KEYS);
            psUser.setString(1, username);
            psUser.setString(2, (email == null || email.trim().isEmpty()) ? null : email.trim());

            if (expirationDate != null && !expirationDate.trim().isEmpty()) {
                try {
                    psUser.setDate(3, java.sql.Date.valueOf(expirationDate.trim()));
                } catch (IllegalArgumentException ex) {
                    psUser.setNull(3, Types.DATE);
                }
            } else {
                psUser.setNull(3, Types.DATE);
            }

            psUser.setInt(4, roleId);

            int affectedRows = psUser.executeUpdate();
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }

            int generatedUserId = 0;
            try (ResultSet generatedKeys = psUser.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    generatedUserId = generatedKeys.getInt(1);
                } else {
                    conn.rollback();
                    return false;
                }
            }

            // --- 2. INSERT EMPLOYEE_PROFILES ---
            PreparedStatement psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setInt(1, generatedUserId);
            psProfile.setString(2, fullName != null ? fullName.trim() : "");
            psProfile.setString(3, phone != null ? phone.trim() : "");
            psProfile.setString(4, identityCard != null ? identityCard.trim() : "");
            psProfile.setInt(5, homeBranchId);
            psProfile.setInt(6, positionId);

            if (departmentId > 0) {
                psProfile.setInt(7, departmentId);
            } else {
                psProfile.setNull(7, Types.INTEGER);
            }

            psProfile.setString(8, employeeType);

            psProfile.executeUpdate();

            // --- 3. UPDATE RECRUITMENT_PROPOSALS ---
            if (proposalId > 0 && hrUserId > 0) {
                PreparedStatement psProposal = conn.prepareStatement(sqlApproveProposal);
                psProposal.setInt(1, hrUserId);
                psProposal.setInt(2, proposalId);
                psProposal.executeUpdate();
            }

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

    /**
     * Lấy thông tin đề xuất tuyển dụng theo ID
     */
    public RecruitmentProposal getProposalById(int proposalId) {
        String sql = "SELECT rp.*, b.name AS branch_name, pos.title AS position_title, "
                + "c.id AS candidate_id_val, c.full_name, c.email, c.phone, c.identity_card "
                + "FROM recruitment_proposals rp "
                + "LEFT JOIN candidates c ON rp.candidate_id = c.id "
                + "LEFT JOIN branches b ON rp.branch_id = b.id "
                + "LEFT JOIN positions pos ON rp.position_id = pos.id "
                + "WHERE rp.id = ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, proposalId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RecruitmentProposal rp = new RecruitmentProposal();
                    rp.setId(rs.getInt("id"));
                    rp.setCandidateId(rs.getInt("candidate_id"));
                    rp.setBranchId(rs.getInt("branch_id"));
                    rp.setBranchName(rs.getString("branch_name"));
                    rp.setPositionId(rs.getInt("position_id"));
                    rp.setPositionTitle(rs.getString("position_title"));

                    int deptId = rs.getInt("department_id");
                    rp.setDepartmentId(rs.wasNull() ? null : deptId);

                    rp.setEmploymentType(rs.getString("employment_type"));
                    rp.setShiftType(rs.getString("shift_type"));
                    rp.setExpirationDate(rs.getDate("expiration_date"));
                    rp.setQuantity(rs.getInt("quantity"));
                    rp.setTargetDate(rs.getDate("target_date"));
                    rp.setReason(rs.getString("reason"));
                    rp.setStatus(rs.getString("status"));

                    Candidate c = new Candidate();
                    c.setId(rs.getInt("candidate_id_val"));
                    c.setFullName(rs.getString("full_name"));
                    c.setEmail(rs.getString("email"));
                    c.setPhone(rs.getString("phone"));
                    c.setIdentityCard(rs.getString("identity_card"));
                    rp.setCandidate(c);

                    return rp;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ----- Các hàm kiểm tra trùng lặp (Đã chuẩn hóa TRIM) -----
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

    public boolean isPhoneExists(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM employee_profiles WHERE TRIM(phone) = TRIM(?)";
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

    public boolean isIdentityCardExists(String identityCard) {
        if (identityCard == null || identityCard.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM employee_profiles WHERE TRIM(identity_card) = TRIM(?)";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, identityCard.trim());
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
                    u.setStatus(rs.getString("status"));
                    list.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createUserWithProfileAndApproveProposalCustomNote(
            String username, String email, int roleId, String expirationDate,
            String fullName, String phone, String identityCard,
            int homeBranchId, int positionId, int departmentId,
            String employeeType, String shiftType, int proposalId, int hrUserId, String customNote) {

        // 1. Tạo tài khoản
        String sqlUser = "INSERT INTO users (username, password_hash, email, status, expiration_date, role_id, is_first_login, created_at, updated_at) "
                + "VALUES (?, '123456', ?, 'ACTIVE', ?, ?, 1, NOW(), NOW())";

        // 2. Tạo hồ sơ nhân viên
        String sqlProfile = "INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        // 3. Tự động tạo hợp đồng lao động đầu tiên
        String sqlContract = "INSERT INTO contracts (user_id, contract_type, start_date, end_date, status) "
                + "VALUES (?, ?, CURDATE(), ?, 'ACTIVE')";

        // 4. Cập nhật trạng thái đề xuất
        String sqlApproveProposal = "UPDATE recruitment_proposals "
                + "SET status = 'APPROVED', approved_by = ?, hr_note = ?, updated_at = NOW() "
                + "WHERE id = ? AND status = 'PENDING'";

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            // --- 1. INSERT USER ---
            PreparedStatement psUser = conn.prepareStatement(sqlUser, PreparedStatement.RETURN_GENERATED_KEYS);
            psUser.setString(1, username);
            psUser.setString(2, (email == null || email.trim().isEmpty()) ? null : email.trim());

            if (expirationDate != null && !expirationDate.trim().isEmpty()) {
                try {
                    psUser.setDate(3, java.sql.Date.valueOf(expirationDate.trim()));
                } catch (IllegalArgumentException ex) {
                    psUser.setNull(3, Types.DATE);
                }
            } else {
                psUser.setNull(3, Types.DATE);
            }

            psUser.setInt(4, roleId);
            if (psUser.executeUpdate() == 0) {
                conn.rollback();
                return false;
            }

            int generatedUserId = 0;
            try (ResultSet generatedKeys = psUser.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    generatedUserId = generatedKeys.getInt(1);
                } else {
                    conn.rollback();
                    return false;
                }
            }

            // --- 2. INSERT PROFILE ---
            PreparedStatement psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setInt(1, generatedUserId);
            psProfile.setString(2, fullName != null ? fullName.trim() : "");
            psProfile.setString(3, phone != null ? phone.trim() : "");
            psProfile.setString(4, identityCard != null ? identityCard.trim() : "");
            psProfile.setInt(5, homeBranchId);
            psProfile.setInt(6, positionId);
            if (departmentId > 0) {
                psProfile.setInt(7, departmentId);
            } else {
                psProfile.setNull(7, Types.INTEGER);
            }
            psProfile.setString(8, employeeType);
            psProfile.executeUpdate();

            // --- 3. INSERT CONTRACT (TỰ ĐỘNG TẠO HỢP ĐỒNG) ---
            PreparedStatement psContract = conn.prepareStatement(sqlContract);
            psContract.setInt(1, generatedUserId);
            psContract.setString(2, "Hợp đồng " + (employeeType != null ? employeeType : "CHÍNH THỨC"));
            
            if (expirationDate != null && !expirationDate.trim().isEmpty()) {
                try {
                    psContract.setDate(3, java.sql.Date.valueOf(expirationDate.trim()));
                } catch (IllegalArgumentException ex) {
                    psContract.setNull(3, Types.DATE);
                }
            } else {
                psContract.setNull(3, Types.DATE);
            }
            psContract.executeUpdate();

            // --- 4. UPDATE PROPOSAL & NOTE ---
            if (proposalId > 0 && hrUserId > 0) {
                PreparedStatement psProposal = conn.prepareStatement(sqlApproveProposal);
                psProposal.setInt(1, hrUserId);
                psProposal.setString(2, customNote);
                psProposal.setInt(3, proposalId);
                psProposal.executeUpdate();
            }

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
}
