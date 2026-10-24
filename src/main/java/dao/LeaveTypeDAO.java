package dao;

import context.DBContext;
import java.sql.*;
import java.util.*;

public class LeaveTypeDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    // Lấy tất cả loại nghỉ phép
    public List<Map<String, Object>> getAll() {
        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT id, code, name, description, "
                + "default_days AS defaultDays, paid_leave AS paidLeave "
                + "FROM leave_types ORDER BY id";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("code", rs.getString("code"));
                row.put("name", rs.getString("name"));
                row.put("description", rs.getString("description"));
                row.put("defaultDays", rs.getInt("defaultDays"));
                row.put("paidLeave", rs.getBoolean("paidLeave"));
                result.add(row);
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave types", e);
        }

        return result;
    }
}
