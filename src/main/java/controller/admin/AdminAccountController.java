package controller.admin;

import controller.base.BaseServlet;
import dao.AuditLogDAO;
import dao.BranchDAO;
import dao.EmployeeLockDAO;
import dao.RoleDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.AuditLog;
import model.Branch;
import model.EmployeeLock;
import model.Role;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminAccountController", urlPatterns = {"/admin/accounts"})
public class AdminAccountController extends BaseServlet {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private final BranchDAO branchDAO = new BranchDAO();
    private final EmployeeLockDAO employeeLockDAO = new EmployeeLockDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    private static final int[] PAGE_SIZES = {5, 10, 20, 50};
    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final int DEFAULT_LOCKED_PAGE_SIZE = 5;

    // =========================================================
    //  GET: Hiển thị danh sách tài khoản
    // =========================================================
    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
        // 1. Auth
    User currentUser = getCurrentUser(request);
    if (currentUser == null) {
        redirectToLogin(request, response);
        return;
    }
    if (currentUser.getRoleId() != ROLE_ADMIN) {
        sendForbidden(request, response, "Bạn không có quyền truy cập trang quản lý tài khoản!");
        return;
    }

        // 2. Parse filter params
        String search        = getStringParameter(request, "search");
        int roleId           = getIntParameter(request, "roleId", -1);
        int branchId         = getIntParameter(request, "branchId", -1);
        String status        = getStringParameter(request, "status");
        String sortColumn    = getStringParameter(request, "sort");
        String sortDirection = getStringParameter(request, "dir");
        int page             = getIntParameter(request, "page", 1);
        int pageSize         = getIntParameter(request, "size", DEFAULT_PAGE_SIZE);

        if (page < 1) page = 1;
        boolean validPageSize = false;
        for (int ps : PAGE_SIZES) {
            if (ps == pageSize) { validPageSize = true; break; }
        }
        if (!validPageSize) pageSize = DEFAULT_PAGE_SIZE;

