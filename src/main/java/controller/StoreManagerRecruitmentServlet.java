package controller;

import dao.CommonDAO;
import dao.RecruitmentProposalDAO;
import model.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Store Manager tạo và xem đề xuất tuyển dụng cho chi nhánh của mình.
 * AuthFilter đã đảm bảo chỉ roleId = 4 (Store Manager) mới vào được /store-manager/*.
 */
@WebServlet("/store-manager/recruitment")
public class StoreManagerRecruitmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        loadFormData(request, user);
        request.getRequestDispatcher("/WEB-INF/views/store-manager/recruitment.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User user = getCurrentUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int positionId = Integer.parseInt(request.getParameter("positionId"));
            String employmentType = request.getParameter("employmentType");
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String targetDate = request.getParameter("targetDate");
            String reason = request.getParameter("reason");

            if (quantity <= 0) {
                request.setAttribute("error", "Số lượng cần tuyển phải lớn hơn 0!");
            } else if (reason == null || reason.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập lý do đề xuất tuyển dụng!");
            } else {
                // Chi nhánh luôn lấy từ hồ sơ của Store Manager đang đăng nhập,
                // không cho client tự truyền branchId để tránh giả mạo chi nhánh khác.
                RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();
                boolean success = proposalDAO.createProposal(
                        user.getHomeBranchId(), positionId, employmentType,
                        quantity, targetDate, reason, user.getId());

                if (success) {
                    request.setAttribute("message", "Gửi đề xuất tuyển dụng thành công! Vui lòng chờ HR phê duyệt.");
                } else {
                    request.setAttribute("error", "Gửi đề xuất thất bại! Vui lòng thử lại.");
                }
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu nhập không hợp lệ!");
        }

        loadFormData(request, user);
        request.getRequestDispatcher("/WEB-INF/views/store-manager/recruitment.jsp")
                .forward(request, response);
    }

    private void loadFormData(HttpServletRequest request, User user) {
        CommonDAO commonDAO = new CommonDAO();
        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();

        request.setAttribute("positions", commonDAO.getAllPositions());
        request.setAttribute("proposals", proposalDAO.getProposalsByBranch(user.getHomeBranchId()));
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("account") : null;
    }
}
