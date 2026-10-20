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

        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        DateTimeFormatter isoFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        request.setAttribute("startDate", nextMonday.format(displayFormatter));
        request.setAttribute("endDate", nextSunday.format(displayFormatter));
        request.setAttribute("weekStartDate", nextMonday.format(isoFormatter));

        // Kiểm tra thời gian mở cổng: Chỉ mở từ Thứ Hai đến hết Thứ Tư
        LocalDateTime now = LocalDateTime.now();
        DayOfWeek currentDay = now.getDayOfWeek();
        boolean isRegistrationOpen = (currentDay == DayOfWeek.MONDAY
                || currentDay == DayOfWeek.TUESDAY
                || currentDay == DayOfWeek.WEDNESDAY);
        request.setAttribute("isRegistrationOpen", isRegistrationOpen);

        EmployeeAvailabilityDAO dao = new EmployeeAvailabilityDAO();
        EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();

        EmployeeProfile profile = profileDAO.getProfileByUserId(user.getId());
        String employeeType = (profile != null && profile.getEmployeeType() != null) ? profile.getEmployeeType().trim().toUpperCase() : "FULL_TIME";
        String shiftType = (profile != null && profile.getShiftType() != null) ? profile.getShiftType().trim().toUpperCase() : "";

        List<Shift> shifts = dao.getShiftsByEmployeeType(employeeType);

        // Lấy lịch rảnh theo đúng user và đúng mốc tuần
        List<EmployeeAvailability> currentAvailabilities = dao.getAvailabilitiesByUserIdAndWeek(user.getId(), nextMonday.format(isoFormatter));

        boolean hasRegistered = (currentAvailabilities != null && !currentAvailabilities.isEmpty());
        request.setAttribute("hasRegistered", hasRegistered);

        request.setAttribute("shifts", shifts);
        request.setAttribute("currentAvailabilities", currentAvailabilities);
        request.setAttribute("employeeType", employeeType);
        request.setAttribute("shiftType", shiftType);

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

        // Chặn bảo mật phía server: Nếu quá thời hạn (sau ngày Thứ Tư) mà cố tình gửi request lưu
        LocalDateTime now = LocalDateTime.now();
        DayOfWeek currentDay = now.getDayOfWeek();
        boolean isRegistrationOpen = (currentDay == DayOfWeek.MONDAY
                || currentDay == DayOfWeek.TUESDAY
                || currentDay == DayOfWeek.WEDNESDAY);
        if (!isRegistrationOpen) {
            response.sendRedirect("availability?error=closed");
            return;
        }

        // Lấy mốc tuần từ request form gửi lên
        String weekStartDate = request.getParameter("weekStartDate");
        if (weekStartDate == null || weekStartDate.trim().isEmpty()) {
            LocalDate nextMonday = LocalDate.now().with(TemporalAdjusters.next(DayOfWeek.MONDAY));
            weekStartDate = nextMonday.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }

        EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
        EmployeeProfile profile = profileDAO.getProfileByUserId(user.getId());
        String employeeType = (profile != null && profile.getEmployeeType() != null) ? profile.getEmployeeType().trim().toUpperCase() : "FULL_TIME";
        String shiftType = (profile != null && profile.getShiftType() != null) ? profile.getShiftType().trim().toUpperCase() : "";

        if ("FULL_TIME".equals(employeeType)) {
            response.sendRedirect("availability?error=unauthorized_action");
            return;
        }

        String[] selectedAvailabilities = request.getParameterValues("availabilities");
        List<EmployeeAvailability> newAvailabilities = new ArrayList<>();

        if (selectedAvailabilities != null) {
            EmployeeAvailabilityDAO dao = new EmployeeAvailabilityDAO();
            List<Shift> shifts = dao.getAllShifts();

            for (String item : selectedAvailabilities) {
                String[] parts = item.split("_");
                if (parts.length == 2) {
                    String dayOfWeek = parts[0];
                    int shiftId = Integer.parseInt(parts[1]);

                    String shiftName = "";
                    for (Shift s : shifts) {
                        if (s.getId() == shiftId) {
                            shiftName = s.getName() != null ? s.getName().toLowerCase() : "";
                            break;
                        }
                    }

                    // Chặn bảo mật phân quyền ca cố định
                    if ("PT_FIXED_MORNING".equals(shiftType) && !shiftName.contains("sáng")) {
                        continue;
                    }
                    if ("PT_FIXED_AFTERNOON".equals(shiftType) && !shiftName.contains("chiều")) {
                        continue;
                    }
                    if ("PT_FIXED_EVENING".equals(shiftType) && !shiftName.contains("tối")) {
                        continue;
                    }

                    newAvailabilities.add(new EmployeeAvailability(0, user.getId(), dayOfWeek, weekStartDate, shiftId));
                }
            }
        }

        // Kiểm tra định mức tối thiểu 5 ca / tuần cho Part-time
        int minShiftsRequired = 5;
        if (newAvailabilities.size() < minShiftsRequired) {
            response.sendRedirect("availability?error=min_shifts&min=" + minShiftsRequired);
            return;
        }

        EmployeeAvailabilityDAO dao = new EmployeeAvailabilityDAO();
        dao.saveAvailabilities(user.getId(), weekStartDate, newAvailabilities);

        response.sendRedirect("availability?success=true");
    }
}
