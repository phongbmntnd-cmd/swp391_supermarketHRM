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
        // --- XÁC THỰC PHIÊN ĐĂNG NHẬP QUA BASESERVLET ---
        User account = getCurrentUser(request);
        if (account == null) {
            redirectToLogin(request, response);
            return;
        }

        // Kiểm tra phân quyền nhân viên
        if (!hasRole(request, ROLE_EMPLOYEE) && account.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền xem lịch làm việc này!");
            return;
        }

        int userId = account.getId();

        LocalDate today = LocalDate.now();
        LocalDate nextMonday = today.with(TemporalAdjusters.next(DayOfWeek.MONDAY));
        LocalDate nextSunday = nextMonday.plusDays(6);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        request.setAttribute("startDate", nextMonday.format(formatter));
        request.setAttribute("endDate", nextSunday.format(formatter));

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

        // Lấy lịch làm việc CHÍNH THỨC (đã Publish) của nhân viên này trong tuần
        String sqlSchedules = "SELECT ss.shift_id, ss.work_date, b.name AS branch_name, pos.title AS position_title " +
                              "FROM shift_schedules ss " +
                              "JOIN branches b ON ss.branch_id = b.id " +
                              "JOIN employee_profiles ep ON ss.user_id = ep.user_id " +
                              "JOIN positions pos ON ep.position_id = pos.id " +
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
                    String workDate = rs.getString("work_date"); // YYYY-MM-DD
                    
                    // Key định danh cho mỗi ô ca/ngày: shiftId_workDate
                    mySchedules.add(shiftId + "_" + workDate);
                    
                    branchName = rs.getString("branch_name");
                    positionTitle = rs.getString("position_title");
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