package controller.store;

import controller.base.BaseServlet;
import dao.CommonDAO;
import dao.RecruitmentProposalDAO;
import model.User;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Store Manager tạo và xem đề xuất tuyển dụng cho chi nhánh của mình.
 */
@WebServlet("/store-manager/recruitment")
public class StoreManagerRecruitmentServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra đăng nhập
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        // 2. Kiểm tra phân quyền Store Manager (ROLE_STORE_MANAGER = 4) hoặc Admin (ROLE_ADMIN = 1)
        if (user.getRoleId() != ROLE_STORE_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Tuyển dụng cửa hàng!");
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

        // 2. Đọc tham số an toàn qua BaseServlet (thay cho Integer.parseInt & try-catch)
        int positionId = getIntParameter(request, "positionId", -1);
        String employmentType = getStringParameter(request, "employmentType");
        int quantity = getIntParameter(request, "quantity", 0);
        String targetDate = getStringParameter(request, "targetDate");
        String reason = getStringParameter(request, "reason");

        if (positionId == -1) {
            request.setAttribute("error", "Vui lòng chọn vị trí cần tuyển dụng!");
        } else if (quantity <= 0) {
            request.setAttribute("error", "Số lượng cần tuyển phải lớn hơn 0!");
        } else if (reason == null || reason.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập lý do đề xuất tuyển dụng!");
        } else {
            // Chi nhánh luôn lấy từ hồ sơ của Store Manager đang đăng nhập
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

    // ĐÃ XÓA hàm getCurrentUser() riêng lẻ ở cuối file 
    // vì BaseServlet đã hỗ trợ sẵn hàm getCurrentUser(request) dùng chung!
}