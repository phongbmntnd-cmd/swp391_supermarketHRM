package controller.employee;

import dao.ShiftChangeRequestDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

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

    private void showPage(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            ShiftChangeRequestDAO dao
                    = new ShiftChangeRequestDAO();

            // Lịch của nhân viên đang đăng nhập
            req.setAttribute(
                    "mySchedules",
                    dao.getMySchedules(user.getId())
            );

            // Dữ liệu phân công để dựng bảng tuần
            req.setAttribute(
                    "colleagueSchedules",
                    dao.getColleagueSchedules(user.getId())
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

                boolean success = dao.respondToSwap(
                        requestId,
                        user.getId(),
                        accepted,
                        null
                );

                resp.sendRedirect(
                        req.getContextPath()
                        + "/employee/request-shift?"
                        + (success ? "responded=1" : "invalid=1")
                );
                return;
            }

            // NHÂN VIÊN A GỬI ĐƠN
            if (action != null && !"create".equals(action)) {
                resp.sendError(400, "Invalid action");
                return;
            }

            int myScheduleId = Integer.parseInt(
                    req.getParameter("myScheduleId")
            );

            int targetScheduleId = Integer.parseInt(
                    req.getParameter("targetScheduleId")
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

            boolean success = dao.createSwap(
                    user.getId(),
                    myScheduleId,
                    targetScheduleId,
                    reason.trim()
            );

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
