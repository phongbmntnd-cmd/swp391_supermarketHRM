package controller.store;

import controller.base.BaseServlet;
import dao.AttendanceDAO;
import model.Attendance;
import model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Trang chấm công của Store Manager.
 *
 * <h3>Phạm vi dữ liệu</h3>
 * Chỉ hiển thị bản ghi chấm công của nhân viên thuộc chi nhánh của
 * Store Manager đang đăng nhập (Admin được xem tất cả).
 *
 * <h3>Bộ lọc</h3>
 * <ul>
 *   <li>{@code from} / {@code to} - khoảng ngày (mặc định: 30 ngày gần nhất).</li>
 *   <li>{@code status} - lọc theo trạng thái bản ghi.</li>
 * </ul>
 */
@WebServlet(name = "StoreManagerAttendanceServlet",
        urlPatterns = {"/store-manager/attendance"})
public class StoreManagerAttendanceServlet extends BaseServlet {

    /** Số ngày mặc định hiển thị khi không có bộ lọc. */
    private static final int DEFAULT_RANGE_DAYS = 30;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        // 2. Kiểm tra phân quyền: Store Manager hoặc Admin
        if (currentUser.getRoleId() != ROLE_STORE_MANAGER
                && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response,
                    "Bạn không có quyền truy cập trang Chấm công cửa hàng!");
            return;
        }

        // 3. Xác định chi nhánh
        //    - Admin: xem tất cả (branchId = -1 => không lọc chi nhánh)
        //    - Store Manager: chỉ chi nhánh của mình
        int branchId = currentUser.getRoleId() == ROLE_ADMIN
                ? -1
                : currentUser.getHomeBranchId();

        // 4. Đọc bộ lọc ngày (parse an toàn, không để lỗi 500)
        LocalDate today = LocalDate.now();
        LocalDate to = parseDate(request.getParameter("to"), today);
        LocalDate from = parseDate(request.getParameter("from"),
                to.minusDays(DEFAULT_RANGE_DAYS - 1));

        // from > to -> đảo chiều cho hợp lý
        if (from.isAfter(to)) {
            LocalDate tmp = from;
            from = to;
            to = tmp;
        }

        String statusFilter = trimToNull(request.getParameter("status"));

        // 5. Load dữ liệu
        AttendanceDAO dao = new AttendanceDAO();
        List<Attendance> attendances;
        Map<LocalDate, Map<String, Object>> dailySummary;

        try {
            attendances = dao.getAttendanceByBranch(branchId, from, to);
            dailySummary = dao.getDailySummary(branchId, from, to);
        } catch (Exception e) {
            throw new ServletException(
                    "Cannot load attendance records", e);
        }

        // 6. Lọc theo trạng thái (sau khi load, vì trạng thái nằm
        //    trên bản ghi chứ không phải điều kiện lọc SQL bắt buộc)
        if (statusFilter != null) {
            attendances = attendances.stream()
                    .filter(a -> statusFilter.equalsIgnoreCase(a.getStatus()))
                    .collect(java.util.stream.Collectors.toList());
        }

        // 7. Thống kê tổng quan
        int totalRecords = attendances.size();
        int completeRecords = (int) attendances.stream()
                .filter(Attendance::isComplete)
                .count();
        double totalHours = attendances.stream()
                .mapToDouble(Attendance::getWorkedHours)
                .sum();

        request.setAttribute("attendanceList", attendances);
        request.setAttribute("dailySummary", dailySummary);
        request.setAttribute("from", from.toString());
        request.setAttribute("to", to.toString());
        request.setAttribute("statusFilter",
                statusFilter == null ? "" : statusFilter);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("completeRecords", completeRecords);
        request.setAttribute("totalHours", round2(totalHours));
        request.setAttribute("isAdminView",
                currentUser.getRoleId() == ROLE_ADMIN);

        request.getRequestDispatcher(
                "/WEB-INF/views/store-manager/attendance.jsp")
                .forward(request, response);
    }

    /**
     * Parse ngày theo định dạng yyyy-MM-dd.
     *
     * <p>Trả về {@code fallback} nếu tham số rỗng hoặc sai định dạng -
     * nhờ vậy người dùng nhập sai không gây HTTP 500.
     */
    private LocalDate parseDate(String raw, LocalDate fallback) {
        if (raw == null || raw.trim().isEmpty()) {
            return fallback;
        }
        try {
            return LocalDate.parse(raw.trim());
        } catch (DateTimeParseException e) {
            return fallback;
        }
    }

    /**
     * Chuẩn hóa chuỗi: bỏ khoảng trắng thừa, trả null nếu rỗng.
     */
    private String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    /**
     * Làm tròn 2 chữ số thập phân (để hiển thị số giờ).
     */
    private double round2(double v) {
        return Math.round(v * 100.0) / 100.0;
    }
}
