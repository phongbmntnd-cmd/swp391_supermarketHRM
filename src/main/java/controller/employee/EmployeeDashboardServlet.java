package controller.employee;

import controller.base.BaseServlet;
import model.User;
import model.Employee;
import dao.EmployeeDAO;
import dao.LeaveRequestDAO;
import dao.ShiftChangeRequestDAO;
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

            // 4b. Đếm số đơn (nghỉ phép + đổi ca) đang chờ duyệt
            request.setAttribute(
                    "pendingRequestCount",
                    countPendingRequests(currentUser.getId())
            );

            // 4c. Badge số đơn đổi ca đang chờ MÌNH phản hồi
            request.setAttribute(
                    "incomingSwapCount",
                    countIncomingSwapRequests(currentUser.getId())
            );

        } catch (Exception e) {
            e.printStackTrace();
        }

        // 5. Forward ra view dashboard.jsp
        request.getRequestDispatcher("/WEB-INF/views/employee/dashboard.jsp").forward(request, response);
    }

    /**
     * Tổng số đơn (nghỉ phép + đổi ca) của nhân viên đang chờ duyệt.
     * Nếu lỗi truy vấn thì trả 0 để trang vẫn hiển thị bình thường.
     */
    private int countPendingRequests(int userId) {
        int total = 0;

        try {
            total += new LeaveRequestDAO()
                    .countMyPendingRequests(userId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            total += new ShiftChangeRequestDAO()
                    .countMyPendingShiftRequests(userId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return total;
    }

    /**
     * Số đơn đổi ca đang chờ nhân viên này phản hồi (đồng nghiệp gửi tới).
     */
    private int countIncomingSwapRequests(int userId) {
        try {
            return new ShiftChangeRequestDAO()
                    .countIncomingShiftRequests(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }
}