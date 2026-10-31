package service;

import context.DBContext;
import model.LeaveRequestShift;
import model.LeaveShiftSelection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Service tính giờ nghỉ theo mô hình "C trên nền B".
 *
 * <h3>Nguyên tắc</h3>
 * <ul>
 *   <li><b>B (nền)</b>: đơn vị đo chuẩn của hệ thống là GIỜ.
 *       Mọi phép so sánh quota đều thực hiện trên giờ, nhờ vậy
 *       full-time (10h/ngày) và part-time (5h/ca) dùng chung được
 *       một bộ quy tắc và báo cáo tổng hợp nhất quán.</li>
 *   <li><b>C (trên nền)</b>: mỗi đơn nghỉ phép gắn với danh sách CA
 *       cụ thể bị ảnh hưởng. Nhờ vậy hệ thống biết chính xác ca nào
 *       cần đưa vào danh sách ca trống để tìm người cover.</li>
 * </ul>
 *
 * <h3>Quy tắc tính giờ</h3>
 * <ol>
 *   <li><b>Ưu tiên ca thực tế</b>: nếu nhân viên đã được xếp ca trong
 *       khoảng nghỉ, giờ nghỉ = tổng thời lượng các ca đó.
 *       Part-time chỉ có ca Tối 5h -> nghỉ 1 ngày = 5 giờ (không phải 8).</li>
 *   <li><b>Fallback theo ngày</b>: nếu chưa có lịch làm việc (chưa publish,
 *       hoặc nhân viên mới), giờ nghỉ = standard_hours_per_day × số ngày.
 *       Đây là đường dự phòng để hệ thống không bị chặn vì thiếu dữ liệu.</li>
 * </ol>
 *
 * Lớp này thuần túy chỉ đọc dữ liệu và tính toán, KHÔNG ghi DB.
 * Việc ghi do {@link dao.LeaveRequestDAO} xử lý trong transaction.
 */
public class LeaveHoursCalculator {

    /** Ca làm việc: id -> (tên, giờ bắt đầu, giờ kết thúc, thời lượng). */
    public static class ShiftInfo {
        public final int id;
        public final String name;
        public final Time startTime;
        public final Time endTime;
        public final double hours;

        public ShiftInfo(int id, String name, Time startTime, Time endTime) {
            this.id = id;
            this.name = name;
            this.startTime = startTime;
            this.endTime = endTime;
            this.hours = durationHours(startTime, endTime);
        }
    }

    /**
     * Kết quả tính giờ nghỉ của một đơn.
     */
    public static class Result {
        /** Tổng giờ nghỉ. */
        public double totalHours;
        /** Số ngày lịch (để tương thích ngược với total_days). */
        public int totalDays;
        /** Danh sách ca bị ảnh hưởng (có thể rỗng nếu dùng fallback). */
        public List<LeaveRequestShift> shiftDetails = new ArrayList<>();
        /** true nếu dùng fallback theo ngày (không tìm thấy ca nào). */
        public boolean usedFallback;
        /** Thông báo giải thích, dùng để hiển thị cho người dùng. */
        public String note;
    }

    // -----------------------------------------------------------------
    // Truy vấn lịch làm việc
    // -----------------------------------------------------------------

    /**
     * Lấy các ca đã xếp (PUBLISHED hoặc ON_LEAVE) của nhân viên trong
     * khoảng [startDate, endDate].
     */
    public List<Map<String, Object>> getScheduledShifts(
            int userId,
            LocalDate startDate,
            LocalDate endDate) {

        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT ss.id AS scheduleId, ss.shift_id AS shiftId, "
                + "ss.work_date AS workDate, ss.position_id AS positionId, "
                + "ss.status, s.name AS shiftName, "
                + "s.start_time AS startTime, s.end_time AS endTime, "
                + "TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time) AS minutes "
                + "FROM shift_schedules ss "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "WHERE ss.user_id = ? "
                + "AND ss.work_date BETWEEN ? AND ? "
                + "AND ss.status IN ('PUBLISHED', 'ON_LEAVE') "
                + "ORDER BY ss.work_date, s.start_time";

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(startDate));
            ps.setDate(3, java.sql.Date.valueOf(endDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("scheduleId", rs.getInt("scheduleId"));
                    row.put("shiftId", rs.getInt("shiftId"));
                    row.put("workDate", rs.getDate("workDate"));
                    row.put("positionId",
                            rs.getInt("positionId"));
                    row.put("status", rs.getString("status"));
                    row.put("shiftName", rs.getString("shiftName"));
                    row.put("startTime", rs.getTime("startTime"));
                    row.put("endTime", rs.getTime("endTime"));
                    row.put("minutes", rs.getInt("minutes"));
                    row.put("hours", rs.getInt("minutes") / 60.0);
                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load scheduled shifts", e);
        }

        return result;
    }

