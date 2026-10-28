package controller.store;

import controller.base.BaseServlet;
import model.User;
import model.Employee;
import model.Branch;
import dao.EmployeeDAO;
import dao.EmployeeLockDAO;
import dao.LeaveRequestDAO;
import dao.RecruitmentProposalDAO;
import dao.ShiftChangeRequestDAO;
import dao.ShiftScheduleDAO;
import context.DBContext;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/store-manager/dashboard")
public class StoreManagerDashboardServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_STORE_MANAGER && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Quản lý cửa hàng!");
            return;
        }

        try {
            int resolvedBranchId = 0;

            // 1. Ưu tiên tìm chi nhánh mà user này làm Store Manager trực tiếp qua bảng branches
            resolvedBranchId = getBranchIdByManagerId(currentUser.getId());

            // 2. Nếu không tìm thấy, fallback lấy theo home_branch_id của nhân viên
            if (resolvedBranchId == 0) {
                EmployeeDAO empDao = new EmployeeDAO();
                Employee currentEmp = empDao.getEmployeeById(currentUser.getId());
                if (currentEmp != null) {
                    resolvedBranchId = currentEmp.getHomeBranchId();
                }
            }

            // Fallback an toàn cuối cùng nếu vẫn bằng 0
            if (resolvedBranchId == 0) {
                resolvedBranchId = 1; 
            }

            // Tạo biến final để sử dụng an toàn bên trong biểu thức Lambda
            final int branchId = resolvedBranchId;

            // 3. Lấy thông tin chi tiết của cơ sở hiện tại
            Branch currentBranch = getBranchById(branchId);

            // 4. Chỉ đếm nhân viên (role_id = 5) thuộc đúng chi nhánh này
            EmployeeDAO empDao = new EmployeeDAO();
            int totalEmployees = empDao.getAllEmployees(null,null,null,null).stream()
                    .filter(e -> e.getHomeBranchId() == branchId && e.getRoleId() == 5)
                    .mapToInt(e -> 1).sum();

            // 5. Tổng số đề xuất tuyển dụng của chi nhánh
            RecruitmentProposalDAO proposalDao = new RecruitmentProposalDAO();
            int totalProposals = proposalDao.getProposalsByBranch(branchId).size();

            // 6. Tổng số ca trực trong ngày hôm nay của chi nhánh
            ShiftScheduleDAO scheduleDao = new ShiftScheduleDAO();
            int totalShifts = scheduleDao.countTodaySchedulesByBranch(branchId);

            // 7. Số tài khoản đang bị khóa khẩn cấp tại chi nhánh
            EmployeeLockDAO lockDao = new EmployeeLockDAO();
            int lockedCount = lockDao.countLockedEmployeesByBranch(branchId, null, null, null);

            // Đưa dữ liệu ra request attribute
            request.setAttribute("currentBranch", currentBranch);
            request.setAttribute("totalEmployees", totalEmployees);
            request.setAttribute("totalProposals", totalProposals);
            request.setAttribute("totalShifts", totalShifts);
            request.setAttribute("lockedCount", lockedCount);

            // 8. Tổng số đơn (nghỉ phép + đổi ca) đang chờ duyệt của chi nhánh
            request.setAttribute(
                    "pendingRequestCount",
                    countPendingRequests(branchId)
            );

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/WEB-INF/views/store-manager/dashboard.jsp").forward(request, response);
    }

    /**
     * Tổng số đơn (nghỉ phép + đổi ca) của chi nhánh đang chờ duyệt.
     * Nếu lỗi truy vấn thì trả 0 để trang vẫn hiển thị bình thường.
     */
    private int countPendingRequests(int branchId) {
        int total = 0;

        try {
            total += new LeaveRequestDAO()
                    .countBranchPendingRequests(branchId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            total += new ShiftChangeRequestDAO()
                    .countBranchPendingShiftRequests(branchId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return total;
    }

    // Hàm phụ trợ: Lấy branchId dựa vào store_manager_id trong bảng branches
    private int getBranchIdByManagerId(int managerId) {        String sql = "SELECT id FROM branches WHERE store_manager_id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Branch getBranchById(int branchId) {
        String sql = "SELECT id, code, name, address, status, store_manager_id FROM branches WHERE id = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, branchId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Branch b = new Branch();
                    b.setId(rs.getInt("id"));
                    b.setCode(rs.getString("code"));
                    b.setName(rs.getString("name"));
                    b.setAddress(rs.getString("address"));
                    return b;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}