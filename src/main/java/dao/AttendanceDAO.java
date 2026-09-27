/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author nguyn
 */

import context.DBContext;
import model.Attendance; // Đảm bảo bạn đã có model Attendance tương ứng
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AttendanceDAO {

    // Lấy danh sách chấm công của tất cả nhân viên thuộc một chi nhánh cụ thể
    public List<Attendance> getAttendanceByBranch(int branchId) {
        List<Attendance> list = new ArrayList<>();
        // Câu lệnh SQL giả định liên kết bảng attendance với users dựa trên home_branch_id
        String sql = "SELECT a.*, u.full_name, u.username FROM attendance a " +
                     "JOIN users u ON a.user_id = u.id " +
                     "WHERE u.home_branch_id = ? ORDER BY a.date DESC";
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Attendance att = new Attendance();
                    att.setId(rs.getInt("id"));
                    att.setUserId(rs.getInt("user_id"));
                    att.setFullName(rs.getString("full_name"));
                    att.setUsername(rs.getString("username"));
                    att.setDate(rs.getDate("date"));
                    att.setCheckIn(rs.getTime("check_in"));
                    att.setCheckOut(rs.getTime("check_out"));
                    att.setStatus(rs.getString("status")); // Ví dụ: PRESENT, ABSENT, LATE
                    list.add(att);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
