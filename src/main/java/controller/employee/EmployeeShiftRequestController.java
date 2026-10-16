
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
            ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

            req.setAttribute(
                "mySchedules",
                dao.getMySchedules(user.getId())
            );

            req.setAttribute(
                "colleagueSchedules",
                dao.getColleagueSchedules(user.getId())
            );

            req.setAttribute(
                "openShifts",
                dao.getOpenShifts(user.getId())
            );

            req.setAttribute(
                "myRequests",
                dao.getMyRequests(user.getId())
            );

            req.getRequestDispatcher(
                "/WEB-INF/views/employee/request-shift.jsp"
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

        try {
            String type = req.getParameter("requestType");

            int myScheduleId = Integer.parseInt(
                req.getParameter("myScheduleId")
            );

            String reason = req.getParameter("reason");

            if (reason == null ||
                reason.trim().isEmpty() ||
                reason.trim().length() > 255) {

                req.setAttribute(
                    "error", "Lý do không hợp lệ."
                );
                showPage(req, resp, user);
                return;
            }

            ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();
            boolean success;

            if ("SWAP".equals(type)) {

                int targetScheduleId = Integer.parseInt(
                    req.getParameter("targetScheduleId")
                );

                success = dao.createSwap(
                    user.getId(),
                    myScheduleId,
                    targetScheduleId,
                    reason.trim()
                );

            } else if ("OPEN".equals(type)) {

                int openShiftId = Integer.parseInt(
                    req.getParameter("openShiftId")
                );

                success = dao.createOpenChange(
                    user.getId(),
                    myScheduleId,
                    openShiftId,
                    reason.trim()
                );

            } else {
                resp.sendError(400, "Invalid request type");
                return;
            }

            resp.sendRedirect(
                req.getContextPath()
                + "/employee/request-shift?"
                + (success ? "success=1" : "invalid=1")
            );

        } catch (NumberFormatException e) {
            req.setAttribute(
                "error", "Vui lòng chọn đầy đủ thông tin."
            );
            showPage(req, resp, user);

        } catch (Exception e) {
            throw new ServletException(
                "Cannot create shift change request", e
            );
        }
    }
}
