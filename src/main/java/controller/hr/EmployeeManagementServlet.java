package controller.hr;

import dao.EmployeeDAO;
import model.Employee;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Trang danh sách "Quản lý Hồ sơ Nhân sự" - khớp với URL /hr/employee-management
 * đang được liên kết từ dashboard.jsp của HR.
 */
@WebServlet("/hr/employee-management")
public class EmployeeManagementServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");

        EmployeeDAO employeeDAO = new EmployeeDAO();
        List<Employee> employees = employeeDAO.getAllEmployees(keyword);

        request.setAttribute("employees", employees);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/hr/employee-list.jsp")
                .forward(request, response);
    }
}
