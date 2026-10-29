package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Kiem chung cac lop bao ve bang du lieu THAT.
 *
 * Cac ca tam thoi duoc tao cho ca A va B, test xong duoc xoa sach.
 */
public class SwapOverlapGuardTest {

    private static int empA;
    private static int empB;
    private static int branchId;
    private static int posId;

    // 1 = Ca Sang 07-12 | 2 = Ca Chieu 12-17 | 3 = Ca Toi 17-22
    // 4 = Ca Full-time Sang-Chieu 07-17
    private static int shiftMorning = 1;
    private static int shiftAfternoon = 2;
    private static int shiftEvening = 3;
    private static int shiftFullDay = 4;

    private static int passCount;
    private static int failCount;

    public static void main(String[] args) throws Exception {
        empA = findUserId("pt_user1");
        empB = findUserId("pt_user2");
        posId = positionOfEmp(empA);
        branchId = branchOf(empA);

        System.out.println("A=" + empA + " B=" + empB
                + " branch=" + branchId + " pos=" + posId);

        test1_CapCaChongLanGioCungNgay();
        test2_CapCaCungLoaiCaCungNgay();
        test3_SwapTaoRaCaTrungChoA();
        test4_CapCaHopLeVanChayDuoc();

        System.out.println();
        System.out.println("========================================");
        System.out.println("  PASS: " + passCount + "   FAIL: " + failCount);
        System.out.println("========================================");

        if (failCount > 0) {
            System.exit(1);
        }
    }

