package controller.employee;

import controller.base.BaseServlet;
import model.User;
import model.Employee;
import dao.EmployeeDAO;
import dao.ShiftScheduleDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/employee/dashboard")
public class EmployeeDashboardServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        // 2. Kiểm tra phân quyền Nhân viên (ROLE_EMPLOYEE = 5) hoặc Admin (ROLE_ADMIN = 1)
        if (currentUser.getRoleId() != ROLE_EMPLOYEE && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Nhân viên!");
            return;
        }

        try {
            // 3. Lấy thông tin chi tiết nhân viên (Cơ sở, Vị trí,...)
            EmployeeDAO empDao = new EmployeeDAO();
            Employee emp = empDao.getEmployeeById(currentUser.getId());

            // 4. Lấy danh sách toàn bộ ca trực trong ngày hôm nay của nhân viên
            ShiftScheduleDAO scheduleDao = new ShiftScheduleDAO();
            List<String> todayShifts = scheduleDao.getTodayShiftsForEmployee(currentUser.getId());

            request.setAttribute("emp", emp);
            request.setAttribute("todayShifts", todayShifts);

        } catch (Exception e) {
            e.printStackTrace();
        }

        // 5. Forward ra view dashboard.jsp
        request.getRequestDispatcher("/WEB-INF/views/employee/dashboard.jsp").forward(request, response);
    }
}