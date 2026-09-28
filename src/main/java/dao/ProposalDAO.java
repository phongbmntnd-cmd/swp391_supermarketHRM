package dao;

import context.DBContext;
import model.RecruitmentProposal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProposalDAO extends DBContext {

    // 1. Lấy danh sách toàn bộ đề xuất nhân sự
    public List getAllProposals() {
        List list = new ArrayList<>();
        String sql = "SELECT * FROM recruitment_proposals ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RecruitmentProposal p = new RecruitmentProposal();
                p.setId(rs.getInt("id"));
                p.setBranchId(rs.getInt("branch_id"));
                p.setUserId(rs.getInt("user_id"));
                p.setPositionNeeded(rs.getString("position_needed"));
                p.setQuantity(rs.getInt("quantity"));
                p.setReason(rs.getString("reason"));
                p.setStatus(rs.getString("status"));
                p.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(p);
            }
        } catch (Exception e) {
        }
        return list;
    }

    // 2. Thêm mới một phiếu đề xuất nhân sự từ Store Manager
    public boolean createProposal(int branchId, int userId, String positionNeeded, int quantity, String reason) {
        String sql = "INSERT INTO recruitment_proposals (branch_id, user_id, position_needed, quantity, reason, status) VALUES (?, ?, ?, ?, ?, 'Pending')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            ps.setInt(2, userId);
            ps.setString(3, positionNeeded);
            ps.setInt(4, quantity);
            ps.setString(5, reason);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
        }
        return false;
    }
}