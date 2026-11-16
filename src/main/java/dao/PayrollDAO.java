/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import context.DBContext;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.PayrollEmployee;
import model.PayrollPeriod;
import model.Payslip;

public class PayrollDAO {

    private static final BigDecimal ZERO = BigDecimal.ZERO.setScale(2);

    public List<PayrollEmployee> getSalaryEmployees() throws SQLException {
        String sql = "SELECT u.id AS user_id, u.username, ep.full_name, ep.employee_type, b.name AS branch_name, "
                + "sc.monthly_salary, sc.hourly_rate, COALESCE(sc.monthly_allowance, 0) AS monthly_allowance "
                + "FROM users u "
                + "JOIN employee_profiles ep ON ep.user_id = u.id "
                + "LEFT JOIN branches b ON b.id = ep.home_branch_id "
                + "LEFT JOIN employee_salary_configs sc ON sc.user_id = u.id "
                + "WHERE u.role_id IN (4, 5) "
                + "ORDER BY ep.full_name";
        List<PayrollEmployee> employees = new ArrayList<>();
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                employees.add(mapPayrollEmployee(result));
            }
        }
        return employees;
    }

    public void saveSalaryConfig(int userId, BigDecimal monthlySalary, BigDecimal hourlyRate,
            BigDecimal monthlyAllowance, int updatedBy) throws SQLException {
        if (userId <= 0 || updatedBy <= 0 || monthlyAllowance == null || monthlyAllowance.signum() < 0) {
            throw new IllegalArgumentException("Thông tin cấu hình lương không hợp lệ.");
        }

        String employeeType;
        String findEmployeeSql = "SELECT ep.employee_type FROM employee_profiles ep "
                + "JOIN users u ON u.id = ep.user_id WHERE ep.user_id = ? AND u.role_id IN (4, 5)";
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(findEmployeeSql)) {
            statement.setInt(1, userId);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) {
                    throw new IllegalArgumentException("Không tìm thấy nhân viên cần cấu hình lương.");
                }
                employeeType = result.getString("employee_type");
            }
        }

        if ("FULL_TIME".equals(employeeType)) {
            if (monthlySalary == null || monthlySalary.signum() <= 0) {
                throw new IllegalArgumentException("Nhân viên toàn thời gian cần có lương tháng lớn hơn 0.");
            }
            hourlyRate = ZERO;
        } else {
            if (hourlyRate == null || hourlyRate.signum() <= 0) {
                throw new IllegalArgumentException("Nhân viên bán thời gian/thời vụ cần có đơn giá giờ lớn hơn 0.");
            }
            monthlySalary = null;
        }

        String sql = "INSERT INTO employee_salary_configs "
                + "(user_id, monthly_salary, hourly_rate, monthly_allowance, updated_by) "
                + "VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE "
                + "monthly_salary = VALUES(monthly_salary), hourly_rate = VALUES(hourly_rate), "
                + "monthly_allowance = VALUES(monthly_allowance), updated_by = VALUES(updated_by)";
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            if (monthlySalary == null) {
                statement.setNull(2, java.sql.Types.DECIMAL);
            } else {
                statement.setBigDecimal(2, monthlySalary);
            }
            statement.setBigDecimal(3, hourlyRate);
            statement.setBigDecimal(4, monthlyAllowance);
            statement.setInt(5, updatedBy);
            statement.executeUpdate();
        }
    }

    public List<PayrollPeriod> getPayrollPeriods() throws SQLException {
        String sql = "SELECT pp.id, pp.month, pp.year, pp.status, COUNT(ps.id) AS payslip_count "
                + "FROM payroll_periods pp LEFT JOIN payslips ps ON ps.payroll_period_id = pp.id "
                + "GROUP BY pp.id, pp.month, pp.year, pp.status "
                + "ORDER BY pp.year DESC, pp.month DESC";
        List<PayrollPeriod> periods = new ArrayList<>();
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql);
                ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                periods.add(mapPeriod(result));
            }
        }
        return periods;
    }

    public PayrollPeriod getPayrollPeriod(int month, int year) throws SQLException {
        String sql = "SELECT pp.id, pp.month, pp.year, pp.status, "
                + "(SELECT COUNT(*) FROM payslips ps WHERE ps.payroll_period_id = pp.id) AS payslip_count "
                + "FROM payroll_periods pp WHERE pp.month = ? AND pp.year = ?";
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, month);
            statement.setInt(2, year);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? mapPeriod(result) : null;
            }
        }
    }

    public List<Payslip> getPayslips(int periodId) throws SQLException {
        String sql = "SELECT ps.user_id, ep.full_name, u.username, b.name AS branch_name, ep.employee_type, "
                + "ps.total_hours, ps.base_salary, ps.allowances, ps.deductions, ps.net_salary "
                + "FROM payslips ps "
                + "JOIN users u ON u.id = ps.user_id "
                + "JOIN employee_profiles ep ON ep.user_id = ps.user_id "
                + "LEFT JOIN branches b ON b.id = ep.home_branch_id "
                + "WHERE ps.payroll_period_id = ? ORDER BY ep.full_name";
        List<Payslip> payslips = new ArrayList<>();
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, periodId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Payslip payslip = new Payslip();
                    payslip.setUserId(result.getInt("user_id"));
                    payslip.setFullName(result.getString("full_name"));
                    payslip.setUsername(result.getString("username"));
                    payslip.setBranchName(result.getString("branch_name"));
                    payslip.setEmployeeType(result.getString("employee_type"));
                    payslip.setTotalHours(result.getBigDecimal("total_hours"));
                    payslip.setBaseSalary(result.getBigDecimal("base_salary"));
                    payslip.setAllowances(result.getBigDecimal("allowances"));
                    payslip.setDeductions(result.getBigDecimal("deductions"));
                    payslip.setNetSalary(result.getBigDecimal("net_salary"));
                    payslips.add(payslip);
                }
            }
        }
        return payslips;
    }

    public List<Payslip> getFinalizedPayslipsForEmployee(int userId) throws SQLException {
        String sql = "SELECT pp.month, pp.year, ps.total_hours, ps.base_salary, ps.allowances, "
                + "ps.deductions, ps.net_salary FROM payslips ps "
                + "JOIN payroll_periods pp ON pp.id = ps.payroll_period_id "
                + "WHERE ps.user_id = ? AND pp.status = 'FINALIZED' "
                + "ORDER BY pp.year DESC, pp.month DESC";
        List<Payslip> payslips = new ArrayList<>();
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Payslip payslip = new Payslip();
                    payslip.setMonth(result.getInt("month"));
                    payslip.setYear(result.getInt("year"));
                    payslip.setTotalHours(result.getBigDecimal("total_hours"));
                    payslip.setBaseSalary(result.getBigDecimal("base_salary"));
                    payslip.setAllowances(result.getBigDecimal("allowances"));
                    payslip.setDeductions(result.getBigDecimal("deductions"));
                    payslip.setNetSalary(result.getBigDecimal("net_salary"));
                    payslips.add(payslip);
                }
            }
        }
        return payslips;
    }

    public int generateDraft(int month, int year) throws SQLException {
        YearMonth payrollMonth = YearMonth.of(year, month);
        Date periodStart = Date.valueOf(payrollMonth.atDay(1));
        Date periodEnd = Date.valueOf(payrollMonth.plusMonths(1).atDay(1));

        try (Connection connection = getConnection()) {
            connection.setAutoCommit(false);
            try {
                PayrollPeriod period = findPeriodForUpdate(connection, month, year);
                if (period != null && "FINALIZED".equals(period.getStatus())) {
                    throw new IllegalStateException("Bảng lương kỳ này đã chốt và không thể tạo lại.");
                }
                if (period == null) {
                    period = insertPeriod(connection, month, year);
                }

                List<PayrollEmployee> employees = getEmployeesForPayroll(connection, periodStart, periodEnd);
                if (employees.isEmpty()) {
                    throw new IllegalStateException("Không có nhân viên thuộc kỳ lương này.");
                }
                List<String> missingConfigs = new ArrayList<>();
                for (PayrollEmployee employee : employees) {
                    if (!employee.isSalaryConfigured()) {
                        missingConfigs.add(employee.getFullName());
                    }
                }
                if (!missingConfigs.isEmpty()) {
                    throw new IllegalStateException("Chưa cấu hình lương cho: " + String.join(", ", missingConfigs));
                }

                Map<Integer, BigDecimal> hoursByEmployee = getWorkedHours(connection, periodStart, periodEnd);
                Map<Integer, BigDecimal> deductionsByEmployee = getDeductions(connection, periodStart, periodEnd);
                try (PreparedStatement delete = connection.prepareStatement(
                        "DELETE FROM payslips WHERE payroll_period_id = ?")) {
                    delete.setInt(1, period.getId());
                    delete.executeUpdate();
                }

                String insertSql = "INSERT INTO payslips "
                        + "(payroll_period_id, user_id, total_hours, regular_hours, paid_leave_hours, overtime_hours, "
                        + "base_salary, bonus, allowances, deductions, net_salary) "
                        + "VALUES (?, ?, ?, ?, 0, 0, ?, 0, ?, ?, ?)";
                try (PreparedStatement insert = connection.prepareStatement(insertSql)) {
                    for (PayrollEmployee employee : employees) {
                        BigDecimal hours = hoursByEmployee.getOrDefault(employee.getUserId(), ZERO)
                                .setScale(2, RoundingMode.HALF_UP);
                        BigDecimal baseSalary = "FULL_TIME".equals(employee.getEmployeeType())
                                ? employee.getMonthlySalary()
                                : hours.multiply(employee.getHourlyRate()).setScale(2, RoundingMode.HALF_UP);
                        BigDecimal allowances = employee.getMonthlyAllowance() == null
                                ? ZERO : employee.getMonthlyAllowance().setScale(2, RoundingMode.HALF_UP);
                        BigDecimal deductions = deductionsByEmployee.getOrDefault(employee.getUserId(), ZERO)
                                .setScale(2, RoundingMode.HALF_UP);
                        BigDecimal netSalary = baseSalary.add(allowances).subtract(deductions)
                                .setScale(2, RoundingMode.HALF_UP);

                        insert.setInt(1, period.getId());
                        insert.setInt(2, employee.getUserId());
                        insert.setBigDecimal(3, hours);
                        insert.setBigDecimal(4, hours);
                        insert.setBigDecimal(5, baseSalary.setScale(2, RoundingMode.HALF_UP));
                        insert.setBigDecimal(6, allowances);
                        insert.setBigDecimal(7, deductions);
                        insert.setBigDecimal(8, netSalary);
                        insert.addBatch();
                    }
                    insert.executeBatch();
                }
                connection.commit();
                return employees.size();
            } catch (SQLException | RuntimeException e) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;
            }
        }
    }

    public boolean finalizePayroll(int periodId, int month, int year, int finalizedBy) throws SQLException {
        String sql = "UPDATE payroll_periods SET status = 'FINALIZED', finalized_by = ?, "
                + "finalized_at = CURRENT_TIMESTAMP WHERE id = ? AND month = ? AND year = ? "
                + "AND status = 'DRAFT' AND EXISTS (SELECT 1 FROM payslips WHERE payroll_period_id = ?)";
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, finalizedBy);
            statement.setInt(2, periodId);
            statement.setInt(3, month);
            statement.setInt(4, year);
            statement.setInt(5, periodId);
            return statement.executeUpdate() == 1;
        }
    }

    private List<PayrollEmployee> getEmployeesForPayroll(Connection connection, Date periodStart, Date periodEnd)
            throws SQLException {
        String sql = "SELECT u.id AS user_id, u.username, ep.full_name, ep.employee_type, b.name AS branch_name, "
                + "sc.monthly_salary, sc.hourly_rate, COALESCE(sc.monthly_allowance, 0) AS monthly_allowance "
                + "FROM users u JOIN employee_profiles ep ON ep.user_id = u.id "
                + "LEFT JOIN branches b ON b.id = ep.home_branch_id "
                + "LEFT JOIN employee_salary_configs sc ON sc.user_id = u.id "
                + "WHERE u.role_id IN (4, 5) AND (u.status = 'ACTIVE' OR EXISTS ("
                + "SELECT 1 FROM contracts c WHERE c.user_id = u.id "
                + "AND c.start_date < ? AND (c.end_date IS NULL OR c.end_date >= ?))) "
                + "ORDER BY ep.full_name";
        List<PayrollEmployee> employees = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, periodEnd);
            statement.setDate(2, periodStart);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    employees.add(mapPayrollEmployee(result));
                }
            }
        }
        return employees;
    }

    private Map<Integer, BigDecimal> getWorkedHours(Connection connection, Date periodStart, Date periodEnd)
            throws SQLException {
        String sql = "SELECT ss.user_id, ROUND(SUM(TIMESTAMPDIFF(MINUTE, a.check_in, a.check_out)) / 60, 2) "
                + "AS total_hours FROM attendances a "
                + "JOIN shift_schedules ss ON ss.id = a.shift_schedule_id "
                + "WHERE a.user_id = ss.user_id AND ss.status = 'PUBLISHED' "
                + "AND ss.work_date >= ? AND ss.work_date < ? "
                + "AND a.status IN ('VALID', 'ADJUSTED') AND a.check_in IS NOT NULL AND a.check_out IS NOT NULL "
                + "AND a.check_out > a.check_in GROUP BY ss.user_id";
        Map<Integer, BigDecimal> hours = new HashMap<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, periodStart);
            statement.setDate(2, periodEnd);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    hours.put(result.getInt("user_id"), result.getBigDecimal("total_hours"));
                }
            }
        }
        return hours;
    }

    private Map<Integer, BigDecimal> getDeductions(Connection connection, Date periodStart, Date periodEnd)
            throws SQLException {
        String sql = "SELECT user_id, SUM(deduction_amount) AS total_deductions FROM violations "
                + "WHERE violation_date >= ? AND violation_date < ? AND status <> 'REJECTED' "
                + "GROUP BY user_id";
        Map<Integer, BigDecimal> deductions = new HashMap<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, periodStart);
            statement.setDate(2, periodEnd);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    BigDecimal value = result.getBigDecimal("total_deductions");
                    deductions.put(result.getInt("user_id"),
                            value == null ? ZERO : value.setScale(2, RoundingMode.HALF_UP));
                }
            }
        }
        return deductions;
    }

    private PayrollPeriod findPeriodForUpdate(Connection connection, int month, int year) throws SQLException {
        String sql = "SELECT id, month, year, status FROM payroll_periods WHERE month = ? AND year = ? FOR UPDATE";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, month);
            statement.setInt(2, year);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) {
                    return null;
                }
                PayrollPeriod period = new PayrollPeriod();
                period.setId(result.getInt("id"));
                period.setMonth(result.getInt("month"));
                period.setYear(result.getInt("year"));
                period.setStatus(result.getString("status"));
                return period;
            }
        }
    }

    private PayrollPeriod insertPeriod(Connection connection, int month, int year) throws SQLException {
        String sql = "INSERT INTO payroll_periods (month, year, status) VALUES (?, ?, 'DRAFT')";
        try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, month);
            statement.setInt(2, year);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Không thể tạo kỳ lương.");
                }
                PayrollPeriod period = new PayrollPeriod();
                period.setId(keys.getInt(1));
                period.setMonth(month);
                period.setYear(year);
                period.setStatus("DRAFT");
                return period;
            }
        }
    }

    private PayrollEmployee mapPayrollEmployee(ResultSet result) throws SQLException {
        PayrollEmployee employee = new PayrollEmployee();
        employee.setUserId(result.getInt("user_id"));
        employee.setFullName(result.getString("full_name"));
        employee.setUsername(result.getString("username"));
        employee.setBranchName(result.getString("branch_name"));
        employee.setEmployeeType(result.getString("employee_type"));
        employee.setMonthlySalary(result.getBigDecimal("monthly_salary"));
        employee.setHourlyRate(result.getBigDecimal("hourly_rate"));
        employee.setMonthlyAllowance(result.getBigDecimal("monthly_allowance"));
        return employee;
    }

    private PayrollPeriod mapPeriod(ResultSet result) throws SQLException {
        PayrollPeriod period = new PayrollPeriod();
        period.setId(result.getInt("id"));
        period.setMonth(result.getInt("month"));
        period.setYear(result.getInt("year"));
        period.setStatus(result.getString("status"));
        period.setPayslipCount(result.getInt("payslip_count"));
        return period;
    }

    private Connection getConnection() throws SQLException {
        try {
            return DBContext.getConnection();
        } catch (Exception e) {
            throw new SQLException("Không thể kết nối cơ sở dữ liệu để xử lý bảng lương.", e);
        }
    }
}

