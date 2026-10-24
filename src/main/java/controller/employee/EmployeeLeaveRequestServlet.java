package controller.employee;

import dao.LeaveBalanceDAO;
import dao.LeaveRequestDAO;
import dao.LeaveTypeDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

@WebServlet(
    name = "EmployeeLeaveRequestServlet",
    urlPatterns = {"/employee/leave-request"}
)
public class EmployeeLeaveRequestServlet extends HttpServlet {

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null
                : (User) session.getAttribute("account");
    }

    private void showPage(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            LeaveTypeDAO typeDao = new LeaveTypeDAO();
            LeaveBalanceDAO balanceDao = new LeaveBalanceDAO();
            LeaveRequestDAO requestDao = new LeaveRequestDAO();

            req.setAttribute(
                "leaveTypes",
                typeDao.getAll()
            );

            req.setAttribute(
                "myBalances",
                balanceDao.getMyBalances(
                    user.getId(),
                    LocalDate.now().getYear()
                )
            );

            req.setAttribute(
                "myRequests",
                requestDao.getMyRequests(user.getId())
            );

            req.getRequestDispatcher(
                "/WEB-INF/views/employee/leave-request.jsp"
            ).forward(req, resp);

        } catch (IllegalStateException e) {
            throw new ServletException(e);
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

        if (user.getRoleId() != 5) {
            resp.sendError(403);
            return;
        }

        showPage(req, resp, user);
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

        if (user.getRoleId() != 5) {
            resp.sendError(403);
            return;
        }

        String action = req.getParameter("action");

        if ("cancel".equals(action)) {
            handleCancel(req, resp, user);
            return;
        }

        handleCreate(req, resp, user);
    }

    private void handleCreate(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            String leaveTypeRaw = req.getParameter("leaveTypeId");
            String startRaw = req.getParameter("startDate");
            String endRaw = req.getParameter("endDate");

            if (leaveTypeRaw == null || leaveTypeRaw.trim().isEmpty()) {
                req.setAttribute(
                    "error",
                    "Vui lòng chọn loại nghỉ phép."
                );
                showPage(req, resp, user);
                return;
            }

            if (startRaw == null || startRaw.trim().isEmpty()
                || endRaw == null || endRaw.trim().isEmpty()) {
                req.setAttribute(
                    "error",
                    "Vui lòng chọn ngày bắt đầu và ngày kết thúc."
                );
                showPage(req, resp, user);
                return;
            }

            int leaveTypeId = Integer.parseInt(leaveTypeRaw.trim());

            LocalDate startDate = LocalDate.parse(startRaw.trim());
            LocalDate endDate = LocalDate.parse(endRaw.trim());

            String reason = req.getParameter("reason");

            LeaveBalanceDAO balanceDao = new LeaveBalanceDAO();

            // Validate ngày
            if (startDate.isAfter(endDate)) {
                req.setAttribute(
                    "error",
                    "Ngày bắt đầu phải trước hoặc bằng ngày kết thúc."
                );
                showPage(req, resp, user);
                return;
            }

            if (startDate.isBefore(LocalDate.now())) {
                req.setAttribute(
                    "error",
                    "Không thể xin nghỉ cho ngày trong quá khứ."
                );
                showPage(req, resp, user);
                return;
            }

            // Validate lý do
            if (reason == null
                || reason.trim().isEmpty()
                || reason.trim().length() > 500) {

                req.setAttribute(
                    "error",
                    "Vui lòng nhập lý do (tối đa 500 ký tự)."
                );
                showPage(req, resp, user);
                return;
            }

            // Tính số ngày nghỉ
            int totalDays = (int) ChronoUnit.DAYS.between(
                startDate, endDate
            ) + 1;

            // Kiểm tra quota còn đủ không (chặn sớm để nhân viên biết)
            int balanceTotal = balanceDao.getTotalDays(
                user.getId(), leaveTypeId, startDate.getYear()
            );

            if (balanceTotal > 0) {
                int balanceUsed = balanceDao.getUsedDays(
                    user.getId(), leaveTypeId, startDate.getYear()
                );

                if (balanceUsed + totalDays > balanceTotal) {
                    req.setAttribute(
                        "error",
                        "Không đủ quota. Bạn chỉ còn "
                        + Math.max(0, balanceTotal - balanceUsed)
                        + " ngày "
                        + "nhưng đơn này dùng " + totalDays + " ngày."
                    );
                    showPage(req, resp, user);
                    return;
                }
            }

            // Tạo đơn (hệ thống sẽ kiểm tra quota khi duyệt)
            LeaveRequestDAO dao = new LeaveRequestDAO();
            boolean success = dao.createRequest(
                user.getId(),
                leaveTypeId,
                startDate,
                endDate,
                totalDays,
                reason.trim()
            );

            resp.sendRedirect(
                req.getContextPath()
                + "/employee/leave-request?"
                + (success ? "success=1" : "invalid=1")
            );

        } catch (NumberFormatException e) {
            req.setAttribute(
                "error",
                "Vui lòng chọn loại nghỉ phép hợp lệ."
            );
            showPage(req, resp, user);

        } catch (DateTimeParseException e) {
            req.setAttribute(
                "error",
                "Ngày không hợp lệ. Vui lòng chọn đúng định dạng (YYYY-MM-DD)."
            );
            showPage(req, resp, user);

        } catch (IllegalArgumentException e) {
            req.setAttribute(
                "error",
                "Thông tin ngày không hợp lệ."
            );
            showPage(req, resp, user);

        } catch (Exception e) {
            throw new ServletException(
                "Cannot create leave request", e
            );
        }
    }

    private void handleCancel(
            HttpServletRequest req,
            HttpServletResponse resp,
            User user)
            throws ServletException, IOException {

        try {
            int requestId = Integer.parseInt(
                req.getParameter("requestId")
            );

            LeaveRequestDAO dao = new LeaveRequestDAO();
            boolean success = dao.cancelMyRequest(requestId, user.getId());

            resp.sendRedirect(
                req.getContextPath()
                + "/employee/leave-request?"
                + (success ? "success=1" : "invalid=1")
            );

        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid request id");

        } catch (Exception e) {
            throw new ServletException(
                "Cannot cancel leave request", e
            );
        }
    }
}