package controller;

import dao.UserDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("account") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("account") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

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
            // Cập nhật lại trạng thái boolean thành false
            user.setFirstLogin(false);
            session.setAttribute("account", user);

            // Điều hướng về Dashboard theo Role
            redirectByRole(user.getRoleId(), request, response);
        } else {
            request.setAttribute("error", "Đổi mật khẩu thất bại! Vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
        }
    }

    private void redirectByRole(int roleId, HttpServletRequest request, HttpServletResponse response) throws IOException {
        switch (roleId) {
            case 1: response.sendRedirect(request.getContextPath() + "/admin/dashboard"); break;
            case 2: response.sendRedirect(request.getContextPath() + "/director/dashboard"); break;
            case 3: response.sendRedirect(request.getContextPath() + "/hr/dashboard"); break;
            case 4: response.sendRedirect(request.getContextPath() + "/store-manager/dashboard"); break;
            case 5: response.sendRedirect(request.getContextPath() + "/employee/dashboard"); break;
            default: response.sendRedirect(request.getContextPath() + "/login.jsp"); break;
        }
    }
}