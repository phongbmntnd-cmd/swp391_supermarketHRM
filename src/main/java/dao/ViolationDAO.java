/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import context.DBContext;
import model.User;
import model.Violation;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class ViolationDAO {

    private static final String SELECT_COLUMNS
            = "SELECT v.*, ep.full_name AS employee_name, b.name AS branch_name, "
            + "rp.full_name AS reporter_name, hp.full_name AS reviewer_name "
            + "FROM violations v "
            + "JOIN employee_profiles ep ON ep.user_id = v.user_id "
            + "JOIN branches b ON b.id = v.branch_id "
            + "LEFT JOIN employee_profiles rp ON rp.user_id = v.reported_by "
            + "LEFT JOIN employee_profiles hp ON hp.user_id = v.reviewed_by ";

    private Connection connection() throws SQLException {
        try {
            return DBContext.getConnection();
        } catch (Exception e) {
            throw new SQLException("Không thể kết nối đến database", e);
        }
    }

    public List<User> getBranchEmployees(int branchId) throws SQLException {
        List<User> employees = new ArrayList<>();
        String sql = "SELECT u.id, u.username, ep.full_name FROM users u "
                + "JOIN employee_profiles ep ON ep.user_id = u.id "
                + "WHERE ep.home_branch_id = ? AND u.role_id = 5 AND u.status = 'ACTIVE' "
                + "ORDER BY ep.full_name";
        try (Connection conn = connection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User employee = new User();
                    employee.setId(rs.getInt("id"));
                    employee.setUsername(rs.getString("username"));
                    employee.setFullName(rs.getString("full_name"));
                    employees.add(employee);
                }
            }
        }
        return employees;
    }

    public List<Violation> getByBranch(int branchId) throws SQLException {
        return getList(SELECT_COLUMNS + "WHERE v.branch_id = ? ORDER BY v.recorded_at DESC, v.id DESC", branchId);
    }

    public List<Violation> getPendingForHr() throws SQLException {
        return getList(SELECT_COLUMNS + "WHERE v.status = 'PENDING_REVIEW' ORDER BY v.recorded_at ASC, v.id ASC");
    }

    public List<Violation> getReviewedForHr() throws SQLException {
        return getList(SELECT_COLUMNS + "WHERE v.status IN ('APPROVED', 'REJECTED', 'LEGACY') "
                + "ORDER BY v.recorded_at DESC, v.id DESC");
    }

    public List<Violation> getByEmployee(int userId) throws SQLException {
        return getList(SELECT_COLUMNS + "WHERE v.user_id = ? ORDER BY v.recorded_at DESC, v.id DESC", userId);
    }

    private List<Violation> getList(String sql, int... parameters) throws SQLException {
        List<Violation> violations = new ArrayList<>();
        try (Connection conn = connection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < parameters.length; i++) {
                ps.setInt(i + 1, parameters[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    violations.add(map(rs));
                }
            }
        }
        return violations;
    }

    private Violation map(ResultSet rs) throws SQLException {
        Violation violation = new Violation();
        violation.setId(rs.getInt("id"));
        violation.setUserId(rs.getInt("user_id"));
        violation.setBranchId(rs.getInt("branch_id"));
        violation.setEmployeeName(rs.getString("employee_name"));
        violation.setBranchName(rs.getString("branch_name"));
        violation.setTitle(rs.getString("title"));
        violation.setCategory(rs.getString("category"));
        violation.setDescription(rs.getString("description"));
        violation.setEvidenceUrl(rs.getString("evidence_url"));
        violation.setViolationDate(rs.getDate("violation_date"));
        violation.setRecordedAt(rs.getTimestamp("recorded_at"));
        violation.setStatus(rs.getString("status"));
        violation.setReporterName(rs.getString("reporter_name"));
        violation.setReviewerName(rs.getString("reviewer_name"));
        violation.setReviewNote(rs.getString("review_note"));
        violation.setDisciplinaryAction(rs.getString("disciplinary_action"));
        violation.setReviewedAt(rs.getTimestamp("reviewed_at"));
        return violation;
    }

    public boolean createReport(int employeeId, int branchId, int reporterId, String title,
            String category, String description, String evidenceUrl, Date violationDate) throws SQLException {
        String sql = "INSERT INTO violations "
                + "(user_id, branch_id, title, category, description, evidence_url, violation_date, "
                + "reported_by, status, deduction_amount) "
                + "SELECT u.id, ep.home_branch_id, ?, ?, ?, ?, ?, ?, 'PENDING_REVIEW', 0 "
                + "FROM users u JOIN employee_profiles ep ON ep.user_id = u.id "
                + "WHERE u.id = ? AND u.role_id = 5 AND u.status = 'ACTIVE' AND ep.home_branch_id = ?";
        try (Connection conn = connection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, category);
            ps.setString(3, description);
            if (evidenceUrl == null) {
                ps.setNull(4, Types.VARCHAR);
            } else {
                ps.setString(4, evidenceUrl);
            }
            ps.setDate(5, violationDate);
            ps.setInt(6, reporterId);
            ps.setInt(7, employeeId);
            ps.setInt(8, branchId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean review(int violationId, int reviewerId, boolean approved,
            String reviewNote, String disciplinaryAction) throws SQLException {
        String sql = "UPDATE violations SET status = ?, reviewed_by = ?, reviewed_at = CURRENT_TIMESTAMP, "
                + "review_note = ?, disciplinary_action = ? "
                + "WHERE id = ? AND status = 'PENDING_REVIEW'";
        try (Connection conn = connection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, approved ? "APPROVED" : "REJECTED");
            ps.setInt(2, reviewerId);
            ps.setString(3, reviewNote);
            ps.setString(4, disciplinaryAction);
            ps.setInt(5, violationId);
            return ps.executeUpdate() == 1;
        }
    }
}

