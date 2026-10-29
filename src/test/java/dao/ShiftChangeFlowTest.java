package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

/**
 * Test tích hợp cho luồng đổi ca của nhân viên.
 *
 * Chạy: mvn -o test -Dtest=ShiftChangeFlowTest
 *
 * Luồng kiểm tra:
 *   1. Nhân viên A tạo đơn đổi ca với đồng nghiệp B (SWAP).
 *   2. B nhận được đơn đến (WAITING_COLLEAGUE) và trả lời.
 *   3. B đồng ý -> đơn chuyển PENDING, A hủy được đơn.
 *   4. B từ chối -> đơn DECLINED.
 *   5. Nhân viên tạo đơn chuyển sang ca trống (OPEN).
 *   6. Store Manager duyệt -> lịch được cập nhật, ca cũ mở lại.
 */
public class ShiftChangeFlowTest {

    private static int empA;
    private static int empB;
    private static int smUserId;
    private static int branchId;

    public static void main(String[] args) throws Exception {
        setup();

        testGetMySchedules();
        testGetColleagueSchedules();
        testCreateSwapAndRespond();
        testDeclineSwap();
        testCancelRequest();
        testCreateOpenChange();
        testReviewApproveSwap();
        testOpenShiftManagement();

        System.out.println("\n=== TẤT CẢ TEST ĐÃ CHẠY XONG ===");
    }

