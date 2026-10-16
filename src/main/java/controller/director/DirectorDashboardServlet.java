package controller.director;

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

@WebServlet("/director/dashboard")
public class DirectorDashboardServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        // 2. Kiểm tra phân quyền Director (ROLE_DIRECTOR = 2) hoặc Admin (ROLE_ADMIN = 1)
        if (currentUser.getRoleId() != ROLE_DIRECTOR && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Giám đốc!");
            return;
        }

        try {
            // 1. Tổng số chi nhánh đang hoạt động
            int totalBranches = countTotalBranches();

            // 2. Tổng nhân sự toàn chuỗi (bao gồm Admin, HR, Store Manager, Employee - trừ Director có role_id = 2)
            int totalEmployees = countTotalStaffExceptDirector();

            request.setAttribute("totalBranches", totalBranches);
            request.setAttribute("totalEmployees", totalEmployees);

        } catch (Exception e) {
            e.printStackTrace();
        }

        // 3. Forward ra view dashboard.jsp
        request.getRequestDispatcher("/WEB-INF/views/director/dashboard.jsp").forward(request, response);
    }

    private int countTotalBranches() {
        String sql = "SELECT COUNT(*) FROM branches WHERE status = 'ACTIVE'";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int countTotalStaffExceptDirector() {
        // Đếm tất cả các tài khoản trong bảng users ngoại trừ Giám đốc (role_id = 2)
        // Nếu hệ thống dùng bảng employee_profiles hoặc users, ta lọc theo role_id != 2
        String sql = "SELECT COUNT(*) FROM users WHERE role_id != 2";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}