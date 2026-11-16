package service;

import dao.LeaveTypeDAO;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Test luật hạn gửi đơn nghỉ phép ("báo trước" = TỐI THIỂU).
 *
 * Chạy: mvn -o test-compile exec:java -Dexec.mainClass=service.LeaveNoticeTest
 * hoặc: java -cp target/classes;mysql-connector.jar service.LeaveNoticeTest
 *
 * Cần cấu hình leave_types trong DB (xem Database/migration_leave_same_day.sql):
 *   ANNUAL  : notice 48h (full) / 48h (part-time), same_day = 0
 *   UNPAID  : notice 24h (full) / 48h (part-time), same_day = 0
 *   SICK    : notice  4h, same_day = 1
 *   FUNERAL : notice  0h, same_day = 1
 */
public class LeaveNoticeTest {

    private static int ANNUAL;
    private static int SICK;
    private static int UNPAID;
    private static int FUNERAL;

    public static void main(String[] args) throws Exception {
        loadTypeIds();

        System.out.println("=== TEST LUẬT HẠN GỬI ĐƠN NGHỈ PHÉP ===\n");

        testSameDayAllowed();
        testSickSameDay();
        testFuneralSameDay();
        testAnnualTooLate();
        testAnnualJustInTime();
        testAnnualEarlyOk();
        testUnpaidBoundary();
        testPartTimeUsesOwnNotice();
        testCheckAllMultipleDates();
        testDeadlineDate();

        System.out.println("\n=== TẤT CẢ TEST ĐÃ CHẠY XONG ===");
    }

    private static void loadTypeIds() {
        List<Map<String, Object>> types = new LeaveTypeDAO().getAll();

        for (Map<String, Object> t : types) {
            String code = String.valueOf(t.get("code"));
            int id = ((Number) t.get("id")).intValue();

            if ("ANNUAL".equals(code)) {
                ANNUAL = id;
            } else if ("SICK".equals(code)) {
                SICK = id;
            } else if ("UNPAID".equals(code)) {
                UNPAID = id;
            } else if ("FUNERAL".equals(code)) {
                FUNERAL = id;
            }
        }

        System.out.println("ANNUAL=" + ANNUAL
                + " SICK=" + SICK
                + " UNPAID=" + UNPAID
                + " FUNERAL=" + FUNERAL + "\n");
    }

    // ---------------------------------------------------------------
    // TEST 1: Cột same_day_allowed đúng cho nghỉ ốm / nghỉ tang
    // ---------------------------------------------------------------
    private static void testSameDayAllowed() {
        System.out.println("--- TEST 1: cờ same_day_allowed ---");

        LeaveTypeDAO dao = new LeaveTypeDAO();

        assertTrue(dao.isSameDayAllowed(SICK),
                "Nghỉ ốm phải được làm đơn trong ngày");
        assertTrue(dao.isSameDayAllowed(FUNERAL),
                "Nghỉ tang phải được làm đơn trong ngày");
        assertTrue(!dao.isSameDayAllowed(ANNUAL),
                "Nghỉ phép năm KHÔNG được làm đơn trong ngày");
        assertTrue(!dao.isSameDayAllowed(UNPAID),
                "Nghỉ không lương KHÔNG được làm đơn trong ngày");
    }

