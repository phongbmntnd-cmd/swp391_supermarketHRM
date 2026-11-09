package controller.admin;

import controller.base.BaseServlet;
import dao.AuditLogDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.AuditLog;

import java.io.IOException;
import java.util.List;

/**
 * Xem chi tiết 1 dòng audit log + các log liên quan trong khoảng thời gian quanh sự kiện.
 * URL: /admin/audit-log-detail?id={logId}
 */
@WebServlet(name = "AdminAuditLogDetailServlet", urlPatterns = {"/admin/audit-log-detail"})
public class AdminAuditLogDetailServlet extends BaseServlet {

    /** Khoảng thời gian (phút) để tìm các log liên quan. */
    private static final int RELATED_MINUTES = 5;

    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!hasRole(request, ROLE_ADMIN)) {
            if (getCurrentUser(request) == null) {
                redirectToLogin(request, response);
            } else {
                sendForbidden(request, response, "Bạn không có quyền truy cập nhật ký hệ thống!");
            }
            return;
        }

        AuditLogDAO.ensureTableOnce();

        int id = getIntParameter(request, "id", -1);
        if (id <= 0) {
            setErrorMessage(request, "ID nhật ký không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/audit-logs");
            return;
        }

        AuditLog log = auditLogDAO.findById(id);
        if (log == null) {
            setErrorMessage(request, "Không tìm thấy dòng nhật ký #" + id + ".");
            response.sendRedirect(request.getContextPath() + "/admin/audit-logs");
            return;
        }

        List<AuditLog> related = auditLogDAO.findRelated(log, RELATED_MINUTES);

        request.setAttribute("log", log);
        request.setAttribute("relatedLogs", related);
        request.setAttribute("relatedMinutes", RELATED_MINUTES);
        request.setAttribute("successMessage", getAndClearSuccessMessage(request));
        request.setAttribute("errorMessage", getAndClearErrorMessage(request));

        request.getRequestDispatcher("/WEB-INF/views/admin/audit-log-detail.jsp").forward(request, response);
    }
}
