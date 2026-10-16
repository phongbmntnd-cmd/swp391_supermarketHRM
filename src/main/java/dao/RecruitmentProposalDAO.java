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

    /**
     * Tạo mới một đề xuất tuyển dụng (kèm thông tin ứng viên và loại ca làm việc)
     */
    public boolean createProposal(
            int branchId, int positionId, String employmentType, String shiftType,
            String fullName, String email, String phone, String identityCard,
            int departmentId, String expirationDate, String targetDate,
            String reason, int createdBy) {

        String sqlCandidate = "INSERT INTO candidates (full_name, email, phone, identity_card, created_at) "
                + "VALUES (?, ?, ?, ?, NOW())";

        String sqlProposal = "INSERT INTO recruitment_proposals "
                + "(candidate_id, branch_id, position_id, department_id, employment_type, shift_type, expiration_date, target_date, reason, status, created_by, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?, NOW())";

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
            
            if (branchId > 0) {
                psProposal.setInt(2, branchId);
            } else {
                psProposal.setNull(2, Types.INTEGER);
            }

            if (positionId > 0) {
                psProposal.setInt(3, positionId);
            } else {
                conn.rollback();
                return false;
            }

            if (departmentId > 0) {
                psProposal.setInt(4, departmentId);
            } else {
                psProposal.setNull(4, Types.INTEGER);
            }

            psProposal.setString(5, employmentType);
            psProposal.setString(6, shiftType);

            if (expirationDate != null && !expirationDate.trim().isEmpty()) {
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
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (Exception e) { e.printStackTrace(); }
            }
        }
    }

    /**
     * Gửi lại đề xuất (Resubmit) khi bị từ chối
     */
    public boolean resubmitProposal(int proposalId, int positionId, String employmentType, String shiftType,
            String fullName, String email, String phone, String identityCard,
            int departmentId, String expirationDate, String targetDate, String reason) {
        
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
            psProposal.setString(4, shiftType);

            if (expirationDate != null && !expirationDate.trim().isEmpty()) {
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
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (Exception e) { e.printStackTrace(); }
            }
        }
    }

    /**
     * Transaction phê duyệt đề xuất và cấp tài khoản trọn gói (Đã tích hợp lưu shift_type vào employee_profiles)
     */
    public boolean approveProposalAndCreateUser(
            String username, String email, int roleId, String expirationDate,
            String fullName, String phone, String identityCard,
            int homeBranchId, int positionId, int departmentId,
            String employeeType, int proposalId, int hrUserId, String customNote) {

        String sqlUser = "INSERT INTO users (username, password_hash, email, status, expiration_date, role_id, is_first_login, created_at, updated_at) "
                + "VALUES (?, '123456', ?, 'ACTIVE', ?, ?, 1, NOW(), NOW())";

        // Đã bổ sung cột shift_type vào bảng employee_profiles
        String sqlProfile = "INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, shift_type) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String sqlApproveProposal = "UPDATE recruitment_proposals "
                + "SET status = 'APPROVED', approved_by = ?, hr_note = ?, updated_at = NOW() "
                + "WHERE id = ? AND status = 'PENDING'";

        Connection conn = null;
        try {
            conn = new DBContext().getConnection();
            conn.setAutoCommit(false);

            // Lấy shift_type từ đề xuất gốc để gán cho nhân sự mới
            String shiftType = null;
            if (proposalId > 0) {
                RecruitmentProposal prop = getProposalById(proposalId);
                if (prop != null) {
                    shiftType = prop.getShiftType();
                }
            }

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
            
            // Set giá trị shift_type cho profile nhân viên
            if (shiftType != null && !shiftType.trim().isEmpty()) {
                psProfile.setString(9, shiftType);
            } else {
                psProfile.setNull(9, Types.VARCHAR);
            }
            
            psProfile.executeUpdate();

            ContractDAO contractDAO = new ContractDAO();
            String contractType = (expirationDate != null && !expirationDate.trim().isEmpty()) ? "Hợp đồng THỜI VỤ" : "Hợp đồng CHÍNH THỨC";
            boolean contractCreated = contractDAO.addContractWithConn(conn, generatedUserId, contractType, null, expirationDate, "ACTIVE");
            if (!contractCreated) {
                conn.rollback();
                return false;
            }

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
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
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

    public List<RecruitmentProposal> getProposals(String tabFilter, Integer branchId, Integer positionId,
                                                   String employmentType, String status) {
        List<RecruitmentProposal> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append("WHERE 1=1 ");

        boolean hasBranch = branchId != null && branchId > 0;
        if (hasBranch) sql.append("AND rp.branch_id = ? ");

        boolean hasPosition = positionId != null && positionId > 0;
        if (hasPosition) sql.append("AND rp.position_id = ? ");

        boolean hasEmploymentType = employmentType != null && !employmentType.trim().isEmpty();
        if (hasEmploymentType) sql.append("AND rp.employment_type = ? ");

        boolean hasStatus = status != null && !status.trim().isEmpty();
        boolean defaultPending = !hasStatus && "pending".equals(tabFilter);

        if (hasStatus) {
            sql.append("AND rp.status = ? ");
        } else if (defaultPending) {
            sql.append("AND rp.status = 'PENDING' ");
        }

        sql.append("ORDER BY rp.created_at DESC");

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            if (hasBranch) ps.setInt(idx++, branchId);
            if (hasPosition) ps.setInt(idx++, positionId);
            if (hasEmploymentType) ps.setString(idx++, employmentType);
            if (hasStatus) ps.setString(idx++, status);

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