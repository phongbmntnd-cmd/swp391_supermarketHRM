package controller.store;

import controller.base.BaseServlet;
import dao.EmployeeAvailabilityDAO;
import dao.ShiftScheduleDAO;
import model.Shift;
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

@WebServlet(name = "StoreManagerScheduleServlet", urlPatterns = {"/store-manager/schedule"})
public class StoreManagerScheduleServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // --- BƯỚC 1: XÁC THỰC PHIÊN ĐĂNG NHẬP THÔNG QUA BASESERVLET ---
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        // --- BƯỚC 2: KIỂM TRA PHÂN QUYỀN (CHỈ STORE_MANAGER HOẶC ADMIN) ---
        if (!isStoreManager(request) && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang quản lý lịch trực!");
            return;
        }

        // --- BƯỚC 3: XÁC ĐỊNH CHI NHÁNH CỦA QUẢN LÝ ---
        int managerBranchId = getCurrentBranchId(request);
        if (managerBranchId == -1) {
            managerBranchId = 1; // Mặc định nếu chưa gán cơ sở
        }

        // --- BƯỚC 4: TÍNH TOÁN THỜI GIAN TUẦN TỚI ---
        LocalDate today = LocalDate.now();
        LocalDate nextMonday = today.with(TemporalAdjusters.next(DayOfWeek.MONDAY));
        LocalDate nextSunday = nextMonday.plusDays(6);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        request.setAttribute("startDate", nextMonday.format(formatter));
        request.setAttribute("endDate", nextSunday.format(formatter));

        // --- BƯỚC 5: GỌI DAO ĐỂ LẤY DỮ LIỆU THÔ ---
        EmployeeAvailabilityDAO availabilityDAO = new EmployeeAvailabilityDAO();
        ShiftScheduleDAO scheduleDAO = new ShiftScheduleDAO();

        List<Shift> shifts = availabilityDAO.getAllShifts();
        List<Map<String, Object>> branchRegistrations = availabilityDAO.getRegistrationsByBranchId(managerBranchId);
        List<String> assignedList = scheduleDAO.getAssignedKeysByBranchId(managerBranchId);

        // --- BƯỚC 6: LỌC DANH SÁCH VỊ TRÍ (LOẠI BỎ CẤP QUẢN LÝ) ---
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

        // --- BƯỚC 7: ÁNH XẠ NGÀY THÁNG CHO TỪNG THỨ TRONG TUẦN ---
        String[] days = {"MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"};
        String[] dayNames = {"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"};

        Map<String, String> dayDateMap = new HashMap<>();
        for (int i = 0; i < days.length; i++) {
            LocalDate d = nextMonday.plusDays(i);
            dayDateMap.put(days[i], d.toString());
        }

        // --- BƯỚC 8: TRUYỀN DỮ LIỆU RA GIAO DIỆN JSP ---
        request.setAttribute("days", days);
        request.setAttribute("dayNames", dayNames);
        request.setAttribute("dayDateMap", dayDateMap);
        request.setAttribute("shifts", shifts);
        request.setAttribute("positions", positions);
        request.setAttribute("branchRegistrations", branchRegistrations);
        request.setAttribute("assignedList", assignedList);
        request.setAttribute("managerBranchId", managerBranchId);

        request.getRequestDispatcher("/WEB-INF/views/store-manager/schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // --- XÁC THỰC QUYỀN CHO YÊU CẦU POST ---
        User user = getCurrentUser(request);
        if (user == null || (!isStoreManager(request) && user.getRoleId() != ROLE_ADMIN)) {
            redirectToLogin(request, response);
            return;
        }

        String action = getStringParameter(request, "action");
        ShiftScheduleDAO scheduleDAO = new ShiftScheduleDAO();

        if ("assign".equals(action)) {
            // --- XỬ LÝ AJAX KHI QUẢN LÝ TÍCH CHỌN HOẶC HỦY CHỌN CA ---
            int userId = getIntParameter(request, "userId", -1);
            int shiftId = getIntParameter(request, "shiftId", -1);
            int branchId = getIntParameter(request, "branchId", -1);
            String workDate = getStringParameter(request, "workDate");

            if (userId != -1 && shiftId != -1 && branchId != -1 && workDate != null) {
                boolean exists = scheduleDAO.checkScheduleExists(branchId, userId, shiftId, workDate);
                if (exists) {
                    // Nếu đã tồn tại -> Xóa (Hủy chọn)
                    scheduleDAO.deleteSchedule(branchId, userId, shiftId, workDate);
                    response.getWriter().write("removed");
                } else {
                    // Nếu chưa tồn tại -> Thêm mới (Chọn)
                    scheduleDAO.insertSchedule(branchId, userId, shiftId, workDate);
                    response.getWriter().write("added");
                }
            }

        } else if ("publish".equals(action)) {
            // --- XỬ LÝ NÚT PUBLISH: CHUYỂN TRẠNG THÁI LỊCH NHÁP SANG CHÍNH THỨC ---
            int branchId = getIntParameter(request, "branchId", -1);
            if (branchId != -1) {
                scheduleDAO.publishSchedules(branchId);
            }
            response.sendRedirect("schedule?success=published");
        }
    }
}