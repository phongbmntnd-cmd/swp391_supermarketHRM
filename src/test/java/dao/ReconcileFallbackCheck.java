package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Kiem tra fallback cua reconcileApprovedLeaves:
 * NV tick ca CO DINH (Ca Toi) nhung Store xep ca KHAC (Ca Sang)
 * cho cung ngay -> don nghi phai duoc khop theo NGAY.
 */
public class ReconcileFallbackCheck {

    public static void main(String[] args) throws Exception {

        int userId = 44;
        int branchId = 1;
        java.sql.Date workDate = java.sql.Date.valueOf("2026-10-31");

        // Ca that cua Store tren ngay do (dang DRAFT)
        int realShiftId = -1;
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT shift_id FROM shift_schedules "
                     + "WHERE user_id = ? AND work_date = ? "
                     + "AND status = 'DRAFT' LIMIT 1")) {
            ps.setInt(1, userId);
            ps.setDate(2, workDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    realShiftId = rs.getInt(1);
                }
            }
        }

        // Ca co dinh ma NV se tick (PT_FIXED_EVENING -> shift 3)
        int fixedShiftId = new LeaveShiftOptionDAO()
                .getFixedShiftOptions("PT_FIXED_EVENING")
                .get(0).get("shiftId") == null ? -1
                : ((Number) new LeaveShiftOptionDAO()
                        .getFixedShiftOptions("PT_FIXED_EVENING")
                        .get(0).get("shiftId")).intValue();

        System.out.println("Ca that cua Store : shift " + realShiftId);
        System.out.println("Ca co dinh NV tick: shift " + fixedShiftId);

        if (realShiftId <= 0) {
            System.out.println("[SKIP] khong co ca DRAFT de test");
            return;
        }

        // 1. Tao don APPROVED gia lap: NV tick ca co dinh
        int leaveTypeId = 1;
        int reqId = -1;

        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO leave_requests (user_id, leave_type_id, "
                    + "start_date, end_date, total_hours, status, "
                    + "reason, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, 'APPROVED', 'test', NOW())")) {
                ps.setInt(1, userId);
                ps.setInt(2, leaveTypeId);
                ps.setDate(3, workDate);
                ps.setDate(4, workDate);
                ps.setDouble(5, 5.0);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT LAST_INSERT_ID()")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        reqId = rs.getInt(1);
                    }
                }
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO leave_request_shifts (leave_request_id, "
                    + "shift_id, shift_name, work_date, hours) "
                    + "VALUES (?, ?, 'Ca Toi (dự kiến)', ?, 5.0)")) {
                ps.setInt(1, reqId);
                ps.setInt(2, fixedShiftId);
                ps.setDate(3, workDate);
                ps.executeUpdate();
            }
            c.commit();
        }
        System.out.println("Da tao don gia lap id=" + reqId);

        // 2. Publish ngay do (gioi luong Store Manager bam Publish)
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "UPDATE shift_schedules SET status = 'PUBLISHED' "
                     + "WHERE user_id = ? AND work_date = ? "
                     + "AND status = 'DRAFT'")) {
            ps.setInt(1, userId);
            ps.setDate(2, workDate);
            ps.executeUpdate();
        }
        System.out.println("Da publish ngay " + workDate);

        // 3. Chay reconcile
        int matched = new LeaveRequestDAO().reconcileApprovedLeaves(
                branchId, workDate, workDate);
        System.out.println("reconcile khop duoc: " + matched + " ca");

        // 4. Kiem tra ket qua
        String status = "?";
        int detailShiftId = -1;
        try (Connection c = DBContext.getConnection()) {
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT status FROM shift_schedules "
                    + "WHERE user_id = ? AND work_date = ? "
                    + "AND shift_id = ?")) {
                ps.setInt(1, userId);
                ps.setDate(2, workDate);
                ps.setInt(3, realShiftId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        status = rs.getString(1);
                    }
                }
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT shift_id FROM leave_request_shifts "
                    + "WHERE leave_request_id = ?")) {
                ps.setInt(1, reqId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        detailShiftId = rs.getInt(1);
                    }
                }
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT COUNT(*) FROM open_shifts "
                    + "WHERE leave_request_id = ? AND work_date = ?")) {
                ps.setInt(1, reqId);
                ps.setDate(2, workDate);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("Ca trong cho cover: "
                                + rs.getInt(1));
                    }
                }
            }
        }

        System.out.println("Status ca that cua Store: " + status);
        System.out.println("shift_id trong chi tiet don: " + detailShiftId);

        boolean ok = "ON_LEAVE".equals(status)
                && detailShiftId == realShiftId;
        System.out.println(ok ? "[PASS] Da khop dung theo ngay"
                : "[FAIL] Khong khop dung");

        // 5. Don dep
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement(
                    "DELETE FROM open_shifts WHERE leave_request_id = ?")) {
                ps.setInt(1, reqId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "DELETE FROM leave_request_shifts "
                    + "WHERE leave_request_id = ?")) {
                ps.setInt(1, reqId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "DELETE FROM leave_requests WHERE id = ?")) {
                ps.setInt(1, reqId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "UPDATE shift_schedules SET status = 'DRAFT' "
                    + "WHERE user_id = ? AND work_date = ? "
                    + "AND shift_id = ?")) {
                ps.setInt(1, userId);
                ps.setDate(2, workDate);
                ps.setInt(3, realShiftId);
                ps.executeUpdate();
            }
            c.commit();
        }
        System.out.println("Da don dep");
    }
}
