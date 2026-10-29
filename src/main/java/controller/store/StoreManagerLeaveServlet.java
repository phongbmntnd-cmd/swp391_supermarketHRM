package controller.store;

import dao.LeaveCoverageDAO;
import dao.LeaveRequestDAO;
import dao.LeaveShiftDetailDAO;
import model.LeaveRequestShift;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Màn hình Store Manager duyệt đơn nghỉ phép - mô hình "C trên nền B".
 *
 * Ngoài danh sách đơn, màn hình này hiển thị:
 *   - Chi tiết ca bị nghỉ của từng đơn (phần "C").
 *   - Cảnh báo ca sẽ thiếu người sau khi duyệt, để SM điều người cover.
 */
@WebServlet(
    name = "StoreManagerLeaveServlet",
    urlPatterns = {"/store-manager/leave-requests"}
)
public class StoreManagerLeaveServlet extends HttpServlet {

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null
                : (User) session.getAttribute("account");
    }

    @Override
    protected void doGet(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        User user = currentUser(req);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (user.getRoleId() != 4 || user.getHomeBranchId() <= 0) {
            resp.sendError(403);
            return;
        }

        try {
            LeaveRequestDAO dao = new LeaveRequestDAO();
            int branchId = user.getHomeBranchId();

            List<Map<String, Object>> requestList =
                    dao.getBranchRequests(branchId);

            // Nạp chi tiết ca cho tất cả đơn (tránh N+1 query)
            List<Integer> ids = new ArrayList<>();
            for (Map<String, Object> r : requestList) {
                ids.add(toInt(r.get("id")));
            }

            Map<Integer, List<LeaveRequestShift>> detailsByRequest =
                    new LeaveShiftDetailDAO().getByRequestIds(ids);

            // Gắn chi tiết ca vào từng dòng để JSP hiển thị
            for (Map<String, Object> r : requestList) {
                int id = toInt(r.get("id"));
                List<LeaveRequestShift> details =
                        detailsByRequest.get(id);
                r.put("shiftDetails",
                        details == null ? new ArrayList<>() : details);
                r.put("shiftCount", details == null ? 0 : details.size());
            }

            // Tình trạng nhân sự của các ca bị nghỉ (phần "C").
            // SM thấy ngay ca nào sẽ thiếu người TRƯỚC khi bấm duyệt.
            LeaveCoverageDAO coverageDao = new LeaveCoverageDAO();
            for (Map<String, Object> r : requestList) {
                int id = toInt(r.get("id"));
                List<Map<String, Object>> cov =
                        coverageDao.getCoverageStatus(branchId, id);

                int missing = 0;
                for (Map<String, Object> row : cov) {
                    if (Boolean.TRUE.equals(row.get("warning"))) {
                        missing++;
                    }
                }

                r.put("coverage", cov);
                r.put("coverageWarningCount", missing);
                r.put("hasCoverageWarning", missing > 0);
            }

            req.setAttribute("requestList", requestList);

            // Tổng hợp thời gian nghỉ theo từng loại của chi nhánh.
            List<Map<String, Object>> leaveSummary =
                    new dao.LeaveBalanceDAO()
                        .getBranchLeaveSummary(
                            branchId,
                            java.time.LocalDate.now().getYear()
                        );

            req.setAttribute("leaveSummary", leaveSummary);

            // Tổng thời gian nghỉ của TẤT CẢ nhân viên trong chi nhánh.
            req.setAttribute(
                "branchTotalHours",
                sumTotalHours(leaveSummary)
            );

            // Định nghĩa ca để SM hiểu giờ nghỉ tương ứng với ca nào.
            req.setAttribute(
                "shiftDefinitions",
                new dao.LeaveShiftOptionDAO().getShiftDefinitions()
            );

            req.getRequestDispatcher(
                "/WEB-INF/views/store-manager/leave-requests.jsp"
            ).forward(req, resp);

        } catch (IllegalStateException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        User user = currentUser(req);

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (user.getRoleId() != 4 || user.getHomeBranchId() <= 0) {
            resp.sendError(403);
            return;
        }

        try {
            String action = req.getParameter("action");

            int requestId = Integer.parseInt(
                req.getParameter("requestId")
            );

            String responseText = req.getParameter("response");

            if (responseText != null && responseText.length() > 255) {
                resp.sendError(400, "Response too long");
                return;
            }

            // ---- Thu hồi đơn đã duyệt ----
            // Hoàn lại quota, gỡ ca ON_LEAVE, đóng ca trống phát sinh.
            if ("revoke".equals(action)) {
                handleRevoke(req, resp, user, requestId, responseText);
                return;
            }

            boolean approve = "approve".equals(action);

            // Cảnh báo thiếu người trước khi duyệt (để SM biết và
            // chủ động điều người cover).
            String warning = "";
            if (approve) {
                warning = new LeaveCoverageDAO().getCoverageWarning(
                        user.getHomeBranchId(), requestId);
            }

            LeaveRequestDAO dao = new LeaveRequestDAO();
            boolean success = dao.review(
                requestId,
                user.getHomeBranchId(),
                approve,
                responseText,
                user.getId()
            );

            if (success) {
                resp.sendRedirect(
                    req.getContextPath()
                    + "/store-manager/leave-requests?success=1"
                    + (warning.isEmpty() ? "" : "&warn=" + java.net.URLEncoder.encode(warning, "UTF-8"))
                );
                return;
            }

            // Thất bại: phân biệt nguyên nhân để SM hiểu vì sao không duyệt được
            String reason = dao.getReviewFailureReason(
                requestId,
                user.getHomeBranchId(),
                approve
            );

            resp.sendRedirect(
                req.getContextPath()
                + "/store-manager/leave-requests?error="
                + java.net.URLEncoder.encode(reason, "UTF-8")
            );

        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid request id");

        } catch (Exception e) {
            throw new ServletException(
                "Cannot process leave request", e
            );
        }
    }

    /**
     * Xử lý thu hồi đơn nghỉ phép đã duyệt.
     *
     * <p>Khác với duyệt/từ chối, thao tác này thay đổi trạng thái
     * đã có hiệu lực nên cần thông báo rõ cho SM kết quả.
     */
    private void handleRevoke(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user,
            int requestId,
            String reason) throws IOException, ServletException {

        LeaveRequestDAO dao = new LeaveRequestDAO();

        boolean success;
        try {
            success = dao.revokeApprovedRequest(
                    requestId,
                    user.getHomeBranchId(),
                    user.getId(),
                    reason);
        } catch (Exception e) {
            throw new ServletException(
                    "Cannot revoke leave request", e);
        }

        if (success) {
            resp.sendRedirect(
                    req.getContextPath()
                    + "/store-manager/leave-requests?success=1"
                    + "&msg="
                    + java.net.URLEncoder.encode(
                        "Đã thu hồi đơn #" + requestId
                        + ". Quota đã được hoàn lại và các ca "
                        + "liên quan đã được mở lại.",
                        "UTF-8"));
            return;
        }

        // Thất bại -> chỉ ra nguyên nhân cụ thể
        String msg = dao.getReviewFailureReason(
                requestId, user.getHomeBranchId(), false);

        if (msg == null || msg.isEmpty()) {
            msg = "Không thể thu hồi đơn này. "
                    + "Chỉ thu hồi được đơn đang ở trạng thái ĐÃ DUYỆT.";
        }

        resp.sendRedirect(
                req.getContextPath()
                + "/store-manager/leave-requests?error="
                + java.net.URLEncoder.encode(msg, "UTF-8"));
    }

    private int toInt(Object o) {
        if (o instanceof Number) {
            return ((Number) o).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(o));
        } catch (Exception e) {
            return -1;
        }
    }

    /**
     * Tổng tất cả thời gian nghỉ (đã duyệt + chờ duyệt) của chi nhánh.
     */
    private double sumTotalHours(List<Map<String, Object>> summary) {
        double sum = 0;
        if (summary == null) {
            return 0;
        }
        for (Map<String, Object> row : summary) {
            Object v = row.get("totalHours");
            if (v instanceof Number) {
                sum += ((Number) v).doubleValue();
            }
        }
        return sum;
    }
}
