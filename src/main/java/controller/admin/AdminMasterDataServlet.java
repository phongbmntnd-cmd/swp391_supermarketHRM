package controller.admin;

import controller.base.BaseServlet;
import dao.AuditLogDAO;
import dao.DepartmentDAO;
import dao.PositionDAO;
import dao.RoleDAO;
import model.AuditLog;
import model.Department;
import model.Position;
import model.Role;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Servlet quản lý Master Data: Departments, Positions, Roles
 * Chỉ System Admin (role_id = 1) được phép truy cập.
 */
@WebServlet(name = "AdminMasterDataServlet", urlPatterns = {"/admin/master-data"})
public class AdminMasterDataServlet extends BaseServlet {

    private final DepartmentDAO deptDAO = new DepartmentDAO();
    private final PositionDAO positionDAO = new PositionDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    // =========================================================
    //  GET: Hiển thị trang quản lý Master Data
    // =========================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Auth check
        if (!hasRole(request, ROLE_ADMIN)) {
            if (getCurrentUser(request) == null) {
                redirectToLogin(request, response);
            } else {
                sendForbidden(request, response, "Bạn không có quyền truy cập trang này!");
            }
            return;
        }

        // 2. Load all data for the 3 tabs
        List<Department> departments = deptDAO.getAllDepartmentsFull();
        List<Position> positions = positionDAO.getAllPositionsFull();
        List<Role> roles = roleDAO.getAllRoles();

        // Load department name for each position (for display)
        List<Department> allDepts = deptDAO.getAllDepartmentsFull();

        request.setAttribute("departments", departments);
        request.setAttribute("positions", positions);
        request.setAttribute("roles", roles);
        request.setAttribute("allDepts", allDepts);

        // Messages
        request.setAttribute("successMessage", getAndClearSuccessMessage(request));
        request.setAttribute("errorMessage", getAndClearErrorMessage(request));

