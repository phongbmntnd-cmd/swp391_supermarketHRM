package controller.director;

import controller.base.BaseServlet;
import dao.BranchDAO;
import model.Branch;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DirectorController", urlPatterns = {"/director/branch-management"})
public class DirectorController extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập & Phân quyền Director (ROLE_DIRECTOR = 2)
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_DIRECTOR && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Quản lý Chi nhánh!");
            return;
        }

        // 2. GIỮ NGUYÊN NGHIỆP VỤ CỦA BẠN: Xử lý các action (list, viewEmployees, edit)
        String action = getStringParameter(request, "action");
        BranchDAO branchDAO = new BranchDAO();

        if (action == null || action.equals("list")) {
            // Hiển thị danh sách cơ sở
            List<Branch> branches = branchDAO.getAllBranches();
            request.setAttribute("branchList", branches);
            request.getRequestDispatcher("/WEB-INF/views/director/branch-management.jsp").forward(request, response);

        } else if (action.equals("viewEmployees")) {
            // Xem danh sách nhân viên của cơ sở
            int branchId = getIntParameter(request, "id", -1);
            List<User> employees = branchDAO.getEmployeesByBranch(branchId);
            request.setAttribute("employeeList", employees);
            request.setAttribute("branchId", branchId);
            request.getRequestDispatcher("/WEB-INF/views/director/branch-employees.jsp").forward(request, response);

        } else if ("edit".equals(action)) {
            int branchId = getIntParameter(request, "id", -1);
            List<Branch> branches = branchDAO.getAllBranches();
            Branch editingBranch = null;
            for (Branch b : branches) {
                if (b.getId() == branchId) {
                    editingBranch = b;
                    break;
                }
            }
            request.setAttribute("branchList", branches);
            request.setAttribute("editingBranch", editingBranch); // Gửi đối tượng cần sửa sang JSP
            request.getRequestDispatcher("/WEB-INF/views/director/branch-management.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập & Phân quyền
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_DIRECTOR && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        // 2. GIỮ NGUYÊN NGHIỆP VỤ CỦA BẠN: Xử lý các action (add, assign, toggleStatus, delete, update)
        String action = getStringParameter(request, "action");
        BranchDAO branchDAO = new BranchDAO();

        if ("add".equals(action)) {
            // Thêm mới cơ sở
            String code = getStringParameter(request, "code");
            String name = getStringParameter(request, "name");
            String address = getStringParameter(request, "address");

            branchDAO.insertBranch(code, name, address);
            response.sendRedirect(request.getContextPath() + "/director/branch-management?action=list");

        } else if ("assign".equals(action)) {
            // Gán quản lý cho cơ sở
            int branchId = getIntParameter(request, "branchId", -1);
            int managerId = getIntParameter(request, "managerId", -1);

            branchDAO.assignStoreManager(branchId, managerId);
            response.sendRedirect(request.getContextPath() + "/director/branch-management?action=list");

        } else if ("toggleStatus".equals(action)) {
            int branchId = getIntParameter(request, "branchId", -1);
            String currentStatus = getStringParameter(request, "currentStatus");

            // Gọi DAO để đảo ngược trạng thái (ACTIVE <-> INACTIVE)
            branchDAO.toggleBranchStatus(branchId, currentStatus);

            // Chuyển hướng lại trang danh sách để load lại dữ liệu mới
            response.sendRedirect(request.getContextPath() + "/director/branch-management");

        } else if ("delete".equals(action)) {
            // Tính năng: Xóa / Hủy kích hoạt cơ sở
            int branchId = getIntParameter(request, "branchId", -1);
            branchDAO.deleteBranch(branchId);
            response.sendRedirect(request.getContextPath() + "/director/branch-management");

        } else if ("update".equals(action)) {
            int id = getIntParameter(request, "id", -1);
            String code = getStringParameter(request, "code");
            String name = getStringParameter(request, "name");
            String address = getStringParameter(request, "address");

            branchDAO.updateBranch(id, code, name, address);
            response.sendRedirect(request.getContextPath() + "/director/branch-management");
        }
    }
}