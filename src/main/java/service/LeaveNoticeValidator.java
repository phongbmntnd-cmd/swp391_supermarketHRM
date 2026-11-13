package service;

import dao.LeaveTypeDAO;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

/**
 * Kiểm tra hạn gửi đơn nghỉ phép (luật "báo trước").
 *
 * <h3>Luật</h3>
 * <ul>
 *   <li><b>Báo trước = TỐI THIỂU</b>: nhân viên được gửi đơn SỚM bất cứ
 *       lúc nào. Hệ thống chỉ chặn khi gửi MUỘN hơn hạn.</li>
 *   <li>Loại nghỉ có {@code notice_hours >= 24}: hạn tính theo NGÀY lịch.
 *       Ví dụ báo trước 2 ngày (48h) và nghỉ Thứ Hai thì được gửi từ
 *       Thứ Bảy trở đi (hết hạn 23:59 ngày Thứ Bảy).</li>
 *   <li>Loại nghỉ có {@code notice_hours < 24}: hạn tính theo GIỜ cụ thể
 *       tính từ 00:00 ngày nghỉ trừ đi số giờ báo trước.</li>
 *   <li>Nghỉ ốm &amp; nghỉ tang ({@code same_day_allowed = 1}):
 *       được làm đơn TRONG NGÀY, KHÔNG kiểm tra hạn báo trước.</li>
 * </ul>
 *
 * Lớp này thuần túy đọc cấu hình loại nghỉ và trả về thông báo lỗi,
 * không ghi DB. Nhờ vậy cả server (servlet) và test đều dùng chung
 * một bộ quy tắc.
 */
public class LeaveNoticeValidator {

    private final LeaveTypeDAO typeDao;

    public LeaveNoticeValidator() {
        this(new LeaveTypeDAO());
    }

    public LeaveNoticeValidator(LeaveTypeDAO typeDao) {
        this.typeDao = typeDao;
    }

    /**
     * Kiểm tra hạn gửi đơn cho một ngày nghỉ.
     *
     * @param leaveTypeId loại nghỉ
     * @param startDate   ngày bắt đầu nghỉ
     * @param isPartTime  dùng notice_hours_part_time hay không
     * @return thông báo lỗi, hoặc null nếu hợp lệ
     */
    public String check(int leaveTypeId,
                        LocalDate startDate,
                        boolean isPartTime) {

        if (startDate == null) {
            return "Vui lòng chọn ngày nghỉ.";
        }

        // Nghỉ ốm / nghỉ tang: làm đơn trong ngày, KHÔNG validate hạn.
        if (typeDao.isSameDayAllowed(leaveTypeId)) {
            return null;
        }

        int noticeHours = typeDao.getNoticeHours(leaveTypeId, isPartTime);

        if (noticeHours <= 0) {
            return null;
        }

        LocalDate today = LocalDate.now();

        if (noticeHours >= 24) {
            // Hạn theo NGÀY lịch: ngày nghỉ trừ đi số ngày báo trước.
            int minLeadDays = (int) Math.ceil(noticeHours / 24.0);
            LocalDate deadlineDate = startDate.minusDays(minLeadDays);

            // Được gửi đến hết ngày hạn (23:59).
            if (!today.isAfter(deadlineDate)) {
                return null;
            }

            long lateBy = ChronoUnit.DAYS.between(deadlineDate, today);

            return "Đơn nghỉ phép đã quá hạn gửi. Loại nghỉ này yêu cầu "
                    + "báo trước tối thiểu " + minLeadDays
                    + " ngày"
                    + partTimeNote(isPartTime)
                    + ". Nếu nghỉ từ " + formatVn(startDate)
                    + " thì bạn phải gửi đơn từ " + formatVn(deadlineDate)
                    + " trở đi"
                    + (lateBy > 0
                        ? " (đã trễ " + lateBy + " ngày)."
                        : ".");
        }

        // Hạn theo GIỜ cụ thể.
        LocalDateTime deadline = startDate
                .atStartOfDay()
                .minusHours(noticeHours);

        if (!LocalDateTime.now().isAfter(deadline)) {
            return null;
        }

        return "Đơn nghỉ phép đã quá hạn gửi. Loại nghỉ này yêu cầu "
                + "báo trước tối thiểu " + formatHours(noticeHours)
                + partTimeNote(isPartTime)
                + ". Nếu nghỉ từ " + formatVn(startDate)
                + " thì phải gửi đơn trước " + formatVnTime(deadline)
                + ".";
    }

