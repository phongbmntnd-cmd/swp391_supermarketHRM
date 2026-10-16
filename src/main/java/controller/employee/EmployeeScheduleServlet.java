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

@WebServlet(name = "EmployeeScheduleServlet", urlPatterns = {"/employee/schedule"})
public class EmployeeScheduleServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        // Nhận tham số startDate từ request để đồng bộ tuần với bên Store Manager hoặc khi nhân viên đổi tuần xem
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
        
        // Tính toán tuần trước và tuần sau phục vụ nút điều hướng
        LocalDate prevMonday = nextMonday.minusWeeks(1);
        LocalDate followingMonday = nextMonday.plusWeeks(1);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        request.setAttribute("startDate", nextMonday.format(formatter));
        request.setAttribute("endDate", nextSunday.format(formatter));
        request.setAttribute("prevWeekDate", prevMonday.toString());
        request.setAttribute("nextWeekDate", followingMonday.toString());

        // Lấy danh sách ca làm việc từ bảng shifts
        List<Map<String, Object>> shifts = new ArrayList<>();
        String sqlShifts = "SELECT id, name, start_time, end_time FROM shifts";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement st = conn.prepareStatement(sqlShifts);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> s = new HashMap<>();
                s.put("id", rs.getInt("id"));
                s.put("name", rs.getString("name"));
                s.put("startTime", rs.getTime("start_time"));
                s.put("endTime", rs.getTime("end_time"));
                shifts.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Lấy lịch làm việc CHÍNH THỨC (đã Publish) của nhân viên này trong tuần tương ứng
        String sqlSchedules = "SELECT ss.shift_id, ss.work_date, b.name AS branch_name " +
                            "FROM shift_schedules ss " +
                            "JOIN branches b ON ss.branch_id = b.id " +
                            "WHERE ss.user_id = ? AND ss.status = 'Published' AND ss.work_date BETWEEN ? AND ?";
        
        List<String> mySchedules = new ArrayList<>();
        String branchName = "Chưa cập nhật";
        String positionTitle = "Chưa cập nhật";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement st = conn.prepareStatement(sqlSchedules)) {
            st.setInt(1, userId);
            st.setDate(2, Date.valueOf(nextMonday));
            st.setDate(3, Date.valueOf(nextSunday));
            
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    int shiftId = rs.getInt("shift_id");
                    String workDate = rs.getString("work_date");
                    
                    mySchedules.add(shiftId + "_" + workDate);
                    branchName = rs.getString("branch_name");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Lấy thông tin vị trí của nhân viên từ bảng employee_profiles
        String sqlProfile = "SELECT pos.title FROM employee_profiles ep JOIN positions pos ON ep.position_id = pos.id WHERE ep.user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement st = conn.prepareStatement(sqlProfile)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    positionTitle = rs.getString("title");
                }
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

        request.setAttribute("days", days);
        request.setAttribute("dayNames", dayNames);
        request.setAttribute("dayDateMap", dayDateMap);
        request.setAttribute("shifts", shifts);
        request.setAttribute("mySchedules", mySchedules);
        request.setAttribute("branchName", branchName);
        request.setAttribute("positionTitle", positionTitle);

        request.getRequestDispatcher("/WEB-INF/views/employee/my-schedule.jsp").forward(request, response);
    }
}