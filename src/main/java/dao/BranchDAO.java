
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author nguyn
 */
import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Branch;
import model.User; // Đảm bảo bạn có Model User chứa các thuộc tính tương ứng

public class BranchDAO {

    // 1. Hiển thị danh sách Cơ sở
    public List<Branch> getAllBranches() {
        List<Branch> list = new ArrayList<>();
        String sql = "SELECT * FROM branches ORDER BY id DESC";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Branch b = new Branch();
                b.setId(rs.getInt("id"));
                b.setCode(rs.getString("code"));
                b.setName(rs.getString("name"));
                b.setAddress(rs.getString("address"));
                b.setStatus(rs.getString("status"));
                b.setStoreManagerId(rs.getInt("store_manager_id"));
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Thêm mới Cơ sở
    public boolean insertBranch(String code, String name, String address) {
        String sql = "INSERT INTO branches (code, name, address, status) VALUES (?, ?, ?, 'ACTIVE')";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setString(2, name);
            ps.setString(3, address);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Gán Quản lý cho Cơ sở
    public boolean assignStoreManager(int branchId, int managerId) {
        String sql = "UPDATE branches SET store_manager_id = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            ps.setInt(2, branchId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Lấy danh sách nhân viên theo Cơ sở
    public List<User> getEmployeesByBranch(int branchId) {
        List<User> list = new ArrayList<>();
        // JOIN bảng users, employee_profiles và positions để lấy thông tin chi tiết
        String sql = "SELECT u.id, u.email, ep.full_name, ep.phone, p.title AS position_name "
                + "FROM users u "
                + "JOIN employee_profiles ep ON u.id = ep.user_id "
                + "JOIN positions p ON ep.position_id = p.id "
                + "WHERE ep.home_branch_id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setEmail(rs.getString("email"));
                    u.setFullName(rs.getString("full_name"));
                    u.setPhone(rs.getString("phone"));
                    u.setPositionName(rs.getString("position_name")); // Thêm thuộc tính này vào model User nếu chưa có
                    list.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy danh sách các user có thể làm quản lý (Ví dụ role_id tương ứng với Store Manager hoặc nhân viên cấp cao)
    public List<User> getAvailableManagers() {
        List<User> list = new ArrayList<>();
        // Lọc các user có role phù hợp làm quản lý (giả sử role_id = 3 là Store Manager hoặc tùy theo DB của bạn)
        String sql = "SELECT u.id, ep.full_name FROM users u JOIN employee_profiles ep ON u.id = ep.user_id WHERE u.role_id = 3";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setFullName(rs.getString("full_name"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Xóa (hoặc chuyển trạng thái cơ sở thành INACTIVE)
    public boolean deleteBranch(int branchId) {
        String sql = "UPDATE branches SET status = 'INACTIVE' WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Đổi trạng thái cơ sở (ACTIVE <-> INACTIVE)
    public boolean toggleBranchStatus(int branchId, String currentStatus) {
        String newStatus = "ACTIVE".equals(currentStatus) ? "INACTIVE" : "ACTIVE";
        String sql = "UPDATE branches SET status = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, branchId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật thông tin Cơ sở
    public boolean updateBranch(int id, String code, String name, String address) {
        String sql = "UPDATE branches SET code = ?, name = ?, address = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setString(2, name);
            ps.setString(3, address);
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
