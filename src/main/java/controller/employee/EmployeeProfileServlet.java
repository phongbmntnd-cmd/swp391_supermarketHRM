
package controller.employee;

import controller.base.BaseServlet;
import dao.EmployeeProfileDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.EmployeeProfile;
import model.User;

@WebServlet("/employee/profile")
public class EmployeeProfileServlet extends BaseServlet {

    private final EmployeeProfileDAO profileDAO =
            new EmployeeProfileDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != 5) {
            sendForbidden(request, response,
                    "Bạn không có quyền truy cập hồ sơ nhân viên.");
            return;
        }

        try {
            EmployeeProfile profile =
                    profileDAO.getProfileByUserId(currentUser.getId());

            if (profile == null) {
                response.sendError(404,
                        "Không tìm thấy hồ sơ cá nhân.");
                return;
            }

            request.setAttribute("profile", profile);

            HttpSession session = request.getSession(false);

            if (session != null) {
                String[] messages = {
                    "profileSuccess",
                    "profileError"
                };

                for (String key : messages) {
                    Object value = session.getAttribute(key);

                    if (value != null) {
                        request.setAttribute(key, value);
                        session.removeAttribute(key);
                    }
                }
            }

            request.getRequestDispatcher(
                    "/WEB-INF/views/employee/profile.jsp"
            ).forward(request, response);

        } catch (Exception e) {
            throw new ServletException(
                    "Không thể tải hồ sơ cá nhân.", e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != 5) {
            sendForbidden(request, response,
                    "Bạn không có quyền cập nhật hồ sơ.");
            return;
        }

        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        email = email == null ? "" : email.trim();
        phone = phone == null ? "" : phone.trim();

        String error = null;

        // Kiểm tra email nếu có nhập
        if (!email.isEmpty()
                && (email.length() > 100
                || !email.matches(
                    "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"))) {

            error = "Định dạng email không hợp lệ.";
        }

        // Kiểm tra số điện thoại Việt Nam
        if (error == null
                && !phone.isEmpty()
                && !phone.matches("^0\\d{9}$")) {

            error = "Số điện thoại phải có 10 chữ số và bắt đầu bằng 0.";
        }

        HttpSession session = request.getSession();

        if (error != null) {
            session.setAttribute("profileError", error);

            response.sendRedirect(
                    request.getContextPath() + "/employee/profile");
            return;
        }

        try {
            profileDAO.updateMyContactInfo(
                    currentUser.getId(),
                    email.isEmpty() ? null : email,
                    phone.isEmpty() ? null : phone
            );

            session.setAttribute(
                    "profileSuccess",
                    "Cập nhật thông tin cá nhân thành công."
            );

        } catch (IllegalArgumentException e) {
            session.setAttribute(
                    "profileError",
                    e.getMessage()
            );

        } catch (Exception e) {
            throw new ServletException(
                    "Không thể cập nhật hồ sơ cá nhân.", e);
        }

        response.sendRedirect(
                request.getContextPath() + "/employee/profile");
    }
}
