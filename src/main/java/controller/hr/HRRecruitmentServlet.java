package controller.hr;

import controller.base.BaseServlet;
import dao.RecruitmentProposalDAO;
import model.RecruitmentProposal;
import model.User;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * HR Manager xem và phê duyệt / từ chối đề xuất tuyển dụng do Store Manager gửi lên.
 */
@WebServlet("/hr/recruitment")
public class HRRecruitmentServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập & Phân quyền HR (hoặc Admin) dùng BaseServlet
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Tuyển dụng!");
            return;
        }

        // 2. GIỮ NGUYÊN NGHIỆP VỤ CỦA BẠN: Lấy filter & query danh sách từ DAO
        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();
        String filter = getStringParameter(request, "filter"); // Thay cho request.getParameter("filter")

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

        // 1. Kiểm tra đăng nhập & Phân quyền
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        if (user.getRoleId() != ROLE_HR_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        // 2. GIỮ NGUYÊN NGHIỆP VỤ CỦA BẠN: Phê duyệt / Từ chối đề xuất
        int proposalId = getIntParameter(request, "proposalId", -1); // Dùng hàm trợ giúp của BaseServlet thay cho Integer.parseInt
        String action = getStringParameter(request, "action"); // "approve" hoặc "reject"
        String hrNote = getStringParameter(request, "hrNote");

        if (proposalId == -1) {
            request.setAttribute("error", "Dữ liệu proposalId không hợp lệ!");
            doGet(request, response);
            return;
        }

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

        doGet(request, response);
    }

    // ĐÃ XÓA hàm getCurrentUser() riêng lẻ ở cuối file 
    // vì BaseServlet đã hỗ trợ sẵn hàm getCurrentUser(request) rồi!
}