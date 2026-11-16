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

        // Ca đã PUBLISHED tại CHÍNH vị trí + ca này thì không mở được
        // đăng ký ca bù nữa (lịch đã chốt).
        //
        // PHẢI giới hạn theo position_id + shift_id. Trước đây check ở
        // cấp CẢ CHI NHÁNH: chỉ cần BẤT KỲ ca nào khác (vị trí khác /
        // ca khác) đã publish ngày đó là chặn cả đăng ký ca bù cho
        // vị trí vẫn còn thiếu người -> sai nghiệp vụ.
        String publishedSql = "SELECT COUNT(*) FROM shift_schedules "
                + "WHERE branch_id = ? AND position_id = ? AND shift_id = ? "
                + "AND work_date = ? AND status = 'PUBLISHED'";
        // Chỉ tính ca CÒN HIỆU LỰC (DRAFT/PUBLISHED).
        // Ca ON_LEAVE = nhân viên đang nghỉ -> không chiếm slot,
        // ca CANCELLED -> đã bị hủy -> không chiếm slot.
        // Nếu không lọc, ca thiếu người sẽ bị coi là đã đủ người
        // -> không mở được đăng ký ca bù (sai logic).
        String assignedSql = "SELECT COUNT(*) FROM shift_schedules WHERE branch_id = ? AND position_id = ? AND shift_id = ? AND work_date = ? AND status IN ('DRAFT', 'PUBLISHED')";
        String requirementSql = "SELECT required_count FROM shift_requirements WHERE branch_id = ? AND position_id = ? AND shift_id = ? AND work_date = ? LIMIT 1";
        String upsertSql = "INSERT INTO supplementary_shift_opportunities "
                + "(branch_id, position_id, shift_id, work_date, registration_deadline, opened_by, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'OPEN') ON DUPLICATE KEY UPDATE "
                + "registration_deadline = VALUES(registration_deadline), opened_by = VALUES(opened_by), status = 'OPEN'";

        try (Connection connection = DBContext.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(publishedSql)) {
                statement.setInt(1, branchId);
                statement.setInt(2, positionId);
                statement.setInt(3, shiftId);
                statement.setDate(4, java.sql.Date.valueOf(date));
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
        // Lịch rảnh chỉ mang tính THAM KHẢO (NV khai báo "rảnh ca này"),
        // KHÔNG phải điều kiện chặn: khai báo rảnh ở một tuần khác /
        // còn tồn tại trong DB không nên chặn NV đăng ký ca bù.
        // -> Chỉ tính "đã bận" khi NV thực sự có lịch (DRAFT/PUBLISHED)
        //    trùng ca/ngày đó.
        String sql = "SELECT o.id, o.work_date, o.registration_deadline, p.title AS position_title, "
                + "s.name AS shift_name, s.start_time, s.end_time, a.id AS application_id, "
                + "(SELECT COUNT(*) FROM shift_schedules ss WHERE ss.user_id = ? AND ss.work_date = o.work_date AND ss.shift_id = o.shift_id AND ss.status IN ('DRAFT', 'PUBLISHED')) AS has_scheduled, "
                + "(SELECT COUNT(*) FROM employee_availabilities ea WHERE ea.user_id = ? AND ea.week_start_date = DATE_SUB(o.work_date, INTERVAL WEEKDAY(o.work_date) DAY) AND ea.day_of_week = UPPER(DAYNAME(o.work_date)) AND ea.shift_id = o.shift_id) AS has_availability "
                + "FROM supplementary_shift_opportunities o "
                + "JOIN positions p ON p.id = o.position_id JOIN shifts s ON s.id = o.shift_id "
                + "LEFT JOIN supplementary_shift_applications a ON a.opportunity_id = o.id AND a.user_id = ? "
                + "WHERE o.branch_id = ? AND (o.position_id = ? OR ? IS NULL) AND o.status = 'OPEN' "
                + "AND o.work_date >= CURDATE() AND o.registration_deadline > NOW() "
                // Lịch tại vị trí + ca này đã publish -> không còn mở
                // đăng ký ca bù cho ô này nữa.
                + "AND NOT EXISTS (SELECT 1 FROM shift_schedules published "
                + "WHERE published.branch_id = o.branch_id "
                + "AND published.position_id = o.position_id "
                + "AND published.shift_id = o.shift_id "
                + "AND published.work_date = o.work_date "
                + "AND published.status = 'PUBLISHED') "
                + "ORDER BY o.work_date, s.start_time";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setInt(2, userId);
            statement.setInt(3, userId);
            statement.setInt(4, branchId);
            statement.setInt(5, positionId);
            statement.setInt(6, positionId);
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
                    
                    boolean isApplied = result.getObject("application_id") != null;
                    boolean hasScheduled = result.getInt("has_scheduled") > 0;
                    boolean hasAvailability = result.getInt("has_availability") > 0;

                    row.put("applied", isApplied);
                    // Đã đăng ký rồi -> không đăng ký lại.
                    // Đã có lịch trùng ca/ngày -> không đăng ký được.
                    // Lịch rảnh khai báo -> KHÔNG chặn (chỉ hiển thị
                    // để NV biết ca này nằm trong lịch rảnh của mình).
                    row.put("hasConflict", isApplied || hasScheduled);
                    // Lịch rảnh đã khai báo cho ca này -> hiển thị
                    // nhãn "Đã khai báo rảnh" (thông tin, không chặn).
                    row.put("hasAvailability", hasAvailability);

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
                // NULL-SAFE: NV chưa có position_id vẫn được đăng ký
                // ca bù (giống các luồng khác).
                + "AND (ep.position_id IS NULL OR o.position_id = ep.position_id) "
                + "AND ep.employee_type IN ('PART_TIME', 'CASUAL') "
                + "AND u.status = 'ACTIVE' AND o.status = 'OPEN' AND o.work_date >= CURDATE() "
                + "AND o.registration_deadline > NOW() "
                // Ca đã PUBLISHED tại CHÍNH vị trí + ca này thì lịch đã
                // chốt -> không đăng ký ca bù được nữa.
                //
                // PHẢI giới hạn theo position_id + shift_id. Trước đây
                // check ở cấp CẢ CHI NHÁNH: chỉ cần ca khác (vị trí
                // khác / ca khác) đã publish ngày đó là chặn cả đăng
                // ký ca bù cho vị trí vẫn còn thiếu người -> sai.
                + "AND NOT EXISTS (SELECT 1 FROM shift_schedules published "
                + "WHERE published.branch_id = o.branch_id "
                + "AND published.position_id = o.position_id "
                + "AND published.shift_id = o.shift_id "
                + "AND published.work_date = o.work_date "
                + "AND published.status = 'PUBLISHED')";
        // Chỉ ca CÒN HIỆU LỰC mới tính là trùng lịch.
        // Ca ON_LEAVE = đang nghỉ (không đi làm) -> KHÔNG tính,
        // ca CANCELLED -> đã hủy -> KHÔNG tính.
        String conflictSql = "SELECT COUNT(*) FROM shift_schedules ss JOIN shifts existing_shift ON existing_shift.id = ss.shift_id "
                + "WHERE ss.user_id = ? AND ss.work_date = ? AND ss.status IN ('DRAFT', 'PUBLISHED') "
                + "AND existing_shift.start_time < ? AND existing_shift.end_time > ?";
        String heldSql = "SELECT COUNT(*) FROM temporary_transfer_employees e JOIN temporary_transfers t ON t.id = e.transfer_id "
                + "JOIN shifts existing_shift ON existing_shift.id = t.shift_id "
                + "WHERE e.employee_id = ? AND t.work_date = ? AND t.status = 'PENDING_HR' AND e.status = 'RESERVED' "
                + "AND existing_shift.start_time < ? AND existing_shift.end_time > ?";

        // Chồng lấn với CÁC ĐƠN ĐĂNG KÝ CA BÙ ĐANG CHỜ của chính
        // nhân viên. Nếu không check, NV có thể đăng ký 2 ca bù chồng
        // giờ nhau trong cùng ngày (vd "Ca Sáng" và "Ca Full-time
        // Sáng - Chiều") -> SM xếp cả 2 -> lịch trùng, lương sai.
        String pendingApplicationSql = "SELECT COUNT(*) "
                + "FROM supplementary_shift_applications a "
                + "JOIN supplementary_shift_opportunities o "
                + "  ON o.id = a.opportunity_id "
                + "JOIN shifts existing_shift ON existing_shift.id = o.shift_id "
                + "WHERE a.user_id = ? AND o.work_date = ? AND o.status = 'OPEN' "
                + "AND o.id <> ? "
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

            // Lịch rảnh đã khai báo KHÔNG phải điều kiện chặn.
            // Lịch rảnh là khai báo "rảnh ca này" dùng để gợi ý cho
            // Store Manager xếp ca; NV vẫn có quyền đăng ký ca bù
            // khi thực tế rảnh (ví dụ đồng nghiệp đã cover giúp).
            // Trước đây điều kiện này chặn nhầm -> NV không bao giờ
            // đăng ký được ca bù cho ca mình đã khai báo rảnh.
            if (!isAllowedFixedShift(shiftType, shiftName)
                    || hasOverlap(connection, conflictSql, userId, workDate, startTime, endTime)
                    || hasOverlap(connection, heldSql, userId, workDate, startTime, endTime)
                    || hasPendingApplicationOverlap(connection, pendingApplicationSql,
                            userId, workDate, opportunityId, startTime, endTime)) {
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

    /**
     * Nhân viên đã đăng ký ca bù khác CHỒNG GIỜ với ca này chưa?
     *
     * <p>Kiểm tra chồng lấn với các đơn đăng ký ca bù ĐANG CHỜ
     * ({@code supplementary_shift_applications} ->
     * {@code supplementary_shift_opportunities}).
     *
     * <p>Vì sao cần? Nếu không, nhân viên có thể đăng ký 2 ca bù
     * chồng lấn nhau trong cùng ngày (ví dụ "Ca Sáng" 07:00-12:00 và
     * "Ca Full-time Sáng - Chiều" 07:00-17:00). Khi đó Store Manager
     * xếp cả 2 ca vào lịch -> lịch trùng giờ, chấm công và tính
     * lương sai.
     *
     * @param excludeOpportunityId cơ hội đang xét (loại trừ chính nó)
     */
    private boolean hasPendingApplicationOverlap(Connection connection, String sql, int userId,
            java.sql.Date workDate, int excludeOpportunityId,
            java.sql.Time startTime, java.sql.Time endTime) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setDate(2, workDate);
            statement.setInt(3, excludeOpportunityId);
            statement.setTime(4, endTime);
            statement.setTime(5, startTime);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() && result.getInt(1) > 0;
            }
        }
    }

    /**
     * Kiểm tra ca có thuộc nhóm ca cố định của nhân viên không.
     *
     * <p>Dùng chung {@link util.ShiftTypeUtil} để khớp với logic trong
     * {@code ShiftChangeRequestDAO.fixedShiftOk(...)} (SQL). Trước đây
     * hai bên đánh giá {@code shift_type} khác nhau -> nhân viên part-time
     * linh hoạt ({@code PT_FLEXIBLE}) bị chặn ở màn hiển thị nhưng lại
     * đi qua ở bước duyệt.
     */
    private boolean isAllowedFixedShift(String shiftType, String shiftName) {
        return util.ShiftTypeUtil.isAllowedFixedShift(
                shiftType, shiftName);
    }
    
    /**
     * Kiểm tra xem ca làm việc này đã được mở đăng ký bổ sung và đang trong trạng thái OPEN hay chưa.
     */
    public boolean isSupplementaryOpened(int branchId, int positionId, int shiftId, String workDate) {
        String sql = "SELECT COUNT(*) FROM supplementary_shift_opportunities "
                + "WHERE branch_id = ? AND position_id = ? AND shift_id = ? AND work_date = ? AND status = 'OPEN'";
        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, branchId);
            statement.setInt(2, positionId);
            statement.setInt(3, shiftId);
            statement.setDate(4, java.sql.Date.valueOf(workDate));
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return result.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không thể kiểm tra trạng thái mở đăng ký bổ sung", e);
        }
        return false;
    }
}