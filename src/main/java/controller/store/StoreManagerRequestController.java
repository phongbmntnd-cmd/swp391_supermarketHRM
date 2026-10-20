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

        } catch (IllegalArgumentException e) {
            resp.sendError(400, "Invalid submitted data");

        } catch (Exception e) {
            throw new ServletException(
                    "Cannot process shift request", e
            );
        }
    }
}
