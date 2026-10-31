package controller.store;

import controller.base.BaseServlet;
import dao.BranchDAO;
import dao.CommonDAO;
import dao.RecruitmentProposalDAO;
import model.Branch;
import model.Position;
import model.User;

import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/store-manager/recruitment")
public class StoreManagerRecruitmentServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        if (user.getRoleId() != ROLE_STORE_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang Tuyển dụng cửa hàng!");
            return;
        }

        loadFormData(request, user);
        request.getRequestDispatcher("/WEB-INF/views/store-manager/recruitment.jsp").forward(request, response);
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

        if (user.getRoleId() != ROLE_STORE_MANAGER && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền thực hiện thao tác này!");
            return;
        }

        String action = getStringParameter(request, "action");
        int positionId = getIntParameter(request, "positionId", -1);
        String employmentType = getStringParameter(request, "employeeType");
        String shiftType = getStringParameter(request, "shiftType");
        String fullName = getStringParameter(request, "fullName");
        String email = getStringParameter(request, "email");
        String phone = getStringParameter(request, "phone");
        String identityCard = getStringParameter(request, "identityCard");
        String expirationDate = getStringParameter(request, "expirationDate");
        String targetDate = getStringParameter(request, "targetDate");
        String reason = getStringParameter(request, "reason");

        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
        java.sql.Date parsedTargetDate = null;
        if (targetDate != null && !targetDate.trim().isEmpty()) {
            try {
                parsedTargetDate = java.sql.Date.valueOf(targetDate.trim());
            } catch (IllegalArgumentException e) {
                parsedTargetDate = null;
            }
        }

        CommonDAO commonDAO = new CommonDAO();
        List<Position> positions = commonDAO.getStoreEmployeePositions();
        int departmentId = -1;
        if (positionId != -1) {
            for (Position p : positions) {
                if (p.getId() == positionId) {
                    departmentId = p.getDepartmentId();
                    break;
                }
            }
        }

        String phoneRegex = "^0\\d{9}$";
        String idCardRegex = "^(\\d{9}|\\d{12})$";
        String emailRegex = "^[A-Za-z0-9+_.-]+@(.+)$";

        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();
        String errorMessage = null;

        // Validation chung
        if (fullName == null || fullName.trim().isEmpty()) {
            errorMessage = "Vui lòng nhập họ và tên ứng viên!";
        } else if (phone == null || !phone.matches(phoneRegex)) {
            errorMessage = "Số điện thoại không hợp lệ! (Bắt đầu bằng 0 và gồm 10 chữ số)";
        } else if (identityCard == null || !identityCard.matches(idCardRegex)) {
            errorMessage = "Số CCCD/CMND không hợp lệ! (Phải là 9 hoặc 12 chữ số)";
        } else if (email != null && !email.trim().isEmpty() && !email.matches(emailRegex)) {
            errorMessage = "Email không đúng định dạng!";
        } else if (positionId == -1) {
            errorMessage = "Vui lòng chọn vị trí đề xuất!";
        } else if (shiftType == null || shiftType.trim().isEmpty()) {
            errorMessage = "Vui lòng chọn loại ca làm việc!";
        } else if (parsedTargetDate == null || parsedTargetDate.before(today)) {
            errorMessage = "Ngày mong muốn có nhân sự không được hợp lệ hoặc trong quá khứ!";
        }

        // Nếu có lỗi validation -> Set attribute và forward lại trang chứa modal
        if (errorMessage != null) {
            request.setAttribute("error", errorMessage);
            loadFormData(request, user);
            request.getRequestDispatcher("/WEB-INF/views/store-manager/recruitment.jsp").forward(request, response);
            return;
        }

        // Thực hiện Thao tác CSDL (Create hoặc Resubmit)
        boolean success = false;
        if ("resubmit".equals(action)) {
            int proposalId = getIntParameter(request, "proposalId", -1);
            success = proposalDAO.resubmitProposal(proposalId, positionId, employmentType, shiftType, fullName, email, phone, identityCard, departmentId, expirationDate, targetDate, reason);
            if (success) {
                request.getSession().setAttribute("message", "Cập nhật và gửi lại đề xuất thành công!");
            }
        } else {
            success = proposalDAO.createProposal(
                    user.getHomeBranchId(), positionId, employmentType, shiftType,
                    fullName, email, phone, identityCard, departmentId,
                    expirationDate, targetDate, reason, user.getId()
            );
            if (success) {
                request.getSession().setAttribute("message", "Gửi đề xuất tuyển dụng thành công! Vui lòng chờ HR phê duyệt.");
            }
        }

        if (success) {
            // ÁP DỤNG CHUẨN PRG (Post/Redirect/Get): Chuyển hướng sang GET để tránh nhân bản khi F5
            response.sendRedirect(request.getContextPath() + "/store-manager/recruitment");
        } else {
            // Thất bại khi thao tác với Database
            request.setAttribute("error", "Thực hiện thao tác thất bại! Vui lòng thử lại.");
            loadFormData(request, user);
            request.getRequestDispatcher("/WEB-INF/views/store-manager/recruitment.jsp").forward(request, response);
        }
    }

    private void loadFormData(HttpServletRequest request, User user) {
        CommonDAO commonDAO = new CommonDAO();
        RecruitmentProposalDAO proposalDAO = new RecruitmentProposalDAO();
        BranchDAO branchDAO = new BranchDAO();

        // Lấy thông tin chi tiết chi nhánh quản lý dựa vào homeBranchId của Store Manager
        Branch currentBranch = branchDAO.getBranchById(user.getHomeBranchId());

        request.setAttribute("positions", commonDAO.getStoreEmployeePositions());
        request.setAttribute("proposals", proposalDAO.getProposalsByBranch(user.getHomeBranchId()));
        request.setAttribute("currentBranch", currentBranch);
    }
}