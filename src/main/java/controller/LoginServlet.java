package controller;

import controller.base.BaseServlet;
import dao.AuditLogDAO;
import dao.UserDAO;
import model.AuditLog;
import model.User;
import util.AuditDescription;
import java.io.IOException;
import java.util.UUID;
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

        // Truyền thông báo lỗi nếu user bị khóa / inactive do AuthFilter đá về
        if ("1".equals(request.getParameter("locked"))) {
            request.setAttribute("error", "Tài khoản của bạn đã bị tạm khóa bởi Admin. Vui lòng liên hệ quản trị viên để được mở khóa.");
        } else if ("1".equals(request.getParameter("inactive"))) {
            request.setAttribute("error", "Tài khoản của bạn hiện không hoạt động. Vui lòng liên hệ quản trị viên.");
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
            // Ghi audit log đăng nhập thất bại (sai tên đăng nhập / mật khẩu, hoặc tài khoản không ACTIVE)
            logLoginFailed(request, username);
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            // 2. XÓA SẠCH SESSION CỦ
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            // Tạo Session hoàn toàn mới cho tài khoản vừa đăng nhập
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("account", account);

            // 3. SINH MÃ TOKEN DUY NHẤT VÀ ĐÁNH DẤU PHIÊN ĐĂNG NHẬP MỚI
            String activeToken = UUID.randomUUID().toString();
            newSession.setAttribute("activeToken", activeToken);
            // Lưu token mới nhất của User này vào ServletContext
            getServletContext().setAttribute("user_token_" + account.getId(), activeToken);

            // 4. Ghi audit log đăng nhập thành công
            logLoginSuccess(request, account);

            // 5. Nếu là lần đầu đăng nhập -> Chuyển sang đổi mật khẩu
            if (account.isFirstLogin()) {
                response.sendRedirect(request.getContextPath() + "/change-password");
                return;
            }

            // 6. Điều hướng tới Dashboard đúng vai trò
            redirectByRole(account.getRoleId(), request, response);
        }
    }

    /**
     * Ghi audit log đăng nhập thành công.
     * target_user_id để null vì không có "đối tượng bị tác động" khi đăng nhập.
     */
    private void logLoginSuccess(HttpServletRequest request, User account) {
        try {
            String desc = AuditDescription.auth(account.getUsername(), account.getFullName(), true);
            new AuditLogDAO().log(AuditLog.ACTION_LOGIN, account.getId(), null,
                    AuditLog.ENTITY_USER, account.getId(), desc, getClientIp(request));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Ghi audit log đăng nhập thất bại.
     * Nếu username tồn tại thì ghi luôn actor_id để Admin lọc/tra cứu được;
     * nếu không tồn tại thì để null (mô tả vẫn chứa username đã nhập).
     */
    private void logLoginFailed(HttpServletRequest request, String username) {
        try {
            Integer actorId = null;
            String actorName = null;
            try {
                User u = new UserDAO().getUserByUsername(username);
                if (u != null) {
                    actorId = u.getId();
                    actorName = u.getFullName() != null ? u.getFullName() : u.getUsername();
                }
            } catch (Exception ignore) {
                // Không tìm thấy user -> actorId giữ null
            }
            String desc = AuditDescription.auth(username, actorName, false);
            new AuditLogDAO().log(AuditLog.ACTION_LOGIN_FAILED, actorId, null,
                    null, null, desc, getClientIp(request));
        } catch (Exception e) {
            e.printStackTrace();
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