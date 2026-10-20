package dao;

import context.DBContext;
import java.sql.*;
import java.util.*;
import java.time.LocalDate;

public class ShiftChangeRequestDAO {

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    private List<Map<String, Object>> query(
            String sql, int value) {

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, value);

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();

                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    for (int i = 1; i <= meta.getColumnCount(); i++) {
                        row.put(
                                meta.getColumnLabel(i),
                                rs.getObject(i)
                        );
                    }
                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load shift data", e
            );
        }

        return result;
    }

    // 1. Lịch đã công bố của Employee
    public List<Map<String, Object>> getMySchedules(int userId) {

        String sql
                = "SELECT ss.id, ss.work_date AS workDate, "
                + "ss.branch_id AS branchId, "
                + "s.name AS shiftName, "
                + "s.start_time AS startTime, "
                + "s.end_time AS endTime "
                + "FROM shift_schedules ss "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "WHERE ss.user_id = ? "
                + "AND ss.status = 'PUBLISHED' "
                + "AND ss.work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) "
                + "ORDER BY ss.work_date, s.start_time";

        return query(sql, userId);
    }

    // 2. Ca đồng nghiệp cùng chi nhánh
    public List<Map<String, Object>> getColleagueSchedules(int userId) {

        String sql
                = "SELECT ss.id, "
                + "ss.user_id AS colleagueId, "
                + "ss.shift_id AS shiftId, "
                + "ss.position_id AS positionId, "
                + "ep.full_name AS colleagueName, "
                + "ss.work_date AS workDate, "
                + "s.name AS shiftName, "
                + "s.start_time AS startTime, "
                + "s.end_time AS endTime "
                + "FROM shift_schedules ss "
                + "JOIN users u ON u.id = ss.user_id "
                + "JOIN employee_profiles ep "
                + "ON ep.user_id = ss.user_id "
                + "JOIN employee_profiles current_ep "
                + "ON current_ep.user_id = ? "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "WHERE ss.branch_id = current_ep.home_branch_id "
                + "AND ss.position_id = current_ep.position_id "
                + "AND ss.user_id <> current_ep.user_id "
                + "AND u.role_id = 5 "
                + "AND u.status = 'ACTIVE' "
                + "AND ss.status = 'PUBLISHED' "
                + "AND ss.work_date >= DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) "
                + "ORDER BY ss.work_date, s.start_time, ep.full_name";

        return query(sql, userId);
    }

    private List<Map<String, Object>> queryTwo(
            String sql, int a, int b) {

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, a);
            ps.setInt(2, b);

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();

                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    for (int i = 1; i <= md.getColumnCount(); i++) {
                        row.put(
                                md.getColumnLabel(i),
                                rs.getObject(i)
                        );
                    }

                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load colleague schedules", e
            );
        }

        return result;
    }

    // 3. Ca trống do Store Manager tạo
    public List<Map<String, Object>> getOpenShifts(int userId) {

        String sql
                = "SELECT os.id, os.work_date AS workDate, "
                + "s.name AS shiftName, "
                + "s.start_time AS startTime, "
                + "s.end_time AS endTime, "
                + "b.name AS branchName "
                + "FROM open_shifts os "
                + "JOIN shifts s ON s.id = os.shift_id "
                + "JOIN branches b ON b.id = os.branch_id "
                + "WHERE os.status = 'OPEN' "
                + "AND os.work_date >= CURRENT_DATE() "
                + "AND os.branch_id IN ( "
                + "SELECT home_branch_id FROM employee_profiles "
                + "WHERE user_id = ?) "
                + "ORDER BY os.work_date, s.start_time";

        return query(sql, userId);
    }

    public boolean createSwap(
            int userId,
            int myScheduleId,
            int targetScheduleId,
            String reason) throws Exception {

        if (myScheduleId == targetScheduleId
                || reason == null
                || reason.trim().isEmpty()
                || reason.trim().length() > 255) {
            return false;
        }

        String sql
                = "INSERT INTO shift_change_requests "
                + "(requester_id, target_user_id, "
                + "shift_schedule_id, target_shift_schedule_id, "
                + "reason, status) "
                + "SELECT ?, theirs.user_id, mine.id, "
                + "theirs.id, ?, 'WAITING_COLLEAGUE' "
                + "FROM shift_schedules mine "
                + "JOIN shift_schedules theirs "
                + "ON mine.branch_id = theirs.branch_id "
                + "JOIN users requester "
                + "ON requester.id = mine.user_id "
                + "JOIN users colleague "
                + "ON colleague.id = theirs.user_id "
                + "WHERE mine.id = ? "
                + "AND theirs.id = ? "
                + "AND mine.user_id = ? "
                + "AND theirs.user_id <> mine.user_id "
                + "AND requester.role_id = 5 "
                + "AND colleague.role_id = 5 "
                + "AND requester.status = 'ACTIVE' "
                + "AND colleague.status = 'ACTIVE' "
                + "AND mine.status = 'PUBLISHED' "
                + "AND theirs.status = 'PUBLISHED' "
                + "AND mine.work_date >= "
                + "DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) "
                + "AND theirs.work_date >= "
                + "DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM shift_change_requests r "
                + "WHERE r.status IN "
                + "('WAITING_COLLEAGUE', 'PENDING') "
                + "AND ("
                + "r.shift_schedule_id IN (mine.id, theirs.id) "
                + "OR r.target_shift_schedule_id "
                + "IN (mine.id, theirs.id)"
                + "))";

        try (Connection conn = connect(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, reason.trim());
            ps.setInt(3, myScheduleId);
            ps.setInt(4, targetScheduleId);
            ps.setInt(5, userId);

            return ps.executeUpdate() == 1;
        }
    }

    // 5. Tạo đơn chuyển từ ca hiện tại sang ca trống
    public boolean createOpenChange(
            int userId,
            int myScheduleId,
            int openShiftId,
            String reason) throws Exception {

        String sql
                = "INSERT INTO shift_change_requests "
                + "(requester_id, shift_schedule_id, "
                + "request_type, open_shift_id, reason, status) "
                + "SELECT ?, mine.id, 'OPEN', os.id, ?, 'PENDING' "
                + "FROM shift_schedules mine "
                + "JOIN open_shifts os "
                + "ON os.branch_id = mine.branch_id "
                + "WHERE mine.id = ? AND os.id = ? "
                + "AND mine.user_id = ? "
                + "AND mine.status = 'PUBLISHED' "
                + "AND os.status = 'OPEN' "
                + "AND mine.work_date >= CURRENT_DATE() "
                + "AND os.work_date >= CURRENT_DATE() "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM shift_change_requests r "
                + "WHERE r.status = 'PENDING' "
                + "AND (r.shift_schedule_id = mine.id "
                + "OR r.open_shift_id = os.id))";

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, reason);
            ps.setInt(3, myScheduleId);
            ps.setInt(4, openShiftId);
            ps.setInt(5, userId);

            return ps.executeUpdate() > 0;
        }
    }

    // 6. Xem lịch sử của Employee
    public List<Map<String, Object>> getMyRequests(int userId) {
        // Tạm thời chưa tải lịch sử đơn vì database
        // chưa được cập nhật các cột mới.
        return new ArrayList<>();
    }

    // 7. Store Manager xem các đơn trong chi nhánh
    public List<Map<String, Object>> getBranchRequests(int branchId) {
        // Tạm thời chưa tải danh sách đơn
        // trong khi chờ cập nhật database.
        return new ArrayList<>();
    }

    // 8. Store Manager tạo ca trống
    public boolean createOpenShift(
            int branchId,
            int shiftId,
            int positionId,
            LocalDate date) throws Exception {

        String sql
                = "INSERT INTO open_shifts "
                + "(branch_id, shift_id, position_id, work_date, status) "
                + "VALUES (?, ?, ?, ?, 'OPEN')";

        if (!date.isAfter(LocalDate.now())) {
            return false;
        }

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, branchId);
            ps.setInt(2, shiftId);
            ps.setInt(3, positionId);
            ps.setDate(4, java.sql.Date.valueOf(date));

            return ps.executeUpdate() > 0;
        }
    }

    // 9. Store Manager xem ca trống của chi nhánh
    public List<Map<String, Object>> getBranchOpenShifts(int branchId) {

        String sql
                = "SELECT os.id, os.work_date AS workDate, "
                + "s.name AS shiftName, os.status "
                + "FROM open_shifts os "
                + "JOIN shifts s ON s.id = os.shift_id "
                + "WHERE os.branch_id = ? "
                + "ORDER BY os.work_date DESC";

        return query(sql, branchId);
    }

    // 10. Duyệt đơn và cập nhật lịch
    public boolean review(
            int requestId,
            int branchId,
            boolean approve,
            String responseText) throws Exception {

        try (Connection c = connect()) {
            c.setAutoCommit(false);

            try {
                String sql
                        = "SELECT r.request_type, r.requester_id, "
                        + "r.shift_schedule_id, "
                        + "r.target_user_id, r.target_shift_schedule_id, "
                        + "r.open_shift_id, r.status "
                        + "FROM shift_change_requests r "
                        + "JOIN shift_schedules ss "
                        + "ON ss.id = r.shift_schedule_id "
                        + "WHERE r.id = ? AND ss.branch_id = ? "
                        + "FOR UPDATE";

                String type;
                int requester;
                int myId;
                int targetId;
                int targetUser;
                int openId;

                try (PreparedStatement ps = c.prepareStatement(sql)) {
                    ps.setInt(1, requestId);
                    ps.setInt(2, branchId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()
                                || !"PENDING".equals(rs.getString("status"))) {
                            c.rollback();
                            return false;
                        }

                        type = rs.getString("request_type");
                        requester = rs.getInt("requester_id");
                        myId = rs.getInt("shift_schedule_id");
                        targetId = rs.getInt("target_shift_schedule_id");
                        targetUser = rs.getInt("target_user_id");
                        openId = rs.getInt("open_shift_id");
                    }
                }

                if (approve) {
                    if ("SWAP".equals(type)) {
                        if (!approveSwap(
                                c, branchId, myId, targetId,
                                requester, targetUser)) {
                            c.rollback();
                            return false;
                        }
                    } else if ("OPEN".equals(type)) {
                        if (!approveOpen(
                                c, branchId, myId, openId, requester)) {
                            c.rollback();
                            return false;
                        }
                    } else {
                        c.rollback();
                        return false;
                    }
                }

                String update
                        = "UPDATE shift_change_requests "
                        + "SET status = ?, response = ? "
                        + "WHERE id = ? AND status = 'PENDING'";

                try (PreparedStatement ps = c.prepareStatement(update)) {
                    ps.setString(1, approve ? "APPROVED" : "REJECTED");
                    ps.setString(2, responseText);
                    ps.setInt(3, requestId);

                    if (ps.executeUpdate() != 1) {
                        c.rollback();
                        return false;
                    }
                }

                c.commit();
                return true;

            } catch (Exception e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    private boolean approveSwap(
            Connection c, int branch, int myId,
            int targetId, int requester, int targetUser)
            throws SQLException {

        String sql
                = "SELECT id, user_id, branch_id, work_date, shift_id, "
                + "position_id, status "
                + "FROM shift_schedules WHERE id IN (?, ?) "
                + "ORDER BY id FOR UPDATE";

        Map<Integer, Integer> owners = new HashMap<>();
        Map<Integer, java.sql.Date> dates = new HashMap<>();
        Map<Integer, Integer> shiftIds = new HashMap<>();
        Map<Integer, Integer> positions = new HashMap<>();

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, myId);
            ps.setInt(2, targetId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("id");

                    if (rs.getInt("branch_id") != branch
                            || !"PUBLISHED".equals(rs.getString("status"))
                            || rs.getDate("work_date").toLocalDate()
                                    .isBefore(LocalDate.now())) {
                        return false;
                    }

                    owners.put(id, rs.getInt("user_id"));
                    dates.put(id, rs.getDate("work_date"));
                    shiftIds.put(id, rs.getInt("shift_id"));
                    positions.put(id, rs.getInt("position_id"));
                }
            }
        }

        if (owners.size() != 2
                || !Objects.equals(owners.get(myId), requester)
                || !Objects.equals(owners.get(targetId), targetUser)
                || requester == targetUser
                || Objects.equals(dates.get(myId), dates.get(targetId))
                && Objects.equals(shiftIds.get(myId), shiftIds.get(targetId))) {
            return false;
        }

        // Kiểm tra cả hai nhân viên không trùng ca mới
        if (hasConflict(c, requester, dates.get(targetId),
                shiftIds.get(targetId), myId)
                || hasConflict(c, targetUser, dates.get(myId),
                        shiftIds.get(myId), targetId)) {
            return false;
        }

        String update
                = "UPDATE shift_schedules SET user_id = ? WHERE id = ?";

        try (PreparedStatement ps = c.prepareStatement(update)) {
            ps.setInt(1, targetUser);
            ps.setInt(2, myId);
            if (ps.executeUpdate() != 1) {
                return false;
            }

            ps.setInt(1, requester);
            ps.setInt(2, targetId);
            return ps.executeUpdate() == 1;
        }
    }

    private boolean approveOpen(
            Connection c, int branch, int myId,
            int openId, int requester) throws SQLException {

        String lockMy
                = "SELECT user_id, branch_id, shift_id, work_date, "
                + "position_id, status "
                + "FROM shift_schedules WHERE id = ? FOR UPDATE";

        int oldShift, oldPosition;
        java.sql.Date oldDate;

        try (PreparedStatement ps = c.prepareStatement(lockMy)) {
            ps.setInt(1, myId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()
                        || rs.getInt("user_id") != requester
                        || rs.getInt("branch_id") != branch
                        || !"PUBLISHED".equals(rs.getString("status"))
                        || rs.getDate("work_date").toLocalDate()
                                .isBefore(LocalDate.now())) {
                    return false;
                }

                oldShift = rs.getInt("shift_id");
                oldDate = rs.getDate("work_date");
                oldPosition = rs.getInt("position_id");
            }
        }

        String lockOpen
                = "SELECT branch_id, shift_id, position_id, work_date, status "
                + "FROM open_shifts WHERE id = ? FOR UPDATE";

        int newShift, newPosition;
        java.sql.Date newDate;

        try (PreparedStatement ps = c.prepareStatement(lockOpen)) {
            ps.setInt(1, openId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()
                        || rs.getInt("branch_id") != branch
                        || !"OPEN".equals(rs.getString("status"))
                        || rs.getDate("work_date").toLocalDate()
                                .isBefore(LocalDate.now())) {
                    return false;
                }

                newShift = rs.getInt("shift_id");
                newDate = rs.getDate("work_date");
                newPosition = rs.getInt("position_id");
            }
        }

        if (hasConflict(c, requester, newDate, newShift, myId)) {
            return false;
        }

        // Chuyển bản ghi lịch hiện tại sang ca mới
        String update
                = "UPDATE shift_schedules "
                + "SET shift_id = ?, work_date = ?, position_id = ? "
                + "WHERE id = ? AND user_id = ?";

        try (PreparedStatement ps = c.prepareStatement(update)) {
            ps.setInt(1, newShift);
            ps.setDate(2, newDate);
            ps.setInt(3, newPosition);
            ps.setInt(4, myId);
            ps.setInt(5, requester);
            if (ps.executeUpdate() != 1) {
                return false;
            }
        }

        // Đóng ca trống vừa được nhận
        try (PreparedStatement ps = c.prepareStatement(
                "UPDATE open_shifts SET status = 'CLOSED' "
                + "WHERE id = ? AND status = 'OPEN'")) {
            ps.setInt(1, openId);
            if (ps.executeUpdate() != 1) {
                return false;
            }
        }

        // Mở lại ca cũ
        try (PreparedStatement ps = c.prepareStatement(
                "INSERT INTO open_shifts "
                + "(branch_id, shift_id, position_id, work_date, status) "
                + "VALUES (?, ?, ?, ?, 'OPEN')")) {

            ps.setInt(1, branch);
            ps.setInt(2, oldShift);

            if (oldPosition == 0) {
                ps.setNull(3, Types.INTEGER);
            } else {
                ps.setInt(3, oldPosition);
            }

            ps.setDate(4, oldDate);
            return ps.executeUpdate() == 1;
        }
    }

    // Kiểm tra trùng ca
    private boolean hasConflict(
            Connection c, int userId,
            java.sql.Date date, int shiftId, int ignoreId)
            throws SQLException {

        String sql
                = "SELECT COUNT(*) FROM shift_schedules "
                + "WHERE user_id = ? AND work_date = ? "
                + "AND shift_id = ? AND id <> ? "
                + "AND status = 'PUBLISHED'";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, date);
            ps.setInt(3, shiftId);
            ps.setInt(4, ignoreId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public List<Map<String, Object>> getPositions() {
        List<Map<String, Object>> result = new ArrayList<>();

        String sql = "SELECT id, title FROM positions ORDER BY title";

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("title", rs.getString("title"));
                result.add(row);
            }

        } catch (Exception e) {
            throw new IllegalStateException("Cannot load positions", e);
        }

        return result;
    }

    public List<Map<String, Object>> getAllShifts() {

        String sql
                = "SELECT id, name, "
                + "start_time AS startTime, "
                + "end_time AS endTime "
                + "FROM shifts "
                + "ORDER BY start_time";

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();

                row.put("id", rs.getInt("id"));
                row.put("name", rs.getString("name"));
                row.put("startTime", rs.getTime("startTime"));
                row.put("endTime", rs.getTime("endTime"));

                result.add(row);
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load shifts", e
            );
        }

        return result;
    }

    public List<Map<String, Object>> getEmployeesInShift(
            int shiftId,
            java.sql.Date workDate,
            int currentUserId) {

        List<Map<String, Object>> employees = new ArrayList<>();

        String sql
                = "SELECT ss.id AS scheduleId, "
                + "u.id AS userId, "
                + "ep.full_name AS fullName, "
                + "p.title AS positionName "
                + "FROM shift_schedules ss "
                + "JOIN users u ON u.id = ss.user_id "
                + "JOIN employee_profiles ep ON ep.user_id = u.id "
                + "LEFT JOIN positions p ON p.id = ss.position_id "
                + "WHERE ss.shift_id = ? "
                + "AND ss.work_date = ? "
                + "AND ss.branch_id IN ("
                + "SELECT home_branch_id "
                + "FROM employee_profiles "
                + "WHERE user_id = ?) "
                + "AND ss.user_id <> ? "
                + "AND u.role_id = 5 "
                + "AND u.status = 'ACTIVE' "
                + "AND ss.status = 'PUBLISHED' "
                + "AND ss.work_date >= "
                + "DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) "
                + "ORDER BY ep.full_name";

        try (Connection conn = connect(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, shiftId);
            ps.setDate(2, workDate);
            ps.setInt(3, currentUserId);
            ps.setInt(4, currentUserId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {

                    Map<String, Object> employee
                            = new LinkedHashMap<>();

                    employee.put(
                            "scheduleId",
                            rs.getInt("scheduleId")
                    );

                    employee.put(
                            "userId",
                            rs.getInt("userId")
                    );

                    employee.put(
                            "fullName",
                            rs.getString("fullName")
                    );

                    employee.put(
                            "positionName",
                            rs.getString("positionName")
                    );

                    employees.add(employee);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load employees in shift", e
            );
        }

        return employees;
    }

    public List<Map<String, Object>> getIncomingRequests(int userId) {

        String sql
                = "SELECT r.id, "
                + "r.requester_id AS requesterId, "
                + "ep.full_name AS requesterName, "
                + "r.reason, "
                + "r.status, "
                + "mine.work_date AS requesterDate, "
                + "ms.name AS requesterShift, "
                + "theirs.work_date AS myDate, "
                + "ts.name AS myShift "
                + "FROM shift_change_requests r "
                + "JOIN shift_schedules mine "
                + "ON mine.id = r.shift_schedule_id "
                + "JOIN shift_schedules theirs "
                + "ON theirs.id = r.target_shift_schedule_id "
                + "JOIN shifts ms "
                + "ON ms.id = mine.shift_id "
                + "JOIN shifts ts "
                + "ON ts.id = theirs.shift_id "
                + "JOIN employee_profiles ep "
                + "ON ep.user_id = r.requester_id "
                + "WHERE r.target_user_id = ? "
                + "AND r.status = 'WAITING_COLLEAGUE' "
                + "ORDER BY r.id DESC";

        return query(sql, userId);
    }

    public boolean respondToSwap(
            int requestId,
            int colleagueId,
            boolean accepted,
            String message) throws Exception {

        if (message != null && message.length() > 255) {
            return false;
        }

        String newStatus = accepted ? "PENDING" : "DECLINED";

        String sql
                = "UPDATE shift_change_requests r "
                + "JOIN shift_schedules mine "
                + "ON mine.id = r.shift_schedule_id "
                + "JOIN shift_schedules theirs "
                + "ON theirs.id = r.target_shift_schedule_id "
                + "JOIN users requester "
                + "ON requester.id = r.requester_id "
                + "JOIN users colleague "
                + "ON colleague.id = r.target_user_id "
                + "SET r.status = ?, "
                + "r.colleague_response = ?, "
                + "r.colleague_responded_at = NOW() "
                + "WHERE r.id = ? "
                + "AND r.target_user_id = ? "
                + "AND r.status = 'WAITING_COLLEAGUE' "
                + "AND mine.user_id = r.requester_id "
                + "AND theirs.user_id = r.target_user_id "
                + "AND mine.branch_id = theirs.branch_id "
                + "AND mine.status = 'PUBLISHED' "
                + "AND theirs.status = 'PUBLISHED' "
                + "AND requester.role_id = 5 "
                + "AND colleague.role_id = 5 "
                + "AND requester.status = 'ACTIVE' "
                + "AND colleague.status = 'ACTIVE' "
                + "AND mine.work_date >= "
                + "DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY) "
                + "AND theirs.work_date >= "
                + "DATE_ADD(CURRENT_DATE(), INTERVAL 2 DAY)";

        try (Connection conn = connect(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setString(2, message);
            ps.setInt(3, requestId);
            ps.setInt(4, colleagueId);

            return ps.executeUpdate() == 1;
        }
    }

    public List<Map<String, Object>> getDepartmentSchedules(
            int userId,
            java.time.LocalDate weekStart) {

        String sql
                = "SELECT ss.id, "
                + "ss.user_id AS employeeId, "
                + "ep.full_name AS employeeName, "
                + "ss.shift_id AS shiftId, "
                + "ss.work_date AS workDate, "
                + "ss.position_id AS positionId, "
                + "s.name AS shiftName, "
                + "s.start_time AS startTime, "
                + "s.end_time AS endTime "
                + "FROM shift_schedules ss "
                + "JOIN employee_profiles current_ep "
                + "ON current_ep.user_id = ? "
                + "JOIN employee_profiles ep "
                + "ON ep.user_id = ss.user_id "
                + "JOIN users u ON u.id = ss.user_id "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "WHERE ss.branch_id = current_ep.home_branch_id "
                + "AND ss.position_id = current_ep.position_id "
                + "AND ss.status = 'PUBLISHED' "
                + "AND u.role_id = 5 "
                + "AND ss.work_date BETWEEN ? AND ? "
                + "ORDER BY ss.work_date, s.start_time, ep.full_name";

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(weekStart));
            ps.setDate(3, java.sql.Date.valueOf(
                    weekStart.plusDays(6)));

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();

                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();

                    for (int i = 1; i <= md.getColumnCount(); i++) {
                        row.put(
                                md.getColumnLabel(i),
                                rs.getObject(i)
                        );
                    }

                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load department schedules", e
            );
        }

        return result;
    }
}
