package util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import context.DBContext;

/**
 * Kiểm tra logic NHÓM CA CỐ ĐỊNH khớp giữa Java và SQL.
 *
 * <p>Chạy độc lập: {@code java -cp target/classes;target/test-classes util.FixedShiftLogicCheck}
 */
public class FixedShiftLogicCheck {

    private static int pass = 0;
    private static int fail = 0;

    public static void main(String[] args) throws Exception {

        // ---- 1. Logic Java ----
        check(ShiftTypeUtil.isAllowedFixedShift(null, "Ca Tối"),
                "null -> cho pép mọi ca");
        check(ShiftTypeUtil.isAllowedFixedShift("", "Ca Tối"),
                "rỗng -> cho pép mọi ca");
        check(ShiftTypeUtil.isAllowedFixedShift("PT_FLEXIBLE", "Ca Tối"),
                "PT_FLEXIBLE -> cho pép mọi ca");
        check(ShiftTypeUtil.isAllowedFixedShift("PT_SEASONAL_WEEKEND", "Ca Sáng"),
                "PT_SEASONAL_WEEKEND -> cho pép mọi ca");
        check(ShiftTypeUtil.isAllowedFixedShift("FT_ROTATING", "Ca Chiều"),
                "FT_ROTATING -> cho pép mọi ca");
        check(ShiftTypeUtil.isAllowedFixedShift("Sang/Toi", "Ca Tối"),
                "Sang/Toi -> cho pép mọi ca");
        check(ShiftTypeUtil.isAllowedFixedShift("PT_FIXED_MORNING", "Ca Sáng"),
                "PT_FIXED_MORNING -> cho pép ca Sáng");
        check(!ShiftTypeUtil.isAllowedFixedShift("PT_FIXED_MORNING", "Ca Tối"),
                "PT_FIXED_MORNING -> CHẶN ca Tối");
        check(!ShiftTypeUtil.isAllowedFixedShift("PT_FIXED_EVENING", "Ca Sáng"),
                "PT_FIXED_EVENING -> CHẶN ca Sáng");
        check(!ShiftTypeUtil.isAllowedFixedShift("PT_FIXED_AFTERNOON", "Ca Tối"),
                "PT_FIXED_AFTERNOON -> CHẶN ca Tối");
        check(ShiftTypeUtil.isAllowedFixedShift("FT_FIXED_MORNING", "Ca Sáng"),
                "FT_FIXED_MORNING -> cho pép ca Sáng");
        check(!ShiftTypeUtil.isAllowedFixedShift("FT_FIXED_EVENING", "Ca Sáng"),
                "FT_FIXED_EVENING -> CHẶN ca Sáng");

        check("Ca Sáng".equals(ShiftTypeUtil.groupLabel("PT_FIXED_MORNING")),
                "groupLabel(PT_FIXED_MORNING) = Ca Sáng");
        check("Ca Tối".equals(ShiftTypeUtil.groupLabel("pt_fixed_evening")),
                "groupLabel(pt_fixed_evening) = Ca Tối (không phân biệt hoa thường)");
        check(ShiftTypeUtil.groupLabel("PT_FLEXIBLE") == null,
                "groupLabel(PT_FLEXIBLE) = null (không ràng buộc)");

        // ---- 2. So khớp Java <-> SQL trên DB thật ----
        checkSqlMatchesJava();

        System.out.println();
        System.out.println("=== Ket qua: " + pass + " pass, " + fail + " fail ===");

        if (fail > 0) {
            System.exit(1);
        }
    }

    /**
     * Với MỌI cặp (shift_type, ca) trong DB, so sánh kết quả Java
     * với kết quả SQL của {@code fixedShiftOk(...)}.
     */
    private static void checkSqlMatchesJava() throws Exception {

        String sql = "SELECT ep.shift_type, s.name FROM employee_profiles ep "
                + "CROSS JOIN shifts s";

        String fixedOk = "(ep.shift_type IS NULL OR TRIM(ep.shift_type) = '' "
                + "OR (UPPER(TRIM(ep.shift_type)) = 'PT_FIXED_MORNING' "
                + "    AND LOWER(s.name) LIKE '%sáng%') "
                + "OR (UPPER(TRIM(ep.shift_type)) = 'PT_FIXED_AFTERNOON' "
                + "    AND LOWER(s.name) LIKE '%chiều%') "
                + "OR (UPPER(TRIM(ep.shift_type)) = 'PT_FIXED_EVENING' "
                + "    AND LOWER(s.name) LIKE '%tối%') "
                + "OR (UPPER(TRIM(ep.shift_type)) = 'FT_FIXED_MORNING' "
                + "    AND LOWER(s.name) LIKE '%sáng%') "
                + "OR (UPPER(TRIM(ep.shift_type)) = 'FT_FIXED_AFTERNOON' "
                + "    AND LOWER(s.name) LIKE '%chiều%') "
                + "OR (UPPER(TRIM(ep.shift_type)) = 'FT_FIXED_EVENING' "
                + "    AND LOWER(s.name) LIKE '%tối%') "
                + "OR UPPER(TRIM(ep.shift_type)) NOT IN ("
                + "'PT_FIXED_MORNING','PT_FIXED_AFTERNOON','PT_FIXED_EVENING',"
                + "'FT_FIXED_MORNING','FT_FIXED_AFTERNOON','FT_FIXED_EVENING'))";

        String sqlCheck = "SELECT ep.shift_type, s.name, (" + fixedOk + ") AS ok "
                + "FROM employee_profiles ep CROSS JOIN shifts s";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlCheck);
             ResultSet rs = ps.executeQuery()) {

            int compared = 0;

            while (rs.next()) {
                String shiftType = rs.getString(1);
                String shiftName = rs.getString(2);
                boolean sqlOk = rs.getBoolean(3);

                boolean javaOk =
                        ShiftTypeUtil.isAllowedFixedShift(shiftType, shiftName);

                compared++;

                if (sqlOk != javaOk) {
                    fail++;
                    System.out.println("[FAIL] Java=" + javaOk
                            + " SQL=" + sqlOk
                            + " | shift_type=" + shiftType
                            + " ca=" + shiftName);
                }
            }

            pass++;
            System.out.println("[PASS] Java <-> SQL khop tren "
                    + compared + " cap (shift_type, ca)");
        }
    }

    private static void check(boolean condition, String description) {
        if (condition) {
            pass++;
            System.out.println("[PASS] " + description);
        } else {
            fail++;
            System.out.println("[FAIL] " + description);
        }
    }
}
