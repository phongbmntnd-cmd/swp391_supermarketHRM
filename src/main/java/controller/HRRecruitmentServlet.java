package controller;

import dao.RecruitmentProposalDAO;
import model.RecruitmentProposal;
import model.User;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * HR Manager xem và phê duyệt / từ chối đề xuất tuyển dụng do Store Manager gửi lên.
 * AuthFilter đã đảm bảo chỉ roleId = 3 (HR Manager) mới vào được /hr/*.
 */
@WebServlet("/hr/recruitment")
public class HRRecruitmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();

        // ?filter=all -> xem toàn bộ lịch sử; mặc định chỉ xem các đề xuất đang chờ duyệt
        String filter = request.getParameter("filter");
        List<RecruitmentProposal> proposals = "all".equals(filter)
                ? proposalDAO.getAllProposals()
                : proposalDAO.getPendingProposals();

        request.setAttribute("proposals", proposals);
        request.setAttribute("filter", filter == null ? "pending" : filter);

        request.getRequestDispatcher("/WEB-INF/views/hr/recruitment.jsp")
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
            int proposalId = Integer.parseInt(request.getParameter("proposalId"));
            String action = request.getParameter("action"); // "approve" hoặc "reject"
            String hrNote = request.getParameter("hrNote");

            RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();
            boolean success;

            if ("approve".equals(action)) {
                success = proposalDAO.approveProposal(proposalId, user.getId(), hrNote);
            } else if ("reject".equals(action)) {
                success = proposalDAO.rejectProposal(proposalId, user.getId(), hrNote);
            } else {
                request.setAttribute("error", "Hành động không hợp lệ!");
                doGet(request, response);
                return;
            }

            if (success) {
                request.setAttribute("message",
                        "approve".equals(action) ? "Đã phê duyệt đề xuất tuyển dụng!" : "Đã từ chối đề xuất tuyển dụng!");
            } else {
                request.setAttribute("error", "Xử lý thất bại! Đề xuất có thể đã được xử lý trước đó.");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ!");
        }

        doGet(request, response);
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("account") : null;
    }
}
