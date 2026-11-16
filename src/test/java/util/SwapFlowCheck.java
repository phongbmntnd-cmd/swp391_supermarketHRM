package util;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import dao.ShiftChangeRequestDAO;

/**
 * Kiểm tra LUỒNG ĐỔI CA VỚI ĐỒNG NGHIỆP end-to-end.
 *
 * <p>Kịch bản: 2 nhân viên part-time cùng chi nhánh, cùng chức vụ,
 * cùng nhóm làm việc, nhưng nhóm ca cố định KHÁC NHAU
 * (một chỉ làm ca Sáng, một chỉ làm ca Tối).
 *
 * <p>Trước khi sửa: màn hình hiển thị TRỐNG (không thấy đồng nghiệp)
 * vì {@code getColleagueSchedules} lọc chéo 2 chiều theo nhóm ca.
 *
 * <p>Sau khi sửa: đồng nghiệp hiện ra, đơn tạo được, đồng nghiệp đồng
 * ý, Store Manager duyệt được -> lịch đổi thành công.
 */
public class SwapFlowCheck {

    private static int pass = 0;
    private static int fail = 0;

    public static void main(String[] args) throws Exception {

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        LocalDate weekStart = LocalDate.of(2026, 11, 16);

        // ------------------------------------------------------------
        // 1. Danh sách đồng nghiệp phải có dữ liệu
        // ------------------------------------------------------------
        List<Map<String, Object>> colleagues45 =
                dao.getColleagueSchedules(45, weekStart);

        List<Map<String, Object>> colleagues44 =
                dao.getColleagueSchedules(44, weekStart);

        check(!colleagues45.isEmpty(),
                "User 45 thay đồng nghiệp (không còn màn trống)");

        check(!colleagues44.isEmpty(),
                "User 44 thay đồng nghiệp (không còn màn trống)");

        // Đồng nghiệp phải là người kia
        boolean hasOther45 = false;
        for (Map<String, Object> row : colleagues45) {
            if (Integer.valueOf(44).equals(
                    ((Number) row.get("colleagueId")).intValue())) {
                hasOther45 = true;
                break;
            }
        }
        check(hasOther45,
                "User 45 thay user 44 trong danh sách đồng nghiệp");

        // ------------------------------------------------------------
        // 2. Chọn 1 ca của tôi + 1 ca của đồng nghiệp
        //    (tránh các ca rơi vào ngày nghỉ phép đã duyệt)
        // ------------------------------------------------------------
        int myScheduleId = -1;
        for (Map<String, Object> row : colleagues45) {
            Object id = row.get("id");
            Object date = row.get("workDate");
            if (id != null && date != null) {
                // NV 44 nghỉ phép ngày 16/11 -> tránh ca của NV 44
                // rơi vào ngày đó (đã kiểm tra ở DB).
                if (!"2026-11-16".equals(date.toString())) {
                    myScheduleId = ((Number) id).intValue();
                    break;
                }
            }
        }

        int targetScheduleId = -1;
        for (Map<String, Object> row : dao.getMySchedules(45, weekStart)) {
            Object id = row.get("id");
            Object date = row.get("workDate");
            if (id != null && date != null) {
                if (!"2026-11-16".equals(date.toString())) {
                    targetScheduleId = ((Number) id).intValue();
                    break;
                }
            }
        }

        check(myScheduleId > 0, "Có ca của đồng nghiệp để chọn");
        check(targetScheduleId > 0, "Có ca của chính mình để chọn");

        // ------------------------------------------------------------
        // 3. canSwapShifts phải cho phép đổi chéo nhóm
        // ------------------------------------------------------------
        boolean canSwap = dao.canSwapShifts(
                45, targetScheduleId, myScheduleId, weekStart);

        check(canSwap,
                "canSwapShifts cho phép đổi chéo nhóm ca");

        // ------------------------------------------------------------
        // 4. Tạo đơn đổi ca
        // ------------------------------------------------------------
        boolean created = dao.createSwap(
                45, targetScheduleId, myScheduleId,
                "Kiem tra dong ca qua nhom ca", weekStart);

        check(created, "Tao don doi ca thanh cong");

        if (!created) {
            report();
            return;
        }

        // Lấy id đơn vừa tạo
        int requestId = -1;
        for (Map<String, Object> row : dao.getMyRequests(45)) {
            Object id = row.get("id");
            if (id != null) {
                requestId = ((Number) id).intValue();
                break;
            }
        }

        check(requestId > 0, "Lay duoc id don vua tao");

        // ------------------------------------------------------------
        // 5. Đồng nghiệp đồng ý
        // ------------------------------------------------------------
        boolean responded = dao.respondToSwap(
                requestId, 44, true, "Dong y");

        check(responded, "Dong nghiep dong y doi ca");

        // ------------------------------------------------------------
        // 6. Store Manager duyệt (chi nhánh 1)
        // ------------------------------------------------------------
        boolean approved = dao.review(
                requestId, 1, true, "Phep doi ca");

        check(approved,
                "Store Manager duyet duoc don doi ca"
                + (approved ? "" : " | loi: " + dao.getLastReviewError()));

        // ------------------------------------------------------------
        // 7. Kiểm tra lịch đã đổi thành công
        // ------------------------------------------------------------
        boolean ownerSwapped = false;

        try (java.sql.Connection conn = context.DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                     "SELECT user_id FROM shift_schedules WHERE id = ?")) {

            ps.setInt(1, myScheduleId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ownerSwapped =
                            rs.getInt("user_id") == 45;
                }
            }
        }

        check(ownerSwapped,
                "Lich da doi: user 45 nhan ca cua user 44");

        // ------------------------------------------------------------
        // 8. Dọn dẹp: trả lại lịch về trạng thái ban đầu
        // ------------------------------------------------------------
        try (java.sql.Connection conn = context.DBContext.getConnection()) {
            conn.setAutoCommit(false);

            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                    "UPDATE shift_schedules SET user_id = 44, position_id = 7 "
                    + "WHERE id = ?")) {
                ps.setInt(1, myScheduleId);
                ps.executeUpdate();
            }

            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                    "UPDATE shift_schedules SET user_id = 45, position_id = 7 "
                    + "WHERE id = ?")) {
                ps.setInt(1, targetScheduleId);
                ps.executeUpdate();
            }

            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM shift_change_requests WHERE id = ?")) {
                ps.setInt(1, requestId);
                ps.executeUpdate();
            }

            conn.commit();
        }

        System.out.println("[PASS] Da don dep du lieu test");

        report();
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

    private static void report() {
        System.out.println();
        System.out.println("=== Ket qua: " + pass + " pass, " + fail + " fail ===");

        if (fail > 0) {
            System.exit(1);
        }
    }
}