        // 3. Lấy danh sách tài khoản theo filter
        int offset = (page - 1) * pageSize;
        List<User> users = userDAO.getAccountsPaginated(
                search, roleId, branchId, status,
                sortColumn, sortDirection, offset, pageSize
        );
        int totalRecords = userDAO.countAccounts(search, roleId, branchId, status);

        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages < 1) totalPages = 1;

        int displayStart = (totalRecords == 0) ? 0 : (page - 1) * pageSize + 1;
        int displayEnd   = Math.min(page * pageSize, totalRecords);
        int pagerStart   = Math.max(1, page - 2);
        int pagerEnd     = Math.min(totalPages, page + 2);

        // Tính nextDir cho từng cột sort (tránh lỗi EL ?: phức tạp trong URL)
        String currentDir = (sortDirection == null) ? "ASC" : sortDirection.toUpperCase();
        boolean isDesc = "DESC".equalsIgnoreCase(currentDir);
        request.setAttribute("usernameDir", isDesc ? "ASC" : "DESC");
        request.setAttribute("fullNameDir", isDesc ? "ASC" : "DESC");
        request.setAttribute("statusDir",   isDesc ? "ASC" : "DESC");
        request.setAttribute("isUsernameSort", "username".equalsIgnoreCase(sortColumn));
        request.setAttribute("isFullNameSort", "full_name".equalsIgnoreCase(sortColumn));
        request.setAttribute("isStatusSort",   "status".equalsIgnoreCase(sortColumn));

        // 4. Dropdown data (Role + Branch)
        List<Role> roles   = roleDAO.getAllRoles();
        List<Branch> branches = branchDAO.getAllBranches();

        // 5. Lấy danh sách tài khoản bị khóa
        String lockedSearch       = getStringParameter(request, "lockedSearch");
        String lockedReasonSearch = getStringParameter(request, "lockedReasonSearch");
        String lockedBySearch     = getStringParameter(request, "lockedBySearch");
        int lockedPage            = getIntParameter(request, "lockedPage", 1);
        if (lockedPage < 1) lockedPage = 1;

        int lockedOffset = (lockedPage - 1) * DEFAULT_LOCKED_PAGE_SIZE;
        List<EmployeeLock> lockedAccounts = userDAO.getLockedAccountsBySystem(
                lockedSearch, lockedReasonSearch, lockedBySearch,
                lockedOffset, DEFAULT_LOCKED_PAGE_SIZE
        );
        int totalLockedRecords = userDAO.countLockedAccountsBySystem(
                lockedSearch, lockedReasonSearch, lockedBySearch
        );
        int totalLockedPages = (int) Math.ceil((double) totalLockedRecords / DEFAULT_LOCKED_PAGE_SIZE);
        if (totalLockedPages < 1) totalLockedPages = 1;
        int lockedPagerStart = Math.max(1, lockedPage - 2);
        int lockedPagerEnd   = Math.min(totalLockedPages, lockedPage + 2);

        // 6. Set attributes cho JSP
        request.setAttribute("users", users);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("pageSizes", PAGE_SIZES);
        request.setAttribute("displayStart", displayStart);
        request.setAttribute("displayEnd", displayEnd);
        request.setAttribute("pagerStart", pagerStart);
        request.setAttribute("pagerEnd", pagerEnd);

        request.setAttribute("search", search);
        request.setAttribute("roleId", roleId);
        request.setAttribute("branchId", branchId);
        request.setAttribute("status", status);
        request.setAttribute("sortColumn", sortColumn);
        request.setAttribute("sortDirection", sortDirection);

        request.setAttribute("roles", roles);
        request.setAttribute("branches", branches);

        // Locked section
        request.setAttribute("lockedAccounts", lockedAccounts);
        request.setAttribute("totalLockedRecords", totalLockedRecords);
        request.setAttribute("totalLockedPages", totalLockedPages);
        request.setAttribute("currentLockedPage", lockedPage);
        request.setAttribute("lockedPageSize", DEFAULT_LOCKED_PAGE_SIZE);
        request.setAttribute("lockedSearch", lockedSearch);
        request.setAttribute("lockedReasonSearch", lockedReasonSearch);
        request.setAttribute("lockedBySearch", lockedBySearch);
        request.setAttribute("lockedPagerStart", lockedPagerStart);
        request.setAttribute("lockedPagerEnd", lockedPagerEnd);

        // Messages
        request.setAttribute("successMessage", getAndClearSuccessMessage(request));
        request.setAttribute("errorMessage", getAndClearErrorMessage(request));

        // 7. Forward
    request.getRequestDispatcher("/WEB-INF/views/admin/accounts.jsp").forward(request, response);
}

    // =========================================================
    //  POST: lock / unlock / resetPassword
    // =========================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Set charset for Vietnamese
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        switch (action) {
            case "lock":
                handleLock(request, response);
                break;
            case "unlock":
                handleUnlock(request, response);
                break;
            case "resetPassword":
                handleResetPassword(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/accounts");
                break;
        }
    }

    // =========================================================
    //  Xử lý KHÓA tài khoản
    // =========================================================
    private void handleLock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null || currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        String targetUserIdStr = request.getParameter("userId");
        if (targetUserIdStr == null || targetUserIdStr.trim().isEmpty()) {
            setErrorMessage(request, "Không xác định được tài khoản cần khóa.");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        int targetUserId;
        try {
            targetUserId = Integer.parseInt(targetUserIdStr.trim());
        } catch (NumberFormatException e) {
            setErrorMessage(request, "ID tài khoản không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        String reason = getStringParameter(request, "reason");

        // CHECK 1: Không tự khóa chính mình
        if (targetUserId == currentUser.getId()) {
            setErrorMessage(request, "Bạn không thể tự khóa tài khoản của mình!");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        // CHECK 2: Tồn tại?
        User targetUser = userDAO.getUserById(targetUserId);
        if (targetUser == null) {
            setErrorMessage(request, "Không tìm thấy tài khoản!");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        // CHECK 3: Không khóa Admin khác
        if (targetUser.getRoleId() == ROLE_ADMIN) {
            setErrorMessage(request, "Bạn không có quyền khóa tài khoản Quản trị viên khác!");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        // CHECK 4: Chưa bị khóa?
        String currentStatus = userDAO.getUserStatus(targetUserId);
        if (STATUS_EMERGENCY_LOCKED.equals(currentStatus)) {
            setErrorMessage(request, "Tài khoản này đã bị khóa trước đó!");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        // Action
        String desc = "Admin khóa tài khoản";
        if (reason != null && !reason.trim().isEmpty()) desc += ": " + reason;

        boolean success = userDAO.updateUserStatusWithAudit(
                targetUserId,
                STATUS_EMERGENCY_LOCKED,
                AuditLog.ACTION_EMERGENCY_LOCK,
                currentUser.getId(),
                desc
        );

        if (success) {
            try {
                employeeLockDAO.ensureTableExists();
                employeeLockDAO.createLock(targetUserId, currentUser.getId(), reason);
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            // ========================================================
            // CƯỠNG BỨC ĐĂNG XUẤT user bị khóa (nếu đang online)
            // Xóa token trong ServletContext -> AuthFilter sẽ tự hủy session
            // ========================================================
            try {
                request.getServletContext().removeAttribute("user_token_" + targetUserId);
            } catch (Exception ignore) {}

            String displayName = targetUser.getFullName() != null ? targetUser.getFullName() : targetUser.getUsername();
            setSuccessMessage(request, "Đã khóa tài khoản \"" + displayName + "\" thành công! User sẽ bị đăng xuất ngay lập tức nếu đang online.");
        } else {
            setErrorMessage(request, "Không thể khóa tài khoản. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/accounts");
    }

    // =========================================================
    //  Xử lý MỞ KHÓA
    // =========================================================
    private void handleUnlock(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null || currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        String targetUserIdStr = request.getParameter("userId");
        if (targetUserIdStr == null || targetUserIdStr.trim().isEmpty()) {
            setErrorMessage(request, "Không xác định được tài khoản cần mở khóa.");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        int targetUserId;
        try {
            targetUserId = Integer.parseInt(targetUserIdStr.trim());
        } catch (NumberFormatException e) {
            setErrorMessage(request, "ID tài khoản không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        User targetUser = userDAO.getUserById(targetUserId);
        if (targetUser == null) {
            setErrorMessage(request, "Không tìm thấy tài khoản!");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        String currentStatus = userDAO.getUserStatus(targetUserId);
        if (!STATUS_EMERGENCY_LOCKED.equals(currentStatus)) {
            setErrorMessage(request, "Tài khoản này không bị khóa!");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        String desc = "Admin mở khóa tài khoản";
        boolean success = userDAO.updateUserStatusWithAudit(
                targetUserId,
                STATUS_ACTIVE,
                AuditLog.ACTION_EMERGENCY_UNLOCK,
                currentUser.getId(),
                desc
        );

        if (success) {
            try {
                employeeLockDAO.ensureTableExists();
                employeeLockDAO.unlock(targetUserId, currentUser.getId());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            String displayName = targetUser.getFullName() != null ? targetUser.getFullName() : targetUser.getUsername();
            setSuccessMessage(request, "Đã mở khóa tài khoản \"" + displayName + "\" thành công!");
        } else {
            setErrorMessage(request, "Không thể mở khóa. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/accounts");
    }

    // =========================================================
    //  Xử lý RESET MẬT KHẨU về "123456"
    // =========================================================
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null || currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        String targetUserIdStr = request.getParameter("userId");
        if (targetUserIdStr == null || targetUserIdStr.trim().isEmpty()) {
            setErrorMessage(request, "Không xác định được tài khoản cần reset mật khẩu.");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        int targetUserId;
        try {
            targetUserId = Integer.parseInt(targetUserIdStr.trim());
        } catch (NumberFormatException e) {
            setErrorMessage(request, "ID tài khoản không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        User targetUser = userDAO.getUserById(targetUserId);
        if (targetUser == null) {
            setErrorMessage(request, "Không tìm thấy tài khoản!");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        // Không reset của Admin khác (giữ nguyên tắc)
        if (targetUser.getRoleId() == ROLE_ADMIN && targetUser.getId() != currentUser.getId()) {
            setErrorMessage(request, "Bạn không có quyền reset mật khẩu của Quản trị viên khác!");
            response.sendRedirect(request.getContextPath() + "/admin/accounts");
            return;
        }

        boolean success = userDAO.changePassword(targetUserId, "123456");
        if (success) {
            String displayName = targetUser.getFullName() != null ? targetUser.getFullName() : targetUser.getUsername();
            setSuccessMessage(request,
                    "Đã reset mật khẩu của \"" + displayName + "\" về mặc định (123456). " +
                    "Người dùng sẽ được yêu cầu đổi mật khẩu khi đăng nhập lần sau.");

            // Ghi audit log
            try {
                String ip = getClientIp(request);
                String desc = "Admin '" + currentUser.getUsername() + "' reset mật khẩu của tài khoản '"
                            + targetUser.getUsername() + "' (id=" + targetUserId + ") về mặc định '123456'";
                auditLogDAO.log(AuditLog.ACTION_RESET_PASSWORD, currentUser.getId(), targetUserId, desc, ip);
            } catch (Exception logEx) {
                logEx.printStackTrace();
            }
        } else {
            setErrorMessage(request, "Không thể reset mật khẩu. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/accounts");
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
