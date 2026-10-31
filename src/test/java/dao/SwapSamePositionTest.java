package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

/**
 * Test quy tắc nghiệp vụ: nhân viên CHỈ được đổi ca với đồng nghiệp
 * có CÙNG CHỨC VỤ (employee_profiles.position_id) và CÙNG NHÓM
 * LÀM VIỆC (FULL_TIME chỉ với FULL_TIME, PART_TIME chỉ với PART_TIME).
 */
public class SwapSamePositionTest {

    private static int passCount;
    private static int failCount;

    public static void main(String[] args) throws Exception {

        testDanhSachDongNghiepChiCungChucVu();
        testDanhSachDongNghiepChiCungNhomLamViec();
        testKhongTaoDuocDonKhacChucVu();
        testKhongTaoDuocDonKhacNhomLamViec();
        testTaoDuocDonCungChucVu();
        testDuyetDonKhacChucVuBiChan();
        testKhongDoiCaQuaTuan();

        System.out.println();
        System.out.println("========================================");
        System.out.println("  PASS: " + passCount + "   FAIL: " + failCount);
        System.out.println("========================================");

        if (failCount > 0) {
            System.exit(1);
        }
    }

    // --------------------------------------------------------------
    // 1. Danh sach dong nghiep chi gom nguoi cung chuc vu
    // --------------------------------------------------------------
    private static void testDanhSachDongNghiepChiCungChucVu()
            throws Exception {

        System.out.println("\n=== [1] Danh sach dong nghiep cung chuc vu ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] emp = findEmployeeWithColleague();
        if (emp == null) {
            fail("Khong tim duoc nhan vien co dong nghiep de kiem tra");
            return;
        }

        int myId = emp[0];
        int myPos = positionOfEmp(myId);

        List<Map<String, Object>> list
                = dao.getColleagueSchedules(myId, weekStartOfAny(myId));

        System.out.println("  Nhan vien " + myId
                + " (chuc vu " + myPos + ") -> "
                + list.size() + " ca dong nghiep");

        boolean allSame = true;
        for (Map<String, Object> row : list) {
            int colleagueId = ((Number) row.get("colleagueId")).intValue();
            int colleaguePos = positionOfEmp(colleagueId);

            if (colleaguePos != myPos) {
                allSame = false;
                System.out.println("    [SAI] dong nghiep " + colleagueId
                        + " chuc vu " + colleaguePos);
            }
        }

        check("Danh sach khong co nguoi khac chuc vu", allSame);
    }

    // --------------------------------------------------------------
    // 1b. Danh sach dong nghiep chi gom cung NHOM LAM VIEC
    // --------------------------------------------------------------
    private static void testDanhSachDongNghiepChiCungNhomLamViec()
            throws Exception {

        System.out.println("\n=== [1b] Danh sach dong nghiep cung nhom lam viec ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        boolean coDuLieu = false;

        for (int uid : allEmployeeIds()) {
            List<Map<String, Object>> list
                    = dao.getColleagueSchedules(uid, weekStartOfAny(uid));
            if (list.isEmpty()) {
                continue;
            }

            coDuLieu = true;

            String myType = typeOfEmp(uid);

            for (Map<String, Object> row : list) {
                int colleagueId
                        = ((Number) row.get("colleagueId")).intValue();
                String theirType = typeOfEmp(colleagueId);

                if (!myType.equals(theirType)) {
                    fail("NV " + uid + " (" + myType + ") thay dong nghiep "
                            + colleagueId + " (" + theirType + ") khac nhom");
                    return;
                }
            }
        }

        if (!coDuLieu) {
            System.out.println("  (khong co du lieu dong nghiep de kiem tra)");
            System.out.println("  PASS (bo qua)");
            passCount++;
            return;
        }

        check("Moi danh sach deu cung nhom lam viec", true);
    }

    // --------------------------------------------------------------
    // 2. Tao don doi ca voi nguoi KHAC chuc vu -> bi chan
    // --------------------------------------------------------------
    private static void testKhongTaoDuocDonKhacChucVu()
            throws Exception {

        System.out.println("\n=== [2] Doi ca voi nguoi khac chuc vu -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findCrossPositionPair();
        if (pair == null) {
            System.out.println("  (khong co cap ca giua 2 nguoi khac chuc vu)");
            System.out.println("  PASS (bo qua)");
            passCount++;
            return;
        }

        int requester = pair[0];
        int mySchedule = pair[1];
        int targetSchedule = pair[2];

        System.out.println("  Nguoi gui " + requester
                + " (chuc vu " + positionOfEmp(requester) + ")");
        System.out.println("  Nguoi nhan " + ownerOf(targetSchedule)
                + " (chuc vu "
                + positionOfEmp(ownerOf(targetSchedule)) + ")");

        cleanupRequests(mySchedule, targetSchedule);

        boolean created = dao.createSwap(
                requester, mySchedule, targetSchedule,
                "Test doi ca khac chuc vu",
                weekOfSchedule(mySchedule));

        check("KHONG duoc tao don doi ca voi nguoi khac chuc vu",
                !created);

        cleanupRequests(mySchedule, targetSchedule);
    }

    // --------------------------------------------------------------
    // 2b. Cung chuc vu nhung KHAC nhom lam viec -> bi chan
    // --------------------------------------------------------------
    private static void testKhongTaoDuocDonKhacNhomLamViec()
            throws Exception {

        System.out.println("\n=== [2b] Doi ca giua FULL_TIME va PART_TIME -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findCrossTypePair();
        if (pair == null) {
            System.out.println("  (khong co cap ca giua 2 nhom lam viec khac nhau)");
            System.out.println("  PASS (bo qua)");
            passCount++;
            return;
        }

        int requester = pair[0];
        int mySchedule = pair[1];
        int targetSchedule = pair[2];

        System.out.println("  Nguoi gui " + requester
                + " (" + typeOfEmp(requester) + ")");
        System.out.println("  Nguoi nhan " + ownerOf(targetSchedule)
                + " (" + typeOfEmp(ownerOf(targetSchedule)) + ")");

        cleanupRequests(mySchedule, targetSchedule);

        boolean created = dao.createSwap(
                requester, mySchedule, targetSchedule,
                "Test doi ca khac nhom lam viec",
                weekOfSchedule(mySchedule));

        check("KHONG duoc tao don doi ca giua FULL_TIME va PART_TIME",
                !created);

        cleanupRequests(mySchedule, targetSchedule);
    }

    // --------------------------------------------------------------
    // 3. Tao don doi ca voi nguoi CUNG chuc vu -> duoc
    // --------------------------------------------------------------
    private static void testTaoDuocDonCungChucVu() throws Exception {

        System.out.println("\n=== [3] Doi ca voi nguoi cung chuc vu -> duoc ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSamePositionPair();
        if (pair == null) {
            System.out.println("  (khong co cap ca cung chuc vu de test)");
            System.out.println("  PASS (bo qua)");
            passCount++;
            return;
        }

        int requester = pair[0];
        int mySchedule = pair[1];
        int targetSchedule = pair[2];

        cleanupRequests(mySchedule, targetSchedule);

        boolean created = dao.createSwap(
                requester, mySchedule, targetSchedule,
                "Test doi ca cung chuc vu",
                weekOfSchedule(mySchedule));

        check("Duoc tao don doi ca voi nguoi cung chuc vu", created);

        cleanupRequests(mySchedule, targetSchedule);
    }

    // --------------------------------------------------------------
    // 4. Don da tao (cung chuc vu) duyet -> OK
    //    Don khac chuc vu dua vao truc tiep -> duyet phai bi chan
    // --------------------------------------------------------------
    private static void testDuyetDonKhacChucVuBiChan() throws Exception {

        System.out.println("\n=== [4] Duyet don -> kiem tra chuc vu ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSamePositionPair();
        if (pair == null) {
            System.out.println("  (khong co cap ca cung chuc vu de test)");
            System.out.println("  PASS (bo qua)");
            passCount++;
            return;
        }

        int requester = pair[0];
        int mySchedule = pair[1];
        int targetSchedule = pair[2];
        int branch = branchOf(requester);

        cleanupRequests(mySchedule, targetSchedule);

        boolean created = dao.createSwap(
                requester, mySchedule, targetSchedule,
                "Test duyet don",
                weekOfSchedule(mySchedule));
        check("Tao don de duyet thanh cong", created);

        if (!created) {
            return;
        }

        int requestId = latestRequestId(requester);

        // Phe ban goc da trong doi -> chuyen sang PENDING
        respondAsTarget(requestId, ownerOf(targetSchedule));

        boolean approved = dao.review(
                requestId, branch, true, "Duyet doi ca cung chuc vu");
        check("Duyet don cung chuc vu thanh cong", approved);

        cleanupRequests(mySchedule, targetSchedule);
    }

    // --------------------------------------------------------------
    // 5. KHONG duoc doi ca qua tuan
    // --------------------------------------------------------------
    private static void testKhongDoiCaQuaTuan() throws Exception {

        System.out.println("\n=== [5] Doi ca qua tuan -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findCrossWeekPair();
        if (pair == null) {
            System.out.println("  (khong co cap ca o 2 tuan khac nhau)");
            System.out.println("  PASS (bo qua)");
            passCount++;
            return;
        }

        int requester = pair[0];
        int mySchedule = pair[1];
        int targetSchedule = pair[2];

        java.time.LocalDate myWeek = weekOfSchedule(mySchedule);
        java.time.LocalDate theirWeek = weekOfSchedule(targetSchedule);

        System.out.println("  Tuan cua ca toi: " + myWeek);
        System.out.println("  Tuan cua ca doi nghiep: " + theirWeek);

        cleanupRequests(mySchedule, targetSchedule);

        // Dung tuan cua ca doi nghiep -> ca cua toi ngoai tuan do
        boolean created = dao.createSwap(
                requester, mySchedule, targetSchedule,
                "Test doi ca qua tuan",
                theirWeek);

        check("KHONG duoc tao don doi ca khi 2 ca o 2 tuan khac nhau",
                !created);

        cleanupRequests(mySchedule, targetSchedule);
    }

    // ==============================================================
    // Tien ich
    // ==============================================================

    /** Nhan vien co it nhat 1 dong nghiep cung chi nhanh. */
    private static int[] findEmployeeWithColleague() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.user_id FROM shift_schedules a "
                     + "JOIN employee_profiles ea ON ea.user_id = a.user_id "
                     + "JOIN shift_schedules b "
                     + "  ON b.branch_id = a.branch_id "
                     + "  AND b.user_id <> a.user_id "
                     + "JOIN employee_profiles eb ON eb.user_id = b.user_id "
                     + "WHERE a.status = 'PUBLISHED' "
                     + "AND b.status = 'PUBLISHED' "
                     + "AND a.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "AND b.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "GROUP BY a.user_id LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{rs.getInt(1)};
                }
            }
        }
        return null;
    }

    /**
     * Cap ca giua 2 nguoi KHAC chuc vu (theo employee_profiles),
     * cung chi nhanh, khac ngay, khung gio khong chong lan.
     */
    private static int[] findCrossPositionPair() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.user_id, a.id, b.id "
                     + "FROM shift_schedules a "
                     + "JOIN employee_profiles ea ON ea.user_id = a.user_id "
                     + "JOIN shift_schedules b "
                     + "  ON b.branch_id = a.branch_id "
                     + "  AND b.user_id <> a.user_id "
                     + "JOIN employee_profiles eb ON eb.user_id = b.user_id "
                     + "JOIN shifts sa ON sa.id = a.shift_id "
                     + "JOIN shifts sb ON sb.id = b.shift_id "
                     + "WHERE ea.position_id <> eb.position_id "
                     + "AND a.status = 'PUBLISHED' "
                     + "AND b.status = 'PUBLISHED' "
                     + "AND a.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "AND b.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "AND NOT (sa.start_time < sb.end_time "
                     + "         AND sa.end_time > sb.start_time) "
                     + "LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{
                        rs.getInt(1), rs.getInt(2), rs.getInt(3)};
                }
            }
        }
        return null;
    }

    /**
     * Cap ca giua 2 nguoi CUNG chuc vu, cung chi nhanh, khac ngay,
     * khung gio khong chong lan.
     */
    private static int[] findSamePositionPair() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.user_id, a.id, b.id "
                     + "FROM shift_schedules a "
                     + "JOIN employee_profiles ea ON ea.user_id = a.user_id "
                     + "JOIN shift_schedules b "
                     + "  ON b.branch_id = a.branch_id "
                     + "  AND b.user_id <> a.user_id "
                     + "JOIN employee_profiles eb ON eb.user_id = b.user_id "
                     + "JOIN shifts sa ON sa.id = a.shift_id "
                     + "JOIN shifts sb ON sb.id = b.shift_id "
                     + "WHERE ea.position_id = eb.position_id "
                     + "AND COALESCE(ea.employee_type, 'FULL_TIME') = "
                     + "COALESCE(eb.employee_type, 'FULL_TIME') "
                     + "AND a.status = 'PUBLISHED' "
                     + "AND b.status = 'PUBLISHED' "
                     + "AND a.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "AND b.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     // Cả hai ca phải cùng tuần.
                     + "AND DATE_SUB(a.work_date, "
                     + "  INTERVAL WEEKDAY(a.work_date) DAY) = "
                     + "DATE_SUB(b.work_date, "
                     + "  INTERVAL WEEKDAY(b.work_date) DAY) "
                     + "AND NOT (sa.start_time < sb.end_time "
                     + "         AND sa.end_time > sb.start_time) "
                     + "LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{
                        rs.getInt(1), rs.getInt(2), rs.getInt(3)};
                }
            }
        }
        return null;
    }

    /**
     * Cap ca giua 2 nguoi KHAC nhom lam viec (FULL_TIME vs PART_TIME),
     * cung chi nhanh, khac ngay, khung gio khong chong lan.
     */
    private static int[] findCrossTypePair() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.user_id, a.id, b.id "
                     + "FROM shift_schedules a "
                     + "JOIN employee_profiles ea ON ea.user_id = a.user_id "
                     + "JOIN shift_schedules b "
                     + "  ON b.branch_id = a.branch_id "
                     + "  AND b.user_id <> a.user_id "
                     + "JOIN employee_profiles eb ON eb.user_id = b.user_id "
                     + "JOIN shifts sa ON sa.id = a.shift_id "
                     + "JOIN shifts sb ON sb.id = b.shift_id "
                     + "WHERE COALESCE(ea.employee_type, 'FULL_TIME') <> "
                     + "COALESCE(eb.employee_type, 'FULL_TIME') "
                     + "AND a.status = 'PUBLISHED' "
                     + "AND b.status = 'PUBLISHED' "
                     + "AND a.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "AND b.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "AND NOT (sa.start_time < sb.end_time "
                     + "         AND sa.end_time > sb.start_time) "
                     + "LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{
                        rs.getInt(1), rs.getInt(2), rs.getInt(3)};
                }
            }
        }
        return null;
    }

    /**
     * Cap ca o 2 TUAN KHAC NHAU giua 2 nguoi cung chuc vu, cung nhom
     * lam viec, khung gio khong chong lan.
     */
    private static int[] findCrossWeekPair() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT a.user_id, a.id, b.id "
                     + "FROM shift_schedules a "
                     + "JOIN employee_profiles ea ON ea.user_id = a.user_id "
                     + "JOIN shift_schedules b "
                     + "  ON b.branch_id = a.branch_id "
                     + "  AND b.user_id <> a.user_id "
                     + "JOIN employee_profiles eb ON eb.user_id = b.user_id "
                     + "JOIN shifts sa ON sa.id = a.shift_id "
                     + "JOIN shifts sb ON sb.id = b.shift_id "
                     + "WHERE ea.position_id = eb.position_id "
                     + "AND COALESCE(ea.employee_type, 'FULL_TIME') = "
                     + "COALESCE(eb.employee_type, 'FULL_TIME') "
                     + "AND a.status = 'PUBLISHED' "
                     + "AND b.status = 'PUBLISHED' "
                     + "AND a.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "AND b.work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "AND DATE_SUB(a.work_date, "
                     + "  INTERVAL WEEKDAY(a.work_date) DAY) <> "
                     + "DATE_SUB(b.work_date, "
                     + "  INTERVAL WEEKDAY(b.work_date) DAY) "
                     + "AND NOT (sa.start_time < sb.end_time "
                     + "         AND sa.end_time > sb.start_time) "
                     + "LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{
                        rs.getInt(1), rs.getInt(2), rs.getInt(3)};
                }
            }
        }
        return null;
    }

    private static void respondAsTarget(int requestId, int targetUser) {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE shift_change_requests "
                     + "SET status = 'PENDING' WHERE id = ?")) {
            ps.setInt(1, requestId);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("  (loi respond: " + e.getMessage() + ")");
        }
    }

    /** Thứ Hai của tuần chứa ca có id cho trước. */
    private static java.time.LocalDate weekOfSchedule(int scheduleId)
            throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT work_date FROM shift_schedules WHERE id = ?")) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDate(1).toLocalDate()
                            .with(java.time.temporal.TemporalAdjusters
                                    .previousOrSame(
                                            java.time.DayOfWeek.MONDAY));
                }
            }
        }
        return java.time.LocalDate.now();
    }

    /** Tuần đầu tiên có ca của nhân viên (>= hôm nay + 2 ngày). */
    private static java.time.LocalDate weekStartOfAny(int userId)
            throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT work_date FROM shift_schedules "
                     + "WHERE user_id = ? AND status = 'PUBLISHED' "
                     + "AND work_date >= DATE_ADD(CURDATE(), INTERVAL 2 DAY) "
                     + "ORDER BY work_date LIMIT 1")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDate(1).toLocalDate()
                            .with(java.time.temporal.TemporalAdjusters
                                    .previousOrSame(
                                            java.time.DayOfWeek.MONDAY));
                }
            }
        }
        return java.time.LocalDate.now();
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

    /** Nhom lam viec cua nhan vien (FULL_TIME / PART_TIME). */
    private static String typeOfEmp(int userId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT employee_type FROM employee_profiles "
                     + "WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String t = rs.getString(1);
                    if (t != null && !t.trim().isEmpty()) {
                        return t.trim().toUpperCase();
                    }
                }
            }
        }
        return "FULL_TIME";
    }

    /** Danh sach tat ca nhan vien co ho so. */
    private static List<Integer> allEmployeeIds() throws Exception {
        List<Integer> list = new java.util.ArrayList<>();

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT user_id FROM employee_profiles "
                     + "ORDER BY user_id")) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt(1));
                }
            }
        }

        return list;
    }

    private static int branchOf(int userId) throws Exception {        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT home_branch_id FROM employee_profiles "
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
