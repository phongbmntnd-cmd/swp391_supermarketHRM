package dao;

import context.DBContext;
import model.Attendance;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO cho bảng {@code attendances} - chấm công nhân viên.
 *
 * <h3>Ghi chú về schema</h3>
 * Bảng thật tên là {@code attendances} (số nhiều), KHÔNG phải
 * {@code attendance}. Cột thời gian là {@code check_in} /
 * {@code check_out} kiểu {@code datetime}, không tách riêng
 * {@code date} + {@code check_in}/{@code check_out}. Tên nhân viên
 * nằm ở bảng {@code employee_profiles.full_name}, không phải
 * {@code users.full_name} (bảng {@code users} không có cột này).
 *
 * <p>DAO cũ trước đây dùng sai tên bảng/cột nên mọi truy vấn đều
 * ném lỗi SQL. Phiên bản này viết lại theo đúng schema.
 */
public class AttendanceDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    /**
     * Lấy danh sách chấm công của nhân viên thuộc một chi nhánh.
     *
     * @param branchId chi nhánh; truyền -1 để xem TẤT CẢ chi nhánh
     *                (dành cho Admin)
     * @param from     ngày bắt đầu (bao gồm), null = không giới hạn
     * @param to       ngày kết thúc (bao gồm), null = không giới hạn
     * @return danh sách bản ghi chấm công, mới nhất trước
     */
    public List<Attendance> getAttendanceByBranch(
            int branchId, LocalDate from, LocalDate to) {

        List<Attendance> list = new ArrayList<>();

        String sql = "SELECT a.id, a.user_id, "
                + "ep.full_name, u.username, "
                + "ep.home_branch_id AS branch_id, "
                + "a.shift_schedule_id, a.check_in, a.check_out, "
                + "a.method, a.status, "
                + "ss.work_date AS work_date "
                + "FROM attendances a "
                + "JOIN employee_profiles ep ON ep.user_id = a.user_id "
                + "JOIN users u ON u.id = a.user_id "
                + "LEFT JOIN shift_schedules ss "
                + "  ON ss.id = a.shift_schedule_id "
                + "WHERE (? < 0 OR ep.home_branch_id = ?) "
                + "AND (? IS NULL OR COALESCE(ss.work_date, DATE(a.check_in)) >= ?) "
                + "AND (? IS NULL OR COALESCE(ss.work_date, DATE(a.check_in)) <= ?) "
                + "ORDER BY COALESCE(ss.work_date, DATE(a.check_in)) DESC, "
                + "a.check_in DESC";

        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setInt(2, branchId);
            setNullableDate(ps, 3, from);
            setNullableDate(ps, 4, from);
            setNullableDate(ps, 5, to);
            setNullableDate(ps, 6, to);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load attendance records", e);
        }

        return list;
    }

    /**
     * Phiên bản cũ (không lọc ngày) - giữ để code đang gọi không lỗi.
     */
    public List<Attendance> getAttendanceByBranch(int branchId) {
        return getAttendanceByBranch(branchId, null, null);
    }

    /**
     * Tổng hợp chấm công theo ngày cho 1 chi nhánh (dùng cho thẻ
     * tổng quan / báo cáo nhanh).
     *
     * @return map: workDate -> map(countTotal, countPresent,
     *         countLate, countAbsent, presentRatio)
     */
    public Map<LocalDate, Map<String, Object>> getDailySummary(
            int branchId, LocalDate from, LocalDate to) {

        Map<LocalDate, Map<String, Object>> result =
                new LinkedHashMap<>();

        String sql = "SELECT ss.work_date, "
                + "COUNT(*) AS total, "
                + "SUM(CASE WHEN a.check_in IS NOT NULL THEN 1 "
                + "         ELSE 0 END) AS present, "
                + "SUM(CASE WHEN a.check_in IS NOT NULL "
                + "          AND TIMESTAMPDIFF(MINUTE, s.start_time, "
                + "              TIME(a.check_in)) > 10 "
                + "         THEN 1 ELSE 0 END) AS late "
                + "FROM attendances a "
                + "JOIN employee_profiles ep ON ep.user_id = a.user_id "
                + "LEFT JOIN shift_schedules ss "
                + "  ON ss.id = a.shift_schedule_id "
                + "LEFT JOIN shifts s "
                + "  ON s.id = ss.shift_id "
                + "WHERE (? < 0 OR ep.home_branch_id = ?) "
                + "AND (? IS NULL OR COALESCE(ss.work_date, DATE(a.check_in)) >= ?) "
                + "AND (? IS NULL OR COALESCE(ss.work_date, DATE(a.check_in)) <= ?) "
                + "GROUP BY ss.work_date "
                + "ORDER BY work_date DESC";

        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setInt(2, branchId);
            setNullableDate(ps, 3, from);
            setNullableDate(ps, 4, from);
            setNullableDate(ps, 5, to);
            setNullableDate(ps, 6, to);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.sql.Date d = rs.getDate("work_date");
                    if (d == null) {
                        continue;
                    }
                    LocalDate day = d.toLocalDate();
                    int total = rs.getInt("total");
                    int present = rs.getInt("present");
                    int late = rs.getInt("late");

                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("workDate", day);
                    row.put("workDateText", formatDate(day));
                    row.put("total", total);
                    row.put("present", present);
                    row.put("late", late);
                    row.put("absent", Math.max(0, total - present));
                    row.put("presentRatio",
                            round2(total == 0 ? 0d
                                    : (present * 100.0) / total));
                    result.put(day, row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load attendance summary", e);
        }

        return result;
    }

    /**
     * Lấy bản ghi chấm công của một nhân viên trong khoảng ngày.
     */
    public List<Attendance> getAttendanceByUser(
            int userId, LocalDate from, LocalDate to) {

        List<Attendance> list = new ArrayList<>();

        String sql = "SELECT a.id, a.user_id, "
                + "ep.full_name, u.username, "
                + "a.shift_schedule_id, a.check_in, a.check_out, "
                + "a.method, a.status, "
                + "DATE(a.check_in) AS work_date "
                + "FROM attendances a "
                + "JOIN employee_profiles ep ON ep.user_id = a.user_id "
                + "JOIN users u ON u.id = a.user_id "
                + "LEFT JOIN shift_schedules ss "
                + "  ON ss.id = a.shift_schedule_id "
                + "WHERE a.user_id = ? "
                + "AND (? IS NULL OR COALESCE(ss.work_date, DATE(a.check_in)) >= ?) "
                + "AND (? IS NULL OR COALESCE(ss.work_date, DATE(a.check_in)) <= ?) "
                + "ORDER BY COALESCE(ss.work_date, DATE(a.check_in)) DESC";

        try (Connection conn = connect();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            setNullableDate(ps, 2, from);
            setNullableDate(ps, 3, from);
            setNullableDate(ps, 4, to);
            setNullableDate(ps, 5, to);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load attendance records", e);
        }

        return list;
    }

    // -----------------------------------------------------------------
    // Tiện ích
    // -----------------------------------------------------------------

    /**
     * Định dạng ngày dạng "dd/MM/yyyy".
     */
    private String formatDate(LocalDate d) {
        if (d == null) {
            return "";
        }
        String dd = d.getDayOfMonth() < 10
                ? "0" + d.getDayOfMonth()
                : String.valueOf(d.getDayOfMonth());
        String mm = d.getMonthValue() < 10
                ? "0" + d.getMonthValue()
                : String.valueOf(d.getMonthValue());
        return dd + "/" + mm + "/" + d.getYear();
    }

    /**
     * Làm tròn 2 chữ số thập phân (để hiển thị).
     */
    private double round2(double v) {
        return Math.round(v * 100.0) / 100.0;
    }

    /**
     * Gán tham số kiểu DATE, cho phép null (nghĩa là không lọc).
     */
    private void setNullableDate(
            PreparedStatement ps, int index, LocalDate value)
            throws java.sql.SQLException {

        if (value == null) {
            ps.setNull(index, java.sql.Types.DATE);
        } else {
            ps.setDate(index, java.sql.Date.valueOf(value));
        }
    }

    /**
     * Ánh xạ 1 dòng kết quả sang đối tượng Attendance.
     */
    private Attendance mapRow(ResultSet rs) throws Exception {
        Attendance att = new Attendance();

        att.setId(rs.getInt("id"));
        att.setUserId(rs.getInt("user_id"));
        att.setFullName(rs.getString("full_name"));
        att.setUsername(rs.getString("username"));
        att.setShiftScheduleId(rs.getInt("shift_schedule_id"));
        att.setCheckIn(toLocalDateTime(rs.getTimestamp("check_in")));
        att.setCheckOut(toLocalDateTime(rs.getTimestamp("check_out")));
        att.setMethod(rs.getString("method"));
        att.setStatus(rs.getString("status"));

        java.sql.Date d = rs.getDate("work_date");
        if (d != null) {
            att.setDate(d);
        } else {
            // Ngay lam viec suy ra tu check_in (truong hop ban ghi
            // khong lien ket duoc voi shift_schedules).
            if (att.getCheckIn() != null) {
                att.setDate(java.sql.Date.valueOf(
                        att.getCheckIn().toLocalDate()));
            }
        }

        return att;
    }

    /**
     * Chuyển Timestamp của JDBC sang LocalDateTime.
     * Trả về null nếu timestamp null (NV chưa check-in / chưa check-out).
     */
    private LocalDateTime toLocalDateTime(Timestamp ts) {
        return ts == null ? null : ts.toLocalDateTime();
    }
}
