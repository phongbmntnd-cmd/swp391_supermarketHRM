package dao;

import context.DBContext;
import model.Position;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng positions - hỗ trợ CRUD đầy đủ
 */
public class PositionDAO {

    public List<Position> getAllPositionsFull() {
        List<Position> list = new ArrayList<>();
        String sql = "SELECT id, title, department_id FROM positions ORDER BY id";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Position(rs.getInt("id"), rs.getString("title"), rs.getInt("department_id")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Position getPositionById(int id) {
        String sql = "SELECT id, title, department_id FROM positions WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Position(rs.getInt("id"), rs.getString("title"), rs.getInt("department_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public String getPositionTitle(int id) {
        Position p = getPositionById(id);
        return p != null ? p.getTitle() : null;
    }

    public boolean existsByTitle(String title) {
        String sql = "SELECT COUNT(*) FROM positions WHERE title = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean existsByTitleOtherThan(String title, int id) {
        String sql = "SELECT COUNT(*) FROM positions WHERE title = ? AND id <> ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setInt(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasPositionsInDepartment(int departmentId) {
        String sql = "SELECT COUNT(*) FROM positions WHERE department_id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean createPosition(String title, int departmentId) {
        String sql = "INSERT INTO positions (title, department_id) VALUES (?, ?)";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setInt(2, departmentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePosition(int id, String title, int departmentId) {
        String sql = "UPDATE positions SET title = ?, department_id = ? WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setInt(2, departmentId);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deletePosition(int id) {
        String sql = "DELETE FROM positions WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