    // ------------------------------------------------------------------
    private static void setup() throws Exception {
        empA = findUserId("pt_user1");
        empB = findUserId("pt_user2");

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT ep.home_branch_id FROM employee_profiles ep "
                     + "WHERE ep.user_id = ?")) {
            ps.setInt(1, empA);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    branchId = rs.getInt(1);
                }
            }
        }

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM users WHERE role_id = 4 "
                     + "AND status = 'ACTIVE' LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    smUserId = rs.getInt(1);
                }
            }
        }

        System.out.println("empA(pt_user1) = " + empA
                + " | empB(pt_user2) = " + empB
                + " | branch = " + branchId
                + " | storeManager = " + smUserId);
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

    // ------------------------------------------------------------------
    private static void testGetMySchedules() throws Exception {
        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        List<Map<String, Object>> list = dao.getMySchedules(empA);
        System.out.println("\n[1] getMySchedules -> " + list.size() + " ca");

        for (Map<String, Object> row : list) {
            System.out.println("    id=" + row.get("id")
                    + " date=" + row.get("workDate")
                    + " shift=" + row.get("shiftName"));
        }
    }

    private static void testGetColleagueSchedules() throws Exception {
        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        List<Map<String, Object>> list =
                dao.getColleagueSchedules(empA);
        System.out.println("\n[2] getColleagueSchedules -> "
                + list.size() + " ca đồng nghiệp");

        for (Map<String, Object> row : list) {
            System.out.println("    schedule=" + row.get("id")
                    + " colleague=" + row.get("colleagueName")
                    + " date=" + row.get("workDate")
                    + " shift=" + row.get("shiftName"));
        }
    }

    // ------------------------------------------------------------------
    private static void testCreateSwapAndRespond() throws Exception {
        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            System.out.println("\n[3] BỎ QUA createSwap: "
                    + "không tìm được cặp ca hợp lệ");
            return;
        }

        cleanupRequests(pair[0], pair[1]);

        boolean created = dao.createSwap(
                empA, pair[0], pair[1], "Xin đổi ca kiểm thử");

        System.out.println("\n[3] createSwap -> " + created
                + " (my=" + pair[0] + ", target=" + pair[1] + ")");

        if (!created) {
            return;
        }

        int requestId = latestRequestId(empA);

        List<Map<String, Object>> incoming =
                dao.getIncomingRequests(empB);
        System.out.println("    incoming của empB -> "
                + incoming.size() + " đơn");

        boolean responded = dao.respondToSwap(
                requestId, empB, true, "Đồng ý đổi ca");
        System.out.println("    respondToSwap(accept) -> " + responded);

        System.out.println("    status hiện tại = "
                + statusOf(requestId));

        // A có thể hủy đơn khi còn PENDING
        boolean cancelled = dao.cancelMyRequest(requestId, empA);
        System.out.println("    cancelMyRequest -> " + cancelled
                + " | status = " + statusOf(requestId));
    }

    private static void testDeclineSwap() throws Exception {
        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            System.out.println("\n[4] BỎ QUA declineSwap");
            return;
        }

        cleanupRequests(pair[0], pair[1]);

        boolean created = dao.createSwap(
                empA, pair[0], pair[1], "Đơn sẽ bị từ chối");
        if (!created) {
            System.out.println("\n[4] BỎ QUA declineSwap: tạo đơn thất bại");
            return;
        }

        int requestId = latestRequestId(empA);

        boolean responded = dao.respondToSwap(
                requestId, empB, false, "Xin lỗi, không đổi được");
        System.out.println("\n[4] respondToSwap(decline) -> " + responded
                + " | status = " + statusOf(requestId));

        // Đơn đã DECLINED thì không hủy được nữa
        boolean cancelled = dao.cancelMyRequest(requestId, empA);
        System.out.println("    cancelMyRequest sau DECLINED -> "
                + cancelled + " (mong đợi false)");
    }

    private static void testCancelRequest() throws Exception {
        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            System.out.println("\n[5] BỎ QUA testCancelRequest");
            return;
        }

        cleanupRequests(pair[0], pair[1]);

        dao.createSwap(empA, pair[0], pair[1], "Đơn để hủy");
        int requestId = latestRequestId(empA);

        boolean cancelled = dao.cancelMyRequest(requestId, empA);
        System.out.println("\n[5] cancelMyRequest (WAITING_COLLEAGUE) -> "
                + cancelled + " | status = " + statusOf(requestId));

        // Hủy lần 2 phải thất bại
        boolean again = dao.cancelMyRequest(requestId, empA);
        System.out.println("    hủy lần 2 -> " + again
                + " (mong đợi false)");
    }

    // ------------------------------------------------------------------
    private static void testCreateOpenChange() throws Exception {
        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        // Tạo một ca trống ở chi nhánh của empA
        int shiftId = firstShiftId();
        int positionId = positionOf(empA);

        if (shiftId <= 0 || positionId <= 0) {
            System.out.println("\n[6] BỎ QUA createOpenChange: "
                    + "thiếu ca / vị trí");
            return;
        }

        java.time.LocalDate workDate =
                java.time.LocalDate.now().plusDays(3);

        dao.createOpenShift(branchId, shiftId, positionId, workDate);

        List<Map<String, Object>> openShifts = dao.getOpenShifts(empA);
        System.out.println("\n[6] getOpenShifts -> "
                + openShifts.size() + " ca trống");

        for (Map<String, Object> row : openShifts) {
            System.out.println("    id=" + row.get("id")
                    + " date=" + row.get("workDate")
                    + " shift=" + row.get("shiftName")
                    + " branch=" + row.get("branchName"));
        }

        if (openShifts.isEmpty()) {
            System.out.println("    không có ca trống -> bỏ qua");
            return;
        }

        int openId = (Integer) openShifts.get(0).get("id");

        // Chọn ca của chính mình SAU cho không chồng lấn khung giờ
        // với ca trống -> việc chuyển ca mới có ý nghĩa.
        int[] mine = findMyScheduleNotOverlapping(openId);
        if (mine == null) {
            System.out.println("    không có ca của chính mình "
                    + "không chồng lấn ca trống -> bỏ qua");
            return;
        }

        boolean created = dao.createOpenChange(
                empA, mine[0], openId, "Xin chuyển sang ca trống");
        System.out.println("    createOpenChange -> " + created
                + " | status = " + statusOf(latestRequestId(empA)));
    }

    /**
     * Tìm ca của chính mình không chồng lấn khung giờ với ca trống.
     */
    private static int[] findMyScheduleNotOverlapping(int openId)
            throws Exception {

        String sql
                = "SELECT ss.id FROM shift_schedules ss "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "JOIN open_shifts os ON os.id = ? "
                + "JOIN shifts os2 ON os2.id = os.shift_id "
                + "WHERE ss.user_id = ? "
                + "AND ss.status = 'PUBLISHED' "
                + "AND ss.work_date >= "
                + "DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) "
                + "AND NOT (ss.work_date = os.work_date "
                + "         AND s.start_time < os2.end_time "
                + "         AND s.end_time > os2.start_time) "
                + "ORDER BY ss.work_date LIMIT 1";

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, openId);
            ps.setInt(2, empA);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{rs.getInt(1)};
                }
            }
        }

        return null;
    }

    // ------------------------------------------------------------------
    private static void testReviewApproveSwap() throws Exception {
        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int[] pair = findSwapPair();
        if (pair == null) {
            System.out.println("\n[7] BỎ QUA review: thiếu cặp ca");
            return;
        }

        cleanupRequests(pair[0], pair[1]);

        if (!dao.createSwap(empA, pair[0], pair[1], "Sẽ được duyệt")) {
            System.out.println("\n[7] BỎ QUA review: tạo đơn thất bại");
            return;
        }

        int requestId = latestRequestId(empA);
        dao.respondToSwap(requestId, empB, true, "OK");

        // Lưu lại chủ ca trước khi duyệt để đối chiếu
        int ownerBefore = ownerOf(pair[0]);

        boolean approved = dao.review(
                requestId, branchId, true, "Đồng ý đổi ca");
        System.out.println("\n[7] review(approve) -> " + approved
                + " | status = " + statusOf(requestId));

        int ownerAfter = ownerOf(pair[0]);
        System.out.println("    chủ ca trước = " + ownerBefore
                + " | sau = " + ownerAfter
                + " (mong đợi sau = empB = " + empB + ")");

        // Duyệt lần 2 phải thất bại (đã APPROVED)
        boolean second = dao.review(
                requestId, branchId, true, "Duyệt lại");
        System.out.println("    duyệt lần 2 -> " + second
                + " (mong đợi false)");
    }

    // ------------------------------------------------------------------
    private static void testOpenShiftManagement() throws Exception {
        ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

        int shiftId = firstShiftId();
        int positionId = positionOf(empA);

        if (shiftId <= 0 || positionId <= 0) {
            System.out.println("\n[8] BỎ QUA openShiftManagement");
            return;
        }

        java.time.LocalDate d =
                java.time.LocalDate.now().plusDays(5);

        boolean created = dao.createOpenShift(
                branchId, shiftId, positionId, d);
        System.out.println("\n[8] createOpenShift -> " + created);

        // Tạo trùng cùng ngày phải thất bại
        boolean dup = dao.createOpenShift(
                branchId, shiftId, positionId, d);
        System.out.println("    tạo trùng -> " + dup
                + " (mong đợi false)");

        // Ngày quá khứ phải thất bại
        boolean past = dao.createOpenShift(
                branchId, shiftId, positionId,
                java.time.LocalDate.now().minusDays(1));
        System.out.println("    ngày quá khứ -> " + past
                + " (mong đợi false)");

        List<Map<String, Object>> list =
                dao.getBranchOpenShifts(branchId);
        System.out.println("    getBranchOpenShifts -> "
                + list.size() + " ca");
    }

    // ==================================================================
    // Tiện ích
    // ==================================================================

    /**
     * Tìm một ca của empA và một ca của empB ở cùng chi nhánh,
     * cùng vị trí, khác ngày, đủ điều kiện đổi ca.
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
                     + "WHERE a.user_id = ? AND b.user_id = ? "
                     + "AND a.status = 'PUBLISHED' "
                     + "AND b.status = 'PUBLISHED' "
                     + "AND a.work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 3 DAY) "
                     + "AND b.work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 3 DAY) "
                     + "LIMIT 1")) {

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

    /** Ca PUBLISHED sắp tới của chính empA. */
    private static int[] findMyScheduleFuture() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM shift_schedules "
                     + "WHERE user_id = ? AND status = 'PUBLISHED' "
                     + "AND work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) "
                     + "ORDER BY work_date LIMIT 1")) {

            ps.setInt(1, empA);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{rs.getInt(1)};
                }
            }
        }
        return null;
    }

    /** Xoá các đơn cũ đang chặn việc tạo đơn mới. */
    private static void cleanupRequests(int scheduleA, int scheduleB)
            throws Exception {

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "DELETE FROM shift_change_requests "
                     + "WHERE shift_schedule_id IN (?, ?) "
                     + "OR target_shift_schedule_id IN (?, ?)")) {

            ps.setInt(1, scheduleA);
            ps.setInt(2, scheduleB);
            ps.setInt(3, scheduleA);
            ps.setInt(4, scheduleB);
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
                     "SELECT status FROM shift_change_requests "
                     + "WHERE id = ?")) {

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

    private static int firstShiftId() throws Exception {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM shifts ORDER BY start_time LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    private static int positionOf(int userId) throws Exception {
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
}
