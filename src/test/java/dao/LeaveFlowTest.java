//package dao;
//
//import context.DBContext;
//import model.LeaveRequestShift;
//import model.LeaveShiftSelection;
//import model.User;
//import service.LeaveHoursCalculator;
//
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
//import java.time.LocalDate;
//import java.util.ArrayList;
//import java.util.List;
//import java.util.Map;
//
///**
// * Test tích hợp cho mô hình nghỉ phép "C trên nền B".
// *
// * Chạy: mvn -o test -Dtest=LeaveFlowTest
// *
// * Các test dùng tài khoản & lịch mẫu trong
// * Database/seed_leave_demo_data.sql
// */
//public class LeaveFlowTest {
//
//    private static final int FULL_TIME_USER = 5;
//    private static int pt1UserId;
//    private static int pt2UserId;
//
//    public static void main(String[] args) throws Exception {
//        setup();
//
//        testFullTimeCalculateFromSchedule();
//        testPartTimeCalculateFromSelections();
//        testPartTimeOneShiftIsFiveHours();
//        testCreateAndReviewRequest();
//        testQuotaCheckConsistency();
//        testLeaveTimeSummary();
//        testBranchLeaveSummary();
//        testShiftDefinitions();
//
//        System.out.println("\n=== TẤT CẢ TEST ĐÃ CHẠY XONG ===");
//    }
//
//    private static void setup() throws Exception {
//        try (Connection c = DBContext.getConnection();
//             PreparedStatement ps = c.prepareStatement(
//                     "SELECT id FROM users WHERE username = 'pt_user1'");
//             ResultSet rs = ps.executeQuery()) {
//            if (rs.next()) {
//                pt1UserId = rs.getInt("id");
//            }
//        }
//        try (Connection c = DBContext.getConnection();
//             PreparedStatement ps = c.prepareStatement(
//                     "SELECT id FROM users WHERE username = 'pt_user2'");
//             ResultSet rs = ps.executeQuery()) {
//            if (rs.next()) {
//                pt2UserId = rs.getInt("id");
//            }
//        }
//        System.out.println("pt1=" + pt1UserId + " pt2=" + pt2UserId);
//    }
//
//    // ---------------------------------------------------------------
//    // TEST 1: Full-time nghỉ 2 ngày = 20 giờ (2 ca x 10h)
//    // ---------------------------------------------------------------
//    private static void testFullTimeCalculateFromSchedule() {
//        System.out.println("\n--- TEST 1: Full-time tính giờ theo ca thực tế ---");
//
//        LeaveHoursCalculator calc = new LeaveHoursCalculator();
//
//        // Tìm 2 ngày đầu có ca full-time trong lịch
//        LocalDate mon = LocalDate.now()
//                .with(java.time.temporal.TemporalAdjusters
//                        .previousOrSame(java.time.DayOfWeek.MONDAY));
//
//        LeaveHoursCalculator.Result r = calc.calculateFromSchedule(
//                FULL_TIME_USER, mon, mon.plusDays(1), 10.0);
//
//        System.out.println("  Tổng giờ = " + r.totalHours
//                + " | số ca = " + r.shiftDetails.size()
//                + " | fallback = " + r.usedFallback);
//
//        assertTrue(r.usedFallback == false,
//                "Full-time có lịch thì KHÔNG được dùng fallback");
//        assertTrue(r.totalHours == 20.0,
//                "Full-time nghỉ 2 ngày ca 10h phải = 20 giờ (thực tế: "
//                        + r.totalHours + ")");
//        assertTrue(r.shiftDetails.size() == 2,
//                "Phải có 2 chi tiết ca");
//    }
//
//    // ---------------------------------------------------------------
//    // TEST 2: Part-time nghỉ 2 ca = 10 giờ
//    // ---------------------------------------------------------------
//    private static void testPartTimeCalculateFromSelections() {
//        System.out.println("\n--- TEST 2: Part-time tính giờ theo ca được tick ---");
//
//        LeaveHoursCalculator calc = new LeaveHoursCalculator();
//
//        // Lấy 2 ca đầu của pt1
//        List<Map<String, Object>> shifts = calc.getScheduledShifts(
//                pt1UserId,
//                LocalDate.now().with(java.time.temporal.TemporalAdjusters
//                        .previousOrSame(java.time.DayOfWeek.MONDAY)),
//                LocalDate.now().plusDays(7));
//
//        List<LeaveShiftSelection> selections = new ArrayList<>();
//        int count = 0;
//        for (Map<String, Object> row : shifts) {
//            if (count >= 2) {
//                break;
//            }
//            java.sql.Date d = (java.sql.Date) row.get("workDate");
//            selections.add(new LeaveShiftSelection(
//                    d.toLocalDate(), (Integer) row.get("shiftId")));
//            count++;
//        }
//
//        LeaveHoursCalculator.Result r = calc.calculateFromSelections(
//                selections, calc.getAllShifts());
//
//        System.out.println("  Tổng giờ = " + r.totalHours
//                + " | số ca = " + r.shiftDetails.size());
//
//        assertTrue(r.shiftDetails.size() == 2, "Phải có 2 ca");
//        assertTrue(r.totalHours == 10.0,
//                "Part-time nghỉ 2 ca 5h phải = 10 giờ (thực tế: "
//                        + r.totalHours + ")");
//    }
//
//    // ---------------------------------------------------------------
//    // TEST 3: Part-time nghỉ 1 ca Tối = 5 giờ (KHÔNG phải 8 hay 10)
//    // ---------------------------------------------------------------
//    private static void testPartTimeOneShiftIsFiveHours() {
//        System.out.println("\n--- TEST 3: 1 ca Tối = 5 giờ ---");
//
//        LeaveHoursCalculator calc = new LeaveHoursCalculator();
//
//        List<LeaveShiftSelection> sels = new ArrayList<>();
//        sels.add(new LeaveShiftSelection(LocalDate.now().plusDays(1), 3));
//
//        LeaveHoursCalculator.Result r = calc.calculateFromSelections(
//                sels, calc.getAllShifts());
//
//        System.out.println("  Tổng giờ = " + r.totalHours);
//
//        assertTrue(r.totalHours == 5.0,
//                "Ca Tối (17:00-22:00) phải = 5 giờ (thực tế: "
//                        + r.totalHours + ")");
//    }
//
//    // ---------------------------------------------------------------
//    // TEST 4: Tạo đơn part-time -> duyệt -> ca thành ON_LEAVE + open_shifts
//    // ---------------------------------------------------------------
//    private static void testCreateAndReviewRequest() throws Exception {
//        System.out.println("\n--- TEST 4: Tạo & duyệt đơn part-time ---");
//
//        LeaveHoursCalculator calc = new LeaveHoursCalculator();
//
//        List<Map<String, Object>> shifts = calc.getScheduledShifts(
//                pt1UserId,
//                LocalDate.now().with(java.time.temporal.TemporalAdjusters
//                        .previousOrSame(java.time.DayOfWeek.MONDAY)),
//                LocalDate.now().plusDays(7));
//
//        if (shifts.isEmpty()) {
//            System.out.println("  BỎ QUA: chưa có lịch cho pt1");
//            return;
//        }
//
//        Map<String, Object> first = shifts.get(0);
//        java.sql.Date workDate = (java.sql.Date) first.get("workDate");
//        int shiftId = (Integer) first.get("shiftId");
//        double hours = (Double) first.get("hours");
//
//        List<LeaveShiftSelection> sels = new ArrayList<>();
//        sels.add(new LeaveShiftSelection(workDate.toLocalDate(), shiftId));
//
//        LeaveHoursCalculator.Result r = calc.calculateFromSelections(
//                sels, calc.getAllShifts());
//
//        LeaveRequestDAO dao = new LeaveRequestDAO();
//
//        int requestId = dao.createRequest(
//                pt1UserId,
//                1,                      // ANNUAL
//                workDate.toLocalDate(),
//                workDate.toLocalDate(),
//                1,
//                r.totalHours,
//                "Test đơn nghỉ phép part-time",
//                r.shiftDetails);
//
//        System.out.println("  Đơn tạo với id = " + requestId);
//
//        assertTrue(requestId > 0, "Tạo đơn phải thành công");
//
//        // Kiểm tra chi tiết ca đã lưu
//        List<LeaveRequestShift> details = dao.getShiftDetails(requestId);
//        System.out.println("  Chi tiết ca đã lưu: " + details.size());
//        assertTrue(details.size() == 1, "Phải lưu 1 chi tiết ca");
//
//        // Duyệt
//        boolean ok = dao.review(requestId, 1, true,
//                "Duyệt test", FULL_TIME_USER);
//        System.out.println("  Duyệt đơn: " + ok);
//        assertTrue(ok, "Duyệt đơn phải thành công");
//
//        // Ca phải chuyển sang ON_LEAVE
//        String scheduleStatus = queryOne(
//                "SELECT status FROM shift_schedules "
//                + "WHERE user_id = ? AND shift_id = ? AND work_date = ?",
//                pt1UserId, shiftId, workDate);
//        System.out.println("  Trạng thái ca sau duyệt: " + scheduleStatus);
//        assertTrue("ON_LEAVE".equals(scheduleStatus),
//                "Ca phải chuyển sang ON_LEAVE");
//
//        // Ca trống phải được tạo
//        int openCount = queryInt(
//                "SELECT COUNT(*) FROM open_shifts "
//                + "WHERE shift_id = ? AND work_date = ? AND status = 'OPEN'",
//                shiftId, workDate);
//        System.out.println("  Số ca trống được tạo: " + openCount);
//        assertTrue(openCount >= 1, "Phải tạo ít nhất 1 ca trống");
//
//        // Quota phải bị trừ theo giờ
//        double used = new LeaveBalanceDAO()
//                .getTotalHours(pt1UserId, 1, LocalDate.now().getYear());
//        System.out.println("  Tổng quota (giờ) của pt1: " + used);
//        assertTrue(used == 60.0,
//                "Quota part-time nghỉ phép năm phải = 12 ca x 5h = 60 giờ");
//
//        // Dọn dẹp: hủy đơn test + trả lại ca
//        cleanup(requestId, pt1UserId, shiftId, workDate);
//    }
//
//    // ---------------------------------------------------------------
//    // TEST 5: Tính nhất quán giữa lúc tạo đơn và lúc duyệt
//    // ---------------------------------------------------------------
//    private static void testQuotaCheckConsistency() {
//        System.out.println("\n--- TEST 5: Nhất quán quota tạo đơn vs duyệt ---");
//
//        LeaveBalanceDAO bal = new LeaveBalanceDAO();
//        int year = LocalDate.now().getYear();
//
//        double total = bal.getTotalHours(FULL_TIME_USER, 1, year);
//        double used = bal.getUsedHours(FULL_TIME_USER, 1, year);
//
//        System.out.println("  Full-time: total=" + total + " used=" + used);
//
//        assertTrue(total == 120.0,
//                "Quota full-time nghỉ phép năm phải = 12 ngày x 10h = 120 giờ");
//
//        // getUsedHours phải >= used_hours trong balance
//        double rawUsed = queryDouble(
//                "SELECT used_hours FROM leave_balances "
//                + "WHERE user_id = ? AND leave_type_id = ? AND year = ?",
//                FULL_TIME_USER, 1, year);
//        assertTrue(used >= rawUsed,
//                "getUsedHours phải bao gồm cả đơn PENDING");
//    }
//
//    // ---------------------------------------------------------------
//    // TEST 6: Tổng hợp thời gian nghỉ theo từng loại (nhân viên)
//    // ---------------------------------------------------------------
//    private static void testLeaveTimeSummary() {
//        System.out.println("\n--- TEST 6: Tổng hợp thời gian nghỉ theo loại ---");
//
//        LeaveBalanceDAO bal = new LeaveBalanceDAO();
//        int year = LocalDate.now().getYear();
//
//        List<Map<String, Object>> summary =
//                bal.getUserLeaveTimeSummary(FULL_TIME_USER, year);
//
//        System.out.println("  Số loại nghỉ có đơn: " + summary.size());
//        assertTrue(summary != null, "Phải trả về danh sách (không null)");
//
//        double sumTotal = 0;
//        for (Map<String, Object> row : summary) {
//            double total = ((Number) row.get("totalHours")).doubleValue();
//            double approved = ((Number) row.get("approvedHours")).doubleValue();
//            double pending = ((Number) row.get("pendingHours")).doubleValue();
//
//            assertTrue(total >= 0, "Tổng giờ phải >= 0");
//            assertTrue(Math.abs(total - (approved + pending)) < 0.001,
//                    "Tổng phải = đã duyệt + chờ duyệt");
//            assertTrue(row.get("leaveTypeName") != null,
//                    "Mỗi dòng phải có tên loại nghỉ");
//
//            sumTotal += total;
//        }
//        System.out.println("  Tổng giờ tất cả loại: " + sumTotal);
//
//        // Đối chiếu với tổng trực tiếp trong DB
//        double dbTotal = queryDouble(
//                "SELECT COALESCE(SUM(total_hours), 0) FROM leave_requests "
//                + "WHERE user_id = ? AND YEAR(start_date) = ? "
//                + "AND status IN ('APPROVED', 'PENDING')",
//                FULL_TIME_USER, year);
//        assertTrue(Math.abs(sumTotal - dbTotal) < 0.001,
//                "Tổng hợp phải khớp với tổng giờ trong DB ("
//                        + sumTotal + " vs " + dbTotal + ")");
//    }
//
//    // ---------------------------------------------------------------
//    // TEST 7: Tổng hợp thời gian nghỉ theo loại (chi nhánh)
//    // ---------------------------------------------------------------
//    private static void testBranchLeaveSummary() {
//        System.out.println("\n--- TEST 7: Tổng hợp theo chi nhánh ---");
//
//        LeaveBalanceDAO bal = new LeaveBalanceDAO();
//        int branchId = 1;
//        int year = LocalDate.now().getYear();
//
//        List<Map<String, Object>> summary =
//                bal.getBranchLeaveSummary(branchId, year);
//
//        System.out.println("  Số loại: " + summary.size());
//        assertTrue(summary != null, "Phải trả về danh sách (không null)");
//
//        double sumTotal = 0;
//        for (Map<String, Object> row : summary) {
//            double total = ((Number) row.get("totalHours")).doubleValue();
//            double approved = ((Number) row.get("approvedHours")).doubleValue();
//            double pending = ((Number) row.get("pendingHours")).doubleValue();
//
//            assertTrue(Math.abs(total - (approved + pending)) < 0.001,
//                    "Tổng = đã duyệt + chờ duyệt");
//
//            int empCount = ((Number) row.get("employeeCount")).intValue();
//            assertTrue(empCount >= 0, "Số nhân viên phải >= 0");
//
//            sumTotal += total;
//        }
//        System.out.println("  Tổng giờ chi nhánh: " + sumTotal);
//
//        double dbTotal = queryDouble(
//                "SELECT COALESCE(SUM(lr.total_hours), 0) "
//                + "FROM leave_requests lr "
//                + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
//                + "WHERE ep.home_branch_id = ? "
//                + "AND YEAR(lr.start_date) = ? "
//                + "AND lr.status IN ('APPROVED', 'PENDING')",
//                branchId, year);
//        assertTrue(Math.abs(sumTotal - dbTotal) < 0.001,
//                "Tổng chi nhánh phải khớp DB (" + sumTotal
//                        + " vs " + dbTotal + ")");
//    }
//
//    // ---------------------------------------------------------------
//    // TEST 8: Định nghĩa ca kèm thời lượng
//    // ---------------------------------------------------------------
//    private static void testShiftDefinitions() {
//        System.out.println("\n--- TEST 8: Định nghĩa ca ---");
//
//        List<Map<String, Object>> defs =
//                new LeaveShiftOptionDAO().getShiftDefinitions();
//
//        System.out.println("  Số ca: " + defs.size());
//        assertTrue(!defs.isEmpty(), "Phải có ít nhất 1 ca");
//
//        for (Map<String, Object> row : defs) {
//            assertTrue(row.get("shiftName") != null, "Ca phải có tên");
//            assertTrue(row.get("startTime") != null, "Ca phải có giờ bắt đầu");
//            assertTrue(row.get("endTime") != null, "Ca phải có giờ kết thúc");
//
//            double hours = ((Number) row.get("hours")).doubleValue();
//            assertTrue(hours > 0, "Mỗi ca phải có thời lượng > 0");
//        }
//    }
//
//    // ---------------------------------------------------------------
//    // Helper
//    // ---------------------------------------------------------------
//    private static void cleanup(int requestId, int userId,
//                                int shiftId, java.sql.Date workDate) {
//        try (Connection c = DBContext.getConnection()) {
//            c.setAutoCommit(false);
//
//            try (PreparedStatement ps = c.prepareStatement(
//                    "UPDATE leave_requests SET status = 'CANCELLED' "
//                    + "WHERE id = ?")) {
//                ps.setInt(1, requestId);
//                ps.executeUpdate();
//            }
//            try (PreparedStatement ps = c.prepareStatement(
//                    "DELETE FROM leave_request_shifts "
//                    + "WHERE leave_request_id = ?")) {
//                ps.setInt(1, requestId);
//                ps.executeUpdate();
//            }
//            try (PreparedStatement ps = c.prepareStatement(
//                    "UPDATE shift_schedules SET status = 'PUBLISHED' "
//                    + "WHERE user_id = ? AND shift_id = ? AND work_date = ?")) {
//                ps.setInt(1, userId);
//                ps.setInt(2, shiftId);
//                ps.setDate(3, workDate);
//                ps.executeUpdate();
//            }
//            try (PreparedStatement ps = c.prepareStatement(
//                    "DELETE FROM open_shifts "
//                    + "WHERE shift_id = ? AND work_date = ? "
//                    + "AND leave_request_id = ?")) {
//                ps.setInt(1, shiftId);
//                ps.setDate(2, workDate);
//                ps.setInt(3, requestId);
//                ps.executeUpdate();
//            }
//            try (PreparedStatement ps = c.prepareStatement(
//                    "UPDATE leave_balances SET used_hours = 0, used_days = 0 "
//                    + "WHERE user_id = ? AND leave_type_id = 1 "
//                    + "AND year = ?")) {
//                ps.setInt(1, userId);
//                ps.setInt(2, year());
//                ps.executeUpdate();
//            }
//
//            c.commit();
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//
//    private static int year() {
//        return LocalDate.now().getYear();
//    }
//
//    private static String queryOne(String sql, Object... params) {
//        try (Connection c = DBContext.getConnection();
//             PreparedStatement ps = c.prepareStatement(sql)) {
//            for (int i = 0; i < params.length; i++) {
//                ps.setObject(i + 1, params[i]);
//            }
//            try (ResultSet rs = ps.executeQuery()) {
//                if (rs.next()) {
//                    return rs.getString(1);
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return null;
//    }
//
//    private static int queryInt(String sql, Object... params) {
//        try (Connection c = DBContext.getConnection();
//             PreparedStatement ps = c.prepareStatement(sql)) {
//            for (int i = 0; i < params.length; i++) {
//                ps.setObject(i + 1, params[i]);
//            }
//            try (ResultSet rs = ps.executeQuery()) {
//                if (rs.next()) {
//                    return rs.getInt(1);
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return 0;
//    }
//
//    private static double queryDouble(String sql, Object... params) {
//        try (Connection c = DBContext.getConnection();
//             PreparedStatement ps = c.prepareStatement(sql)) {
//            for (int i = 0; i < params.length; i++) {
//                ps.setObject(i + 1, params[i]);
//            }
//            try (ResultSet rs = ps.executeQuery()) {
//                if (rs.next()) {
//                    return rs.getDouble(1);
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return 0;
//    }
//
//    private static void assertTrue(boolean condition, String message) {
//        if (condition) {
//            System.out.println("  [PASS] " + message);
//        } else {
//            System.out.println("  [FAIL] " + message);
//            throw new AssertionError(message);
//        }
//    }
//}
