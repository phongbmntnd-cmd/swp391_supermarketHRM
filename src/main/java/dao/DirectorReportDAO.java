/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import context.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import model.Branch;
import model.DirectorBranchReport;

public class DirectorReportDAO {

    public List<DirectorBranchReport> getMonthlyBranchReports(YearMonth period, int branchId)
            throws SQLException {
        String sql = "SELECT b.id, b.code, b.name, b.status, "
                + "(SELECT COUNT(*) FROM users u "
                + "JOIN employee_profiles ep ON ep.user_id = u.id "
                + "WHERE ep.home_branch_id = b.id AND u.role_id IN (4, 5) AND u.status = 'ACTIVE') "
                + "AS employee_count, "
                + "COALESCE(a.scheduled_shifts, 0) AS scheduled_shifts, "
                + "COALESCE(a.recorded_attendances, 0) AS recorded_attendances, "
                + "COALESCE(a.valid_attendances, 0) AS valid_attendances, "
                + "COALESCE(a.adjusted_attendances, 0) AS adjusted_attendances, "
                + "COALESCE(a.invalid_attendances, 0) AS invalid_attendances, "
                + "COALESCE(a.pending_attendances, 0) AS pending_attendances, "
                + "COALESCE(p.payroll_payslips, 0) AS payroll_payslips, "
                + "COALESCE(p.finalized_payroll, 0) AS finalized_payroll, "
                + "COALESCE(v.violation_count, 0) AS violation_count, "
                + "COALESCE(v.pending_violations, 0) AS pending_violations, "
                + "COALESCE(v.approved_violations, 0) AS approved_violations "
                + "FROM branches b "
                + "LEFT JOIN ("
                + "SELECT ss.branch_id, COUNT(DISTINCT ss.id) AS scheduled_shifts, COUNT(a.id) AS recorded_attendances, "
                + "SUM(CASE WHEN a.status = 'VALID' THEN 1 ELSE 0 END) AS valid_attendances, "
                + "SUM(CASE WHEN a.status = 'ADJUSTED' THEN 1 ELSE 0 END) AS adjusted_attendances, "
                + "SUM(CASE WHEN a.status = 'INVALID' THEN 1 ELSE 0 END) AS invalid_attendances, "
                + "SUM(CASE WHEN a.status = 'PENDING' THEN 1 ELSE 0 END) AS pending_attendances "
                + "FROM shift_schedules ss "
                + "LEFT JOIN attendances a ON a.shift_schedule_id = ss.id AND a.user_id = ss.user_id "
                + "WHERE ss.status = 'PUBLISHED' AND ss.work_date >= ? AND ss.work_date < ? "
                + "GROUP BY ss.branch_id"
                + ") a ON a.branch_id = b.id "
                + "LEFT JOIN ("
                + "SELECT ep.home_branch_id AS branch_id, COUNT(ps.id) AS payroll_payslips, "
                + "SUM(ps.net_salary) AS finalized_payroll "
                + "FROM payroll_periods pp "
                + "JOIN payslips ps ON ps.payroll_period_id = pp.id "
                + "JOIN employee_profiles ep ON ep.user_id = ps.user_id "
                + "WHERE pp.month = ? AND pp.year = ? AND pp.status = 'FINALIZED' "
                + "GROUP BY ep.home_branch_id"
                + ") p ON p.branch_id = b.id "
                + "LEFT JOIN ("
                + "SELECT branch_id, COUNT(*) AS violation_count, "
                + "SUM(CASE WHEN status = 'PENDING_REVIEW' THEN 1 ELSE 0 END) AS pending_violations, "
                + "SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) AS approved_violations "
                + "FROM violations "
                + "WHERE COALESCE(violation_date, DATE(recorded_at)) >= ? "
                + "AND COALESCE(violation_date, DATE(recorded_at)) < ? "
                + "GROUP BY branch_id"
                + ") v ON v.branch_id = b.id "
                + "WHERE (? = 0 OR b.id = ?) "
                + "ORDER BY b.id";

        Date periodStart = Date.valueOf(period.atDay(1));
        Date periodEnd = Date.valueOf(period.plusMonths(1).atDay(1));
        List<DirectorBranchReport> reports = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, periodStart);
            statement.setDate(2, periodEnd);
            statement.setInt(3, period.getMonthValue());
            statement.setInt(4, period.getYear());
            statement.setDate(5, periodStart);
            statement.setDate(6, periodEnd);
            statement.setInt(7, branchId);
            statement.setInt(8, branchId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    BigDecimal finalizedPayroll = result.getBigDecimal("finalized_payroll");
                    reports.add(new DirectorBranchReport(
                            result.getInt("id"),
                            result.getString("code"),
                            result.getString("name"),
                            result.getString("status"),
                            result.getInt("employee_count"),
                            result.getInt("scheduled_shifts"),
                            result.getInt("recorded_attendances"),
                            result.getInt("valid_attendances"),
                            result.getInt("adjusted_attendances"),
                            result.getInt("invalid_attendances"),
                            result.getInt("pending_attendances"),
                            result.getInt("payroll_payslips"),
                            finalizedPayroll == null ? BigDecimal.ZERO : finalizedPayroll,
                            result.getInt("violation_count"),
                            result.getInt("pending_violations"),
                            result.getInt("approved_violations")));
                }
            }
        } catch (Exception e) {
            throw new SQLException("Không thể tải báo cáo hoạt động chi nhánh.", e);
        }
        return reports;
    }

    public List<Branch> getBranches(int branchId) throws SQLException {
        String sql = "SELECT id, code, name, address, status, store_manager_id, created_at "
                + "FROM branches WHERE (? = 0 OR id = ?) ORDER BY id";
        List<Branch> branches = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, branchId);
            statement.setInt(2, branchId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Branch branch = new Branch();
                    branch.setId(result.getInt("id"));
                    branch.setCode(result.getString("code"));
                    branch.setName(result.getString("name"));
                    branch.setAddress(result.getString("address"));
                    branch.setStatus(result.getString("status"));
                    branch.setStoreManagerId(result.getInt("store_manager_id"));
                    branch.setCreatedAt(result.getTimestamp("created_at"));
                    branches.add(branch);
                }
            }
        } catch (Exception e) {
            throw new SQLException("Không thể tải danh sách chi nhánh cho bộ lọc báo cáo.", e);
        }
        return branches;
    }
}

