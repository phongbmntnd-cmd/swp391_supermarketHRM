package controller.employee;

import controller.base.BaseServlet;
import dao.EmployeeAvailabilityDAO;
import dao.EmployeeProfileDAO;
import dao.ShiftScheduleDAO;
import dao.SupplementaryShiftDAO;
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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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

        // TUẦN ĐANG XEM = TUẦN HIỆN TẠI (thứ Hai của tuần đang chạy).
        //
        // Trước đây dùng TemporalAdjusters.next(MONDAY) -> hàm này
        // LOẠI TRỪ chính ngày hôm nay, nên vào Thứ Hai nó nhảy sang
        // tuần kế tiếp. Hôm 16/11 (Thứ Hai) form hiện tuần
        // 23/11-29/11, trong khi hôm trước (15/11 - Chủ Nhật) lại
        // hiện tuần 16/11-22/11 -> cùng một ngày hôm nay nhưng mốc
        // tuần nhảy lung tung, nhân viên tưởng hệ thống lỗi.
        //
        // Quan trọng hơn: quy tắc nghiệp vụ của hệ thống là tuần làm
        // việc = tuần chứa ngày làm việc (previousOrSame), đúng như
        // ShiftScheduleDAO.hasRegisteredAvailability dùng để tra cứu
        // lịch rảnh. Trước đây màn này lưu theo tuần kế tiếp trong
        // khi Store Manager tra cứu theo tuần hiện tại -> KHÔNG BAO
        // GIỜ nào xếp được ca cho nhân viên đã đăng ký rảnh.
        LocalDate currentMonday = util.WeekUtil.currentMonday();

        // Cho phép xem lại tuần trước / tuần sau (chỉ xem).
        LocalDate viewingMonday = util.WeekUtil.resolveWeekStart(
                request.getParameter("startDate"), currentMonday);

        // Chỉ được ĐĂNG KÝ / SỬA lịch rảnh của tuần hiện tại.
        // Tuần khác chỉ xem lại, không lưu được.
        boolean isCurrentWeek = viewingMonday.equals(currentMonday);

        LocalDate viewingSunday = viewingMonday.plusDays(6);

        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        DateTimeFormatter isoFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        request.setAttribute("startDate", viewingMonday.format(displayFormatter));
        request.setAttribute("endDate", viewingSunday.format(displayFormatter));
        request.setAttribute("weekStartDate", viewingMonday.format(isoFormatter));
        request.setAttribute("prevWeekDate", currentMonday.minusWeeks(1).toString());
        request.setAttribute("nextWeekDate", currentMonday.plusWeeks(1).toString());
        request.setAttribute("isCurrentWeek", isCurrentWeek);

        // Kiểm tra thời gian mở cổng: Chỉ mở từ Thứ Hai đến hết Thứ Tư
        boolean isRegistrationOpen = util.WeekUtil.isRegistrationWindowOpen(
                LocalDate.now());
        request.setAttribute("isRegistrationOpen", isRegistrationOpen);

        EmployeeAvailabilityDAO dao = new EmployeeAvailabilityDAO();
        EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();

        EmployeeProfile profile = profileDAO.getProfileByUserId(user.getId());
        String employeeType = (profile != null && profile.getEmployeeType() != null) ? profile.getEmployeeType().trim().toUpperCase() : "FULL_TIME";
        String shiftType = (profile != null && profile.getShiftType() != null) ? profile.getShiftType().trim().toUpperCase() : "";

        if (profile != null && !"FULL_TIME".equals(employeeType)) {
            request.setAttribute("supplementaryRegistrations",
                new SupplementaryShiftDAO().getOpenRegistrationsForEmployee(
                    user.getId(), profile.getHomeBranchId(), profile.getPositionId()));
        }

        List<Shift> shifts = dao.getShiftsByEmployeeType(employeeType);

        // Lấy lịch rảnh theo đúng user và đúng mốc tuần ĐANG XEM
        List<EmployeeAvailability> currentAvailabilities = dao.getAvailabilitiesByUserIdAndWeek(user.getId(), viewingMonday.format(isoFormatter));

        // Đưa danh sách vào Set định dạng "DAY_shiftId" để JSP kiểm tra nhanh và sạch sẽ
        Set<String> registeredKeySet = new HashSet<>();
        if (currentAvailabilities != null) {
            for (EmployeeAvailability av : currentAvailabilities) {
                registeredKeySet.add(av.getDayOfWeek() + "_" + av.getShiftId());
            }
        }

        boolean hasRegistered = (currentAvailabilities != null && !currentAvailabilities.isEmpty());
        request.setAttribute("hasRegistered", hasRegistered);

        // LỊCH RẢNH CỦA TUẦN ĐÃ BỊ KHOÁ khi Store Manager đã PUBLISH
        // tuần đó (lịch đã chốt). Từ thời điểm đó nhân viên không
        // được đăng ký / sửa lịch rảnh của tuần đó nữa.
        //
        // Chỉ khi Store bấm "Publish" mới khoá - trước đó (kể cả khi
        // Store đã xếp ca dạng nháp DRAFT) nhân viên vẫn đăng ký và
        // sửa lịch rảnh bình thường.
        int homeBranchId = (profile != null) ? profile.getHomeBranchId() : -1;
        boolean isWeekLocked = new ShiftScheduleDAO()
                .isWeekPublished(homeBranchId,
                        viewingMonday.format(isoFormatter));
        request.setAttribute("isWeekLocked", isWeekLocked);

        request.setAttribute("shifts", shifts);
        request.setAttribute("registeredKeySet", registeredKeySet);
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

        if (!hasRole(request, ROLE_EMPLOYEE)) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        if ("applySupplementary".equals(getStringParameter(request, "action"))) {
            int registrationId = getIntParameter(request, "registrationId", -1);
            boolean applied = registrationId > 0 && new SupplementaryShiftDAO().apply(registrationId, user.getId());
            response.sendRedirect(request.getContextPath() + "/employee/availability?"
                    + (applied ? "success=supplementary" : "error=supplementary"));
            return;
        }

        // Cổng đăng ký chỉ mở Thứ Hai -> hết Thứ Tư.
        boolean isRegistrationOpen = util.WeekUtil.isRegistrationWindowOpen(
                LocalDate.now());
        if (!isRegistrationOpen) {
            response.sendRedirect("availability?error=closed");
            return;
        }

        // Chỉ được ghi lịch rảnh vào TUẦN HIỆN TẠI.
        // Tuần khác (tuần trước / tuần sau) chỉ để xem lại.
        LocalDate currentMonday = util.WeekUtil.currentMonday();

        String requestedWeek = request.getParameter("weekStartDate");
        LocalDate requestedMonday = util.WeekUtil.resolveWeekStart(
                requestedWeek, currentMonday);

        if (!requestedMonday.equals(currentMonday)) {
            response.sendRedirect("availability?error=invalid_week");
            return;
        }

        String weekStartDate = currentMonday
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

        EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
        EmployeeProfile profile = profileDAO.getProfileByUserId(user.getId());
        String employeeType = (profile != null && profile.getEmployeeType() != null) ? profile.getEmployeeType().trim().toUpperCase() : "FULL_TIME";
        String shiftType = (profile != null && profile.getShiftType() != null) ? profile.getShiftType().trim().toUpperCase() : "";

        if ("FULL_TIME".equals(employeeType)) {
            response.sendRedirect("availability?error=unauthorized_action");
            return;
        }

        // LỊCH RẢNH ĐÃ BỊ KHOÁ: Store Manager đã publish tuần này ->
        // lịch đã chốt, nhân viên không được sửa nữa.
        // (Trước khi publish thì đăng ký / sửa bình thường.)
        int homeBranchId = (profile != null) ? profile.getHomeBranchId() : -1;
        if (new ShiftScheduleDAO()
                .isWeekPublished(homeBranchId, weekStartDate)) {
            response.sendRedirect("availability?error=week_locked");
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

                    // Chỉ chặn nếu nhân viên thật sự có nhóm ca cố định.
                    // NV linh hoạt (PT_FLEXIBLE, PT_SEASONAL_WEEKEND,
                    // Sang/Toi, ...) được đăng ký mọi ca.
                    if (!util.ShiftTypeUtil.isAllowedFixedShift(
                            shiftType, shiftName)) {
                        continue;
                    }

                    newAvailabilities.add(new EmployeeAvailability(0, user.getId(), dayOfWeek, weekStartDate, shiftId));
                }
            }
        }

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