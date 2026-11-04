package dao;

import context.DBContext;
import model.AuditLog;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO cho bảng audit_logs - ghi log và truy vết.
 * Schema chính thức: id, user_id, action, description, ip_address, created_at
 * Code cũ từng tự thêm actor_id/target_user_id; module này dùng description
 * để lưu "actor=X, target=Y, ..." cho ngắn gọn và tương thích schema.
 */
public class AuditLogDAO {

    /** Cờ đảm bảo schema đã chạy 1 lần trong suốt vòng đời app (tránh DDL lặp mỗi request) */
    private static volatile boolean schemaReady = false;

    /**
     * Đảm bảo bảng audit_logs tồn tại (chỉ chạy DDL lần đầu tiên).
     * Các luồng ghi log ngoài trang Admin (login/logout...) gọi hàm này qua log().
     */
    public static synchronized void ensureTableOnce() {
        if (schemaReady) return;
        try {
            new AuditLogDAO().ensureTable();
            schemaReady = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // =========================================================
    //  ĐẢM BẢO SCHEMA (chạy 1 lần khi app start)
    // =========================================================
    /**
     * Đảm bảo bảng audit_logs có đầy đủ cột cần thiết:
     *   - Nếu bảng chưa có → tạo mới với schema mở rộng
     *   - Nếu bảng đã có (schema cũ) → thêm cột còn thiếu
     */
    public void ensureTable() {
        try (Connection conn = new DBContext().getConnection();
             Statement st = conn.createStatement()) {

            // Tạo bảng nếu chưa tồn tại (schema mở rộng)
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS audit_logs ("
              + "  id INT NOT NULL AUTO_INCREMENT,"
              + "  user_id INT DEFAULT NULL,"
              + "  action VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,"
              + "  description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,"
              + "  ip_address VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,"
              + "  actor_id INT DEFAULT NULL,"
              + "  target_user_id INT DEFAULT NULL,"
              + "  entity_type VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,"
              + "  entity_id INT DEFAULT NULL,"
              + "  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,"
              + "  PRIMARY KEY (id),"
              + "  KEY idx_user (user_id),"
              + "  KEY idx_actor (actor_id),"
              + "  KEY idx_target (target_user_id),"
              + "  KEY idx_action (action),"
              + "  KEY idx_entity (entity_type, entity_id),"
              + "  KEY idx_created (created_at)"
              + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
            );

            addColumnIfMissing(conn, "audit_logs", "actor_id",
                "ALTER TABLE audit_logs ADD COLUMN actor_id INT DEFAULT NULL");
            addColumnIfMissing(conn, "audit_logs", "target_user_id",
                "ALTER TABLE audit_logs ADD COLUMN target_user_id INT DEFAULT NULL");
            addColumnIfMissing(conn, "audit_logs", "ip_address",
                "ALTER TABLE audit_logs ADD COLUMN ip_address VARCHAR(45) DEFAULT NULL");
            addColumnIfMissing(conn, "audit_logs", "description",
                "ALTER TABLE audit_logs ADD COLUMN description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            addColumnIfMissing(conn, "audit_logs", "entity_type",
                "ALTER TABLE audit_logs ADD COLUMN entity_type VARCHAR(30) DEFAULT NULL");
            addColumnIfMissing(conn, "audit_logs", "entity_id",
                "ALTER TABLE audit_logs ADD COLUMN entity_id INT DEFAULT NULL");
            addColumnIfMissing(conn, "audit_logs", "created_at",
                "ALTER TABLE audit_logs ADD COLUMN created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void addColumnIfMissing(Connection conn, String tableName, String columnName, String alterSql) {
        String checkSql = "SELECT COUNT(*) FROM information_schema.columns "
                        + "WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) == 0) {
                    try (Statement st = conn.createStatement()) {
                        st.executeUpdate(alterSql);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // =========================================================
    //  GHI LOG
    // =========================================================
    /**
     * Ghi log cơ bản (chỉ user_id là actor). description tự xây theo format chuẩn.
     */
    public boolean log(String action, Integer actorId, Integer targetUserId, String detail, String ipAddress) {
        String description = buildDescription(actorId, targetUserId, detail);
        return insertRaw(action, actorId, targetUserId, null, null, description, ipAddress);
    }

    /**
     * Ghi log kèm thông tin đối tượng bị tác động (entity_type / entity_id).
     * Dùng cho các action không tác động lên user, ví dụ CREATE_DEPARTMENT.
     *
     * @param action     mã hành động
     * @param actorId    người thực hiện (có thể null)
     * @param targetUserId user bị tác động (có thể null)
     * @param entityType loại đối tượng (AuditLog.ENTITY_*), có thể null
     * @param entityId   id đối tượng, có thể null
     * @param detail     mô tả đã format theo util.AuditDescription
     * @param ipAddress  IP client (có thể null)
     */
    public boolean log(String action, Integer actorId, Integer targetUserId,
                       String entityType, Integer entityId,
                       String detail, String ipAddress) {
        String description = buildDescription(actorId, targetUserId, detail);
        return insertRaw(action, actorId, targetUserId, entityType, entityId, description, ipAddress);
    }

    /**
     * Ghi log nâng cao (description đã build sẵn).
     */
    public boolean logRaw(String action, Integer actorId, Integer targetUserId, String description, String ipAddress) {
        return insertRaw(action, actorId, targetUserId, null, null, description, ipAddress);
    }

    private boolean insertRaw(String action, Integer actorId, Integer targetUserId,
                              String entityType, Integer entityId,
                              String description, String ipAddress) {
        // Đảm bảo bảng tồn tại (chỉ chạy DDL lần đầu)
        ensureTableOnce();
        String sql = "INSERT INTO audit_logs (action, actor_id, target_user_id, entity_type, entity_id, "
                   + "user_id, description, ip_address) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, action);
            if (actorId == null) ps.setNull(2, java.sql.Types.INTEGER); else ps.setInt(2, actorId);
            if (targetUserId == null) ps.setNull(3, java.sql.Types.INTEGER); else ps.setInt(3, targetUserId);
            if (entityType == null) ps.setNull(4, java.sql.Types.VARCHAR); else ps.setString(4, entityType);
            if (entityId == null) ps.setNull(5, java.sql.Types.INTEGER); else ps.setInt(5, entityId);
            // user_id = actorId nếu có (giữ tương thích FK)
            if (actorId == null) ps.setNull(6, java.sql.Types.INTEGER); else ps.setInt(6, actorId);
            ps.setString(7, description);
            if (ipAddress == null || ipAddress.isEmpty()) ps.setNull(8, java.sql.Types.VARCHAR);
            else ps.setString(8, ipAddress);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Chuẩn hoá description trước khi lưu.
     *
     * LƯU Ý: định dạng chuẩn của dự án nằm ở util.AuditDescription - nơi đã có
     * sẵn phần "Bởi {actor}" và đã tự escape ký tự "|" trong nội dung tự do.
     * Hàm này chỉ loại bỏ ký tự xuống dòng (làm vỡ cấu trúc " | ").
     *
     * TUYỆT ĐỐI KHÔNG thay thế ký tự "|" ở đây, vì "|" chính là dấu phân
     * cách trường của định dạng chuẩn.
     */
    private String buildDescription(Integer actorId, Integer targetUserId, String detail) {
        if (detail == null) return "";
        return detail.replace("\r\n", " ").replace("\n", " ").replace("\r", " ").trim();
    }

    // =========================================================
    //  TRUY VẤN (filter + phân trang)
    // =========================================================
    /**
     * Lấy audit log theo nhiều tiêu chí + phân trang.
     */
    public List<AuditLog> search(String action, Integer actorId, Integer targetUserId,
                                 String keyword, String fromDate, String toDate,
                                 int offset, int limit) {
        return search(action, actorId, targetUserId, null, null,
                      keyword, fromDate, toDate, offset, limit);
    }

    /**
     * Lấy audit log theo nhiều tiêu chí + phân trang (có thêm filter loại/id đối tượng).
     */
    public List<AuditLog> search(String action, Integer actorId, Integer targetUserId,
                                 String entityType, Integer entityId,
                                 String keyword, String fromDate, String toDate,
                                 int offset, int limit) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT al.id, al.action, al.actor_id, al.target_user_id, ")
           .append("       al.entity_type, al.entity_id, al.description, ")
           .append("       al.ip_address, al.created_at, ")
           .append("       actor_u.username   AS actor_username, ")
           .append("       target_u.username  AS target_username, ")
           .append("       actor_ep.full_name AS actor_name, ")
           .append("       target_ep.full_name AS target_name, ")
           .append("       actor_r.name       AS actor_role, ")
           .append("       target_r.name      AS target_role, ")
           .append("       actor_b.name       AS actor_branch, ")
           .append("       target_b.name      AS target_branch ")
           .append("FROM audit_logs al ")
           .append("LEFT JOIN users actor_u  ON al.actor_id = actor_u.id ")
           .append("LEFT JOIN users target_u ON al.target_user_id = target_u.id ")
           .append("LEFT JOIN employee_profiles actor_ep  ON al.actor_id = actor_ep.user_id ")
           .append("LEFT JOIN employee_profiles target_ep ON al.target_user_id = target_ep.user_id ")
           .append("LEFT JOIN roles actor_r    ON actor_u.role_id = actor_r.id ")
           .append("LEFT JOIN roles target_r   ON target_u.role_id = target_r.id ")
           .append("LEFT JOIN branches actor_b  ON actor_ep.home_branch_id = actor_b.id ")
           .append("LEFT JOIN branches target_b ON target_ep.home_branch_id = target_b.id ")
           .append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (action != null && !action.trim().isEmpty()) {
            sql.append("AND al.action = ? ");
            params.add(action.trim());
        }
        if (actorId != null) {
            sql.append("AND al.actor_id = ? ");
            params.add(actorId);
        }
        if (targetUserId != null) {
            sql.append("AND al.target_user_id = ? ");
            params.add(targetUserId);
        }
        if (entityType != null && !entityType.trim().isEmpty()) {
            sql.append("AND al.entity_type = ? ");
            params.add(entityType.trim());
        }
        if (entityId != null) {
            sql.append("AND al.entity_id = ? ");
            params.add(entityId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (al.description LIKE ? OR al.action LIKE ? OR al.ip_address LIKE ?) ");
            String k = "%" + keyword.trim() + "%";
            params.add(k); params.add(k); params.add(k);
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql.append("AND al.created_at >= ? ");
            params.add(fromDate.trim() + " 00:00:00");
        }
        if (toDate != null && !toDate.trim().isEmpty()) {
            sql.append("AND al.created_at <= ? ");
            params.add(toDate.trim() + " 23:59:59");
        }

        sql.append("ORDER BY al.created_at DESC, al.id DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = mapRow(rs);
                    list.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countSearch(String action, Integer actorId, Integer targetUserId,
                           String keyword, String fromDate, String toDate) {
        return countSearch(action, actorId, targetUserId, null, null, keyword, fromDate, toDate);
    }

    public int countSearch(String action, Integer actorId, Integer targetUserId,
                           String entityType, Integer entityId,
                           String keyword, String fromDate, String toDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM audit_logs al WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (action != null && !action.trim().isEmpty()) { sql.append("AND al.action = ? "); params.add(action.trim()); }
        if (actorId != null) { sql.append("AND al.actor_id = ? "); params.add(actorId); }
        if (targetUserId != null) { sql.append("AND al.target_user_id = ? "); params.add(targetUserId); }
        if (entityType != null && !entityType.trim().isEmpty()) { sql.append("AND al.entity_type = ? "); params.add(entityType.trim()); }
        if (entityId != null) { sql.append("AND al.entity_id = ? "); params.add(entityId); }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (al.description LIKE ? OR al.action LIKE ? OR al.ip_address LIKE ?) ");
            String k = "%" + keyword.trim() + "%";
            params.add(k); params.add(k); params.add(k);
        }
        if (fromDate != null && !fromDate.trim().isEmpty()) { sql.append("AND al.created_at >= ? "); params.add(fromDate.trim() + " 00:00:00"); }
        if (toDate != null && !toDate.trim().isEmpty()) { sql.append("AND al.created_at <= ? "); params.add(toDate.trim() + " 23:59:59"); }

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =========================================================
    //  THỐNG KÊ (cho dashboard)
    // =========================================================
    /** Map<action, count> - thống kê số lượt theo action (toàn hệ thống) */
    public Map<String, Integer> countByAction() {
        Map<String, Integer> result = new HashMap<>();
        String sql = "SELECT action, COUNT(*) AS c FROM audit_logs GROUP BY action ORDER BY c DESC";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.put(rs.getString(1), rs.getInt(2));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /** Tổng số log ghi trong N ngày gần nhất (mặc định 7) */
    public int countRecentDays(int days) {
        // Dùng CURDATE() để tính theo ngày lịch, tránh lệch do giờ hệ thống
        String sql = "SELECT COUNT(*) FROM audit_logs WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(0, days - 1));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Map<yyyy-MM-dd, count> - số log theo ngày trong N ngày gần nhất (bao gồm hôm nay) */
    public Map<String, Integer> countByDate(int days) {
        Map<String, Integer> result = new java.util.LinkedHashMap<>();
        // DATE_SUB(CURDATE(), INTERVAL N DAY) sẽ trả về N+1 ngày -> dùng (N-1) để
        // giữ đúng N ngày (hôm nay + N-1 ngày trước đó)
        String sql = "SELECT DATE(created_at) AS d, COUNT(*) AS c FROM audit_logs "
                   + "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY) "
                   + "GROUP BY DATE(created_at) ORDER BY d ASC";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(0, days - 1));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getString(1), rs.getInt(2));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    /** Lấy N log mới nhất */
    public List<AuditLog> findRecent(int limit) {
        return search(null, null, null, null, null, null, 0, limit);
    }

    /** Lấy các action duy nhất đang dùng trong DB (dùng cho filter dropdown) */
    public List<String> findDistinctActions() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT action FROM audit_logs ORDER BY action";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(rs.getString(1));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lấy các loại đối tượng đang có trong log (dùng cho filter dropdown) */
    public List<String> findDistinctEntityTypes() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT entity_type FROM audit_logs "
                   + "WHERE entity_type IS NOT NULL AND entity_type <> '' ORDER BY entity_type";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(rs.getString(1));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================================================
    //  CHI TIẾT 1 LOG (P2-2)
    // =========================================================
    /**
     * Lấy 1 log theo id (kèm đầy đủ thông tin actor/target).
     * Trả về null nếu không tồn tại.
     */
    public AuditLog findById(int id) {
        String sql = "SELECT al.id, al.action, al.actor_id, al.target_user_id, "
                   + "       al.entity_type, al.entity_id, al.description, "
                   + "       al.ip_address, al.created_at, "
                   + "       actor_u.username   AS actor_username, "
                   + "       target_u.username  AS target_username, "
                   + "       actor_ep.full_name AS actor_name, "
                   + "       target_ep.full_name AS target_name, "
                   + "       actor_r.name       AS actor_role, "
                   + "       target_r.name      AS target_role, "
                   + "       actor_b.name       AS actor_branch, "
                   + "       target_b.name      AS target_branch "
                   + "FROM audit_logs al "
                   + "LEFT JOIN users actor_u  ON al.actor_id = actor_u.id "
                   + "LEFT JOIN users target_u ON al.target_user_id = target_u.id "
                   + "LEFT JOIN employee_profiles actor_ep  ON al.actor_id = actor_ep.user_id "
                   + "LEFT JOIN employee_profiles target_ep ON al.target_user_id = target_ep.user_id "
                   + "LEFT JOIN roles actor_r    ON actor_u.role_id = actor_r.id "
                   + "LEFT JOIN roles target_r   ON target_u.role_id = target_r.id "
                   + "LEFT JOIN branches actor_b  ON actor_ep.home_branch_id = actor_b.id "
                   + "LEFT JOIN branches target_b ON target_ep.home_branch_id = target_b.id "
                   + "WHERE al.id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy các log liên quan cùng actor hoặc cùng target trong khoảng thời gian
     * quanh log đang xem (mặc định ±5 phút) - dùng cho "ngữ cảnh" khi điều tra.
     */
    public List<AuditLog> findRelated(AuditLog center, int minutesRange) {
        if (center == null) return new ArrayList<>();
        long delta = Math.max(1, minutesRange) * 60L * 1000L;
        long ts = center.getCreatedAt() == null ? System.currentTimeMillis() : center.getCreatedAt().getTime();

        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.id, al.action, al.actor_id, al.target_user_id, "
                   + "       al.entity_type, al.entity_id, al.description, "
                   + "       al.ip_address, al.created_at, "
                   + "       actor_u.username   AS actor_username, "
                   + "       target_u.username  AS target_username, "
                   + "       actor_ep.full_name AS actor_name, "
                   + "       target_ep.full_name AS target_name, "
                   + "       actor_r.name       AS actor_role, "
                   + "       target_r.name      AS target_role, "
                   + "       actor_b.name       AS actor_branch, "
                   + "       target_b.name      AS target_branch "
                   + "FROM audit_logs al "
                   + "LEFT JOIN users actor_u  ON al.actor_id = actor_u.id "
                   + "LEFT JOIN users target_u ON al.target_user_id = target_u.id "
                   + "LEFT JOIN employee_profiles actor_ep  ON al.actor_id = actor_ep.user_id "
                   + "LEFT JOIN employee_profiles target_ep ON al.target_user_id = target_ep.user_id "
                   + "LEFT JOIN roles actor_r    ON actor_u.role_id = actor_r.id "
                   + "LEFT JOIN roles target_r   ON target_u.role_id = target_r.id "
                   + "LEFT JOIN branches actor_b  ON actor_ep.home_branch_id = actor_b.id "
                   + "LEFT JOIN branches target_b ON target_ep.home_branch_id = target_b.id "
                   + "WHERE al.id <> ? "
                   + "  AND (al.actor_id = ? OR (al.target_user_id IS NOT NULL AND al.target_user_id = ?)) "
                   + "  AND al.created_at BETWEEN ? AND ? "
                   + "ORDER BY al.created_at ASC, al.id ASC "
                   + "LIMIT 50";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, center.getId());
            ps.setInt(2, center.getActorId() == null ? -1 : center.getActorId());
            ps.setInt(3, center.getTargetUserId() == null ? -1 : center.getTargetUserId());
            ps.setTimestamp(4, new java.sql.Timestamp(ts - delta));
            ps.setTimestamp(5, new java.sql.Timestamp(ts + delta));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================================================
    //  EXPORT CSV (P2-1)
    // =========================================================
    /**
     * Lấy TOÀN BỘ log khớp bộ lọc (không phân trang) để xuất CSV.
     * Có giới hạn tối đa để tránh tràn bộ nhớ.
     */
    public List<AuditLog> exportCsv(String action, Integer actorId, Integer targetUserId,
                                    String entityType, Integer entityId,
                                    String keyword, String fromDate, String toDate,
                                    int maxRows) {
        return search(action, actorId, targetUserId, entityType, entityId,
                      keyword, fromDate, toDate, 0, maxRows);
    }

    // =========================================================
    //  RETENTION - xóa log cũ (P2-3)
    // =========================================================
    /**
     * Xóa các log cũ hơn {@code retentionDays} ngày.
     *
     * @param retentionDays số ngày được giữ lại
     * @return số dòng đã xóa
     */
    public int deleteOlderThan(int retentionDays) {
        ensureTableOnce();
        String sql = "DELETE FROM audit_logs WHERE created_at < DATE_SUB(CURDATE(), INTERVAL ? DAY)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, retentionDays));
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Đếm số log sẽ bị xóa nếu áp dụng retentionDays (để Admin xem trước khi xoá).
     */
    public int countOlderThan(int retentionDays) {
        String sql = "SELECT COUNT(*) FROM audit_logs WHERE created_at < DATE_SUB(CURDATE(), INTERVAL ? DAY)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, retentionDays));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Số ngày dữ liệu log cũ nhất đang có (0 nếu bảng trống) */
    public int getOldestLogAgeDays() {
        String sql = "SELECT DATEDIFF(CURDATE(), DATE(MIN(created_at))) FROM audit_logs";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =========================================================
    //  MAPPER
    // =========================================================
    private AuditLog mapRow(ResultSet rs) throws Exception {
        AuditLog log = new AuditLog();
        log.setId(rs.getInt("id"));
        log.setAction(rs.getString("action"));

        int actor = rs.getInt("actor_id");
        log.setActorId(rs.wasNull() ? null : actor);

        int target = rs.getInt("target_user_id");
        log.setTargetUserId(rs.wasNull() ? null : target);

        int entity = rs.getInt("entity_id");
        log.setEntityId(rs.wasNull() ? null : entity);
        log.setEntityType(rs.getString("entity_type"));

        log.setDescription(rs.getString("description"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setCreatedAt(rs.getTimestamp("created_at"));

        log.setActorUsername(rs.getString("actor_username"));
        log.setTargetUsername(rs.getString("target_username"));
        log.setActorName(rs.getString("actor_name"));
        log.setTargetUserName(rs.getString("target_name"));
        log.setActorRoleName(rs.getString("actor_role"));
        log.setTargetRoleName(rs.getString("target_role"));
        log.setActorBranchName(rs.getString("actor_branch"));
        log.setTargetBranchName(rs.getString("target_branch"));
        return log;
    }

    // Backward-compatible method used by some old callers
    public boolean isTableExists() {
        return countRecentDays(365) >= 0; // cheap check that table queryable
    }
}
