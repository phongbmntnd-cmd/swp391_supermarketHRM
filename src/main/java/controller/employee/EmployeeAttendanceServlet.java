/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.employee;

import controller.base.BaseServlet;
import dao.AttendanceDAO;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import model.Attendance;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "EmployeeAttendanceServlet", urlPatterns = {"/employee/attendance"})
public class EmployeeAttendanceServlet extends BaseServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (user.getRoleId() != ROLE_EMPLOYEE && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập chức năng chấm công cá nhân.");
            return;
        }

        LocalDate today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        try {
            List<Attendance> todayShifts = attendanceDAO.getEmployeeShifts(user.getId(), Date.valueOf(today));
            List<Attendance> recentAttendance = attendanceDAO.getRecentEmployeeAttendance(
                    user.getId(), Date.valueOf(today));
            request.setAttribute("todayShifts", todayShifts);
            request.setAttribute("recentAttendance", recentAttendance);
            request.setAttribute("today", today);
            request.setAttribute("successMessage", getAndClearSuccessMessage(request));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.getRequestDispatcher("/WEB-INF/views/employee/attendance.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải thông tin chấm công.", e);
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
        if (user.getRoleId() != ROLE_EMPLOYEE && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện chấm công cá nhân.");
            return;
        }

        int shiftScheduleId;
        try {
            shiftScheduleId = Integer.parseInt(request.getParameter("shiftScheduleId"));
        } catch (NumberFormatException | NullPointerException e) {
            setErrorMessage(request, "Ca làm được chọn không hợp lệ.");
            redirectToAttendance(request, response);
            return;
        }
        if (shiftScheduleId <= 0) {
            setErrorMessage(request, "Ca làm được chọn không hợp lệ.");
            redirectToAttendance(request, response);
            return;
        }

        String action = request.getParameter("action");
        Date today = Date.valueOf(LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")));
        try {
            if ("checkIn".equals(action)) {
                attendanceDAO.recordCheckIn(user.getId(), shiftScheduleId, today);
                setSuccessMessage(request, "Đã ghi nhận giờ chấm công vào.");
            } else if ("checkOut".equals(action)) {
                attendanceDAO.recordCheckOut(user.getId(), shiftScheduleId, today);
                setSuccessMessage(request, "Đã ghi nhận giờ chấm công ra.");
            } else {
                setErrorMessage(request, "Thao tác chấm công không hợp lệ.");
            }
        } catch (IllegalStateException e) {
            setErrorMessage(request, e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Không thể lưu thông tin chấm công.", e);
        }
        redirectToAttendance(request, response);
    }

    private void redirectToAttendance(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/employee/attendance");
    }
}
