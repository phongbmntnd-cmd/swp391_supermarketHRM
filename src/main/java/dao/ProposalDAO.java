/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 *
 * @author nguyn
 */
public class ProposalDAO {
    public boolean insertProposal(int branchId, int managerId, String title, String content) {
    String sql = "INSERT INTO recruitment_proposals (branch_id, manager_id, title, content, status) VALUES (?, ?, ?, ?, 'PENDING')";
    try (Connection conn = new DBContext().getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, branchId);
        ps.setInt(2, managerId);
        ps.setString(3, title);
        ps.setString(4, content);
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}
}
