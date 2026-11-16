/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author phong
 */



import context.DBContext;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

public class BranchRequestDAO {

    // Kiểm tra chi nhánh hoặc yêu cầu đang xử lý bị trùng
    public boolean isDuplicate(String name, String address)
            throws Exception {

        String sql =
            "SELECT 1 FROM branches " +
            "WHERE LOWER(TRIM(name)) = LOWER(TRIM(?)) " +
            "OR LOWER(TRIM(address)) = LOWER(TRIM(?)) " +
            "UNION ALL " +
            "SELECT 1 FROM branch_requests " +
            "WHERE status IN ('PENDING_HR', 'IN_PROGRESS') " +
            "AND (LOWER(TRIM(branch_name)) = LOWER(TRIM(?)) " +
            "OR LOWER(TRIM(branch_address)) = LOWER(TRIM(?))) " +
            "LIMIT 1";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, address);
            ps.setString(3, name);
            ps.setString(4, address);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // Lưu yêu cầu mở chi nhánh
    public boolean createRequest(
            String name,
            String address,
            LocalDate openingDate,
            String reason,
            int directorId) throws Exception {

        String sql =
            "INSERT INTO branch_requests " +
            "(branch_name, branch_address, " +
            "expected_opening_date, reason, requested_by, status) " +
            "VALUES (?, ?, ?, ?, ?, 'PENDING_HR')";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, address);
            ps.setDate(3, Date.valueOf(openingDate));
            ps.setString(4, reason);
            ps.setInt(5, directorId);

            return ps.executeUpdate() == 1;
        }
    }
}
