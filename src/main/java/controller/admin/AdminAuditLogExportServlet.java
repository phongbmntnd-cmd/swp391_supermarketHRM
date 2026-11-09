package controller.admin;

import controller.base.BaseServlet;
import dao.AuditLogDAO;
import dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.AuditLog;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;

/**
 * Xuất audit log ra file CSV.
 * URL: /admin/audit-logs/export
 *
 * Xuất TOÀN BỘ kết quả khớp bộ lọc (không phân trang), có giới hạn tối đa
 * để tránh tràn bộ nhớ. File dùng UTF-8 kèm BOM để Excel đọc đúng tiếng Việt.
 */
@WebServlet(name = "AdminAuditLogExportServlet", urlPatterns = {"/admin/audit-logs/export"})
public class AdminAuditLogExportServlet extends BaseServlet {

    /** Giới hạn số dòng tối đa được xuất. */
    private static final int MAX_EXPORT_ROWS = 50000;

    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (!hasRole(request, ROLE_ADMIN)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xuất nhật ký hệ thống!");
            return;
        }

        AuditLogDAO.ensureTableOnce();

        // Phân giải bộ lọc (giống hệt trang danh sách)
        AuditFilter.Resolved f = AuditFilter.resolve(auditLogDAO, userDAO,
                getStringParameter(request, "action"),
                getStringParameter(request, "actor"),
                getStringParameter(request, "target"),
                getStringParameter(request, "entityType"),
                getStringParameter(request, "entityId"),
                getStringParameter(request, "keyword"),
                getStringParameter(request, "fromDate"),
                getStringParameter(request, "toDate"));

        List<AuditLog> logs;
        if (f.notFound) {
            logs = java.util.Collections.emptyList();
        } else {
            logs = auditLogDAO.exportCsv(f.action, f.actorId, f.targetId,
                    f.entityType, f.entityId, f.keyword, f.fromDate, f.toDate, MAX_EXPORT_ROWS);
        }

        // Thiết lập header để trình duyệt tải về file
        String fileName = "audit-log-" + new SimpleDateFormat("yyyyMMdd-HHmmss").format(new java.util.Date()) + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        // BOM để Excel nhận diện UTF-8
        out.write('﻿');

        // Header
        out.println("ID,Thoi_gian,Han_dong,Loai_doi_tuong,ID_doi_tuong,"
                + "Nguoi_thuc_hien,Vai_tro,Chi_nhanh,"
                + "Doi_tuong,Doi_tuong_vai_tro,Mo_ta,Dia_chi_IP");

        SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (AuditLog log : logs) {
            out.println(
                    log.getId() + ","
                    + (log.getCreatedAt() != null ? fmt.format(log.getCreatedAt()) : "") + ","
                    + escape(log.getAction()) + ","
                    + escape(log.getEntityType()) + ","
                    + (log.getEntityId() != null ? log.getEntityId() : "") + ","
                    + escape(displayActor(log)) + ","
                    + escape(log.getActorRoleName()) + ","
                    + escape(log.getActorBranchName()) + ","
                    + escape(displayTarget(log)) + ","
                    + escape(log.getTargetRoleName()) + ","
                    + escape(log.getDescription()) + ","
                    + escape(log.getIpAddress())
            );
        }
        out.flush();
    }

    /** Tên hiển thị của người thực hiện: ưu tiên họ tên, fallback username. */
    private String displayActor(AuditLog log) {
        if (log.getActorName() != null && !log.getActorName().isEmpty()) return log.getActorName();
        if (log.getActorUsername() != null && !log.getActorUsername().isEmpty()) return log.getActorUsername();
        return "(system)";
    }

    /** Tên hiển thị của đối tượng bị tác động. */
    private String displayTarget(AuditLog log) {
        if (log.getTargetUserName() != null && !log.getTargetUserName().isEmpty()) return log.getTargetUserName();
        if (log.getTargetUsername() != null && !log.getTargetUsername().isEmpty()) return log.getTargetUsername();
        return "";
    }

    /**
     * Escape giá trị cho CSV: bọc trong dấu nháy kép và nhân đôi dấu nháy kép bên trong.
     */
    private String escape(String value) {
        if (value == null) return "";
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }
}
