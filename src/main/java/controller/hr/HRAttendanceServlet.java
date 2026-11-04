package controller.hr;

import controller.base.BaseServlet;
import dao.AttendanceDAO;
import dao.BranchDAO;
import model.Attendance;
import model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Trang Chấm công &amp; Ca làm dành cho HR.
 *
 * <h3>Phạm vi</h3>
 * HR xem được chấm công của TOÀN BỘ chi nhánh (khác với Store Manager
 * chỉ thấy chi nhánh của mình). Có thể lọc theo chi nhánh cụ thể.
 *
 * <h3>Bộ lọc</h3>
 * <ul>
 *   <li>{@code branchId} - chi nhánh (mặc định: tất cả).</li>
 *   <li>{@code from} / {@code to} - khoảng ngày (mặc định: 30 ngày).</li>
 *   <li>{@code status} - trạng thái bản ghi.</li>
 *   <li>{@code q} - tìm theo tên / username nhân viên.</li>
 * </ul>
 */
@WebServlet(name = "HRAttendanceServlet",
        urlPatterns = {"/hr/attendance-management"})
public class HRAttendanceServlet extends BaseServlet {

    private static final int DEFAULT_RANGE_DAYS = 30;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER
                && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response,
                    "Bạn không có quyền truy cập trang Chấm công!");
            return;
        }

        // 1. Bộ lọc chi nhánh
        //    -1 = tất cả chi nhánh
        int branchId = -1;
        String branchRaw = request.getParameter("branchId");
        if (branchRaw != null && !branchRaw.trim().isEmpty()) {
            try {
                branchId = Integer.parseInt(branchRaw.trim());
            } catch (NumberFormatException e) {
                branchId = -1;
            }
        }

        // 2. Bộ lọc ngày (parse an toàn)
        LocalDate today = LocalDate.now();
        LocalDate to = parseDate(request.getParameter("to"), today);
        LocalDate from = parseDate(request.getParameter("from"),
                to.minusDays(DEFAULT_RANGE_DAYS - 1));
        if (from.isAfter(to)) {
            LocalDate tmp = from;
            from = to;
            to = tmp;
        }

        String statusFilter = trimToNull(request.getParameter("status"));
        String keyword = trimToNull(request.getParameter("q"));

        // 3. Load dữ liệu
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

        // 4. Lọc theo trạng thái
        if (statusFilter != null) {
            final String sf = statusFilter;
            attendances = attendances.stream()
                    .filter(a -> sf.equalsIgnoreCase(a.getStatus()))
                    .collect(Collectors.toList());
        }

        // 5. Lọc theo từ khoá tên / username
        if (keyword != null) {
            final String kw = keyword.toLowerCase();
            attendances = attendances.stream()
                    .filter(a -> {
                        String name = a.getFullName() == null
                                ? "" : a.getFullName().toLowerCase();
                        String uname = a.getUsername() == null
                                ? "" : a.getUsername().toLowerCase();
                        return name.contains(kw) || uname.contains(kw);
                    })
                    .collect(Collectors.toList());
        }

        // 6. Thống kê
        int totalRecords = attendances.size();
        int completeRecords = (int) attendances.stream()
                .filter(Attendance::isComplete)
                .count();
        double totalHours = attendances.stream()
                .mapToDouble(Attendance::getWorkedHours)
                .sum();

        request.setAttribute("attendanceList", attendances);
        request.setAttribute("dailySummary", dailySummary);
        request.setAttribute("branchList", new BranchDAO().getAllBranches());
        request.setAttribute("branchId", branchId);
        request.setAttribute("from", from.toString());
        request.setAttribute("to", to.toString());
        request.setAttribute("statusFilter",
                statusFilter == null ? "" : statusFilter);
        request.setAttribute("keyword",
                keyword == null ? "" : keyword);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("completeRecords", completeRecords);
        request.setAttribute("totalHours", Math.round(totalHours * 100.0) / 100.0);

        request.getRequestDispatcher(
                "/WEB-INF/views/hr/attendance-management.jsp")
                .forward(request, response);
    }

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

    private String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
