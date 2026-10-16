package controller.admin;

import controller.base.BaseServlet;
import dao.AuditLogDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.AuditLog;
import model.User;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Module 3: Audit Log & System Monitoring
 * URL: /admin/audit-logs
 * Chỉ System Admin (role 1) truy cập.
 */
@WebServlet(name = "AdminAuditLogServlet", urlPatterns = {"/admin/audit-logs"})
public class AdminAuditLogServlet extends BaseServlet {

    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private final UserDAO userDAO = new UserDAO();

    private static final int[] PAGE_SIZES = {10, 20, 50, 100};
    private static final int DEFAULT_PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Auth
        if (!hasRole(request, ROLE_ADMIN)) {
            if (getCurrentUser(request) == null) {
                redirectToLogin(request, response);
            } else {
                sendForbidden(request, response, "Bạn không có quyền truy cập nhật ký hệ thống!");
            }
            return;
        }

        // 2. Đảm bảo schema tồn tại (chạy 1 lần)
        auditLogDAO.ensureTable();

        // 3. Parse filter
        String action        = getStringParameter(request, "action");
        String actorUsername = getStringParameter(request, "actor");
        String targetUsername= getStringParameter(request, "target");
        String keyword       = getStringParameter(request, "keyword");
        String fromDate      = getStringParameter(request, "fromDate");
        String toDate        = getStringParameter(request, "toDate");
        int page             = getIntParameter(request, "page", 1);
        int pageSize         = getIntParameter(request, "size", DEFAULT_PAGE_SIZE);
        if (page < 1) page = 1;
        boolean validPs = false;
        for (int ps : PAGE_SIZES) if (ps == pageSize) { validPs = true; break; }
        if (!validPs) pageSize = DEFAULT_PAGE_SIZE;

        // 4. Resolve username -> user_id
        Integer actorId = null;
        if (actorUsername != null) {
            User u = userDAO.getUserByUsername(actorUsername);
            if (u != null) actorId = u.getId();
        }
        Integer targetId = null;
        if (targetUsername != null) {
            User u = userDAO.getUserByUsername(targetUsername);
            if (u != null) targetId = u.getId();
        }

        // 5. Query
        int offset = (page - 1) * pageSize;
        List<AuditLog> logs = auditLogDAO.search(
                action, actorId, targetId, keyword, fromDate, toDate, offset, pageSize);
        int totalRecords = auditLogDAO.countSearch(
                action, actorId, targetId, keyword, fromDate, toDate);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages < 1) totalPages = 1;
        int displayStart = (totalRecords == 0) ? 0 : (page - 1) * pageSize + 1;
        int displayEnd   = Math.min(page * pageSize, totalRecords);
        int pagerStart   = Math.max(1, page - 2);
        int pagerEnd     = Math.min(totalPages, page + 2);

        // 6. Thống kê cho dashboard
        Map<String, Integer> statsByAction = auditLogDAO.countByAction();
        Map<String, Integer> statsByDate   = auditLogDAO.countByDate(7);
        int totalAll   = auditLogDAO.countSearch(null, null, null, null, null, null);
        int totalToday = auditLogDAO.countRecentDays(1);
        int totalWeek  = auditLogDAO.countRecentDays(7);
        List<String> distinctActions = auditLogDAO.findDistinctActions();
        List<AuditLog> recent = auditLogDAO.findRecent(5);

        // 7. Set attributes
        request.setAttribute("logs", logs);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("pageSizes", PAGE_SIZES);
        request.setAttribute("displayStart", displayStart);
        request.setAttribute("displayEnd", displayEnd);
        request.setAttribute("pagerStart", pagerStart);
        request.setAttribute("pagerEnd", pagerEnd);

        request.setAttribute("action", action);
        request.setAttribute("actor", actorUsername);
        request.setAttribute("target", targetUsername);
        request.setAttribute("keyword", keyword);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);

        request.setAttribute("statsByAction", statsByAction);
        request.setAttribute("statsByDate", statsByDate);
        request.setAttribute("totalAll", totalAll);
        request.setAttribute("totalToday", totalToday);
        request.setAttribute("totalWeek", totalWeek);
        request.setAttribute("distinctActions", distinctActions);
        request.setAttribute("recentLogs", recent);

        request.setAttribute("successMessage", getAndClearSuccessMessage(request));
        request.setAttribute("errorMessage", getAndClearErrorMessage(request));

        request.getRequestDispatcher("/WEB-INF/views/admin/audit-logs.jsp").forward(request, response);
    }
}
