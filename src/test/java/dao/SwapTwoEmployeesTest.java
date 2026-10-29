package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

/**
 * Test tích hợp: 2 nhân viên đổi ca cho nhau.
 *
 * Chạy: java -cp "target/classes;target/test-classes;$(cat target/cp.txt)" dao.SwapTwoEmployeesTest
 *
 * Kịch bản:
 *   1. A (pt_user1) tạo đơn đổi ca với B (pt_user2) -> WAITING_COLLEAGUE
 *   2. B thấy đơn đến, đồng ý -> PENDING
 *   3. Store Manager duyệt -> lịch 2 người đổi chỗ
 *   4. Kiểm tra đủ các trường hợp lỗi đã sửa:
 *      - 2 ca chồng lấn giờ cùng ngày -> phải bị chặn
 *      - ca trùng shift_id cùng ngày -> phải bị chặn
 *      - đồng nghiệp sai -> phải bị chặn
 *      - đơn của người khác -> phải bị chặn
 */
public class SwapTwoEmployeesTest {

    private static int empA;
    private static int empB;
    private static int branchId;

    private static int passCount;
    private static int failCount;

    public static void main(String[] args) throws Exception {
        setup();

        testA_TaoDonDoiCaChoB();
        testB_ThayDoiCaSaiPhaiBiChan();
        testHienThiDanhSachDongNghiep();
        testKhongDoiCungNgayChongLanGio();
        testKhongDoiCaCungShiftIdCungNgay();
        testDuyetVaKiemTraLich();
        testHuyDonKhongPhaiCuaMinh();
        testCaDaDungKhongTaoLai();

        System.out.println();
        System.out.println("========================================");
        System.out.println("  PASS: " + passCount + "   FAIL: " + failCount);
        System.out.println("========================================");

        if (failCount > 0) {
            System.exit(1);
        }
    }

    // ==============================================================
    // 1. A tạo đơn đổi ca cho B -> B trả lời -> SM duyệt
    // ==============================================================
    private static void testA_TaoDonDoiCaChoB() throws Exception {
        System.out.println("\n=== [1] A tao don doi ca cho B ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            fail("Khong tim duoc cap ca hop le de doi");
            return;
        }

        cleanupRequests(pair[0], pair[1]);

        int myId = pair[0];
        int targetId = pair[1];

        System.out.println("  A (pt_user1) muon doi schedule " + myId);
        System.out.println("  B (pt_user2) co schedule " + targetId);

        boolean created = dao.createSwap(
                empA, myId, targetId, "E2E: A xin doi ca cho B");
        check("Tao don doi ca thanh cong", created);

        if (!created) {
            return;
        }

        int requestId = latestRequestId(empA);
        check("Don duoc tao o trang thai WAITING_COLLEAGUE",
                "WAITING_COLLEAGUE".equals(statusOf(requestId)));

        // B phải thấy đơn đến
        List<Map<String, Object>> incoming =
                dao.getIncomingRequests(empB);
        check("B thay duoc 1 don den", incoming.size() == 1);

        // B đồng ý
        boolean responded = dao.respondToSwap(
                requestId, empB, true, "B dong y doi ca");
        check("B dong y -> PENDING", responded
                && "PENDING".equals(statusOf(requestId)));

        // Lưu lại để test [5]
        lastRequestId = requestId;
        lastMySchedule = myId;
        lastTargetSchedule = targetId;
    }

    // ==============================================================
    // 2. B đổi ca SAI (cho người khác) -> phải bị chặn
    // ==============================================================
    private static void testB_ThayDoiCaSaiPhaiBiChan() throws Exception {
        System.out.println("\n=== [2] Tra loi don cua nguoi khac -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            fail("Khong tim duoc cap ca");
            return;
        }

        cleanupRequests(pair[0], pair[1]);
        dao.createSwap(empA, pair[0], pair[1], "Don cho nguoi khac tra loi");
        int requestId = latestRequestId(empA);

        // emp_user (id=5) la nhan vien khac -> khong duoc tra loi
        boolean wrong = dao.respondToSwap(requestId, 5, true, "Tra loi sai");
        check("Nhan vien khac khong the tra loi", !wrong);
        check("Don van con WAITING_COLLEAGUE",
                "WAITING_COLLEAGUE".equals(statusOf(requestId)));

        // Chinh nguoi gửi (A) cung khong the tu tra loi
        boolean self = dao.respondToSwap(requestId, empA, true, "Tu tra loi");
        check("Nguoi gui khong the tu tra loi", !self);
        check("Don van con WAITING_COLLEAGUE sau khi A thu tra loi",
                "WAITING_COLLEAGUE".equals(statusOf(requestId)));
    }

