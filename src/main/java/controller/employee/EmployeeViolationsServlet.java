package controller.employee;

import controller.base.BaseServlet;
import dao.ViolationDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/employee/violations")
public class EmployeeViolationsServlet extends BaseServlet {

    private final ViolationDAO violationDAO = new ViolationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (user.getRoleId() != ROLE_EMPLOYEE) {
            sendForbidden(request, response, "Trang này chỉ dành cho nhân viên.");
            return;
        }
        try {
            request.setAttribute("violations", violationDAO.getByEmployee(user.getId()));
            request.getRequestDispatcher("/WEB-INF/views/employee/violations.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải lịch sử báo cáo liên quan đến bạn.", e);
        }
    }
}
