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
        String idParam = request.getParameter("id");

        // Có ?id=... -> hiển thị trang chi tiết 1 đề xuất (xem đầy đủ + duyệt/từ chối tại đây)
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                RecruitmentProposal proposal = proposalDAO.getProposalById(id);

                if (proposal == null) {
                    response.sendRedirect(request.getContextPath() + "/hr/recruitment");
                    return;
                }

                request.setAttribute("proposal", proposal);
                request.getRequestDispatcher("/WEB-INF/views/hr/recruitment-detail.jsp")
                        .forward(request, response);
                return;

            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/hr/recruitment");
                return;
            }
        }

        // Không có id -> hiển thị danh sách. ?filter=all -> toàn bộ lịch sử;
        // mặc định chỉ xem các đề xuất đang chờ duyệt
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

        String ctx = request.getContextPath();
        int proposalId;

        try {
            proposalId = Integer.parseInt(request.getParameter("proposalId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(ctx + "/hr/recruitment");
            return;
        }

        String action = request.getParameter("action"); // "approve" hoặc "reject"
        String hrNote = request.getParameter("hrNote");

        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();
        boolean success;

        if ("approve".equals(action)) {
            success = proposalDAO.approveProposal(proposalId, user.getId(), hrNote);
        } else if ("reject".equals(action)) {
            success = proposalDAO.rejectProposal(proposalId, user.getId(), hrNote);
        } else {
            response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=1");
            return;
        }

        if (success) {
            // Xử lý xong -> quay về danh sách "Đang chờ duyệt" kèm thông báo qua query param
            String msg = "approve".equals(action) ? "approved" : "rejected";
            response.sendRedirect(ctx + "/hr/recruitment?filter=pending&msg=" + msg);
        } else {
            // Thất bại (VD đề xuất đã được xử lý trước đó) -> quay lại trang chi tiết, báo lỗi
            response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=1");
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("account") : null;
    }
}
