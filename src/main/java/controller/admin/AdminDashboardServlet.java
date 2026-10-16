package controller.admin;

import controller.base.BaseServlet;
import model.User;
import context.DBContext;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        // Kiểm tra phân quyền Admin (ROLE_ADMIN = 1)
        if (currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Quản trị hệ thống!");
            return;
        }

        try {
            // 1. Tổng số tài khoản trên toàn hệ thống
            int totalAccounts = countTableRows("users");

            // 2. Tổng số tài khoản đang bị khóa
            int lockedAccounts = countLockedAccounts();

            // 3. Tổng số chi nhánh
            int totalBranches = countTableRows("branches");

            // 4. Tổng số log hệ thống (nếu có bảng audit_logs)
            int totalLogs = countTableRows("audit_logs");

            request.setAttribute("totalAccounts", totalAccounts);
            request.setAttribute("lockedAccounts", lockedAccounts);
            request.setAttribute("totalBranches", totalBranches);
            request.setAttribute("totalLogs", totalLogs);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }

    private int countTableRows(String tableName) {
        String sql = "SELECT COUNT(*) FROM " + tableName;
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            // Trả về 0 nếu bảng có thể chưa tồn tại
        }
        return 0;
    }

    private int countLockedAccounts() {
        String sql = "SELECT COUNT(*) FROM employee_locks WHERE is_active = TRUE";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            // Trả về 0 nếu chưa có bảng
        }
        return 0;
    }
}