package controller.employee;

import dao.ShiftChangeRequestDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;

@WebServlet(
        name = "EmployeeShiftRequestController",
        urlPatterns = {"/employee/request-shift"}
)
public class EmployeeShiftRequestController extends HttpServlet {

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null
                : (User) session.getAttribute("account");
    }

    /**
     * Xác định tuần đang xem từ tham số {@code startDate}.
     * Luôn chuẩn hoá về thứ Hai của tuần đó.
     */
    private LocalDate resolveWeekStart(HttpServletRequest req) {
        String param = req.getParameter("startDate");

        if (param != null && !param.trim().isEmpty()) {
            try {
                return LocalDate.parse(param.trim())
                        .with(TemporalAdjusters
                                .previousOrSame(DayOfWeek.MONDAY));
            } catch (Exception e) {
                // Bỏ qua -> dùng tuần mặc định bên dưới.
            }
        }

        return LocalDate.now()
                .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
    }

    private void showPage(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            ShiftChangeRequestDAO dao
                    = new ShiftChangeRequestDAO();

            // TUẦN ĐANG XEM: nhân viên chỉ được đổi ca trong tuần
            // đang mở trên màn hình (thứ 2 .. chủ nhật).
            LocalDate weekStart = resolveWeekStart(req);

            req.setAttribute("weekStart", weekStart.toString());

            // Lịch của nhân viên đang đăng nhập (chỉ trong tuần đang xem)
            req.setAttribute(
                    "mySchedules",
                    dao.getMySchedules(user.getId(), weekStart)
            );

            // Dữ liệu phân công để dựng bảng tuần
            req.setAttribute(
                    "colleagueSchedules",
                    dao.getColleagueSchedules(user.getId(), weekStart)
            );

            // Tên và thời gian của các loại ca
            req.setAttribute(
                    "allShifts",
                    dao.getAllShifts()
            );

            // Đơn nhân viên đã gửi
            req.setAttribute(
                    "myRequests",
                    dao.getMyRequests(user.getId())
            );

            // Chỉ các đơn gửi đến chính tài khoản này
            req.setAttribute(
                    "incomingRequests",
                    dao.getIncomingRequests(user.getId())
            );

            // Ca trống tại cơ sở để nhân viên đề nghị chuyển sang
            // (chỉ trong tuần đang xem)
            req.setAttribute(
                    "openShifts",
                    dao.getOpenShifts(user.getId(), weekStart)
            );

            // Badge số đơn đổi ca đang chờ mình phản hồi
            req.setAttribute(
                    "incomingSwapCount",
                    dao.countIncomingShiftRequests(user.getId())
            );

            req.getRequestDispatcher(
                    "/WEB-INF/views/employee/request-shift.jsp"
            ).forward(req, resp);

        } catch (IllegalStateException e) {
            throw new ServletException(
                    "Cannot load shift request page", e
            );
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
            resp.sendRedirect(
                    req.getContextPath() + "/login.jsp"
            );
            return;
        }

        // Chỉ role Employee được đổi ca
        if (user.getRoleId() != 5) {
            resp.sendError(403);
            return;
        }

        try {
            ShiftChangeRequestDAO dao
                    = new ShiftChangeRequestDAO();

            String action = req.getParameter("action");

            // NHÂN VIÊN B XÁC NHẬN / TỪ CHỐI
            if ("respond".equals(action)) {

                int requestId = Integer.parseInt(
                        req.getParameter("requestId")
                );

                String decision
                        = req.getParameter("decision");

                if (!"accept".equals(decision)
                        && !"decline".equals(decision)) {

                    resp.sendError(400, "Invalid decision");
                    return;
                }

                boolean accepted
                        = "accept".equals(decision);

                String message = req.getParameter("message");

                if (message != null
                        && message.trim().length() > 255) {
                    resp.sendError(400, "Message too long");
                    return;
                }

                boolean success = dao.respondToSwap(
                        requestId,
                        user.getId(),
                        accepted,
                        message == null
                                ? null
                                : message.trim()
                );

                resp.sendRedirect(
                        req.getContextPath()
                        + "/employee/request-shift?"
                        + (success ? "responded=1" : "invalid=1")
                );
                return;
            }

            // NHÂN VIÊN A HỦY ĐƠN
            if ("cancel".equals(action)) {

                int requestId = Integer.parseInt(
                        req.getParameter("requestId")
                );

                boolean success = dao.cancelMyRequest(
                        requestId, user.getId());

                resp.sendRedirect(
                        req.getContextPath()
                        + "/employee/request-shift?"
                        + (success ? "cancelled=1" : "invalid=1")
                );
                return;
            }

            // NHÂN VIÊN A GỬI ĐƠN
            if (action != null
                    && !"create".equals(action)
                    && !"createOpen".equals(action)) {
                resp.sendError(400, "Invalid action");
                return;
            }

            // Loại đơn: đổi với đồng nghiệp (SWAP) hay chuyển
            // sang ca trống (OPEN).
            boolean openType = "createOpen".equals(action);

            int myScheduleId = Integer.parseInt(
                    req.getParameter("myScheduleId")
            );

            String reason = req.getParameter("reason");

            if (reason == null
                    || reason.trim().isEmpty()
                    || reason.trim().length() > 255) {

                req.setAttribute(
                        "error",
                        "Vui lòng nhập lý do đổi ca (tối đa 255 ký tự)."
                );

                showPage(req, resp, user);
                return;
            }

            boolean success;

            if (openType) {
                int openShiftId = Integer.parseInt(
                        req.getParameter("openShiftId")
                );

                success = dao.createOpenChange(
                        user.getId(),
                        myScheduleId,
                        openShiftId,
                        reason.trim(),
                        resolveWeekStart(req)
                );
            } else {
                int targetScheduleId = Integer.parseInt(
                        req.getParameter("targetScheduleId")
                );

                success = dao.createSwap(
                        user.getId(),
                        myScheduleId,
                        targetScheduleId,
                        reason.trim(),
                        resolveWeekStart(req)
                );
            }

            resp.sendRedirect(
                    req.getContextPath()
                    + "/employee/request-shift?"
                    + (success ? "success=1" : "invalid=1")
            );

        } catch (NumberFormatException e) {

            req.setAttribute(
                    "error",
                    "Vui lòng chọn đầy đủ thông tin đổi ca."
            );

            showPage(req, resp, user);

        } catch (Exception e) {

            throw new ServletException(
                    "Cannot process shift swap", e
            );
        }
    }

}
