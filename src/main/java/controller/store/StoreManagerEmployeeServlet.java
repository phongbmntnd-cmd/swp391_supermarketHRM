package controller.store;

import controller.base.BaseServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.UserDAO;
import dao.BranchDAO;
import dao.EmployeeProfileDAO;
import dao.EmployeeLockDAO;
import dao.AuditLogDAO;
import dao.RoleDAO;
import model.User;
import model.EmployeeProfile;
import model.EmployeeLock;
import model.Branch;
import model.AuditLog;
import java.io.IOException;
import java.util.List;

/**
 * Servlet cho Store Manager - Employee Management
 * 
 * Implement đầy đủ:
 * 1. Xem danh sách nhân sự với Search/Filter/Sort/Pagination
 * 2. Emergency Lock nhân sự
 * 3. Emergency Unlock (luồng bổ sung của Lock)
 */
@WebServlet(urlPatterns = {"/store-manager/employees"})
public class StoreManagerEmployeeServlet extends BaseServlet {

    // DAO instances
    private final UserDAO userDAO = new UserDAO();
    private final BranchDAO branchDAO = new BranchDAO();
    private final EmployeeProfileDAO employeeProfileDAO = new EmployeeProfileDAO();
    private final EmployeeLockDAO employeeLockDAO = new EmployeeLockDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    // Các giá trị page size cho pagination
    private static final int[] PAGE_SIZES = {5, 10, 20, 50};
    private static final int DEFAULT_PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("===========================================");
        System.out.println(">>> StoreManagerEmployeeServlet.doGet() START");
        
        // 1. Kiểm tra đăng nhập
        User currentUser = getCurrentUser(request);
        System.out.println(">>> currentUser: " + currentUser);
        if (currentUser == null) {
            System.out.println(">>> ERROR: currentUser is NULL!");
            redirectToLogin(request, response);
            return;
        }
        
        System.out.println(">>> currentUser.getId(): " + currentUser.getId());
        System.out.println(">>> currentUser.getRoleId(): " + currentUser.getRoleId());
        System.out.println(">>> currentUser.getHomeBranchId(): " + currentUser.getHomeBranchId());

        // 2. Kiểm tra role = Store Manager (role_id = 4)
        if (currentUser.getRoleId() != ROLE_STORE_MANAGER) {
            System.out.println(">>> ERROR: Wrong role!");
            sendForbidden(request, response, "Bạn không có quyền truy cập trang này!");
            return;
        }

        // 3. Xác định branch của Store Manager - KHÔNG TIN branchId TỪ CLIENT
        int branchId = currentUser.getHomeBranchId();
        System.out.println(">>> branchId: " + branchId);
        if (branchId <= 0) {
            System.out.println(">>> ERROR: branchId <= 0!");
            sendInternalError(request, response, "Không xác định được cơ sở của bạn. Vui lòng liên hệ quản trị viên.");
            return;
        }

        // 4. Lấy branch info
        Branch branch = branchDAO.getBranchById(branchId);
        System.out.println(">>> branch: " + (branch != null ? branch.getName() : "NULL"));
        request.setAttribute("currentBranch", branch);

        // 5. Lấy các tham số filter từ request
        String search = getStringParameter(request, "search");
        Integer positionId = getIntParameter(request, "positionId", -1);
        if (positionId == -1) positionId = null;
        
        Integer departmentId = getIntParameter(request, "departmentId", -1);
        if (departmentId == -1) departmentId = null;
        
        String employeeType = getStringParameter(request, "employeeType");
        String status = getStringParameter(request, "status");
        String sortColumn = getStringParameter(request, "sort");
        String sortDirection = getStringParameter(request, "dir");
        int page = getIntParameter(request, "page", 1);
        int pageSize = getIntParameter(request, "size", DEFAULT_PAGE_SIZE);

        // Validate page
        if (page < 1) page = 1;
        
        // Validate page size
        boolean validPageSize = false;
        for (int ps : PAGE_SIZES) {
            if (ps == pageSize) {
                validPageSize = true;
                break;
            }
        }
        if (!validPageSize) pageSize = DEFAULT_PAGE_SIZE;

        // 6. Lấy dữ liệu từ DAO
        int offset = (page - 1) * pageSize;
        System.out.println(">>> Calling getEmployeesPaginated(branchId=" + branchId + ", page=" + page + ", pageSize=" + pageSize + ")");
        List<EmployeeProfile> employees = employeeProfileDAO.getEmployeesPaginated(
            branchId, search, positionId, departmentId, employeeType, status,
            sortColumn, sortDirection, offset, pageSize
        );
        int totalRecords = employeeProfileDAO.countEmployees(
            branchId, search, positionId, departmentId, employeeType, status
        );
        System.out.println(">>> employees.size(): " + employees.size());
        System.out.println(">>> totalRecords: " + totalRecords);

