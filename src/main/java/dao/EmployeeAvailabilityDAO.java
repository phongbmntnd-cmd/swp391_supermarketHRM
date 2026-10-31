package dao;

import context.DBContext;
import model.EmployeeAvailability;
import model.Shift;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EmployeeAvailabilityDAO {

    // 1. Lấy tất cả danh sách ca làm việc (Phục vụ cho Store Manager xếp lịch)
    public List<Shift> getAllShifts() {
        List<Shift> list = new ArrayList<>();
        String sql = "SELECT id, name, start_time, end_time FROM shifts ORDER BY start_time";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql); ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                Shift s = new Shift();
                s.setId(rs.getInt("id"));
                s.setName(rs.getString("name"));
                s.setStartTime(rs.getTime("start_time"));
                s.setEndTime(rs.getTime("end_time"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy danh sách ca làm việc tùy theo loại nhân sự (Phục vụ cho nhân viên đăng ký lịch rảnh)
    public List<Shift> getShiftsByEmployeeType(String employeeType) {
        List<Shift> list = new ArrayList<>();
        String sql = "SELECT id, name, start_time, end_time FROM shifts";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Shift s = new Shift();
                s.setId(rs.getInt("id"));
                s.setName(rs.getString("name"));
                s.setStartTime(rs.getTime("start_time"));
                s.setEndTime(rs.getTime("end_time"));

                String shiftName = s.getName() != null ? s.getName().trim().toLowerCase() : "";

                // Nếu là Part-time, lọc bỏ các ca có chứa chữ "full"
                if ("PART_TIME".equalsIgnoreCase(employeeType) || "CASUAL".equalsIgnoreCase(employeeType)) {
                    if (!shiftName.contains("full")) {
                        list.add(s);
                    }
                } else {
                    // Full-time lấy tất cả
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy lịch rảnh của nhân viên theo userId
    public List<EmployeeAvailability> getAvailabilitiesByUserIdAndWeek(int userId, String weekStartDate) {
        List<EmployeeAvailability> list = new ArrayList<>();
        String sql = "SELECT * FROM employee_availabilities WHERE user_id = ? AND week_start_date = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, userId);
            st.setString(2, weekStartDate);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(new EmployeeAvailability(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getString("day_of_week"), // Đưa day_of_week lên trước
                            rs.getString("week_start_date"), // Đưa week_start_date ra sau
                            rs.getInt("shift_id")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy tất cả lịch rảnh của nhân viên
    public List<EmployeeAvailability> getAllAvailabilities() {
        List<EmployeeAvailability> list = new ArrayList<>();
        String sql = "SELECT * FROM employee_availabilities";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                list.add(new EmployeeAvailability(
                        rs.getInt("id"),
                        rs.getInt("user_id"),
                        rs.getString("day_of_week"), // Đưa day_of_week lên trước
                        rs.getString("week_start_date"), // Đưa week_start_date ra sau
                        rs.getInt("shift_id")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Xóa lịch rảnh cũ và lưu lịch rảnh mới của nhân viên (Dùng Transaction)
    public void saveAvailabilities(int userId, String weekStartDate, List<EmployeeAvailability> availabilities) {
        String deleteSql = "DELETE FROM employee_availabilities WHERE user_id = ? AND week_start_date = ?";
        String insertSql = "INSERT INTO employee_availabilities (user_id, week_start_date, day_of_week, shift_id) VALUES (?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement stDel = conn.prepareStatement(deleteSql)) {
                stDel.setInt(1, userId);
                stDel.setString(2, weekStartDate);
                stDel.executeUpdate();
            }

            try (PreparedStatement stIns = conn.prepareStatement(insertSql)) {
                for (EmployeeAvailability av : availabilities) {
                    stIns.setInt(1, userId);
                    stIns.setString(2, weekStartDate);

                    // --- BỔ SUNG ĐOẠN CHUẨN HÓA NÀY ĐỂ TRÁNH LỖI DATA TRUNCATED ---
                    String rawDay = av.getDayOfWeek();
                    String formattedDay = (rawDay != null) ? rawDay.trim().toUpperCase() : "";
                    stIns.setString(3, formattedDay);
                    // -------------------------------------------------------------

                    stIns.setInt(4, av.getShiftId());
                    stIns.addBatch();
                }
                stIns.executeBatch();
            }

            conn.commit();
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * Lấy danh sách lịch rảnh kèm tên và vị trí theo cơ sở của Store Manager.
     *
     * <p><b>Quan trọng:</b> phải lọc theo {@code week_start_date} đúng tuần đang xem.
     * Nếu thiếu điều kiện này, lưới xếp lịch sẽ trộn lịch rảnh của các tuần khác
     * vào tuần hiện tại (nhân viên đăng ký thêm tuần sau sẽ xuất hiện ở tuần này),
     * khiến Store thấy "đã có người đăng ký" ở những ca thực tế chưa ai đăng ký.
     *
     * @param branchId      cơ sở đang quản lý
     * @param weekStartDate mốc tuần (yyyy-MM-dd) của lịch rảnh cần lấy
     */
    public List<java.util.Map<String, Object>> getRegistrationsByBranchId(int branchId, String weekStartDate) {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT ea.user_id, ep.full_name, pos.title AS position_title, "
                + "pos.id AS position_id, ea.day_of_week, s.name AS shift_name, ea.shift_id "
                + "FROM employee_availabilities ea "
                + "JOIN employee_profiles ep ON ea.user_id = ep.user_id "
                + "JOIN positions pos ON ep.position_id = pos.id "
                + "JOIN shifts s ON ea.shift_id = s.id "
                + "WHERE ep.home_branch_id = ? AND ea.week_start_date = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setString(2, weekStartDate);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    row.put("userId", rs.getInt("user_id"));
                    row.put("fullName", rs.getString("full_name"));
                    row.put("positionTitle", rs.getString("position_title"));
                    row.put("positionId", rs.getInt("position_id"));
                    row.put("dayOfWeek", rs.getString("day_of_week"));
                    row.put("shiftName", rs.getString("shift_name"));
                    row.put("shiftId", rs.getInt("shift_id"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số nhân viên đã đăng ký lịch rảnh cho đúng (ngày trong tuần, ca, vị trí).
     * Dùng để Store Manager thấy được "ca này có bao nhiêu người đăng ký"
     * trước khi xếp ca.
     *
     * @return Map key = {@code dayOfWeek_shiftId_positionId} -> số người đăng ký
     */
    public java.util.Map<String, Integer> getRegistrationCountMap(int branchId, String weekStartDate) {
        java.util.Map<String, Integer> map = new java.util.HashMap<>();
        String sql = "SELECT ea.day_of_week, ea.shift_id, pos.id AS position_id, COUNT(*) AS reg_count "
                + "FROM employee_availabilities ea "
                + "JOIN employee_profiles ep ON ea.user_id = ep.user_id "
                + "JOIN positions pos ON ep.position_id = pos.id "
                + "WHERE ep.home_branch_id = ? AND ea.week_start_date = ? "
                + "GROUP BY ea.day_of_week, ea.shift_id, pos.id";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setString(2, weekStartDate);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    String key = rs.getString("day_of_week") + "_"
                            + rs.getInt("shift_id") + "_"
                            + rs.getInt("position_id");
                    map.put(key, rs.getInt("reg_count"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }
}
