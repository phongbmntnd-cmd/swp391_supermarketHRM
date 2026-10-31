package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

/**
 * Kiểm chứng quy tắc: Store chỉ được xếp nhân viên ĐÃ ĐĂNG KÝ LỊCH RẢNH
 * cho đúng ca + đúng ngày của tuần đang xem.
 *
 * <p>Test dùng DB thật, tự tạo dữ liệu tạm rồi xoá sạch.
 */
public class ScheduleAvailabilityRuleTest {

    private static int passCount;
    private static int failCount;

    public static void main(String[] args) throws Exception {
        // Tuần test: chọn tuần có Thứ Hai = 2026-11-02
        String weekStart = "2026-11-02";
        String monday = "2026-11-02";
        String tuesday = "2026-11-03";

        int branchId = findBranchId();
        int posId = findPositionId();
        int shiftId = findShiftId("Ca Tối");
        int ptUser = findPartTimeUser(branchId, posId);

        System.out.println("branch=" + branchId + " pos=" + posId
                + " shift(Ca Toi)=" + shiftId + " ptUser=" + ptUser);

        if (branchId <= 0 || posId <= 0 || shiftId <= 0) {
            System.out.println("!! Khong tim thay du lieu de test");
            System.exit(2);
        }
        if (ptUser <= 0) {
            // Khong tim duoc PT dung branch/pos -> dung bat ky PT/Casual nao
            ptUser = findAnyPartTimeUser();
            posId = positionOf(ptUser);
            branchId = branchOf(ptUser);
            System.out.println("-> fallback: ptUser=" + ptUser
                    + " branch=" + branchId + " pos=" + posId);
            if (ptUser <= 0) {
                System.out.println("!! Khong co nhan vien Part-time/Casual nao trong DB");
                System.exit(2);
            }
        }

        test1_DangKyRanh_DuocXep(branchId, posId, shiftId, ptUser, weekStart, monday);
        test2_KhongDangKy_DuocChan(branchId, posId, shiftId, ptUser, weekStart, tuesday);
        test3_LocDungTuan(branchId, posId, shiftId, ptUser, weekStart, monday);
        test4_SoNguoiDangKy(branchId, posId, shiftId, ptUser, weekStart, monday);

        System.out.println();
        System.out.println("========================================");
        System.out.println("  PASS: " + passCount + "   FAIL: " + failCount);
        System.out.println("========================================");
        if (failCount > 0) {
            System.exit(1);
        }
    }

    // Nhan vien DA dang ky ranh ca Toi o thu Hai -> duoc phep xep
    private static void test1_DangKyRanh_DuocXep(int branchId, int posId, int shiftId,
                                                int userId, String weekStart, String workDate) throws Exception {
        System.out.println("\n=== [1] Da dang ky ranh ca do -> DUOC xep ===");
        insertAvailability(userId, weekStart, "MONDAY", shiftId);
        boolean ok = new ShiftScheduleDAO()
                .hasRegisteredAvailability(branchId, userId, posId, shiftId, workDate);
        check("Da dang ky ranh -> hasRegisteredAvailability = true", ok);
        deleteAvailability(userId, weekStart);
    }

    // Nhan vien KHONG dang ky o thu Ba -> bi chan
    private static void test2_KhongDangKy_DuocChan(int branchId, int posId, int shiftId,
                                                 int userId, String weekStart, String workDate) throws Exception {
        System.out.println("\n=== [2] Khong dang ky ranh ca do -> BI CHAN ===");
        boolean ok = !new ShiftScheduleDAO()
                .hasRegisteredAvailability(branchId, userId, posId, shiftId, workDate);
        check("Khong dang ky -> hasRegisteredAvailability = false", ok);
    }

    // Dang ky o Tuan A thi khong duoc xep o Tuan B
    private static void test3_LocDungTuan(int branchId, int posId, int shiftId,
                                         int userId, String weekStart, String workDate) throws Exception {
        System.out.println("\n=== [3] Dang ky o tuan khac -> BI CHAN ===");
        String otherWeek = "2026-11-09";
        insertAvailability(userId, otherWeek, "MONDAY", shiftId);
        boolean ok = !new ShiftScheduleDAO()
                .hasRegisteredAvailability(branchId, userId, posId, shiftId, workDate);
        check("Dang ky o tuan khac -> hasRegisteredAvailability = false", ok);
        deleteAvailability(userId, otherWeek);
    }

