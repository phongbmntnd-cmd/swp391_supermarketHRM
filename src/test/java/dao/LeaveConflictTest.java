package dao;

import model.LeaveRequestShift;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Test cho ham chong trung don nghi phep.
 *
 * Test tu tao du lieu (roi don dep) nen khong phu thuoc vao
 * du lieu san co trong DB.
 *
 * Chay:
 *   mvn -o test-compile
 *   java -cp target/classes;target/test-classes;&lt;mysql-connector&gt; dao.LeaveConflictTest
 */
public class LeaveConflictTest {

    /** Nhan vien dung lam doi tuong test (full-time). */
    private static final int FULL_TIME_USER = 5;

    /** Tien to reason de nhan biet don do test nay tao ra. */
    private static final String TAG = "UT-CONFLICT";

    private static final LocalDate D1 = LocalDate.parse("2026-12-01");
    private static final LocalDate D2 = LocalDate.parse("2026-12-02");
    private static final LocalDate D3 = LocalDate.parse("2026-12-03");

    public static void main(String[] args) throws Exception {
        cleanup();

        try {
            LeaveRequestDAO dao = new LeaveRequestDAO();

            // ---- 1. Don co chi tiet ca chiem o (ngay + ca) ----
            dao.createRequest(
                    FULL_TIME_USER, 1, D1, D1, 1, 5.0,
                    TAG + " co chi tiet ca",
                    shifts(D1, 3));

            // 1a. Trung dung ca -> bi chan
            LeaveRequestDAO.LeaveConflict c1 = dao.findConflictingRequest(
                    FULL_TIME_USER, shifts(D1, 3), D1, D1);
            check(c1 != null, "Trung dung ca phai bi chan");
            if (c1 != null) {
                System.out.println("     -> ngay " + c1.getDate()
                        + " don #" + c1.getRequestId()
                        + " wholeDay=" + c1.isWholeDay());
            }

            // 1b. Khac ca, cung ngay -> KHONG bi chan
            LeaveRequestDAO.LeaveConflict c2 = dao.findConflictingRequest(
                    FULL_TIME_USER, shifts(D1, 1), D1, D1);
            check(c2 == null, "Khac ca cung ngay phai KHONG bi chan");

            // 1c. Ngay khac -> KHONG bi chan
            LeaveRequestDAO.LeaveConflict c3 = dao.findConflictingRequest(
                    FULL_TIME_USER, shifts(D3, 3), D3, D3);
            check(c3 == null, "Ngay khac phai KHONG bi chan");

            // 1d. Don fallback theo ngay trung don co ca -> bi chan
            LeaveRequestDAO.LeaveConflict c4 = dao.findConflictingRequest(
                    FULL_TIME_USER, new ArrayList<>(), D1, D1);
            check(c4 != null,
                    "Don fallback (tron ngay) trung don co ca phai bi chan");

            // ---- 2. Don fallback theo ngay ----
            dao.createRequest(
                    FULL_TIME_USER, 2, D2, D2, 1, 10.0,
                    TAG + " fallback theo ngay", null);

            // 2a. Don co ca trung don fallback -> bi chan
            LeaveRequestDAO.LeaveConflict c5 = dao.findConflictingRequest(
                    FULL_TIME_USER, shifts(D2, 1), D2, D2);
            check(c5 != null,
                    "Don co ca trung don fallback phai bi chan");
            if (c5 != null) {
                System.out.println("     -> ngay " + c5.getDate()
                        + " don #" + c5.getRequestId()
                        + " wholeDay=" + c5.isWholeDay());
                check(c5.isWholeDay(),
                        "Don fallback phai duoc danh dau wholeDay");
            }

            // 2b. Don fallback trung don fallback -> bi chan
            LeaveRequestDAO.LeaveConflict c6 = dao.findConflictingRequest(
                    FULL_TIME_USER, new ArrayList<>(), D2, D2);
            check(c6 != null,
                    "Hai don fallback cung ngay phai bi chan");

            // ---- 3. KHONG loc theo loai nghi ----
            LeaveRequestDAO.LeaveConflict c7 = dao.findConflictingRequest(
                    FULL_TIME_USER, shifts(D2, 3), D2, D2);
            check(c7 != null,
                    "Khong duoc loc theo loai nghi (loai khac van bi chan)");

            // ---- 4. createRequest tu chan trung ----
            boolean threw = false;
            try {
                dao.createRequest(
                        FULL_TIME_USER, 1, D1, D1, 1, 5.0,
                        TAG + " trung ca",
                        shifts(D1, 3));
            } catch (LeaveRequestDAO.DuplicateLeaveException e) {
                threw = true;
                System.out.println("     -> DuplicateLeaveException: ngay "
                        + e.getConflict().getDate());
            }
            check(threw,
                    "createRequest phai nem DuplicateLeaveException khi trung");

            // ---- 5. Don CANCELLED khong con hieu luc ----
            int reqCancelled = dao.createRequest(
                    FULL_TIME_USER, 1, D3, D3, 1, 5.0,
                    TAG + " se huy", shifts(D3, 3));
            cancelRequest(reqCancelled);

            LeaveRequestDAO.LeaveConflict c8 = dao.findConflictingRequest(
                    FULL_TIME_USER, shifts(D3, 3), D3, D3);
            check(c8 == null,
                    "Don da huy khong con chan (phai tao lai duoc)");

            System.out.println();
            System.out.println("=== TAT CA TEST CHONG TRUNG DA CHAY XONG ===");

        } finally {
            cleanup();
        }
    }

    private static List<LeaveRequestShift> shifts(LocalDate date, int shiftId) {
        List<LeaveRequestShift> list = new ArrayList<>();
        list.add(new LeaveRequestShift(
                0, Date.valueOf(date), shiftId, "", 5.0));
        return list;
    }

    private static void cancelRequest(int requestId) throws Exception {
        try (Connection c = context.DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE leave_requests SET status = 'CANCELLED' "
                     + "WHERE id = ?")) {
            ps.setInt(1, requestId);
            ps.executeUpdate();
        }
    }

    /**
     * Xoa cac don test tao ra (duoc danh dau bang reason).
     */
    private static void cleanup() {
        try (Connection c = context.DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT id FROM leave_requests "
                     + "WHERE user_id = ? AND reason LIKE ?")) {
            ps.setInt(1, FULL_TIME_USER);
            ps.setString(2, TAG + "%");
            List<Integer> ids = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt(1));
                }
            }
            if (ids.isEmpty()) {
                return;
            }
            try (PreparedStatement del = c.prepareStatement(
                    "DELETE FROM leave_request_shifts "
                    + "WHERE leave_request_id = ?")) {
                for (int id : ids) {
                    del.setInt(1, id);
                    del.addBatch();
                }
                del.executeBatch();
            }
            try (PreparedStatement del = c.prepareStatement(
                    "DELETE FROM leave_requests WHERE id = ?")) {
                for (int id : ids) {
                    del.setInt(1, id);
                    del.addBatch();
                }
                del.executeBatch();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void check(boolean ok, String msg) {
        System.out.println((ok ? "  [PASS] " : "  [FAIL] ") + msg);
        if (!ok) {
            throw new AssertionError(msg);
        }
    }
}
