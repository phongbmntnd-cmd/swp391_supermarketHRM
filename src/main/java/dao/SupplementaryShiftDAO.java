package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class SupplementaryShiftDAO {

    public boolean openRegistration(int branchId, int positionId, int shiftId, String workDate,
            Timestamp deadline, int openedBy) {
        LocalDate date = LocalDate.parse(workDate);
        if (date.isBefore(LocalDate.now()) || deadline == null
            || !deadline.after(new Timestamp(System.currentTimeMillis()))
            || deadline.toLocalDateTime().isAfter(date.atStartOfDay())) {
            return false;
        }

        String publishedSql = "SELECT COUNT(*) FROM shift_schedules WHERE branch_id = ? AND work_date = ? AND status = 'PUBLISHED'";
        String assignedSql = "SELECT COUNT(*) FROM shift_schedules WHERE branch_id = ? AND position_id = ? AND shift_id = ? AND work_date = ?";
        String requirementSql = "SELECT required_count FROM shift_requirements WHERE branch_id = ? AND position_id = ? AND shift_id = ? AND work_date = ? LIMIT 1";
        String upsertSql = "INSERT INTO supplementary_shift_opportunities "
                + "(branch_id, position_id, shift_id, work_date, registration_deadline, opened_by, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'OPEN') ON DUPLICATE KEY UPDATE "
                + "registration_deadline = VALUES(registration_deadline), opened_by = VALUES(opened_by), status = 'OPEN'";

        try (Connection connection = DBContext.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(publishedSql)) {
                statement.setInt(1, branchId);
                statement.setDate(2, java.sql.Date.valueOf(date));
                try (ResultSet result = statement.executeQuery()) {
                    if (result.next() && result.getInt(1) > 0) {
                        return false;
                    }
                }
            }

            int assignedCount;
            try (PreparedStatement statement = connection.prepareStatement(assignedSql)) {
                statement.setInt(1, branchId);
                statement.setInt(2, positionId);
                statement.setInt(3, shiftId);
                statement.setDate(4, java.sql.Date.valueOf(date));
                try (ResultSet result = statement.executeQuery()) {
                    result.next();
                    assignedCount = result.getInt(1);
                }
            }

            int requiredCount;
            try (PreparedStatement statement = connection.prepareStatement(requirementSql)) {
                statement.setInt(1, branchId);
                statement.setInt(2, positionId);
                statement.setInt(3, shiftId);
                statement.setDate(4, java.sql.Date.valueOf(date));
                try (ResultSet result = statement.executeQuery()) {
                    requiredCount = result.next()
                            ? result.getInt("required_count")
                            : new ShiftScheduleDAO().getSmartDefaultRequirement(workDate, positionId, shiftId);
                }
            }

            if (assignedCount <= 0 || assignedCount >= requiredCount) {
                return false;
            }

            try (PreparedStatement statement = connection.prepareStatement(upsertSql)) {
                statement.setInt(1, branchId);
                statement.setInt(2, positionId);
                statement.setInt(3, shiftId);
                statement.setDate(4, java.sql.Date.valueOf(date));
                statement.setTimestamp(5, deadline);
                statement.setInt(6, openedBy);
                statement.executeUpdate();
                return true;
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không thể mở đăng ký bổ sung ca", e);
        }
    }

    public List<Map<String, Object>> getOpenRegistrationsForEmployee(int userId, int branchId, int positionId) {
        List<Map<String, Object>> registrations = new ArrayList<>();
        String sql = "SELECT o.id, o.work_date, o.registration_deadline, p.title AS position_title, "
                + "s.name AS shift_name, s.start_time, s.end_time, a.id AS application_id "
                + "FROM supplementary_shift_opportunities o "
                + "JOIN positions p ON p.id = o.position_id JOIN shifts s ON s.id = o.shift_id "
                + "LEFT JOIN supplementary_shift_applications a ON a.opportunity_id = o.id AND a.user_id = ? "
                + "WHERE o.branch_id = ? AND o.position_id = ? AND o.status = 'OPEN' "
                + "AND o.work_date >= CURDATE() AND o.registration_deadline > NOW() "
                + "ORDER BY o.work_date, s.start_time";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setInt(2, branchId);
            statement.setInt(3, positionId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("registrationId", result.getInt("id"));
                    row.put("workDate", result.getDate("work_date").toString());
                    row.put("deadline", result.getTimestamp("registration_deadline"));
                    row.put("positionTitle", result.getString("position_title"));
                    row.put("shiftName", result.getString("shift_name"));
                    row.put("startTime", result.getTime("start_time"));
                    row.put("endTime", result.getTime("end_time"));
                    row.put("applied", result.getObject("application_id") != null);
                    registrations.add(row);
                }
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không thể tải danh sách ca đăng ký bổ sung", e);
        }
        return registrations;
    }

    public boolean apply(int opportunityId, int userId) {
        String eligibilitySql = "SELECT o.branch_id, o.position_id, o.shift_id, o.work_date, s.name AS shift_name, "
                + "s.start_time, s.end_time, ep.shift_type FROM supplementary_shift_opportunities o "
                + "JOIN shifts s ON s.id = o.shift_id JOIN employee_profiles ep ON ep.user_id = ? "
                + "JOIN users u ON u.id = ep.user_id WHERE o.id = ? AND o.branch_id = ep.home_branch_id "
                + "AND o.position_id = ep.position_id AND ep.employee_type IN ('PART_TIME', 'CASUAL') "
                + "AND u.status = 'ACTIVE' AND o.status = 'OPEN' AND o.work_date >= CURDATE() "
                + "AND o.registration_deadline > NOW() "
                + "AND NOT EXISTS (SELECT 1 FROM shift_schedules published "
                + "WHERE published.branch_id = o.branch_id AND published.work_date = o.work_date AND published.status = 'PUBLISHED')";
        String conflictSql = "SELECT COUNT(*) FROM shift_schedules ss JOIN shifts existing_shift ON existing_shift.id = ss.shift_id "
                + "WHERE ss.user_id = ? AND ss.work_date = ? AND existing_shift.start_time < ? AND existing_shift.end_time > ?";
        String heldSql = "SELECT COUNT(*) FROM temporary_transfer_employees e JOIN temporary_transfers t ON t.id = e.transfer_id "
                + "JOIN shifts existing_shift ON existing_shift.id = t.shift_id "
                + "WHERE e.employee_id = ? AND t.work_date = ? AND t.status = 'PENDING_HR' AND e.status = 'RESERVED' "
                + "AND existing_shift.start_time < ? AND existing_shift.end_time > ?";
        String insertSql = "INSERT INTO supplementary_shift_applications (opportunity_id, user_id) VALUES (?, ?)";

        try (Connection connection = DBContext.getConnection()) {
            java.sql.Date workDate;
            java.sql.Time startTime;
            java.sql.Time endTime;
            String shiftName;
            String shiftType;
            try (PreparedStatement statement = connection.prepareStatement(eligibilitySql)) {
                statement.setInt(1, userId);
                statement.setInt(2, opportunityId);
                try (ResultSet result = statement.executeQuery()) {
                    if (!result.next()) {
                        return false;
                    }
                    workDate = result.getDate("work_date");
                    startTime = result.getTime("start_time");
                    endTime = result.getTime("end_time");
                    shiftName = result.getString("shift_name");
                    shiftType = result.getString("shift_type");
                }
            }

            if (!isAllowedFixedShift(shiftType, shiftName)
                    || hasOverlap(connection, conflictSql, userId, workDate, startTime, endTime)
                    || hasOverlap(connection, heldSql, userId, workDate, startTime, endTime)) {
                return false;
            }

            try (PreparedStatement statement = connection.prepareStatement(insertSql)) {
                statement.setInt(1, opportunityId);
                statement.setInt(2, userId);
                return statement.executeUpdate() == 1;
            }
        } catch (SQLException e) {
            if ("23000".equals(e.getSQLState())) {
                return false;
            }
            throw new IllegalStateException("Không thể đăng ký ca bổ sung", e);
        } catch (Exception e) {
            throw new IllegalStateException("Không thể đăng ký ca bổ sung", e);
        }
    }

    public List<Map<String, Object>> getApplicants(int branchId, String startDate, String endDate) {
        List<Map<String, Object>> applicants = new ArrayList<>();
        String sql = "SELECT o.work_date, o.position_id, o.shift_id, p.title AS position_title, "
            + "s.name AS shift_name, a.user_id, ep.full_name "
                + "FROM supplementary_shift_opportunities o JOIN supplementary_shift_applications a ON a.opportunity_id = o.id "
            + "JOIN employee_profiles ep ON ep.user_id = a.user_id JOIN shifts s ON s.id = o.shift_id "
            + "JOIN positions p ON p.id = o.position_id "
                + "WHERE o.branch_id = ? AND o.work_date BETWEEN ? AND ? ORDER BY o.work_date, ep.full_name";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, branchId);
            statement.setDate(2, java.sql.Date.valueOf(startDate));
            statement.setDate(3, java.sql.Date.valueOf(endDate));
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("workDate", result.getDate("work_date").toString());
                    row.put("positionId", result.getInt("position_id"));
                    row.put("positionTitle", result.getString("position_title"));
                    row.put("shiftId", result.getInt("shift_id"));
                    row.put("shiftName", result.getString("shift_name"));
                    row.put("userId", result.getInt("user_id"));
                    row.put("fullName", result.getString("full_name"));
                    row.put("dayOfWeek", result.getDate("work_date").toLocalDate().getDayOfWeek().name());
                    applicants.add(row);
                }
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không thể tải nhân viên đăng ký ca bổ sung", e);
        }
        return applicants;
    }

    public void closeRegistrationsForWeek(int branchId, String startDate, String endDate) {
        String sql = "UPDATE supplementary_shift_opportunities SET status = 'CLOSED' "
                + "WHERE branch_id = ? AND work_date BETWEEN ? AND ? AND status = 'OPEN'";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, branchId);
            statement.setDate(2, java.sql.Date.valueOf(startDate));
            statement.setDate(3, java.sql.Date.valueOf(endDate));
            statement.executeUpdate();
        } catch (Exception e) {
            throw new IllegalStateException("Không thể đóng đăng ký bổ sung sau khi publish", e);
        }
    }

    private boolean hasOverlap(Connection connection, String sql, int userId, java.sql.Date workDate,
            java.sql.Time startTime, java.sql.Time endTime) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setDate(2, workDate);
            statement.setTime(3, endTime);
            statement.setTime(4, startTime);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() && result.getInt(1) > 0;
            }
        }
    }

    private boolean isAllowedFixedShift(String shiftType, String shiftName) {
        if (shiftType == null || shiftName == null) {
            return true;
        }
        String type = shiftType.trim().toUpperCase(Locale.ROOT);
        String name = shiftName.toLowerCase(Locale.ROOT);
        if (type.equals("PT_FIXED_MORNING")) {
            return name.contains("sáng");
        }
        if (type.equals("PT_FIXED_AFTERNOON")) {
            return name.contains("chiều");
        }
        if (type.equals("PT_FIXED_EVENING")) {
            return name.contains("tối");
        }
        return true;
    }
}