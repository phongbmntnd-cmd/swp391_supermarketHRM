package controller.store;

import controller.base.BaseServlet;
import model.User;
import model.Employee;
import model.Branch;
import dao.BranchDAO;
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

            // 1. Lấy từ BaseServlet (nếu hệ thống đã hỗ trợ sẵn session/currentBranchId)
            try {
                resolvedBranchId = getCurrentBranchId(request);
            } catch (Exception ignored) {}

            // 2. Nếu chưa có, tìm chi nhánh mà user này làm Store Manager trực tiếp qua bảng branches
            if (resolvedBranchId <= 0) {
                resolvedBranchId = getBranchIdByManagerId(currentUser.getId());
            }

            // 3. Nếu vẫn không tìm thấy, fallback lấy theo home_branch_id của nhân viên
            if (resolvedBranchId <= 0) {
                EmployeeDAO empDao = new EmployeeDAO();
                Employee currentEmp = empDao.getEmployeeById(currentUser.getId());
                if (currentEmp != null) {
                    resolvedBranchId = currentEmp.getHomeBranchId();
                }
            }

            // Fallback an toàn cuối cùng nếu tất cả đều bằng 0
            if (resolvedBranchId <= 0) {
                resolvedBranchId = 1; 
            }

            final int branchId = resolvedBranchId;

            // 4. Lấy thông tin chi tiết của cơ sở hiện tại thông qua BranchDAO chuẩn
            BranchDAO branchDAO = new BranchDAO();
            Branch currentBranch = branchDAO.getBranchById(branchId);
            
            // Phòng hờ nếu DAO trả về null, khởi tạo đối tượng mặc định để tránh lỗi hiển thị JSP
            if (currentBranch == null) {
                currentBranch = new Branch();
                currentBranch.setId(branchId);
                currentBranch.setName("Chi nhánh mặc định");
                currentBranch.setCode("BRANCH-" + branchId);
                currentBranch.setAddress("Đang cập nhật");
            }

            // --- XỬ LÝ GHÉP CHUỖI HIỂN THỊ CHI NHÁNH TẠI SERVLET ---
            String displayBranchInfo = currentBranch.getName() + " (" + currentBranch.getCode() + ") - " + currentBranch.getAddress();
            request.setAttribute("displayBranchInfo", displayBranchInfo);

            // 5. Chỉ đếm nhân viên thuộc đúng chi nhánh này
            EmployeeDAO empDao = new EmployeeDAO();
            int totalEmployees = empDao.getAllEmployees(null, null, null, null).stream()
                    .filter(e -> e.getHomeBranchId() == branchId && e.getRoleId() == 5)
                    .mapToInt(e -> 1).sum();

            // 6. Tổng số đề xuất tuyển dụng của chi nhánh
            RecruitmentProposalDAO proposalDao = new RecruitmentProposalDAO();
            int totalProposals = proposalDao.getProposalsByBranch(branchId).size();

            // 7. Tổng số ca trực trong ngày hôm nay của chi nhánh
            ShiftScheduleDAO scheduleDao = new ShiftScheduleDAO();
            int totalShifts = scheduleDao.countTodaySchedulesByBranch(branchId);

            // 8. Số tài khoản đang bị khóa khẩn cấp tại chi nhánh
            EmployeeLockDAO lockDao = new EmployeeLockDAO();
            int lockedCount = lockDao.countLockedEmployeesByBranch(branchId, null, null, null);

            // Đưa dữ liệu ra request attribute
            request.setAttribute("currentBranch", currentBranch);
            request.setAttribute("totalEmployees", totalEmployees);
            request.setAttribute("totalProposals", totalProposals);
            request.setAttribute("totalShifts", totalShifts);
            request.setAttribute("lockedCount", lockedCount);

            // 9. Tổng số đơn (nghỉ phép + đổi ca) đang chờ duyệt của chi nhánh
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
     */
    private int countPendingRequests(int branchId) {
        int total = 0;

        try {
            total += new LeaveRequestDAO().countBranchPendingRequests(branchId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            total += new ShiftChangeRequestDAO().countBranchPendingShiftRequests(branchId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return total;
    }

    // Hàm phụ trợ: Lấy branchId dựa vào store_manager_id trong bảng branches
    private int getBranchIdByManagerId(int managerId) {
        String sql = "SELECT id FROM branches WHERE store_manager_id = ?";
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
}