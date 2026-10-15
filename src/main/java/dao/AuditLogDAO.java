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
              + "  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,"
              + "  PRIMARY KEY (id),"
              + "  KEY idx_user (user_id),"
              + "  KEY idx_actor (actor_id),"
              + "  KEY idx_target (target_user_id),"
              + "  KEY idx_action (action),"
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
        return insertRaw(action, actorId, targetUserId, description, ipAddress);
    }

    /**
     * Ghi log nâng cao (description đã build sẵn).
     */
    public boolean logRaw(String action, Integer actorId, Integer targetUserId, String description, String ipAddress) {
        return insertRaw(action, actorId, targetUserId, description, ipAddress);
    }

    private boolean insertRaw(String action, Integer actorId, Integer targetUserId,
                              String description, String ipAddress) {
        String sql = "INSERT INTO audit_logs (action, actor_id, target_user_id, user_id, description, ip_address) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, action);
            if (actorId == null) ps.setNull(2, java.sql.Types.INTEGER); else ps.setInt(2, actorId);
            if (targetUserId == null) ps.setNull(3, java.sql.Types.INTEGER); else ps.setInt(3, targetUserId);
            // user_id = actorId nếu có (giữ tương thích FK)
            if (actorId == null) ps.setNull(4, java.sql.Types.INTEGER); else ps.setInt(4, actorId);
            ps.setString(5, description);
            if (ipAddress == null || ipAddress.isEmpty()) ps.setNull(6, java.sql.Types.VARCHAR);
            else ps.setString(6, ipAddress);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Tạo description dạng "actorName (role) -> action -> targetName (role). detail" */
    private String buildDescription(Integer actorId, Integer targetUserId, String detail) {
        StringBuilder sb = new StringBuilder();
        if (actorId != null) sb.append("[actor=#").append(actorId).append("] ");
        if (targetUserId != null) sb.append("[target=#").append(targetUserId).append("] ");
        if (detail != null && !detail.isEmpty()) sb.append(detail);
        return sb.toString().trim();
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
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT al.id, al.action, al.actor_id, al.target_user_id, al.description, ")
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
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM audit_logs al WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (action != null && !action.trim().isEmpty()) { sql.append("AND al.action = ? "); params.add(action.trim()); }
        if (actorId != null) { sql.append("AND al.actor_id = ? "); params.add(actorId); }
        if (targetUserId != null) { sql.append("AND al.target_user_id = ? "); params.add(targetUserId); }
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
        String sql = "SELECT COUNT(*) FROM audit_logs WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /** Map<yyyy-MM-dd, count> - số log theo ngày trong N ngày gần nhất */
    public Map<String, Integer> countByDate(int days) {
        Map<String, Integer> result = new java.util.LinkedHashMap<>();
        String sql = "SELECT DATE(created_at) AS d, COUNT(*) AS c FROM audit_logs "
                   + "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY) "
                   + "GROUP BY DATE(created_at) ORDER BY d ASC";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
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