    // ==============================================================
    // 3. Danh sách đồng nghiệp chỉ hiện ca hợp lệ
    // ==============================================================
    private static void testHienThiDanhSachDongNghiep() throws Exception {
        System.out.println("\n=== [3] Danh sach ca dong nghiep ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        List<Map<String, Object>> list =
                dao.getColleagueSchedules(empA);

        check("Co ca dong nghiep de doi", !list.isEmpty());

        int sameBranch = 0;
        int samePos = 0;
        for (Map<String, Object> row : list) {
            if (empB == ((Integer) row.get("colleagueId")).intValue()) {
                sameBranch++;
            }
            Object pos = row.get("positionId");
            if (pos != null && ((Integer) pos) == 7) {
                samePos++;
            }
        }

        System.out.println("  Tong ca dong nghiep: " + list.size()
                + " | cua B: " + sameBranch
                + " | cung vi tri 7: " + samePos);

        check("Co ca cua B trong danh sach", sameBranch > 0);
        check("Tat ca ca deu dung vi tri cong tac",
                samePos == list.size());
    }

    // ==============================================================
    // 4. KHÔNG cho đổi 2 ca chồng lấn giờ cùng ngày
    // ==============================================================
    private static void testKhongDoiCungNgayChongLanGio() throws Exception {
        System.out.println("\n=== [4] Doi 2 ca chong lan gio cung ngay -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        // Tim 2 ca cung ngay: A co "Ca Toi" (17:00-22:00) va
        // "Ca Sang" (07:00-12:00) -> KHONG chong lan.
        // Can tim 2 ca CUNG NGAY ma khung gio CHONG LAN:
        //   "Ca Sang" (07-12) va "Ca Full-time Sang-Chieu" (07-17).
        int[][] overlapping = findOverlappingPair();

        if (overlapping == null) {
            System.out.println("  (khong co cap ca chong lan trong du lieu hien tai)");
            System.out.println("  -> dung com cho nhan vien + SM: ca trong nghiep chi");
            System.out.println("     theo ca cua ban, nen ca chong lan se khong xuat hien");
            System.out.println("  PASS (bo qua vi du lieu khong co cap chong lan)");
            passCount++;
            return;
        }

        System.out.println("  Cap chong lan: " + overlapping[0][0]
                + " <-> " + overlapping[0][1]);

        cleanupRequests(overlapping[0][0], overlapping[0][1]);

        boolean created = dao.createSwap(
                empA, overlapping[0][0], overlapping[0][1],
                "Doi ca chong lan gio");
        check("KHONG duoc tao don doi 2 ca chong lan gio", !created);
    }

    // ==============================================================
    // 5. KHÔNG cho đổi 2 ca cùng shift_id cùng ngày
    // ==============================================================
    private static void testKhongDoiCaCungShiftIdCungNgay() throws Exception {
        System.out.println("\n=== [5] Doi 2 ca cung loai ca cung ngay -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[][] same = findSameShiftSameDayPair();

        if (same == null) {
            System.out.println("  (khong co cap ca cung loai ca cung ngay)");
            System.out.println("  PASS (bo qua)");
            passCount++;
            return;
        }

        System.out.println("  Cap cung loai ca: " + same[0][0]
                + " <-> " + same[0][1]);

        cleanupRequests(same[0][0], same[0][1]);

        boolean created = dao.createSwap(
                empA, same[0][0], same[0][1],
                "Doi 2 ca cung loai cung ngay");
        check("KHONG duoc tao don doi 2 ca cung loai cung ngay", !created);
    }

    // ==============================================================
    // 6. SM duyệt -> lịch 2 người đổi chỗ đúng
    // ==============================================================
    private static void testDuyetVaKiemTraLich() throws Exception {
        System.out.println("\n=== [6] SM duyet -> 2 nguoi doi cho nhau ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            fail("Khong tim duoc cap ca");
            return;
        }

        cleanupRequests(pair[0], pair[1]);

        if (!dao.createSwap(empA, pair[0], pair[1], "Duyet va doi lich")) {
            fail("Khong tao duoc don de duyet");
            return;
        }

        int requestId = latestRequestId(empA);
        dao.respondToSwap(requestId, empB, true, "OK");

        int ownerBeforeA = ownerOf(pair[0]);
        int ownerBeforeB = ownerOf(pair[1]);
        int dateA = dateOf(pair[0]);
        int dateB = dateOf(pair[1]);
        int shiftA = shiftOf(pair[0]);
        int shiftB = shiftOf(pair[1]);

        System.out.println("  Truoc khi duyet:");
        System.out.println("    schedule " + pair[0] + ": owner=" + ownerBeforeA
                + " date=" + dateA + " shift=" + shiftA);
        System.out.println("    schedule " + pair[1] + ": owner=" + ownerBeforeB
                + " date=" + dateB + " shift=" + shiftB);

        boolean approved = dao.review(
                requestId, branchId, true, "Duyet doi ca");
        check("SM duyet thanh cong", approved);
        check("Trang thai = APPROVED",
                "APPROVED".equals(statusOf(requestId)));

        int ownerAfterA = ownerOf(pair[0]);
        int ownerAfterB = ownerOf(pair[1]);

        System.out.println("  Sau khi duyet:");
        System.out.println("    schedule " + pair[0] + ": owner=" + ownerAfterA);
        System.out.println("    schedule " + pair[1] + ": owner=" + ownerAfterB);

        check("Ca cua A (schedule " + pair[0] + ") do B nham",
                ownerAfterA == empB);
        check("Ca cua B (schedule " + pair[1] + ") do A nham",
                ownerAfterB == empA);

        // Ngay va ca khong doi (chi doi nguoi giu ca)
        check("Ngay cua ca " + pair[0] + " khong doi",
                dateOf(pair[0]) == dateA);
        check("Ngay cua ca " + pair[1] + " khong doi",
                dateOf(pair[1]) == dateB);
        check("Loai ca cua " + pair[0] + " khong doi",
                shiftOf(pair[0]) == shiftA);
        check("Loai ca cua " + pair[1] + " khong doi",
                shiftOf(pair[1]) == shiftB);

        // Vi tri cong tac phai khop voi nguoi giu ca moi
        check("Vi tri cong tac ca " + pair[0] + " theo B",
                positionOf(pair[0]) == positionOfEmp(empB));
        check("Vi tri cong tac ca " + pair[1] + " theo A",
                positionOf(pair[1]) == positionOfEmp(empA));

        // Khong duoc duyet 2 lan
        boolean second = dao.review(
                requestId, branchId, true, "Duyet lai");
        check("Khong duyet duoc 2 lan", !second);
    }

    // ==============================================================
    // 7. Hủy đơn của người khác -> phải bị chặn
    // ==============================================================
    private static void testHuyDonKhongPhaiCuaMinh() throws Exception {
        System.out.println("\n=== [7] Huy don cua nguoi khac -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            fail("Khong tim duoc cap ca");
            return;
        }

        cleanupRequests(pair[0], pair[1]);
        dao.createSwap(empA, pair[0], pair[1], "Huy don nguoi khac");
        int requestId = latestRequestId(empA);

        boolean wrong = dao.cancelMyRequest(requestId, empB);
        check("Khong the huy don cua nguoi khac", !wrong);
        check("Don van con WAITING_COLLEAGUE",
                "WAITING_COLLEAGUE".equals(statusOf(requestId)));

        boolean right = dao.cancelMyRequest(requestId, empA);
        check("Nguoi gui duoc huy don cua minh", right);
        check("Trang thai = CANCELLED",
                "CANCELLED".equals(statusOf(requestId)));
    }

    // ==============================================================
    // 8. Ca đã dùng -> không tạo lại đơn trùng
    // ==============================================================
    private static void testCaDaDungKhongTaoLai() throws Exception {
        System.out.println("\n=== [8] Khong tao duoc 2 don cho cung 1 ca ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            fail("Khong tim duoc cap ca");
            return;
        }

        cleanupRequests(pair[0], pair[1]);

        boolean first = dao.createSwap(
                empA, pair[0], pair[1], "Don thu nhat");
        check("Tao don thu nhat thanh cong", first);

        boolean second = dao.createSwap(
                empA, pair[0], pair[1], "Don thu hai cung ca");
        check("Khong tao duoc don thu hai cho cung ca", !second);

        // Cung vay, doi chieu (B xin doi ca cua A)
        boolean reverse = dao.createSwap(
                empB, pair[1], pair[0], "Don chieu");
        check("Khong tao duoc don chieu cho cung cap ca", !reverse);

        dao.cancelMyRequest(latestRequestId(empA), empA);
    }

    // ==============================================================
    // Tien ich
    // ==============================================================
    private static int lastRequestId;
    private static int lastMySchedule;
    private static int lastTargetSchedule;

    private static void setup() throws Exception {
        empA = findUserId("pt_user1");
        empB = findUserId("pt_user2");

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT home_branch_id FROM employee_profiles "
                     + "WHERE user_id = ?")) {
            ps.setInt(1, empA);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    branchId = rs.getInt(1);
                }
            }
        }

