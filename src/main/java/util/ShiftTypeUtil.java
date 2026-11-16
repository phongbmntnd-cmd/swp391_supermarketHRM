package util;

import java.util.Locale;

/**
 * Quy tắc NHÓM CA CỐ ĐỊNH của nhân viên.
 *
 * <h3>Vì sao cần class này?</h3>
 * Trước đây logic này bị viết trùng lặp ở 3 nơi với 2 logic KHÁC NHAU:
 * <ul>
 *   <li>SQL {@code fixedShiftOk(...)} trong
 *       {@code ShiftChangeRequestDAO} - chặn MỌI {@code shift_type}
 *       không nằm trong 3 giá trị {@code PT_FIXED_*}.</li>
 *   <li>Java {@code isAllowedFixedShift(...)} - lại cho qua mọi giá trị
 *       lạ.</li>
 * </ul>
 * Hệ quả: nhân viên part-time linh hoạt
 * ({@code PT_FLEXIBLE}, {@code PT_SEASONAL_WEEKEND}, {@code Sang/Toi})
 * bị chặn toàn bộ ca ở màn hiển thị nhưng lại đi qua được bước duyệt
 * -> nhân viên không hiện được gì mà hệ thống lại cho tạo đơn.
 *
 * <h3>Quy tắc chuẩn</h3>
 * <ul>
 *   <li>Chỉ {@code PT_FIXED_MORNING}, {@code PT_FIXED_AFTERNOON},
 *       {@code PT_FIXED_EVENING} (và bản {@code FT_FIXED_*} tương ứng)
 *       là ràng buộc thật sự.</li>
 *   <li>Mọi giá trị khác (NULL, rỗng, {@code PT_FLEXIBLE},
 *       {@code PT_SEASONAL_WEEKEND}, {@code FT_ROTATING},
 *       {@code Sang/Toi}, ...) = KHÔNG ràng buộc -> được làm mọi ca.</li>
 * </ul>
 */
public final class ShiftTypeUtil {

    /** Nhóm ca cố định -> từ khóa trong tên ca. */
    private static final String[][] FIXED_GROUPS = {
        {"PT_FIXED_MORNING", "sáng"},
        {"PT_FIXED_AFTERNOON", "chiều"},
        {"PT_FIXED_EVENING", "tối"},
        {"FT_FIXED_MORNING", "sáng"},
        {"FT_FIXED_AFTERNOON", "chiều"},
        {"FT_FIXED_EVENING", "tối"},
    };

    private ShiftTypeUtil() {
    }

    /**
     * Chuẩn hóa {@code shift_type} về dạng so sánh được
     * (viết hoa, bỏ khoảng trắng thừa).
     */
    public static String normalize(String shiftType) {
        if (shiftType == null) {
            return "";
        }
        return shiftType.trim().toUpperCase(Locale.ROOT);
    }

    /**
     * Nhân viên có bị ràng buộc nhóm ca cố định không?
     *
     * @param shiftType {@code employee_profiles.shift_type}
     * @return true nếu chỉ được làm đúng một nhóm ca
     */
    public static boolean hasFixedGroup(String shiftType) {
        String type = normalize(shiftType);

        for (String[] group : FIXED_GROUPS) {
            if (group[0].equals(type)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Nhân viên có được phép làm ca này không (theo nhóm ca cố định)?
     *
     * <p>Nhân viên không có ràng buộc (linh hoạt) -> luôn được phép.
     *
     * @param shiftType  {@code employee_profiles.shift_type}
     * @param shiftName  tên ca (ví dụ "Ca Sáng", "Ca Tối")
     * @return true nếu được phép
     */
    public static boolean isAllowedFixedShift(
            String shiftType, String shiftName) {

        if (!hasFixedGroup(shiftType)) {
            return true;   // không ràng buộc -> cho phép mọi ca
        }

        if (shiftName == null) {
            return true;
        }

        String type = normalize(shiftType);
        String name = shiftName.toLowerCase(Locale.ROOT);

        for (String[] group : FIXED_GROUPS) {
            if (group[0].equals(type)) {
                return name.contains(group[1]);
            }
        }

        return true;
    }

    /**
     * Tên nhóm ca cố định để hiển thị cho người dùng.
     *
     * @param shiftType {@code employee_profiles.shift_type}
     * @return ví dụ "Ca Sáng", "Ca Tối", hoặc null nếu không ràng buộc
     */
    public static String groupLabel(String shiftType) {
        String type = normalize(shiftType);

        for (String[] group : FIXED_GROUPS) {
            if (group[0].equals(type)) {
                String keyword = group[1];

                if ("sáng".equals(keyword)) {
                    return "Ca Sáng";
                }
                if ("chiều".equals(keyword)) {
                    return "Ca Chiều";
                }
                return "Ca Tối";
            }
        }

        return null;
    }

    /**
     * Mô tả ràng buộc để hiển thị cho người dùng (ví dụ trong thông báo
     * lỗi khi Store xếp ca sai nhóm).
     *
     * @param shiftType {@code employee_profiles.shift_type}
     * @return chuỗi mô tả, hoặc null nếu nhân viên không bị ràng buộc
     */
    public static String describeRestriction(String shiftType) {
        String label = groupLabel(shiftType);

        if (label == null) {
            return null;
        }

        return "nhân viên chỉ làm " + label;
    }
}
