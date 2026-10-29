package dao;

import context.DBContext;
import model.LeaveRequestShift;

import java.sql.*;
import java.time.LocalDate;
import java.util.*;

/**
 * DAO cho bảng leave_requests.
 *
 * Mô hình "C trên nền B" được triển khai tại đây:
 *
 * <h3>B (nền) - đơn vị đo là GIờ</h3>
 * Mọi phép kiểm tra quota dùng {@code total_hours}/{@code used_hours}
 * thay vì số ngày. Nhờ vậy full-time (10h/ngày) và part-time (5h/ca)
 * dùng chung một bộ quy tắc.
 *
 * <h3>C (trên nền) - mỗi đơn gắn với danh sách CA</h3>
 * Khi duyệt đơn:
 *   <ol>
 *     <li>Các ca bị nghỉ trong {@code shift_schedules} chuyển sang
 *         {@code ON_LEAVE} (đúng những ca ghi trong
 *         {@code leave_request_shifts}).</li>
 *     <li>Các ca đó được đưa vào {@code open_shifts} để nhân viên khác
 *         có thể nhận cover, kèm {@code leave_request_id} để truy vết.</li>
 *     <li>Quota được trừ theo GIỜ.</li>
 *   </ol>
 *
 * <h3>Chống xung đột</h3>
 * <ul>
 *   <li>Ca trống đã tồn tại (do Store Manager tạo) được <b>liên kết</b>
 *       lại bằng {@code leave_request_id} thay vì tạo bản trùng.</li>
 *   <li>Chi tiết ca được snapshot, nên sửa định nghĩa ca sau này không
 *       làm thay đổi lịch sử nghỉ phép.</li>
 *   <li>Toàn bộ thao tác duyệt nằm trong một transaction với
 *       {@code SELECT ... FOR UPDATE} để tránh 2 manager duyệt cùng đơn.</li>
 * </ul>
 */
public class LeaveRequestDAO {

    /**
     * Lỗi ném ra khi đơn mới trùng với đơn cũ đang có hiệu lực.
     */
    public static class DuplicateLeaveException extends Exception {

        private final LeaveConflict conflict;

        public DuplicateLeaveException(LeaveConflict conflict) {
            super("Duplicate leave request on "
                    + (conflict == null ? "?" : conflict.getDate()));
            this.conflict = conflict;
        }

        public LeaveConflict getConflict() {
            return conflict;
        }
    }

    private Connection connect() throws Exception {
        return DBContext.getConnection();
    }

