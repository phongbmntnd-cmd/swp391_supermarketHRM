package dao;

import context.DBContext;
import java.sql.*;
import java.util.*;

/**
 * DAO cho bảng leave_types.
 *
 * Mô hình "C trên nền B": hạn gửi đơn có 2 mức:
 *   - notice_hours          : áp dụng cho FULL_TIME
 *   - notice_hours_part_time: áp dụng cho PART_TIME / CASUAL
 *
 * Part-time dùng cùng mức hạn với full-time (48 giờ) cho nghỉ phép
 * năm và nghỉ không lương; các loại khác có thể đặt riêng.
 */
public class LeaveTypeDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    // Lấy tất cả loại nghỉ phép
    public List<Map<String, Object>> getAll() {
        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT id, code, name, description, "
                + "default_days AS defaultDays, paid_leave AS paidLeave, "
                + "notice_hours AS noticeHours, "
                + "notice_hours_part_time AS noticeHoursPartTime, "
                + "same_day_allowed AS sameDayAllowed "
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
                row.put("noticeHoursPartTime",
                        rs.getInt("noticeHoursPartTime"));
                row.put("sameDayAllowed",
                        rs.getBoolean("sameDayAllowed"));
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

    /**
     * Lấy số giờ phải báo trước của 1 loại nghỉ dành cho part-time.
     * Trả về -1 nếu không tìm thấy (coi như không giới hạn).
     */
    public int getNoticeHoursPartTime(int leaveTypeId) {
        String sql = "SELECT notice_hours_part_time "
                + "FROM leave_types WHERE id = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, leaveTypeId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("notice_hours_part_time");
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load part-time notice hours", e);
        }

        return -1;
    }

    /**
     * Lấy hạn gửi đơn phù hợp với loại nhân viên.
     *
     * @param leaveTypeId  id loại nghỉ
     * @param isPartTime   true nếu nhân viên là PART_TIME / CASUAL
     */
    public int getNoticeHours(int leaveTypeId, boolean isPartTime) {
        return isPartTime
                ? getNoticeHoursPartTime(leaveTypeId)
                : getNoticeHours(leaveTypeId);
    }

    /**
     * Loại nghỉ này có được làm đơn TRONG NGÀY (không kiểm tra hạn
     * báo trước) hay không.
     *
     * Áp dụng cho nghỉ ốm và nghỉ tang: nhân viên có thể xin nghỉ
     * ngay trong ngày mà không bị chặn bởi quy định báo trước.
     *
     * @return true nếu được làm đơn trong ngày
     */
    public boolean isSameDayAllowed(int leaveTypeId) {
        String sql = "SELECT same_day_allowed "
                + "FROM leave_types WHERE id = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, leaveTypeId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean("same_day_allowed");
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load same_day_allowed", e);
        }

        return false;
    }
}