        request.getRequestDispatcher("/WEB-INF/views/admin/master-data.jsp").forward(request, response);
    }

    // =========================================================
    //  POST: Xử lý CRUD cho Departments, Positions, Roles
    // =========================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Auth check
        if (!hasRole(request, ROLE_ADMIN)) {
            if (getCurrentUser(request) == null) {
                redirectToLogin(request, response);
            } else {
                sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            }
            return;
        }

        String action = getStringParameter(request, "action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }

        switch (action) {
            // ---- DEPARTMENTS ----
            case "createDepartment":
                handleCreateDepartment(request, response);
                break;
            case "updateDepartment":
                handleUpdateDepartment(request, response);
                break;
            case "deleteDepartment":
                handleDeleteDepartment(request, response);
                break;

            // ---- POSITIONS ----
            case "createPosition":
                handleCreatePosition(request, response);
                break;
            case "updatePosition":
                handleUpdatePosition(request, response);
                break;
            case "deletePosition":
                handleDeletePosition(request, response);
                break;

            // ---- ROLES ----
            case "createRole":
                handleCreateRole(request, response);
                break;
            case "updateRole":
                handleUpdateRole(request, response);
                break;
            case "deleteRole":
                handleDeleteRole(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/admin/master-data");
                break;
        }
    }

    // =========================================================
    //  HANDLERS: DEPARTMENTS
    // =========================================================
    private void handleCreateDepartment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String name = getStringParameter(request, "name");
        if (name == null || name.trim().isEmpty()) {
            setErrorMessage(request, "Tên phòng ban không được để trống!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        name = name.trim();
        if (deptDAO.existsByName(name)) {
            setErrorMessage(request, "Phòng ban '" + name + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        boolean ok = deptDAO.createDepartment(name);
        if (ok) {
            setSuccessMessage(request, "Đã thêm phòng ban mới: " + name);
            writeMasterLog(request, AuditLog.ACTION_CREATE_DEPARTMENT,
                    "Tạo phòng ban mới: '" + name + "'");
        } else {
            setErrorMessage(request, "Không thể thêm phòng ban. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    private void handleUpdateDepartment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = getIntParameter(request, "id", -1);
        String name = getStringParameter(request, "name");
        if (id <= 0 || name == null || name.trim().isEmpty()) {
            setErrorMessage(request, "Dữ liệu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        name = name.trim();
        // Check duplicate (excluding current id)
        if (deptDAO.existsByNameOtherThan(name, id)) {
            setErrorMessage(request, "Phòng ban '" + name + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        boolean ok = deptDAO.updateDepartment(id, name);
        if (ok) {
            setSuccessMessage(request, "Đã cập nhật phòng ban: " + name);
            writeMasterLog(request, AuditLog.ACTION_UPDATE_DEPARTMENT,
                    "Cập nhật phòng ban id=" + id + " thành '" + name + "'");
        } else {
            setErrorMessage(request, "Không thể cập nhật phòng ban. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    private void handleDeleteDepartment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = getIntParameter(request, "id", -1);
        if (id <= 0) {
            setErrorMessage(request, "ID phòng ban không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        // Cannot delete if has positions
        if (positionDAO.hasPositionsInDepartment(id)) {
            setErrorMessage(request, "Không thể xóa! Phòng ban này đang có vị trí. Hãy xóa các vị trí trước.");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        String deptName = deptDAO.getDepartmentName(id);
        boolean ok = deptDAO.deleteDepartment(id);
        if (ok) {
            setSuccessMessage(request, "Đã xóa phòng ban: " + (deptName != null ? deptName : "#" + id));
            writeMasterLog(request, AuditLog.ACTION_DELETE_DEPARTMENT,
                    "Xóa phòng ban '" + deptName + "' (id=" + id + ")");
        } else {
            setErrorMessage(request, "Không thể xóa phòng ban. Có thể đang có dữ liệu liên quan.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    // =========================================================
    //  HANDLERS: POSITIONS
    // =========================================================
    private void handleCreatePosition(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String title = getStringParameter(request, "title");
        int deptId = getIntParameter(request, "departmentId", -1);
        if (title == null || title.trim().isEmpty()) {
            setErrorMessage(request, "Tên vị trí không được để trống!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        if (deptId <= 0) {
            setErrorMessage(request, "Vui lòng chọn phòng ban!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        title = title.trim();
        if (positionDAO.existsByTitle(title)) {
            setErrorMessage(request, "Vị trí '" + title + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        boolean ok = positionDAO.createPosition(title, deptId);
        if (ok) {
            setSuccessMessage(request, "Đã thêm vị trí mới: " + title);
            writeMasterLog(request, AuditLog.ACTION_CREATE_POSITION,
                    "Tạo vị trí mới: '" + title + "' thuộc phòng ban id=" + deptId);
        } else {
            setErrorMessage(request, "Không thể thêm vị trí. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    private void handleUpdatePosition(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = getIntParameter(request, "id", -1);
        String title = getStringParameter(request, "title");
        int deptId = getIntParameter(request, "departmentId", -1);
        if (id <= 0 || title == null || title.trim().isEmpty() || deptId <= 0) {
            setErrorMessage(request, "Dữ liệu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        title = title.trim();
        if (positionDAO.existsByTitleOtherThan(title, id)) {
            setErrorMessage(request, "Vị trí '" + title + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        boolean ok = positionDAO.updatePosition(id, title, deptId);
        if (ok) {
            setSuccessMessage(request, "Đã cập nhật vị trí: " + title);
            writeMasterLog(request, AuditLog.ACTION_UPDATE_POSITION,
                    "Cập nhật vị trí id=" + id + " thành '" + title + "', dept=" + deptId);
        } else {
            setErrorMessage(request, "Không thể cập nhật vị trí. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    private void handleDeletePosition(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = getIntParameter(request, "id", -1);
        if (id <= 0) {
            setErrorMessage(request, "ID vị trí không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        String posTitle = positionDAO.getPositionTitle(id);
        boolean ok = positionDAO.deletePosition(id);
        if (ok) {
            setSuccessMessage(request, "Đã xóa vị trí: " + (posTitle != null ? posTitle : "#" + id));
            writeMasterLog(request, AuditLog.ACTION_DELETE_POSITION,
                    "Xóa vị trí '" + posTitle + "' (id=" + id + ")");
        } else {
            setErrorMessage(request, "Không thể xóa vị trí. Có thể đang có nhân viên giữ vị trí này.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    // =========================================================
    //  HANDLERS: ROLES
    // =========================================================
    private void handleCreateRole(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String name = getStringParameter(request, "name");
        String description = getStringParameter(request, "description");
        if (name == null || name.trim().isEmpty()) {
            setErrorMessage(request, "Tên vai trò không được để trống!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        name = name.trim();
        if (description != null) description = description.trim();
        if (roleDAO.existsByName(name)) {
            setErrorMessage(request, "Vai trò '" + name + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        boolean ok = roleDAO.createRole(name, description);
        if (ok) {
            setSuccessMessage(request, "Đã thêm vai trò mới: " + name);
            writeMasterLog(request, AuditLog.ACTION_CREATE_ROLE,
                    "Tạo vai trò mới: '" + name + "' - " + (description != null ? description : ""));
        } else {
            setErrorMessage(request, "Không thể thêm vai trò. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    private void handleUpdateRole(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = getIntParameter(request, "id", -1);
        String name = getStringParameter(request, "name");
        String description = getStringParameter(request, "description");
        if (id <= 0 || name == null || name.trim().isEmpty()) {
            setErrorMessage(request, "Dữ liệu không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        name = name.trim();
        if (description != null) description = description.trim();
        if (roleDAO.existsByNameOtherThan(name, id)) {
            setErrorMessage(request, "Vai trò '" + name + "' đã tồn tại!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        boolean ok = roleDAO.updateRole(id, name, description);
        if (ok) {
            setSuccessMessage(request, "Đã cập nhật vai trò: " + name);
            writeMasterLog(request, AuditLog.ACTION_UPDATE_ROLE,
                    "Cập nhật vai trò id=" + id + " thành '" + name + "'");
        } else {
            setErrorMessage(request, "Không thể cập nhật vai trò. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    private void handleDeleteRole(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = getIntParameter(request, "id", -1);
        if (id <= 0) {
            setErrorMessage(request, "ID vai trò không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        // Prevent deleting core roles (1-5)
        if (id >= 1 && id <= 5) {
            setErrorMessage(request, "Không thể xóa vai trò hệ thống mặc định!");
            response.sendRedirect(request.getContextPath() + "/admin/master-data");
            return;
        }
        String roleName = roleDAO.getRoleName(id);
        boolean ok = roleDAO.deleteRole(id);
        if (ok) {
            setSuccessMessage(request, "Đã xóa vai trò: " + (roleName != null ? roleName : "#" + id));
            try {
                String ip = getClientIp(request);
                String desc = "Admin '" + getCurrentUser(request).getUsername() + "' xóa vai trò '"
                            + roleName + "' (id=" + id + ")";
                auditLogDAO.log(AuditLog.ACTION_DELETE_ROLE, getCurrentUser(request).getId(), null, desc, ip);
            } catch (Exception e) { e.printStackTrace(); }
        } else {
            setErrorMessage(request, "Không thể xóa vai trò. Có thể đang có tài khoản sử dụng vai trò này.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/master-data");
    }

    // =========================================================
    //  AUDIT LOG cho các thao tác CRUD Master Data
    // =========================================================
    private void writeMasterLog(HttpServletRequest request, String action, String detail) {
        try {
            User u = getCurrentUser(request);
            if (u == null) return;
            String ip = getClientIp(request);
            auditLogDAO.log(action, u.getId(), null, detail, ip);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Lấy IP client (hỗ trợ X-Forwarded-For) */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
            int comma = ip.indexOf(',');
            return comma > 0 ? ip.substring(0, comma).trim() : ip.trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) return ip;
        return request.getRemoteAddr();
    }
}
