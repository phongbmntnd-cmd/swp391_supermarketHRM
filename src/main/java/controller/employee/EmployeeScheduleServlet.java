package controller.employee;

import context.DBContext;
import controller.base.BaseServlet;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "EmployeeScheduleServlet", urlPatterns = {"/employee/my-schedule"})
public class EmployeeScheduleServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = getCurrentUser(request);
        if (account == null) {
            redirectToLogin(request, response);
            return;
        }

        if (!hasRole(request, ROLE_EMPLOYEE) && account.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền xem lịch làm việc này!");
            return;
        }

        int userId = account.getId();

        // Giữ nguyên chức năng chọn và chuyển tuần.
        String startDateParam = request.getParameter("startDate");
        LocalDate nextMonday;
        try {
            if (startDateParam != null && !startDateParam.trim().isEmpty()) {
                nextMonday = LocalDate.parse(startDateParam)
                        .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            } else {
                nextMonday = LocalDate.now().with(TemporalAdjusters.next(DayOfWeek.MONDAY));
            }
        } catch (Exception e) {
            nextMonday = LocalDate.now().with(TemporalAdjusters.next(DayOfWeek.MONDAY));
        }

        LocalDate nextSunday = nextMonday.plusDays(6);
        LocalDate prevMonday = nextMonday.minusWeeks(1);
        LocalDate followingMonday = nextMonday.plusWeeks(1);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        request.setAttribute("startDate", nextMonday.format(formatter));
        request.setAttribute("endDate", nextSunday.format(formatter));
        request.setAttribute("prevWeekDate", prevMonday.toString());
        request.setAttribute("nextWeekDate", followingMonday.toString());

        List<Map<String, Object>> shifts = new ArrayList<>();
        String sqlShifts = "SELECT id, name, start_time, end_time FROM shifts ORDER BY start_time";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sqlShifts); ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> s = new HashMap<>();
                s.put("id", rs.getInt("id"));
                s.put("name", rs.getString("name"));
                s.put("startTime", rs.getTime("start_time"));
                s.put("endTime", rs.getTime("end_time"));
                shifts.add(s);
            }
        } catch (Exception e) {
            throw new ServletException("Không thể lấy danh sách ca làm việc", e);
        }
        // Lấy tất cả ca đã Published của nhân viên, kể cả ca ở cơ sở mượn.
        // Chỉ đưa tên cơ sở vào map khi ca có temporary_transfer_id.
        String sqlSchedules
                = "SELECT ss.shift_id, ss.work_date, ss.temporary_transfer_id, "
                + "b.name AS working_branch_name "
                + "FROM shift_schedules ss "
                + "JOIN branches b ON b.id = ss.branch_id "
                + "WHERE ss.user_id = ? AND ss.status = 'PUBLISHED' "
                + "AND ss.work_date BETWEEN ? AND ? "
                + "ORDER BY ss.work_date, ss.shift_id";

        List<String> mySchedules = new ArrayList<>();
        Map<String, String> transferredBranches = new HashMap<>();
        String branchName = "Chưa cập nhật";
        String positionTitle = "Chưa cập nhật";

        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sqlSchedules)) {
            st.setInt(1, userId);
            st.setDate(2, Date.valueOf(nextMonday));
            st.setDate(3, Date.valueOf(nextSunday));

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    int shiftId = rs.getInt("shift_id");
                    String workDate = rs.getDate("work_date").toString();
                    String currentKey = shiftId + "_" + workDate;

                    if (!mySchedules.contains(currentKey)) {
                        mySchedules.add(currentKey);
                    }
                    int transferId = rs.getInt("temporary_transfer_id");
                    if (!rs.wasNull()) {
                        transferredBranches.put(currentKey, rs.getString("working_branch_name"));
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException("Không thể lấy lịch đã công bố", e);
        }

        // Lấy cơ sở chính độc lập với lịch điều chuyển.
        String sqlProfile
                = "SELECT pos.title, b.name AS home_branch_name "
                + "FROM employee_profiles ep "
                + "LEFT JOIN positions pos ON pos.id = ep.position_id "
                + "JOIN branches b ON b.id = ep.home_branch_id "
                + "WHERE ep.user_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement st = conn.prepareStatement(sqlProfile)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    positionTitle = rs.getString("title") != null ? rs.getString("title") : "Chưa cập nhật";
                    branchName = rs.getString("home_branch_name");
                }
            }
        } catch (Exception e) {
            throw new ServletException("Không thể lấy thông tin cơ sở chính", e);
        }

        String[] days = {"MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"};
        String[] dayNames = {"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"};
        Map<String, String> dayDateMap = new HashMap<>();
        for (int i = 0; i < days.length; i++) {
            dayDateMap.put(days[i], nextMonday.plusDays(i).toString());
        }

        request.setAttribute("days", days);
        request.setAttribute("dayNames", dayNames);
        request.setAttribute("dayDateMap", dayDateMap);
        request.setAttribute("shifts", shifts);
        request.setAttribute("mySchedules", mySchedules);
        request.setAttribute("branchName", branchName);
        request.setAttribute("positionTitle", positionTitle);
        request.setAttribute("transferredBranches", transferredBranches);

        request.getRequestDispatcher("/WEB-INF/views/employee/my-schedule.jsp")
                .forward(request, response);
    }
}