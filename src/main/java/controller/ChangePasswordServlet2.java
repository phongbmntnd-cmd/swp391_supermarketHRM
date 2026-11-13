package controller;

import context.DBContext;
import controller.base.BaseServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;
import model.User;

/**
 * Self-service password change for Admin, Director, HR Manager and Store Manager.
 * The first-login password change remains mapped to /change-password.
 * Employee continues to use /employee/profile.
 */
@WebServlet("/account/change-password")
public class ChangePasswordServlet2 extends BaseServlet {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String VIEW = "/WEB-INF/views/change_password/change_password.jsp";
    private static final String URL = "/account/change-password";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (!isAllowedRole(user.getRoleId())) {
            sendForbidden(request, response, "Chức năng này dành cho Admin, Director, HR và Store Manager.");
            return;
        }

        HttpSession session = request.getSession();
        if (session.getAttribute("changePasswordCsrf") == null) {
            byte[] token = new byte[32];
            RANDOM.nextBytes(token);
            session.setAttribute("changePasswordCsrf",
                    Base64.getUrlEncoder().withoutPadding().encodeToString(token));
        }

        request.setAttribute("error", session.getAttribute("changePasswordError"));
        request.setAttribute("success", session.getAttribute("changePasswordSuccess"));
        session.removeAttribute("changePasswordError");
        session.removeAttribute("changePasswordSuccess");
        request.setAttribute("roleLabel", getRoleLabel(user.getRoleId()));
        request.setAttribute("dashboardUrl", request.getContextPath() + getDashboardPath(user.getRoleId()));

        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (!isAllowedRole(user.getRoleId())) {
            sendForbidden(request, response, "Bạn không có quyền đổi mật khẩu tại đây.");
            return;
        }

        HttpSession session = request.getSession(false);
        String expectedToken = session == null ? null : (String) session.getAttribute("changePasswordCsrf");
        String suppliedToken = request.getParameter("csrfToken");
        if (expectedToken == null || suppliedToken == null || !MessageDigest.isEqual(
                expectedToken.getBytes(StandardCharsets.UTF_8),
                suppliedToken.getBytes(StandardCharsets.UTF_8))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Yêu cầu không hợp lệ. Vui lòng tải lại trang đổi mật khẩu.");
            return;
        }

        // Do not trim password inputs; whitespace may be part of a password.
        String current = request.getParameter("currentPassword");
        String next = request.getParameter("newPassword");
        String confirm = request.getParameter("confirmPassword");

        String error = null;
        if (current == null || current.isEmpty() || next == null || next.isEmpty()
                || confirm == null || confirm.isEmpty()) {
            error = "Vui lòng nhập đầy đủ các ô mật khẩu.";
        } else if (next.length() < 8 || next.length() > 128) {
            error = "Mật khẩu mới phải từ 8 đến 128 ký tự.";
        } else if (!next.equals(confirm)) {
            error = "Xác nhận mật khẩu mới không khớp.";
        } else if (current.equals(next)) {
            error = "Mật khẩu mới phải khác mật khẩu cũ.";
        }
        if (error != null) {
            session.setAttribute("changePasswordError", error);
            response.sendRedirect(request.getContextPath() + URL);
            return;
        }

        // Matches the current training database, where password_hash stores plaintext.
        // Before production, update both this flow and the login flow to use a password hash.
        String selectSql = "SELECT password_hash FROM users "
                + "WHERE id = ? AND role_id = ? AND status = 'ACTIVE'";
        String updateSql = "UPDATE users SET password_hash = ?, is_first_login = 0 "
                + "WHERE id = ? AND role_id = ? AND password_hash = ? AND status = 'ACTIVE'";

        try (Connection conn = DBContext.getConnection()) {
            String stored = null;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, user.getId());
                ps.setInt(2, user.getRoleId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stored = rs.getString("password_hash");
                    }
                }
            }

            boolean valid = stored != null && MessageDigest.isEqual(
                    current.getBytes(StandardCharsets.UTF_8),
                    stored.getBytes(StandardCharsets.UTF_8));
            if (!valid) {
                session.setAttribute("changePasswordError",
                        "Mật khẩu hiện tại không đúng hoặc tài khoản không hoạt động.");
            } else {
                int count;
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, next);
                    ps.setInt(2, user.getId());
                    ps.setInt(3, user.getRoleId());
                    ps.setString(4, stored);
                    count = ps.executeUpdate();
                }
                if (count == 1) {
                    session.setAttribute("changePasswordSuccess", "Đổi mật khẩu thành công.");
                    // Rotate the CSRF token on the next GET.
                    session.removeAttribute("changePasswordCsrf");
                    user.setFirstLogin(false);
                    session.setAttribute("account", user);
                } else {
                    session.setAttribute("changePasswordError",
                            "Mật khẩu đã thay đổi ở phiên khác. Vui lòng thử lại.");
                }
            }
        } catch (Exception ex) {
            throw new ServletException("Không thể đổi mật khẩu.", ex);
        }
        response.sendRedirect(request.getContextPath() + URL);
    }

    private boolean isAllowedRole(int roleId) {
        return roleId >= 1 && roleId <= 4;
    }

    private String getRoleLabel(int roleId) {
        switch (roleId) {
            case 1: return "Admin Control";
            case 2: return "Director Portal";
            case 3: return "HR Portal";
            case 4: return "Store Manager Portal";
            default: return "";
        }
    }

    private String getDashboardPath(int roleId) {
        switch (roleId) {
            case 1: return "/admin/dashboard";
            case 2: return "/director/dashboard";
            case 3: return "/hr/dashboard";
            case 4: return "/store-manager/dashboard";
            default: return "/login";
        }
    }
}
