package controller.employee;

import controller.base.BaseServlet;
import dao.EmployeeAvailabilityDAO;
import dao.EmployeeProfileDAO;
import model.EmployeeAvailability;
import model.EmployeeProfile;
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
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        if (!hasRole(request, ROLE_EMPLOYEE) && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang khai báo lịch rảnh!");
            return;
        }

        LocalDate today = LocalDate.now();
        LocalDate nextMonday = today.with(TemporalAdjusters.next(DayOfWeek.MONDAY));
        LocalDate nextSunday = nextMonday.plusDays(6);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        
        request.setAttribute("startDate", nextMonday.format(formatter));
        request.setAttribute("endDate", nextSunday.format(formatter));

        LocalDateTime now = LocalDateTime.now();
        boolean isRegistrationOpen = (now.getDayOfWeek() != DayOfWeek.SUNDAY);
        request.setAttribute("isRegistrationOpen", isRegistrationOpen);

        EmployeeAvailabilityDAO dao = new EmployeeAvailabilityDAO();
        EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();

        // Lấy thông tin profile của nhân viên trước để xác định loại nhân sự
        EmployeeProfile profile = profileDAO.getProfileByUserId(user.getId());
        String employeeType = (profile != null && profile.getEmployeeType() != null) ? profile.getEmployeeType().trim().toUpperCase() : "FULL_TIME";
        String fixedShiftType = (profile != null && profile.getShiftType() != null) ? profile.getShiftType().trim().toUpperCase() : "";

        // Chỉ lấy danh sách ca tương ứng với loại nhân viên (Full-time hoặc Part-time)
        List<Shift> shifts = dao.getShiftsByEmployeeType(employeeType);
        List<EmployeeAvailability> currentAvailabilities = dao.getAvailabilitiesByUserId(user.getId());

        boolean hasRegistered = (currentAvailabilities != null && !currentAvailabilities.isEmpty());
        request.setAttribute("hasRegistered", hasRegistered);

        request.setAttribute("shifts", shifts);
        request.setAttribute("currentAvailabilities", currentAvailabilities);
        request.setAttribute("employeeType", employeeType);
        request.setAttribute("fixedShiftType", fixedShiftType);
        
        request.getRequestDispatcher("/WEB-INF/views/employee/availability.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
        EmployeeProfile profile = profileDAO.getProfileByUserId(user.getId());
        String employeeType = (profile != null && profile.getEmployeeType() != null) ? profile.getEmployeeType().trim().toUpperCase() : "FULL_TIME";

        if ("FULL_TIME".equals(employeeType)) {
            response.sendRedirect("availability?error=unauthorized_action");
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

        // Tăng mức tối thiểu lên 5 ca / tuần cho nhân viên Part-time
        int minShiftsRequired = 5;
        if (newAvailabilities.size() < minShiftsRequired) {
            response.sendRedirect("availability?error=min_shifts&min=" + minShiftsRequired);
            return;
        }

        EmployeeAvailabilityDAO dao = new EmployeeAvailabilityDAO();
        dao.saveAvailabilities(user.getId(), newAvailabilities);

        response.sendRedirect("availability?success=true");
    }
}