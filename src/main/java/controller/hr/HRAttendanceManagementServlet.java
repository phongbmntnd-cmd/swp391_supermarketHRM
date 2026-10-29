/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.hr;

import controller.base.BaseServlet;
import dao.AttendanceDAO;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.List;
import model.Attendance;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "HRAttendanceManagementServlet", urlPatterns = {"/hr/attendance-management"})
public class HRAttendanceManagementServlet extends BaseServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (!isHr(user)) {
            sendForbidden(request, response, "Chỉ HR mới được xem báo cáo chấm công toàn hệ thống.");
            return;
        }

        String adjustmentId = request.getParameter("adjustmentId");
        if (adjustmentId != null) {
            showAdjustmentPage(request, response, adjustmentId);
            return;
        }

        LocalDate today = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDate fromDate = today.withDayOfMonth(1);
        LocalDate toDate = today;
        String dateError = null;
        try {
            String fromParam = request.getParameter("fromDate");
            String toParam = request.getParameter("toDate");
            if (fromParam != null && !fromParam.trim().isEmpty()) {
                fromDate = LocalDate.parse(fromParam);
            }
            if (toParam != null && !toParam.trim().isEmpty()) {
                toDate = LocalDate.parse(toParam);
            }
            if (fromDate.isAfter(toDate)) {
                throw new DateTimeParseException("Ngày bắt đầu sau ngày kết thúc", fromDate.toString(), 0);
            }
            if (ChronoUnit.DAYS.between(fromDate, toDate) > 366) {
                throw new DateTimeParseException("Khoảng lọc quá dài", fromDate.toString(), 0);
            }
        } catch (DateTimeParseException e) {
            fromDate = today.withDayOfMonth(1);
            toDate = today;
            dateError = "Khoảng ngày không hợp lệ hoặc vượt quá 1 năm. Đang hiển thị dữ liệu từ đầu tháng đến hôm nay.";
        }

        try {
            List<Attendance> attendances = attendanceDAO.getAttendanceForHr(
                    Date.valueOf(fromDate), Date.valueOf(toDate));

            request.setAttribute("attendances", attendances);
            request.setAttribute("fromDate", fromDate.toString());
            request.setAttribute("toDate", toDate.toString());
            request.setAttribute("dateError", dateError);
            request.setAttribute("successMessage", getAndClearSuccessMessage(request));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.getRequestDispatcher("/WEB-INF/views/hr/attendance-management.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải danh sách chấm công cho HR.", e);
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
        if (!isHr(user)) {
            sendForbidden(request, response, "Chỉ HR mới được điều chỉnh dữ liệu chấm công.");
            return;
        }

        int attendanceId = getIntParameter(request, "attendanceId", -1);
        String note = getStringParameter(request, "adjustmentNote");
        LocalTime checkIn;
        LocalTime checkOut;
        try {
            checkIn = parseTime(request.getParameter("checkIn"));
            checkOut = parseTime(request.getParameter("checkOut"));
        } catch (DateTimeParseException e) {
            setErrorMessage(request, "Giờ vào hoặc giờ ra không hợp lệ.");
            redirectToAdjustment(request, response);
            return;
        }

        if (attendanceId <= 0 || note == null || note.length() > 1000
                || (checkIn == null && checkOut == null)
                || (checkIn != null && checkOut != null && !checkOut.isAfter(checkIn))) {
            setErrorMessage(request, "Thông tin điều chỉnh chưa hợp lệ. Hãy nhập ít nhất một giờ và ghi rõ lý do.");
            redirectToAdjustment(request, response);
            return;
        }

        try {
            boolean adjusted = attendanceDAO.adjustAttendance(attendanceId, user.getId(), checkIn, checkOut, note);
            if (adjusted) {
                setSuccessMessage(request, "Đã điều chỉnh giờ công, lưu lý do và ghi lại lịch sử xử lý.");
            } else {
                setErrorMessage(request, "Không tìm thấy bản ghi chấm công cần điều chỉnh.");
            }
        } catch (IllegalArgumentException e) {
            setErrorMessage(request, e.getMessage());
            redirectToAdjustment(request, response);
            return;
        } catch (Exception e) {
            throw new ServletException("Không thể lưu điều chỉnh chấm công.", e);
        }
        redirectToReport(request, response);
    }

    private boolean isHr(User user) {
        return user.getRoleId() == ROLE_HR_MANAGER || user.getRoleId() == ROLE_ADMIN;
    }

    private LocalTime parseTime(String value) {
        return value == null || value.trim().isEmpty() ? null : LocalTime.parse(value);
    }

    private void showAdjustmentPage(HttpServletRequest request, HttpServletResponse response, String idParam)
            throws ServletException, IOException {
        int attendanceId;
        try {
            attendanceId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/hr/attendance-management");
            return;
        }
        if (attendanceId <= 0) {
            response.sendRedirect(request.getContextPath() + "/hr/attendance-management");
            return;
        }

        try {
            Attendance attendance = attendanceDAO.getAttendanceForHrById(attendanceId);
            if (attendance == null) {
                response.sendRedirect(request.getContextPath() + "/hr/attendance-management");
                return;
            }
            request.setAttribute("attendance", attendance);
            request.setAttribute("fromDate", request.getParameter("fromDate"));
            request.setAttribute("toDate", request.getParameter("toDate"));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.getRequestDispatcher("/WEB-INF/views/hr/attendance-adjustment.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải trang điều chỉnh chấm công.", e);
        }
    }

    private void redirectToAdjustment(HttpServletRequest request, HttpServletResponse response) throws IOException {
        StringBuilder location = new StringBuilder(request.getContextPath())
                .append("/hr/attendance-management?adjustmentId=")
                .append(request.getParameter("attendanceId"));
        appendDateParameters(location, request);
        response.sendRedirect(location.toString());
    }

    private void redirectToReport(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String from = request.getParameter("fromDate");
        String to = request.getParameter("toDate");
        StringBuilder location = new StringBuilder(request.getContextPath()).append("/hr/attendance-management");
        if (from != null && !from.trim().isEmpty() && to != null && !to.trim().isEmpty()) {
            location.append("?fromDate=").append(from).append("&toDate=").append(to);
        }
        response.sendRedirect(location.toString());
    }

    private void appendDateParameters(StringBuilder location, HttpServletRequest request) {
        String from = request.getParameter("fromDate");
        String to = request.getParameter("toDate");
        if (isIsoDate(from) && isIsoDate(to)) {
            location.append("&fromDate=").append(from).append("&toDate=").append(to);
        }
    }

    private boolean isIsoDate(String value) {
        if (value == null) {
            return false;
        }
        try {
            LocalDate.parse(value);
            return true;
        } catch (DateTimeParseException e) {
            return false;
        }
    }

}