    // So dem nguoi dang ky dung theo (ngay, ca, vi tri)
    private static void test4_SoNguoiDangKy(int branchId, int posId, int shiftId,
                                           int userId, String weekStart, String workDate) throws Exception {
        System.out.println("\n=== [4] Dem so nguoi dang ky theo tuan ===");
        insertAvailability(userId, weekStart, "MONDAY", shiftId);

        Map<String, Integer> counts = new EmployeeAvailabilityDAO()
                .getRegistrationCountMap(branchId, weekStart);
        Integer cnt = counts.get("MONDAY_" + shiftId + "_" + posId);

        check("Dem dung so nguoi dang ky = 1 (thuc te: " + cnt + ")",
                cnt != null && cnt == 1);

        // Kiem tra danh sach chi lay dung tuan
        List<Map<String, Object>> regs = new EmployeeAvailabilityDAO()
                .getRegistrationsByBranchId(branchId, weekStart);
        boolean found = false;
        for (Map<String, Object> r : regs) {
            if (((Integer) r.get("userId")) == userId
                    && "MONDAY".equals(r.get("dayOfWeek"))
                    && ((Integer) r.get("shiftId")) == shiftId) {
                found = true;
            }
        }
        check("Danh sach dang ky co dung nhan vien/ngay/ca", found);

        // Tuan khac phai rong
        List<Map<String, Object>> other = new EmployeeAvailabilityDAO()
                .getRegistrationsByBranchId(branchId, "2026-11-09");
        boolean leak = false;
        for (Map<String, Object> r : other) {
            if (((Integer) r.get("userId")) == userId) {
                leak = true;
            }
        }
        check("Khong ro ri dinh sang tuan khac", !leak);

        deleteAvailability(userId, weekStart);
    }

    // ==============================================================
    // Helper
    // ==============================================================
    private static void check(String label, boolean condition) {
        if (condition) {
            passCount++;
            System.out.println("  [PASS] " + label);
        } else {
            failCount++;
            System.out.println("  [FAIL] " + label);
        }
    }

    private static void insertAvailability(int userId, String weekStart,
                                           String dayOfWeek, int shiftId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "INSERT INTO employee_availabilities (user_id, week_start_date, day_of_week, shift_id) VALUES (?,?,?,?)")) {
            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(weekStart));
            ps.setString(3, dayOfWeek);
            ps.setInt(4, shiftId);
            ps.executeUpdate();
        }
    }

    private static void deleteAvailability(int userId, String weekStart) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM employee_availabilities WHERE user_id = ? AND week_start_date = ?")) {
            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(weekStart));
            ps.executeUpdate();
        }
    }

    private static int findBranchId() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM branches ORDER BY id LIMIT 1");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : -1;
        }
    }

    private static int findPositionId() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM positions WHERE title NOT LIKE '%Quản Lý%' "
                             + "AND title NOT LIKE '%Giám Đốc%' AND title NOT LIKE '%Trị Hệ Thống%' ORDER BY id LIMIT 1");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : -1;
        }
    }

    private static int findShiftId(String nameLike) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM shifts WHERE name LIKE ? ORDER BY id LIMIT 1")) {
            ps.setString(1, "%" + nameLike + "%");
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    private static int findPartTimeUser(int branchId, int posId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT ep.user_id FROM employee_profiles ep JOIN users u ON u.id = ep.user_id "
                             + "WHERE ep.home_branch_id = ? AND ep.position_id = ? "
                             + "AND ep.employee_type IN ('PART_TIME','CASUAL') AND u.status = 'ACTIVE' LIMIT 1")) {
            ps.setInt(1, branchId);
            ps.setInt(2, posId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    private static int findAnyPartTimeUser() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT ep.user_id FROM employee_profiles ep JOIN users u ON u.id = ep.user_id "
                             + "WHERE ep.employee_type IN ('PART_TIME','CASUAL') AND u.status = 'ACTIVE' LIMIT 1");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : -1;
        }
    }

    private static int positionOf(int userId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT position_id FROM employee_profiles WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    private static int branchOf(int userId) throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT home_branch_id FROM employee_profiles WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }
}
