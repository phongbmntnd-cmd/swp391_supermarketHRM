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
                + "default_days AS defaultDays, paid_leave AS paidLeave, "
                + "notice_hours AS noticeHours "
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
                row.put("noticeHours", rs.getInt("noticeHours"));
                result.add(row);
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave types", e);
        }

        return result;
    }

    // Lấy số giờ phải báo trước của 1 loại nghỉ.
    // Trả về -1 nếu không tìm thấy (coi như không giới hạn).
    public int getNoticeHours(int leaveTypeId) {
        String sql = "SELECT notice_hours FROM leave_types WHERE id = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, leaveTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("notice_hours");
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load notice hours", e);
        }

        return -1;
    }
}
