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
 * Hỗ trợ tìm kiếm theo từ khoá và lọc theo vị trí / phòng ban / loại nhân viên.
 */
@WebServlet("/hr/employee-list")
public class EmployeeManagementServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        Integer positionId = parseIntOrNull(request.getParameter("positionId"));
        Integer departmentId = parseIntOrNull(request.getParameter("departmentId"));
        String employeeType = request.getParameter("employeeType");

        EmployeeDAO employeeDAO = new EmployeeDAO();
        List<Employee> employees = employeeDAO.getAllEmployees(keyword, positionId, departmentId, employeeType);

        request.setAttribute("employees", employees);
        request.setAttribute("keyword", keyword);
        request.setAttribute("positionId", positionId);
        request.setAttribute("departmentId", departmentId);
        request.setAttribute("employeeType", employeeType);

        // Dữ liệu đổ vào 3 dropdown lọc
        request.setAttribute("positions", employeeDAO.getAllPositionsFull());
        request.setAttribute("departments", employeeDAO.getAllDepartmentsFull());

        request.getRequestDispatcher("/WEB-INF/views/hr/employee-list.jsp")
                .forward(request, response);
    }

    private Integer parseIntOrNull(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
