/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.hr;

import controller.base.BaseServlet;
import dao.PayrollDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.PayrollPeriod;
import model.Payslip;
import model.User;

@WebServlet("/hr/payroll")
public class HRPayrollServlet extends BaseServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (!isHr(user)) {
            sendForbidden(request, response, "Chỉ HR mới được quản lý bảng lương.");
            return;
        }

        YearMonth selectedPeriod;
        try {
            selectedPeriod = parsePeriod(request.getParameter("month"), request.getParameter("year"));
        } catch (IllegalArgumentException e) {
            setErrorMessage(request, e.getMessage());
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
            return;
        }
        try {
            PayrollPeriod period = payrollDAO.getPayrollPeriod(
                    selectedPeriod.getMonthValue(), selectedPeriod.getYear());
            request.setAttribute("selectedMonth", selectedPeriod.getMonthValue());
            request.setAttribute("selectedYear", selectedPeriod.getYear());
            request.setAttribute("salaryEmployees", payrollDAO.getSalaryEmployees());
            request.setAttribute("payrollPeriods", payrollDAO.getPayrollPeriods());
            request.setAttribute("payrollPeriod", period);
            List<Payslip> payslips = period == null
                    ? new ArrayList<>() : payrollDAO.getPayslips(period.getId());
            BigDecimal totalHours = BigDecimal.ZERO;
            BigDecimal totalBaseSalary = BigDecimal.ZERO;
            BigDecimal totalAllowances = BigDecimal.ZERO;
            BigDecimal totalDeductions = BigDecimal.ZERO;
            BigDecimal totalNetSalary = BigDecimal.ZERO;
            for (Payslip payslip : payslips) {
                totalHours = totalHours.add(payslip.getTotalHours());
                totalBaseSalary = totalBaseSalary.add(payslip.getBaseSalary());
                totalAllowances = totalAllowances.add(payslip.getAllowances());
                totalDeductions = totalDeductions.add(payslip.getDeductions());
                totalNetSalary = totalNetSalary.add(payslip.getNetSalary());
            }
            request.setAttribute("payslips", payslips);
            request.setAttribute("totalHours", totalHours);
            request.setAttribute("totalBaseSalary", totalBaseSalary);
            request.setAttribute("totalAllowances", totalAllowances);
            request.setAttribute("totalDeductions", totalDeductions);
            request.setAttribute("totalNetSalary", totalNetSalary);
            request.setAttribute("successMessage", getAndClearSuccessMessage(request));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.getRequestDispatcher("/WEB-INF/views/hr/payroll.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Không thể tải dữ liệu bảng lương.", e);
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
        if (!isHr(user)) {
            sendForbidden(request, response, "Chỉ HR mới được quản lý bảng lương.");
            return;
        }

        String action = getStringParameter(request, "action");
        YearMonth period;
        try {
            period = parsePeriod(request.getParameter("month"), request.getParameter("year"));
        } catch (IllegalArgumentException e) {
            setErrorMessage(request, e.getMessage());
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
            return;
        }

        try {
            if ("saveSalary".equals(action)) {
                int employeeId = getIntParameter(request, "employeeId", -1);
                BigDecimal monthlySalary = parseOptionalAmount(request.getParameter("monthlySalary"), "lương tháng");
                BigDecimal hourlyRate = parseOptionalAmount(request.getParameter("hourlyRate"), "đơn giá giờ");
                BigDecimal monthlyAllowance = parseRequiredAmount(
                        request.getParameter("monthlyAllowance"), "phụ cấp tháng");
                payrollDAO.saveSalaryConfig(employeeId, monthlySalary, hourlyRate, monthlyAllowance, user.getId());
                setSuccessMessage(request, "Đã lưu cấu hình lương nhân viên.");
            } else if ("generate".equals(action)) {
                int employeeCount = payrollDAO.generateDraft(period.getMonthValue(), period.getYear());
                setSuccessMessage(request, "Đã tạo bảng lương nháp cho " + employeeCount + " nhân viên.");
            } else if ("finalize".equals(action)) {
                int periodId = getIntParameter(request, "periodId", -1);
                if (periodId <= 0 || !payrollDAO.finalizePayroll(
                        periodId, period.getMonthValue(), period.getYear(), user.getId())) {
                    throw new IllegalStateException("Không thể chốt bảng lương. Kỳ lương có thể đã chốt hoặc chưa có phiếu lương.");
                }
                setSuccessMessage(request, "Đã chốt bảng lương. Kỳ này không thể tạo lại.");
            } else {
                throw new IllegalArgumentException("Thao tác bảng lương không hợp lệ.");
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            setErrorMessage(request, e.getMessage());
        } catch (SQLException e) {
            throw new ServletException("Không thể lưu thay đổi bảng lương.", e);
        }

        response.sendRedirect(request.getContextPath() + "/hr/payroll?month="
                + period.getMonthValue() + "&year=" + period.getYear());
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

    private BigDecimal parseRequiredAmount(String value, String label) {
        BigDecimal amount = parseOptionalAmount(value, label);
        if (amount == null) {
            throw new IllegalArgumentException("Vui lòng nhập " + label + ".");
        }
        return amount;
    }

    private BigDecimal parseOptionalAmount(String value, String label) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        String normalized = value.trim();
        if (!normalized.matches("[0-9]{1,10}(\\.[0-9]{1,2})?")) {
            throw new IllegalArgumentException(
                    label + " chỉ được gồm chữ số, tối đa 10 chữ số nguyên và 2 chữ số thập phân.");
        }
        try {
            return new BigDecimal(normalized).setScale(2, RoundingMode.UNNECESSARY);
        } catch (NumberFormatException | ArithmeticException e) {
            throw new IllegalArgumentException(label + " không hợp lệ.");
        }
    }

    private boolean isHr(User user) {
        return user.getRoleId() == ROLE_HR_MANAGER || user.getRoleId() == ROLE_ADMIN;
    }
}
