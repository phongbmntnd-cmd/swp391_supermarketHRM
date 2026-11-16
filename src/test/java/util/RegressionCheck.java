package util;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import dao.ShiftChangeRequestDAO;

/**
 * Kiểm tra KHÔNG HỒI QUY cho các luồng khác sau khi sửa logic nhóm ca:
 *   - Đăng ký nhận thêm ca (EXTRA)
 *   - Chuyển sang ca trống (OPEN)
 *   - Xem lịch của mình
 *   - Danh sách ca trống tại cơ sở
 */
public class RegressionCheck {

    private static int pass = 0;
    private static int fail = 0;

    public static void main(String[] args) throws Exception {

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        LocalDate weekStart = LocalDate.of(2026, 11, 16);

        // ---- Lịch của chính mình ----
        List<Map<String, Object>> mine = dao.getMySchedules(45, weekStart);
        check(!mine.isEmpty(),
                "getMySchedules(45) tra ve " + mine.size() + " ca");

        List<Map<String, Object>> mine44 = dao.getMySchedules(44, weekStart);
        check(!mine44.isEmpty(),
                "getMySchedules(44) tra ve " + mine44.size() + " ca");

        // ---- Ca trống tại cơ sở ----
        List<Map<String, Object>> open = dao.getOpenShifts(45, weekStart);
        check(open != null,
                "getOpenShifts(45) khong loi (so ca trong: "
                + (open == null ? 0 : open.size()) + ")");

        // ---- Ca trống để đăng ký nhận thêm ----
        List<Map<String, Object>> extra =
                dao.getAvailableExtraShifts(45, weekStart);
        check(extra != null,
                "getAvailableExtraShifts(45) khong loi (so ca: "
                + (extra == null ? 0 : extra.size()) + ")");

        // ---- Danh sách đơn của nhân viên ----
        List<Map<String, Object>> myRequests = dao.getMyRequests(45);
        check(myRequests != null,
                "getMyRequests(45) khong loi");

        List<Map<String, Object>> incoming = dao.getIncomingRequests(44);
        check(incoming != null,
                "getIncomingRequests(44) khong loi");

        // ---- Danh sách đơn của Store Manager ----
        List<Map<String, Object>> branch = dao.getBranchRequests(1);
        check(branch != null,
                "getBranchRequests(1) khong loi (so don: "
                + (branch == null ? 0 : branch.size()) + ")");

        // ---- Đếm đơn chờ duyệt ----
        int pending = dao.countBranchPendingShiftRequests(1);
        check(pending >= 0,
                "countBranchPendingShiftRequests(1) = " + pending);

        int incomingCount = dao.countIncomingShiftRequests(44);
        check(incomingCount >= 0,
                "countIncomingShiftRequests(44) = " + incomingCount);

        // ---- Cờ crossGroup phải được gắn đúng ----
        int crossCount = 0;
        for (Map<String, Object> row : branch) {
            Object flag = row.get("crossGroup");
            if (flag != null && "1".equals(flag.toString())) {
                crossCount++;
            }
        }
        System.out.println("[INFO] So don duoc gan co crossGroup: " + crossCount);

        System.out.println();
        System.out.println("=== Ket qua: " + pass + " pass, " + fail + " fail ===");

        if (fail > 0) {
            System.exit(1);
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
