package dao;

import context.DBContext;
import model.RecruitmentProposal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý nghiệp vụ "Đề xuất tuyển dụng":
 * - Store Manager tạo đề xuất cho chi nhánh của mình.
 * - HR Manager xem danh sách và phê duyệt / từ chối.
 */
public class RecruitmentProposalDAO {

    // Câu SELECT dùng chung, JOIN sẵn tên chi nhánh / vị trí / người tạo / người duyệt
    private static final String BASE_SELECT =
            "SELECT rp.id, rp.branch_id, b.name AS branch_name, "
            + "rp.position_id, p.title AS position_title, "
            + "rp.employment_type, rp.quantity, rp.target_date, rp.reason, rp.status, "
            + "rp.created_by, ep_creator.full_name AS created_by_name, "
            + "rp.approved_by, ep_approver.full_name AS approved_by_name, "
            + "rp.hr_note, rp.created_at, rp.updated_at "
            + "FROM recruitment_proposals rp "
            + "JOIN branches b ON rp.branch_id = b.id "
            + "JOIN positions p ON rp.position_id = p.id "
            + "LEFT JOIN employee_profiles ep_creator ON rp.created_by = ep_creator.user_id "
            + "LEFT JOIN employee_profiles ep_approver ON rp.approved_by = ep_approver.user_id ";

    /**
     * Store Manager tạo đề xuất tuyển dụng mới cho chi nhánh của mình.
     */
    public boolean createProposal(int branchId, int positionId, String employmentType,
                                   int quantity, String targetDate, String reason, int createdBy) {

        String sql = "INSERT INTO recruitment_proposals "
                + "(branch_id, position_id, employment_type, quantity, target_date, reason, status, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'PENDING', ?)";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setInt(2, positionId);
            ps.setString(3, employmentType);
            ps.setInt(4, quantity);

            if (targetDate != null && !targetDate.trim().isEmpty()) {
                ps.setDate(5, java.sql.Date.valueOf(targetDate));
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setString(6, reason);
            ps.setInt(7, createdBy);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Danh sách đề xuất của MỘT chi nhánh (Store Manager xem đề xuất do chính mình tạo).
     */
    public List<RecruitmentProposal> getProposalsByBranch(int branchId) {
        List<RecruitmentProposal> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE rp.branch_id = ? ORDER BY rp.created_at DESC";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Toàn bộ đề xuất trong hệ thống (HR Manager / Director xem để quản lý chung).
     */
    public List<RecruitmentProposal> getAllProposals() {
        List<RecruitmentProposal> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY rp.created_at DESC";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Chỉ lấy các đề xuất đang chờ xử lý (mặc định hiển thị cho HR Manager).
     */
    public List<RecruitmentProposal> getPendingProposals() {
        List<RecruitmentProposal> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE rp.status = 'PENDING' ORDER BY rp.created_at ASC";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy chi tiết 1 đề xuất theo ID.
     */
    public RecruitmentProposal getProposalById(int id) {
        String sql = BASE_SELECT + "WHERE rp.id = ?";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * HR Manager phê duyệt đề xuất.
     * Chỉ cập nhật khi đề xuất đang ở trạng thái PENDING (tránh duyệt lại đề xuất đã xử lý).
     */
    public boolean approveProposal(int proposalId, int approvedBy, String hrNote) {
        return updateStatus(proposalId, "APPROVED", approvedBy, hrNote);
    }

    /**
     * HR Manager từ chối đề xuất.
     */
    public boolean rejectProposal(int proposalId, int approvedBy, String hrNote) {
        return updateStatus(proposalId, "REJECTED", approvedBy, hrNote);
    }

    private boolean updateStatus(int proposalId, String newStatus, int approvedBy, String hrNote) {
        String sql = "UPDATE recruitment_proposals "
                + "SET status = ?, approved_by = ?, hr_note = ? "
                + "WHERE id = ? AND status = 'PENDING'";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, approvedBy);
            ps.setString(3, hrNote);
            ps.setInt(4, proposalId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private RecruitmentProposal mapRow(ResultSet rs) throws Exception {
        RecruitmentProposal rp = new RecruitmentProposal();
        rp.setId(rs.getInt("id"));
        rp.setBranchId(rs.getInt("branch_id"));
        rp.setBranchName(rs.getString("branch_name"));
        rp.setPositionId(rs.getInt("position_id"));
        rp.setPositionTitle(rs.getString("position_title"));
        rp.setEmploymentType(rs.getString("employment_type"));
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
        return rp;
    }
}
