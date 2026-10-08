package controller.store;

import controller.base.BaseServlet;
import dao.AttendanceDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "StoreManagerAttendanceServlet", urlPatterns = {"/store-manager/attendance"})
public class StoreManagerAttendanceServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        // 2. Kiểm tra phân quyền Store Manager (ROLE_STORE_MANAGER = 4) hoặc Admin (ROLE_ADMIN = 1)
        if (currentUser.getRoleId() != ROLE_STORE_MANAGER && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Chấm công cửa hàng!");
            return;
        }

        // 3. Lấy dữ liệu bảng chấm công theo branchId của cửa hàng (Giữ nguyên luồng của bạn)
        AttendanceDAO attendanceDAO = new AttendanceDAO();
        // List<Attendance> attendances = attendanceDAO.getByBranch(currentUser.getHomeBranchId());
        // request.setAttribute("attendanceList", attendances);

        request.getRequestDispatcher("/WEB-INF/views/store-manager/attendance.jsp").forward(request, response);
    }
}