    // ---------------------------------------------------------------
    // TEST 2: Nghỉ ốm -> gửi trong ngày vẫn OK
    // ---------------------------------------------------------------
    private static void testSickSameDay() {
        System.out.println("\n--- TEST 2: nghỉ ốm gửi trong ngày ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        String err = v.check(SICK, LocalDate.now(), false);
        System.out.println("  Nghỉ ốm hôm nay -> " + (err == null ? "OK" : err));
        assertTrue(err == null,
                "Nghỉ ốm gửi trong ngày phải hợp lệ (không validate hạn)");

        // Nghỉ ốm tương lai cũng OK
        err = v.check(SICK, LocalDate.now().plusDays(3), false);
        assertTrue(err == null,
                "Nghỉ ốm tương lai phải hợp lệ");
    }

    // ---------------------------------------------------------------
    // TEST 3: Nghỉ tang -> gửi trong ngày OK
    // ---------------------------------------------------------------
    private static void testFuneralSameDay() {
        System.out.println("\n--- TEST 3: nghỉ tang gửi trong ngày ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        String err = v.check(FUNERAL, LocalDate.now(), false);
        System.out.println("  Nghỉ tang hôm nay -> " + (err == null ? "OK" : err));
        assertTrue(err == null,
                "Nghỉ tang gửi trong ngày phải hợp lệ");
    }

    // ---------------------------------------------------------------
    // TEST 4: Nghỉ phép năm gửi QUÁ MUỘN -> bị chặn
    // ---------------------------------------------------------------
    private static void testAnnualTooLate() {
        System.out.println("\n--- TEST 4: nghỉ phép năm gửi quá muộn ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        // ANNUAL full-time: báo trước 2 ngày.
        // Nghỉ NGAY NGÀY MAI -> deadline = hôm qua -> quá hạn.
        LocalDate tomorrow = LocalDate.now().plusDays(1);

        String err = v.check(ANNUAL, tomorrow, false);
        System.out.println("  Nghỉ ngày mai -> " + err);
        assertTrue(err != null,
                "Nghỉ phép năm ngày mai (báo trước 2 ngày) phải bị chặn");
        assertTrue(err.contains("quá hạn"),
                "Thông báo phải nói rõ quá hạn");

        // Nghỉ HÔM NAY -> deadline = 2 ngày trước -> quá hạn
        err = v.check(ANNUAL, LocalDate.now(), false);
        System.out.println("  Nghỉ hôm nay -> " + err);
        assertTrue(err != null,
                "Nghỉ phép năm hôm nay phải bị chặn");
    }

    // ---------------------------------------------------------------
    // TEST 5: Nghỉ phép năm gửi ĐÚNG HẠN -> OK (hết hạn 23:59)
    // ---------------------------------------------------------------
    private static void testAnnualJustInTime() {
        System.out.println("\n--- TEST 5: nghỉ phép năm gửi đúng hạn ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        // deadline = ngày nghỉ - 2 ngày. Hôm nay phải <= deadline.
        LocalDate leaveDate = LocalDate.now().plusDays(2);

        String err = v.check(ANNUAL, leaveDate, false);
        System.out.println("  Nghỉ " + leaveDate + " -> " + (err == null ? "OK" : err));
        assertTrue(err == null,
                "Gửi đúng ngày hạn (hạn = ngày nghỉ - 2 ngày) phải hợp lệ");
    }

    // ---------------------------------------------------------------
    // TEST 6: Gửi SỚM -> luôn OK (không giới hạn cửa sổ gửi đơn)
    // ---------------------------------------------------------------
    private static void testAnnualEarlyOk() {
        System.out.println("\n--- TEST 6: gửi sớm luôn hợp lệ ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        for (int days : new int[]{3, 7, 30, 90}) {
            LocalDate leaveDate = LocalDate.now().plusDays(days);
            String err = v.check(ANNUAL, leaveDate, false);
            System.out.println("  Nghỉ sau " + days + " ngày -> "
                    + (err == null ? "OK" : err));
            assertTrue(err == null,
                    "Gửi sớm " + days + " ngày phải hợp lệ");
        }
    }

    // ---------------------------------------------------------------
    // TEST 7: UNPAID báo trước 1 ngày -> nghỉ ngày mai bị chặn
    // ---------------------------------------------------------------
    private static void testUnpaidBoundary() {
        System.out.println("\n--- TEST 7: nghỉ không lương (báo trước 1 ngày) ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        // deadline = ngày nghỉ - 1 ngày = hôm nay -> OK
        String err = v.check(UNPAID, LocalDate.now().plusDays(1), false);
        System.out.println("  Nghỉ ngày mai -> " + (err == null ? "OK" : err));
        assertTrue(err == null,
                "Nghỉ không lương ngày mai (báo trước 1 ngày) phải hợp lệ");

        // deadline = hôm nay - 1 -> quá hạn
        err = v.check(UNPAID, LocalDate.now(), false);
        System.out.println("  Nghỉ hôm nay -> " + err);
        assertTrue(err != null,
                "Nghỉ không lương hôm nay phải bị chặn");
    }

    // ---------------------------------------------------------------
    // TEST 8: Part-time dùng notice_hours_part_time riêng
    // ---------------------------------------------------------------
    private static void testPartTimeUsesOwnNotice() {
        System.out.println("\n--- TEST 8: part-time dùng hạn riêng ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        // ANNUAL part-time: báo trước 48h = 2 ngày (giống full-time).
        // Nghỉ sau 1 ngày -> cả hai đều bị chặn.
        LocalDate leaveDate = LocalDate.now().plusDays(1);

        String errPt = v.check(ANNUAL, leaveDate, true);
        String errFt = v.check(ANNUAL, leaveDate, false);

        System.out.println("  Part-time -> " + errPt);
        System.out.println("  Full-time -> " + (errFt == null ? "OK" : errFt));

        assertTrue(errPt != null,
                "Part-time (báo trước 2 ngày) nghỉ sau 1 ngày phải bị chặn");
        assertTrue(errFt != null,
                "Full-time (báo trước 2 ngày) nghỉ sau 1 ngày phải bị chặn");

        // Nghỉ sau 2 ngày -> cả hai đều hợp lệ (đúng hạn).
        errPt = v.check(ANNUAL, LocalDate.now().plusDays(2), true);
        errFt = v.check(ANNUAL, LocalDate.now().plusDays(2), false);
        System.out.println("  Nghỉ sau 2 ngày -> Part-time: "
                + (errPt == null ? "OK" : errPt)
                + " | Full-time: " + (errFt == null ? "OK" : errFt));
        assertTrue(errPt == null,
                "Part-time nghỉ sau 2 ngày phải hợp lệ");
        assertTrue(errFt == null,
                "Full-time nghỉ sau 2 ngày phải hợp lệ");

        // UNPAID: part-time báo trước 48h (2 ngày), full-time 24h (1 ngày).
        // Nghỉ sau 1 ngày -> full-time OK, part-time bị chặn.
        errPt = v.check(UNPAID, LocalDate.now().plusDays(1), true);
        errFt = v.check(UNPAID, LocalDate.now().plusDays(1), false);
        System.out.println("  UNPAID nghỉ sau 1 ngày -> Part-time: "
                + (errPt == null ? "OK" : errPt)
                + " | Full-time: " + (errFt == null ? "OK" : errFt));
        assertTrue(errPt != null,
                "UNPAID part-time (báo trước 2 ngày) nghỉ sau 1 ngày phải bị chặn");
        assertTrue(errFt == null,
                "UNPAID full-time (báo trước 1 ngày) nghỉ sau 1 ngày phải hợp lệ");
    }

    // ---------------------------------------------------------------
    // TEST 9: checkAll - 1 ngày vi phạm là cả đơn bị chặn
    // ---------------------------------------------------------------
    private static void testCheckAllMultipleDates() {
        System.out.println("\n--- TEST 9: validate nhiều ngày (part-time tick ca) ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        List<LocalDate> dates = new ArrayList<>();
        dates.add(LocalDate.now().plusDays(10));
        dates.add(LocalDate.now().plusDays(20));

        String err = v.checkAll(ANNUAL, dates, true);
        System.out.println("  Cả 2 ngày đủ hạn -> " + (err == null ? "OK" : err));
        assertTrue(err == null,
                "Các ngày đủ hạn phải hợp lệ");

        // Thêm 1 ngày vi phạm
        dates.add(LocalDate.now().plusDays(1));

        err = v.checkAll(ANNUAL, dates, true);
        System.out.println("  Thêm ngày vi phạm -> " + err);
        assertTrue(err != null,
                "Chỉ cần 1 ngày vi phạm là cả đơn bị chặn");

        // Nghỉ ốm: dù có ngày vi phạm vẫn OK
        err = v.checkAll(SICK, dates, true);
        assertTrue(err == null,
                "Nghỉ ốm không validate hạn dù có ngày gần");
    }

    // ---------------------------------------------------------------
    // TEST 10: getDeadlineDate
    // ---------------------------------------------------------------
    private static void testDeadlineDate() {
        System.out.println("\n--- TEST 10: tính ngày hạn ---");

        LeaveNoticeValidator v = new LeaveNoticeValidator();

        LocalDate leaveDate = LocalDate.now().plusDays(10);

        LocalDate dl = v.getDeadlineDate(ANNUAL, leaveDate, false);
        System.out.println("  ANNUAL deadline = " + dl);
        assertTrue(dl != null && dl.equals(leaveDate.minusDays(2)),
                "ANNUAL full-time: hạn = ngày nghỉ - 2 ngày");

        dl = v.getDeadlineDate(ANNUAL, leaveDate, true);
        System.out.println("  ANNUAL (part-time) deadline = " + dl);
        assertTrue(dl != null && dl.equals(leaveDate.minusDays(2)),
                "ANNUAL part-time: hạn = ngày nghỉ - 2 ngày (48 giờ)");

        dl = v.getDeadlineDate(SICK, leaveDate, false);
        System.out.println("  SICK deadline = " + dl);
        assertTrue(dl == null,
                "Nghỉ ốm không có hạn (làm đơn trong ngày)");
    }

    // ---------------------------------------------------------------
    private static void assertTrue(boolean condition, String message) {
        if (condition) {
            System.out.println("  [PASS] " + message);
        } else {
            System.out.println("  [FAIL] " + message);
            throw new AssertionError(message);
        }
    }
}
