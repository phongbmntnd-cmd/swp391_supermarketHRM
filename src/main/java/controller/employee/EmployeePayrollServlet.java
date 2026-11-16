/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.employee;

import controller.base.BaseServlet;
import dao.PayrollDAO;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

@WebServlet("/employee/payroll")
public class EmployeePayrollServlet extends BaseServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (user.getRoleId() != ROLE_EMPLOYEE) {
            sendForbidden(request, response, "Trang phiếu lương chỉ dành cho nhân viên.");
            return;
        }
        try {
            request.setAttribute("payslips", payrollDAO.getFinalizedPayslipsForEmployee(user.getId()));
            request.getRequestDispatcher("/WEB-INF/views/employee/payroll.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Không thể tải phiếu lương của bạn.", e);
        }
    }
}
