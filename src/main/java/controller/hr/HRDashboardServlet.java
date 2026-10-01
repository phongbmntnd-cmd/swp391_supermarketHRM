package controller.hr;

import controller.base.BaseServlet;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

@WebServlet("/hr/dashboard")
public class HRDashboardServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Nhân sự!");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/hr/dashboard.jsp").forward(request, response);
    }
}