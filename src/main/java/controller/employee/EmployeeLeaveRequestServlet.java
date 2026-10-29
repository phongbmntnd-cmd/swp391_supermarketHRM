package controller.employee;

import dao.EmployeeProfileDAO;
import dao.LeaveBalanceDAO;
import dao.LeaveRequestDAO;
import dao.LeaveShiftOptionDAO;
import dao.LeaveTypeDAO;
import dao.ShiftChangeRequestDAO;
import model.EmployeeProfile;
import model.LeaveShiftSelection;
import model.User;
import service.LeaveHoursCalculator;
import service.LeaveNoticeValidator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Màn hình nhân viên xin nghỉ phép - mô hình "C trên nền B".
 *
 * <h3>Full-time: nhập theo NGÀY</h3>
 * Nhân viên chọn từ ngày - đến ngày. Hệ thống tự quy ra các ca đã xếp
 * trong khoảng đó và tính giờ nghỉ theo thời lượng thực của từng ca.
 *
 * <h3>Part-time: nhập theo CA</h3>
 * Nhân viên tick đúng những ca muốn nghỉ trong tuần. Giờ nghỉ = tổng
 * thời lượng các ca được tick (ví dụ ca Tối 5h -> nghỉ 1 ngày = 5 giờ).
 *
 * <h3>Đơn vị đo chuẩn: GIỜ</h3>
 * Cả hai loại nhân viên đều so sánh quota theo giờ, nên báo cáo tổng
 * hợp nhất quán và khớp với cách tính lương.
 */
