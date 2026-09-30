package dao;

import context.DBContext;
import model.Branch;
import model.Department;
import model.Employee;
import model.Position;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho màn hình "Quản lý Hồ sơ Nhân sự":
 * danh sách/tìm kiếm nhân viên toàn hệ thống, xem chi tiết, cập nhật hồ sơ.
 */
public class EmployeeDAO {

    private static final String BASE_SELECT =
            "SELECT u.id AS user_id, u.username, u.email, u.status AS user_status, u.role_id, r.name AS role_name, "
            + "ep.full_name, ep.phone, ep.identity_card, "
            + "ep.home_branch_id, b.name AS branch_name, "
            + "ep.position_id, p.title AS position_title, "
            + "ep.department_id, d.name AS department_name, "
            + "ep.employee_type "
            + "FROM users u "
            + "JOIN roles r ON u.role_id = r.id "
            + "LEFT JOIN employee_profiles ep ON u.id = ep.user_id "
            + "LEFT JOIN branches b ON ep.home_branch_id = b.id "
            + "LEFT JOIN positions p ON ep.position_id = p.id "
            + "LEFT JOIN departments d ON ep.department_id = d.id ";

    /**
     * Danh sách toàn bộ nhân viên (có hồ sơ), hỗ trợ tìm theo tên/username/SĐT/CCCD.
     * keyword = null hoặc rỗng -> lấy tất cả.
     */
    public List<Employee> getAllEmployees(String keyword) {
        List<Employee> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append("WHERE ep.user_id IS NOT NULL ");

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        if (hasKeyword) {
            sql.append("AND (u.username LIKE ? OR ep.full_name LIKE ? OR ep.phone LIKE ? OR ep.identity_card LIKE ?) ");
        }
        sql.append("ORDER BY ep.full_name ASC");

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (hasKeyword) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(1, kw);
                ps.setString(2, kw);
                ps.setString(3, kw);
                ps.setString(4, kw);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Xem chi tiết 1 nhân viên theo user_id.
     */
    public Employee getEmployeeById(int userId) {
        String sql = BASE_SELECT + "WHERE u.id = ?";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật thông tin chi tiết + thông tin liên lạc của nhân viên.
     */
    public boolean updateEmployeeProfile(int userId, String fullName, String phone, String identityCard,
                                          int homeBranchId, int positionId, int departmentId, String employeeType) {

        String sql = "UPDATE employee_profiles SET full_name = ?, phone = ?, identity_card = ?, "
                + "home_branch_id = ?, position_id = ?, department_id = ?, employee_type = ? "
                + "WHERE user_id = ?";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, identityCard);
            ps.setInt(4, homeBranchId);
            ps.setInt(5, positionId);
            ps.setInt(6, departmentId);
            ps.setString(7, employeeType);
            ps.setInt(8, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật trạng thái tài khoản (ACTIVE / INACTIVE / EMERGENCY_LOCKED).
     * Dùng khi HR cần khoá/mở tài khoản nhân viên nghỉ việc.
     */
    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ----- Dữ liệu cho dropdown (không giới hạn theo phòng ban như CommonDAO) -----

    public List<Branch> getAllBranchesFull() {
        List<Branch> list = new ArrayList<>();
        String sql = "SELECT id, code, name FROM branches WHERE status = 'ACTIVE'";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Branch(rs.getInt("id"), rs.getString("code"), rs.getString("name")));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Department> getAllDepartmentsFull() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT id, name FROM departments ORDER BY name";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Department(rs.getInt("id"), rs.getString("name")));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public List<Position> getAllPositionsFull() {
        List<Position> list = new ArrayList<>();
        String sql = "SELECT id, title, department_id FROM positions ORDER BY title";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Position(rs.getInt("id"), rs.getString("title"), rs.getInt("department_id")));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    private Employee mapRow(ResultSet rs) throws Exception {
        Employee e = new Employee();
        e.setUserId(rs.getInt("user_id"));
        e.setUsername(rs.getString("username"));
        e.setEmail(rs.getString("email"));
        e.setUserStatus(rs.getString("user_status"));
        e.setRoleId(rs.getInt("role_id"));
        e.setRoleName(rs.getString("role_name"));

        e.setFullName(rs.getString("full_name"));
        e.setPhone(rs.getString("phone"));
        e.setIdentityCard(rs.getString("identity_card"));

        e.setHomeBranchId(rs.getInt("home_branch_id"));
        e.setBranchName(rs.getString("branch_name"));

        e.setPositionId(rs.getInt("position_id"));
        e.setPositionTitle(rs.getString("position_title"));

        e.setDepartmentId(rs.getInt("department_id"));
        e.setDepartmentName(rs.getString("department_name"));

        e.setEmployeeType(rs.getString("employee_type"));
        return e;
    }
}
