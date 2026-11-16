package controller.hr;

import controller.base.BaseServlet;
import context.DBContext;
import model.User;
import dao.BranchDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.sql.Statement;
import java.sql.SQLException;
import java.util.UUID;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.sql.Date;
import java.sql.SQLException;

@WebServlet("/hr/branch-request")
public class HRBranchRequestServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER
                && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response,
                    "Bạn không có quyền xem yêu cầu mở chi nhánh!");
            return;
        }

        List<Map<String, Object>> branchRequests = new ArrayList<>();

        String sql
                = "SELECT br.*, "
                + "b.store_manager_id, "
                + "b.status AS branch_status, "
                + "a.end_date AS assignment_end_date "
                + "FROM branch_requests br "
                + "LEFT JOIN branches b ON br.branch_id = b.id "
                + "LEFT JOIN branch_manager_assignments a "
                + "ON a.id = ( "
                + "    SELECT MAX(a2.id) "
                + "    FROM branch_manager_assignments a2 "
                + "    WHERE a2.branch_id = b.id "
                + ") "
                + "ORDER BY br.created_at DESC";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();

                item.put("id", rs.getInt("id"));
                item.put("branchName", rs.getString("branch_name"));
                item.put("branchAddress", rs.getString("branch_address"));
                item.put("expectedOpeningDate", rs.getDate("expected_opening_date"));
                item.put("reason", rs.getString("reason"));
                item.put("requestedBy", rs.getInt("requested_by"));
                item.put("status", rs.getString("status"));
                item.put("createdAt", rs.getTimestamp("created_at"));
                item.put("storeManagerId", rs.getObject("store_manager_id"));
                item.put("assignmentEndDate", rs.getDate("assignment_end_date"));
                item.put("branchStatus", rs.getString("branch_status"));
                branchRequests.add(item);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error",
                    "Không thể tải danh sách yêu cầu mở chi nhánh.");
        }

        request.setAttribute("branchRequests", branchRequests);

        BranchDAO branchDAO = new BranchDAO();

        request.setAttribute(
                "availableManagers",
                branchDAO.getAvailableManagers()
        );

        request.getRequestDispatcher(
                "/WEB-INF/views/hr/branch-request.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER
                && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response,
                    "Bạn không có quyền xử lý yêu cầu!");
            return;
        }

        String action = request.getParameter("action");

        if ("assignManager".equals(action)) {
            assignManager(request, response);
            return;
        }

        if ("extendAssignment".equals(action)) {
            extendAssignment(request, response);
            return;
        }

        if ("activateBranch".equals(action)) {
            activateBranch(request, response);
            return;
        }

        if (!"startProcessing".equals(action)) {
            response.sendError(400, "Hành động không hợp lệ.");
            return;
        }

        int requestId;

        try {
            requestId = Integer.parseInt(
                    request.getParameter("requestId"));
            if (requestId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400, "Mã yêu cầu không hợp lệ.");
            return;
        }

        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Khóa yêu cầu để tránh xử lý trùng
            String selectSql
                    = "SELECT branch_name, branch_address, status "
                    + "FROM branch_requests WHERE id = ? FOR UPDATE";

            String branchName;
            String branchAddress;
            String status;

            try (PreparedStatement ps
                    = conn.prepareStatement(selectSql)) {

                ps.setInt(1, requestId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException(
                                "Không tìm thấy yêu cầu.");
                    }

                    branchName = rs.getString("branch_name");
                    branchAddress = rs.getString("branch_address");
                    status = rs.getString("status");
                }
            }

            if (!"PENDING_HR".equals(status)) {
                throw new IllegalStateException(
                        "Yêu cầu này đã được xử lý.");
            }

            // 2. Kiểm tra chi nhánh đã tồn tại
            String checkSql
                    = "SELECT id FROM branches "
                    + "WHERE LOWER(TRIM(name)) = LOWER(TRIM(?)) "
                    + "OR LOWER(TRIM(address)) = LOWER(TRIM(?)) "
                    + "LIMIT 1";

            try (PreparedStatement ps
                    = conn.prepareStatement(checkSql)) {

                ps.setString(1, branchName);
                ps.setString(2, branchAddress);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        throw new IllegalStateException(
                                "Chi nhánh đã tồn tại.");
                    }
                }
            }

            // 3. Tạo chi nhánh PREPARING
            // Dùng mã tạm, sau đó tạo mã BR theo ID
            String tempCode = "TMP"
                    + UUID.randomUUID().toString()
                            .replace("-", "").substring(0, 16);

            String insertSql
                    = "INSERT INTO branches "
                    + "(code, name, address, status, store_manager_id) "
                    + "VALUES (?, ?, ?, 'PREPARING', NULL)";

            int branchId;

            try (PreparedStatement ps
                    = conn.prepareStatement(
                            insertSql,
                            Statement.RETURN_GENERATED_KEYS)) {

                ps.setString(1, tempCode);
                ps.setString(2, branchName);
                ps.setString(3, branchAddress);

                if (ps.executeUpdate() != 1) {
                    throw new SQLException("Không thể tạo chi nhánh.");
                }

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new SQLException(
                                "Không lấy được ID chi nhánh.");
                    }
                    branchId = keys.getInt(1);
                }
            }

            // 4. Tạo mã chi nhánh, ví dụ BR004
            String branchCode = String.format("BR%03d", branchId);

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE branches SET code = ? WHERE id = ?")) {

                ps.setString(1, branchCode);
                ps.setInt(2, branchId);

                if (ps.executeUpdate() != 1) {
                    throw new SQLException("Không thể cập nhật mã.");
                }
            }

            // 5. Cập nhật yêu cầu
            String updateSql
                    = "UPDATE branch_requests "
                    + "SET status = 'IN_PROGRESS', branch_id = ? "
                    + "WHERE id = ? AND status = 'PENDING_HR'";

            try (PreparedStatement ps
                    = conn.prepareStatement(updateSql)) {

                ps.setInt(1, branchId);
                ps.setInt(2, requestId);

                if (ps.executeUpdate() != 1) {
                    throw new SQLException(
                            "Không thể cập nhật yêu cầu.");
                }
            }

            // 6. Lưu tất cả thay đổi
            conn.commit();

            response.sendRedirect(
                    request.getContextPath()
                    + "/hr/branch-request?success=1");
            return;

        } catch (Exception e) {

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/hr/branch-request?error=1");
            return;

        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

    }

    private void assignManager(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER
                && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response, "Bạn không có quyền bổ nhiệm quản lý!");
            return;
        }

        int requestId;
        int managerId;
        LocalDate startDate;
        LocalDate endDate;

        // 1. Validate dữ liệu từ form
        try {
            requestId = Integer.parseInt(request.getParameter("requestId"));
            managerId = Integer.parseInt(request.getParameter("managerId"));
            startDate = LocalDate.parse(request.getParameter("startDate"));
            endDate = LocalDate.parse(request.getParameter("endDate"));

            if (requestId <= 0 || managerId <= 0) {
                throw new IllegalArgumentException();
            }

            if (startDate.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException();
            }

            if (!endDate.isAfter(startDate)) {
                throw new IllegalArgumentException();
            }

        } catch (IllegalArgumentException e) {
            response.sendError(400, "Thông tin bổ nhiệm hoặc ngày kiêm nhiệm không hợp lệ.");
            return;
        }

        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 2. Kiểm tra người được chọn là Store Manager
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM users WHERE id = ? AND role_id = 4")) {

                ps.setInt(1, managerId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException(
                                "Người được chọn không phải Store Manager.");
                    }
                }
            }

            // 3. Kiểm tra yêu cầu và khóa chi nhánh để tránh bổ nhiệm trùng
            int branchId;

            String checkSql
                    = "SELECT b.id, b.status, b.store_manager_id "
                    + "FROM branch_requests br "
                    + "JOIN branches b ON br.branch_id = b.id "
                    + "WHERE br.id = ? AND br.status = 'IN_PROGRESS' "
                    + "FOR UPDATE";

            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, requestId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        throw new IllegalStateException(
                                "Yêu cầu chưa được xử lý hoặc không tồn tại.");
                    }

                    branchId = rs.getInt("id");

                    if (!"PREPARING".equals(rs.getString("status"))) {
                        throw new IllegalStateException(
                                "Chi nhánh không ở trạng thái PREPARING.");
                    }

                    if (rs.getObject("store_manager_id") != null) {
                        throw new IllegalStateException(
                                "Chi nhánh đã có Store Manager phụ trách.");
                    }
                }
            }

            // 4. Lưu thông tin kiêm nhiệm
            String insertSql
                    = "INSERT INTO branch_manager_assignments "
                    + "(branch_id, manager_id, start_date, end_date, assigned_by) "
                    + "VALUES (?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {

                ps.setInt(1, branchId);
                ps.setInt(2, managerId);
                ps.setDate(3, Date.valueOf(startDate));
                ps.setDate(4, Date.valueOf(endDate));
                ps.setInt(5, currentUser.getId());

                if (ps.executeUpdate() != 1) {
                    throw new SQLException("Không thể lưu thông tin bổ nhiệm.");
                }
            }

            // 5. Cập nhật Store Manager cho chi nhánh mới
            String updateSql
                    = "UPDATE branches SET store_manager_id = ? "
                    + "WHERE id = ? AND store_manager_id IS NULL "
                    + "AND status = 'PREPARING'";

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {

                ps.setInt(1, managerId);
                ps.setInt(2, branchId);

                if (ps.executeUpdate() != 1) {
                    throw new SQLException("Không thể cập nhật Store Manager.");
                }
            }

            conn.commit();

            response.sendRedirect(
                    request.getContextPath()
                    + "/hr/branch-request?assigned=1");
            return;

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/hr/branch-request?assignError=1");

        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void extendAssignment(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER
                && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response,
                    "Bạn không có quyền gia hạn quản lý!");
            return;
        }

        int requestId;
        LocalDate newEndDate;
        String reason = request.getParameter("extendReason");

        // 1. Validate dữ liệu
        try {
            requestId = Integer.parseInt(
                    request.getParameter("requestId"));

            newEndDate = LocalDate.parse(
                    request.getParameter("newEndDate"));

            if (requestId <= 0
                    || !newEndDate.isAfter(LocalDate.now())
                    || reason == null
                    || reason.trim().isEmpty()
                    || reason.trim().length() > 500) {

                throw new IllegalArgumentException();
            }

        } catch (Exception e) {
            response.sendError(400,
                    "Thông tin gia hạn không hợp lệ.");
            return;
        }

        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 2. Khóa bản ghi bổ nhiệm hiện tại
            String selectSql
                    = "SELECT a.id, a.end_date "
                    + "FROM branch_manager_assignments a "
                    + "JOIN branches b ON a.branch_id = b.id "
                    + "JOIN branch_requests br ON br.branch_id = b.id "
                    + "WHERE br.id = ? "
                    + "AND br.status = 'IN_PROGRESS' "
                    + "AND b.status IN ('PREPARING', 'ACTIVE') "
                    + "AND b.store_manager_id = a.manager_id "
                    + "ORDER BY a.id DESC LIMIT 1 FOR UPDATE";

            int assignmentId;
            LocalDate oldEndDate;

            try (PreparedStatement ps
                    = conn.prepareStatement(selectSql)) {

                ps.setInt(1, requestId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        throw new IllegalStateException(
                                "Không tìm thấy bổ nhiệm cần gia hạn.");
                    }

                    assignmentId = rs.getInt("id");
                    oldEndDate = rs.getDate("end_date").toLocalDate();
                }
            }

            // 3. Ngày mới phải sau ngày kết thúc hiện tại
            if (!newEndDate.isAfter(oldEndDate)) {
                throw new IllegalArgumentException(
                        "Ngày kết thúc mới phải sau ngày kết thúc cũ.");
            }

            // 4. Cập nhật thời hạn và lý do gia hạn
            String updateSql
                    = "UPDATE branch_manager_assignments "
                    + "SET end_date = ?, extend_reason = ? "
                    + "WHERE id = ?";

            try (PreparedStatement ps
                    = conn.prepareStatement(updateSql)) {

                ps.setDate(1, Date.valueOf(newEndDate));
                ps.setString(2, reason.trim());
                ps.setInt(3, assignmentId);

                if (ps.executeUpdate() != 1) {
                    throw new SQLException(
                            "Không thể cập nhật thời hạn kiêm nhiệm.");
                }
            }

            conn.commit();

            response.sendRedirect(
                    request.getContextPath()
                    + "/hr/branch-request?extended=1");
            return;

        } catch (Exception e) {

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            e.printStackTrace();

            request.getSession().setAttribute(
                    "extendError",
                    e.getMessage() != null
                    ? e.getMessage()
                    : "Gia hạn thất bại. Vui lòng thử lại."
            );

            response.sendRedirect(
                    request.getContextPath() + "/hr/branch-request"
            );
            return;

        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void activateBranch(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (currentUser.getRoleId() != ROLE_HR_MANAGER
                && currentUser.getRoleId() != ROLE_ADMIN) {
            sendForbidden(request, response,
                    "Bạn không có quyền kích hoạt chi nhánh!");
            return;
        }

        int requestId;
        try {
            requestId = Integer.parseInt(
                    request.getParameter("requestId"));

            if (requestId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(400, "Mã yêu cầu không hợp lệ.");
            return;
        }

        Connection conn = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Khóa và kiểm tra chi nhánh
            String sql
                    = "SELECT b.id, b.status, b.store_manager_id "
                    + "FROM branch_requests br "
                    + "JOIN branches b ON br.branch_id = b.id "
                    + "WHERE br.id = ? AND br.status = 'IN_PROGRESS' "
                    + "FOR UPDATE";

            int branchId;
            int managerId;

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, requestId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException(
                                "Yêu cầu không tồn tại hoặc đã hoàn thành.");
                    }

                    branchId = rs.getInt("id");
                    managerId = rs.getInt("store_manager_id");

                    if (!"PREPARING".equals(rs.getString("status"))) {
                        throw new IllegalStateException(
                                "Chi nhánh không ở trạng thái PREPARING.");
                    }

                    if (rs.wasNull()) {
                        throw new IllegalStateException(
                                "Chi nhánh chưa được bổ nhiệm Store Manager.");
                    }
                }
            }

            // 2. Kiểm tra thời gian kiêm nhiệm còn hiệu lực
            String checkAssignment
                    = "SELECT id FROM branch_manager_assignments "
                    + "WHERE branch_id = ? AND manager_id = ? "
                    + "AND CURDATE() BETWEEN start_date AND end_date "
                    + "LIMIT 1";

            try (PreparedStatement ps
                    = conn.prepareStatement(checkAssignment)) {

                ps.setInt(1, branchId);
                ps.setInt(2, managerId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException(
                                "Quản lý kiêm nhiệm chưa có hiệu lực hoặc đã hết hạn.");
                    }
                }
            }

            // 3. Kích hoạt chi nhánh
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE branches SET status = 'ACTIVE' "
                    + "WHERE id = ? AND status = 'PREPARING'")) {

                ps.setInt(1, branchId);

                if (ps.executeUpdate() != 1) {
                    throw new SQLException(
                            "Không thể kích hoạt chi nhánh.");
                }
            }

            // 4. Hoàn thành yêu cầu
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE branch_requests SET status = 'COMPLETED' "
                    + "WHERE id = ? AND status = 'IN_PROGRESS'")) {

                ps.setInt(1, requestId);

                if (ps.executeUpdate() != 1) {
                    throw new SQLException(
                            "Không thể hoàn thành yêu cầu.");
                }
            }

            conn.commit();

            response.sendRedirect(
                    request.getContextPath()
                    + "/hr/branch-request?activated=1");
            return;

        } catch (Exception e) {

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }

            e.printStackTrace();
            System.out.println("ACTIVATION ERROR: " + e.getMessage());

            request.getSession().setAttribute(
                    "activationError",
                    e.getMessage() != null
                    ? e.getMessage()
                    : "Kích hoạt chi nhánh thất bại."
            );

            response.sendRedirect(
                    request.getContextPath() + "/hr/branch-request");
            return;

        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

}
