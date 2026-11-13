package controller.store;

import dao.ShiftChangeRequestDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(
        name = "StoreManagerRequestController",
        urlPatterns = {"/store-manager/shift-requests"}
)
public class StoreManagerRequestController extends HttpServlet {

    private int resolveManagedBranchId(HttpServletRequest req, User user) {
        if (user == null || user.getRoleId() != 4) {
            return -1;
        }

        HttpSession session = req.getSession(false);
        if (session == null) {
            return -1;
        }

        int selectedBranchId = user.getHomeBranchId();
        Object value = session.getAttribute("currentBranchId");

        if (value instanceof Number) {
            selectedBranchId = ((Number) value).intValue();
        }

        dao.BranchDAO branchDAO = new dao.BranchDAO();

        for (model.Branch branch
                : branchDAO.getManagedBranches(user.getId())) {

            if (branch.getId() == selectedBranchId
                    && "ACTIVE".equals(branch.getStatus())) {
                return selectedBranchId;
            }
        }

        return -1;
    }

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null
                : (User) session.getAttribute("account");
    }

    /**
     * Parse số nguyên an toàn.
     *
     * <p>
     * Trước đây dùng {@code Integer.parseInt(param)} trực tiếp: khi Store chọn
     * giá trị mặc định {@code -- Chọn ca --} (value="") thì ném
     * {@link NumberFormatException} và người dùng thấy trang lỗi 400 trắng,
     * không biết mình sai ở đâu.
     *
     * @return giá trị số, hoặc 0 nếu rỗng / không phải số
     */
    private int parseIntOrZero(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
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

        int branchId = resolveManagedBranchId(req, user);

        if (branchId <= 0) {
            resp.sendError(403,
                    "Bạn không có quyền xem ca thiếu tại chi nhánh này.");
            return;
        }

        // Lấy thông tin chi nhánh đang được SM quản lý
        dao.BranchDAO branchDAO = new dao.BranchDAO();
        model.Branch currentBranch
                = branchDAO.getBranchById(branchId);

        if (currentBranch == null) {
            throw new ServletException(
                    "Không tìm thấy chi nhánh có ID: " + branchId);
        }

        String displayBranchInfo
                = currentBranch.getName()
                + " (" + currentBranch.getCode() + ") - "
                + currentBranch.getAddress();

        req.setAttribute("currentBranch", currentBranch);
        req.setAttribute("displayBranchInfo", displayBranchInfo);

        try {
            ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

            req.setAttribute(
                    "requestList",
                    dao.getBranchRequests(branchId)
            );

            // Danh sách ca trống của chi nhánh + dữ liệu để tạo mới
            req.setAttribute(
                    "openShiftList",
                    dao.getBranchOpenShifts(branchId)
            );

            req.setAttribute(
                    "allShifts",
                    dao.getAllShifts()
            );

            // Chỉ chức vụ của nhân viên vận hành (thu ngân, bán hàng,
            // kho...) - không có Giám Đốc / các loại Quản lý.
            req.setAttribute(
                    "allPositions",
                    dao.getShiftPositions()
            );

            req.getRequestDispatcher(
                    "/WEB-INF/views/store-manager/shift-requests.jsp"
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

        int branchId = resolveManagedBranchId(req, user);

        if (branchId <= 0) {
            resp.sendError(403,
                    "Bạn không có quyền thao tác tại chi nhánh này.");
            return;
        }

        try {
            String action = req.getParameter("action");

            // Tạo ca trống để nhân viên có thể đề nghị chuyển sang
            if ("createOpenShift".equals(action)) {

                int shiftId = parseIntOrZero(req.getParameter("shiftId"));
                int positionId = parseIntOrZero(req.getParameter("positionId"));

                String dateRaw = req.getParameter("workDate");

                if (shiftId <= 0 || positionId <= 0) {
                    resp.sendRedirect(
                            req.getContextPath()
                            + "/store-manager/shift-requests?"
                            + "invalid=1&reason=missing");
                    return;
                }

                if (dateRaw == null || dateRaw.trim().isEmpty()) {
                    resp.sendRedirect(
                            req.getContextPath()
                            + "/store-manager/shift-requests?"
                            + "invalid=1&reason=missing");
                    return;
                }

                java.time.LocalDate workDate;
                try {
                    workDate = java.time.LocalDate.parse(dateRaw.trim());
                } catch (Exception e) {
                    resp.sendRedirect(
                            req.getContextPath()
                            + "/store-manager/shift-requests?"
                            + "invalid=1&reason=date");
                    return;
                }

                ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

                boolean success = dao.createOpenShift(
                        branchId,
                        shiftId,
                        positionId,
                        workDate
                );

                resp.sendRedirect(
                        req.getContextPath()
                        + "/store-manager/shift-requests?"
                        + (success ? "openCreated=1" : "invalid=1"));
                return;
            }

            // Đóng ca trống thủ công (ca không còn ai nhận được).
            if ("closeOpenShift".equals(action)) {

                int openShiftId = parseIntOrZero(req.getParameter("openShiftId"));

                if (openShiftId <= 0) {
                    resp.sendRedirect(
                            req.getContextPath()
                            + "/store-manager/shift-requests?"
                            + "invalid=1&reason=missing");
                    return;
                }

                ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

                boolean success = dao.closeOpenShift(
                        branchId,
                        openShiftId
                );

                resp.sendRedirect(
                        req.getContextPath()
                        + "/store-manager/shift-requests?"
                        + (success ? "openClosed=1" : "invalid=1"));
                return;
            }

            if (!"approve".equals(action)
                    && !"reject".equals(action)) {
                resp.sendError(400, "Invalid action");
                return;
            }

            int requestId = Integer.parseInt(
                    req.getParameter("requestId")
            );

            String responseText = req.getParameter("response");

            if (responseText != null
                    && responseText.length() > 255) {
                resp.sendError(400, "Response too long");
                return;
            }

            ShiftChangeRequestDAO dao = new ShiftChangeRequestDAO();

            boolean success = dao.review(
                    requestId,
                    branchId,
                    "approve".equals(action),
                    responseText == null ? null : responseText.trim()
            );

            resp.sendRedirect(
                    req.getContextPath()
                    + "/store-manager/shift-requests?"
                    + (success ? "success=1" : "invalid=1")
            );

        } catch (IllegalArgumentException e) {
            resp.sendError(400, "Invalid submitted data");

        } catch (Exception e) {
            throw new ServletException(
                    "Cannot process shift request", e
            );
        }
    }
}
