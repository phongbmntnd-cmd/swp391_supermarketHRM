/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import context.DBContext;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import model.Attendance;

public class AttendanceDAO {

    public List<Attendance> getEmployeeShifts(int userId, Date workDate) throws SQLException {
        String sql = "SELECT ss.id AS shift_schedule_id, ss.user_id AS user_id, ss.work_date, s.name AS shift_name, "
                + "s.start_time, s.end_time, a.id, a.check_in, a.check_out, a.status "
                + "FROM shift_schedules ss "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "LEFT JOIN attendances a ON a.shift_schedule_id = ss.id AND a.user_id = ss.user_id "
                + "WHERE ss.user_id = ? AND ss.work_date = ? AND ss.status = 'PUBLISHED' "
                + "ORDER BY s.start_time";

        List<Attendance> shifts = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setDate(2, workDate);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    shifts.add(mapAttendance(result));
                }
            }
        } catch (Exception e) {
            throw new SQLException("Không thể tải ca làm và chấm công của nhân viên.", e);
        }
        return shifts;
    }

    public List<Attendance> getRecentEmployeeAttendance(int userId, Date beforeDate) throws SQLException {
        String sql = "SELECT a.id, a.user_id, a.shift_schedule_id, ss.work_date, "
                + "s.name AS shift_name, s.start_time, s.end_time, a.check_in, a.check_out, a.status "
                + "FROM attendances a "
                + "JOIN shift_schedules ss ON ss.id = a.shift_schedule_id "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "WHERE a.user_id = ? AND ss.work_date < ? "
                + "ORDER BY ss.work_date DESC, s.start_time DESC LIMIT 20";

        List<Attendance> attendances = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setDate(2, beforeDate);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    attendances.add(mapAttendance(result));
                }
            }
        } catch (Exception e) {
            throw new SQLException("Không thể tải lịch sử chấm công.", e);
        }
        return attendances;
    }

    public List<Attendance> getBranchAttendance(int branchId, Date workDate) throws SQLException {
        String sql = "SELECT a.id, a.user_id, a.shift_schedule_id, ss.work_date, "
                + "s.name AS shift_name, s.start_time, s.end_time, a.check_in, a.check_out, a.status, "
                + "ep.full_name, u.username, b.name AS branch_name "
                + "FROM attendances a "
                + "JOIN shift_schedules ss ON ss.id = a.shift_schedule_id "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "JOIN users u ON u.id = a.user_id "
                + "JOIN employee_profiles ep ON ep.user_id = a.user_id "
                + "JOIN branches b ON b.id = ss.branch_id "
                + "WHERE ss.work_date = ? AND (? = 0 OR ss.branch_id = ?) "
                + "ORDER BY s.start_time, ep.full_name";

        List<Attendance> attendances = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, workDate);
            statement.setInt(2, branchId);
            statement.setInt(3, branchId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Attendance attendance = mapAttendance(result);
                    attendance.setFullName(result.getString("full_name"));
                    attendance.setUsername(result.getString("username"));
                    attendance.setBranchName(result.getString("branch_name"));
                    attendances.add(attendance);
                }
            }
        } catch (Exception e) {
            throw new SQLException("Không thể tải bảng chấm công của chi nhánh.", e);
        }
        return attendances;
    }

    public List<Attendance> getAttendanceForHr(Date fromDate, Date toDate) throws SQLException {
        String sql = "SELECT a.id, a.user_id, a.shift_schedule_id, ss.work_date, "
                + "s.name AS shift_name, s.start_time, s.end_time, a.check_in, a.check_out, a.status, "
                + "ep.full_name, u.username, b.name AS branch_name, latest.adjustment_note, "
                + "reviewer.username AS adjusted_by_username, latest.created_at AS adjusted_at "
                + "FROM attendances a "
                + "JOIN shift_schedules ss ON ss.id = a.shift_schedule_id "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "JOIN users u ON u.id = a.user_id "
                + "JOIN employee_profiles ep ON ep.user_id = a.user_id "
                + "JOIN branches b ON b.id = ss.branch_id "
                + "LEFT JOIN attendance_adjustment_history latest ON latest.id = ("
                + "SELECT MAX(history.id) FROM attendance_adjustment_history history "
                + "WHERE history.attendance_id = a.id) "
                + "LEFT JOIN users reviewer ON reviewer.id = latest.adjusted_by "
                + "WHERE ss.work_date BETWEEN ? AND ? "
                + "ORDER BY ss.work_date DESC, b.name, ep.full_name, s.start_time";

        List<Attendance> attendances = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, fromDate);
            statement.setDate(2, toDate);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Attendance attendance = mapAttendance(result);
                    attendance.setFullName(result.getString("full_name"));
                    attendance.setUsername(result.getString("username"));
                    attendance.setBranchName(result.getString("branch_name"));
                    attendance.setAdjustmentNote(result.getString("adjustment_note"));
                    attendance.setAdjustedBy(result.getString("adjusted_by_username"));
                    attendance.setAdjustedAt(result.getTimestamp("adjusted_at"));
                    attendances.add(attendance);
                }
            }
        } catch (Exception e) {
            throw new SQLException("Không thể tải báo cáo chấm công toàn hệ thống.", e);
        }
        return attendances;
    }

    public Attendance getAttendanceForHrById(int attendanceId) throws SQLException {
        String sql = "SELECT a.id, a.user_id, a.shift_schedule_id, ss.work_date, "
                + "s.name AS shift_name, s.start_time, s.end_time, a.check_in, a.check_out, a.status, "
                + "ep.full_name, u.username, b.name AS branch_name, latest.adjustment_note, "
                + "reviewer.username AS adjusted_by_username, latest.created_at AS adjusted_at "
                + "FROM attendances a "
                + "JOIN shift_schedules ss ON ss.id = a.shift_schedule_id "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "JOIN users u ON u.id = a.user_id "
                + "JOIN employee_profiles ep ON ep.user_id = a.user_id "
                + "JOIN branches b ON b.id = ss.branch_id "
                + "LEFT JOIN attendance_adjustment_history latest ON latest.id = ("
                + "SELECT MAX(history.id) FROM attendance_adjustment_history history "
                + "WHERE history.attendance_id = a.id) "
                + "LEFT JOIN users reviewer ON reviewer.id = latest.adjusted_by "
                + "WHERE a.id = ?";

        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, attendanceId);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) {
                    return null;
                }
                Attendance attendance = mapAttendance(result);
                attendance.setFullName(result.getString("full_name"));
                attendance.setUsername(result.getString("username"));
                attendance.setBranchName(result.getString("branch_name"));
                attendance.setAdjustmentNote(result.getString("adjustment_note"));
                attendance.setAdjustedBy(result.getString("adjusted_by_username"));
                attendance.setAdjustedAt(result.getTimestamp("adjusted_at"));
                return attendance;
            }
        } catch (Exception e) {
            throw new SQLException("Không thể tải bản ghi chấm công cần điều chỉnh.", e);
        }
    }

    public boolean adjustAttendance(int attendanceId, int hrUserId, LocalTime newCheckIn,
            LocalTime newCheckOut, String note) throws SQLException {
        if (newCheckIn == null && newCheckOut == null) {
            throw new IllegalArgumentException("Cần nhập ít nhất một giờ chấm công sau điều chỉnh.");
        }

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                Date workDate;
                Timestamp previousCheckIn;
                Timestamp previousCheckOut;
                String selectSql = "SELECT ss.work_date, a.check_in, a.check_out "
                        + "FROM attendances a JOIN shift_schedules ss ON ss.id = a.shift_schedule_id "
                        + "WHERE a.id = ? FOR UPDATE";
                try (PreparedStatement statement = connection.prepareStatement(selectSql)) {
                    statement.setInt(1, attendanceId);
                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            connection.rollback();
                            return false;
                        }
                        workDate = result.getDate("work_date");
                        previousCheckIn = result.getTimestamp("check_in");
                        previousCheckOut = result.getTimestamp("check_out");
                    }
                }

                Timestamp adjustedCheckIn = toTimestamp(workDate, newCheckIn);
                Timestamp adjustedCheckOut = toTimestamp(workDate, newCheckOut);
                if (adjustedCheckIn != null && adjustedCheckOut != null
                        && !adjustedCheckOut.after(adjustedCheckIn)) {
                    throw new IllegalArgumentException("Giờ ra sau điều chỉnh phải sau giờ vào.");
                }

                String updateSql = "UPDATE attendances SET check_in = ?, check_out = ?, status = 'ADJUSTED' "
                        + "WHERE id = ?";
                try (PreparedStatement statement = connection.prepareStatement(updateSql)) {
                    setNullableTimestamp(statement, 1, adjustedCheckIn);
                    setNullableTimestamp(statement, 2, adjustedCheckOut);
                    statement.setInt(3, attendanceId);
                    statement.executeUpdate();
                }

                String historySql = "INSERT INTO attendance_adjustment_history "
                        + "(attendance_id, adjusted_by, previous_check_in, previous_check_out, "
                        + "adjusted_check_in, adjusted_check_out, adjustment_note) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement statement = connection.prepareStatement(historySql)) {
                    statement.setInt(1, attendanceId);
                    statement.setInt(2, hrUserId);
                    setNullableTimestamp(statement, 3, previousCheckIn);
                    setNullableTimestamp(statement, 4, previousCheckOut);
                    setNullableTimestamp(statement, 5, adjustedCheckIn);
                    setNullableTimestamp(statement, 6, adjustedCheckOut);
                    statement.setString(7, note);
                    statement.executeUpdate();
                }
                connection.commit();
                return true;
            } catch (Exception e) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            }
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException("Không thể điều chỉnh dữ liệu chấm công.", e);
        }
    }

    private Timestamp toTimestamp(Date workDate, LocalTime time) {
        return time == null ? null : Timestamp.valueOf(workDate.toLocalDate().atTime(time));
    }

    private void setNullableTimestamp(PreparedStatement statement, int parameter, Timestamp value)
            throws SQLException {
        if (value == null) {
            statement.setNull(parameter, java.sql.Types.TIMESTAMP);
        } else {
            statement.setTimestamp(parameter, value);
        }
    }

    public void recordCheckIn(int userId, int shiftScheduleId, Date workDate) throws SQLException {
        String scheduleSql = "SELECT ss.id, s.end_time, a.id AS attendance_id, a.check_in "
                + "FROM shift_schedules ss "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "LEFT JOIN attendances a ON a.shift_schedule_id = ss.id AND a.user_id = ss.user_id "
                + "WHERE ss.id = ? AND ss.user_id = ? AND ss.work_date = ? "
                + "AND ss.status = 'PUBLISHED' FOR UPDATE";

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement statement = connection.prepareStatement(scheduleSql)) {
                    statement.setInt(1, shiftScheduleId);
                    statement.setInt(2, userId);
                    statement.setDate(3, workDate);
                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            throw new IllegalStateException("Không tìm thấy ca làm đã công bố trong ngày hôm nay.");
                        }
                        int attendanceId = result.getInt("attendance_id");
                        boolean attendanceMissing = result.wasNull();
                        Timestamp checkIn = result.getTimestamp("check_in");
                        if (checkIn != null) {
                            throw new IllegalStateException("Ca làm này đã được chấm công vào.");
                        }
                        if (result.getTime("end_time").toLocalTime().isBefore(
                                java.time.LocalTime.now(java.time.ZoneId.of("Asia/Ho_Chi_Minh")))) {
                            throw new IllegalStateException("Ca làm đã kết thúc, không thể chấm công vào.");
                        }

                        if (attendanceMissing) {
                            String insertSql = "INSERT INTO attendances "
                                    + "(user_id, shift_schedule_id, check_in, method, status) "
                                    + "VALUES (?, ?, CURRENT_TIMESTAMP, 'WEB', 'PENDING')";
                            try (PreparedStatement insert = connection.prepareStatement(insertSql)) {
                                insert.setInt(1, userId);
                                insert.setInt(2, shiftScheduleId);
                                insert.executeUpdate();
                            }
                        } else {
                            String updateSql = "UPDATE attendances SET check_in = CURRENT_TIMESTAMP "
                                    + "WHERE id = ? AND check_in IS NULL";
                            try (PreparedStatement update = connection.prepareStatement(updateSql)) {
                                update.setInt(1, attendanceId);
                                if (update.executeUpdate() != 1) {
                                    throw new IllegalStateException("Không thể cập nhật giờ chấm công vào.");
                                }
                            }
                        }
                    }
                }
                connection.commit();
            } catch (Exception e) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            }
        } catch (IllegalStateException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException("Không thể ghi nhận giờ chấm công vào.", e);
        }
    }

    public void recordCheckOut(int userId, int shiftScheduleId, Date workDate) throws SQLException {
        String sql = "UPDATE attendances a "
                + "JOIN shift_schedules ss ON ss.id = a.shift_schedule_id "
                + "SET a.check_out = CURRENT_TIMESTAMP "
                + "WHERE a.user_id = ? AND a.shift_schedule_id = ? AND ss.work_date = ? "
                + "AND ss.status = 'PUBLISHED' AND a.check_in IS NOT NULL AND a.check_out IS NULL "
                + "AND a.check_in <= CURRENT_TIMESTAMP";

        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setInt(2, shiftScheduleId);
            statement.setDate(3, workDate);
            if (statement.executeUpdate() != 1) {
                throw new IllegalStateException("Chưa chấm công vào hoặc ca làm đã được chấm công ra.");
            }
        } catch (IllegalStateException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException("Không thể ghi nhận giờ chấm công ra.", e);
        }
    }

    public boolean reviewAttendance(int attendanceId, int branchId, String status) throws SQLException {
        String sql = "UPDATE attendances a "
                + "JOIN shift_schedules ss ON ss.id = a.shift_schedule_id "
                + "SET a.status = ? WHERE a.id = ? AND (? = 0 OR ss.branch_id = ?)";
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setInt(2, attendanceId);
            statement.setInt(3, branchId);
            statement.setInt(4, branchId);
            return statement.executeUpdate() == 1;
        } catch (Exception e) {
            throw new SQLException("Không thể cập nhật kết quả duyệt chấm công.", e);
        }
    }

    private Attendance mapAttendance(ResultSet result) throws SQLException {
        Attendance attendance = new Attendance();
        attendance.setId(result.getInt("id"));
        attendance.setUserId(result.getInt("user_id"));
        attendance.setShiftScheduleId(result.getInt("shift_schedule_id"));
        attendance.setWorkDate(result.getDate("work_date"));
        attendance.setShiftName(result.getString("shift_name"));
        attendance.setShiftStart(result.getTime("start_time"));
        attendance.setShiftEnd(result.getTime("end_time"));
        attendance.setCheckIn(result.getTimestamp("check_in"));
        attendance.setCheckOut(result.getTimestamp("check_out"));
        attendance.setStatus(result.getString("status"));
        return attendance;
    }
}