    // ==============================================================
    // 1. A ca Sang (07-12) + B ca Full-time Sang-Chieu (07-17)
    //    cung ngay -> CHONG LAN GIO -> khong duoc tao don.
    // ==============================================================
    private static void test1_CapCaChongLanGioCungNgay() throws Exception {
        System.out.println("\n=== [1] Cap ca CHONG LAN GIO cung ngay -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        java.sql.Date date = futureDate(7);
        int tempA = insertTempSchedule(empA, shiftMorning, date);
        int tempB = insertTempSchedule(empB, shiftFullDay, date);

        System.out.println("  A: schedule=" + tempA + " ngay=" + date
                + " ca=07:00-12:00 (Ca Sang)");
        System.out.println("  B: schedule=" + tempB + " ngay=" + date
                + " ca=07:00-17:00 (Ca Full-time Sang-Chieu)");
        System.out.println("  -> 2 ca nay CHONG LAN khuong gio");

        try {
            cleanupRequests(tempA, tempB);

            boolean created = dao.createSwap(
                    empA, tempA, tempB,
                    "Doi 2 ca chong lan gio cung ngay");

            check("KHONG duoc tao don doi 2 ca chong lan gio cung ngay",
                    !created);
            check("Khong co ban ghi don nao duoc tao",
                    countRequests(tempA, tempB) == 0);
        } finally {
            deleteSchedule(tempA);
            deleteSchedule(tempB);
        }
    }

    // ==============================================================
    // 2. A ca Sang + B ca Sang cung ngay -> cung loai ca,
    //    cung khuong gio -> cung phai bi chan.
    // ==============================================================
    private static void test2_CapCaCungLoaiCaCungNgay() throws Exception {
        System.out.println("\n=== [2] Cap ca CUNG LOAI CA cung ngay -> bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        java.sql.Date date = futureDate(9);
        int tempA = insertTempSchedule(empA, shiftMorning, date);
        int tempB = insertTempSchedule(empB, shiftMorning, date);

        System.out.println("  A: schedule=" + tempA + " ca=07:00-12:00");
        System.out.println("  B: schedule=" + tempB + " ca=07:00-12:00");
        System.out.println("  -> cung ngay + cung loai ca");

        try {
            cleanupRequests(tempA, tempB);

            boolean created = dao.createSwap(
                    empA, tempA, tempB,
                    "Doi 2 ca cung loai cung ngay");

            check("KHONG duoc tao don doi 2 ca cung loai ca cung ngay",
                    !created);
        } finally {
            deleteSchedule(tempA);
            deleteSchedule(tempB);
        }
    }

    // ==============================================================
    // 3. A da co Ca Chieu (12-17) ngay X.
    //    A muon doi Ca Sang (07-12) cua B (cung ngay X) sang.
    //    Sau khi doi A se co 2 ca cung loai (Ca Chieu + Ca Sang)
    //    -> trung ca -> SM phai TU CHOI duyet va giu nguyen lich.
    // ==============================================================
    private static void test3_SwapTaoRaCaTrungChoA() throws Exception {
        System.out.println("\n=== [3] Swap tao ra ca TRUNG cho A -> SM duyet bi chan ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        java.sql.Date date = futureDate(11);
        int tempA1 = insertTempSchedule(empA, shiftAfternoon, date);
        int tempA2 = insertTempSchedule(empA, shiftMorning, date);
        int tempB = insertTempSchedule(empB, shiftAfternoon, date);

        System.out.println("  A: schedule=" + tempA1 + " ca=12:00-17:00 (Ca Chieu)");
        System.out.println("  A: schedule=" + tempA2 + " ca=07:00-12:00 (Ca Sang)");
        System.out.println("  B: schedule=" + tempB + " ca=12:00-17:00 (Ca Chieu)");
        System.out.println("  -> A doi Ca Sang cua B -> se co 2 ca cung loai cung ngay");

        try {
            cleanupRequests(tempA2, tempB);

            boolean created = dao.createSwap(
                    empA, tempA2, tempB, "Doi ca se bi trung");
            check("Tao don duoc (2 ca cua cap khong chong lan)", created);

            if (created) {
                int requestId = latestRequestId(empA);

                check("Dong nghiep tra loi duoc",
                        dao.respondToSwap(requestId, empB, true, "OK"));

                int ownerBeforeA2 = ownerOf(tempA2);
                int ownerBeforeB = ownerOf(tempB);

                boolean approved = dao.review(
                        requestId, branchId, true, "Duyet");

                check("SM duyet bi chan (tao ca trung cho A)", !approved);
                check("Don khong chuyen sang APPROVED",
                        !"APPROVED".equals(statusOf(requestId)));

                check("Lich A giu nguyen (rollback)",
                        ownerOf(tempA2) == ownerBeforeA2
                        && ownerOf(tempB) == ownerBeforeB);
            }
        } finally {
            deleteSchedule(tempA1);
            deleteSchedule(tempA2);
            deleteSchedule(tempB);
        }
    }

    // ==============================================================
    // 4. Cap ca hop le (khac ngay) van chay duoc binh thuong.
    // ==============================================================
    private static void test4_CapCaHopLeVanChayDuoc() throws Exception {
        System.out.println("\n=== [4] Cap ca hop le (khac ngay) van chay duoc ===");

        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        java.sql.Date dateA = futureDate(14);
        java.sql.Date dateB = futureDate(15);

        int tempA = insertTempSchedule(empA, shiftEvening, dateA);
        int tempB = insertTempSchedule(empB, shiftMorning, dateB);

        System.out.println("  A: schedule=" + tempA + " ngay=" + dateA
                + " ca=17:00-22:00");
        System.out.println("  B: schedule=" + tempB + " ngay=" + dateB
                + " ca=07:00-12:00");
        System.out.println("  -> khac ngay -> hop le");

        try {
            cleanupRequests(tempA, tempB);

            check("Tao don duoc", dao.createSwap(
                    empA, tempA, tempB, "Cap hop le"));

            int requestId = latestRequestId(empA);

            check("Trang thai = WAITING_COLLEAGUE",
                    "WAITING_COLLEAGUE".equals(statusOf(requestId)));

            check("Dong nghiep tra loi duoc",
                    dao.respondToSwap(requestId, empB, true, "OK"));

            check("Trang thai = PENDING",
                    "PENDING".equals(statusOf(requestId)));

            check("SM duyet duoc",
                    dao.review(requestId, branchId, true, "Duyet"));

            check("Trang thai = APPROVED",
                    "APPROVED".equals(statusOf(requestId)));

            check("A nham ca cua B", ownerOf(tempA) == empB);
            check("B nham ca cua A", ownerOf(tempB) == empA);
            check("Ngay va loai ca giu nguyen",
                    dateOf(tempA).equals(dateA)
                    && shiftOf(tempA) == shiftEvening
                    && dateOf(tempB).equals(dateB)
                    && shiftOf(tempB) == shiftMorning);
        } finally {
            deleteSchedule(tempA);
            deleteSchedule(tempB);
        }
    }

    // ==============================================================
    // Tien ich
    // ==============================================================
    private static java.sql.Date futureDate(int days) {
        return java.sql.Date.valueOf(
                java.time.LocalDate.now().plusDays(days));
    }

    private static int insertTempSchedule(
            int userId, int shiftId, java.sql.Date date) throws Exception {

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO shift_schedules "
                     + "(user_id, branch_id, shift_id, position_id, "
                     + " work_date, status) "
                     + "VALUES (?, ?, ?, ?, ?, 'PUBLISHED')")) {

            ps.setInt(1, userId);
            ps.setInt(2, branchId);
            ps.setInt(3, shiftId);
            ps.setInt(4, posId);
            ps.setDate(5, date);
            ps.executeUpdate();
        }

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT MAX(id) FROM shift_schedules "
                     + "WHERE user_id = ? AND work_date = ? "
                     + "AND shift_id = ?")) {

            ps.setInt(1, userId);
            ps.setDate(2, date);
            ps.setInt(3, shiftId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static void deleteSchedule(int id) throws Exception {
        if (id <= 0) {
            return;
        }

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM shift_change_requests "
                     + "WHERE shift_schedule_id = ? "
                     + "OR target_shift_schedule_id = ?")) {
            ps.setInt(1, id);
            ps.setInt(2, id);
            ps.executeUpdate();
        }

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM shift_schedules WHERE id = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private static java.sql.Date dateOf(int id) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT work_date FROM shift_schedules WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDate(1);
                }
            }
        }
        return null;
    }

    private static int shiftOf(int id) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT shift_id FROM shift_schedules WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static int ownerOf(int id) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT user_id FROM shift_schedules WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static int countRequests(int a, int b) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT COUNT(*) FROM shift_change_requests "
                     + "WHERE shift_schedule_id IN (?, ?) "
                     + "OR target_shift_schedule_id IN (?, ?)")) {
            ps.setInt(1, a);
            ps.setInt(2, b);
            ps.setInt(3, a);
            ps.setInt(4, b);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
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

    private static String statusOf(int id) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT status FROM shift_change_requests WHERE id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        }
        return "?";
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

    private static int branchOf(int userId) throws Exception {
        try (Connection c = DBContext.getConnection();
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
}
