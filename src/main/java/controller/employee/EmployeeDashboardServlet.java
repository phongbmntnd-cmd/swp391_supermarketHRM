package controller.employee;

import controller.base.BaseServlet;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/employee/dashboard")
public class EmployeeDashboardServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        // 2. Kiểm tra phân quyền Nhân viên (ROLE_EMPLOYEE = 5) hoặc Admin (ROLE_ADMIN = 1)
        if (currentUser.getRoleId() != ROLE_EMPLOYEE && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Nhân viên!");
            return;
        }

        // 3. Giữ nguyên câu lệnh forward ra view của bạn
        request.getRequestDispatcher("/WEB-INF/views/employee/dashboard.jsp").forward(request, response);
    }
}