    private List<Map<String, Object>> queryList(String sql, Object... params) {
        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();

                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= md.getColumnCount(); i++) {
                        row.put(md.getColumnLabel(i), rs.getObject(i));
                    }
                    result.add(row);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot load leave requests", e);
        }

        return result;
    }

    /**
     * Chạy câu truy vấn trả về 1 giá trị số nguyên (COUNT, SUM...).
     * Trả về 0 nếu có lỗi để giao diện không bị vỡ.
     */
    private int countScalar(String sql, Object... params) {
        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot count leave requests", e);
        }

        return 0;
    }

    // 1. Employee: Lịch sử đơn nghỉ phép của mình
    public List<Map<String, Object>> getMyRequests(int userId) {
        String sql = "SELECT lr.id, lr.start_date AS startDate, "
                + "lr.end_date AS endDate, lr.total_days AS totalDays, "
                + "COALESCE(lr.total_hours, 0) AS totalHours, "
                + "lt.code AS leaveTypeCode, "
                + "lt.name AS leaveTypeName, "
                + "lr.reason, lr.status, lr.manager_response AS managerResponse, "
                + "lr.created_at AS createdAt, "
                + "lr.reviewed_at AS reviewedAt "
                + "FROM leave_requests lr "
                + "JOIN leave_types lt ON lt.id = lr.leave_type_id "
                + "WHERE lr.user_id = ? "
                + "ORDER BY lr.created_at DESC";

        return queryList(sql, userId);
    }

    // 1b. Employee: Đếm số đơn nghỉ phép đang chờ duyệt của tôi
    public int countMyPendingRequests(int userId) {
        return countScalar(
            "SELECT COUNT(*) FROM leave_requests "
            + "WHERE user_id = ? AND status = 'PENDING'",
            userId
        );
    }

    // 1c. Store Manager: Đếm số đơn nghỉ phép đang chờ duyệt của chi nhánh
    public int countBranchPendingRequests(int branchId) {
        return countScalar(
            "SELECT COUNT(*) FROM leave_requests lr "
            + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
            + "WHERE ep.home_branch_id = ? AND lr.status = 'PENDING'",
            branchId
        );
    }

    /**
     * Thông tin đơn cũ bị trùng với đơn đang tạo.
     */
    public static class LeaveConflict {

        private final LocalDate date;
        private final int requestId;
        private final boolean wholeDay;

        LeaveConflict(LocalDate date, int requestId, boolean wholeDay) {
            this.date = date;
            this.requestId = requestId;
            this.wholeDay = wholeDay;
        }

        /** Ngày bị trùng. */
        public LocalDate getDate() {
            return date;
        }

        /** Id của đơn cũ đã tồn tại. */
        public int getRequestId() {
            return requestId;
        }

        /**
         * true nếu đơn cũ được tính theo NGÀY (fallback, chưa có lịch
         * chi tiết) - tức là đơn đó chiếm trọn cả ngày.
         */
        public boolean isWholeDay() {
            return wholeDay;
        }
    }

    /**
     * Kiểm tra nhân viên đã có đơn nghỉ phép TRÙNG slot nghỉ chưa.
     *
     * <h3>Vì sao cần chặn?</h3>
     * Nhân viên rất dễ bấm nhầm tạo 2 đơn cùng một ngày. Nếu không chặn:
     *   <ul>
     *     <li>Quota bị trừ 2 lần cho cùng một ca nghỉ.</li>
     *     <li>Cùng một ca bị đưa vào open_shifts 2 lần.</li>
     *     <li>Lịch sử nghỉ phép mâu thuẫn với lịch làm việc.</li>
     *   </ul>
     *
     * <h3>Quy tắc</h3>
     * <ul>
     *   <li>Chỉ tính đơn đang chờ duyệt (PENDING) hoặc đã duyệt
     *       (APPROVED) - đơn bị từ chối/hủy thì không còn hiệu lực.</li>
     *   <li>Mỗi đơn chiếm một tập "slot" (ô nghỉ):
     *       <ul>
     *         <li>Đơn CÓ chi tiết ca ({@code leave_request_shifts})
     *             -> chiếm từng ô (ngày + ca).</li>
     *         <li>Đơn KHÔNG có chi tiết ca (fallback theo ngày, dùng
     *             khi lịch chưa được publish) -> chiếm TRỌN cả ngày,
     *             đè lên mọi ca của ngày đó.</li>
     *       </ul>
     *   </li>
     *   <li>Hai đơn xung đột khi các slot của chúng chạm nhau:
     *       cùng ngày, hoặc cùng ngày + cùng ca.</li>
     *   <li>KHÔNG lọc theo loại nghỉ: một ngày làm việc chỉ có thể
     *       được chiếm bởi MỘT đơn nghỉ, nếu không nhân viên sẽ
     *       nghỉ 2 lần cho cùng một ca (và quota của 2 loại nghỉ
     *       cùng bị tiêu).</li>
     * </ul>
     *
     * @param newShifts  chi tiết ca của đơn mới (rỗng = fallback theo ngày)
     * @param startDate  ngày bắt đầu của đơn mới
     * @param endDate    ngày kết thúc của đơn mới
     * @return thông tin đơn bị trùng, hoặc null nếu không trùng
     */
    public LeaveConflict findConflictingRequest(
            int userId,
            List<LeaveRequestShift> newShifts,
            LocalDate startDate,
            LocalDate endDate) {

        try (Connection c = connect()) {
            return findConflict(
                    c, userId, newShifts, startDate, endDate);
        } catch (Exception e) {
            // Không chặn người dùng vì lỗi kỹ thuật.
            return null;
        }
    }

    /**
     * Lõi của việc phát hiện trùng (dùng chung connection, có thể gọi
     * bên trong transaction để tránh race condition).
     */
    private LeaveConflict findConflict(
            Connection c,
            int userId,
            List<LeaveRequestShift> newShifts,
            LocalDate startDate,
            LocalDate endDate) throws SQLException {

        // ---------- 1. Slot của đơn MỚI ----------
        // newWholeDays: các ngày bị chiếm TRỌN (đơn fallback theo ngày)
        Set<String> newWholeDays = new HashSet<>();
        // newShiftSlots: các ô (ngày#ca) bị chiếm
        Set<String> newShiftSlots = new HashSet<>();

        if (newShifts == null || newShifts.isEmpty()) {
            for (LocalDate d = startDate; !d.isAfter(endDate); d = d.plusDays(1)) {
                newWholeDays.add(d.toString());
            }
        } else {
            for (LeaveRequestShift s : newShifts) {
                if (s.getWorkDate() == null) {
                    continue;
                }
                String date = s.getWorkDate().toLocalDate().toString();
                newShiftSlots.add(date + "#" + s.getShiftId());
            }
        }

        if (newWholeDays.isEmpty() && newShiftSlots.isEmpty()) {
            return null;
        }

        // ---------- 2. Các đơn cũ còn hiệu lực ----------
        String sql = "SELECT lr.id AS requestId, "
                + "lr.start_date AS startDate, lr.end_date AS endDate, "
                + "lrs.work_date AS workDate, lrs.shift_id AS shiftId "
                + "FROM leave_requests lr "
                + "LEFT JOIN leave_request_shifts lrs "
                + "  ON lrs.leave_request_id = lr.id "
                + "WHERE lr.user_id = ? "
                + "AND lr.status IN ('PENDING', 'APPROVED') "
                + "AND lr.start_date <= ? "
                + "AND lr.end_date >= ? "
                + "ORDER BY lr.id";

        Map<Integer, int[]> oldRange = new HashMap<>();   // id -> {start,end}
        Map<Integer, Set<String>> oldSlots = new HashMap<>();
        Map<Integer, Boolean> oldHasShifts = new HashMap<>();

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(endDate));
            ps.setDate(3, java.sql.Date.valueOf(startDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("requestId");
                    java.sql.Date s = rs.getDate("startDate");
                    java.sql.Date e = rs.getDate("endDate");

                    if (!oldRange.containsKey(id)) {
                        oldRange.put(id, new int[]{
                                s == null ? 0 : (int) s.toLocalDate().toEpochDay(),
                                e == null ? 0 : (int) e.toLocalDate().toEpochDay()
                        });
                        oldSlots.put(id, new HashSet<>());
                        oldHasShifts.put(id, Boolean.FALSE);
                    }

                    java.sql.Date wd = rs.getDate("workDate");
                    if (wd != null) {
                        oldHasShifts.put(id, Boolean.TRUE);
                        oldSlots.get(id).add(
                                wd.toLocalDate() + "#" + rs.getInt("shiftId"));
                    }
                }
            }
        }

        // ---------- 3. So sánh slot ----------
        for (Map.Entry<Integer, int[]> entry : oldRange.entrySet()) {
            int id = entry.getKey();
            int[] range = entry.getValue();
            LocalDate oldStart = LocalDate.ofEpochDay(range[0]);
            LocalDate oldEnd = LocalDate.ofEpochDay(range[1]);

            if (Boolean.TRUE.equals(oldHasShifts.get(id))) {
                // Đơn có chi tiết ca -> chiếm từng ô (ngày + ca)
                for (String slot : oldSlots.get(id)) {
                    String date = slot.substring(0, slot.indexOf('#'));

                    // Đơn mới chiếm trọn ngày này -> trùng
                    if (newWholeDays.contains(date)) {
                        return new LeaveConflict(
                                LocalDate.parse(date), id, false);
                    }
                    // Cùng ngày + cùng ca -> trùng
                    if (newShiftSlots.contains(slot)) {
                        return new LeaveConflict(
                                LocalDate.parse(date), id, false);
                    }
                }
            } else {
                // Đơn fallback theo ngày -> chiếm trọn mỗi ngày
                for (LocalDate d = oldStart; !d.isAfter(oldEnd); d = d.plusDays(1)) {
                    String date = d.toString();

                    if (newWholeDays.contains(date)) {
                        return new LeaveConflict(d, id, true);
                    }
                    // Đơn mới chiếm ô (ngày + ca) của ngày này -> trùng
                    for (String slot : newShiftSlots) {
                        if (slot.startsWith(date + "#")) {
                            return new LeaveConflict(d, id, true);
                        }
                    }
                }
            }
        }

        return null;
    }

    // 2. Employee: Tạo đơn nghỉ phép (kèm chi tiết ca - phần "C")
    /**
     * Tạo đơn nghỉ phép trong một transaction.
     *
     * @param userId       nhân viên xin nghỉ
     * @param leaveTypeId  loại nghỉ
     * @param startDate    ngày bắt đầu
     * @param endDate      ngày kết thúc
     * @param totalDays    số ngày lịch (tương thích ngược)
     * @param totalHours   số giờ nghỉ (đơn vị chuẩn)
     * @param reason       lý do
     * @param shiftDetails danh sách ca bị ảnh hưởng (có thể rỗng khi
     *                    dùng fallback theo ngày)
     * @return id của đơn vừa tạo, hoặc -1 nếu thất bại
     */
    public int createRequest(
            int userId,
            int leaveTypeId,
            LocalDate startDate,
            LocalDate endDate,
            int totalDays,
            double totalHours,
            String reason,
            List<LeaveRequestShift> shiftDetails) throws Exception {

        Connection c = null;
        try {
            c = connect();
            c.setAutoCommit(false);

            // Chống trùng ngay trong transaction để tránh 2 request
            // song song cùng tạo đơn cho một ca.
            LeaveConflict conflict = findConflict(
                    c, userId, shiftDetails, startDate, endDate);
            if (conflict != null) {
                c.rollback();
                throw new DuplicateLeaveException(conflict);
            }

            String sql = "INSERT INTO leave_requests "
                    + "(user_id, leave_type_id, start_date, end_date, "
                    + "total_days, total_hours, reason, status) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')";

            int requestId;
            try (PreparedStatement ps = c.prepareStatement(sql,
                    Statement.RETURN_GENERATED_KEYS)) {

                ps.setInt(1, userId);
                ps.setInt(2, leaveTypeId);
                ps.setDate(3, java.sql.Date.valueOf(startDate));
                ps.setDate(4, java.sql.Date.valueOf(endDate));
                ps.setInt(5, totalDays);
                ps.setDouble(6, totalHours);
                ps.setString(7, reason);

                if (ps.executeUpdate() == 0) {
                    c.rollback();
                    return -1;
                }

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        c.rollback();
                        return -1;
                    }
                    requestId = keys.getInt(1);
                }
            }

            // Lưu chi tiết ca (phần "C")
            if (shiftDetails != null && !shiftDetails.isEmpty()) {
                new LeaveShiftDetailDAO()
                        .insertDetails(c, requestId, shiftDetails);
            }

            c.commit();
            return requestId;

        } catch (Exception e) {
            if (c != null) {
                try {
                    c.rollback();
                } catch (SQLException re) {
                    // ignore
                }
            }
            throw e;
        } finally {
            if (c != null) {
                try {
                    c.setAutoCommit(true);
                    c.close();
                } catch (SQLException e) {
                    // ignore
                }
            }
        }
    }

    // 2b. Employee: Tạo đơn nghỉ phép (tương thích ngược - không có ca)
    public boolean createRequest(
            int userId,
            int leaveTypeId,
            LocalDate startDate,
            LocalDate endDate,
            int totalDays,
            String reason) throws Exception {

        return createRequest(
                userId, leaveTypeId, startDate, endDate,
                totalDays, totalDays, reason, null) > 0;
    }

    // 3. Employee: Hủy đơn nghỉ phép của mình (chỉ khi PENDING)
    public boolean cancelMyRequest(int requestId, int userId) {
        String sql = "UPDATE leave_requests "
                + "SET status = 'CANCELLED' "
                + "WHERE id = ? AND user_id = ? AND status = 'PENDING'";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Cannot cancel leave request", e);
        }
    }

    // 4. Store Manager: Đơn nghỉ phép của chi nhánh
    public List<Map<String, Object>> getBranchRequests(int branchId) {
        String sql = "SELECT lr.id, lr.user_id AS userId, "
                + "ep.full_name AS userName, "
                + "ep.employee_type AS employeeType, "
                + "lt.code AS leaveTypeCode, "
                + "lt.name AS leaveTypeName, "
                + "lr.start_date AS startDate, "
                + "lr.end_date AS endDate, "
                + "lr.total_days AS totalDays, "
                + "COALESCE(lr.total_hours, 0) AS totalHours, "
                + "lr.reason, lr.status, "
                + "lr.manager_response AS managerResponse, "
                + "lr.created_at AS createdAt, "
                + "lr.reviewed_at AS reviewedAt "
                + "FROM leave_requests lr "
                + "JOIN users u ON u.id = lr.user_id "
                + "JOIN employee_profiles ep ON ep.user_id = u.id "
                + "JOIN leave_types lt ON lt.id = lr.leave_type_id "
                + "WHERE ep.home_branch_id = ? "
                + "ORDER BY lr.created_at DESC";

        return queryList(sql, branchId);
    }

    // 5. Store Manager: Duyệt / Từ chối đơn - CÓ TRANSACTION + FOR UPDATE
    public boolean review(
            int requestId,
            int branchId,
            boolean approve,
            String responseText,
            int reviewerId) throws Exception {

        Connection c = null;
        try {
            c = connect();
            c.setAutoCommit(false);

            // Khóa dòng của leave_request trong transaction này
            String lockSql = "SELECT lr.user_id AS userId, "
                    + "ep.home_branch_id AS branchId, "
                    + "lr.leave_type_id AS leaveTypeId, "
                    + "lr.start_date AS startDate, "
                    + "lr.end_date AS endDate, "
                    + "lr.total_days AS totalDays, "
                    + "COALESCE(lr.total_hours, 0) AS totalHours, "
                    + "lr.status "
                    + "FROM leave_requests lr "
                    + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
                    + "WHERE lr.id = ? "
                    + "FOR UPDATE";

            int userId;
            int reqBranchId;
            int leaveTypeId;
            java.sql.Date startDate;
            java.sql.Date endDate;
            int totalDays;
            double totalHours;
            String status;
            int year;

            try (PreparedStatement ps = c.prepareStatement(lockSql)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        c.rollback();
                        return false;
                    }

                    status = rs.getString("status");
                    userId = rs.getInt("userId");
                    reqBranchId = rs.getInt("branchId");
                    leaveTypeId = rs.getInt("leaveTypeId");
                    startDate = rs.getDate("startDate");
                    endDate = rs.getDate("endDate");
                    totalDays = rs.getInt("totalDays");
                    totalHours = rs.getDouble("totalHours");
                    year = startDate.toLocalDate().getYear();
                }
            }

            if (!"PENDING".equals(status) || reqBranchId != branchId) {
                c.rollback();
                return false;
            }

            // Nếu duyệt: kiểm tra quota còn đủ không (đơn vị GIỜ)
            if (approve && !hasEnoughBalance(
                    c, userId, leaveTypeId, totalHours, year, requestId)) {
                c.rollback();
                return false;
            }

            // Cập nhật đơn
            String updateSql = "UPDATE leave_requests "
                    + "SET status = ?, manager_response = ?, "
                    + "reviewed_by = ?, reviewed_at = CURRENT_TIMESTAMP "
                    + "WHERE id = ? AND status = 'PENDING'";

            try (PreparedStatement ps = c.prepareStatement(updateSql)) {
                ps.setString(1, approve ? "APPROVED" : "REJECTED");
                ps.setString(2, responseText);
                ps.setInt(3, reviewerId);
                ps.setInt(4, requestId);

                if (ps.executeUpdate() != 1) {
                    c.rollback();
                    return false;
                }
            }

            // Nếu duyệt: cập nhật ca làm việc + trừ quota
            if (approve) {
                // Lấy chi tiết ca của đơn (phần "C")
                List<LeaveRequestShift> details =
                        loadShiftDetails(c, requestId);

                // Đưa ca bị nghỉ vào danh sách ca trống để tìm người cover.
                // Hàm này đọc các ca đang PUBLISHED nên phải chạy TRƯỚC
                // khi đánh dấu ON_LEAVE.
                releaseShiftsToOpen(
                        c, userId, branchId, requestId,
                        details, startDate, endDate);

                if (details.isEmpty()) {
                    // Đơn cũ / fallback theo ngày: đánh dấu toàn bộ
                    // ca trong khoảng ngày.
                    markSchedulesAsLeave(
                            c, userId, startDate, endDate);
                } else {
                    // Đánh dấu đúng những ca bị nghỉ.
                    markSchedulesAsLeave(
                            c, userId, details);
                }

                // Trừ quota theo GIỜ
                String updateBalance = "UPDATE leave_balances lb "
                        + "JOIN employee_profiles ep "
                        + "  ON ep.user_id = lb.user_id "
                        + "SET lb.used_hours = COALESCE(lb.used_hours, 0) + ?, "
                        + "lb.used_days = GREATEST(0, lb.used_days + "
                        + "  FLOOR(? / ep.standard_hours_per_day)) "
                        + "WHERE lb.user_id = ? AND lb.leave_type_id = ? "
                        + "AND lb.year = ? "
                        + "AND COALESCE(lb.total_hours, 0) > 0";

                try (PreparedStatement ps = c.prepareStatement(updateBalance)) {
                    ps.setDouble(1, totalHours);
                    ps.setDouble(2, totalHours);
                    ps.setInt(3, userId);
                    ps.setInt(4, leaveTypeId);
                    ps.setInt(5, year);
                    ps.executeUpdate();
                }
            }

            c.commit();
            return true;

        } catch (Exception e) {
            if (c != null) {
                try {
                    c.rollback();
                } catch (SQLException re) {
                    // ignore
                }
            }
            throw e;
        } finally {
            if (c != null) {
                try {
                    c.setAutoCommit(true);
                    c.close();
                } catch (SQLException e) {
                    // ignore
                }
            }
        }
    }

    /**
     * Thu hồi một đơn nghỉ phép ĐÃ DUYỆT.
     *
     * <h3>Vì sao cần?</h3>
     * Trong vận hành thực tế, đơn đã duyệt có thể cần bị hủy:
     * nhân viên ốm đột xuất, kế hoạch thay đổi, chi nhánh thiếu
     * người... Nếu không có chức năng này thì:
     *   <ul>
     *     <li>Quota đã trừ mà không được hoàn lại.</li>
     *     <li>Ca vẫn bị đánh dấu ON_LEAVE dù nhân viên không nghỉ.</li>
     *     <li>Ca trống vẫn treo trong danh sách cover vô ích.</li>
     *   </ul>
     *
     * <h3>Thao tác (trong 1 transaction)</h3>
     * <ol>
     *   <li>Chuyển đơn APPROVED -> CANCELLED.</li>
     *   <li>Hoàn lại giờ nghỉ đã trừ vào quota.</li>
     *   <li>Gỡ trạng thái ON_LEAVE của các ca bị nghỉ
     *       (đưa về PUBLISHED nếu ca còn ở tương lai).</li>
     *   <li>Đóng các ca trống phát sinh từ đơn này
     *       (trừ khi ca đó đã có người nhận cover).</li>
     * </ol>
     *
     * @param requestId  id đơn cần thu hồi
     * @param branchId   chi nhánh của người thực hiện (để chặn SM
     *                   chi nhánh khác thao tác)
     * @param reviewerId id người thực hiện
     * @param reason     lý do thu hồi
     * @return true nếu thu hồi thành công
     */
    public boolean revokeApprovedRequest(
            int requestId,
            int branchId,
            int reviewerId,
            String reason) throws Exception {

        Connection c = null;
        try {
            c = connect();
            c.setAutoCommit(false);

            // 1. Khóa dòng đơn và kiểm tra điều kiện
            String lockSql = "SELECT lr.user_id AS userId, "
                    + "ep.home_branch_id AS branchId, "
                    + "lr.leave_type_id AS leaveTypeId, "
                    + "YEAR(lr.start_date) AS leaveYear, "
                    + "COALESCE(lr.total_hours, 0) AS totalHours, "
                    + "lr.status "
                    + "FROM leave_requests lr "
                    + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
                    + "WHERE lr.id = ? FOR UPDATE";

            int userId;
            int reqBranchId;
            int leaveTypeId;
            int year;
            double totalHours;
            String status;

            try (PreparedStatement ps = c.prepareStatement(lockSql)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        c.rollback();
                        return false;
                    }
                    status = rs.getString("status");
                    userId = rs.getInt("userId");
                    reqBranchId = rs.getInt("branchId");
                    leaveTypeId = rs.getInt("leaveTypeId");
                    year = rs.getInt("leaveYear");
                    totalHours = rs.getDouble("totalHours");
                }
            }

            // Chỉ thu hồi được đơn đã duyệt, đúng chi nhánh
            if (!"APPROVED".equals(status) || reqBranchId != branchId) {
                c.rollback();
                return false;
            }

            // 2. Chuyển trạng thái đơn
            String updateSql = "UPDATE leave_requests "
                    + "SET status = 'CANCELLED', "
                    + "manager_response = ?, "
                    + "reviewed_by = ?, reviewed_at = CURRENT_TIMESTAMP "
                    + "WHERE id = ? AND status = 'APPROVED'";

            String note = (reason == null || reason.trim().isEmpty())
                    ? "Đơn đã được thu hồi bởi quản lý."
                    : "Thu hồi: " + reason.trim();

            try (PreparedStatement ps = c.prepareStatement(updateSql)) {
                ps.setString(1, note);
                ps.setInt(2, reviewerId);
                ps.setInt(3, requestId);
                if (ps.executeUpdate() != 1) {
                    c.rollback();
                    return false;
                }
            }

            // 3. Hoàn lại quota (giờ đã trừ lúc duyệt)
            if (totalHours > 0) {
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE leave_balances lb "
                        + "JOIN employee_profiles ep "
                        + "  ON ep.user_id = lb.user_id "
                        + "SET lb.used_hours = GREATEST(0, "
                        + "  COALESCE(lb.used_hours, 0) - ?), "
                        + "lb.used_days = GREATEST(0, lb.used_days - "
                        + "  FLOOR(? / ep.standard_hours_per_day)) "
                        + "WHERE lb.user_id = ? AND lb.leave_type_id = ? "
                        + "AND lb.year = ?")) {

                    ps.setDouble(1, totalHours);
                    ps.setDouble(2, totalHours);
                    ps.setInt(3, userId);
                    ps.setInt(4, leaveTypeId);
                    ps.setInt(5, year);
                    ps.executeUpdate();
                }
            }

            // 4. Gỡ ON_LEAVE của các ca bị nghỉ
            //    Chỉ gỡ những ca CHƯA QUA (còn trong tương lai) và
            //    CHƯA CÓ NGƯỜI COVER.
            //
            //    "Đã có người cover" = ca trống phát sinh từ chính
            //    đơn này đã bị đóng (một đồng nghiệp đã nhận ca).
            //    Khi đó phải giữ ca ở trạng thái ON_LEAVE vì ca đó
            //    đã có người khác đảm nhiệm.
            String restoreSql = "UPDATE shift_schedules ss "
                    + "JOIN leave_request_shifts lrs "
                    + "  ON lrs.shift_id = ss.shift_id "
                    + " AND lrs.work_date = ss.work_date "
                    + "SET ss.status = 'PUBLISHED' "
                    + "WHERE ss.user_id = ? "
                    + "AND ss.status = 'ON_LEAVE' "
                    + "AND lrs.leave_request_id = ? "
                    + "AND ss.work_date >= CURDATE() "
                    + "AND NOT EXISTS (SELECT 1 FROM open_shifts os "
                    + "  WHERE os.leave_request_id = lrs.leave_request_id "
                    + "  AND os.shift_id = ss.shift_id "
                    + "  AND os.work_date = ss.work_date "
                    + "  AND os.status = 'CLOSED')";

            try (PreparedStatement ps = c.prepareStatement(restoreSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, requestId);
                ps.executeUpdate();
            }

            // 5. Đóng các ca trống phát sinh từ đơn này mà CHƯA có
            //    người nhận. (Ca đã có người cover thì vốn đã CLOSED.)
            String closeOpenSql = "UPDATE open_shifts "
                    + "SET status = 'CLOSED' "
                    + "WHERE leave_request_id = ? AND status = 'OPEN'";

            try (PreparedStatement ps = c.prepareStatement(closeOpenSql)) {
                ps.setInt(1, requestId);
                ps.executeUpdate();
            }

            c.commit();
            return true;

        } catch (Exception e) {
            if (c != null) {
                try {
                    c.rollback();
                } catch (SQLException re) {
                    // ignore
                }
            }
            throw e;
        } finally {
            if (c != null) {
                try {
                    c.setAutoCommit(true);
                    c.close();
                } catch (SQLException e) {
                    // ignore
                }
            }
        }
    }

    // 6. Đánh dấu ca làm việc trong khoảng nghỉ thành "ON_LEAVE"
    // (MySQL không hỗ trợ UPDATE...LIMIT trong mọi version)
    private void markSchedulesAsLeave(
            Connection c,
            int userId,
            java.sql.Date startDate,
            java.sql.Date endDate) throws SQLException {

        String sql = "UPDATE shift_schedules "
                + "SET status = 'ON_LEAVE' "
                + "WHERE user_id = ? "
                + "AND status = 'PUBLISHED' "
                + "AND work_date BETWEEN ? AND ?";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, startDate);
            ps.setDate(3, endDate);
            ps.executeUpdate();
        }
    }

    // 6b. Đánh dấu đúng các ca nằm trong danh sách chi tiết của đơn.
    private void markSchedulesAsLeave(
            Connection c,
            int userId,
            List<LeaveRequestShift> details) throws SQLException {

        String sql = "UPDATE shift_schedules "
                + "SET status = 'ON_LEAVE' "
                + "WHERE user_id = ? "
                + "AND status = 'PUBLISHED' "
                + "AND shift_id = ? "
                + "AND work_date = ?";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            for (LeaveRequestShift d : details) {
                ps.setInt(1, userId);
                ps.setInt(2, d.getShiftId());
                ps.setDate(3, d.getWorkDate());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    /**
     * Đưa các ca bị nghỉ vào bảng open_shifts để nhân viên khác có thể
     * nhận cover - đúng cách vận hành thực tế của siêu thị.
     *
     * Chống xung đột:
     *   - Nếu đã tồn tại ca trống cùng (branch, ca, ngày) thì chỉ liên
     *     kết leave_request_id, KHÔNG tạo bản trùng.
     *   - Chỉ xét ca trong bảng shift_schedules của chính nhân viên đó.
     */
    private void releaseShiftsToOpen(
            Connection c,
            int userId,
            int branchId,
            int requestId,
            List<LeaveRequestShift> details,
            java.sql.Date startDate,
            java.sql.Date endDate) throws SQLException {

        // Lấy danh sách ca đã xếp của nhân viên bị ảnh hưởng.
        // Chỉ lấy ca PUBLISHED vì các ca ON_LEAVE có thể thuộc đơn
        // khác đã duyệt trước đó (không nên đưa lại vào ca trống).
        List<Object[]> schedules = new ArrayList<>();

        String selSql = "SELECT ss.id, ss.branch_id, ss.shift_id, "
                + "ss.work_date, ss.position_id "
                + "FROM shift_schedules ss "
                + "WHERE ss.user_id = ? "
                + "AND ss.status = 'PUBLISHED' "
                + "AND ss.work_date BETWEEN ? AND ?";

        try (PreparedStatement ps = c.prepareStatement(selSql)) {
            ps.setInt(1, userId);
            ps.setDate(2, startDate);
            ps.setDate(3, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    schedules.add(new Object[]{
                            rs.getInt("id"),
                            rs.getInt("branch_id"),
                            rs.getInt("shift_id"),
                            rs.getDate("work_date"),
                            rs.getInt("position_id")
                    });
                }
            }
        }

        if (schedules.isEmpty()) {
            return;
        }

        // Lọc theo danh sách ca chi tiết (nếu có) để không đưa nhầm
        // ca không thuộc đơn vào danh sách ca trống.
        Set<String> allowed = new HashSet<>();
        for (LeaveRequestShift d : details) {
            allowed.add(d.getWorkDate() + "#" + d.getShiftId());
        }

        String findExisting = "SELECT id FROM open_shifts "
                + "WHERE branch_id = ? AND shift_id = ? AND work_date = ? "
                + "AND status = 'OPEN' "
                + "ORDER BY id LIMIT 1";

        String linkExisting = "UPDATE open_shifts "
                + "SET leave_request_id = ? WHERE id = ?";

        String insertNew = "INSERT INTO open_shifts "
                + "(branch_id, shift_id, position_id, work_date, status, "
                + "leave_request_id) "
                + "VALUES (?, ?, ?, ?, 'OPEN', ?)";

        try (PreparedStatement psFind = c.prepareStatement(findExisting);
             PreparedStatement psLink = c.prepareStatement(linkExisting);
             PreparedStatement psIns = c.prepareStatement(insertNew)) {

            for (Object[] row : schedules) {
                int scheduleId = (Integer) row[0];
                int schBranchId = (Integer) row[1];
                int schShiftId = (Integer) row[2];
                java.sql.Date schDate = (java.sql.Date) row[3];
                int schPositionId = (Integer) row[4];

                if (!allowed.isEmpty()
                        && !allowed.contains(schDate + "#" + schShiftId)) {
                    continue;
                }

                // open_shifts.position_id là NOT NULL -> cần giá trị hợp lệ
                int positionId = schPositionId;
                if (positionId <= 0) {
                    positionId = findDefaultPositionId(c, userId);
                }
                if (positionId <= 0) {
                    // Không xác định được vị trí -> bỏ qua ca này
                    // (không tạo ca trống sai vị trí).
                    continue;
                }

                int branch = schBranchId > 0 ? schBranchId : branchId;

                // Đã có ca trống cùng ca/ngày? -> liên kết, không tạo trùng.
                int existingId = -1;
                psFind.setInt(1, branch);
                psFind.setInt(2, schShiftId);
                psFind.setDate(3, schDate);
                try (ResultSet rs = psFind.executeQuery()) {
                    if (rs.next()) {
                        existingId = rs.getInt(1);
                    }
                }

                if (existingId > 0) {
                    // Đã có ca trống cùng ca/ngày -> liên kết vào đơn
                    // này, KHÔNG tạo bản trùng.
                    psLink.setInt(1, requestId);
                    psLink.setInt(2, existingId);
                    psLink.executeUpdate();
                } else {
                    psIns.setInt(1, branch);
                    psIns.setInt(2, schShiftId);
                    psIns.setInt(3, positionId);
                    psIns.setDate(4, schDate);
                    psIns.setInt(5, requestId);
                    psIns.executeUpdate();
                }
            }
        }
    }

    /**
     * Tìm position_id mặc định của nhân viên (dùng khi ca trong lịch
     * không có position_id).
     */
    private int findDefaultPositionId(Connection c, int userId)
            throws SQLException {

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

    // 7. Kiểm tra quota còn đủ để duyệt đơn hay không (đơn vị GIỜ).
    //
    // Quy ước "đã cam kết" - GIỐNG HỆT với LeaveBalanceDAO.getUsedHours:
    //   used = used_hours (đơn APPROVED) + tổng giờ các đơn PENDING khác
    //
    // - Không có dòng balance cho user/loại nghỉ/năm => chưa được cấp quota,
    //   coi như không giới hạn (khớp với logic kiểm tra lúc tạo đơn).
    // - Nếu có dòng balance thì total_hours là trần cứng: KHÔNG được vượt.
    //
    // Tham số excludeRequestId = id của đơn đang duyệt, để không tính
    // trùng chính đơn đó vào phần PENDING.
    private boolean hasEnoughBalance(
            Connection c,
            int userId,
            int leaveTypeId,
            double totalHours,
            int year,
            int excludeRequestId) throws SQLException {

        String sql = "SELECT "
                + "COALESCE(lb.total_hours, "
                + "  lb.total_days * ep.standard_hours_per_day) AS totalHours, "
                + "COALESCE(lb.used_hours, "
                + "  lb.used_days * ep.standard_hours_per_day) AS usedHours, "
                + "COALESCE((SELECT SUM(lr.total_hours) FROM leave_requests lr "
                + "  WHERE lr.user_id = lb.user_id "
                + "  AND lr.leave_type_id = lb.leave_type_id "
                + "  AND YEAR(lr.start_date) = lb.year "
                + "  AND lr.status = 'PENDING' "
                + "  AND lr.id <> ?), 0) AS pendingHours "
                + "FROM leave_balances lb "
                + "JOIN employee_profiles ep ON ep.user_id = lb.user_id "
                + "WHERE lb.user_id = ? AND lb.leave_type_id = ? "
                + "AND lb.year = ? "
                + "FOR UPDATE";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, excludeRequestId);
            ps.setInt(2, userId);
            ps.setInt(3, leaveTypeId);
            ps.setInt(4, year);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    // Chưa cấp quota => không giới hạn.
                    // UPDATE used_hours sau đó không khớp dòng nào => no-op.
                    return true;
                }

                double total = rs.getDouble("totalHours");
                double used = rs.getDouble("usedHours");
                double pending = rs.getDouble("pendingHours");

                // total = 0 nghĩa là loại nghỉ không giới hạn
                // (ví dụ nghỉ không lương) -> vẫn duyệt, nhưng không
                // phải trừ quota vì total = 0.
                if (total <= 0) {
                    return true;
                }

                return (used + pending + totalHours) <= total + 0.0001;
            }
        }
    }

    /**
     * Khớp lại các đơn nghỉ phép đã DUYỆT với lịch làm việc vừa
     * được publish.
     *
     * <h3>Vì sao cần?</h3>
     * Part-time có thể xin nghỉ TRƯỚC khi lịch tuần đó được publish
     * (tick theo ca cố định). Khi Store Manager publish lịch, hệ thống
     * phải:
     *   <ol>
     *     <li>Đánh dấu ca tương ứng thành {@code ON_LEAVE}.</li>
     *     <li>Đưa ca đó vào {@code open_shifts} để tìm người cover.</li>
     *   </ol>
     * Nếu không làm bước này, đơn đã duyệt sẽ không khớp với lịch thật
     * và ca đó vẫn bị tính là đang đi làm.
     *
     * @param branchId  chi nhánh vừa publish
     * @param startDate ngày bắt đầu tuần
     * @param endDate   ngày kết thúc tuần
     * @return số ca đã được khớp
     */
    public int reconcileApprovedLeaves(
            int branchId,
            java.sql.Date startDate,
            java.sql.Date endDate) {

        Connection c = null;
        try {
            c = connect();
            c.setAutoCommit(false);

            // Các đơn đã duyệt có chi tiết ca trong khoảng tuần.
            String findSql = "SELECT DISTINCT lr.id AS requestId, "
                    + "lr.user_id AS userId, lrs.work_date AS workDate, "
                    + "lrs.shift_id AS shiftId "
                    + "FROM leave_requests lr "
                    + "JOIN leave_request_shifts lrs "
                    + "  ON lrs.leave_request_id = lr.id "
                    + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
                    + "WHERE lr.status = 'APPROVED' "
                    + "AND ep.home_branch_id = ? "
                    + "AND lrs.work_date BETWEEN ? AND ?";

            List<Object[]> targets = new ArrayList<>();

            try (PreparedStatement ps = c.prepareStatement(findSql)) {
                ps.setInt(1, branchId);
                ps.setDate(2, startDate);
                ps.setDate(3, endDate);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        targets.add(new Object[]{
                                rs.getInt("requestId"),
                                rs.getInt("userId"),
                                rs.getDate("workDate"),
                                rs.getInt("shiftId")
                        });
                    }
                }
            }

            if (targets.isEmpty()) {
                c.commit();
                return 0;
            }

            int matched = 0;

            String markSql = "UPDATE shift_schedules "
                    + "SET status = 'ON_LEAVE' "
                    + "WHERE user_id = ? AND shift_id = ? "
                    + "AND work_date = ? AND status = 'PUBLISHED'";

            String findOpen = "SELECT id FROM open_shifts "
                    + "WHERE branch_id = ? AND shift_id = ? "
                    + "AND work_date = ? AND status = 'OPEN' "
                    + "ORDER BY id LIMIT 1";

            String linkOpen = "UPDATE open_shifts "
                    + "SET leave_request_id = ? WHERE id = ?";

            String insertOpen = "INSERT INTO open_shifts "
                    + "(branch_id, shift_id, position_id, work_date, "
                    + "status, leave_request_id) "
                    + "VALUES (?, ?, ?, ?, 'OPEN', ?)";

            // Tập các đơn bị ảnh hưởng -> cần tính lại giờ nghỉ.
            Set<Integer> touchedRequests = new HashSet<>();

            try (PreparedStatement psMark = c.prepareStatement(markSql);
                 PreparedStatement psFind = c.prepareStatement(findOpen);
                 PreparedStatement psLink = c.prepareStatement(linkOpen);
                 PreparedStatement psIns = c.prepareStatement(insertOpen)) {

                for (Object[] t : targets) {
                    int requestId = (Integer) t[0];
                    int userId = (Integer) t[1];
                    java.sql.Date workDate = (java.sql.Date) t[2];
                    int shiftId = (Integer) t[3];

                    // Ca đã ON_LEAVE rồi -> không cần xử lý lại.
                    int alreadyOnLeave = countScalar(
                            c, "SELECT COUNT(*) FROM shift_schedules "
                            + "WHERE user_id = ? AND shift_id = ? "
                            + "AND work_date = ? AND status = 'ON_LEAVE'",
                            userId, shiftId, workDate);

                    if (alreadyOnLeave > 0) {
                        continue;
                    }

                    // Ca có tồn tại trong lịch vừa publish không?
                    int scheduleId = findSchedule(
                            c, userId, shiftId, workDate);
                    int positionId = findPosition(
                            c, scheduleId, userId);

                    if (scheduleId <= 0 || positionId <= 0) {
                        continue;   // lịch chưa khớp -> bỏ qua
                    }

                    psMark.setInt(1, userId);
                    psMark.setInt(2, shiftId);
                    psMark.setDate(3, workDate);
                    if (psMark.executeUpdate() == 0) {
                        continue;
                    }

                    matched++;
                    touchedRequests.add(requestId);

                    // Cập nhật giờ của ca trong bảng chi tiết theo
                    // thời lượng THỰC TẾ của ca trong bảng shifts.
                    // (Đơn có thể được tạo khi lịch chưa publish, lúc
                    // đó giờ chỉ là ước lượng theo ca cố định.)
                    updateDetailHours(
                            c, requestId, shiftId, workDate);

                    // Đưa vào ca trống (liên kết nếu đã có, tránh trùng)
                    int existingId = -1;
                    psFind.setInt(1, branchId);
                    psFind.setInt(2, shiftId);
                    psFind.setDate(3, workDate);
                    try (ResultSet rs = psFind.executeQuery()) {
                        if (rs.next()) {
                            existingId = rs.getInt(1);
                        }
                    }

                    if (existingId > 0) {
                        psLink.setInt(1, requestId);
                        psLink.setInt(2, existingId);
                        psLink.executeUpdate();
                    } else {
                        psIns.setInt(1, branchId);
                        psIns.setInt(2, shiftId);
                        psIns.setInt(3, positionId);
                        psIns.setDate(4, workDate);
                        psIns.setInt(5, requestId);
                        psIns.executeUpdate();
                    }
                }
            }

            // Tính lại giờ nghỉ cho các đơn vừa được khớp.
            // Lý do: part-time có thể xin nghỉ TRƯỚC khi lịch được
            // publish, lúc đó giờ nghỉ được ước lượng theo ca cố định.
            // Khi lịch thật có hiệu lực, thời lượng ca có thể khác ->
            // phải cập nhật total_hours và hoàn lại phần chênh lệch
            // trong quota, nếu không NV sẽ bị trừ quota sai.
            resyncRequestHours(c, touchedRequests);

            c.commit();
            return matched;

        } catch (Exception e) {
            if (c != null) {
                try {
                    c.rollback();
                } catch (SQLException re) {
                    // ignore
                }
            }
            throw new IllegalStateException(
                    "Cannot reconcile approved leaves", e);
        } finally {
            if (c != null) {
                try {
                    c.setAutoCommit(true);
                    c.close();
                } catch (SQLException e) {
                    // ignore
                }
            }
        }
    }

    /**
     * Tính lại giờ nghỉ của các đơn đã duyệt sau khi lịch được publish.
     *
     * <h3>Vì sao cần?</h3>
     * Part-time có thể xin nghỉ TRƯỚC khi lịch tuần đó được publish.
     * Lúc đó hệ thống ước lượng giờ nghỉ theo ca cố định
     * ({@code getFixedShiftOptions}), ví dụ 5 giờ/ca. Khi lịch thật
     * được publish, thời lượng ca thực tế có thể khác (ví dụ ca gộp
     * 8 giờ) -> {@code total_hours} của đơn và quota đã trừ sẽ SAI.
     *
     * <p>Hàm này:
     * <ol>
     *   <li>Tính lại tổng giờ nghỉ của đơn từ bảng
     *       {@code leave_request_shifts} (đã cập nhật theo ca thật).</li>
     *   <li>Cập nhật {@code leave_requests.total_hours}.</li>
     *   <li>Hoàn lại phần chênh lệch trong quota (nếu giờ thực nhỏ hơn
     *       giờ ước lượng thì hoàn lại cho NV; nếu lớn hơn thì trừ
     *       thêm, nhưng không để quota âm).</li>
     * </ol>
     *
     * @param c        connection (đang trong transaction)
     * @param requestIds các id đơn cần tính lại
     */
    private void resyncRequestHours(Connection c, Set<Integer> requestIds)
            throws SQLException {

        if (requestIds == null || requestIds.isEmpty()) {
            return;
        }

        for (Integer requestId : requestIds) {
            // Giờ nghỉ mới = tổng giờ trong bảng chi tiết ca.
            // Chi tiết được cập nhật ở bước đánh dấu ON_LEAVE
            // (xem resyncDetailHours).
            double newHours = countScalarDouble(
                    c, "SELECT COALESCE(SUM(hours), 0) "
                    + "FROM leave_request_shifts "
                    + "WHERE leave_request_id = ?",
                    requestId);

            // Giờ cũ đã ghi trong đơn.
            double oldHours = countScalarDouble(
                    c, "SELECT COALESCE(total_hours, 0) "
                    + "FROM leave_requests WHERE id = ?",
                    requestId);

            double diff = newHours - oldHours;
            if (Math.abs(diff) < 0.0001) {
                continue;   // không có chênh lệch -> khỏi làm gì
            }

            // Cập nhật giờ trong đơn.
            try (PreparedStatement ps = c.prepareStatement(
                    "UPDATE leave_requests "
                    + "SET total_hours = ? WHERE id = ?")) {
                ps.setDouble(1, newHours);
                ps.setInt(2, requestId);
                ps.executeUpdate();
            }

            // Lấy thông tin đơn để hoàn lại quota.
            int userId = -1;
            int leaveTypeId = -1;
            int year = 0;

            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT user_id, leave_type_id, "
                    + "YEAR(start_date) AS leaveYear "
                    + "FROM leave_requests WHERE id = ?")) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                        leaveTypeId = rs.getInt("leave_type_id");
                        year = rs.getInt("leaveYear");
                    }
                }
            }

            if (userId < 0) {
                continue;
            }

            // Hoàn lại / trừ thêm phần chênh lệch trong quota.
            // used_hours được giữ >= 0 để không xảy ra quota âm.
            try (PreparedStatement ps = c.prepareStatement(
                    "UPDATE leave_balances lb "
                    + "JOIN employee_profiles ep ON ep.user_id = lb.user_id "
                    + "SET lb.used_hours = GREATEST(0, "
                    + "  COALESCE(lb.used_hours, 0) - ?), "
                    + "lb.used_days = GREATEST(0, lb.used_days - "
                    + "  FLOOR(? / ep.standard_hours_per_day)) "
                    + "WHERE lb.user_id = ? AND lb.leave_type_id = ? "
                    + "AND lb.year = ?")) {

                ps.setDouble(1, diff);
                ps.setDouble(2, diff);
                ps.setInt(3, userId);
                ps.setInt(4, leaveTypeId);
                ps.setInt(5, year);
                ps.executeUpdate();
            }
        }
    }

    /**
     * Cập nhật giờ của một ca trong bảng chi tiết theo thời lượng
     * thực tế lấy từ bảng {@code shifts}.
     *
     * <p>Áp dụng khi lịch được publish sau khi đơn đã duyệt: giờ
     * lúc tạo đơn chỉ là ước lượng theo ca cố định, cần sửa lại
     * theo ca thật để quota được trừ chính xác.
     */
    private void updateDetailHours(
            Connection c,
            int requestId,
            int shiftId,
            java.sql.Date workDate) throws SQLException {

        String sql = "UPDATE leave_request_shifts lrs "
                + "JOIN shifts s ON s.id = lrs.shift_id "
                + "SET lrs.hours = TIMESTAMPDIFF(MINUTE, "
                + "  s.start_time, s.end_time) / 60.0, "
                + "lrs.shift_name = s.name "
                + "WHERE lrs.leave_request_id = ? "
                + "AND lrs.shift_id = ? AND lrs.work_date = ?";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, shiftId);
            ps.setDate(3, workDate);
            ps.executeUpdate();
        }
    }

    /**
     * Đếm số thực theo 1 câu SQL (trả về 0 nếu không có dòng).
     */
    private double countScalarDouble(
            Connection c, String sql, Object... params)
            throws SQLException {

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        }

        return 0;
    }

    /**
     * Tìm id của ca trong lịch (PUBLISHED) theo nhân viên + ca + ngày.
     */
    private int findSchedule(
            Connection c,
            int userId,
            int shiftId,
            java.sql.Date workDate) throws SQLException {

        String sql = "SELECT id FROM shift_schedules "
                + "WHERE user_id = ? AND shift_id = ? "
                + "AND work_date = ? AND status = 'PUBLISHED' "
                + "LIMIT 1";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, shiftId);
            ps.setDate(3, workDate);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return -1;
    }

    /**
     * Lấy position_id của ca trong lịch (fallback về position của nhân viên).
     */
    private int findPosition(
            Connection c,
            int scheduleId,
            int userId) throws SQLException {

        if (scheduleId > 0) {
            String sql = "SELECT COALESCE(position_id, 0) "
                    + "FROM shift_schedules WHERE id = ?";

            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, scheduleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return rs.getInt(1);
                    }
                }
            }
        }

        return findDefaultPositionId(c, userId);
    }

    /**
     * Đếm số bản ghi thỏa điều kiện (dùng connection hiện tại).
     */
    private int countScalar(
            Connection c,
            String sql,
            Object... params) throws SQLException {

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    // 8. Mô tả lý do duyệt/từ chối thất bại để hiển thị cho Store Manager.
    public String getReviewFailureReason(
            int requestId,
            int branchId,
            boolean approve) {

        String sql = "SELECT lr.status, "
                + "COALESCE(lr.total_hours, 0) AS totalHours, "
                + "ep.home_branch_id AS branchId, "
                + "lr.leave_type_id AS leaveTypeId, "
                + "YEAR(lr.start_date) AS leaveYear "
                + "FROM leave_requests lr "
                + "JOIN employee_profiles ep ON ep.user_id = lr.user_id "
                + "WHERE lr.id = ?";

        try (Connection c = connect();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return "Không tìm thấy đơn nghỉ phép này.";
                }

                String status = rs.getString("status");
                int reqBranchId = rs.getInt("branchId");
                int leaveTypeId = rs.getInt("leaveTypeId");
                int leaveYear = rs.getInt("leaveYear");
                double totalHours = rs.getDouble("totalHours");

                if (reqBranchId != branchId) {
                    return "Đơn này không thuộc chi nhánh của bạn.";
                }

                if (!"PENDING".equals(status)) {
                    return "Đơn đã được xử lý (trạng thái: "
                        + status + ").";
                }

                if (approve) {
                    double total = 0;
                    double used = 0;
                    double pending = 0;

                    String balSql = "SELECT "
                            + "COALESCE(lb.total_hours, "
                            + "  lb.total_days * ep.standard_hours_per_day) "
                            + "  AS totalHours, "
                            + "COALESCE(lb.used_hours, "
                            + "  lb.used_days * ep.standard_hours_per_day) "
                            + "  AS usedHours, "
                            + "COALESCE((SELECT SUM(lr2.total_hours) "
                            + "  FROM leave_requests lr2 "
                            + "  WHERE lr2.user_id = lb.user_id "
                            + "  AND lr2.leave_type_id = lb.leave_type_id "
                            + "  AND YEAR(lr2.start_date) = lb.year "
                            + "  AND lr2.status = 'PENDING' "
                            + "  AND lr2.id <> lr.id), 0) AS pendingHours "
                            + "FROM leave_balances lb "
                            + "JOIN employee_profiles ep "
                            + "  ON ep.user_id = lb.user_id "
                            + "JOIN leave_requests lr ON lr.id = ? "
                            + "WHERE lb.user_id = lr.user_id "
                            + "AND lb.leave_type_id = lr.leave_type_id "
                            + "AND lb.year = YEAR(lr.start_date)";

                    try (PreparedStatement bps =
                            c.prepareStatement(balSql)) {
                        bps.setInt(1, requestId);

                        try (ResultSet brs = bps.executeQuery()) {
                            if (brs.next()) {
                                total = brs.getDouble("totalHours");
                                used = brs.getDouble("usedHours");
                                pending = brs.getDouble("pendingHours");
                            }
                        }
                    }

                    double committed = used + pending;

                    if (total > 0
                            && committed + totalHours > total + 0.0001) {
                        return "Nhân viên đã vượt quota: còn "
                            + formatHours(total - committed)
                            + " giờ nhưng đơn này dùng "
                            + formatHours(totalHours) + " giờ.";
                    }
                }

                return "Không thể thực hiện. Vui lòng kiểm tra lại "
                    + "trạng thái đơn.";
            }

        } catch (Exception e) {
            return "Không thể thực hiện. Vui lòng kiểm tra lại trạng thái đơn.";
        }
    }

    // ============================================================
    // HỖ TRỢ "C" - đọc chi tiết ca
    // ============================================================

    /**
     * Lấy chi tiết ca của một đơn (dùng chung connection hiện tại).
     */
    private List<LeaveRequestShift> loadShiftDetails(
            Connection c, int requestId) throws SQLException {

        List<LeaveRequestShift> list = new ArrayList<>();

        String sql = "SELECT lrs.work_date AS workDate, "
                + "lrs.shift_id AS shiftId, "
                + "lrs.shift_name AS shiftName, lrs.hours "
                + "FROM leave_request_shifts lrs "
                + "WHERE lrs.leave_request_id = ? "
                + "ORDER BY lrs.work_date";

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LeaveRequestShift d = new LeaveRequestShift();
                    d.setLeaveRequestId(requestId);
                    d.setWorkDate(rs.getDate("workDate"));
                    d.setShiftId(rs.getInt("shiftId"));
                    d.setShiftName(rs.getString("shiftName"));
                    d.setHours(rs.getDouble("hours"));
                    list.add(d);
                }
            }
        }

        return list;
    }

    /**
     * Lấy chi tiết ca của một đơn (dùng ngoài transaction).
     */
    public List<LeaveRequestShift> getShiftDetails(int requestId) {
        return new LeaveShiftDetailDAO().getByRequestId(requestId);
    }

    /**
     * Định dạng giờ cho thông báo (10.0 -> "10", 7.5 -> "7.5").
     */
    private String formatHours(double hours) {
        if (hours == Math.floor(hours)) {
            return String.valueOf((long) hours);
        }
        return String.valueOf(Math.round(hours * 100.0) / 100.0);
    }
}
