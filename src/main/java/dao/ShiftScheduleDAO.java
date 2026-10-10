package dao;

import context.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShiftScheduleDAO {

    // 1. Lấy danh sách khóa các ca đã được phân công trong cơ sở để đồng bộ tích xanh
    public List<String> getAssignedKeysByBranchId(int branchId) {
        List<String> assignedList = new ArrayList<>();
        String sql = "SELECT user_id, shift_id, work_date FROM shift_schedules WHERE branch_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    int dbUserId = rs.getInt("user_id");
                    int dbShiftId = rs.getInt("shift_id");
                    String dbDate = rs.getString("work_date");
                    // Tạo khóa định dạng: userId_shiftId_date
                    String key = dbUserId + "_" + dbShiftId + "_" + dbDate;
                    assignedList.add(key);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return assignedList;
    }

    // 2. Kiểm tra xem ca trực đã tồn tại trong database chưa
    public boolean checkScheduleExists(int branchId, int userId, int shiftId, String workDate) {
        String sql = "SELECT id FROM shift_schedules WHERE branch_id = ? AND user_id = ? AND shift_id = ? AND work_date = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setInt(2, userId);
            st.setInt(3, shiftId);
            st.setDate(4, Date.valueOf(workDate));
            try (ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Thêm mới phân công ca (Lưu nháp - Draft)
    public void insertSchedule(int branchId, int userId, int shiftId, String workDate) {
        String sql = "INSERT INTO shift_schedules (branch_id, user_id, shift_id, work_date, status) VALUES (?, ?, ?, ?, 'Draft')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setInt(2, userId);
            st.setInt(3, shiftId);
            st.setDate(4, Date.valueOf(workDate));
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 4. Xóa phân công ca (Hủy chọn)
    public void deleteSchedule(int branchId, int userId, int shiftId, String workDate) {
        String sql = "DELETE FROM shift_schedules WHERE branch_id = ? AND user_id = ? AND shift_id = ? AND work_date = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.setInt(2, userId);
            st.setInt(3, shiftId);
            st.setDate(4, Date.valueOf(workDate));
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 5. Công bố toàn bộ lịch nháp của chi nhánh sang trạng thái Published
    public void publishSchedules(int branchId) {
        String sql = "UPDATE shift_schedules SET status = 'Published' WHERE branch_id = ? AND status = 'Draft'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, branchId);
            st.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}