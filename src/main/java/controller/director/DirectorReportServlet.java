/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.director;

import controller.base.BaseServlet;
import dao.DirectorReportDAO;
import dao.BranchDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.YearMonth;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Branch;
import model.DirectorBranchReport;
import model.User;

@WebServlet("/director/reports")
public class DirectorReportServlet extends BaseServlet {

    private final DirectorReportDAO reportDAO = new DirectorReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }
        int roleId = currentUser.getRoleId();
        boolean storeManager = roleId == ROLE_STORE_MANAGER;
        if (roleId != ROLE_DIRECTOR && roleId != ROLE_ADMIN
                && roleId != ROLE_HR_MANAGER && !storeManager) {
            sendForbidden(request, response, "Bạn không có quyền xem báo cáo toàn chuỗi.");
            return;
        }

        YearMonth selectedPeriod;
        int branchId;
        try {
            selectedPeriod = parsePeriod(request.getParameter("month"), request.getParameter("year"));
            branchId = storeManager
                    ? resolveManagedBranchId(request, currentUser)
                    : parseBranchId(request.getParameter("branchId"));

        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
            return;
        }

        if (storeManager && branchId <= 0) {
            sendForbidden(request, response,
                    "Bạn không có quyền xem báo cáo tại chi nhánh này.");
            return;
        }

        String reportHomePath = storeManager ? "/store-manager/dashboard"
                : roleId == ROLE_HR_MANAGER ? "/hr/dashboard" : "/director/dashboard";

        try {
            List<DirectorBranchReport> reports = reportDAO.getMonthlyBranchReports(selectedPeriod, branchId);
            List<Branch> branches = reportDAO.getBranches(storeManager ? branchId : 0);
            int employeeCount = 0;
            int scheduledShifts = 0;
            int recordedAttendances = 0;
            int violationCount = 0;
            int pendingViolations = 0;
            int payrollPayslips = 0;
            BigDecimal finalizedPayroll = BigDecimal.ZERO;
            for (DirectorBranchReport report : reports) {
                employeeCount += report.getEmployeeCount();
                scheduledShifts += report.getScheduledShifts();
                recordedAttendances += report.getRecordedAttendances();
                violationCount += report.getViolationCount();
                pendingViolations += report.getPendingViolations();
                payrollPayslips += report.getPayrollPayslips();
                finalizedPayroll = finalizedPayroll.add(report.getFinalizedPayroll());
            }

            request.setAttribute("reports", reports);
            request.setAttribute("branches", branches);
            request.setAttribute("selectedMonth", selectedPeriod.getMonthValue());
            request.setAttribute("selectedYear", selectedPeriod.getYear());
            request.setAttribute("selectedBranchId", branchId);
            request.setAttribute("storeManagerReport", storeManager);
            request.setAttribute("reportHomePath", reportHomePath);
            request.setAttribute("employeeCount", employeeCount);
            request.setAttribute("scheduledShifts", scheduledShifts);
            request.setAttribute("recordedAttendances", recordedAttendances);
            request.setAttribute("violationCount", violationCount);
            request.setAttribute("pendingViolations", pendingViolations);
            request.setAttribute("payrollPayslips", payrollPayslips);
            request.setAttribute("finalizedPayroll", finalizedPayroll);
        } catch (SQLException e) {
            throw new ServletException("Không thể tải báo cáo hoạt động chi nhánh.", e);
        }
        request.getRequestDispatcher("/WEB-INF/views/director/reports.jsp").forward(request, response);
    }

    private int resolveManagedBranchId(
            HttpServletRequest request, User user) {

        if (user == null
                || user.getRoleId() != ROLE_STORE_MANAGER) {
            return -1;
        }

        int selectedBranchId = getCurrentBranchId(request);

        BranchDAO branchDAO = new BranchDAO();

        for (Branch branch
                : branchDAO.getManagedBranches(user.getId())) {

            if (branch.getId() == selectedBranchId
                    && "ACTIVE".equals(branch.getStatus())) {
                return selectedBranchId;
            }
        }

        return -1;
    }

    private YearMonth parsePeriod(String rawMonth, String rawYear) {
        YearMonth current = YearMonth.now();
        int month = parseInteger(rawMonth, current.getMonthValue(), "tháng");
        int year = parseInteger(rawYear, current.getYear(), "năm");
        if (year < 2000 || year > 9999 || month < 1 || month > 12) {
            throw new IllegalArgumentException("Tháng hoặc năm không hợp lệ.");
        }
        return YearMonth.of(year, month);
    }

    private int parseInteger(String value, int fallback, String label) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Giá trị " + label + " không hợp lệ.");
        }
    }

    private int parseBranchId(String value) {
        if (value == null || value.trim().isEmpty()) {
            return 0;
        }
        int branchId;
        try {
            branchId = Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Chi nhánh không hợp lệ.");
        }
        if (branchId < 0) {
            throw new IllegalArgumentException("Chi nhánh không hợp lệ.");
        }
        return branchId;
    }
}
