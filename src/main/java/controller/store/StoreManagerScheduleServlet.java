package controller.store;

import controller.base.BaseServlet;
import dao.EmployeeAvailabilityDAO;
import dao.ShiftScheduleDAO;
import dao.SupplementaryShiftDAO;
import dao.TemporaryTransferDAO;
import model.Shift;
import model.TemporaryTransfer;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet(name = "StoreManagerScheduleServlet", urlPatterns = {"/store-manager/schedule"})
public class StoreManagerScheduleServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        if (!isStoreManager(request) && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang quản lý lịch trực!");
            return;
        }

        int managerBranchId = getCurrentBranchId(request);
        if (managerBranchId == -1) {
            sendForbidden(request, response, "Không xác định được cơ sở.");
            return;
        }

        // Nhận tham số startDate từ request để hỗ trợ xem lại các tuần cũ hoặc tuần khác
        String startDateParam = request.getParameter("startDate");
        LocalDate nextMonday;
        try {
            if (startDateParam != null && !startDateParam.trim().isEmpty()) {
                nextMonday = LocalDate.parse(startDateParam);
            } else {
                LocalDate today = LocalDate.now();
                nextMonday = today.with(TemporalAdjusters.next(DayOfWeek.MONDAY));
            }
        } catch (Exception e) {
            nextMonday = LocalDate.now().with(TemporalAdjusters.next(DayOfWeek.MONDAY));
        }

        LocalDate nextSunday = nextMonday.plusDays(6);

        // Tính toán mốc tuần trước và tuần sau để phục vụ nút điều hướng trên giao diện
        LocalDate prevMonday = nextMonday.minusWeeks(1);
        LocalDate followingMonday = nextMonday.plusWeeks(1);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        request.setAttribute("startDate", nextMonday.format(formatter));
        request.setAttribute("endDate", nextSunday.format(formatter));
        request.setAttribute("startDateRaw", nextMonday.toString());
        request.setAttribute("prevWeekDate", prevMonday.toString());
        request.setAttribute("nextWeekDate", followingMonday.toString());

        EmployeeAvailabilityDAO availabilityDAO = new EmployeeAvailabilityDAO();
        ShiftScheduleDAO scheduleDAO = new ShiftScheduleDAO();
        SupplementaryShiftDAO suppDAO = new SupplementaryShiftDAO();
        TemporaryTransferDAO transferDAO = new TemporaryTransferDAO();

        // Lấy danh sách cơ sở khác để phục vụ cho tính năng mượn nhân sự
        dao.BranchDAO branchDAO = new dao.BranchDAO();
        List<model.Branch> otherBranches = branchDAO.getOtherBranches(managerBranchId);
        request.setAttribute("allBranches", otherBranches);

        List<Shift> shifts = availabilityDAO.getAllShifts();
        List<Map<String, Object>> branchRegistrations = availabilityDAO.getRegistrationsByBranchId(managerBranchId);
        List<Map<String, Object>> supplementaryApplicants = suppDAO
                .getApplicants(managerBranchId, nextMonday.toString(), nextSunday.toString());
        for (Map<String, Object> applicant : supplementaryApplicants) {
            boolean alreadyListed = false;
            for (Map<String, Object> registration : branchRegistrations) {
                if (registration.get("userId").equals(applicant.get("userId"))
                        && registration.get("dayOfWeek").equals(applicant.get("dayOfWeek"))
                        && registration.get("shiftName").equals(applicant.get("shiftName"))) {
                    alreadyListed = true;
                    break;
                }
            }
            if (!alreadyListed) {
                Map<String, Object> registration = new HashMap<>(applicant);
                registration.put("registrationType", "SUPPLEMENTARY");
                branchRegistrations.add(registration);
            }
        }

        // Lấy danh sách nhân viên Full-time cố định của chi nhánh
        List<Map<String, Object>> fullTimeEmployees = scheduleDAO.getFullTimeEmployeesByBranch(managerBranchId);

        List<String> assignedList = scheduleDAO.getAssignedKeysByBranchId(managerBranchId);

        // Kiểm tra xem lịch trong tuần này của chi nhánh đã được publish chưa
        boolean isPublished = scheduleDAO.isWeekPublished(managerBranchId, nextMonday.toString(), nextSunday.toString());
        request.setAttribute("isPublished", isPublished);

        String sqlPos = "SELECT id, title FROM positions "
                + "WHERE title NOT LIKE '%Quản Lý%' "
                + "AND title NOT LIKE '%Giám Đốc%' "
                + "AND title NOT LIKE '%Trị Hệ Thống%'";
        List<Map<String, Object>> positions = new ArrayList<>();
        try (Connection conn = context.DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sqlPos); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> p = new HashMap<>();
                p.put("id", rs.getInt("id"));
                p.put("title", rs.getString("title"));
                positions.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        String[] days = {"MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"};
        String[] dayNames = {"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"};

        Map<String, String> dayDateMap = new HashMap<>();
        for (int i = 0; i < days.length; i++) {
            LocalDate d = nextMonday.plusDays(i);
            dayDateMap.put(days[i], d.toString());
        }

        // Lấy định mức yêu cầu và số lượng thực tế đã xếp trong tuần theo từng ngày, vị trí, ca
        Map<String, Map<String, Object>> weeklyRequirements = scheduleDAO.getWeeklyRequirementsMap(managerBranchId, nextMonday.toString(), nextSunday.toString());
        Map<String, Integer> weeklyAssignedCounts = scheduleDAO.getWeeklyAssignedCountMap(managerBranchId, nextMonday.toString(), nextSunday.toString());

        // Lấy danh sách các đề xuất điều chuyển của chi nhánh (vai trò là cơ sở đích - mượn người) để mapping
        List<TemporaryTransfer> myOutgoingTransfers = transferDAO.getTransfersByStore(managerBranchId, false);
        Set<String> proposedKeys = new HashSet<>();
        for (TemporaryTransfer tr : myOutgoingTransfers) {
            if (tr.getWorkDate() != null && ("PENDING_MANAGER".equals(tr.getStatus()) || "PENDING_HR".equals(tr.getStatus()) || "APPROVED".equals(tr.getStatus()))) {
                String key = tr.getWorkDate().toString() + "_" + tr.getPositionId() + "_" + tr.getShiftId();
                proposedKeys.add(key);
            }
        }

        // Tạo Map kiểm tra trạng thái Đã mở đăng ký bổ sung hoặc Đã tạo đề xuất điều chuyển cho từng ô ca trong tuần
        Map<String, Boolean> supplementaryOpenedMap = new HashMap<>();
        Map<String, Boolean> transferProposedMap = new HashMap<>();

        for (Map.Entry<String, String> entry : dayDateMap.entrySet()) {
            String workDate = entry.getValue();
            for (Map<String, Object> pos : positions) {
                int positionId = (int) pos.get("id");
                for (Shift shift : shifts) {
                    int shiftId = shift.getId();
                    String reqKey = workDate + "_" + positionId + "_" + shiftId;

                    // Kiểm tra xem ca này đã mở đăng ký bổ sung hay chưa
                    boolean isSuppOpen = suppDAO.isSupplementaryOpened(managerBranchId, positionId, shiftId, workDate);
                    supplementaryOpenedMap.put(reqKey, isSuppOpen);

                    // Kiểm tra xem ca này đã có trong danh sách đề xuất điều chuyển hay chưa
                    transferProposedMap.put(reqKey, proposedKeys.contains(reqKey));
                }
            }
        }

        request.setAttribute("days", days);
        request.setAttribute("dayNames", dayNames);
        request.setAttribute("dayDateMap", dayDateMap);
        request.setAttribute("shifts", shifts);
        request.setAttribute("positions", positions);
        request.setAttribute("branchRegistrations", branchRegistrations);
        request.setAttribute("fullTimeEmployees", fullTimeEmployees);
        request.setAttribute("assignedList", assignedList);
        request.setAttribute("managerBranchId", managerBranchId);
        request.setAttribute("weeklyRequirements", weeklyRequirements);
        request.setAttribute("weeklyAssignedCounts", weeklyAssignedCounts);
        request.setAttribute("supplementaryOpenedMap", supplementaryOpenedMap);
        request.setAttribute("transferProposedMap", transferProposedMap);
        request.setAttribute("borrowedAssignments", scheduleDAO.getBorrowedAssignments(managerBranchId, nextMonday.toString(), nextSunday.toString()));

        request.getRequestDispatcher("/WEB-INF/views/store-manager/schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null || (!isStoreManager(request) && user.getRoleId() != ROLE_ADMIN)) {
            redirectToLogin(request, response);
            return;
        }

        String action = getStringParameter(request, "action");
        String startDate = getStringParameter(request, "startDate"); // Mốc ngày bắt đầu tuần (Thứ Hai)
        int branchId = getIntParameter(request, "branchId", -1);
        int currentBranch = getCurrentBranchId(request);
        if(currentBranch <= 0 || branchId != currentBranch) {
            sendForbidden(request, response, "Không có quyền sửa lịch cơ sở này");
            return;
        }

        ShiftScheduleDAO scheduleDAO = new ShiftScheduleDAO();

        // Check publish based on actual workDate, never depend on an optional startDate parameter.
        if("assign".equals(action) || "updateRequirement".equals(action)){
            try{
                LocalDate d = LocalDate.parse(getStringParameter(request,"workDate"));
                LocalDate monday = d.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
                if(scheduleDAO.isWeekPublished(branchId, monday.toString(), monday.plusDays(6).toString())){
                    response.getWriter().write("published_locked");
                    return;
                }
            } catch(Exception e){
                response.sendError(400, "Ngày không hợp lệ");
                return;
            }
        }

        if ("assign".equals(action)) {
            int userId = getIntParameter(request, "userId", -1);
            int positionId = getIntParameter(request, "positionId", -1);
            int shiftId = getIntParameter(request, "shiftId", -1);
            String workDate = getStringParameter(request, "workDate");
            if (userId != -1 && shiftId != -1 && positionId > 0 && branchId != -1 && workDate != null) {
                // Ca đang ON_LEAVE (nhân viên đã nghỉ phép được duyệt):
                // không được xoá, không được xếp thêm -> báo riêng cho SM.
                if (scheduleDAO.checkOnLeaveSchedule(branchId, userId, shiftId, workDate)
                        || scheduleDAO.isOnApprovedLeave(userId, workDate)) {
                    response.getWriter().write("on_leave");
                    return;
                }
                boolean exists = scheduleDAO.checkScheduleExists(branchId, userId, shiftId, workDate);
                if (exists) {
                    if(scheduleDAO.isLockedForTransfer(branchId, userId, shiftId, workDate)){
                        response.getWriter().write("transfer_locked");
                        return;
                    }
                    scheduleDAO.deleteSchedule(branchId, userId, shiftId, workDate);
                    response.getWriter().write("removed");
                } else {
                    if(!scheduleDAO.canAssign(branchId, userId, positionId, shiftId, workDate)){
                        response.getWriter().write("assignment_invalid");
                        return;
                    }
                    scheduleDAO.insertSchedule(branchId, userId, shiftId, workDate, positionId);
                    response.getWriter().write("added");
                }
            }

        } else if ("updateRequirement".equals(action)) {
            int positionId = getIntParameter(request, "positionId", -1);
            int shiftId = getIntParameter(request, "shiftId", -1);
            String workDate = getStringParameter(request, "workDate");
            int requiredCount = getIntParameter(request, "requiredCount", 1);
            if (requiredCount < 1) {
                requiredCount = 1;
            }

            if (branchId != -1 && positionId != -1 && shiftId != -1 && workDate != null) {
                scheduleDAO.updateShiftRequirementByDate(branchId, positionId, shiftId, workDate, requiredCount);
                response.getWriter().write("success");
            }

        } else if ("publish".equals(action)) {
            if (branchId != -1) {
//<<<<<<< HEAD
                if(startDate == null){response.sendError(400, "Thiếu tuần cần Publish");return;}
                LocalDate monday = LocalDate.parse(startDate);
                scheduleDAO.publishSchedules(branchId, monday.toString(), monday.plusDays(6).toString());
                new SupplementaryShiftDAO().closeRegistrationsForWeek(branchId, monday.toString(), monday.plusDays(6).toString());
////=======
//                if(startDate == null){response.sendError(400,"Thiếu tuần cần Publish");return;}
//                LocalDate monday=LocalDate.parse(startDate);
//                scheduleDAO.publishSchedules(branchId,monday.toString(),monday.plusDays(6).toString());
//
//                // Khớp lại các đơn nghỉ phép đã duyệt với lịch vừa
//                // publish: đánh dấu ON_LEAVE + đưa ca vào open_shifts.
//                // Nhờ vậy part-time xin nghỉ trước khi lịch được publish
//                // vẫn có hiệu lực đầy đủ.
//                try {
//                    new dao.LeaveRequestDAO().reconcileApprovedLeaves(
//                            branchId,
//                            java.sql.Date.valueOf(monday),
//                            java.sql.Date.valueOf(monday.plusDays(6)));
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//>>>>>>> origin/TienDat
            }
            String redirectUrl = "schedule?success=published";
            if (startDate != null && !startDate.trim().isEmpty()) {
                redirectUrl += "&startDate=" + startDate;
            }
            response.sendRedirect(redirectUrl);
        } else if ("openSupplementaryRegistration".equals(action)) {
            int positionId = getIntParameter(request, "positionId", -1);
            int shiftId = getIntParameter(request, "shiftId", -1);
            String workDate = getStringParameter(request, "workDate");
            String deadlineValue = getStringParameter(request, "registrationDeadline");
            boolean opened = false;
            try {
                if (positionId > 0 && shiftId > 0 && workDate != null && deadlineValue != null) {
                    LocalDate selectedDate = LocalDate.parse(workDate);
                    LocalDate selectedWeek = LocalDate.parse(startDate);
                    if (selectedWeek.getDayOfWeek() != DayOfWeek.MONDAY
                            || selectedDate.isBefore(selectedWeek)
                            || selectedDate.isAfter(selectedWeek.plusDays(6))) {
                        throw new IllegalArgumentException("Ngày đăng ký không thuộc tuần đang xem");
                    }
                    LocalDateTime deadline = LocalDateTime.parse(deadlineValue);
                    opened = new SupplementaryShiftDAO().openRegistration(
                            branchId, positionId, shiftId, workDate, Timestamp.valueOf(deadline), user.getId());
                }
            } catch (Exception e) {
                opened = false;
            }
            String redirectUrl = "schedule?" + (opened ? "success=supplementary_opened" : "error=supplementary_open_failed");
            if (startDate != null && !startDate.trim().isEmpty()) {
                redirectUrl += "&startDate=" + startDate;
            }
            response.sendRedirect(redirectUrl);
        }
    }
}