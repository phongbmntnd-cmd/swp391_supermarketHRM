package dao;

import context.DBContext;
import model.Role;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng roles
 */
public class RoleDAO {

    /**
     * Lấy Role theo ID
     * @param roleId Role ID
     * @return Role object hoặc null nếu không tìm thấy
     */
    public Role getRoleById(int roleId) {
        String sql = "SELECT id, name, description FROM roles WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role role = new Role();
                    role.setId(rs.getInt("id"));
                    role.setName(rs.getString("name"));
                    role.setDescription(rs.getString("description"));
                    return role;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy danh sách tất cả các Role
     * @return Danh sách Role
     */
    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT id, name, description FROM roles ORDER BY id";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Role role = new Role();
                role.setId(rs.getInt("id"));
                role.setName(rs.getString("name"));
                role.setDescription(rs.getString("description"));
                list.add(role);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy Role theo tên
     * @param roleName Tên role
     * @return Role object hoặc null nếu không tìm thấy
     */
    public Role getRoleByName(String roleName) {
        String sql = "SELECT id, name, description FROM roles WHERE name = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role role = new Role();
                    role.setId(rs.getInt("id"));
                    role.setName(rs.getString("name"));
                    role.setDescription(rs.getString("description"));
                    return role;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy các Role mà Store Manager có thể thao tác (Employee = 5)
     * @return Danh sách Role
     */
    public List<Role> getRolesForStoreManager() {
        List<Role> list = new ArrayList<>();
        // Store Manager chỉ thao tác với Employee
        String sql = "SELECT id, name, description FROM roles WHERE id = 5";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Role role = new Role();
                role.setId(rs.getInt("id"));
                role.setName(rs.getString("name"));
                role.setDescription(rs.getString("description"));
                list.add(role);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
