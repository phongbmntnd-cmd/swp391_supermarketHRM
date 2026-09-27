package servlet.base;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;

/**
 * BaseServlet - Cung cấp các phương thức dùng chung cho các Servlet con.
 * KHÔNG chứa business logic riêng của chức năng cụ thể.
 */
public abstract class BaseServlet extends HttpServlet {

    // Các hằng số cho Role
    public static final int ROLE_ADMIN = 1;
    public static final int ROLE_DIRECTOR = 2;
    public static final int ROLE_HR_MANAGER = 3;
    public static final int ROLE_STORE_MANAGER = 4;
    public static final int ROLE_EMPLOYEE = 5;

    // Các hằng số cho Status
    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_EMERGENCY_LOCKED = "EMERGENCY_LOCKED";

    // Session attribute name
    public static final String SESSION_USER = "account";

    /**
     * Lấy User hiện tại từ session.
     * @param request HttpServletRequest
     * @return User đang đăng nhập, hoặc null nếu chưa đăng nhập
     */
    protected User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(SESSION_USER);
        }
        return null;
    }

    /**
     * Kiểm tra session có tồn tại không.
     * @param request HttpServletRequest
     * @return true nếu session tồn tại
     */
    protected boolean hasSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute(SESSION_USER) != null;
    }

    /**
     * Kiểm tra user hiện tại có role cụ thể không.
     * @param request HttpServletRequest
     * @param roleId Role ID cần kiểm tra
     * @return true nếu user có role tương ứng
     */
    protected boolean hasRole(HttpServletRequest request, int roleId) {
        User user = getCurrentUser(request);
        return user != null && user.getRoleId() == roleId;
    }

    /**
     * Kiểm tra user hiện tại có phải Store Manager không.
     * @param request HttpServletRequest
     * @return true nếu user là Store Manager
     */
    protected boolean isStoreManager(HttpServletRequest request) {
        return hasRole(request, ROLE_STORE_MANAGER);
    }

    /**
     * Lấy branch ID của Store Manager hiện tại.
     * @param request HttpServletRequest
     * @return branch ID, hoặc -1 nếu không có quyền hoặc chưa đăng nhập
     */
    protected int getCurrentBranchId(HttpServletRequest request) {
        User user = getCurrentUser(request);
        if (user != null) {
            return user.getHomeBranchId();
        }
        return -1;
    }

    /**
     * Chuyển hướng đến trang đăng nhập.
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     */
    protected void redirectToLogin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    /**
     * Trả về lỗi 403 Forbidden.
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param message Thông báo lỗi
     */
    protected void sendForbidden(HttpServletRequest request, HttpServletResponse response, String message) 
            throws IOException, ServletException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(request, response);
    }

    /**
     * Trả về lỗi 404 Not Found.
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param message Thông báo lỗi
     */
    protected void sendNotFound(HttpServletRequest request, HttpServletResponse response, String message) 
            throws IOException, ServletException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/WEB-INF/views/error/404.jsp").forward(request, response);
    }

    /**
     * Trả về lỗi 500 Internal Server Error.
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param message Thông báo lỗi
     */
    protected void sendInternalError(HttpServletRequest request, HttpServletResponse response, String message) 
            throws IOException, ServletException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/WEB-INF/views/error/500.jsp").forward(request, response);
    }

    /**
     * Chuyển hướng về trang dashboard của Store Manager.
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     */
    protected void redirectToDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/store-manager/dashboard");
    }

    /**
     * Đặt thông báo thành công vào session.
     * @param request HttpServletRequest
     * @param message Thông báo thành công
     */
    protected void setSuccessMessage(HttpServletRequest request, String message) {
        request.getSession().setAttribute("successMessage", message);
    }

    /**
     * Đặt thông báo lỗi vào session.
     * @param request HttpServletRequest
     * @param message Thông báo lỗi
     */
    protected void setErrorMessage(HttpServletRequest request, String message) {
        request.getSession().setAttribute("errorMessage", message);
    }

    /**
     * Lấy và xóa thông báo thành công từ session.
     * @param request HttpServletRequest
     * @return Thông báo thành công, hoặc null
     */
    protected String getAndClearSuccessMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String message = (String) session.getAttribute("successMessage");
            session.removeAttribute("successMessage");
            return message;
        }
        return null;
    }

    /**
     * Lấy và xóa thông báo lỗi từ session.
     * @param request HttpServletRequest
     * @return Thông báo lỗi, hoặc null
     */
    protected String getAndClearErrorMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String message = (String) session.getAttribute("errorMessage");
            session.removeAttribute("errorMessage");
            return message;
        }
        return null;
    }

    /**
     * Lấy tham số int từ request, trả về default nếu null hoặc lỗi.
     * @param request HttpServletRequest
     * @param paramName Tên tham số
     * @param defaultValue Giá trị mặc định
     * @return Giá trị int
     */
    protected int getIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        String value = request.getParameter(paramName);
        if (value != null && !value.trim().isEmpty()) {
            try {
                return Integer.parseInt(value.trim());
            } catch (NumberFormatException e) {
                return defaultValue;
            }
        }
        return defaultValue;
    }

    /**
     * Lấy tham số String từ request, trim và trả về null nếu rỗng.
     * @param request HttpServletRequest
     * @param paramName Tên tham số
     * @return Giá trị String, hoặc null
     */
    protected String getStringParameter(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        if (value != null && !value.trim().isEmpty()) {
            return value.trim();
        }
        return null;
    }
}
