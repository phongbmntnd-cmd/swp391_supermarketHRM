package util;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;

/**
 * Tiện ích xác định TUẦN ĐANG XEM cho toàn hệ thống.
 *
 * <h3>Vì sao cần lớp này?</h3>
 * Trước đây mỗi servlet tự tính tuần mặc định bằng
 * {@code TemporalAdjusters.next(DayOfWeek.MONDAY)} hoặc
 * {@code previousOrSame(...)} một cách rời rạc. Kết quả là lỗi
 * "lệch tuần" rất khó chịu:
 *
 * <ul>
 *   <li>{@code TemporalAdjusters.next(MONDAY)} <b>loại trừ chính ngày
 *       hôm nay</b>, nên vào Thứ Hai nó nhảy sang tuần kế tiếp. Hôm
 *       16/11 (Thứ Hai) form "Khai báo lịch rảnh" hiện tuần
 *       23/11–29/11, trong khi hôm trước (15/11 – Chủ Nhật) lại
 *       hiện tuần 16/11–22/11. Cùng một ngày hôm nay, mốc tuần
 *       nhảy lung tung -> nhân viên tưởng hệ thống lỗi.</li>
 *   <li>Quy tắc nghiệp vụ của hệ thống là <b>tuần làm việc = tuần
 *       chứa ngày làm việc</b>, tính bằng
 *       {@code previousOrSame(MONDAY)} (xem
 *       {@code ShiftScheduleDAO.hasRegisteredAvailability}). Màn "Khai
 *       báo lịch rảnh" lưu theo mốc tuần khác -> Store Manager
 *       không bao giờ xếp được ca cho nhân viên đã đăng ký rảnh.</li>
 * </ul>
 *
 * <h3>Quy tắc thống nhất</h3>
 * <ul>
 *   <li><b>Tuần hiện tại</b> ({@link #currentMonday()}): thứ Hai của
 *       tuần chứa hôm nay. Đây là mốc MẶC ĐỊNH cho mọi màn:
 *       Lịch của tôi, Khai báo lịch rảnh, Yêu cầu đổi ca và cả
 *       màn xếp ca của Store Manager.</li>
 *   <li><b>Xem tuần khác</b> ({@link #resolveWeekStart(String, LocalDate)}):
 *       nhân viên có thể xem lại tuần trước / tuần sau (chỉ xem),
 *       nhưng chỉ được <b>ghi</b> vào tuần hiện tại.</li>
 * </ul>
 */
public final class WeekUtil {

    private WeekUtil() {
        // Lớp tiện ích -> không cho khởi tạo.
    }

    /**
     * Thứ Hai của tuần HIỆN TẠI (tuần đang chạy).
     *
     * <p>Dùng chung cho {@code /employee/my-schedule},
     * {@code /employee/availability}, {@code /employee/request-shift}
     * và {@code /store-manager/schedule} để mọi màn luôn hiển thị
     * cùng một tuần và khớp với mốc tuần mà Store Manager dùng khi
     * tra cứu lịch rảnh.
     */
    public static LocalDate currentMonday() {
        return mondayOf(LocalDate.now());
    }

    /**
     * Tuần của một ngày bất kỳ (luôn trả về thứ Hai).
     */
    public static LocalDate mondayOf(LocalDate date) {
        if (date == null) {
            return currentMonday();
        }

        return date.with(
                TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }

    /**
     * Tuần đang xem từ tham số {@code startDate} của request.
     *
     * @param rawStartDate giá trị tham số (có thể null/rỗng/không hợp lệ)
     * @return thứ Hai của tuần được chọn, hoặc {@link #currentMonday()}
     *         nếu không có tham số hợp lệ.
     */
    public static LocalDate resolveWeekStart(String rawStartDate) {
        return resolveWeekStart(rawStartDate, currentMonday());
    }

    /**
     * Tuần đang xem từ tham số, có fallback tùy chọn.
     *
     * @param rawStartDate giá trị tham số (có thể null/rỗng/không hợp lệ)
     * @param fallback    tuần dùng khi không có tham số hợp lệ
     */
    public static LocalDate resolveWeekStart(
            String rawStartDate, LocalDate fallback) {

        if (rawStartDate != null && !rawStartDate.trim().isEmpty()) {
            try {
                return mondayOf(LocalDate.parse(rawStartDate.trim()));
            } catch (Exception e) {
                // Tham số không hợp lệ -> dùng tuần fallback.
            }
        }

        return fallback;
    }

    /**
     * Cổng đăng ký lịch rảnh chỉ mở từ Thứ Hai đến hết Thứ Tư.
     */
    public static boolean isRegistrationWindowOpen(LocalDate today) {
        if (today == null) {
            return false;
        }

        DayOfWeek day = today.getDayOfWeek();

        return day == DayOfWeek.MONDAY
                || day == DayOfWeek.TUESDAY
                || day == DayOfWeek.WEDNESDAY;
    }
}
