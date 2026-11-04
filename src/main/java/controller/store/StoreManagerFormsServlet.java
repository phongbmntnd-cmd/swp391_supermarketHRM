package controller.store;

import dao.LeaveRequestDAO;
import dao.ShiftChangeRequestDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Trang trung tâm "Đơn từ & Khiếu nại" của Store Manager.
 * Liệt kê các nhóm đơn cần xét duyệt kèm số đơn đang chờ.
 */
@WebServlet(
    name = "StoreManagerFormsServlet",
    urlPatterns = {"/store-manager/forms"}
)
public class StoreManagerFormsServlet extends HttpServlet {

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null
                : (User) session.getAttribute("account");
    }

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (user.getRoleId() != 4 || user.getHomeBranchId() <= 0) {
            resp.sendError(403);
            return;
        }

        try {
            LeaveRequestDAO leaveDao = new LeaveRequestDAO();
            ShiftChangeRequestDAO shiftDao = new ShiftChangeRequestDAO();

            int branchId = user.getHomeBranchId();

            List<Map<String, Object>> forms = new ArrayList<>();

            forms.add(buildForm(
                "leave",
                "Duyệt nghỉ phép",
                "Xét duyệt các đơn xin nghỉ phép của nhân viên trong chi nhánh. "
                + "Khi duyệt, hệ thống tự đánh dấu ca làm việc và trừ quota.",
                "fa-plane-departure",
                "#16a34a",
                "/store-manager/leave-requests",
                leaveDao.countBranchPendingRequests(branchId)
            ));

            forms.add(buildForm(
                "shift",
                "Duyệt đổi ca",
                "Xét duyệt các yêu cầu đổi ca làm việc "
                + "(đổi với đồng nghiệp hoặc chuyển sang ca trống).",
                "fa-arrows-rotate",
                "#2563eb",
                "/store-manager/shift-requests",
                shiftDao.countBranchPendingShiftRequests(branchId)
            ));

            req.setAttribute("forms", forms);

            req.getRequestDispatcher(
                "/WEB-INF/views/store-manager/forms.jsp"
            ).forward(req, resp);

        } catch (IllegalStateException e) {
            throw new ServletException(e);
        }
    }

    private Map<String, Object> buildForm(
            String key,
            String title,
            String description,
            String icon,
            String color,
            String url,
            int pendingCount) {

        Map<String, Object> form = new LinkedHashMap<>();
        form.put("key", key);
        form.put("title", title);
        form.put("description", description);
        form.put("icon", icon);
        form.put("color", color);
        form.put("url", url);
        form.put("pendingCount", pendingCount);

        return form;
    }
}
