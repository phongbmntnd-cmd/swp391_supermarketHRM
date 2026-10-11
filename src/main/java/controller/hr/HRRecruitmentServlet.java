package controller.hr;

import controller.base.BaseServlet;
import dao.RecruitmentProposalDAO;
import dao.UserDAO;
import model.Candidate;
import model.RecruitmentProposal;
import model.User;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/hr/recruitment")
public class HRRecruitmentServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Tuyển dụng!");
            return;
        }

        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();
        String idParam = getStringParameter(request, "id");

        // 1. Hiển thị trang CHI TIẾT ĐỀ XUẤT
        if (idParam != null && !idParam.trim().isEmpty()) {
            int id = getIntParameter(request, "id", -1);
            if (id != -1) {
                RecruitmentProposal proposal = proposalDAO.getProposalById(id);
                if (proposal != null) {
                    request.setAttribute("proposal", proposal);
                    request.getRequestDispatcher("/WEB-INF/views/hr/recruitment-detail.jsp")
                            .forward(request, response);
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/hr/recruitment");
            return;
        }

        // 2. Hiển thị DANH SÁCH TỔNG QUAN
        String filter = getStringParameter(request, "filter");
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
            redirectToLogin(request, response);
            return;
        }

        if (user.getRoleId() != ROLE_HR_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        String ctx = request.getContextPath();
        int proposalId = getIntParameter(request, "proposalId", -1);
        String action = getStringParameter(request, "action");
        String hrNote = getStringParameter(request, "hrNote");

        if (proposalId == -1) {
            response.sendRedirect(ctx + "/hr/recruitment");
            return;
        }

        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();

        // Xử lý khi HR chọn PHÊ DUYỆT đề xuất
        // Trong phương thức doPost của HRRecruitmentServlet.java (nhánh "approve"):
        if ("approve".equals(action)) {
            RecruitmentProposal proposal = proposalDAO.getProposalById(proposalId);
            if (proposal == null || !"PENDING".equals(proposal.getStatus())) {
                response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=1");
                return;
            }

            // Kiểm tra validate trùng lặp thông tin ứng viên trước khi chuyển sang form tạo tài khoản
            Candidate c = proposal.getCandidate();
            if (c != null) {
                UserDAO userDAO = new UserDAO();
                if (c.getPhone() != null && userDAO.isPhoneExists(c.getPhone())) {
                    response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=phone_exists");
                    return;
                }
                if (c.getIdentityCard() != null && userDAO.isIdentityCardExists(c.getIdentityCard())) {
                    response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=id_exists");
                    return;
                }
                if (c.getEmail() != null && !c.getEmail().trim().isEmpty() && userDAO.isEmailExists(c.getEmail())) {
                    response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=email_exists");
                    return;
                }
            }

            // Nếu hợp lệ -> Chuyển hướng sang form cấp tài khoản nhân sự (CreateUserServlet)
            response.sendRedirect(ctx + "/hr/create-user?proposalId=" + proposalId);
        } // Xử lý khi HR chọn TỪ CHỐI đề xuất
        else if ("reject".equals(action)) {
            if (hrNote == null || hrNote.trim().isEmpty()) {
                response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=err_note");
                return;
            }
            boolean success = proposalDAO.rejectProposal(proposalId, user.getId(), hrNote);
            if (success) {
                response.sendRedirect(ctx + "/hr/recruitment?filter=pending&msg=rejected");
            } else {
                response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=1");
            }
        } else {
            response.sendRedirect(ctx + "/hr/recruitment");
        }
    }
}
