package controller.employee;

import controller.base.BaseServlet;
import dao.EmployeeAvailabilityDAO;
import model.EmployeeAvailability;
import model.Shift;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "EmployeeAvailabilityServlet", urlPatterns = {"/employee/availability"})
public class EmployeeAvailabilityServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // --- XÁC THỰC PHIÊN ĐĂNG NHẬP QUA BASESERVLET ---
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        // Kiểm tra phân quyền (Phải là Nhân viên hoặc Admin)
        if (!hasRole(request, ROLE_EMPLOYEE) && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang khai báo lịch rảnh!");
            return;
        }

        // Tính toán ngày bắt đầu và kết thúc của tuần tới (Thứ Hai tới Chủ Nhật tuần sau)
        LocalDate today = LocalDate.now();
        LocalDate nextMonday = today.with(TemporalAdjusters.next(DayOfWeek.MONDAY));
        LocalDate nextSunday = nextMonday.plusDays(6);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        
        request.setAttribute("startDate", nextMonday.format(formatter));
        request.setAttribute("endDate", nextSunday.format(formatter));

        // Kiểm tra deadline đăng ký (Mở đến 23:59 Thứ Bảy)
        LocalDateTime now = LocalDateTime.now();
        boolean isRegistrationOpen = (now.getDayOfWeek() != DayOfWeek.SUNDAY);
        request.setAttribute("isRegistrationOpen", isRegistrationOpen);

        EmployeeAvailabilityDAO dao = new EmployeeAvailabilityDAO();
        List<Shift> shifts = dao.getAllShifts();
        List<EmployeeAvailability> currentAvailabilities = dao.getAvailabilitiesByUserId(user.getId());

        // Kiểm tra xem nhân viên đã đăng ký lịch rảnh chưa để hiển thị trạng thái
        boolean hasRegistered = (currentAvailabilities != null && !currentAvailabilities.isEmpty());
        request.setAttribute("hasRegistered", hasRegistered);

        request.setAttribute("shifts", shifts);
        request.setAttribute("currentAvailabilities", currentAvailabilities);
        
        request.getRequestDispatcher("/WEB-INF/views/employee/availability.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // --- XÁC THỰC PHIÊN ĐĂNG NHẬP QUA BASESERVLET ---
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        if (!hasRole(request, ROLE_EMPLOYEE) && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        if (now.getDayOfWeek() == DayOfWeek.SUNDAY) {
            response.sendRedirect("availability?error=closed");
            return;
        }

        String[] selectedAvailabilities = request.getParameterValues("availabilities");
        List<EmployeeAvailability> newAvailabilities = new ArrayList<>();

        if (selectedAvailabilities != null) {
            for (String item : selectedAvailabilities) {
                String[] parts = item.split("_");
                if (parts.length == 2) {
                    String dayOfWeek = parts[0];
                    int shiftId = Integer.parseInt(parts[1]);
                    newAvailabilities.add(new EmployeeAvailability(0, user.getId(), dayOfWeek, shiftId));
                }
            }
        }

        EmployeeAvailabilityDAO dao = new EmployeeAvailabilityDAO();
        dao.saveAvailabilities(user.getId(), newAvailabilities);

        response.sendRedirect("availability?success=true");
    }
}