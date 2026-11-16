package util;

import dao.ShiftScheduleDAO;

/**
 * Kiểm tra {@code ShiftScheduleDAO.canAssign} có chặn đúng
 * nhóm ca cố định hay không.
 *
 * <p>Trước khi sửa: NV "chỉ làm ca Sáng" vẫn bị Store xếp vào
 * "Ca Tối" -> sinh ra lịch vi phạm hợp đồng.
 */
public class CanAssignCheck {

    private static int pass = 0;
    private static int fail = 0;

    public static void main(String[] args) {

        ShiftScheduleDAO dao = new ShiftScheduleDAO();

        // NV 44 & 45 hiện PT_FLEXIBLE -> được xếp mọi ca.
        check(dao.isAllowedFixedShift(44, 1),
                "NV 44 (PT_FLEXIBLE) duoc xep ca Sang");
        check(dao.isAllowedFixedShift(44, 3),
                "NV 44 (PT_FLEXIBLE) duoc xep ca Toi");
        check(dao.isAllowedFixedShift(45, 1),
                "NV 45 (PT_FLEXIBLE) duoc xep ca Sang");
        check(dao.isAllowedFixedShift(45, 3),
                "NV 45 (PT_FLEXIBLE) duoc xep ca Toi");

        // NV full-time không ràng buộc -> mọi ca.
        check(dao.isAllowedFixedShift(5, 1),
                "NV 5 (FULL_TIME, null) duoc xep ca Sang");
        check(dao.isAllowedFixedShift(5, 3),
                "NV 5 (FULL_TIME, null) duoc xep ca Toi");

        // ---- Mô phỏng NV có nhóm ca cố định ----
        // Tạm đổi NV 45 sang PT_FIXED_MORNING, kiểm tra, rồi khôi phục.
        try {
            setShiftType(45, "PT_FIXED_MORNING");

            check(!dao.isAllowedFixedShift(45, 3),
                    "NV PT_FIXED_MORNING -> BI CHAN ca Toi");
            check(!dao.isAllowedFixedShift(45, 2),
                    "NV PT_FIXED_MORNING -> BI CHAN ca Chieu");
            check(dao.isAllowedFixedShift(45, 1),
                    "NV PT_FIXED_MORNING -> duoc xep ca Sang");
            check(dao.isAllowedFixedShift(45, 4),
                    "NV PT_FIXED_MORNING -> duoc xep ca Full-time Sang-Chieu");

            // canAssign phải trả false khi xếp sai nhóm ca
            boolean canAssign = dao.canAssign(1, 45, 7, 3, "2026-11-19");
            check(!canAssign,
                    "canAssign(chan) -> false khi xep NV ca Sang vao ca Toi");

        } catch (Exception e) {
            fail++;
            System.out.println("[FAIL] Loi khi kiem tra nhom ca co dinh: "
                    + e.getMessage());
        } finally {
            try {
                setShiftType(45, "PT_FLEXIBLE");
            } catch (Exception ignored) {
                // bo qua
            }
        }

        // ---- Kiểm tra lại sau khi khôi phục ----
        check(dao.isAllowedFixedShift(45, 3),
                "Sau khi khoi phuc, NV 45 duoc xep ca Toi");

        System.out.println();
        System.out.println("=== Ket qua: " + pass + " pass, " + fail + " fail ===");

        if (fail > 0) {
            System.exit(1);
        }
    }

    private static void setShiftType(int userId, String shiftType)
            throws Exception {

        try (java.sql.Connection conn = context.DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                     "UPDATE employee_profiles SET shift_type = ? "
                     + "WHERE user_id = ?")) {

            ps.setString(1, shiftType);
            ps.setInt(2, userId);
            ps.executeUpdate();
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