@WebServlet(
    name = "EmployeeLeaveRequestServlet",
    urlPatterns = {"/employee/leave-request"}
)
public class EmployeeLeaveRequestServlet extends HttpServlet {

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null
                : (User) session.getAttribute("account");
    }

    /**
     * Nhân viên có phải PART_TIME / CASUAL không (dùng ca lẻ) hay không.
     */
    private boolean isPartTime(EmployeeProfile profile) {
        if (profile == null || profile.getEmployeeType() == null) {
            return false;
        }
        String t = profile.getEmployeeType().trim().toUpperCase();
        return "PART_TIME".equals(t) || "CASUAL".equals(t);
    }

    private void showPage(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            LeaveTypeDAO typeDao = new LeaveTypeDAO();
            LeaveBalanceDAO balanceDao = new LeaveBalanceDAO();
            LeaveRequestDAO requestDao = new LeaveRequestDAO();
            EmployeeProfileDAO profileDao = new EmployeeProfileDAO();
            LeaveShiftOptionDAO optionDao = new LeaveShiftOptionDAO();

            EmployeeProfile profile =
                    profileDao.getProfileByUserId(user.getId());
            boolean partTime = isPartTime(profile);

            req.setAttribute("leaveTypes", typeDao.getAll());

            req.setAttribute(
                "myBalances",
                balanceDao.getMyBalances(
                    user.getId(),
                    LocalDate.now().getYear()
                )
            );

            // Tổng thời gian nghỉ theo từng loại (đã duyệt / chờ duyệt
            // / tổng cộng) trong năm hiện tại.
            req.setAttribute(
                "myLeaveSummary",
                balanceDao.getUserLeaveTimeSummary(
                    user.getId(),
                    LocalDate.now().getYear()
                )
            );

            // Định nghĩa ca (sáng/chiều/tối) kèm thời lượng để hiển thị
            // trong phần quy định.
            req.setAttribute(
                "shiftDefinitions",
                optionDao.getShiftDefinitions()
            );

            req.setAttribute(
                "myRequests",
                requestDao.getMyRequests(user.getId())
            );

            // Thông tin loại nhân viên để JSP render đúng form
            req.setAttribute("isPartTime", partTime);            req.setAttribute("employeeType",
                    profile == null ? "FULL_TIME"
                            : profile.getEmployeeType());
            req.setAttribute("standardHoursPerDay",
                    profile == null ? 10.0
                            : profile.getStandardHoursPerDay());

            // Danh sách ca để part-time tick
            if (partTime) {
                // Cửa sổ 4 tuần: tuần hiện tại + 3 tuần tới.
                // Tuần hiện tại đã có lịch -> tick được ca thật.
                // Các tuần sau chưa publish -> tick ca cố định theo ngày.
                // Cửa sổ rộng để part-time có thể xin nghỉ trước hạn
                // (ANNUAL yêu cầu báo trước 5 ngày).
                LocalDate weekStart = LocalDate.now()
                        .with(TemporalAdjusters.previousOrSame(
                                DayOfWeek.MONDAY));
                LocalDate windowEnd = weekStart.plusDays(27);

                req.setAttribute("leaveWeekStart",
                        weekStart.toString());

                List<Map<String, Object>> assigned =
                        optionDao.getAssignedShifts(
                                user.getId(), weekStart, windowEnd);

                // Ca cố định của nhân viên (dùng để dựng lịch tuần
                // chưa được publish).
                List<Map<String, Object>> fixed =
                        optionDao.getFixedShiftOptions(
                                profile.getShiftType());

                req.setAttribute("assignedShifts", assigned);
                req.setAttribute("fixedShiftOptions", fixed);

                // Tuần hiện tại đã có lịch publish hay chưa?
                boolean published = optionDao.isWeekPublished(
                        profile.getHomeBranchId(), weekStart);

                req.setAttribute("hasPublishedSchedule", published);

                // Danh sách ca DUY NHẤT để hiển thị (không trùng lặp):
                //   - Ca đã được xếp trong lịch -> tick được thật.
                //   - Ca cố định cho các ngày CHƯA có lịch -> tick được
                //     theo ca cố định, hệ thống sẽ khớp lại khi publish.
                req.setAttribute("shiftChoices",
                        buildShiftChoices(assigned, fixed, weekStart,
                                windowEnd));
            } else {
                req.setAttribute("assignedShifts", new ArrayList<>());
                req.setAttribute("fixedShiftOptions", new ArrayList<>());
                req.setAttribute("hasPublishedSchedule", false);
            }

            // Badge số đơn đổi ca đang chờ mình phản hồi (sidebar)
            req.setAttribute(
                "incomingSwapCount",
                new ShiftChangeRequestDAO()
                    .countIncomingShiftRequests(user.getId())
            );

            req.getRequestDispatcher(
                "/WEB-INF/views/employee/leave-request.jsp"
            ).forward(req, resp);

        } catch (IllegalStateException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (user.getRoleId() != 5) {
            resp.sendError(403);
            return;
        }

        showPage(req, resp, user);
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User user = currentUser(req);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (user.getRoleId() != 5) {
            resp.sendError(403);
            return;
        }

        String action = req.getParameter("action");

        if ("cancel".equals(action)) {
            handleCancel(req, resp, user);
            return;
        }

        handleCreate(req, resp, user);
    }

    private void handleCreate(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            String leaveTypeRaw = req.getParameter("leaveTypeId");

            if (leaveTypeRaw == null || leaveTypeRaw.trim().isEmpty()) {
                req.setAttribute(
                    "error",
                    "Vui lòng chọn loại nghỉ phép."
                );
                showPage(req, resp, user);
                return;
            }

            int leaveTypeId = Integer.parseInt(leaveTypeRaw.trim());

            EmployeeProfileDAO profileDao = new EmployeeProfileDAO();
            EmployeeProfile profile =
                    profileDao.getProfileByUserId(user.getId());
            boolean partTime = isPartTime(profile);
            double standardHours =
                    (profile == null || profile.getStandardHoursPerDay() <= 0)
                            ? 10.0
                            : profile.getStandardHoursPerDay();

            // Lý do
            String reason = req.getParameter("reason");
            if (reason == null
                || reason.trim().isEmpty()
                || reason.trim().length() > 500) {
                req.setAttribute(
                    "error",
                    "Vui lòng nhập lý do (tối đa 500 ký tự)."
                );
                showPage(req, resp, user);
                return;
            }

            LeaveHoursCalculator.Result calc;
            LocalDate startDate;
            LocalDate endDate;

            if (partTime) {
                // Part-time: tick ca
                Object[] partTimeData =
                        buildPartTimeCalculation(
                                req, resp, user, leaveTypeId);
                if (partTimeData == null) {
                    return;   // đã set error và render
                }
                calc = (LeaveHoursCalculator.Result) partTimeData[0];
                startDate = (LocalDate) partTimeData[1];
                endDate = (LocalDate) partTimeData[2];
            } else {
                // Full-time: nhập khoảng ngày
                Object[] fullTimeData =
                        buildFullTimeCalculation(
                                req, resp, user, leaveTypeId,
                                standardHours);
                if (fullTimeData == null) {
                    return;
                }
                calc = (LeaveHoursCalculator.Result) fullTimeData[0];
                startDate = (LocalDate) fullTimeData[1];
                endDate = (LocalDate) fullTimeData[2];
            }

            // Kiểm tra quota theo GIỜ
            int year = startDate.getYear();

            LeaveBalanceDAO balanceDao = new LeaveBalanceDAO();
            double balanceTotal = balanceDao.getTotalHours(
                user.getId(), leaveTypeId, year
            );

            if (balanceTotal > 0) {
                double balanceUsed = balanceDao.getUsedHours(
                    user.getId(), leaveTypeId, year
                );

                if (balanceUsed + calc.totalHours > balanceTotal + 0.0001) {
                    req.setAttribute(
                        "error",
                        "Không đủ quota. Bạn chỉ còn "
                        + formatHours(balanceTotal - balanceUsed)
                        + " giờ nhưng đơn này dùng "
                        + formatHours(calc.totalHours) + " giờ."
                    );
                    showPage(req, resp, user);
                    return;
                }
            }

            LeaveRequestDAO dao = new LeaveRequestDAO();

            // Chống trùng lặp: một ca/ngày làm việc chỉ được chiếm
            // bởi MỘT đơn nghỉ (đang chờ duyệt hoặc đã duyệt).
            LeaveRequestDAO.LeaveConflict conflict =
                    dao.findConflictingRequest(
                            user.getId(),
                            calc.shiftDetails,
                            startDate,
                            endDate);

            if (conflict != null) {
                String msg = "Bạn đã có đơn nghỉ phép cho ca ngày "
                        + formatVn(conflict.getDate())
                        + ". Vui lòng hủy đơn cũ trước khi gửi đơn mới.";
                if (conflict.isWholeDay()) {
                    msg = "Ngày "
                        + formatVn(conflict.getDate())
                        + " đã có đơn nghỉ phép khác "
                        + "(đơn #" + conflict.getRequestId()
                        + "). Vui lòng hủy đơn cũ trước khi gửi đơn mới.";
                }
                req.setAttribute("error", msg);
                showPage(req, resp, user);
                return;
            }

            // Tạo đơn (kèm chi tiết ca)
            int requestId = dao.createRequest(
                user.getId(),
                leaveTypeId,
                startDate,
                endDate,
                calc.totalDays,
                calc.totalHours,
                reason.trim(),
                calc.shiftDetails
            );

            resp.sendRedirect(
                req.getContextPath()
                + "/employee/leave-request?"
                + (requestId > 0 ? "success=1" : "invalid=1")
            );

        } catch (LeaveRequestDAO.DuplicateLeaveException e) {
            LeaveRequestDAO.LeaveConflict c = e.getConflict();
            String msg = "Bạn đã có đơn nghỉ phép cho ca ngày "
                    + formatVn(c.getDate())
                    + ". Vui lòng hủy đơn cũ trước khi gửi đơn mới.";
            if (c.isWholeDay()) {
                msg = "Ngày " + formatVn(c.getDate())
                        + " đã có đơn nghỉ phép khác (đơn #"
                        + c.getRequestId()
                        + "). Vui lòng hủy đơn cũ trước khi gửi đơn mới.";
            }
            req.setAttribute("error", msg);
            showPage(req, resp, user);

        } catch (NumberFormatException e) {
            req.setAttribute(
                "error",
                "Vui lòng chọn loại nghỉ phép hợp lệ."
            );
            showPage(req, resp, user);

        } catch (DateTimeParseException e) {
            req.setAttribute(
                "error",
                "Ngày không hợp lệ. Vui lòng chọn đúng định dạng (YYYY-MM-DD)."
            );
            showPage(req, resp, user);

        } catch (IllegalArgumentException e) {
            req.setAttribute(
                "error",
                "Thông tin ngày không hợp lệ."
            );
            showPage(req, resp, user);

        } catch (Exception e) {
            throw new ServletException(
                "Cannot create leave request", e
            );
        }
    }

    /**
     * Dựng danh sách ca để nhân viên part-time tick, KHÔNG trùng lặp.
     *
     * Quy tắc:
     *   - Ngày đã có ca được xếp (PUBLISHED) -> dùng ca thật.
     *   - Ngày chưa có lịch -> dùng ca cố định của nhân viên, gắn với
     *     đúng ngày đó (hệ thống sẽ khớp lại khi lịch được publish).
     *   - Ca đang ON_LEAVE -> hiển thị nhưng không tick được.
     *
     * @return list các map: workDate, shiftId, shiftName, hours,
     *         startTime, endTime, scheduled, onLeave
     */
    private List<Map<String, Object>> buildShiftChoices(
            List<Map<String, Object>> assigned,
            List<Map<String, Object>> fixed,
            LocalDate weekStart,
            LocalDate windowEnd) {

        Map<String, List<Map<String, Object>>> byDate =
                new LinkedHashMap<>();

        for (Map<String, Object> a : assigned) {
            LocalDate d = toLocalDate(a.get("workDate"));
            if (d == null) {
                continue;
            }
            byDate
                .computeIfAbsent(d.toString(),
                        k -> new ArrayList<>())
                .add(a);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        LocalDate today = LocalDate.now();

        for (LocalDate d = weekStart;
             !d.isAfter(windowEnd);
             d = d.plusDays(1)) {

            if (d.isBefore(today)) {
                continue;   // không cho xin nghỉ quá khứ
            }

            List<Map<String, Object>> real = byDate.get(d.toString());

            if (real != null && !real.isEmpty()) {
                for (Map<String, Object> r : real) {
                    Map<String, Object> row =
                            new LinkedHashMap<>(r);
                    row.put("workDate",
                            java.sql.Date.valueOf(d));
                    row.put("scheduled", true);
                    row.put("onLeave",
                            Boolean.TRUE.equals(r.get("onLeave")));
                    result.add(row);
                }
                continue;
            }

            // Chưa có lịch -> dựng ca cố định cho ngày này.
            for (Map<String, Object> f : fixed) {
                Map<String, Object> row =
                        new LinkedHashMap<>(f);
                row.put("workDate",
                        java.sql.Date.valueOf(d));
                row.put("scheduled", false);
                row.put("onLeave", false);
                result.add(row);
            }
        }

        return result;
    }

    /**
     * Chuyển giá trị ngày (java.sql.Date) về LocalDate.
     */
    private LocalDate toLocalDate(Object value) {
        if (value instanceof java.sql.Date) {
            return ((java.sql.Date) value).toLocalDate();
        }
        if (value instanceof LocalDate) {
            return (LocalDate) value;
        }
        if (value == null) {
            return null;
        }
        try {
            return LocalDate.parse(String.valueOf(value));
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Full-time: nhập khoảng ngày -> quy ra ca đã xếp trong khoảng đó.
     *
     * @return Object[]{Result, startDate, endDate} hoặc null nếu có lỗi
     *         (error đã được set và trang đã render).
     */
    private Object[] buildFullTimeCalculation(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user,
            int leaveTypeId,
            double standardHours) throws Exception {

        String startRaw = req.getParameter("startDate");
        String endRaw = req.getParameter("endDate");

        if (startRaw == null || startRaw.trim().isEmpty()
            || endRaw == null || endRaw.trim().isEmpty()) {
            req.setAttribute(
                "error",
                "Vui lòng chọn ngày bắt đầu và ngày kết thúc."
            );
            showPage(req, resp, user);
            return null;
        }

        LocalDate startDate = LocalDate.parse(startRaw.trim());
        LocalDate endDate = LocalDate.parse(endRaw.trim());

        if (startDate.isAfter(endDate)) {
            req.setAttribute(
                "error",
                "Ngày bắt đầu phải trước hoặc bằng ngày kết thúc."
            );
            showPage(req, resp, user);
            return null;
        }

        if (startDate.isBefore(LocalDate.now())) {
            req.setAttribute(
                "error",
                "Không thể xin nghỉ cho ngày trong quá khứ."
            );
            showPage(req, resp, user);
            return null;
        }

        // Kiểm tra hạn gửi đơn (riêng theo loại nhân viên)
        String noticeError = checkNoticeDeadline(
                leaveTypeId, startDate, false);
        if (noticeError != null) {
            req.setAttribute("error", noticeError);
            showPage(req, resp, user);
            return null;
        }

        LeaveHoursCalculator calculator = new LeaveHoursCalculator();
        LeaveHoursCalculator.Result calc = calculator.calculateFromSchedule(
                user.getId(), startDate, endDate, standardHours);

        if (calc.totalHours <= 0) {
            req.setAttribute(
                "error",
                "Không tính được số giờ nghỉ cho khoảng thời gian này. "
                + "Vui lòng liên hệ Store Manager."
            );
            showPage(req, resp, user);
            return null;
        }

        return new Object[]{calc, startDate, endDate};
    }

    /**
     * Part-time: tick các ca -> tính giờ theo thời lượng từng ca.
     *
     * @return Object[]{Result, startDate, endDate} hoặc null nếu có lỗi
     *         (error đã được set và trang đã render).
     */
    private Object[] buildPartTimeCalculation(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user,
            int leaveTypeId) throws Exception {

        String[] rawSelections = req.getParameterValues("selectedShifts");

        if (rawSelections == null || rawSelections.length == 0) {
            req.setAttribute(
                "error",
                "Vui lòng chọn ít nhất một ca để xin nghỉ."
            );
            showPage(req, resp, user);
            return null;
        }

        List<LeaveShiftSelection> selections = new ArrayList<>();
        LocalDate minDate = null;
        LocalDate maxDate = null;
        LocalDate pastDate = null;

        for (String raw : rawSelections) {
            LeaveShiftSelection sel = LeaveShiftSelection.parse(raw);
            if (sel == null) {
                continue;
            }
            // Chặn nghỉ trong quá khứ
            if (sel.getWorkDate().isBefore(LocalDate.now())) {
                if (pastDate == null
                    || sel.getWorkDate().isAfter(pastDate)) {
                    pastDate = sel.getWorkDate();
                }
                continue;
            }
            selections.add(sel);

            if (minDate == null || sel.getWorkDate().isBefore(minDate)) {
                minDate = sel.getWorkDate();
            }
            if (maxDate == null || sel.getWorkDate().isAfter(maxDate)) {
                maxDate = sel.getWorkDate();
            }
        }

        if (selections.isEmpty()) {
            req.setAttribute(
                "error",
                "Không có ca hợp lệ nào được chọn. "
                + (pastDate != null
                    ? "Không thể xin nghỉ cho ngày "
                        + formatVn(pastDate) + " trong quá khứ."
                    : "Vui lòng chọn lại các ca.")
            );
            showPage(req, resp, user);
            return null;
        }

        // Kiểm tra hạn gửi đơn cho TỪNG ca được chọn.
        // Mỗi ca có hạn riêng theo ngày của nó, nên phải validate
        // từng ca chứ không chỉ ca đầu tiên.
        String noticeError = new LeaveNoticeValidator().checkAll(
                leaveTypeId, distinctDates(selections), true);
        if (noticeError != null) {
            req.setAttribute("error", noticeError);
            showPage(req, resp, user);
            return null;
        }

        LeaveHoursCalculator calculator = new LeaveHoursCalculator();
        LeaveHoursCalculator.Result calc =
                calculator.calculateFromSelections(
                        selections,
                        calculator.getAllShifts());

        if (calc.totalHours <= 0) {
            req.setAttribute(
                "error",
                "Các ca đã chọn không có thời lượng hợp lệ. "
                + "Vui lòng liên hệ Store Manager."
            );
            showPage(req, resp, user);
            return null;
        }

        return new Object[]{calc, minDate, maxDate};
    }

    /**
     * Lấy danh sách các ngày (không trùng lặp) trong các ca được chọn.
     */
    private List<LocalDate> distinctDates(
            List<LeaveShiftSelection> selections) {

        Map<LocalDate, Boolean> seen = new LinkedHashMap<>();

        for (LeaveShiftSelection sel : selections) {
            seen.put(sel.getWorkDate(), Boolean.TRUE);
        }

        return new ArrayList<>(seen.keySet());
    }

    /**
     * Kiểm tra hạn chót gửi đơn.
     *
     * <h3>Luật "báo trước" (tối thiểu)</h3>
     * <ul>
     *   <li>Gửi SỚM luôn được - không giới hạn cửa sổ gửi đơn.</li>
     *   <li>Chỉ bị chặn khi gửi MUỘN hơn hạn.</li>
     *   <li>Hạn = ngày nghỉ trừ đi số giờ báo trước. Với loại nghỉ
     *       báo trước &gt;= 24 giờ, hạn được tính theo NGÀY lịch
     *       (ví dụ báo trước 2 ngày: nghỉ Thứ Hai thì gửi từ
     *       Thứ Bảy trở đi).</li>
     *   <li>Nghỉ ốm &amp; nghỉ tang: được làm đơn TRONG NGÀY,
     *       không kiểm tra hạn báo trước.</li>
     * </ul>
     *
     * @param leaveTypeId loại nghỉ
     * @param startDate   ngày bắt đầu nghỉ
     * @param isPartTime  dùng notice_hours_part_time hay không
     * @return thông báo lỗi, hoặc null nếu hợp lệ
     */
    private String checkNoticeDeadline(
            int leaveTypeId,
            LocalDate startDate,
            boolean isPartTime) {

        return new LeaveNoticeValidator()
                .check(leaveTypeId, startDate, isPartTime);
    }

    // Định dạng ngày kiểu Việt Nam: "Thứ Hai (02/06/2026)"
    // Chỉ số = DayOfWeek.getValue() - 1 (Thứ Hai = 1 ... Chủ Nhật = 7)
    private static final String[] VN_WEEKDAYS = {
        "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm",
        "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"
    };

    private String formatVn(LocalDate date) {
        String dd = date.getDayOfMonth() < 10
            ? "0" + date.getDayOfMonth()
            : String.valueOf(date.getDayOfMonth());

        String mm = date.getMonthValue() < 10
            ? "0" + date.getMonthValue()
            : String.valueOf(date.getMonthValue());

        return VN_WEEKDAYS[date.getDayOfWeek().getValue() - 1]
            + " (" + dd + "/" + mm + "/" + date.getYear() + ")";
    }

    // Định dạng số giờ (10.0 -> "10", 7.5 -> "7.5")
    private String formatHours(double hours) {
        if (hours == Math.floor(hours)) {
            return String.valueOf((long) hours);
        }
        return String.valueOf(Math.round(hours * 100.0) / 100.0);
    }

    // Định dạng ngày giờ kiểu Việt Nam: "Thứ Hai (02/06/2026) 08:00"
    private String formatVnTime(LocalDateTime dt) {
        String hh = dt.getHour() < 10
            ? "0" + dt.getHour()
            : String.valueOf(dt.getHour());

        String mm = dt.getMinute() < 10
            ? "0" + dt.getMinute()
            : String.valueOf(dt.getMinute());

        return formatVn(dt.toLocalDate()) + " " + hh + ":" + mm;
    }

    private void handleCancel(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            int requestId = Integer.parseInt(
                req.getParameter("requestId")
            );

            LeaveRequestDAO dao = new LeaveRequestDAO();
            boolean success = dao.cancelMyRequest(requestId, user.getId());

            resp.sendRedirect(
                req.getContextPath()
                + "/employee/leave-request?"
                + (success ? "success=1" : "invalid=1")
            );

        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid request id");

        } catch (Exception e) {
            throw new ServletException(
                "Cannot cancel leave request", e
            );
        }
    }
}
