package controller.employee;

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
 * Trang trung tâm "Đơn từ & Khiếu nại" của Employee.
 * Hiển thị danh sách các loại đơn, người dùng chọn loại đơn
 * để tạo đơn lên Store Manager.
 */
@WebServlet(
    name = "EmployeeFormsServlet",
    urlPatterns = {"/employee/forms"}
)
public class EmployeeFormsServlet extends HttpServlet {

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

        if (user.getRoleId() != 5) {
            resp.sendError(403);
            return;
        }

        try {
            LeaveRequestDAO leaveDao = new LeaveRequestDAO();
            ShiftChangeRequestDAO shiftDao = new ShiftChangeRequestDAO();

            List<Map<String, Object>> forms = new ArrayList<>();

            forms.add(buildForm(
                "leave",
                "Xin nghỉ phép",
                "Gửi đơn xin nghỉ (phép, không phép, tang, hiếu...). "
                + "Hệ thống tự trừ quota khi Store Manager duyệt.",
                "fa-plane-departure",
                "#16a34a",
                "/employee/leave-request",
                leaveDao.countMyPendingRequests(user.getId())
            ));

            forms.add(buildForm(
                "shift",
                "Đổi ca làm",
                "Đề nghị đổi ca với đồng nghiệp hoặc chuyển sang ca trống "
                + "tại cơ sở.",
                "fa-arrows-rotate",
                "#2563eb",
                "/employee/request-shift",
                shiftDao.countMyPendingShiftRequests(user.getId())
            ));

            req.setAttribute("forms", forms);

            // Badge số đơn đổi ca đang chờ mình phản hồi
            req.setAttribute(
                    "incomingSwapCount",
                    shiftDao.countIncomingShiftRequests(user.getId())
            );

            req.getRequestDispatcher(
                "/WEB-INF/views/employee/forms.jsp"
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
