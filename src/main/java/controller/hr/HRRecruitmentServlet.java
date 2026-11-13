package controller.hr;

import controller.base.BaseServlet;
import dao.CommonDAO;
import dao.EmployeeProfileDAO;
import dao.RecruitmentProposalDAO;
import dao.RecruitmentRequestDAO;
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
        
        // Khôi phục thông tin khi HR tạo nhân viên thất bại
        jakarta.servlet.http.HttpSession session =
                request.getSession(false);

        if (session != null
                && session.getAttribute("hireError") != null) {

            String[] keys = {
                "hireError",
                "hireRequestId",
                "hireFullName",
                "hirePhone",
                "hireIdentityCard",
                "hireEmail",
                "hireExpirationDate",
                "hireContractType"
            };

            for (String key : keys) {
                request.setAttribute(key,
                        session.getAttribute(key));
                session.removeAttribute(key);
            }
        }

        if (session != null
                && Boolean.TRUE.equals(
                        session.getAttribute("createRecruitmentSuccess"))) {

            request.setAttribute(
                    "createRecruitmentSuccess", true
            );

            request.setAttribute(
                    "createdEmployeeUsername",
                    session.getAttribute("createdEmployeeUsername")
            );

            request.setAttribute(
                    "createdEmployeeFullName",
                    session.getAttribute("createdEmployeeFullName")
            );

            // Chỉ hiển thị thông báo một lần
            session.removeAttribute("createRecruitmentSuccess");
            session.removeAttribute("createdEmployeeUsername");
            session.removeAttribute("createdEmployeeFullName");
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

        // 2. Hiển thị DANH SÁCH TỔNG QUAN - có lọc thêm Chi nhánh / Vị trí / Hình thức / Trạng thái
        String filter = getStringParameter(request, "filter");
        int branchIdParam = getIntParameter(request, "branchId", -1);
        int positionIdParam = getIntParameter(request, "positionId", -1);
        String employmentType = getStringParameter(request, "employmentType");
        String status = getStringParameter(request, "status");

        Integer branchId = branchIdParam == -1 ? null : branchIdParam;
        Integer positionId = positionIdParam == -1 ? null : positionIdParam;

        List<RecruitmentProposal> proposals = proposalDAO.getProposals(
                filter == null ? "pending" : filter, branchId, positionId, employmentType, status);

        request.setAttribute("proposals", proposals);
        request.setAttribute("filter", filter == null ? "pending" : filter);
        request.setAttribute("branchId", branchId);
        request.setAttribute("positionId", positionId);
        request.setAttribute("employmentType", employmentType);
        request.setAttribute("status", status);

        // Dữ liệu đổ vào dropdown lọc
        CommonDAO commonDAO = new CommonDAO();
        request.setAttribute("branches", commonDAO.getAllBranches());
        request.setAttribute("positions", commonDAO.getStoreEmployeePositions());

        try {
            RecruitmentRequestDAO recruitmentDAO
                    = new RecruitmentRequestDAO();

            // Cùng bộ lọc với danh sách đề xuất tiếp nhận ứng viên.
            request.setAttribute(
                    "recruitmentRequests",
                    recruitmentDAO.getFilteredRequests(
                            filter == null ? "pending" : filter,
                            branchId, positionId, employmentType, status)
            );

        } catch (Exception e) {
            throw new ServletException(
                    "Không thể tải đề xuất tuyển dụng.", e);
        }

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

        // LUỒNG MỚI: HR duyệt/từ chối nhu cầu tuyển dụng
        if ("approveRecruitmentRequest".equals(action)
                || "rejectRecruitmentRequest".equals(action)) {

            int requestId = getIntParameter(
                    request, "requestId", -1);

            boolean approved
                    = "approveRecruitmentRequest".equals(action);

            if (requestId <= 0) {
                response.sendError(400,
                        "Mã đề xuất tuyển dụng không hợp lệ.");
                return;
            }

            if (!approved
                    && (hrNote == null || hrNote.trim().isEmpty())) {
                response.sendError(400,
                        "Vui lòng nhập lý do từ chối.");
                return;
            }

            try {
                RecruitmentRequestDAO recruitmentDAO
                        = new RecruitmentRequestDAO();

                boolean success = recruitmentDAO.reviewRequest(
                        requestId,
                        user.getId(),
                        approved,
                        hrNote
                );

                if (success) {
                    response.sendRedirect(
                            ctx + "/hr/recruitment?type=hiring&msg="
                            + (approved ? "approved" : "rejected"));
                } else {
                    response.sendRedirect(
                            ctx + "/hr/recruitment?type=hiring&err=review");
                }

            } catch (Exception e) {
                throw new ServletException(
                        "Không thể xử lý đề xuất tuyển dụng.", e);
            }

            return;
        }

        if (proposalId == -1) {
            response.sendRedirect(ctx + "/hr/recruitment");
            return;
        }

        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();

        // Xử lý khi HR chọn PHÊ DUYỆT đề xuất
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
                EmployeeProfileDAO profileDAO = new EmployeeProfileDAO(); // Khởi tạo EmployeeProfileDAO để check SĐT và CCCD

                // SĐT và CCCD kiểm tra qua profileDAO (bảng employee_profiles)
                if (c.getPhone() != null && profileDAO.isPhoneExists(c.getPhone())) {
                    response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=phone_exists");
                    return;
                }
                if (c.getIdentityCard() != null && profileDAO.isIdentityCardExists(c.getIdentityCard())) {
                    response.sendRedirect(ctx + "/hr/recruitment?id=" + proposalId + "&err=id_exists");
                    return;
                }
                // Email kiểm tra qua userDAO (bảng users)
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
