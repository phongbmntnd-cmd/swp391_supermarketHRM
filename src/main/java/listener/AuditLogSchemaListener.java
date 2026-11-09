package listener;

import dao.AuditLogDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * Listener khởi tạo schema audit_logs khi ứng dụng khởi động.
 *
 * Mục đích:
 *  - Bảng audit_logs luôn tồn tại đúng shape trước khi có bất kỳ request ghi log nào
 *    (đăng nhập / đăng xuất / khóa tài khoản...).
 *  - DDL chỉ chạy 1 lần duy nhất thay vì mỗi lần request.
 */
@WebListener
public class AuditLogSchemaListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            AuditLogDAO.ensureTableOnce();
            System.out.println("[AuditLog] Đã khởi tạo bảng audit_logs.");
        } catch (Exception e) {
            System.out.println("[AuditLog] Lỗi khi khởi tạo bảng audit_logs: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Không cần làm gì khi app shutdown
    }
}
