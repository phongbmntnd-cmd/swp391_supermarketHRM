package filter;

import model.User;
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(urlPatterns = {"/admin/*", "/director/*", "/hr/*", "/store-manager/*", "/employee/*"})
public class AuthFilter implements Filter {

    @Override
public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
        throws IOException, ServletException {

    HttpServletRequest req = (HttpServletRequest) request;
    HttpServletResponse res = (HttpServletResponse) response;
    HttpSession session = req.getSession(false);

    String path = req.getRequestURI().substring(req.getContextPath().length());

    // 1. CHO PHÉP TRUY CẬP FREELY VÀO TRANG LOGIN VÀ TÀI NGUYÊN TĨNH (CSS/JS)
    if (path.equals("/login") || path.equals("/login.jsp") || path.startsWith("/css/") || path.startsWith("/js/")) {
        chain.doFilter(request, response);
        return;
    }

    // 2. NẾU CHƯA ĐĂNG NHẬP MÀ CỐ TÌM CÁCH VÀO TRANG KHÁC -> MỚI CHUYỂN VỀ LOGIN
    User user = (session != null) ? (User) session.getAttribute("account") : null;

    if (user == null) {
        res.sendRedirect(req.getContextPath() + "/login.jsp");
        return;
    }

    // 3. KIỂM TRA QUYỀN TRUY CẬP THEO ROLE ID (Code cũ của bạn giữ nguyên bên dưới)
    int roleId = user.getRoleId();

    if (path.contains("/admin/") && roleId != 1) {
        res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang Admin!");
        return;
    } else if (path.contains("/director/") && roleId != 2) {
        res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang Giám Đốc!");
        return;
    } else if (path.contains("/hr/") && roleId != 3) {
        res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang HR!");
        return;
    } else if (path.contains("/store-manager/") && roleId != 4) {
        res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang Quản Lý Cửa Hàng!");
        return;
    } else if (path.contains("/employee/") && roleId != 5) {
        res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang Nhân Viên!");
        return;
    }

    // Cho phép đi tiếp nếu thỏa mãn mọi điều kiện
    chain.doFilter(request, response);
}

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}