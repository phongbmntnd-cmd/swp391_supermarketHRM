package controller.admin;

import dao.AuditLogDAO;
import dao.UserDAO;
import model.User;

/**
 * AuditFilter - Gom logic phân giải bộ lọc của trang Audit Log
 * để dùng chung giữa trang danh sách, xuất CSV và xem chi tiết.
 */
public final class AuditFilter {

    /** Kết quả phân giải bộ lọc. */
    public static class Resolved {
        public String action;
        public Integer actorId;
        public Integer targetId;
        public String entityType;
        public Integer entityId;
        public String keyword;
        public String fromDate;
        public String toDate;
        /** true nếu có username được nhập nhưng không tồn tại -> không có kết quả nào khớp. */
        public boolean notFound;
    }

    private AuditFilter() {
    }

    /**
     * Phân giải các tham số filter từ request thành điều kiện truy vấn.
     */
    public static Resolved resolve(AuditLogDAO auditLogDAO, UserDAO userDAO,
                                    String action, String actorUsername, String targetUsername,
                                    String entityType, String entityIdRaw,
                                    String keyword, String fromDate, String toDate) {
        Resolved r = new Resolved();
        r.action = action;
        r.keyword = keyword;
        r.fromDate = fromDate;
        r.toDate = toDate;
        r.entityType = entityType;

        if (actorUsername != null) {
            User u = userDAO.getUserByUsername(actorUsername);
            if (u != null) {
                r.actorId = u.getId();
            } else {
                r.notFound = true;
            }
        }
        if (targetUsername != null) {
            User u = userDAO.getUserByUsername(targetUsername);
            if (u != null) {
                r.targetId = u.getId();
            } else {
                r.notFound = true;
            }
        }
        if (entityIdRaw != null && !entityIdRaw.trim().isEmpty()) {
            try {
                r.entityId = Integer.parseInt(entityIdRaw.trim());
            } catch (NumberFormatException e) {
                r.notFound = true;
            }
        }
        return r;
    }
}
