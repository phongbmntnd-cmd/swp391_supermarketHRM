package controller.store;

import controller.base.BaseServlet;
import dao.AttendanceDAO;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.util.List;
import model.Attendance;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "StoreManagerAttendanceServlet", urlPatterns = {"/store-manager/attendance"})
public class StoreManagerAttendanceServlet extends BaseServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (user.getRoleId() != ROLE_STORE_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập bảng chấm công cửa hàng.");
            return;
        }
        if (user.getRoleId() == ROLE_STORE_MANAGER && user.getHomeBranchId() <= 0) {
            sendForbidden(request, response, "Tài khoản quản lý chưa được gán chi nhánh.");
            return;
        }

        LocalDate workDate = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        String dateParam = request.getParameter("date");
        String dateError = null;
        if (dateParam != null && !dateParam.trim().isEmpty()) {
            try {
                workDate = LocalDate.parse(dateParam);
            } catch (DateTimeParseException e) {
                dateError = "Ngày lọc không hợp lệ. Đang hiển thị chấm công hôm nay.";
            }
        }

        try {
            List<Attendance> attendances = attendanceDAO.getBranchAttendance(
                    user.getRoleId() == ROLE_ADMIN ? 0 : user.getHomeBranchId(),
                    Date.valueOf(workDate));
            request.setAttribute("attendances", attendances);
            request.setAttribute("selectedDate", workDate.toString());
            request.setAttribute("successMessage", getAndClearSuccessMessage(request));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.setAttribute("dateError", dateError);
            request.getRequestDispatcher("/WEB-INF/views/store-manager/attendance.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải bảng chấm công của chi nhánh.", e);
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
        if (user.getRoleId() != ROLE_STORE_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền duyệt chấm công.");
            return;
        }
        if (user.getRoleId() == ROLE_STORE_MANAGER && user.getHomeBranchId() <= 0) {
            sendForbidden(request, response, "Tài khoản quản lý chưa được gán chi nhánh.");
            return;
        }

        int attendanceId;
        try {
            attendanceId = Integer.parseInt(request.getParameter("attendanceId"));
        } catch (NumberFormatException | NullPointerException e) {
            setErrorMessage(request, "Bản ghi chấm công không hợp lệ.");
            redirectToSelectedDate(request, response);
            return;
        }
        String status = request.getParameter("status");
        if (attendanceId <= 0 || (!"VALID".equals(status) && !"INVALID".equals(status))) {
            setErrorMessage(request, "Kết quả duyệt chấm công không hợp lệ.");
            redirectToSelectedDate(request, response);
            return;
        }

        try {
            boolean updated = attendanceDAO.reviewAttendance(attendanceId,
                    user.getRoleId() == ROLE_ADMIN ? 0 : user.getHomeBranchId(), status);
            if (updated) {
                setSuccessMessage(request, "Đã cập nhật kết quả duyệt chấm công.");
            } else {
                setErrorMessage(request, "Không tìm thấy bản ghi thuộc chi nhánh của bạn.");
            }
        } catch (Exception e) {
            throw new ServletException("Không thể duyệt bản ghi chấm công.", e);
        }
        redirectToSelectedDate(request, response);
    }

    private void redirectToSelectedDate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String date = request.getParameter("date");
        LocalDate selectedDate;
        try {
            selectedDate = date == null
                    ? LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"))
                    : LocalDate.parse(date);
        } catch (DateTimeParseException e) {
            selectedDate = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        }
        response.sendRedirect(request.getContextPath()
                + "/store-manager/attendance?date=" + selectedDate);
    }
}
