package controller.store;

import controller.base.BaseServlet;
import dao.BranchDAO;
import dao.TemporaryTransferDAO;
import model.Branch;
import model.TemporaryTransfer;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.*;

@WebServlet(name="TransferRequestsServlet", urlPatterns="/store-manager/transfer-requests")
public class TransferRequestsServlet extends BaseServlet {
    private boolean permitted(HttpServletRequest req) {
        User u = getCurrentUser(req);
        return u != null && (isStoreManager(req) || u.getRoleId() == ROLE_ADMIN);
    }
    private int branch(HttpServletRequest req) {
        return getCurrentBranchId(req);
    }
    
    @Override 
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (getCurrentUser(req) == null) {
            redirectToLogin(req, resp);
            return;
        }
        if (!permitted(req) || branch(req) <= 0) {
            sendForbidden(req, resp, "Bạn không có quyền xem đề xuất tại cơ sở này");
            return;
        }
        
        TemporaryTransferDAO dao = new TemporaryTransferDAO();
        BranchDAO branchDAO = new BranchDAO();
        
        try {
            Branch currentBranch = branchDAO.getBranchById(branch(req));
            req.setAttribute("currentBranch", currentBranch);

            List<TemporaryTransfer> outgoing = dao.getTransfersByStore(branch(req), false);
            List<TemporaryTransfer> incoming = dao.getTransfersByStore(branch(req), true);
            
            // Đã sửa lại kiểu Generics chuẩn xác, không bị dư thừa ký tự
            Map<Integer, List> eligibles = new HashMap<>();
            Map<Integer, List> selected = new HashMap<>();
            
            for (TemporaryTransfer t : incoming) {
                if (TemporaryTransferDAO.PENDING_MANAGER.equals(t.getStatus())) {
                    eligibles.put(t.getId(), dao.getEligibleEmployees(t.getId(), branch(req)));
                }
                selected.put(t.getId(), dao.getSelectedEmployees(t.getId()));
            }
            
            for (TemporaryTransfer t : outgoing) {
                selected.put(t.getId(), dao.getSelectedEmployees(t.getId()));
            }
            
            req.setAttribute("outgoingRequests", outgoing);
            req.setAttribute("incomingRequests", incoming);
            req.setAttribute("eligibleByTransfer", eligibles);
            req.setAttribute("selectedByTransfer", selected);
            
            req.setAttribute("message", req.getSession().getAttribute("transferMessage"));
            req.getSession().removeAttribute("transferMessage");
            req.setAttribute("error", req.getSession().getAttribute("transferError"));
            req.getSession().removeAttribute("transferError");
            
            req.getRequestDispatcher("/WEB-INF/views/store-manager/transfer-requests.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException("Không thể tải đề xuất", ex);
        }
    }
    
    @Override 
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (getCurrentUser(req) == null) {
            redirectToLogin(req, resp);
            return;
        }
        if (!permitted(req) || branch(req) <= 0) {
            sendForbidden(req, resp, "Không có quyền thao tác tại cơ sở này");
            return;
        }
        
        String action = getStringParameter(req, "action");
        TemporaryTransferDAO dao = new TemporaryTransferDAO();
        boolean ok = false;
        try {
            if ("createTransferProposal".equals(action)) {
                TemporaryTransfer t = new TemporaryTransfer();
                t.setRequesterId(getCurrentUser(req).getId());
                t.setDestinationStoreId(branch(req));
                t.setSourceStoreId(getIntParameter(req, "sourceStoreId", -1));
                t.setPositionId(getIntParameter(req, "positionId", -1));
                t.setShiftId(getIntParameter(req, "shiftId", -1));
                t.setWorkDate(Date.valueOf(getStringParameter(req, "workDate")));
                t.setRequestedCount(getIntParameter(req, "requestedCount", -1));
                t.setReason(getStringParameter(req, "reason"));
                
                ok = t.getWorkDate().toLocalDate().isAfter(java.time.LocalDate.now()) 
                     && t.getSourceStoreId() > 0 && t.getPositionId() > 0 
                     && t.getShiftId() > 0 && dao.insertTransferProposal(t);
                     
                req.getSession().setAttribute(ok ? "transferMessage" : "transferError", 
                    ok ? "Đã gửi đề xuất." : "Đề xuất không hợp lệ, trùng hoặc vượt số người thiếu.");
                    
                String startDate = getStringParameter(req, "startDate");
                String url = req.getContextPath() + "/store-manager/schedule" + (startDate != null && startDate.matches("\\d{4}-\\d{2}-\\d{2}") ? "?startDate=" + startDate : "");
                resp.sendRedirect(url);
                return;
            } else if ("approveTransfer".equals(action)) {
                int id = getIntParameter(req, "requestId", -1);
                String[] values = req.getParameterValues("selectedUserId");
                List<Integer> people = new ArrayList<>();
                if (values != null) {
                    for (String v : values) {
                        people.add(Integer.parseInt(v));
                    }
                }
                ok = dao.approveTransfer(id, people, branch(req));
            } else if ("rejectTransfer".equals(action)) {
                ok = dao.rejectTransfer(getIntParameter(req, "requestId", -1), branch(req), getStringParameter(req, "rejectReason"));
            } else {
                resp.sendError(400, "Action không hợp lệ");
                return;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            ok = false;
        }
        req.getSession().setAttribute(ok ? "transferMessage" : "transferError", 
            ok ? "Đã cập nhật đề xuất thành công (có thể hỗ trợ một phần)." : "Không thể xử lý. Kiểm tra số người dư: số đã xếp trừ người cho mượn phải >= định mức; đồng thời kiểm tra lịch và trạng thái đơn.");
        resp.sendRedirect(req.getContextPath() + "/store-manager/transfer-requests");
    }
}