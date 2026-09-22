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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String u = request.getParameter("username");
        String p = request.getParameter("password");

        UserDAO userDAO = new UserDAO();
        User account = userDAO.checkLogin(u, p);

        if (account == null) {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            HttpSession session = request.getSession();
            session.setAttribute("account", account);

            switch (account.getRoleId()) {
                case 1:
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    break;
                case 2:
                    response.sendRedirect(request.getContextPath() + "/director/dashboard");
                    break;
                case 3:
                    response.sendRedirect(request.getContextPath() + "/hr/dashboard");
                    break;
                case 4:
                    response.sendRedirect(request.getContextPath() + "/store-manager/dashboard");
                    break;
                case 5:
                    response.sendRedirect(request.getContextPath() + "/employee/dashboard");
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/login.jsp");
                    break;
            }
        }
    }
}