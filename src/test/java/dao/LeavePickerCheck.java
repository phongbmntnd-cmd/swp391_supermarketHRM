package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Kiem tra: ca da xep (ke ca DRAFT) cua nhan vien co hien ra dung
 * trong "Chon ca muon nghi" khong.
 */
public class LeavePickerCheck {

    public static void main(String[] args) throws Exception {

        int userId = 44;

        try (Connection c = DBContext.getConnection()) {

            System.out.println("=== Thong tin NV ===");
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT ep.employee_type, ep.shift_type, ep.position_id, "
                    + "ep.home_branch_id FROM employee_profiles ep "
                    + "WHERE ep.user_id = ?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("  employee_type = " + rs.getString(1));
                        System.out.println("  shift_type    = " + rs.getString(2));
                        System.out.println("  position_id   = " + rs.getInt(3));
                        System.out.println("  branch_id     = " + rs.getInt(4));
                    }
                }
            }

            System.out.println();
            System.out.println("=== Ca da xep trong 4 tuan ===");
            String sql = "SELECT ss.work_date, ss.shift_id, s.name, ss.status "
                    + "FROM shift_schedules ss "
                    + "JOIN shifts s ON s.id = ss.shift_id "
                    + "WHERE ss.user_id = ? "
                    + "AND ss.work_date BETWEEN CURDATE() "
                    + "  AND DATE_ADD(CURDATE(), INTERVAL 27 DAY) "
                    + "ORDER BY ss.work_date, s.start_time";

            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    int count = 0;
                    while (rs.next()) {
                        count++;
                        System.out.println("  " + rs.getDate(1)
                                + " | shift " + rs.getInt(2)
                                + " | " + rs.getString(3)
                                + " | " + rs.getString(4));
                    }
                    System.out.println("  --> tong so dong: " + count);
                }
            }

            System.out.println();
            System.out.println("=== Kiem tra DAO moi (getAssignedShifts) ===");
            LeaveShiftOptionDAO dao = new LeaveShiftOptionDAO();
            java.time.LocalDate start = java.time.LocalDate.now()
                    .with(java.time.temporal.TemporalAdjusters
                            .previousOrSame(java.time.DayOfWeek.MONDAY));

            java.util.List<java.util.Map<String, Object>> rows =
                    dao.getAssignedShifts(userId, start,
                            start.plusDays(27));

            for (java.util.Map<String, Object> r : rows) {
                System.out.println("  " + r.get("workDate")
                        + " | " + r.get("shiftName")
                        + " | scheduled=" + r.get("published")
                        + " | onLeave=" + r.get("onLeave")
                        + " | status=" + r.get("status"));
            }
            System.out.println("  --> so dong DAO tra ve: " + rows.size());

            System.out.println();
            System.out.println("=== Trang thai publish tuần hien tai ===");
            int branchId = 0;
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT home_branch_id FROM employee_profiles "
                    + "WHERE user_id = ?")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        branchId = rs.getInt(1);
                    }
                }
            }
            System.out.println("  isWeekPublished      = "
                    + dao.isWeekPublished(branchId, start));
            System.out.println("  isWeekFullyPublished = "
                    + dao.isWeekFullyPublished(branchId, start));

            System.out.println();
            System.out.println("=== Ca co dinh theo shift_type ===");
            for (java.util.Map<String, Object> f
                    : dao.getFixedShiftOptions("PT_FIXED_EVENING")) {
                System.out.println("  shift " + f.get("shiftId")
                        + " | " + f.get("shiftName")
                        + " | " + f.get("hours") + " gio");
            }
        }
    }
}
