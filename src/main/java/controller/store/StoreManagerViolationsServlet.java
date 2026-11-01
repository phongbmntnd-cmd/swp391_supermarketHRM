package controller.store;

import controller.base.BaseServlet;
import dao.ViolationDAO;
import dao.BranchDAO;
import model.Branch;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URI;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebServlet("/store-manager/violations")
public class StoreManagerViolationsServlet extends BaseServlet {

    private static final BigDecimal MAX_DEDUCTION_AMOUNT = new BigDecimal("9999999999.99");
    private final ViolationDAO violationDAO = new ViolationDAO();
    private final BranchDAO branchDAO = new BranchDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }
        if (user.getRoleId() != ROLE_STORE_MANAGER || user.getHomeBranchId() <= 0) {
            sendForbidden(request, response, "Chỉ quản lý cửa hàng có cơ sở hợp lệ mới được báo cáo vi phạm.");
            return;
        }

        try {
            // Lấy thông tin chi tiết chi nhánh để hiển thị lên giao diện
            int branchId = user.getHomeBranchId();
            Branch currentBranch = branchDAO.getBranchById(branchId);
            if (currentBranch == null) {
                currentBranch = new Branch();
                currentBranch.setId(branchId);
                currentBranch.setName("Chi nhánh mặc định");
                currentBranch.setCode("BRANCH-" + branchId);
                currentBranch.setAddress("Đang cập nhật");
            }
            request.setAttribute("currentBranch", currentBranch);

            request.setAttribute("today", LocalDate.now().toString());
            request.setAttribute("employees", violationDAO.getBranchEmployees(branchId));
            request.setAttribute("violations", violationDAO.getByBranch(branchId));
            request.setAttribute("successMessage", getAndClearSuccessMessage(request));
            request.setAttribute("errorMessage", getAndClearErrorMessage(request));
            request.getRequestDispatcher("/WEB-INF/views/store-manager/violations.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải danh sách vi phạm của chi nhánh.", e);
        }
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
        if (user.getRoleId() != ROLE_STORE_MANAGER || user.getHomeBranchId() <= 0) {
            sendForbidden(request, response, "Chỉ quản lý cửa hàng có cơ sở hợp lệ mới được báo cáo vi phạm.");
            return;
        }

        try {
            int employeeId = getIntParameter(request, "employeeId", -1);
            String title = getStringParameter(request, "title");
            String category = getStringParameter(request, "category");
            String description = getStringParameter(request, "description");
            String evidenceUrl = getStringParameter(request, "evidenceUrl");
            String dateValue = getStringParameter(request, "violationDate");
            String deductionValue = getStringParameter(request, "deductionAmount");
            BigDecimal deductionAmount = parseDeductionAmount(deductionValue);
            if (employeeId <= 0 || title == null || title.length() > 100
                    || description == null || description.length() > 2000
                    || !isCategory(category) || dateValue == null
                    || deductionAmount == null
                    || (evidenceUrl != null && (evidenceUrl.length() > 255 || !isHttpUrl(evidenceUrl)))) {
                setErrorMessage(request, "Dữ liệu không hợp lệ. Hãy kiểm tra nhân viên, loại vi phạm, mô tả, bằng chứng và khoản khấu trừ (0 đến 9.999.999.999,99 đồng, tối đa 2 chữ số thập phân).");
                response.sendRedirect(request.getContextPath() + "/store-manager/violations");
                return;
            }

            LocalDate violationDate = LocalDate.parse(dateValue);
            if (violationDate.isAfter(LocalDate.now())) {
                setErrorMessage(request, "Ngày xảy ra vi phạm không được ở tương lai.");
            } else if (violationDAO.createReport(employeeId, user.getHomeBranchId(), user.getId(),
                    title, category, description, evidenceUrl, Date.valueOf(violationDate), deductionAmount)) {
                setSuccessMessage(request, "Đã ghi nhận báo cáo và khoản khấu trừ lương. Dữ liệu đã sẵn sàng để tổng hợp theo tháng xảy ra vi phạm khi tính lương.");
            } else {
                setErrorMessage(request, "Không tạo được báo cáo. Nhân viên có thể không thuộc chi nhánh hoặc đã ngừng hoạt động.");
            }
        } catch (DateTimeParseException e) {
            setErrorMessage(request, "Ngày vi phạm không hợp lệ.");
        } catch (Exception e) {
            throw new ServletException("Không thể tạo báo cáo vi phạm.", e);
        }
        response.sendRedirect(request.getContextPath() + "/store-manager/violations");
    }

    private boolean isCategory(String category) {
        return "ATTENDANCE".equals(category) || "WORKPLACE_CONDUCT".equals(category)
                || "WORK_PERFORMANCE".equals(category) || "OPERATIONAL".equals(category);
    }

    private BigDecimal parseDeductionAmount(String value) {
        if (value == null) {
            return null;
        }
        try {
            BigDecimal amount = new BigDecimal(value);
            if (amount.signum() < 0 || amount.scale() > 2
                    || amount.compareTo(MAX_DEDUCTION_AMOUNT) > 0) {
                return null;
            }
            return amount;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean isHttpUrl(String value) {
        try {
            URI uri = URI.create(value);
            String scheme = uri.getScheme();
            return uri.getHost() != null
                    && ("http".equalsIgnoreCase(scheme) || "https".equalsIgnoreCase(scheme));
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}