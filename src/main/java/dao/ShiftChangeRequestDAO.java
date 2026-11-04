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

    /**
     * Truy vấn với 1 tham số int và 2 tham số ngày (LocalDate).
     */
    private List<Map<String, Object>> query(
            String sql, int value,
            LocalDate from, LocalDate to) {

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, value);
            ps.setDate(2, java.sql.Date.valueOf(from));
            ps.setDate(3, java.sql.Date.valueOf(to));

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
    //
    // Chỉ trả về ca nằm trong TUẦN ĐANG XEM (weekStart..weekStart+6).
    // Nhân viên chỉ được đổi ca trong tuần đang xem trên màn hình.
    public List<Map<String, Object>> getMySchedules(
            int userId, LocalDate weekStart) {

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
                + "AND ss.work_date BETWEEN ? AND ? "
                + "AND ss.work_date >= CURRENT_DATE() "
                + "ORDER BY ss.work_date, s.start_time";

        return query(sql, userId, weekStart, weekStart.plusDays(6));
    }

    // 2. Ca đồng nghiệp cùng chi nhánh, CÙNG CHỨC VỤ
    //    và CÙNG NHÓM LÀM VIỆC
    //
    // Quy tắc nghiệp vụ:
    //   - Nhân viên chỉ được đổi ca với đồng nghiệp có CÙNG CHỨC VỤ
    //     (position_id trong employee_profiles).
    //   - FULL_TIME chỉ đổi được với FULL_TIME.
    //     PART_TIME (và CASUAL) chỉ đổi được với PART_TIME (CASUAL).
    //
    // Chú ý: phải so sánh theo CHỨC VỤ THỰC của đồng nghiệp
    // (their_ep.position_id), KHÔNG so sánh theo position_id của
    // dòng lịch (ss.position_id) - vì dòng lịch có thể đã bị Store
    // xếp sai chức vụ (dữ liệu thực tế có 9 dòng lệch).
    public List<Map<String, Object>> getColleagueSchedules(
            int userId, LocalDate weekStart) {

        String sql
                = "SELECT ss.id, "
                + "ss.user_id AS colleagueId, "
                + "ss.shift_id AS shiftId, "
                + "ss.position_id AS positionId, "
                + "ep.full_name AS colleagueName, "
                + "ep.employee_type AS colleagueType, "
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
                + "AND ep.position_id = current_ep.position_id "
                + "AND COALESCE(ep.employee_type, 'FULL_TIME') = "
                + "COALESCE(current_ep.employee_type, 'FULL_TIME') "
                + "AND ss.user_id <> current_ep.user_id "
                + "AND u.role_id = 5 "
                + "AND u.status = 'ACTIVE' "
                + "AND ss.status = 'PUBLISHED' "
                + "AND ss.work_date BETWEEN ? AND ? "
                + "AND ss.work_date >= CURRENT_DATE() "
                + "ORDER BY ss.work_date, s.start_time, ep.full_name";

        return query(sql, userId, weekStart, weekStart.plusDays(6));
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

    /**
     * Truy vấn với 2 tham số int + 1 khoảng ngày (from, to).
     */
    private List<Map<String, Object>> query2(
            String sql, int a, int b,
            LocalDate from, LocalDate to) {

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, a);
            ps.setInt(2, b);
            ps.setDate(3, java.sql.Date.valueOf(from));
            ps.setDate(4, java.sql.Date.valueOf(to));

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
                    "Cannot load available extra shifts", e
            );
        }

        return result;
    }

    // 3. Ca trống do Store Manager tạo
    // Chỉ trả về ca trống:
    //   - ở cơ sở của nhân viên,
    //   - đúng vị trí công tác của nhân viên (nếu ca có gán vị trí),
    //   - trong TUẦN ĐANG XEM,
    //   - chưa có đơn đổi ca nào đang chờ duyệt.
    public List<Map<String, Object>> getOpenShifts(
            int userId, LocalDate weekStart) {

        String sql
                = "SELECT os.id, os.work_date AS workDate, "
                + "s.name AS shiftName, "
                + "s.start_time AS startTime, "
                + "s.end_time AS endTime, "
                + "b.name AS branchName "
                + "FROM open_shifts os "
                + "JOIN shifts s ON s.id = os.shift_id "
                + "JOIN branches b ON b.id = os.branch_id "
                + "JOIN employee_profiles ep "
                + "ON ep.user_id = ? "
                + "WHERE os.status = 'OPEN' "
                + "AND os.work_date BETWEEN ? AND ? "
                + "AND os.work_date >= "
                + "CURRENT_DATE() "
                + "AND os.branch_id = ep.home_branch_id "
                + "AND (ep.position_id IS NULL "
                + "OR os.position_id = ep.position_id) "
                // Ca trống gắn đơn nghỉ phép đã hủy/thu hồi thì không
                // còn ai làm việc ở ca đó -> không cho nhận.
                + "AND NOT EXISTS (SELECT 1 FROM leave_requests lr "
                + "WHERE lr.id = os.leave_request_id "
                + "AND lr.status <> 'APPROVED') "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM shift_change_requests r "
                + "WHERE r.open_shift_id = os.id "
                + "AND r.status = 'PENDING') "
                + "ORDER BY os.work_date, s.start_time";

        return query(sql, userId, weekStart, weekStart.plusDays(6));
    }

    /**
     * Danh sách ca trống mà nhân viên có thể ĐĂNG KÝ NHẬN THÊM.
     *
     * <p>Khác {@link #getOpenShifts} ở chỗ:
     * <ul>
     *   <li>Hiển thị cả ca trống phát sinh từ đơn nghỉ phép
     *       (người nghỉ) lẫn ca trống do Store tạo.</li>
     *   <li>Trả về thêm thông tin người nghỉ (từ {@code leave_requests})
     *       để nhân viên biết ca đó của ai.</li>
     *   <li>Đánh dấu ca đã có đơn PENDING và ca chồng giờ.</li>
     * </ul>
     */
    public List<Map<String, Object>> getAvailableExtraShifts(
            int userId, LocalDate weekStart) {

        String sql
                = "SELECT os.id, os.work_date AS workDate, "
                + "s.name AS shiftName, "
                + "s.start_time AS startTime, "
                + "s.end_time AS endTime, "
                + "b.name AS branchName, "
                + "p.title AS positionTitle, "
                + "COALESCE(ep.full_name, 'Đồng nghiệp') AS onLeaveName, "
                + "EXISTS(SELECT 1 FROM shift_change_requests r "
                + "WHERE r.open_shift_id = os.id AND r.status = 'PENDING') "
                + "AS alreadyRequested, "
                + "EXISTS(SELECT 1 FROM shift_schedules ss "
                + "JOIN shifts s2 ON s2.id = ss.shift_id "
                + "WHERE ss.user_id = ? AND ss.work_date = os.work_date "
                + "AND ss.status = 'PUBLISHED' "
                + "AND s2.start_time < s.end_time "
                + "AND s2.end_time > s.start_time) AS timeConflict "
                + "FROM open_shifts os "
                + "JOIN shifts s ON s.id = os.shift_id "
                + "JOIN branches b ON b.id = os.branch_id "
                + "JOIN positions p ON p.id = os.position_id "
                + "LEFT JOIN leave_requests lr "
                + "ON lr.id = os.leave_request_id "
                + "LEFT JOIN employee_profiles ep "
                + "ON ep.user_id = lr.user_id "
                + "JOIN employee_profiles myep "
                + "ON myep.user_id = ? "
                + "WHERE os.status = 'OPEN' "
                + "AND os.work_date BETWEEN ? AND ? "
                + "AND os.work_date >= "
                + "CURRENT_DATE() "
                + "AND os.branch_id = myep.home_branch_id "
                + "AND (myep.position_id IS NULL "
                + "OR os.position_id = myep.position_id) "
                // Ca trống gắn đơn nghỉ phép đã bị hủy/thu hồi thì
                // không còn ai làm việc ở ca đó -> không cho nhận.
                + "AND (lr.id IS NULL OR lr.status = 'APPROVED') "
                + "ORDER BY os.work_date, s.start_time";

        return query2(sql, userId, userId, weekStart, weekStart.plusDays(6));
    }

    public boolean createSwap(
            int userId,
            int myScheduleId,
            int targetScheduleId,
            String reason,
            LocalDate weekStart) throws Exception {

        if (myScheduleId == targetScheduleId
                || reason == null
                || reason.trim().isEmpty()
                || reason.trim().length() > 255) {
            return false;
        }

        // Chặn trước 2 ca chồng lấn giờ trong cùng ngày và các
        // LAM VIEC, CUNG TUAN).
        if (!canSwapShifts(userId, myScheduleId, targetScheduleId, weekStart)) {
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
                + "JOIN employee_profiles mine_ep "
                + "ON mine_ep.user_id = mine.user_id "
                + "JOIN employee_profiles their_ep "
                + "ON their_ep.user_id = theirs.user_id "
                + "JOIN users requester "
                + "ON requester.id = mine.user_id "
                + "JOIN users colleague "
                + "ON colleague.id = theirs.user_id "
                + "WHERE mine.id = ? "
                + "AND theirs.id = ? "
                + "AND mine.user_id = ? "
                + "AND theirs.user_id <> mine.user_id "
                + "AND mine_ep.position_id = their_ep.position_id "
                + "AND COALESCE(mine_ep.employee_type, 'FULL_TIME') = "
                + "COALESCE(their_ep.employee_type, 'FULL_TIME') "
                + "AND requester.role_id = 5 "
                + "AND colleague.role_id = 5 "
                + "AND requester.status = 'ACTIVE' "
                + "AND colleague.status = 'ACTIVE' "
                + "AND mine.status = 'PUBLISHED' "
                + "AND theirs.status = 'PUBLISHED' "
                // Cả hai ca phải nằm trong TUẦN ĐANG XEM.
                + "AND mine.work_date BETWEEN ? AND ? "
                + "AND theirs.work_date BETWEEN ? AND ? "
                + "AND mine.work_date >= "
                + "CURRENT_DATE() "
                + "AND theirs.work_date >= "
                + "CURRENT_DATE() "
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
            ps.setDate(6, java.sql.Date.valueOf(weekStart));
            ps.setDate(7, java.sql.Date.valueOf(weekStart.plusDays(6)));
            ps.setDate(8, java.sql.Date.valueOf(weekStart));
            ps.setDate(9, java.sql.Date.valueOf(weekStart.plusDays(6)));

            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Hai ca có thể đổi cho nhau được không?
     *
     * <h3>Điều kiện</h3>
     * <ul>
     *   <li>Cùng chi nhánh.</li>
     *   <li><b>Cùng chức vụ</b> (employee_profiles.position_id).</li>
     *   <li><b>Cùng nhóm làm việc</b>: FULL_TIME chỉ đổi với FULL_TIME,
     *       PART_TIME chỉ đổi với PART_TIME.</li>
     *   <li>Không cùng một ngày VÀ chồng lấn khung giờ -&gt;
     *       nếu không, sau khi đổi mỗi người sẽ có 2 ca chồng nhau.</li>
     *   <li>Cả hai ca phải còn hiệu lực (không nằm trong quá khứ).</li>
     *   <li><b>Cung tuần</b>: ca cua toi va ca cua dong nghiep phai
     *       cung nam trong tuan dang xem.</li>
     * </ul>
     */
    public boolean canSwapShifts(
            int userId,
            int myScheduleId,
            int targetScheduleId,
            LocalDate weekStart) throws Exception {

        if (myScheduleId == targetScheduleId) {
            return false;
        }

        String sql
                = "SELECT mine.work_date AS myDate, mine.shift_id AS myShift, "
                + "theirs.work_date AS theirDate, theirs.shift_id AS theirShift "
                + "FROM shift_schedules mine "
                + "JOIN shift_schedules theirs ON theirs.id = ? "
                + "JOIN employee_profiles current_ep "
                + "  ON current_ep.user_id = ? "
                + "JOIN employee_profiles their_ep "
                + "  ON their_ep.user_id = theirs.user_id "
                + "JOIN users colleague ON colleague.id = theirs.user_id "
                + "WHERE mine.id = ? "
                + "AND mine.branch_id = theirs.branch_id "
                + "AND mine.branch_id = current_ep.home_branch_id "
                + "AND current_ep.position_id = their_ep.position_id "
                + "AND COALESCE(current_ep.employee_type, 'FULL_TIME') = "
                + "COALESCE(their_ep.employee_type, 'FULL_TIME') "
                + "AND theirs.user_id <> current_ep.user_id "
                + "AND colleague.role_id = 5 "
                + "AND colleague.status = 'ACTIVE' "
                + "AND mine.status = 'PUBLISHED' "
                + "AND theirs.status = 'PUBLISHED' "
                // Cả hai ca phải nằm trong TUẦN ĐANG XEM.
                + "AND mine.work_date BETWEEN ? AND ? "
                + "AND theirs.work_date BETWEEN ? AND ? "
                + "AND mine.work_date >= "
                + "CURRENT_DATE() "
                + "AND theirs.work_date >= "
                + "CURRENT_DATE()";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, targetScheduleId);
            ps.setInt(2, userId);
            ps.setInt(3, myScheduleId);
            ps.setDate(4, java.sql.Date.valueOf(weekStart));
            ps.setDate(5, java.sql.Date.valueOf(weekStart.plusDays(6)));
            ps.setDate(6, java.sql.Date.valueOf(weekStart));
            ps.setDate(7, java.sql.Date.valueOf(weekStart.plusDays(6)));

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }

                java.sql.Date myDate = rs.getDate("myDate");
                int myShift = rs.getInt("myShift");
                java.sql.Date theirDate = rs.getDate("theirDate");
                int theirShift = rs.getInt("theirShift");

                // Không cho đổi 2 ca chồng lấn giờ trong cùng ngày.
                return !overlapsSameDay(c,
                        myDate, myShift, theirDate, theirShift);
            }
        }
    }

    // 5. Tạo đơn chuyển từ ca hiện tại sang ca trống
    //
    // Ca của nhân viên và ca trống phải cùng nằm trong TUẦN ĐANG XEM.
    public boolean createOpenChange(
            int userId,
            int myScheduleId,
            int openShiftId,
            String reason,
            LocalDate weekStart) throws Exception {
        String sql
                = "INSERT INTO shift_change_requests "
                + "(requester_id, shift_schedule_id, "
                + "request_type, open_shift_id, reason, status) "
                + "SELECT ?, mine.id, 'OPEN', os.id, ?, 'PENDING' "
                + "FROM shift_schedules mine "
                + "JOIN open_shifts os "
                + "ON os.branch_id = mine.branch_id "
                + "JOIN users requester "
                + "ON requester.id = mine.user_id "
                + "WHERE mine.id = ? AND os.id = ? "
                + "AND mine.user_id = ? "
                + "AND requester.role_id = 5 "
                + "AND requester.status = 'ACTIVE' "
                + "AND mine.status = 'PUBLISHED' "
                + "AND os.status = 'OPEN' "
                + "AND mine.work_date BETWEEN ? AND ? "
                + "AND os.work_date BETWEEN ? AND ? "
                + "AND mine.work_date >= "
                + "CURRENT_DATE() "
                + "AND os.work_date >= "
                + "CURRENT_DATE() "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM shift_change_requests r "
                + "WHERE r.status = 'PENDING' "
                + "AND (r.shift_schedule_id = mine.id "
                + "OR r.open_shift_id = os.id))";

        if (reason == null
                || reason.trim().isEmpty()
                || reason.trim().length() > 255) {
            return false;
        }

        // Chặn trước: ca mới không được chồng lấn khung giờ với ca
        // đang có của nhân viên trong cùng ngày.
        if (!canTakeOpenShift(userId, myScheduleId, openShiftId)) {
            return false;
        }

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, reason.trim());
            ps.setInt(3, myScheduleId);
            ps.setInt(4, openShiftId);
            ps.setInt(5, userId);
            ps.setDate(6, java.sql.Date.valueOf(weekStart));
            ps.setDate(7, java.sql.Date.valueOf(weekStart.plusDays(6)));
            ps.setDate(8, java.sql.Date.valueOf(weekStart));
            ps.setDate(9, java.sql.Date.valueOf(weekStart.plusDays(6)));

            return ps.executeUpdate() > 0;
        }
    }

    // 5b. Nhân viên ĐĂNG KÝ NHẬN THÊM ca trống (EXTRA)
    //
    // Khác với "chuyển sang ca trống" (OPEN):
    //   - OPEN  : nhân viên MẤT ca cũ, được chuyển sang ca trống.
    //   - EXTRA : nhân viên GIỮ NGUYÊN lịch cũ, chỉ được THÊM ca trống.
    //
    // Vì không mất ca nào nên đơn EXTRA không có `shift_schedule_id`
    // (để NULL).
    //
    // Điều kiện:
    //   - Nhân viên part-time (role_id = 5) đang ACTIVE.
    //   - Ca trống đang OPEN, thuộc cơ sở của nhân viên, khớp vị trí.
    //   - Ca trống nằm trong tuần đang xem và không nằm trong quá khứ.
    //   - Ca trống KHÔNG chồng lấn khung giờ với ca đang có của
    //     nhân viên trong cùng ngày.
    //   - Chưa có ai đăng ký ca trống này (đơn PENDING).
    public boolean createExtraShift(
            int userId,
            int openShiftId,
            String reason,
            LocalDate weekStart) throws Exception {

        if (reason == null
                || reason.trim().isEmpty()
                || reason.trim().length() > 255) {
            return false;
        }

        if (userId <= 0 || openShiftId <= 0 || weekStart == null) {
            return false;
        }

        // Chặn trước: ca trống phải hợp lệ với nhân viên và không
        // chồng lấn giờ với ca đang có.
        if (!canTakeExtraShift(userId, openShiftId, weekStart)) {
            return false;
        }

        String sql
                = "INSERT INTO shift_change_requests "
                + "(requester_id, shift_schedule_id, "
                + "request_type, open_shift_id, reason, status) "
                + "SELECT ?, NULL, 'EXTRA', os.id, ?, 'PENDING' "
                + "FROM open_shifts os "
                + "JOIN employee_profiles ep ON ep.user_id = ? "
                + "JOIN users requester ON requester.id = ep.user_id "
                + "WHERE os.id = ? "
                + "AND requester.role_id = 5 "
                + "AND requester.status = 'ACTIVE' "
                + "AND os.status = 'OPEN' "
                + "AND os.branch_id = ep.home_branch_id "
                + "AND (ep.position_id IS NULL "
                + "OR os.position_id = ep.position_id) "
                + "AND os.work_date BETWEEN ? AND ? "
                + "AND os.work_date >= "
                + "CURRENT_DATE() "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM leave_requests lr "
                + "WHERE lr.id = os.leave_request_id "
                + "AND lr.status <> 'APPROVED') "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM shift_change_requests r "
                + "WHERE r.open_shift_id = os.id "
                + "AND r.status = 'PENDING')";

        try (Connection c = connect(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, reason.trim());
            ps.setInt(3, userId);
            ps.setInt(4, openShiftId);
            ps.setDate(5, java.sql.Date.valueOf(weekStart));
            ps.setDate(6, java.sql.Date.valueOf(weekStart.plusDays(6)));

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Nhân viên có thể nhận thêm ca trống này không?
     *
     * <p>Khác {@link #canTakeOpenShift} ở chỗ: không so với một ca cũ
     * cụ thể, mà so với TẤT CẢ các ca đang có của nhân viên trong
     * ngày của ca trống. Nếu nhân viên đã có ca chiều trong ngày đó
     * thì không được nhận thêm ca tối (tránh làm quá giờ, tránh
     * chồng lấn).
     */
    private boolean canTakeExtraShift(
            int userId, int openShiftId, LocalDate weekStart)
            throws Exception {

        String sql
                = "SELECT os.work_date AS openDate, os.shift_id AS openShift "
                + "FROM open_shifts os "
                + "JOIN employee_profiles ep ON ep.user_id = ? "
                + "JOIN users requester ON requester.id = ep.user_id "
                + "WHERE os.id = ? "
                + "AND requester.role_id = 5 "
                + "AND requester.status = 'ACTIVE' "
                + "AND os.status = 'OPEN' "
                + "AND os.branch_id = ep.home_branch_id "
                + "AND (ep.position_id IS NULL "
                + "OR os.position_id = ep.position_id) "
                + "AND os.work_date BETWEEN ? AND ? "
                + "AND os.work_date >= "
                + "CURRENT_DATE() "
                + "AND NOT EXISTS (SELECT 1 FROM leave_requests lr "
                + "WHERE lr.id = os.leave_request_id "
                + "AND lr.status <> 'APPROVED')";

        java.sql.Date openDate;
        int openShift;

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, openShiftId);
            ps.setDate(3, java.sql.Date.valueOf(weekStart));
            ps.setDate(4, java.sql.Date.valueOf(weekStart.plusDays(6)));

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                openDate = rs.getDate("openDate");
                openShift = rs.getInt("openShift");
            }
        }

        // Ca trống phải nằm trong tuần đang xem.
        if (openDate == null
                || !sameWeek(openDate, java.sql.Date.valueOf(weekStart))) {
            return false;
        }

        // Không được nhận thêm ca nếu đã có ca chồng lấn khung giờ
        // trong cùng ngày.
        return !hasConflictWithOwnSchedule(
                userId, openDate, openShift);
    }

    /**
     * Nhân viên đã có ca chồng lấn khung giờ với ca (ngày, ca) này chưa?
     *
     * <p>Không tính ca đang ON_LEAVE (nhân viên nghỉ phép ở ca đó thì
     * không xung đột giờ với ca nhận thêm).
     */
    private boolean hasConflictWithOwnSchedule(
            int userId, java.sql.Date date, int shiftId)
            throws Exception {

        String sql
                = "SELECT COUNT(*) FROM shift_schedules ss "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "WHERE ss.user_id = ? AND ss.work_date = ? "
                + "AND ss.status = 'PUBLISHED' "
                + "AND s.start_time < (SELECT end_time FROM shifts WHERE id = ?) "
                + "AND s.end_time > (SELECT start_time FROM shifts WHERE id = ?)";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setDate(2, date);
            ps.setInt(3, shiftId);
            ps.setInt(4, shiftId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Nhân viên đang có đơn nghỉ phép ĐÃ DUYỆT trong ngày này không?
     * Dùng để chặn việc giao ca cho nhân viên đang nghỉ.
     *
     * <h3>Phân biệt full-time và part-time</h3>
     * <ul>
     *   <li>Đơn có chi tiết ca ({@code leave_request_shifts}) ->
     *       nhân viên nghỉ đúng những ca đó. Chỉ chặn nếu ca cần
     *       giao CHỒNG LẤN với ca đã nghỉ (ví dụ nghỉ "Ca Sáng"
     *       07:00-12:00 thì vẫn có thể nhận "Ca Chiều" 12:00-17:00).</li>
     *   <li>Đơn không có chi tiết ca (full-time nghỉ trọn ngày) ->
     *       chặn toàn bộ ngày trong khoảng start_date..end_date.</li>
     * </ul>
     *
     * @param userId  nhân viên
     * @param workDate ngày sắp giao ca
     * @param shiftId  ca sắp giao (dùng để so khung giờ)
     */
    private boolean isOnApprovedLeave(
            int userId,
            java.sql.Date workDate,
            int shiftId) throws SQLException {

        // 1. Đơn nghỉ trọn ngày (không có chi tiết ca) -> chặn cả ngày.
        String wholeDay
                = "SELECT COUNT(*) FROM leave_requests lr "
                + "WHERE lr.user_id = ? AND lr.status = 'APPROVED' "
                + "AND lr.start_date <= ? AND lr.end_date >= ? "
                + "AND NOT EXISTS ("
                + "SELECT 1 FROM leave_request_shifts lrs "
                + "WHERE lrs.leave_request_id = lr.id)";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(wholeDay)) {
            ps.setInt(1, userId);
            ps.setDate(2, workDate);
            ps.setDate(3, workDate);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return true;
                }
            }
        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException(
                    "Không kiểm tra được đơn nghỉ phép", e);
        }

        // 2. Đơn có chi tiết ca -> chỉ chặn nếu ca chồng lấn khung giờ.
        String byShift
                = "SELECT COUNT(*) FROM leave_request_shifts lrs "
                + "JOIN leave_requests lr "
                + "  ON lr.id = lrs.leave_request_id "
                + "JOIN shifts s ON s.id = lrs.shift_id "
                + "WHERE lr.user_id = ? AND lr.status = 'APPROVED' "
                + "AND lrs.work_date = ? "
                + "AND s.start_time < (SELECT end_time FROM shifts WHERE id = ?) "
                + "AND s.end_time > (SELECT start_time FROM shifts WHERE id = ?)";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(byShift)) {
            ps.setInt(1, userId);
            ps.setDate(2, workDate);
            ps.setInt(3, shiftId);
            ps.setInt(4, shiftId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw e;
        } catch (Exception e) {
            throw new SQLException(
                    "Không kiểm tra được đơn nghỉ phép", e);
        }
    }

    // 6. Xem lịch sử của Employee
    public List<Map<String, Object>> getMyRequests(int userId) {
        String sql
                = "SELECT r.id, r.request_type AS requestType, "
                + "mine.work_date AS myDate, "
                + "ms.name AS myShift, "
                + "COALESCE(target.work_date, os.work_date) AS targetDate, "
                + "COALESCE(ts.name, os2.name) AS targetShift, "
                + "ep.full_name AS colleagueName, "
                + "r.reason, r.status, r.response, "
                + "r.colleague_response AS colleagueResponse "
                + "FROM shift_change_requests r "
                + "LEFT JOIN shift_schedules mine "
                + "ON mine.id = r.shift_schedule_id "
                + "LEFT JOIN shifts ms ON ms.id = mine.shift_id "
                + "LEFT JOIN shift_schedules target "
                + "ON target.id = r.target_shift_schedule_id "
                + "LEFT JOIN shifts ts ON ts.id = target.shift_id "
                + "LEFT JOIN open_shifts os "
                + "ON os.id = r.open_shift_id "
                + "LEFT JOIN shifts os2 ON os2.id = os.shift_id "
                + "LEFT JOIN users u ON u.id = r.target_user_id "
                + "LEFT JOIN employee_profiles ep "
                + "ON ep.user_id = r.target_user_id "
                + "WHERE r.requester_id = ? "
                + "ORDER BY r.id DESC";

        return query(sql, userId);
    }

    // 6b. Employee: Đếm số đơn đổi ca đang chờ duyệt của tôi
    public int countMyPendingShiftRequests(int userId) {
        String sql
                = "SELECT COUNT(*) FROM shift_change_requests "
                + "WHERE requester_id = ? AND status = 'PENDING'";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot count shift requests", e);
        }

        return 0;
    }

    // 6b-2. Employee: Đếm số đơn đổi ca đang chờ MÌNH phản hồi
    // (đồng nghiệp gửi tới, chưa trả lời -> status WAITING_COLLEAGUE).
    public int countIncomingShiftRequests(int userId) {
        String sql
                = "SELECT COUNT(*) FROM shift_change_requests "
                + "WHERE target_user_id = ? "
                + "AND request_type = 'SWAP' "
                + "AND status = 'WAITING_COLLEAGUE'";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot count incoming shift requests", e);
        }

        return 0;
    }

    // 6c. Employee: Hủy đơn đổi ca của mình
    // Chỉ hủy được khi đơn còn chờ (WAITING_COLLEAGUE hoặc PENDING).
    // Đơn đã được đồng nghiệp từ chối (DECLINED) hoặc quyết định
    // (APPROVED/REJECTED) thì không hủy được nữa.
    public boolean cancelMyRequest(int requestId, int userId) {

        String sql
                = "UPDATE shift_change_requests "
                + "SET status = 'CANCELLED' "
                + "WHERE id = ? AND requester_id = ? "
                + "AND status IN ('WAITING_COLLEAGUE', 'PENDING')";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot cancel shift change request", e);
        }
    }

    // 7. Store Manager xem các đơn trong chi nhánh
    public List<Map<String, Object>> getBranchRequests(int branchId) {
        String sql
                = "SELECT r.id, r.request_type AS requestType, "
                + "req_ep.full_name AS employeeName, "
                + "mine.work_date AS myDate, "
                + "ms.name AS myShift, "
                + "COALESCE(target.work_date, os.work_date) AS targetDate, "
                + "COALESCE(ts.name, os2.name) AS targetShift, "
                + "tgt_ep.full_name AS colleagueName, "
                + "r.open_shift_id AS openShiftId, "
                + "r.reason, r.status, r.response "
                + "FROM shift_change_requests r "
                + "LEFT JOIN shift_schedules mine "
                + "ON mine.id = r.shift_schedule_id "
                + "LEFT JOIN shifts ms ON ms.id = mine.shift_id "
                + "LEFT JOIN shift_schedules target "
                + "ON target.id = r.target_shift_schedule_id "
                + "LEFT JOIN shifts ts ON ts.id = target.shift_id "
                + "LEFT JOIN open_shifts os "
                + "ON os.id = r.open_shift_id "
                + "LEFT JOIN shifts os2 ON os2.id = os.shift_id "
                + "LEFT JOIN employee_profiles req_ep "
                + "ON req_ep.user_id = r.requester_id "
                + "LEFT JOIN employee_profiles tgt_ep "
                + "ON tgt_ep.user_id = r.target_user_id "
                + "WHERE COALESCE(mine.branch_id, os.branch_id) = ? "
                + "ORDER BY r.id DESC";

        return query(sql, branchId);
    }

    // 7b. Store Manager: Đếm số đơn đổi ca đang chờ duyệt của chi nhánh
    public int countBranchPendingShiftRequests(int branchId) {
        // Đơn EXTRA không có shift_schedule_id (nhân viên không mất ca
        // nào) -> cơ sở được xác định qua ca trống.
        String sql
                = "SELECT COUNT(*) FROM shift_change_requests r "
                + "LEFT JOIN shift_schedules ss "
                + "ON ss.id = r.shift_schedule_id "
                + "LEFT JOIN open_shifts os "
                + "ON os.id = r.open_shift_id "
                + "WHERE COALESCE(ss.branch_id, os.branch_id) = ? "
                + "AND r.status = 'PENDING'";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, branchId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot count shift requests", e);
        }

        return 0;
    }

    /**
     * Store Manager tạo ca trống.
     *
     * <h3>Quy tắc nghiệp vụ</h3>
     * <ul>
     *   <li>Ngày làm việc phải từ hôm nay trở đi. KHÔNG đặt khoảng cách
     *       tối thiểu, vì ca ốm đột xuất xảy ra trong ngày: Store cần
     *       mở ca trống ngay để nhân viên khác đi thế trong ngày.
     *       Nhân viên cũng thấy ca trống từ {@code CURRENT_DATE()}
     *       trở đi (xem {@link #getOpenShifts}).</li>
     *   <li>Không tạo trùng ca trống: cùng cơ sở + cùng ca + cùng VỊ TRÍ
     *       + cùng ngày. Phải có {@code position_id} trong điều kiện kiểm
     *       tra, vì một ca có thể thiếu người ở nhiều vị trí khác nhau
     *       (ví dụ: Ca Sáng thiếu người ở cả Bán Hàng và Thu Ngân).</li>
     * </ul>
     */
    public boolean createOpenShift(
            int branchId,
            int shiftId,
            int positionId,
            LocalDate date) throws Exception {

        if (branchId <= 0 || shiftId <= 0 || positionId <= 0) {
            return false;
        }

        if (date == null) {
            return false;
        }

        // Không cho tạo ca trống cho ngày đã qua.
        // KHÔNG đặt khoảng cách tối thiểu: ca ốm đột xuất xảy ra trong
        // ngày, Store cần mở ca trống ngay để nhân viên khác đi thế.
        if (date.isBefore(LocalDate.now())) {
            return false;
        }

        // Không tạo trùng ca trống cùng ngày + cùng ca + cùng vị trí.
        // Phải so cả position_id, nếu không thì Store không thể mở ca
        // trống cho 2 vị trí khác nhau cùng ca cùng ngày.
        String check
                = "SELECT COUNT(*) FROM open_shifts "
                + "WHERE branch_id = ? AND shift_id = ? AND position_id = ? "
                + "AND work_date = ? AND status = 'OPEN'";

        try (Connection c = connect()) {

            try (PreparedStatement ps = c.prepareStatement(check)) {
                ps.setInt(1, branchId);
                ps.setInt(2, shiftId);
                ps.setInt(3, positionId);
                ps.setDate(4, java.sql.Date.valueOf(date));

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return false;
                    }
                }
            }

            String sql
                    = "INSERT INTO open_shifts "
                    + "(branch_id, shift_id, position_id, work_date, status) "
                    + "VALUES (?, ?, ?, ?, 'OPEN')";

            try (PreparedStatement ps = c.prepareStatement(sql)) {

                ps.setInt(1, branchId);
                ps.setInt(2, shiftId);
                ps.setInt(3, positionId);
                ps.setDate(4, java.sql.Date.valueOf(date));

                return ps.executeUpdate() > 0;
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot create open shift", e);
        }
    }

    /**
     * Store Manager đóng ca trống thủ công.
     *
     * <h3>Vì sao cần?</h3>
     * Ca trống chỉ được đóng tự động khi: nhân viên nhận, hoặc đơn nghỉ
     * phép bị thu hồi. Nếu không có cách đóng thủ công thì ca trống "vô
     * chủ" sẽ tồn tại vĩnh viễn, chặn Store tạo ca trống mới cho cùng
     * ca/ngày/vị trí và làm nhân viên thấy ca trống không ai nhận được.
     *
     * <p>Không cho đóng ca trống đã có người đề nghị nhận (đơn PENDING),
     * vì Store cần xử lý đơn đó trước.
     *
     * @return true nếu đóng thành công
     */
    public boolean closeOpenShift(int branchId, int openShiftId)
            throws Exception {

        if (branchId <= 0 || openShiftId <= 0) {
            return false;
        }

        // Chặn đóng ca trống đang có người xin -> phải duyệt/từ chối đơn trước.
        String pendingSql
                = "SELECT COUNT(*) FROM shift_change_requests "
                + "WHERE open_shift_id = ? AND status = 'PENDING'";

        // Ca trống sinh ra từ đơn nghỉ phép ĐÃ DUYỆT không được đóng tay:
        // việc đó thuộc chức năng thu hồi đơn nghỉ phép (nếu không,
        // ca sẽ bị đóng mà nhân viên vẫn nghỉ -> mất nhân lực).
        String leaveSql
                = "SELECT COUNT(*) FROM open_shifts "
                + "WHERE id = ? AND leave_request_id IS NOT NULL "
                + "AND EXISTS (SELECT 1 FROM leave_requests lr "
                + "WHERE lr.id = open_shifts.leave_request_id "
                + "AND lr.status = 'APPROVED')";

        // Đóng ca trống thuộc đúng cơ sở của Store Manager.
        String closeSql
                = "UPDATE open_shifts SET status = 'CLOSED' "
                + "WHERE id = ? AND branch_id = ? AND status = 'OPEN'";

        try (Connection c = connect()) {

            try (PreparedStatement ps = c.prepareStatement(pendingSql)) {
                ps.setInt(1, openShiftId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = c.prepareStatement(leaveSql)) {
                ps.setInt(1, openShiftId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = c.prepareStatement(closeSql)) {
                ps.setInt(1, openShiftId);
                ps.setInt(2, branchId);
                return ps.executeUpdate() == 1;
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot close open shift", e);
        }
    }

    // 9. Store Manager xem ca trống của chi nhánh
    public List<Map<String, Object>> getBranchOpenShifts(int branchId) {

        // "past" = ca đã qua, không thể nhận nữa -> cảnh báo để Store
        // đóng lại. Ca từ hôm nay trở đi thì nhân viên nhận được ngay
        // (không còn khoảng cách tối thiểu) nên không cần cảnh báo.
        String sql
                = "SELECT os.id, os.work_date AS workDate, "
                + "s.name AS shiftName, os.status, "
                + "os.leave_request_id AS leaveRequestId, "
                + "p.title AS positionTitle, "
                + "(CASE WHEN os.work_date < CURRENT_DATE() "
                + "THEN '1' ELSE '0' END) AS past, "
                + "DATEDIFF(os.work_date, CURRENT_DATE()) AS daysLeft "
                + "FROM open_shifts os "
                + "JOIN shifts s ON s.id = os.shift_id "
                + "LEFT JOIN positions p ON p.id = os.position_id "
                + "WHERE os.branch_id = ? "
                + "ORDER BY os.work_date DESC, s.start_time";

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
                // Đơn EXTRA không có shift_schedule_id (nhân viên không
                // mất ca nào) -> phải xác định cơ sở qua ca trống.
                // Vì vậy dùng LEFT JOIN và lấy branch_id từ ca trống.
                String sql
                        = "SELECT r.request_type, r.requester_id, "
                        + "r.shift_schedule_id, "
                        + "r.target_user_id, r.target_shift_schedule_id, "
                        + "r.open_shift_id, r.status, "
                        + "COALESCE(ss.branch_id, os.branch_id) AS branch_id "
                        + "FROM shift_change_requests r "
                        + "LEFT JOIN shift_schedules ss "
                        + "ON ss.id = r.shift_schedule_id "
                        + "LEFT JOIN open_shifts os "
                        + "ON os.id = r.open_shift_id "
                        + "WHERE r.id = ? "
                        + "AND COALESCE(ss.branch_id, os.branch_id) = ? "
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
                    } else if ("EXTRA".equals(type)) {
                        if (!approveExtra(
                                c, branchId, openId, requester)) {
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
                || requester == targetUser) {
            return false;
        }

        // Hai ca được đổi phải KHÁC NHAU về ngày hoặc khung giờ.
        // Nếu cùng ngày và chồng lấn giờ -> sau khi đổi, mỗi người
        // sẽ có 2 ca chồng lấn nhau.
        if (overlapsSameDay(c,
                dates.get(myId), shiftIds.get(myId),
                dates.get(targetId), shiftIds.get(targetId))) {
            return false;
        }

        // Hai ca phải nằm trong CÙNG TUẦN (thứ 2 .. chủ nhật).
        // Nhân viên chỉ được đổi ca trong tuần đang xem.
        if (!sameWeek(dates.get(myId), dates.get(targetId))) {
            return false;
        }

        // Kiểm tra cả hai nhân viên không trùng ca với ca mới.
        // hasConflict so sánh cả KHOẢNG GIỜ, nên chặn được trường
        // hợp "Ca Sáng" và "Ca Full-time Sáng - Chiều" cùng ngày.
        if (hasConflict(c, requester, dates.get(targetId),
                shiftIds.get(targetId), myId)
            || hasConflict(c, targetUser, dates.get(myId),
                    shiftIds.get(myId), targetId)) {
            return false;
        }

        // Người nhận ca (targetUser) không được đang nghỉ phép trong
        // ca sẽ làm việc mới.
        if (isOnApprovedLeave(targetUser, dates.get(myId),
                shiftIds.get(myId))) {
            return false;
        }

        // Người gửi (requester) cũng không được đang nghỉ phép trong
        // ca sẽ làm việc mới.
        if (isOnApprovedLeave(requester, dates.get(targetId),
                shiftIds.get(targetId))) {
            return false;
        }

        // Ca sau khi đổi phải giữ vị trí công tác của chính người
        // làm ca đó, nếu không lịch sẽ bị lệch vị trí.
        int requesterPosition = positionOf(c, requester);
        int targetPosition = positionOf(c, targetUser);

        if (requesterPosition <= 0 || targetPosition <= 0) {
            return false;
        }

        // Hai người đổi ca phải có CÙNG CHỨC VỤ và CÙNG NHÓM
        // LÀM VIỆC (full-time chỉ đổi với full-time,
        // part-time chỉ đổi với part-time).
        // Kiểm tra lại lúc duyệt vì chức vụ/loại NV có thể đã
        // thay đổi trong khoảng thời gian chờ duyệt.
        if (requesterPosition != targetPosition) {
            return false;
        }

        String requesterType = employeeTypeOf(c, requester);
        String targetType = employeeTypeOf(c, targetUser);

        if (!requesterType.equals(targetType)) {
            return false;
        }

        String update
                = "UPDATE shift_schedules SET user_id = ?, "
                + "position_id = ? WHERE id = ?";

        try (PreparedStatement ps = c.prepareStatement(update)) {
            ps.setInt(1, targetUser);
            ps.setInt(2, targetPosition);
            ps.setInt(3, myId);
            if (ps.executeUpdate() != 1) {
                return false;
            }

            ps.setInt(1, requester);
            ps.setInt(2, requesterPosition);
            ps.setInt(3, targetId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Nhóm làm việc của nhân viên (FULL_TIME / PART_TIME / CASUAL).
     * Nếu hồ sơ không ghi -> coi như FULL_TIME.
     */
    private String employeeTypeOf(
            Connection c, int userId) throws SQLException {

        String sql = "SELECT employee_type FROM employee_profiles "
                + "WHERE user_id = ?";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String type = rs.getString(1);

                    if (type != null && !type.trim().isEmpty()) {
                        return type.trim().toUpperCase();
                    }
                }
            }
        }

        return "FULL_TIME";
    }

    /**
     * Vị trí công tác của nhân viên.
     */
    private int positionOf(
            Connection c, int userId) throws SQLException {
        String sql = "SELECT position_id FROM employee_profiles "
                + "WHERE user_id = ?";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("position_id");
                }
            }
        }

        return -1;
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

        // Nhân viên nhận ca trống nhưng đang nghỉ phép (đơn đã duyệt)
        // trong ca đó -> không được nhận ca.
        if (isOnApprovedLeave(requester, newDate, newShift)) {
            return false;
        }

        // Ca mới phải giữ vị trí công tác của nhân viên.
        int requesterPosition = positionOf(c, requester);

        if (requesterPosition <= 0) {
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
            ps.setInt(3, requesterPosition);
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

            // open_shifts.position_id là NOT NULL -> nếu ca cũ không
            // có position_id thì lấy vị trí mặc định của nhân viên.
            int reopenPosition = oldPosition > 0
                    ? oldPosition
                    : findDefaultPositionId(c, requester);

            if (reopenPosition <= 0) {
                // Không xác định được vị trí -> không mở lại ca cũ,
                // nhưng vẫn giữ nguyên kết quả đã đổi ca.
                return true;
            }

            ps.setInt(3, reopenPosition);
            ps.setDate(4, oldDate);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Duyệt đơn "nhận thêm ca" (EXTRA).
     *
     * <p>Khác {@link #approveOpen}: KHÔNG chuyển ca cũ của nhân viên.
     * Thay vào đó tạo MỘT bản ghi MỚI trong {@code shift_schedules}
     * cho ca trống đã nhận, và đóng ca trống lại. Lịch cũ của nhân viên
     * giữ nguyên hoàn toàn.
     *
     * @param c       connection (đã bắt đầu transaction)
     * @param branch  chi nhánh của ca trống
     * @param openId  ca trống được nhận
     * @param requester nhân viên nhận ca
     */
    private boolean approveExtra(
            Connection c, int branch, int openId, int requester)
            throws SQLException {

        // Khoá ca trống để tránh 2 Store duyệt cùng lúc cho 2 người.
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

        // Ca mới không được chồng lấn với ca đang có của nhân viên.
        if (hasConflict(c, requester, newDate, newShift, -1)) {
            return false;
        }

        // Nhân viên nhận ca trống nhưng đang nghỉ phép (đơn đã duyệt)
        // trong ca đó -> không được nhận ca.
        if (isOnApprovedLeave(requester, newDate, newShift)) {
            return false;
        }

        // Ca mới phải giữ vị trí công tác của nhân viên.
        int requesterPosition = positionOf(c, requester);

        if (requesterPosition <= 0) {
            return false;
        }

        // Vị trí của ca trống phải khớp vị trí của nhân viên.
        // (Nhân viên có thể đã đổi vị trí sau khi gửi đơn -> không
        // được gán ca vị trí khác cho họ.)
        if (newPosition > 0 && newPosition != requesterPosition) {
            return false;
        }

        // Tạo bản ghi lịch MỚI cho nhân viên.
        // Lịch cũ KHÔNG bị thay đổi.
        String insert
                = "INSERT INTO shift_schedules "
                + "(branch_id, user_id, shift_id, work_date, "
                + "position_id, status) "
                + "VALUES (?, ?, ?, ?, ?, 'PUBLISHED')";

        try (PreparedStatement ps = c.prepareStatement(insert)) {
            ps.setInt(1, branch);
            ps.setInt(2, requester);
            ps.setInt(3, newShift);
            ps.setDate(4, newDate);
            ps.setInt(5, requesterPosition);
            if (ps.executeUpdate() != 1) {
                return false;
            }
        }

        // Đóng ca trống vừa được nhận.
        try (PreparedStatement ps = c.prepareStatement(
                "UPDATE open_shifts SET status = 'CLOSED' "
                + "WHERE id = ? AND status = 'OPEN'")) {
            ps.setInt(1, openId);
            if (ps.executeUpdate() != 1) {
                return false;
            }
        }

        return true;
    }

    /**
     * Tìm position_id mặc định của nhân viên (dùng khi ca trong lịch
     * không có position_id).
     */
    private int findDefaultPositionId(
            Connection c, int userId) throws SQLException {

        String sql = "SELECT position_id FROM employee_profiles "
                + "WHERE user_id = ?";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("position_id");
                }
            }
        }

        return -1;
    }

    // Kiểm tra trùng ca: KHÔNG được có 2 ca chồng lấn khung giờ
    // trong cùng một ngày.
    //
    // Chỉ so sánh shift_id là KHÔNG ĐỦ, vì các ca khác nhau vẫn có
    // thể trùng giờ (ví dụ "Ca Sáng" 07:00-12:00 và
    // "Ca Full-time Sáng - Chiều" 07:00-17:00 cùng một ngày).
    // -> phải so sánh cả khoảng [start_time, end_time).
    private boolean hasConflict(
            Connection c, int userId,
            java.sql.Date date, int shiftId, int ignoreId)
            throws SQLException {

        String sql
                = "SELECT COUNT(*) FROM shift_schedules ss "
                + "JOIN shifts s ON s.id = ss.shift_id "
                + "WHERE ss.user_id = ? AND ss.work_date = ? "
                + "AND ss.id <> ? "
                + "AND ss.status = 'PUBLISHED' "
                + "AND s.start_time < (SELECT end_time FROM shifts WHERE id = ?) "
                + "AND s.end_time > (SELECT start_time FROM shifts WHERE id = ?)";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, date);
            ps.setInt(3, ignoreId);
            ps.setInt(4, shiftId);
            ps.setInt(5, shiftId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Nhân viên có thể nhận ca trống này không?
     *
     * <h3>Điều kiện</h3>
     * <ul>
     *   <li>Ca trống thuộc cơ sở của nhân viên, đang mở, còn hiệu lực.</li>
     *   <li>Ca trống khớp vị trí công tác của nhân viên.</li>
     *   <li>Ca trống không chồng lấn khung giờ với ca đang có của
     *       nhân viên trong cùng ngày.</li>
     * </ul>
     */
    private boolean canTakeOpenShift(
            int userId, int myScheduleId, int openShiftId)
            throws Exception {

        String sql
                = "SELECT os.work_date AS openDate, os.shift_id AS openShift, "
                + "os.branch_id AS openBranch, "
                + "mine.work_date AS myDate, mine.shift_id AS myShift "
                + "FROM open_shifts os "
                + "JOIN shift_schedules mine ON mine.id = ? "
                + "JOIN employee_profiles ep ON ep.user_id = ? "
                + "JOIN users requester ON requester.id = mine.user_id "
                + "WHERE os.id = ? "
                + "AND os.status = 'OPEN' "
                + "AND os.branch_id = ep.home_branch_id "
                + "AND (ep.position_id IS NULL "
                + "OR os.position_id = ep.position_id) "
                + "AND mine.user_id = ? "
                + "AND mine.status = 'PUBLISHED' "
                + "AND requester.role_id = 5 "
                + "AND requester.status = 'ACTIVE' "
                + "AND os.work_date >= "
                + "CURRENT_DATE() "
                + "AND mine.work_date >= "
                + "CURRENT_DATE()";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, myScheduleId);
            ps.setInt(2, userId);
            ps.setInt(3, openShiftId);
            ps.setInt(4, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }

                java.sql.Date openDate = rs.getDate("openDate");
                int openShift = rs.getInt("openShift");
                java.sql.Date myDate = rs.getDate("myDate");
                int myShift = rs.getInt("myShift");

                // Ca trống phải khác ca đang giữ (nếu cùng ngày và
                // cùng khung giờ thì việc chuyển là vô nghĩa).
                return !overlapsSameDay(c,
                        openDate, openShift, myDate, myShift);
            }
        }
    }

    /**
     * Hai ngày có nằm trong cùng một tuần (thứ 2 .. chủ nhật) không?
     */
    private boolean sameWeek(
            java.sql.Date dateA, java.sql.Date dateB) {

        if (dateA == null || dateB == null) {
            return false;
        }

        LocalDate a = dateA.toLocalDate();
        LocalDate b = dateB.toLocalDate();

        LocalDate mondayA = a.with(
                java.time.temporal.TemporalAdjusters
                        .previousOrSame(java.time.DayOfWeek.MONDAY));
        LocalDate mondayB = b.with(
                java.time.temporal.TemporalAdjusters
                        .previousOrSame(java.time.DayOfWeek.MONDAY));

        return mondayA.equals(mondayB);
    }

    /**
     * Hai ca có chồng lấn khung giờ không.
     * Dùng để chặn việc đổi 2 ca cùng một ngày.
     */
    private boolean overlapsSameDay(
            Connection c,
            java.sql.Date dateA, int shiftA,
            java.sql.Date dateB, int shiftB)
            throws SQLException {

        if (!Objects.equals(dateA, dateB)) {
            return false;
        }

        if (shiftA == shiftB) {
            return true;
        }

        String sql
                = "SELECT (a.start_time < b.end_time "
                + "       AND a.end_time > b.start_time) "
                + "FROM shifts a, shifts b "
                + "WHERE a.id = ? AND b.id = ?";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, shiftA);
            ps.setInt(2, shiftB);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) == 1;
            }
        }
    }

    /**
     * Chức vụ dùng để XẾP CA (chỉ chức vụ của nhân viên vận hành).
     *
     * <h3>Vì sao không lấy toàn bộ bảng {@code positions}?</h3>
     * Ca trống chỉ dành cho nhân viên làm việc tại cửa hàng (thu ngân,
     * bán hàng, kho, bảo vệ...). Nếu hiển thị cả "Giám Đốc Chuỗi",
     * "Quản Lý Chi Nhánh"... thì Store có thể tạo ca trống cho vị trí
     * mà không nhân viên nào đảm nhiệm -> ca trống không ai nhận được.
     *
     * <h3>Cách lọc</h3>
     * <ul>
     *   <li>Loại chức vụ quản lý: tên bắt đầu bằng "Quản" / "Giám"
     *       (Giám Đốc, Quản Lý Nhân Sự, Quản Trị Hệ Thống,
     *       Quản Lý Chi Nhánh).</li>
     *   <li>Loại chức vụ đang được gán cho người có role quản lý
     *       (System Admin, Director, HR Manager, Store Manager).</li>
     * </ul>
     *
     * <p>KHÔNG lọc theo "có nhân viên đang đảm nhiệm hay không", để
     * các chức vụ vận hành mới (chưa tuyển người) vẫn chọn được.
     */
    public List<Map<String, Object>> getShiftPositions() {
        List<Map<String, Object>> result = new ArrayList<>();

        String sql
                = "SELECT p.id, p.title FROM positions p "
                + "WHERE p.title NOT LIKE 'Quản%' "
                + "AND p.title NOT LIKE 'Giám%' "
                + "AND NOT EXISTS ("
                + "  SELECT 1 FROM employee_profiles ep "
                + "  JOIN users u ON u.id = ep.user_id "
                + "  WHERE ep.position_id = p.id "
                + "  AND u.role_id IN (1, 2, 3, 4)"
                + ") "
                + "ORDER BY p.title";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("title", rs.getString("title"));
                result.add(row);
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load shift positions", e);
        }

        return result;
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
                + "CURRENT_DATE() "
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
                + "JOIN employee_profiles requester_ep "
                + "ON requester_ep.user_id = r.requester_id "
                + "JOIN employee_profiles colleague_ep "
                + "ON colleague_ep.user_id = r.target_user_id "
                + "SET r.status = ?, "
                + "r.colleague_response = ?, "
                + "r.colleague_responded_at = NOW() "
                + "WHERE r.id = ? "
                + "AND r.target_user_id = ? "
                + "AND r.status = 'WAITING_COLLEAGUE' "
                + "AND r.request_type = 'SWAP' "
                + "AND mine.user_id = r.requester_id "
                + "AND theirs.user_id = r.target_user_id "
                + "AND r.shift_schedule_id = mine.id "
                + "AND r.target_shift_schedule_id = theirs.id "
                + "AND mine.branch_id = theirs.branch_id "
                + "AND mine.status = 'PUBLISHED' "
                + "AND theirs.status = 'PUBLISHED' "
                + "AND requester.role_id = 5 "
                + "AND colleague.role_id = 5 "
                + "AND requester.status = 'ACTIVE' "
                + "AND colleague.status = 'ACTIVE' "
                + "AND requester.id <> colleague.id "
                + "AND requester_ep.position_id = colleague_ep.position_id "
                + "AND COALESCE(requester_ep.employee_type, 'FULL_TIME') = "
                + "COALESCE(colleague_ep.employee_type, 'FULL_TIME') "
                // Hai ca phai cung thuoc ve cung mot tuan (thu 2..chu nhat).
                + "AND DATE_SUB(mine.work_date, "
                + "INTERVAL WEEKDAY(mine.work_date) DAY) = "
                + "DATE_SUB(theirs.work_date, "
                + "INTERVAL WEEKDAY(theirs.work_date) DAY) "
                + "AND mine.work_date >= "
                + "CURRENT_DATE() "
                + "AND theirs.work_date >= "
                + "CURRENT_DATE()";

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
