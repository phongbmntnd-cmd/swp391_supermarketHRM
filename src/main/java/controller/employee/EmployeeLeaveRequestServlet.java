package controller.employee;

import dao.LeaveBalanceDAO;
import dao.LeaveRequestDAO;
import dao.LeaveTypeDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

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

    private void showPage(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            LeaveTypeDAO typeDao = new LeaveTypeDAO();
            LeaveBalanceDAO balanceDao = new LeaveBalanceDAO();
            LeaveRequestDAO requestDao = new LeaveRequestDAO();

            req.setAttribute(
                "leaveTypes",
                typeDao.getAll()
            );

            req.setAttribute(
                "myBalances",
                balanceDao.getMyBalances(
                    user.getId(),
                    LocalDate.now().getYear()
                )
            );

            req.setAttribute(
                "myRequests",
                requestDao.getMyRequests(user.getId())
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
            String startRaw = req.getParameter("startDate");
            String endRaw = req.getParameter("endDate");

            if (leaveTypeRaw == null || leaveTypeRaw.trim().isEmpty()) {
                req.setAttribute(
                    "error",
                    "Vui lòng chọn loại nghỉ phép."
                );
                showPage(req, resp, user);
                return;
            }

            if (startRaw == null || startRaw.trim().isEmpty()
                || endRaw == null || endRaw.trim().isEmpty()) {
                req.setAttribute(
                    "error",
                    "Vui lòng chọn ngày bắt đầu và ngày kết thúc."
                );
                showPage(req, resp, user);
                return;
            }

            int leaveTypeId = Integer.parseInt(leaveTypeRaw.trim());

            LocalDate startDate = LocalDate.parse(startRaw.trim());
            LocalDate endDate = LocalDate.parse(endRaw.trim());

            String reason = req.getParameter("reason");

            LeaveBalanceDAO balanceDao = new LeaveBalanceDAO();

            // Validate ngày
            if (startDate.isAfter(endDate)) {
                req.setAttribute(
                    "error",
                    "Ngày bắt đầu phải trước hoặc bằng ngày kết thúc."
                );
                showPage(req, resp, user);
                return;
            }

            if (startDate.isBefore(LocalDate.now())) {
                req.setAttribute(
                    "error",
                    "Không thể xin nghỉ cho ngày trong quá khứ."
                );
                showPage(req, resp, user);
                return;
            }

            // Quy định: mỗi loại nghỉ có thời hạn báo trước riêng
            // (notice_hours trong bảng leave_types).
            //   0  = gửi trong ngày được (không giới hạn)
            //   48 = phải báo trước 2 ngày (nghỉ phép năm)
            //   24 = phải báo trước 1 ngày (nghỉ không lương)
            //   4  = phải báo trước tối thiểu 4 giờ (nghỉ ốm)
            int noticeHours = new LeaveTypeDAO()
                .getNoticeHours(leaveTypeId);

            if (noticeHours > 0) {
                LocalDateTime now = LocalDateTime.now();
                LocalDate today = LocalDate.now();

                // Mốc chót = thời điểm SỚM NHẤT được gửi đơn
                // (00:00 của ngày bắt đầu nghỉ trừ đi notice_hours).
                // VD: nghỉ Thứ Hai, notice = 48h
                //     => mốc = Thứ Bảy 00:00 => gửi từ Thứ Bảy trở đi.
                LocalDateTime deadline = startDate
                    .atStartOfDay()
                    .minusHours(noticeHours);

                boolean blocked;

                if (noticeHours >= 24) {
                    // Loại cần báo trước >= 1 ngày:
                    // phải nghỉ từ ngày mai trở đi, và phải gửi
                    // sau mốc chót.
                    blocked = !startDate.isAfter(today)
                        || now.isBefore(deadline);
                } else {
                    // Loại báo trước ngắn (vd nghỉ ốm 4h):
                    // nghỉ trong ngày vẫn gửi được, nhưng nghỉ từ
                    // ngày mai thì phải gửi trước mốc chót.
                    boolean sameDay = startDate.equals(today);
                    blocked = !sameDay && now.isBefore(deadline);
                }

                if (blocked) {
                    req.setAttribute(
                        "error",
                        "Đơn nghỉ phép đã quá hạn gửi. Loại nghỉ này yêu cầu "
                        + "báo trước " + formatHours(noticeHours)
                        + ". Nếu nghỉ từ " + formatVn(startDate)
                        + " thì phải gửi đơn từ "
                        + formatVnTime(deadline) + " trở đi."
                    );
                    showPage(req, resp, user);
                    return;
                }
            }
            // Validate lý do
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

            // Tính số ngày nghỉ
            int totalDays = (int) ChronoUnit.DAYS.between(
                startDate, endDate
            ) + 1;

            // Kiểm tra quota còn đủ không (chặn sớm để nhân viên biết)
            int balanceTotal = balanceDao.getTotalDays(
                user.getId(), leaveTypeId, startDate.getYear()
            );

            if (balanceTotal > 0) {
                int balanceUsed = balanceDao.getUsedDays(
                    user.getId(), leaveTypeId, startDate.getYear()
                );

                if (balanceUsed + totalDays > balanceTotal) {
                    req.setAttribute(
                        "error",
                        "Không đủ quota. Bạn chỉ còn "
                        + Math.max(0, balanceTotal - balanceUsed)
                        + " ngày "
                        + "nhưng đơn này dùng " + totalDays + " ngày."
                    );
                    showPage(req, resp, user);
                    return;
                }
            }

            // Tạo đơn (hệ thống sẽ kiểm tra quota khi duyệt)
            LeaveRequestDAO dao = new LeaveRequestDAO();
            boolean success = dao.createRequest(
                user.getId(),
                leaveTypeId,
                startDate,
                endDate,
                totalDays,
                reason.trim()
            );

            resp.sendRedirect(
                req.getContextPath()
                + "/employee/leave-request?"
                + (success ? "success=1" : "invalid=1")
            );

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

    // Định dạng số giờ thành câu tiếng Việt dễ hiểu
    private String formatHours(int hours) {
        if (hours % 24 == 0) {
            int days = hours / 24;
            return days + " ngày";
        }
        return hours + " giờ";
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