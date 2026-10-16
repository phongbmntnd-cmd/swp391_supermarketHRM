package controller.hr;

import controller.base.BaseServlet;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import dao.EmployeeDAO;
import dao.RecruitmentProposalDAO;
import context.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/hr/dashboard")
public class HRDashboardServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Nhân sự!");
            return;
        }

        try {
            EmployeeDAO empDao = new EmployeeDAO();
            
            // 1. Tổng nhân sự toàn hệ thống (role 4 và 5)
            int totalEmployees = empDao.getAllEmployees(null,null,null,null).size();

            // 2. Đề xuất tuyển dụng đang chờ duyệt (PENDING)
            RecruitmentProposalDAO proposalDao = new RecruitmentProposalDAO();
            int pendingProposals = proposalDao.getPendingProposals().size();

            // 3. Tổng số chi nhánh đang hoạt động
            int totalBranches = countTotalBranches();

            // 4. Tổng số tài khoản đang bị khóa trên toàn hệ thống
            int totalLocked = countTotalLockedAccounts();

            request.setAttribute("totalEmployees", totalEmployees);
            request.setAttribute("pendingProposals", pendingProposals);
            request.setAttribute("totalBranches", totalBranches);
            request.setAttribute("totalLocked", totalLocked);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/WEB-INF/views/hr/dashboard.jsp").forward(request, response);
    }

    private int countTotalBranches() {
        String sql = "SELECT COUNT(*) FROM branches WHERE status = 'ACTIVE'";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int countTotalLockedAccounts() {
        String sql = "SELECT COUNT(*) FROM employee_locks WHERE is_active = TRUE";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}