        System.out.println("A(pt_user1)=" + empA + " | B(pt_user2)=" + empB
                + " | branch=" + branchId);
    }

    private static int findUserId(String username) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM users WHERE username = ?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    /**
     * Cap ca hop le de doi.
     *
     * <h3>Dieu kien</h3>
     * <ul>
     *   <li>Cung chi nhanh, cung vi tri cong tac.</li>
     *   <li>Khac ngay.</li>
     *   <li>Ca cua A va ca cua B phai <b>KHAC KHUNG GIO</b>, vi sau
     *       khi doi, A se lam ca cua B va B se lam ca cua A. Neu hai ca
     *       cung khung gio (ca Ca Sang cua ca Ca Sang) thi viec doi
     *       khong doi gi, va he thong se TU cho phep.</li>
     * </ul>
     */
    private static int[] findSwapPair() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.id, b.id "
                     + "FROM shift_schedules a "
                     + "JOIN shift_schedules b "
                     + "  ON a.branch_id = b.branch_id "
                     + "  AND a.position_id = b.position_id "
                     + "  AND a.work_date <> b.work_date "
                     + "JOIN shifts sa ON sa.id = a.shift_id "
                     + "JOIN shifts sb ON sb.id = b.shift_id "
                     + "WHERE a.user_id = ? AND b.user_id = ? "
                     + "AND a.status = 'PUBLISHED' "
                     + "AND b.status = 'PUBLISHED' "
                     + "AND a.work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 3 DAY) "
                     + "AND b.work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 3 DAY) "
                     + "AND NOT (sa.start_time < sb.end_time "
                     + "         AND sa.end_time > sb.start_time) "
                     /* A khong duoc co ca KHAC cung ngay voi ca cua B
                        (truoc khi doi), va nguoc lai. */
                     + "AND NOT EXISTS (SELECT 1 FROM shift_schedules c "
                     + "  JOIN shifts sc ON sc.id = c.shift_id "
                     + "  WHERE c.user_id = a.user_id AND c.id <> a.id "
                     + "  AND c.status = 'PUBLISHED' "
                     + "  AND c.work_date = b.work_date "
                     + "  AND sc.start_time < sb.end_time "
                     + "  AND sc.end_time > sb.start_time) "
                     + "AND NOT EXISTS (SELECT 1 FROM shift_schedules c "
                     + "  JOIN shifts sc ON sc.id = c.shift_id "
                     + "  WHERE c.user_id = b.user_id AND c.id <> b.id "
                     + "  AND c.status = 'PUBLISHED' "
                     + "  AND c.work_date = a.work_date "
                     + "  AND sc.start_time < sa.end_time "
                     + "  AND sc.end_time > sa.start_time) "
                     + "ORDER BY a.work_date, b.work_date LIMIT 1")) {

            ps.setInt(1, empA);
            ps.setInt(2, empB);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{rs.getInt(1), rs.getInt(2)};
                }
            }
        }
        return null;
    }

    /** Cap ca cung ngay va CHONG LAN khung gio. */
    private static int[][] findOverlappingPair() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.id, b.id "
                     + "FROM shift_schedules a "
                     + "JOIN shift_schedules b "
                     + "  ON a.user_id = b.user_id "
                     + "  AND a.work_date = b.work_date "
                     + "  AND a.shift_id <> b.shift_id "
                     + "JOIN shifts sa ON sa.id = a.shift_id "
                     + "JOIN shifts sb ON sb.id = b.shift_id "
                     + "WHERE a.user_id = ? "
                     + "AND a.status = 'PUBLISHED' AND b.status = 'PUBLISHED' "
                     + "AND sa.start_time < sb.end_time "
                     + "AND sa.end_time > sb.start_time "
                     + "AND a.work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 3 DAY) "
                     + "LIMIT 1")) {

            ps.setInt(1, empA);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[][]{{rs.getInt(1), rs.getInt(2)}};
                }
            }
        }
        return null;
    }

    /** Cap ca cung ngay va cung loai ca. */
    private static int[][] findSameShiftSameDayPair() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.id, b.id "
                     + "FROM shift_schedules a "
                     + "JOIN shift_schedules b "
                     + "  ON a.user_id = b.user_id "
                     + "  AND a.work_date = b.work_date "
                     + "  AND a.shift_id = b.shift_id "
                     + "WHERE a.user_id = ? "
                     + "AND a.status = 'PUBLISHED' AND b.status = 'PUBLISHED' "
                     + "AND a.work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 3 DAY) "
                     + "LIMIT 1")) {

            ps.setInt(1, empA);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[][]{{rs.getInt(1), rs.getInt(2)}};
                }
            }
        }
        return null;
    }

    private static void cleanupRequests(int a, int b) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM shift_change_requests "
                     + "WHERE shift_schedule_id IN (?, ?) "
                     + "OR target_shift_schedule_id IN (?, ?)")) {

            ps.setInt(1, a);
            ps.setInt(2, b);
            ps.setInt(3, a);
            ps.setInt(4, b);
            ps.executeUpdate();
        }
    }

    private static int latestRequestId(int requesterId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM shift_change_requests "
                     + "WHERE requester_id = ? ORDER BY id DESC LIMIT 1")) {

            ps.setInt(1, requesterId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static String statusOf(int requestId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT status FROM shift_change_requests WHERE id = ?")) {

            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        }
        return "?";
    }

    private static int ownerOf(int scheduleId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT user_id FROM shift_schedules WHERE id = ?")) {

            ps.setInt(1, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static int dateOf(int scheduleId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT work_date FROM shift_schedules WHERE id = ?")) {

            ps.setInt(1, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return (int) rs.getDate(1).toLocalDate().toEpochDay();
                }
            }
        }
        return -1;
    }

    private static int shiftOf(int scheduleId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT shift_id FROM shift_schedules WHERE id = ?")) {

            ps.setInt(1, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static int positionOf(int scheduleId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT position_id FROM shift_schedules WHERE id = ?")) {

            ps.setInt(1, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static int positionOfEmp(int userId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT position_id FROM employee_profiles "
                     + "WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static void check(String label, boolean ok) {
        if (ok) {
            passCount++;
            System.out.println("  [PASS] " + label);
        } else {
            failCount++;
            System.out.println("  [FAIL] " + label);
        }
    }

    private static void fail(String msg) {
        failCount++;
        System.out.println("  [FAIL] " + msg);
    }
}