        // 7. Tính toán pagination
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages < 1) totalPages = 1;
        
        // Tính toán display range cho JSP (tránh EL gọi Math.min/max)
        int displayStart = (page - 1) * pageSize + 1;
        int displayEnd = Math.min(page * pageSize, totalRecords);
        if (totalRecords == 0) {
            displayStart = 0;
            displayEnd = 0;
        }
        
        // Tính pagination buttons range
        int pagerStart = Math.max(1, page - 2);
        int pagerEnd = Math.min(totalPages, page + 2);
        
        // 8. Đặt các thuộc tính cho JSP
        request.setAttribute("employees", employees);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("pageSizes", PAGE_SIZES);
        request.setAttribute("displayStart", displayStart);
        request.setAttribute("displayEnd", displayEnd);
        request.setAttribute("pagerStart", pagerStart);
        request.setAttribute("pagerEnd", pagerEnd);
        
        // Filter values
        request.setAttribute("search", search);
        request.setAttribute("positionId", positionId);
        request.setAttribute("departmentId", departmentId);
        request.setAttribute("employeeType", employeeType);
        request.setAttribute("status", status);
        request.setAttribute("sortColumn", sortColumn);
        request.setAttribute("sortDirection", sortDirection);
        
        // Dropdown data
        request.setAttribute("positions", employeeProfileDAO.getAllPositions());
        request.setAttribute("departments", employeeProfileDAO.getAllDepartments());
        request.setAttribute("employeeTypes", employeeProfileDAO.getDistinctEmployeeTypes());
        
        // =============================================
        // LẤY DANH SÁCH NHÂN VIÊN BỊ KHÓA
        // =============================================
        String lockedSearch = getStringParameter(request, "lockedSearch");
        int lockedPage = getIntParameter(request, "lockedPage", 1);
        int lockedPageSize = 5; // Mặc định 5 record mỗi trang
        
        if (lockedPage < 1) lockedPage = 1;
        
        int lockedOffset = (lockedPage - 1) * lockedPageSize;
        List<EmployeeLock> lockedEmployees = employeeLockDAO.getLockedEmployeesByBranch(
            branchId, lockedSearch, lockedOffset, lockedPageSize
        );
        int totalLockedRecords = employeeLockDAO.countLockedEmployeesByBranch(branchId, lockedSearch);
        int totalLockedPages = (int) Math.ceil((double) totalLockedRecords / lockedPageSize);
        if (totalLockedPages < 1) totalLockedPages = 1;
        
        // Tính pagination buttons range cho locked
        int lockedPagerStart = Math.max(1, lockedPage - 2);
        int lockedPagerEnd = Math.min(totalLockedPages, lockedPage + 2);
        
        request.setAttribute("lockedEmployees", lockedEmployees);
        request.setAttribute("totalLockedRecords", totalLockedRecords);
        request.setAttribute("totalLockedPages", totalLockedPages);
        request.setAttribute("currentLockedPage", lockedPage);
        request.setAttribute("lockedPageSize", lockedPageSize);
        request.setAttribute("lockedSearch", lockedSearch);
        request.setAttribute("lockedPagerStart", lockedPagerStart);
        request.setAttribute("lockedPagerEnd", lockedPagerEnd);
        
        // Messages
        request.setAttribute("successMessage", getAndClearSuccessMessage(request));
        request.setAttribute("errorMessage", getAndClearErrorMessage(request));

        // 9. Forward to view
        System.out.println(">>> Forwarding to JSP...");
        System.out.println("===========================================");
        request.getRequestDispatcher("/WEB-INF/views/store-manager/employees.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy action từ parameter
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        switch (action) {
            case "lock":
                handleLock(request, response);
                break;
            case "unlock":
                handleUnlock(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/store-manager/employees");
                break;
        }
    }

    /**
     * Xử lý Emergency Lock
     */
    private void handleLock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra đăng nhập và role
        User currentUser = getCurrentUser(request);
        if (currentUser == null || currentUser.getRoleId() != ROLE_STORE_MANAGER) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        // 2. Lấy target user ID từ request
        String targetUserIdStr = request.getParameter("userId");
        if (targetUserIdStr == null || targetUserIdStr.trim().isEmpty()) {
            setErrorMessage(request, "Không xác định được nhân viên cần khóa.");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        int targetUserId;
        try {
            targetUserId = Integer.parseInt(targetUserIdStr.trim());
        } catch (NumberFormatException e) {
            setErrorMessage(request, "ID nhân viên không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // 3. Lấy lý do lock (có thể null)
        String reason = getStringParameter(request, "reason");

        // ============================================
        // CÁC CHECKS BẢO MẬT
        // ============================================
        
        // CHECK 1: Không tự khóa chính mình (self-lock)
        if (targetUserId == currentUser.getId()) {
            setErrorMessage(request, "Bạn không thể tự khóa tài khoản của mình!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // CHECK 2: Lấy thông tin target user từ database
        User targetUser = userDAO.getUserById(targetUserId);
        if (targetUser == null) {
            setErrorMessage(request, "Không tìm thấy nhân viên!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // CHECK 3: Không lock Store Manager khác (role_id = 4)
        if (targetUser.getRoleId() == ROLE_STORE_MANAGER) {
            setErrorMessage(request, "Bạn không có quyền khóa tài khoản Quản lý Cửa hàng khác!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // CHECK 4: Chỉ lock Employee (role_id = 5)
        if (targetUser.getRoleId() != ROLE_EMPLOYEE) {
            setErrorMessage(request, "Chỉ có thể khóa tài khoản Nhân viên!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // CHECK 5: Kiểm tra Local Scope - KHÔNG TIN branchId từ client
        // Backend tự xác định branch từ current user
        int currentBranchId = currentUser.getHomeBranchId();
        int targetBranchId = userDAO.getUserBranchId(targetUserId);
        
        if (targetBranchId != currentBranchId) {
            setErrorMessage(request, "Bạn không có quyền khóa nhân viên không thuộc cơ sở bạn quản lý!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // CHECK 6: Kiểm tra target không bị lock rồi
        String targetStatus = userDAO.getUserStatus(targetUserId);
        if ("EMERGENCY_LOCKED".equals(targetStatus)) {
            setErrorMessage(request, "Nhân viên này đã bị khóa trước đó!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // ============================================
        // THỰC HIỆN LOCK VỚI TRANSACTION
        // ============================================
        
        String auditDescription = "Emergency Lock bởi Store Manager";
        if (reason != null && !reason.trim().isEmpty()) {
            auditDescription += ": " + reason;
        }
        
        boolean success = userDAO.updateUserStatusWithAudit(
            targetUserId,
            STATUS_EMERGENCY_LOCKED,
            AuditLog.ACTION_EMERGENCY_LOCK,
            currentUser.getId(),
            auditDescription
        );

        if (success) {
            // Cũng tạo lock record trong employee_locks nếu bảng tồn tại
            if (employeeLockDAO.isTableExists()) {
                employeeLockDAO.createLock(targetUserId, currentUser.getId(), reason);
            }
            setSuccessMessage(request, "Đã khóa tài khoản nhân viên \"" + targetUser.getFullName() + "\" thành công!");
        } else {
            setErrorMessage(request, "Không thể khóa tài khoản. Vui lòng thử lại!");
        }
        
        response.sendRedirect(request.getContextPath() + "/store-manager/employees");
    }

    /**
     * Xử lý Emergency Unlock
     */
    private void handleUnlock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Kiểm tra đăng nhập và role
        User currentUser = getCurrentUser(request);
        if (currentUser == null || currentUser.getRoleId() != ROLE_STORE_MANAGER) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        // 2. Lấy target user ID từ request
        String targetUserIdStr = request.getParameter("userId");
        if (targetUserIdStr == null || targetUserIdStr.trim().isEmpty()) {
            setErrorMessage(request, "Không xác định được nhân viên cần mở khóa.");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        int targetUserId;
        try {
            targetUserId = Integer.parseInt(targetUserIdStr.trim());
        } catch (NumberFormatException e) {
            setErrorMessage(request, "ID nhân viên không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // ============================================
        // CÁC CHECKS BẢO MẬT
        // ============================================
        
        // CHECK 1: Kiểm tra target user tồn tại
        User targetUser = userDAO.getUserById(targetUserId);
        if (targetUser == null) {
            setErrorMessage(request, "Không tìm thấy nhân viên!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // CHECK 2: Kiểm tra Local Scope - KHÔNG TIN branchId từ client
        int currentBranchId = currentUser.getHomeBranchId();
        int targetBranchId = userDAO.getUserBranchId(targetUserId);
        if (targetBranchId != currentBranchId) {
            setErrorMessage(request, "Bạn không có quyền mở khóa nhân viên không thuộc cơ sở bạn quản lý!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // CHECK 3: Kiểm tra target đang bị lock
        String targetStatus = userDAO.getUserStatus(targetUserId);
        if (!"EMERGENCY_LOCKED".equals(targetStatus)) {
            setErrorMessage(request, "Nhân viên này không bị khóa!");
            response.sendRedirect(request.getContextPath() + "/store-manager/employees");
            return;
        }

        // ============================================
        // THỰC HIỆN UNLOCK VỚI TRANSACTION
        // ============================================
        
        String auditDescription = "Emergency Unlock bởi Store Manager";
        
        boolean success = userDAO.updateUserStatusWithAudit(
            targetUserId,
            STATUS_ACTIVE,
            AuditLog.ACTION_EMERGENCY_UNLOCK,
            currentUser.getId(),
            auditDescription
        );

        if (success) {
            // Cập nhật lock record trong employee_locks nếu bảng tồn tại
            if (employeeLockDAO.isTableExists()) {
                employeeLockDAO.unlock(targetUserId, currentUser.getId());
            }
            setSuccessMessage(request, "Đã mở khóa tài khoản nhân viên \"" + targetUser.getFullName() + "\" thành công!");
        } else {
            setErrorMessage(request, "Không thể mở khóa tài khoản. Vui lòng thử lại!");
        }
        
        response.sendRedirect(request.getContextPath() + "/store-manager/employees");
    }
}
