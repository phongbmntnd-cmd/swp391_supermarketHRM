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

// SỬA 1: Đổi urlPatterns thành "/*" để Filter chặn MỌI request (bao gồm cả /login và /login.jsp)
@WebFilter(urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Chống lưu Cache: Ép trình duyệt hỏi lại Server khi bấm Back/Forward
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        HttpSession session = req.getSession(false);
        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Cho phép tài nguyên tĩnh và servlet logout đi qua tự do
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/") || path.equals("/logout")) {
            chain.doFilter(request, response);
            return;
        }

        User user = (session != null) ? (User) session.getAttribute("account") : null;

        // 1. XỬ LÝ KHI TRUY CẬP TRANG LOGIN
        if (path.equals("/login") || path.equals("/login.jsp") || path.equals("/")) {
            // NẾU ĐÃ ĐĂNG NHẬP -> Tự động bật ngược lại Dashboard, KHÔNG cho xem trang Login
            if (user != null) {
                redirectToDashboard(res, req.getContextPath(), user.getRoleId());
                return;
            }
            // Chưa đăng nhập -> Cho xem trang Login
            chain.doFilter(request, response);
            return;
        }

        // 2. CHƯA ĐĂNG NHẬP MÀ CỐ VÀO TRANG NỘI BỘ -> Ép về Login
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        // 3. KIỂM TRA QUYỀN TRUY CẬP
        int roleId = user.getRoleId();
        boolean hasAccess = true;

        if (path.contains("/admin/") && roleId != 1) hasAccess = false;
        else if (path.contains("/director/") && roleId != 2) hasAccess = false;
        else if (path.contains("/hr/") && roleId != 3) hasAccess = false;
        else if (path.contains("/store-manager/") && roleId != 4) hasAccess = false;
        else if (path.contains("/employee/") && roleId != 5) hasAccess = false;

        // SỬA 2: Thay vì hiện lỗi 403, tự đưa về đúng Dashboard của tài khoản hiện tại
        if (!hasAccess) {
            redirectToDashboard(res, req.getContextPath(), roleId);
            return;
        }

        chain.doFilter(request, response);
    }

    // Hàm phụ trợ giúp chuyển hướng gọn gàng
    private void redirectToDashboard(HttpServletResponse res, String contextPath, int roleId) throws IOException {
        switch (roleId) {
            case 1: res.sendRedirect(contextPath + "/admin/dashboard"); break;
            case 2: res.sendRedirect(contextPath + "/director/dashboard"); break;
            case 3: res.sendRedirect(contextPath + "/hr/dashboard"); break;
            case 4: res.sendRedirect(contextPath + "/store-manager/dashboard"); break;
            case 5: res.sendRedirect(contextPath + "/employee/dashboard"); break;
            default: res.sendRedirect(contextPath + "/login.jsp"); break;
        }
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}