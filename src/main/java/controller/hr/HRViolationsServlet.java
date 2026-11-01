package controller.hr;

import controller.base.BaseServlet;
import dao.ViolationDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/hr/violations")
public class HRViolationsServlet extends BaseServlet {

    private final ViolationDAO violationDAO = new ViolationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (!isHr(user)) {
            sendForbidden(request, response, "Chỉ HR mới được xác minh và quyết định xử lý vi phạm.");
            return;
        }
        try {
            request.setAttribute("pendingViolations", violationDAO.getPendingForHr());
            request.setAttribute("reviewedViolations", violationDAO.getReviewedForHr());
            request.setAttribute("successMessage", getAndClearSuccessMessage(request));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.getRequestDispatcher("/WEB-INF/views/hr/violations.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải danh sách cần xác minh.", e);
        }
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
        if (!isHr(user)) {
            sendForbidden(request, response, "Chỉ HR mới được xác minh và quyết định xử lý vi phạm.");
            return;
        }

        int id = getIntParameter(request, "violationId", -1);
        String action = getStringParameter(request, "action");
        String reviewNote = getStringParameter(request, "reviewNote");
        String disciplinaryAction = getStringParameter(request, "disciplinaryAction");
        boolean approved = "approve".equals(action);
<<<<<<< HEAD
        if (id <= 0 || (!approved && !"reject".equals(action))
                || (approved && (disciplinaryAction == null || disciplinaryAction.length() > 1000))
=======
        boolean terminateEmployment = "true".equals(request.getParameter("terminateEmployment"));
        String savedDisciplinaryAction = terminateEmployment
                ? "Chấm dứt hợp đồng do vi phạm nghiêm trọng. " + (disciplinaryAction == null ? "" : disciplinaryAction)
                : disciplinaryAction;
        if (id <= 0 || (!approved && !"reject".equals(action))
                || (approved && (disciplinaryAction == null || disciplinaryAction.length() > 1000))
                || (approved && terminateEmployment && savedDisciplinaryAction.length() > 1000)
                || (!approved && terminateEmployment)
>>>>>>> origin/update_luồng_vi_phạm
                || (reviewNote != null && reviewNote.length() > 1000)
                || (!approved && reviewNote == null)) {
            setErrorMessage(request, "Thông tin xét duyệt chưa hợp lệ. Khi từ chối, HR cần ghi rõ lý do.");
            response.sendRedirect(request.getContextPath() + "/hr/violations");
            return;
        }

        try {
<<<<<<< HEAD
            boolean updated = violationDAO.review(id, user.getId(), approved, reviewNote,
                    approved ? disciplinaryAction : null);
            if (updated) {
                setSuccessMessage(request, approved
                        ? "Đã xác minh và lưu quyết định xử lý. Nhân viên có thể xem kết quả trong tài khoản."
                        : "Đã từ chối báo cáo và lưu lý do. Nhân viên có thể xem kết quả trong tài khoản.");
=======
            ViolationDAO.ReviewResult result = violationDAO.review(id, user.getId(), approved, reviewNote,
                    approved ? savedDisciplinaryAction : null, terminateEmployment);
            if (result.isUpdated()) {
                if (result.getTerminatedEmployeeId() > 0) {
                    request.getServletContext().removeAttribute(
                            "user_token_" + result.getTerminatedEmployeeId());
                    setSuccessMessage(request, "Đã chấm dứt hợp đồng và vô hiệu hóa tài khoản do vi phạm nghiêm trọng.");
                } else {
                    setSuccessMessage(request, approved
                            ? "Đã xác minh và lưu quyết định xử lý. Khoản khấu trừ đã được ghi nhận từ lúc tạo báo cáo."
                            : "Đã từ chối báo cáo và lưu lý do. Nhân viên có thể xem kết quả trong tài khoản.");
                }
>>>>>>> origin/update_luồng_vi_phạm
            } else {
                setErrorMessage(request, "Báo cáo không tồn tại hoặc đã được HR xử lý trước đó.");
            }
        } catch (Exception e) {
            throw new ServletException("Không thể lưu kết quả xét duyệt vi phạm.", e);
        }
        response.sendRedirect(request.getContextPath() + "/hr/violations");
    }

    private boolean isHr(User user) {
        return user.getRoleId() == ROLE_HR_MANAGER || user.getRoleId() == ROLE_ADMIN;
    }
}
