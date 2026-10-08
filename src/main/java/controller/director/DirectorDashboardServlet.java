package controller.director;

import controller.base.BaseServlet;
import model.User;
import java.io.IOException;
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

        // 3. Giữ nguyên câu lệnh forward ra view của bạn
        request.getRequestDispatcher("/WEB-INF/views/director/dashboard.jsp").forward(request, response);
    }
}