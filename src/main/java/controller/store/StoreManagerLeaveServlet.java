package controller.store;

import dao.LeaveRequestDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(
    name = "StoreManagerLeaveServlet",
    urlPatterns = {"/store-manager/leave-requests"}
)
public class StoreManagerLeaveServlet extends HttpServlet {

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
            LeaveRequestDAO dao = new LeaveRequestDAO();

            req.setAttribute(
                "requestList",
                dao.getBranchRequests(user.getHomeBranchId())
            );

            req.getRequestDispatcher(
                "/WEB-INF/views/store-manager/leave-requests.jsp"
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

            int requestId = Integer.parseInt(
                req.getParameter("requestId")
            );

            String responseText = req.getParameter("response");

            if (responseText != null && responseText.length() > 255) {
                resp.sendError(400, "Response too long");
                return;
            }

            boolean approve = "approve".equals(action);

            LeaveRequestDAO dao = new LeaveRequestDAO();
            boolean success = dao.review(
                requestId,
                user.getHomeBranchId(),
                approve,
                responseText,
                user.getId()
            );

            if (success) {
                resp.sendRedirect(
                    req.getContextPath()
                    + "/store-manager/leave-requests?success=1"
                );
                return;
            }

            // Thất bại: phân biệt nguyên nhân để SM hiểu vì sao không duyệt được
            String reason = dao.getReviewFailureReason(
                requestId,
                user.getHomeBranchId(),
                approve
            );

            resp.sendRedirect(
                req.getContextPath()
                + "/store-manager/leave-requests?error="
                + java.net.URLEncoder.encode(reason, "UTF-8")
            );

        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid request id");

        } catch (Exception e) {
            throw new ServletException(
                "Cannot process leave request", e
            );
        }
    }
}