package dao;

import context.DBContext;
import model.Candidate;
import model.RecruitmentProposal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class RecruitmentProposalDAO {

    private static final String BASE_SELECT
            = "SELECT rp.*, "
            + "b.name AS branch_name, "
            + "p.title AS position_title, "
            + "c.id AS candidate_id_val, c.full_name, c.email, c.phone, c.identity_card, c.created_at AS candidate_created_at, "
            + "ep_creator.full_name AS created_by_name, "
            + "ep_approver.full_name AS approved_by_name "
            + "FROM recruitment_proposals rp "
            + "LEFT JOIN candidates c ON rp.candidate_id = c.id "
            + "LEFT JOIN branches b ON rp.branch_id = b.id "
            + "LEFT JOIN positions p ON rp.position_id = p.id "
            + "LEFT JOIN employee_profiles ep_creator ON rp.created_by = ep_creator.user_id "
            + "LEFT JOIN employee_profiles ep_approver ON rp.approved_by = ep_approver.user_id ";

    public boolean createProposal(
            int branchId, int positionId, String employmentType,
            String fullName, String email, String phone, String identityCard,
            int departmentId, String shiftType, String expirationDate, String targetDate,
            String reason, int createdBy) {

        String sqlCandidate = "INSERT INTO candidates (full_name, email, phone, identity_card, created_at) "
                + "VALUES (?, ?, ?, ?, NOW())";

        String sqlProposal = "INSERT INTO recruitment_proposals "
                + "(candidate_id, branch_id, position_id, department_id, employment_type, shift_type, expiration_date, target_date, quantity, reason, status, created_by, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, 'PENDING', ?, NOW())";

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            PreparedStatement psCandidate = conn.prepareStatement(sqlCandidate, PreparedStatement.RETURN_GENERATED_KEYS);
            psCandidate.setString(1, fullName);
            psCandidate.setString(2, (email == null || email.trim().isEmpty()) ? null : email.trim());
            psCandidate.setString(3, phone);
            psCandidate.setString(4, identityCard);

            int rows = psCandidate.executeUpdate();
            if (rows == 0) {
                conn.rollback();
                return false;
            }

            int candidateId = 0;
            try (ResultSet rs = psCandidate.getGeneratedKeys()) {
                if (rs.next()) {
                    candidateId = rs.getInt(1);
                } else {
                    conn.rollback();
                    return false;
                }
            }

            PreparedStatement psProposal = conn.prepareStatement(sqlProposal);
            psProposal.setInt(1, candidateId);
            psProposal.setInt(2, branchId);
            psProposal.setInt(3, positionId);

            if (departmentId > 0) {
                psProposal.setInt(4, departmentId);
            } else {
                psProposal.setNull(4, Types.INTEGER);
            }

            psProposal.setString(5, employmentType);

            if ("PART_TIME".equalsIgnoreCase(employmentType) && shiftType != null && !shiftType.trim().isEmpty()) {
                psProposal.setString(6, shiftType.trim());
            } else {
                psProposal.setNull(6, Types.VARCHAR);
            }

            if ("CASUAL".equalsIgnoreCase(employmentType) && expirationDate != null && !expirationDate.trim().isEmpty()) {
                try {
                    psProposal.setDate(7, java.sql.Date.valueOf(expirationDate.trim()));
                } catch (IllegalArgumentException e) {
                    psProposal.setNull(7, Types.DATE);
                }
            } else {
                psProposal.setNull(7, Types.DATE);
            }

            if (targetDate != null && !targetDate.trim().isEmpty()) {
                try {
                    psProposal.setDate(8, java.sql.Date.valueOf(targetDate.trim()));
                } catch (IllegalArgumentException e) {
                    psProposal.setNull(8, Types.DATE);
                }
            } else {
                psProposal.setNull(8, Types.DATE);
            }

            psProposal.setString(9, reason);
            psProposal.setInt(10, createdBy);

            psProposal.executeUpdate();
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

    public boolean resubmitProposal(int proposalId, int positionId, String employmentType,
            String fullName, String email, String phone, String identityCard,
            int departmentId, String shiftType, String expirationDate, String targetDate, String reason) {
        
        RecruitmentProposal proposal = getProposalById(proposalId);
        if (proposal == null || !"REJECTED".equals(proposal.getStatus())) {
            return false;
        }

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            String sqlCandidate = "UPDATE candidates SET full_name = ?, email = ?, phone = ?, identity_card = ? WHERE id = ?";
            PreparedStatement psCandidate = conn.prepareStatement(sqlCandidate);
            psCandidate.setString(1, fullName);
            psCandidate.setString(2, (email == null || email.trim().isEmpty()) ? null : email.trim());
            psCandidate.setString(3, phone);
            psCandidate.setString(4, identityCard);
            psCandidate.setInt(5, proposal.getCandidateId());
            psCandidate.executeUpdate();

            String sqlProposal = "UPDATE recruitment_proposals "
                    + "SET position_id = ?, department_id = ?, employment_type = ?, shift_type = ?, "
                    + "expiration_date = ?, target_date = ?, reason = ?, status = 'PENDING', hr_note = NULL, updated_at = NOW() "
                    + "WHERE id = ?";
            
            PreparedStatement psProposal = conn.prepareStatement(sqlProposal);
            psProposal.setInt(1, positionId);
            
            if (departmentId > 0) {
                psProposal.setInt(2, departmentId);
            } else {
                psProposal.setNull(2, Types.INTEGER);
            }
            
            psProposal.setString(3, employmentType);

            if ("PART_TIME".equalsIgnoreCase(employmentType) && shiftType != null && !shiftType.trim().isEmpty()) {
                psProposal.setString(4, shiftType.trim());
            } else {
                psProposal.setNull(4, Types.VARCHAR);
            }

            if ("CASUAL".equalsIgnoreCase(employmentType) && expirationDate != null && !expirationDate.trim().isEmpty()) {
                psProposal.setDate(5, java.sql.Date.valueOf(expirationDate.trim()));
            } else {
                psProposal.setNull(5, Types.DATE);
            }

            if (targetDate != null && !targetDate.trim().isEmpty()) {
                psProposal.setDate(6, java.sql.Date.valueOf(targetDate.trim()));
            } else {
                psProposal.setNull(6, Types.DATE);
            }

            psProposal.setString(7, reason);
            psProposal.setInt(8, proposalId);

            psProposal.executeUpdate();
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

    public List<RecruitmentProposal> getProposalsByBranch(int branchId) {
        List<RecruitmentProposal> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE rp.branch_id = ? ORDER BY rp.created_at DESC";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProposal(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<RecruitmentProposal> getAllProposals() {
        List<RecruitmentProposal> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY rp.created_at DESC";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToProposal(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<RecruitmentProposal> getPendingProposals() {
        List<RecruitmentProposal> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE rp.status = 'PENDING' ORDER BY rp.created_at DESC";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToProposal(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public RecruitmentProposal getProposalById(int id) {
        String sql = BASE_SELECT + "WHERE rp.id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProposal(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean approveProposal(int proposalId, int approvedBy, String hrNote) {
        RecruitmentProposal proposal = getProposalById(proposalId);
        if (proposal == null || !"PENDING".equals(proposal.getStatus())) {
            return false;
        }

        Candidate c = proposal.getCandidate();
        if (c == null) {
            return false;
        }

        // Kiểm tra trùng lặp trực tiếp tại DAO trước khi thực hiện cấp tài khoản
        UserDAO userDAO = new UserDAO();
        if (c.getPhone() != null && userDAO.isPhoneExists(c.getPhone())) {
            return false;
        }
        if (c.getIdentityCard() != null && userDAO.isIdentityCardExists(c.getIdentityCard())) {
            return false;
        }
        if (c.getEmail() != null && !c.getEmail().trim().isEmpty() && userDAO.isEmailExists(c.getEmail())) {
            return false;
        }

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            // 1. Tạo tài khoản mới trong bảng users (role_id = 5 cho nhân viên)
            String username = (c.getEmail() != null && !c.getEmail().trim().isEmpty()) ? c.getEmail().trim() : c.getPhone();
            String sqlUser = "INSERT INTO users (username, password_hash, email, role_id, status, is_first_login, created_at, updated_at) "
                    + "VALUES (?, '123456', ?, 5, 'ACTIVE', 1, NOW(), NOW())";
            
            PreparedStatement psUser = conn.prepareStatement(sqlUser, PreparedStatement.RETURN_GENERATED_KEYS);
            psUser.setString(1, username);
            psUser.setString(2, c.getEmail());
            psUser.executeUpdate();

            int userId = 0;
            try (ResultSet rs = psUser.getGeneratedKeys()) {
                if (rs.next()) {
                    userId = rs.getInt(1);
                } else {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Tạo hồ sơ nhân viên trong bảng employee_profiles
            String sqlProfile = "INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement psProfile = conn.prepareStatement(sqlProfile);
            psProfile.setInt(1, userId);
            psProfile.setString(2, c.getFullName());
            psProfile.setString(3, c.getPhone());
            psProfile.setString(4, c.getIdentityCard());
            psProfile.setInt(5, proposal.getBranchId());
            psProfile.setInt(6, proposal.getPositionId());
            if (proposal.getDepartmentId() != null) {
                psProfile.setInt(7, proposal.getDepartmentId());
            } else {
                psProfile.setNull(7, Types.INTEGER);
            }
            psProfile.setString(8, proposal.getEmploymentType());
            psProfile.executeUpdate();

            // 3. Cập nhật trạng thái đề xuất thành APPROVED
            String sqlUpdateProposal = "UPDATE recruitment_proposals "
                    + "SET status = 'APPROVED', approved_by = ?, hr_note = ?, updated_at = NOW() "
                    + "WHERE id = ? AND status = 'PENDING'";
            PreparedStatement psProp = conn.prepareStatement(sqlUpdateProposal);
            psProp.setInt(1, approvedBy);
            psProp.setString(2, (hrNote == null || hrNote.trim().isEmpty()) ? "Đã phê duyệt và cấp tài khoản thành công." : hrNote);
            psProp.setInt(3, proposalId);
            psProp.executeUpdate();

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

    public boolean rejectProposal(int proposalId, int approvedBy, String hrNote) {
        String sql = "UPDATE recruitment_proposals "
                + "SET status = 'REJECTED', approved_by = ?, hr_note = ?, updated_at = NOW() "
                + "WHERE id = ? AND status = 'PENDING'";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setString(2, hrNote);
            ps.setInt(3, proposalId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private RecruitmentProposal mapResultSetToProposal(ResultSet rs) throws Exception {
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
        rp.setCreatedBy(rs.getInt("created_by"));
        rp.setCreatedByName(rs.getString("created_by_name"));

        int approvedBy = rs.getInt("approved_by");
        rp.setApprovedBy(rs.wasNull() ? null : approvedBy);
        rp.setApprovedByName(rs.getString("approved_by_name"));

        rp.setHrNote(rs.getString("hr_note"));
        rp.setCreatedAt(rs.getTimestamp("created_at"));
        rp.setUpdatedAt(rs.getTimestamp("updated_at"));

        Candidate c = new Candidate();
        c.setId(rs.getInt("candidate_id_val"));
        c.setFullName(rs.getString("full_name"));
        c.setEmail(rs.getString("email"));
        c.setPhone(rs.getString("phone"));
        c.setIdentityCard(rs.getString("identity_card"));
        c.setCreatedAt(rs.getTimestamp("candidate_created_at"));
        rp.setCandidate(c);

        return rp;
    }
}