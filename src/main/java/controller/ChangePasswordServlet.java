package controller;

import controller.base.BaseServlet;
import dao.UserDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/change-password")
public class ChangePasswordServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra đăng nhập bằng BaseServlet
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra đăng nhập
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        // 2. Đọc tham số an toàn qua BaseServlet
        String oldPassword = getStringParameter(request, "oldPassword");
        String newPassword = getStringParameter(request, "newPassword");
        String confirmPassword = getStringParameter(request, "confirmPassword");

        // Validate cơ bản
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < 6) {
            request.setAttribute("error", "Mật khẩu mới phải chứa ít nhất 6 ký tự!");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        boolean success = userDAO.changePassword(user.getId(), newPassword);

        if (success) {
            // Cập nhật lại trạng thái cờ firstLogin trong session
            user.setFirstLogin(false);
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.setAttribute("account", user);
            }

            // Điều hướng về Dashboard theo Role
            redirectByRole(user.getRoleId(), request, response);
        } else {
            request.setAttribute("error", "Đổi mật khẩu thất bại! Vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
        }
    }

    private void redirectByRole(int roleId, HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Tận dụng các hằng số ROLE_* định nghĩa sẵn trong BaseServlet
        switch (roleId) {
            case ROLE_ADMIN: 
                response.sendRedirect(request.getContextPath() + "/admin/dashboard"); 
                break;
            case ROLE_DIRECTOR: 
                response.sendRedirect(request.getContextPath() + "/director/dashboard"); 
                break;
            case ROLE_HR_MANAGER: 
                response.sendRedirect(request.getContextPath() + "/hr/dashboard"); 
                break;
            case ROLE_STORE_MANAGER: 
                response.sendRedirect(request.getContextPath() + "/store-manager/dashboard"); 
                break;
            case ROLE_EMPLOYEE: 
                response.sendRedirect(request.getContextPath() + "/employee/dashboard"); 
                break;
            default: 
                response.sendRedirect(request.getContextPath() + "/login.jsp"); 
                break;
        }
    }
}