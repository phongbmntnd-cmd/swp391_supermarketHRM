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

@WebServlet("/login")
public class LoginServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Nếu người dùng đã đăng nhập rồi mà vẫn gõ URL /login, điều hướng họ thẳng về Dashboard tương ứng
        User currentUser = getCurrentUser(request);
        if (currentUser != null) {
            redirectByRole(currentUser.getRoleId(), request, response);
            return;
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Đọc tham số đăng nhập an toàn bằng tiện ích của BaseServlet
        String username = getStringParameter(request, "username");
        String password = getStringParameter(request, "password");

        UserDAO userDAO = new UserDAO();
        User account = userDAO.checkLogin(username, password);

        System.out.println(">>> LOGIN TEST - Account result: " + account);

        if (account == null) {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            // 2. Lưu thông tin đăng nhập vào Session
            HttpSession session = request.getSession();
            session.setAttribute("account", account);

            // 3. Nếu là lần đầu đăng nhập -> Chuyển sang đổi mật khẩu
            if (account.isFirstLogin()) {
                response.sendRedirect(request.getContextPath() + "/change-password");
                return;
            }

            // 4. Điều hướng tới Dashboard đúng vai trò
            redirectByRole(account.getRoleId(), request, response);
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