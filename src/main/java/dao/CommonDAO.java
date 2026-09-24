package dao;
/**
 * Chứa các hàm đọc dữ liệu danh mục tĩnh (Lấy danh sách các Chi nhánh, Phòng ban, Vị trí công việc) dùng chung cho toàn bộ hệ thống.
 */
import context.DBContext;
import model.Branch;
import model.Department;
import model.Position;
import model.Role;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CommonDAO {

    public List<Branch> getAllBranches() {
        List<Branch> list = new ArrayList<>();
        String sql = "SELECT id, code, name FROM branches WHERE status = 'ACTIVE'";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Branch b = new Branch();
                b.setId(rs.getInt("id"));
                b.setCode(rs.getString("code"));
                b.setName(rs.getString("name"));
                list.add(b);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Lọc chỉ lấy các Phòng ban thuộc khối Cửa hàng (ID = 4 và 5)
    public List<Department> getAllDepartments() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT id, name FROM departments WHERE id IN (4, 5)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Department(rs.getInt("id"), rs.getString("name")));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Lọc chỉ lấy các Vị trí thuộc khối Cửa hàng (department_id = 4 hoặc 5)
    public List<Position> getAllPositions() {
        List<Position> list = new ArrayList<>();
        String sql = "SELECT id, title, department_id FROM positions WHERE department_id IN (4, 5)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Position(rs.getInt("id"), rs.getString("title"), rs.getInt("department_id")));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // HR chỉ tạo tài khoản cho Store Manager (id = 4) và Employee (id = 5)
    public List<Role> getHRManageableRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT id, name, description FROM roles WHERE id IN (4, 5)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Role(rs.getInt("id"), rs.getString("name"), rs.getString("description")));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}