package controller.admin;

import controller.base.BaseServlet;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

@WebServlet(name = "AdminAccountController", urlPatterns = {"/admin/accounts"})
public class AdminAccountController extends BaseServlet {

    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    // 1. Lấy user hiện tại từ session
    User currentUser = getCurrentUser(request);
    
    // 2. Nếu chưa đăng nhập -> Chuyển về trang login
    if (currentUser == null) {
        redirectToLogin(request, response);
        return;
    }
    
    // 3. Nếu không phải Admin (ROLE_ADMIN = 1) -> Báo lỗi 403 Forbidden
    if (currentUser.getRoleId() != ROLE_ADMIN) {
        sendForbidden(request, response, "Bạn không có quyền truy cập trang quản lý tài khoản!");
        return;
    }

    // 4. Cho phép vào view nếu hợp lệ
    request.getRequestDispatcher("/WEB-INF/views/admin/accounts.jsp").forward(request, response);
}

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("accounts");
    }
}