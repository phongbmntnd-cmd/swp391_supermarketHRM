package controller.store;

import dao.ShiftChangeRequestDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(
        name = "StoreManagerRequestController",
        urlPatterns = {"/store-manager/shift-requests"}
)
public class StoreManagerRequestController extends HttpServlet {

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null
                : (User) session.getAttribute("account");
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

        if (user.getRoleId() != 4 || user.getHomeBranchId() <= 0) {
            resp.sendError(403);
            return;
        }

        try {
            ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

            req.setAttribute(
                    "requestList",
                    dao.getBranchRequests(user.getHomeBranchId())
            );

            // Danh sách ca trống của chi nhánh + dữ liệu để tạo mới
            req.setAttribute(
                    "openShiftList",
                    dao.getBranchOpenShifts(user.getHomeBranchId())
            );

            req.setAttribute(
                    "allShifts",
                    dao.getAllShifts()
            );

            req.setAttribute(
                    "allPositions",
                    dao.getPositions()
            );

            req.getRequestDispatcher(
                    "/WEB-INF/views/store-manager/shift-requests.jsp"
            ).forward(req, resp);

        } catch (IllegalStateException e) {
            throw new ServletException(e);
        }
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

        if (user.getRoleId() != 4 || user.getHomeBranchId() <= 0) {
            resp.sendError(403);
            return;
        }

        try {
            String action = req.getParameter("action");

            // Tạo ca trống để nhân viên có thể đề nghị chuyển sang
            if ("createOpenShift".equals(action)) {

                int shiftId = Integer.parseInt(
                        req.getParameter("shiftId")
                );

                int positionId = Integer.parseInt(
                        req.getParameter("positionId")
                );

                String dateRaw = req.getParameter("workDate");

                if (dateRaw == null || dateRaw.trim().isEmpty()) {
                    resp.sendError(400, "Thiếu ngày làm việc");
                    return;
                }

                java.time.LocalDate workDate =
                        java.time.LocalDate.parse(dateRaw.trim());

                ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

                boolean success = dao.createOpenShift(
                        user.getHomeBranchId(),
                        shiftId,
                        positionId,
                        workDate
                );

                resp.sendRedirect(
                        req.getContextPath()
                        + "/store-manager/shift-requests?"
                        + (success ? "openCreated=1" : "invalid=1")
                );
                return;
            }

            if (!"approve".equals(action)
                    && !"reject".equals(action)) {
                resp.sendError(400, "Invalid action");
                return;
            }

            int requestId = Integer.parseInt(
                    req.getParameter("requestId")
            );

            String responseText = req.getParameter("response");

            if (responseText != null
                    && responseText.length() > 255) {
                resp.sendError(400, "Response too long");
                return;
            }

            ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

            boolean success = dao.review(
                    requestId,
                    user.getHomeBranchId(),
                    "approve".equals(action),
                    responseText == null ? null : responseText.trim()
            );

            resp.sendRedirect(
                    req.getContextPath()
                    + "/store-manager/shift-requests?"
                    + (success ? "success=1" : "invalid=1")
            );

        } catch (IllegalArgumentException e) {
            resp.sendError(400, "Invalid submitted data");

        } catch (Exception e) {
            throw new ServletException(
                    "Cannot process shift request", e
            );
        }
    }
}
