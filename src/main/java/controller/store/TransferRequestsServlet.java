package controller.store;

import controller.base.BaseServlet;
import dao.TemporaryTransferDAO;
import model.TemporaryTransfer;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;

@WebServlet(name = "TransferRequestsServlet", urlPatterns = {"/store-manager/transfer-requests"})
public class TransferRequestsServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        if (!isStoreManager(request) && user.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền truy cập trang quản lý đề xuất điều chuyển!");
            return;
        }

        int managerBranchId = getCurrentBranchId(request);
        if (managerBranchId == -1) {
            managerBranchId = 1;
        }

        TemporaryTransferDAO transferDAO = new TemporaryTransferDAO();
        
        // 1. Đổi tên attribute thành outgoingRequests để khớp hoàn toàn với file transfer-requests.jsp
        request.setAttribute("outgoingRequests", transferDAO.getTransfersByStore(managerBranchId, false));
        
        // 2. Đổi tên attribute thành incomingRequests để khớp hoàn toàn với file transfer-requests.jsp
        request.setAttribute("incomingRequests", transferDAO.getTransfersByStore(managerBranchId, true));

        // 3. Lấy danh sách nhân viên thuộc cơ sở này để đổ vào dropdown lựa chọn trong Modal Phê Duyệt
        request.setAttribute("branchEmployees", transferDAO.getEmployeesByBranch(managerBranchId));

        // Forward sang trang JSP hiển thị danh sách đề xuất
        request.getRequestDispatcher("/WEB-INF/views/store-manager/transfer-requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null || (!isStoreManager(request) && user.getRoleId() != ROLE_ADMIN)) {
            redirectToLogin(request, response);
            return;
        }

        int managerBranchId = getCurrentBranchId(request);
        if (managerBranchId == -1) {
            managerBranchId = 1;
        }

        String action = getStringParameter(request, "action");
        TemporaryTransferDAO transferDAO = new TemporaryTransferDAO();

        // Trường hợp 1: Tạo đề xuất mới từ modal trang lịch
        if ("createTransferProposal".equals(action)) {
            int sourceStoreId = getIntParameter(request, "sourceStoreId", -1);
            int positionId = getIntParameter(request, "positionId", -1);
            int shiftId = getIntParameter(request, "shiftId", -1);
            String workDateStr = getStringParameter(request, "workDate");
            int requiredCount = getIntParameter(request, "requiredCount", 0);
            String reason = getStringParameter(request, "reason");
            String startDate = getStringParameter(request, "startDate");

            if (managerBranchId != -1 && sourceStoreId != -1 && positionId != -1 && shiftId != -1 && workDateStr != null) {
                try {
                    TemporaryTransfer transfer = new TemporaryTransfer();
                    transfer.setRequesterId(user.getId());
                    transfer.setDestinationStoreId(managerBranchId);
                    transfer.setSourceStoreId(sourceStoreId);
                    transfer.setPositionId(positionId);
                    transfer.setShiftId(shiftId);
                    transfer.setWorkDate(Date.valueOf(workDateStr));
                    transfer.setRequiredCount(requiredCount);
                    transfer.setReason(reason);

                    transferDAO.insertTransferProposal(transfer);
                    request.getSession().setAttribute("message", "Gửi đề xuất mượn nhân sự thành công!");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.getSession().setAttribute("error", "Lỗi khi tạo đề xuất mượn nhân sự.");
                }
            }

            // Redirect ngược lại trang lịch và giữ nguyên tuần đang xem
            String redirectUrl = "schedule?success=transfer_created";
            if (startDate != null && !startDate.trim().isEmpty()) {
                redirectUrl += "&startDate=" + startDate;
            }
            response.sendRedirect(redirectUrl);
            return;
        }

        // Trường hợp 2: Cơ sở cho mượn bấm Phê duyệt và chọn nhân sự cử đi
        else if ("approveTransfer".equals(action)) {
            int requestId = getIntParameter(request, "requestId", -1);
            int selectedUserId = getIntParameter(request, "selectedUserId", -1);

            if (requestId != -1 && selectedUserId != -1) {
                boolean success = transferDAO.approveTransfer(requestId, selectedUserId);
                if (success) {
                    request.getSession().setAttribute("message", "Đã phê duyệt và cử nhân viên sang hỗ trợ thành công!");
                } else {
                    request.getSession().setAttribute("error", "Phê duyệt thất bại!");
                }
            }
        }

        // Trường hợp 3: Cơ sở cho mượn bấm Từ chối yêu cầu
        else if ("rejectTransfer".equals(action)) {
            int requestId = getIntParameter(request, "requestId", -1);

            if (requestId != -1) {
                boolean success = transferDAO.rejectTransfer(requestId);
                if (success) {
                    request.getSession().setAttribute("message", "Đã từ chối yêu cầu mượn nhân sự.");
                } else {
                    request.getSession().setAttribute("error", "Thao tác từ chối thất bại!");
                }
            }
        }

        // Điều hướng PRG về trang quản lý điều chuyển sau khi thực hiện xong hành động
        response.sendRedirect(request.getContextPath() + "/store-manager/transfer-requests");
    }
}