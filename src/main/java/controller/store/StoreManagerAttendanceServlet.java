package controller.store;

import controller.base.BaseServlet;
import dao.AttendanceDAO;
<<<<<<< Updated upstream
import model.User;
import java.io.IOException;
=======
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.util.List;
import model.Attendance;
import model.User;
>>>>>>> Stashed changes
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "StoreManagerAttendanceServlet", urlPatterns = {"/store-manager/attendance"})
public class StoreManagerAttendanceServlet extends BaseServlet {

<<<<<<< Updated upstream
=======
    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

>>>>>>> Stashed changes
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
<<<<<<< Updated upstream

        // 2. Kiểm tra phân quyền Store Manager (ROLE_STORE_MANAGER = 4) hoặc Admin (ROLE_ADMIN = 1)
        if (currentUser.getRoleId() != ROLE_STORE_MANAGER && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Chấm công cửa hàng!");
            return;
        }

        // 3. Lấy dữ liệu bảng chấm công theo branchId của cửa hàng (Giữ nguyên luồng của bạn)
        AttendanceDAO attendanceDAO = new AttendanceDAO();
        // List<Attendance> attendances = attendanceDAO.getByBranch(currentUser.getHomeBranchId());
        // request.setAttribute("attendanceList", attendances);

        request.getRequestDispatcher("/WEB-INF/views/store-manager/attendance.jsp").forward(request, response);
    }
}
=======
        if (user.getRoleId() != ROLE_STORE_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập bảng chấm công cửa hàng.");
            return;
        }
        if (user.getRoleId() == ROLE_STORE_MANAGER && user.getHomeBranchId() <= 0) {
            sendForbidden(request, response, "Tài khoản quản lý chưa được gán chi nhánh.");
            return;
        }

        String adjustmentId = request.getParameter("adjustmentId");
        if (adjustmentId != null) {
            showAdjustmentPage(request, response, user, adjustmentId);
            return;
        }

        LocalDate workDate = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        String dateParam = request.getParameter("date");
        String dateError = null;
        if (dateParam != null && !dateParam.trim().isEmpty()) {
            try {
                workDate = LocalDate.parse(dateParam);
            } catch (DateTimeParseException e) {
                dateError = "Ngày lọc không hợp lệ. Đang hiển thị chấm công hôm nay.";
            }
        }

        try {
            List<Attendance> attendances = attendanceDAO.getBranchAttendance(
                    getBranchId(user), Date.valueOf(workDate));
            request.setAttribute("attendances", attendances);
            request.setAttribute("selectedDate", workDate.toString());
            request.setAttribute("successMessage", getAndClearSuccessMessage(request));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.setAttribute("dateError", dateError);
            request.getRequestDispatcher("/WEB-INF/views/store-manager/attendance.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải bảng chấm công của chi nhánh.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (user.getRoleId() != ROLE_STORE_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền xử lý chấm công.");
            return;
        }
        if (user.getRoleId() == ROLE_STORE_MANAGER && user.getHomeBranchId() <= 0) {
            sendForbidden(request, response, "Tài khoản quản lý chưa được gán chi nhánh.");
            return;
        }

        if ("adjust".equals(request.getParameter("action"))) {
            adjustAttendance(request, response, user);
            return;
        }

        int attendanceId;
        try {
            attendanceId = Integer.parseInt(request.getParameter("attendanceId"));
        } catch (NumberFormatException | NullPointerException e) {
            setErrorMessage(request, "Bản ghi chấm công không hợp lệ.");
            redirectToSelectedDate(request, response);
            return;
        }
        String status = request.getParameter("status");
        if (attendanceId <= 0 || (!"VALID".equals(status) && !"INVALID".equals(status))) {
            setErrorMessage(request, "Kết quả duyệt chấm công không hợp lệ.");
            redirectToSelectedDate(request, response);
            return;
        }

        try {
            boolean updated = attendanceDAO.reviewAttendance(attendanceId,
                    getBranchId(user), status);
            if (updated) {
                setSuccessMessage(request, "Đã cập nhật kết quả duyệt chấm công.");
            } else {
                setErrorMessage(request, "Không tìm thấy bản ghi thuộc chi nhánh của bạn.");
            }
        } catch (Exception e) {
            throw new ServletException("Không thể duyệt bản ghi chấm công.", e);
        }
        redirectToSelectedDate(request, response);
    }

    private void showAdjustmentPage(HttpServletRequest request, HttpServletResponse response,
            User user, String idParam) throws ServletException, IOException {
        int attendanceId;
        try {
            attendanceId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            redirectToSelectedDate(request, response);
            return;
        }
        if (attendanceId <= 0) {
            redirectToSelectedDate(request, response);
            return;
        }

        try {
            Attendance attendance = attendanceDAO.getAttendanceForStoreManagerById(attendanceId, getBranchId(user));
            if (attendance == null) {
                setErrorMessage(request, "Không tìm thấy bản ghi thuộc chi nhánh của bạn.");
                redirectToSelectedDate(request, response);
                return;
            }
            request.setAttribute("attendance", attendance);
            request.setAttribute("selectedDate", getSelectedDate(request));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.getRequestDispatcher("/WEB-INF/views/store-manager/attendance-adjustment.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải trang điều chỉnh chấm công.", e);
        }
    }

    private void adjustAttendance(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        int attendanceId;
        LocalTime checkIn;
        LocalTime checkOut;
        String note = request.getParameter("adjustmentNote");
        if (note != null) {
            note = note.trim();
        }
        try {
            attendanceId = Integer.parseInt(request.getParameter("attendanceId"));
            checkIn = parseTime(request.getParameter("checkIn"));
            checkOut = parseTime(request.getParameter("checkOut"));
        } catch (NumberFormatException | DateTimeParseException | NullPointerException e) {
            setErrorMessage(request, "Giờ chấm công hoặc bản ghi được chọn không hợp lệ.");
            redirectToAdjustment(request, response);
            return;
        }

        if (attendanceId <= 0 || note == null || note.isEmpty() || note.length() > 1000
                || (checkIn == null && checkOut == null)
                || (checkIn != null && checkOut != null && !checkOut.isAfter(checkIn))) {
            setErrorMessage(request, "Hãy nhập giờ chấm công hợp lệ và ghi rõ lý do điều chỉnh.");
            redirectToAdjustment(request, response);
            return;
        }

        try {
            boolean adjusted = attendanceDAO.adjustAttendance(attendanceId, getBranchId(user), user.getId(),
                    checkIn, checkOut, note);
            if (adjusted) {
                setSuccessMessage(request, "Đã điều chỉnh giờ chấm công và lưu lý do xử lý.");
                redirectToSelectedDate(request, response);
            } else {
                setErrorMessage(request, "Không tìm thấy bản ghi thuộc chi nhánh của bạn.");
                redirectToAdjustment(request, response);
            }
        } catch (IllegalArgumentException e) {
            setErrorMessage(request, e.getMessage());
            redirectToAdjustment(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể lưu điều chỉnh chấm công.", e);
        }
    }

    private LocalTime parseTime(String value) {
        return value == null || value.trim().isEmpty() ? null : LocalTime.parse(value);
    }

    private int getBranchId(User user) {
        return user.getRoleId() == ROLE_ADMIN ? 0 : user.getHomeBranchId();
    }

    private void redirectToAdjustment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String id = request.getParameter("attendanceId");
        if (id == null || !id.matches("\\d+")) {
            redirectToSelectedDate(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/store-manager/attendance?adjustmentId="
                + id + "&date=" + getSelectedDate(request));
    }

    private void redirectToSelectedDate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath()
                + "/store-manager/attendance?date=" + getSelectedDate(request));
    }

    private String getSelectedDate(HttpServletRequest request) {
        String date = request.getParameter("date");
        LocalDate selectedDate;
        try {
            selectedDate = date == null
                    ? LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"))
                    : LocalDate.parse(date);
        } catch (DateTimeParseException e) {
            selectedDate = LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        }
        return selectedDate.toString();
    }
}
>>>>>>> Stashed changes
