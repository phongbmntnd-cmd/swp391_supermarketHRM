package dao;

import context.DBContext;
import model.Contract;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO quản lý hợp đồng lao động của nhân viên (bảng contracts).
 */
public class ContractDAO {

    public List<Contract> getContractsByUser(int userId) {
        List<Contract> list = new ArrayList<>();
        String sql = "SELECT id, user_id, contract_type, start_date, end_date, status "
                + "FROM contracts WHERE user_id = ? ORDER BY start_date DESC";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
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

    public boolean addContract(int userId, String contractType, String startDate, String endDate, String status) {
        String sql = "INSERT INTO contracts (user_id, contract_type, start_date, end_date, status) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, contractType);
            ps.setDate(3, java.sql.Date.valueOf(startDate));

            if (endDate != null && !endDate.trim().isEmpty()) {
                ps.setDate(4, java.sql.Date.valueOf(endDate));
            } else {
                ps.setNull(4, Types.DATE);
            }

            ps.setString(5, status == null || status.isEmpty() ? "ACTIVE" : status);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateContractStatus(int contractId, String status) {
        String sql = "UPDATE contracts SET status = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, contractId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Contract mapRow(ResultSet rs) throws Exception {
        Contract c = new Contract();
        c.setId(rs.getInt("id"));
        c.setUserId(rs.getInt("user_id"));
        c.setContractType(rs.getString("contract_type"));
        c.setStartDate(rs.getDate("start_date"));
        c.setEndDate(rs.getDate("end_date"));
        c.setStatus(rs.getString("status"));
        return c;
    }
}
