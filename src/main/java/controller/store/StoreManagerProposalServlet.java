package controller.store;

import controller.base.BaseServlet;
import dao.ProposalDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "StoreManagerProposalServlet", urlPatterns = {"/store-manager/proposal"})
public class StoreManagerProposalServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        // 2. Kiểm tra phân quyền Store Manager (ROLE_STORE_MANAGER = 4) hoặc Admin (ROLE_ADMIN = 1)
        if (currentUser.getRoleId() != ROLE_STORE_MANAGER && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Đề xuất tuyển dụng!");
            return;
        }

        // 3. Lấy danh sách đề xuất
        ProposalDAO dao = new ProposalDAO();
        request.setAttribute("proposalList", dao.getAllProposals());
        request.getRequestDispatcher("/WEB-INF/views/store-manager/proposal.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra đăng nhập & Phân quyền
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        if (user.getRoleId() != ROLE_STORE_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        // 2. Đọc tham số an toàn qua tiện ích BaseServlet
        String position = getStringParameter(request, "position");
        int quantity = getIntParameter(request, "quantity", 1);
        String reason = getStringParameter(request, "reason");
        int branchId = user.getHomeBranchId();

        // 3. Tạo đề xuất mới
        ProposalDAO dao = new ProposalDAO();
        dao.createProposal(branchId, user.getId(), position, quantity, reason);

        response.sendRedirect(request.getContextPath() + "/store-manager/proposal");
    }
}