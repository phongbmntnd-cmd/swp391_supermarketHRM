package controller;

import controller.base.BaseServlet;
import dao.AuditLogDAO;
import model.AuditLog;
import model.User;
import util.AuditDescription;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Lấy Session hiện tại (không tạo session mới nếu chưa có)
        HttpSession session = request.getSession(false);

        // 2. Ghi audit log đăng xuất - phải lấy user TRƯỚC khi invalidate session
        User currentUser = getCurrentUser(request);
        if (currentUser != null) {
            try {
                String desc = AuditDescription.logout(currentUser.getUsername(), currentUser.getFullName());
                new AuditLogDAO().log(AuditLog.ACTION_LOGOUT, currentUser.getId(), null,
                        AuditLog.ENTITY_USER, currentUser.getId(), desc, getClientIp(request));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 3. Xóa sạch thông tin đăng nhập khỏi Session
        if (session != null) {
            session.invalidate();
        }

        // 4. Chuyển hướng người dùng về trang đăng nhập
        response.sendRedirect(request.getContextPath() + "/login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
