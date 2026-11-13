package controller.director;

import controller.base.BaseServlet;
import dao.BranchDAO;
import dao.BranchRequestDAO;
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

        } else if ("viewEmployees".equals(action)) {
            int branchId = getIntParameter(request, "id", -1);

            if (branchId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Mã chi nhánh không hợp lệ."
                );
                return;
            }

            Branch selectedBranch = branchDAO.getBranchById(branchId);

            if (selectedBranch == null) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Không tìm thấy chi nhánh."
                );
                return;
            }

            List<User> employees
                    = branchDAO.getEmployeesByBranch(branchId);

            request.setAttribute("branchDetail", selectedBranch);
            request.setAttribute("branchId", branchId);
            request.setAttribute("employeeList", employees);

            request.getRequestDispatcher(
                    "/WEB-INF/views/director/branch-employees.jsp"
            ).forward(request, response);
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

        if ("createRequest".equals(action)) {

            String name = request.getParameter("name");
            String address = request.getParameter("address");
            String openingDate = request.getParameter("openingDate");
            String reason = request.getParameter("reason");

            try {
                // Kiểm tra thông tin bắt buộc
                if (name == null || name.trim().isEmpty()
                        || address == null || address.trim().isEmpty()
                        || reason == null || reason.trim().isEmpty()
                        || openingDate == null || openingDate.trim().isEmpty()) {
                    throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin.");
                }

                java.time.LocalDate date = java.time.LocalDate.parse(openingDate);

                if (!date.isAfter(java.time.LocalDate.now())) {
                    throw new IllegalArgumentException(
                            "Ngày khai trương phải lớn hơn ngày hiện tại."
                    );
                }

                BranchRequestDAO requestDAO = new BranchRequestDAO();

                if (requestDAO.isDuplicate(name, address)) {
                    throw new IllegalArgumentException(
                            "Tên hoặc địa chỉ chi nhánh đã tồn tại."
                    );
                }

                boolean success = requestDAO.createRequest(
                        name.trim(),
                        address.trim(),
                        date,
                        reason.trim(),
                        currentUser.getId()
                );

                if (!success) {
                    throw new Exception("Không thể lưu yêu cầu.");
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/director/branch-management?success=1"
                );
                return;

            } catch (Exception e) {
                request.setAttribute("error", e.getMessage());
                request.setAttribute("branchList", branchDAO.getAllBranches());

                request.getRequestDispatcher(
                        "/WEB-INF/views/director/branch-management.jsp"
                ).forward(request, response);
                return;
            }
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

            String error = null;

            // 1. Kiểm tra thông tin bắt buộc
            if (id <= 0 || code == null || name == null || address == null) {
                error = "Vui lòng nhập đầy đủ thông tin chi nhánh.";
            }

            // 2. Kiểm tra chi nhánh cần sửa có tồn tại
            Branch existingBranch = branchDAO.getBranchById(id);

            if (error == null && existingBranch == null) {
                error = "Không tìm thấy chi nhánh cần cập nhật.";
            }

            // 3. Kiểm tra mã chi nhánh có bị trùng không
            if (error == null) {
                for (Branch b : branchDAO.getAllBranches()) {
                    if (b.getId() != id
                            && b.getCode() != null
                            && b.getCode().equalsIgnoreCase(code)) {
                        error = "Mã chi nhánh " + code
                                + " đã tồn tại. Vui lòng chọn mã khác.";
                        break;
                    }
                }
            }

            // 4. Cập nhật khi thông tin hợp lệ
            if (error == null) {
                boolean updated = branchDAO.updateBranch(
                        id, code, name, address
                );

                if (updated) {
                    response.sendRedirect(
                            request.getContextPath()
                            + "/director/branch-management?updated=1"
                    );
                    return;
                }

                error = "Không thể cập nhật chi nhánh. Vui lòng kiểm tra lại.";
            }

            // 5. Có lỗi: giữ form sửa và hiển thị thông báo
            Branch editingBranch = new Branch();
            editingBranch.setId(id);
            editingBranch.setCode(code);
            editingBranch.setName(name);
            editingBranch.setAddress(address);

            request.setAttribute("editingBranch", editingBranch);
            request.setAttribute("branchList", branchDAO.getAllBranches());
            request.setAttribute("editError", error);

            request.getRequestDispatcher(
                    "/WEB-INF/views/director/branch-management.jsp"
            ).forward(request, response);
            return;
        }

    }
}