    /**
     * Kiểm tra hạn gửi đơn cho nhiều ngày (part-time tick nhiều ca).
     * Chỉ cần một ngày vi phạm là trả về lỗi của ngày đó.
     *
     * @param leaveTypeId loại nghỉ
     * @param dates       các ngày nghỉ
     * @param isPartTime  dùng notice_hours_part_time hay không
     */
    public String checkAll(int leaveTypeId,
                           List<LocalDate> dates,
                           boolean isPartTime) {

        if (dates == null) {
            return null;
        }

        for (LocalDate d : dates) {
            String err = check(leaveTypeId, d, isPartTime);
            if (err != null) {
                return err;
            }
        }

        return null;
    }

    /**
     * Hạn gửi đơn (dạng ngày) cho ngày nghỉ - dùng để hiển thị cho
     * nhân viên biết mình còn có thể gửi đơn cho ngày nào.
     *
     * @return ngày hạn, hoặc null nếu không áp dụng hạn
     */
    public LocalDate getDeadlineDate(int leaveTypeId,
                                     LocalDate startDate,
                                     boolean isPartTime) {

        if (startDate == null || typeDao.isSameDayAllowed(leaveTypeId)) {
            return null;
        }

        int noticeHours = typeDao.getNoticeHours(leaveTypeId, isPartTime);

        if (noticeHours <= 0) {
            return null;
        }

        if (noticeHours >= 24) {
            int minLeadDays = (int) Math.ceil(noticeHours / 24.0);
            return startDate.minusDays(minLeadDays);
        }

        return startDate;
    }

    /**
     * Số giờ báo trước đang áp dụng (để hiển thị lên UI).
     */
    public Integer getNoticeHours(int leaveTypeId, boolean isPartTime) {
        int v = typeDao.getNoticeHours(leaveTypeId, isPartTime);
        return v < 0 ? null : v;
    }

    // -------------------------------------------------------------
    // Tiện ích định dạng
    // -------------------------------------------------------------

    private String partTimeNote(boolean isPartTime) {
        return isPartTime ? " (quy định cho nhân viên part-time)" : "";
    }

    private static final String[] VN_WEEKDAYS = {
        "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm",
        "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"
    };

    public static String formatVn(LocalDate date) {
        String dd = date.getDayOfMonth() < 10
                ? "0" + date.getDayOfMonth()
                : String.valueOf(date.getDayOfMonth());

        String mm = date.getMonthValue() < 10
                ? "0" + date.getMonthValue()
                : String.valueOf(date.getMonthValue());

        return VN_WEEKDAYS[date.getDayOfWeek().getValue() - 1]
                + " (" + dd + "/" + mm + "/" + date.getYear() + ")";
    }

    public static String formatHours(double hours) {
        if (hours == Math.floor(hours)) {
            return String.valueOf((long) hours);
        }
        return String.valueOf(Math.round(hours * 100.0) / 100.0);
    }

    public static String formatVnTime(LocalDateTime dt) {
        String hh = dt.getHour() < 10
                ? "0" + dt.getHour()
                : String.valueOf(dt.getHour());

        String mm = dt.getMinute() < 10
                ? "0" + dt.getMinute()
                : String.valueOf(dt.getMinute());

        return formatVn(dt.toLocalDate()) + " " + hh + ":" + mm;
    }

    /**
     * Lấy danh sách loại nghỉ kèm cờ same-day (dùng để render UI).
     */
    public List<Map<String, Object>> getTypesForUi() {
        return typeDao.getAll();
    }
}
