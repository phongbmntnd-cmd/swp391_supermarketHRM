package dao;

import context.DBContext;
import model.EmployeeProfile;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * DAO cho bảng employee_profiles và lấy danh sách nhân viên
 */
public class EmployeeProfileDAO {

    // Các cột được phép sort (whitelist để tránh SQL injection)
    private static final List<String> ALLOWED_SORT_COLUMNS = List.of(
        "full_name", "username", "email", "phone", 
        "position_name", "department_name", "employee_type", "status", 
        "created_at"
    );

    /**
     * Lấy EmployeeProfile theo User ID
     * @param userId User ID
     * @return EmployeeProfile object hoặc null nếu không tìm thấy
     */
    public EmployeeProfile getProfileByUserId(int userId) {
        String sql = "SELECT ep.user_id, ep.full_name, ep.phone, ep.identity_card, "
                   + "ep.home_branch_id, ep.position_id, ep.department_id, ep.employee_type, ep.created_at, "
                   + "p.title AS position_name, d.name AS department_name, "
                   + "u.username, u.email, u.status, u.role_id, r.name AS role_name "
                   + "FROM employee_profiles ep "
                   + "JOIN users u ON ep.user_id = u.id "
                   + "JOIN roles r ON u.role_id = r.id "
                   + "LEFT JOIN positions p ON ep.position_id = p.id "
                   + "LEFT JOIN departments d ON ep.department_id = d.id "
                   + "WHERE ep.user_id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProfile(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy danh sách nhân viên thuộc branch của Store Manager với Search/Filter/Sort/Pagination
     * 
     * @param branchId Branch ID của Store Manager (BẮT BUỘC - xác định từ Store Manager)
     * @param search Từ khóa tìm kiếm (theo full_name, username, email, phone)
     * @param positionId Lọc theo position ID (-1 = không lọc)
     * @param departmentId Lọc theo department ID (-1 = không lọc)
     * @param employeeType Lọc theo employee_type (null = không lọc)
     * @param status Lọc theo user status (null = không lọc)
     * @param sortColumn Cột sắp xếp (whitelist)
     * @param sortDirection ASC hoặc DESC
     * @param offset Bắt đầu từ record nào
     * @param limit Số record mỗi trang
     * @return Danh sách EmployeeProfile
     */
    public List<EmployeeProfile> getEmployeesPaginated(
            int branchId, String search, Integer positionId, 
            Integer departmentId, String employeeType, String status,
            String sortColumn, String sortDirection,
            int offset, int limit) {
        
        List<EmployeeProfile> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        
        // Base query (FIX: removed ep.created_at - column doesn't exist)
        sql.append("SELECT ep.user_id, ep.full_name, ep.phone, ep.identity_card, ");
        sql.append("ep.home_branch_id, ep.position_id, ep.department_id, ep.employee_type, ");
        sql.append("p.title AS position_name, d.name AS department_name, ");
        sql.append("u.username, u.email, u.status, u.role_id, r.name AS role_name ");
        sql.append("FROM employee_profiles ep ");
        sql.append("JOIN users u ON ep.user_id = u.id ");
        sql.append("JOIN roles r ON u.role_id = r.id ");
        sql.append("LEFT JOIN positions p ON ep.position_id = p.id ");
        sql.append("LEFT JOIN departments d ON ep.department_id = d.id ");
        sql.append("WHERE ep.home_branch_id = ? AND u.role_id = 5 ");  // Chỉ Employee
        
        List<Object> params = new ArrayList<>();
        params.add(branchId);
        
        // Search
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (ep.full_name LIKE ? OR u.username LIKE ? OR u.email LIKE ? OR ep.phone LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        // Position filter
        if (positionId != null && positionId > 0) {
            sql.append("AND ep.position_id = ? ");
            params.add(positionId);
        }
        
        // Department filter
        if (departmentId != null && departmentId > 0) {
            sql.append("AND ep.department_id = ? ");
            params.add(departmentId);
        }
        
        // Employee type filter (chuẩn hóa cả 2 dạng: FULL_TIME, Full-time)
        if (employeeType != null && !employeeType.trim().isEmpty()) {
            String normalizedType = normalizeForQuery(employeeType.trim());
            sql.append("AND UPPER(REPLACE(REPLACE(ep.employee_type, '-', '_'), ' ', '_')) = ? ");
            params.add(normalizedType);
        }
        
        // Status filter
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND u.status = ? ");
            params.add(status.trim());
        }
        
        // Sort - whitelist validation
        String validatedSortColumn = validateSortColumn(sortColumn);
        String validatedSortDirection = validateSortDirection(sortDirection);
        sql.append("ORDER BY ").append(validatedSortColumn).append(" ").append(validatedSortDirection);
        
        // Pagination
        sql.append(" LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProfile(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm tổng số nhân viên với các điều kiện lọc
     * 
     * @param branchId Branch ID
     * @param search Từ khóa tìm kiếm
     * @param positionId Lọc theo position ID
     * @param departmentId Lọc theo department ID
     * @param employeeType Lọc theo employee type
     * @param status Lọc theo status
     * @return Tổng số record
     */
    public int countEmployees(
            int branchId, String search, Integer positionId,
            Integer departmentId, String employeeType, String status) {
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM employee_profiles ep ");
        sql.append("JOIN users u ON ep.user_id = u.id ");
        sql.append("WHERE ep.home_branch_id = ? AND u.role_id = 5 ");
        
        List<Object> params = new ArrayList<>();
        params.add(branchId);
        
        // Search
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (ep.full_name LIKE ? OR u.username LIKE ? OR u.email LIKE ? OR ep.phone LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        // Position filter
        if (positionId != null && positionId > 0) {
            sql.append("AND ep.position_id = ? ");
            params.add(positionId);
        }
        
        // Department filter
        if (departmentId != null && departmentId > 0) {
            sql.append("AND ep.department_id = ? ");
            params.add(departmentId);
        }
        
        // Employee type filter (chuẩn hóa cả 2 dạng: FULL_TIME, Full-time)
        if (employeeType != null && !employeeType.trim().isEmpty()) {
            String normalizedType = normalizeForQuery(employeeType.trim());
            sql.append("AND UPPER(REPLACE(REPLACE(ep.employee_type, '-', '_'), ' ', '_')) = ? ");
            params.add(normalizedType);
        }
        
        // Status filter
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND u.status = ? ");
            params.add(status.trim());
        }
        
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Validate sort column - chỉ cho phép các cột trong whitelist
     */
    private String validateSortColumn(String sortColumn) {
        if (sortColumn == null || sortColumn.trim().isEmpty()) {
            return "ep.full_name"; // Default
        }
        
        String col = sortColumn.toLowerCase().trim();
        
        // Mapping tên cột database
        if (col.equals("full_name") || col.equals("name")) {
            return "ep.full_name";
        } else if (col.equals("username")) {
            return "u.username";
        } else if (col.equals("email")) {
            return "u.email";
        } else if (col.equals("phone")) {
            return "ep.phone";
        } else if (col.equals("position") || col.equals("position_name")) {
            return "p.title";
        } else if (col.equals("department") || col.equals("department_name")) {
            return "d.name";
        } else if (col.equals("employee_type") || col.equals("type")) {
            return "ep.employee_type";
        } else if (col.equals("status")) {
            return "u.status";
        } else if (col.equals("created_at") || col.equals("created")) {
            return "u.created_at";  // Dùng users.created_at vì employee_profiles không có column này
        } else {
            return "ep.full_name"; // Default fallback
        }
    }

    /**
     * Validate sort direction - chỉ cho phép ASC hoặc DESC
     */
    private String validateSortDirection(String sortDirection) {
        if ("DESC".equalsIgnoreCase(sortDirection)) {
            return "DESC";
        }
        return "ASC"; // Default
    }

    /**
     * Map ResultSet to EmployeeProfile
     */
    private EmployeeProfile mapResultSetToProfile(ResultSet rs) throws Exception {
        EmployeeProfile profile = new EmployeeProfile();
        profile.setUserId(rs.getInt("user_id"));
        profile.setFullName(rs.getString("full_name"));
        profile.setPhone(rs.getString("phone"));
        profile.setIdentityCard(rs.getString("identity_card"));
        profile.setHomeBranchId(rs.getInt("home_branch_id"));
        profile.setPositionId(rs.getInt("position_id"));
        profile.setDepartmentId(rs.getInt("department_id"));
        profile.setEmployeeType(rs.getString("employee_type"));
        
        // Từ JOIN
        profile.setPositionName(rs.getString("position_name"));
        profile.setDepartmentName(rs.getString("department_name"));
        
        // Từ users
        profile.setUsername(rs.getString("username"));
        profile.setEmail(rs.getString("email"));
        profile.setStatus(rs.getString("status"));
        profile.setRoleId(rs.getInt("role_id"));
        profile.setRoleName(rs.getString("role_name"));
        
        return profile;
    }

    /**
     * Lấy tất cả positions (dùng cho filter dropdown)
     * @return Danh sách Position
     */
    public List<model.Position> getAllPositions() {
        List<model.Position> list = new ArrayList<>();
        String sql = "SELECT id, title, department_id FROM positions WHERE department_id IN (4, 5) ORDER BY title";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                model.Position p = new model.Position();
                p.setId(rs.getInt("id"));
                p.setTitle(rs.getString("title"));
                p.setDepartmentId(rs.getInt("department_id"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả departments (dùng cho filter dropdown)
     * @return Danh sách Department
     */
    public List<model.Department> getAllDepartments() {
        List<model.Department> list = new ArrayList<>();
        String sql = "SELECT id, name FROM departments WHERE id IN (4, 5) ORDER BY name";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                model.Department d = new model.Department();
                d.setId(rs.getInt("id"));
                d.setName(rs.getString("name"));
                list.add(d);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy các loại employee type có trong database (đã chuẩn hóa)
     * @return Danh sách employee types (loại bỏ trùng lặp không phân biệt hoa/thường)
     */
    public List<String> getDistinctEmployeeTypes() {
        Set<String> uniqueTypes = new LinkedHashSet<>();
        String sql = "SELECT DISTINCT employee_type FROM employee_profiles WHERE employee_type IS NOT NULL AND employee_type != '' ORDER BY employee_type";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String type = rs.getString("employee_type").trim();
                // Chuẩn hóa: FULL_TIME -> Full-time, Full_Time -> Full-time
                String normalized = normalizeEmployeeType(type);
                if (!normalized.isEmpty()) {
                    uniqueTypes.add(normalized);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new ArrayList<>(uniqueTypes);
    }
    
    /**
     * Chuẩn hóa employee type về dạng "Full-time", "Part-time"
     */
    private String normalizeEmployeeType(String type) {
        if (type == null) return "";
        String upper = type.toUpperCase().replace("-", "_").replace(" ", "_");
        switch (upper) {
            case "FULL_TIME":
            case "FULLTIME":
                return "Full-time";
            case "PART_TIME":
            case "PARTTIME":
                return "Part-time";
            case "CONTRACT":
                return "Contract";
            case "INTERN":
                return "Intern";
            case "SEASONAL":
                return "Seasonal";
            default:
                // Giữ nguyên nếu không khớp pattern, viết hoa chữ đầu
                if (type.length() > 0) {
                    return type.substring(0, 1).toUpperCase() + type.substring(1).toLowerCase();
                }
                return type;
        }
    }
    
    /**
     * Chuẩn hóa employee type cho query SQL (chuyển về dạng FULL_TIME)
     * @param type Employee type cần chuẩn hóa
     * @return Chuỗi chuẩn hóa cho SQL (VD: "Full-time" -> "FULL_TIME")
     */
    private String normalizeForQuery(String type) {
        if (type == null) return "";
        String upper = type.toUpperCase().replace("-", "_").replace(" ", "_");
        switch (upper) {
            case "FULL_TIME":
            case "FULLTIME":
                return "FULL_TIME";
            case "PART_TIME":
            case "PARTTIME":
                return "PART_TIME";
            case "CONTRACT":
                return "CONTRACT";
            case "INTERN":
                return "INTERN";
            case "SEASONAL":
                return "SEASONAL";
            default:
                return upper;
        }
    }
}
