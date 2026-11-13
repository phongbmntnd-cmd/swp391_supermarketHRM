package controller.employee;

import context.DBContext;
import controller.base.BaseServlet;
import dao.EmployeeProfileDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.EmployeeProfile;
import model.User;

@WebServlet("/employee/profile")
public class EmployeeProfileServlet extends BaseServlet {

    private final EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }
        if (currentUser.getRoleId() != 5) {
            sendForbidden(request, response, "Bạn không có quyền truy cập hồ sơ nhân viên.");
            return;
        }

        try {
            EmployeeProfile profile = profileDAO.getProfileByUserId(currentUser.getId());
            if (profile == null) {
                response.sendError(404, "Không tìm thấy hồ sơ cá nhân.");
                return;
            }
            request.setAttribute("profile", profile);

            HttpSession session = request.getSession(false);
            if (session != null) {
                String[] messages = {"profileSuccess", "profileError"};
                for (String key : messages) {
                    Object value = session.getAttribute(key);
                    if (value != null) {
                        request.setAttribute(key, value);
                        session.removeAttribute(key);
                    }
                }
            }

            request.getRequestDispatcher("/WEB-INF/views/employee/profile.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải hồ sơ cá nhân.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }
        if (currentUser.getRoleId() != 5) {
            sendForbidden(request, response, "Bạn không có quyền cập nhật hồ sơ.");
            return;
        }

        if ("changePassword".equals(request.getParameter("action"))) {
            handleChangePassword(request, response, currentUser);
            return;
        }

        // Giữ nguyên chức năng cập nhật số điện thoại và email.
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        email = email == null ? "" : email.trim();
        phone = phone == null ? "" : phone.trim();
        String error = null;

        if (!email.isEmpty() && (email.length() > 100 ||
                !email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"))) {
            error = "Định dạng email không hợp lệ.";
        }
        if (error == null && !phone.isEmpty() && !phone.matches("^0\\d{9}$")) {
            error = "Số điện thoại phải có 10 chữ số và bắt đầu bằng 0.";
        }

        HttpSession session = request.getSession();
        if (error != null) {
            session.setAttribute("profileError", error);
            response.sendRedirect(request.getContextPath() + "/employee/profile");
            return;
        }

        try {
            profileDAO.updateMyContactInfo(currentUser.getId(),
                    email.isEmpty() ? null : email,
                    phone.isEmpty() ? null : phone);
            session.setAttribute("profileSuccess", "Cập nhật thông tin cá nhân thành công.");
        } catch (IllegalArgumentException e) {
            session.setAttribute("profileError", e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Không thể cập nhật hồ sơ cá nhân.", e);
        }
        response.sendRedirect(request.getContextPath() + "/employee/profile");
    }

    private void handleChangePassword(HttpServletRequest request,
            HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String oldPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        HttpSession session = request.getSession();
        String error = null;

        if (oldPassword == null || oldPassword.isEmpty() ||
                newPassword == null || newPassword.isEmpty() ||
                confirmPassword == null || confirmPassword.isEmpty()) {
            error = "Vui lòng nhập đầy đủ các ô mật khẩu.";
        } else if (newPassword.length() < 8 || newPassword.length() > 128) {
            error = "Mật khẩu mới phải từ 8 đến 128 ký tự.";
        } else if (!newPassword.equals(confirmPassword)) {
            error = "Xác nhận mật khẩu mới không khớp.";
        } else if (oldPassword.equals(newPassword)) {
            error = "Mật khẩu mới phải khác mật khẩu cũ.";
        }

        if (error != null) {
            session.setAttribute("profileError", error);
            response.sendRedirect(request.getContextPath() + "/employee/profile");
            return;
        }

        // Tương thích tạm thời với dữ liệu P: password_hash hiện chứa mật khẩu thường.
        // Để triển khai thực tế, thay bằng kiểm tra và lưu password hash an toàn,
        // đồng thời cập nhật cơ chế đăng nhập tương ứng.
        String selectSql = "SELECT password_hash FROM users "
                + "WHERE id = ? AND role_id = 5 AND status = 'ACTIVE'";
        String updateSql = "UPDATE users SET password_hash = ?, is_first_login = 0 "
                + "WHERE id = ? AND password_hash = ? AND role_id = 5 AND status = 'ACTIVE'";

        try (Connection conn = DBContext.getConnection()) {
            String storedPassword = null;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setInt(1, currentUser.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        storedPassword = rs.getString("password_hash");
                    }
                }
            }

            boolean correct = storedPassword != null && MessageDigest.isEqual(
                    oldPassword.getBytes(StandardCharsets.UTF_8),
                    storedPassword.getBytes(StandardCharsets.UTF_8));

            if (!correct) {
                session.setAttribute("profileError", "Mật khẩu hiện tại không đúng.");
            } else {
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, newPassword);
                    ps.setInt(2, currentUser.getId());
                    ps.setString(3, storedPassword);
                    updated = ps.executeUpdate();
                }
                session.setAttribute(updated == 1 ? "profileSuccess" : "profileError",
                        updated == 1 ? "Đổi mật khẩu thành công." :
                                "Mật khẩu đã thay đổi ở phiên khác. Vui lòng thử lại.");
            }
        } catch (Exception e) {
            throw new ServletException("Không thể đổi mật khẩu.", e);
        }

        response.sendRedirect(request.getContextPath() + "/employee/profile");
    }
}