    /**
     * Lấy toàn bộ ca trong hệ thống (dùng để dựng danh sách tick cho
     * part-time khi chưa có lịch publish).
     */
    public List<ShiftInfo> getAllShifts() {
        List<ShiftInfo> list = new ArrayList<>();

        String sql = "SELECT id, name, start_time, end_time "
                + "FROM shifts ORDER BY start_time";

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new ShiftInfo(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getTime("start_time"),
                        rs.getTime("end_time")
                ));
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load shifts", e);
        }

        return list;
    }

    // -----------------------------------------------------------------
    // Tính giờ nghỉ
    // -----------------------------------------------------------------

    /**
     * Tính giờ nghỉ cho một khoảng ngày, dựa trên lịch làm việc thực tế
     * của nhân viên.
     *
     * @param userId           nhân viên xin nghỉ
     * @param startDate        ngày bắt đầu
     * @param endDate          ngày kết thúc
     * @param standardHoursPerDay định mức giờ/ngày (fallback)
     * @return kết quả tính giờ
     */
    public Result calculateFromSchedule(
            int userId,
            LocalDate startDate,
            LocalDate endDate,
            double standardHoursPerDay) {

        Result result = new Result();
        result.totalDays = (int) ChronoUnit.DAYS.between(startDate, endDate) + 1;

        List<Map<String, Object>> scheduled =
                getScheduledShifts(userId, startDate, endDate);

        if (scheduled.isEmpty()) {
            // Fallback: chưa có lịch -> tính theo ngày
            result.usedFallback = true;
            result.totalHours = standardHoursPerDay * result.totalDays;
            result.note = "Chưa có lịch làm việc được công bố cho khoảng "
                    + "thời gian này, hệ thống tạm tính "
                    + trimHours(result.totalHours) + " giờ theo định mức "
                    + trimHours(standardHoursPerDay) + " giờ/ngày.";
            return result;
        }

        double sum = 0;
        for (Map<String, Object> row : scheduled) {
            double hours = toDouble(row.get("hours"));
            sum += hours;

            LeaveRequestShift d = new LeaveRequestShift();
            d.setWorkDate((java.sql.Date) row.get("workDate"));
            d.setShiftId(toInt(row.get("shiftId")));
            d.setShiftName(String.valueOf(row.get("shiftName")));
            d.setHours(hours);
            result.shiftDetails.add(d);
        }

        result.totalHours = sum;
        return result;
    }

    /**
     * Tính giờ nghỉ cho các ca mà nhân viên chọn (dùng cho part-time).
     *
     * @param selections các ca được tick
     * @param shifts     danh sách ca trong hệ thống để tra thời lượng
     * @return kết quả tính giờ
     */
    public Result calculateFromSelections(
            List<LeaveShiftSelection> selections,
            List<ShiftInfo> shifts) {

        Result result = new Result();

        if (selections == null || selections.isEmpty()) {
            return result;
        }

        Map<Integer, ShiftInfo> shiftMap = new LinkedHashMap<>();
        for (ShiftInfo s : shifts) {
            shiftMap.put(s.id, s);
        }

        double sum = 0;
        int minDay = Integer.MAX_VALUE;
        int maxDay = Integer.MIN_VALUE;

        for (LeaveShiftSelection sel : selections) {
            ShiftInfo info = shiftMap.get(sel.getShiftId());
            double hours = (info != null) ? info.hours : 0;

            LeaveRequestShift d = new LeaveRequestShift();
            d.setWorkDate(java.sql.Date.valueOf(sel.getWorkDate()));
            d.setShiftId(sel.getShiftId());
            d.setShiftName(info != null ? info.name : null);
            d.setHours(hours);
            result.shiftDetails.add(d);

            sum += hours;

            int epoch = (int) sel.getWorkDate().toEpochDay();
            minDay = Math.min(minDay, epoch);
            maxDay = Math.max(maxDay, epoch);
        }

        result.totalHours = sum;
        if (minDay != Integer.MAX_VALUE) {
            LocalDate from = LocalDate.ofEpochDay(minDay);
            LocalDate to = LocalDate.ofEpochDay(maxDay);
            result.totalDays = (int) ChronoUnit.DAYS.between(from, to) + 1;
        }

        return result;
    }

    /**
     * Lấy thời lượng (giờ) của một ca theo id.
     */
    public double getShiftHours(int shiftId) {
        for (ShiftInfo s : getAllShifts()) {
            if (s.id == shiftId) {
                return s.hours;
            }
        }
        return 0;
    }

    // -----------------------------------------------------------------
    // Tiện ích
    // -----------------------------------------------------------------

    /**
     * Tính thời lượng giữa hai mốc giờ.
     * Xử lý ca qua nửa đêm (end &lt; start) bằng cách cộng thêm 24h.
     */
    public static double durationHours(Time start, Time end) {
        if (start == null || end == null) {
            return 0;
        }
        int startMin = start.getHours() * 60 + start.getMinutes();
        int endMin = end.getHours() * 60 + end.getMinutes();

        int diff = endMin - startMin;
        if (diff <= 0) {
            diff += 24 * 60;
        }

        return diff / 60.0;
    }

    /**
     * Loại bỏ phần thập phân thừa (10.0 -> 10, 7.5 -> 7.5).
     */
    public static String trimHours(double hours) {
        if (hours == Math.floor(hours)) {
            return String.valueOf((long) hours);
        }
        return String.valueOf(Math.round(hours * 100.0) / 100.0);
    }

    private static double toDouble(Object o) {
        if (o instanceof Number) {
            return ((Number) o).doubleValue();
        }
        try {
            return Double.parseDouble(String.valueOf(o));
        } catch (Exception e) {
            return 0;
        }
    }

    private static int toInt(Object o) {
        if (o instanceof Number) {
            return ((Number) o).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(o));
        } catch (Exception e) {
            return 0;
        }
    }
}
