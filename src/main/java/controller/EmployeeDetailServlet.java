package controller;

import dao.ContractDAO;
import dao.EmployeeDAO;
import model.Employee;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Xem / cập nhật chi tiết hồ sơ 1 nhân viên, và quản lý hợp đồng lao động của người đó.
 * URL: /hr/employee-detail?id={userId}
 */
@WebServlet("/hr/employee-detail")
public class EmployeeDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId;
        try {
            userId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/hr/employee-management");
            return;
        }

        loadDetailData(request, userId);
        request.getRequestDispatcher("/WEB-INF/views/hr/employee-detail.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        int userId;
        try {
            userId = Integer.parseInt(request.getParameter("userId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/hr/employee-management");
            return;
        }

        String formType = request.getParameter("formType");

        if ("profile".equals(formType)) {
            handleUpdateProfile(request, userId);
        } else if ("contract".equals(formType)) {
            handleAddContract(request, userId);
        }

        loadDetailData(request, userId);
        request.getRequestDispatcher("/WEB-INF/views/hr/employee-detail.jsp")
                .forward(request, response);
    }

    private void handleUpdateProfile(HttpServletRequest request, int userId) {
        try {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String identityCard = request.getParameter("identityCard");
            int homeBranchId = Integer.parseInt(request.getParameter("homeBranchId"));
            int positionId = Integer.parseInt(request.getParameter("positionId"));
            int departmentId = Integer.parseInt(request.getParameter("departmentId"));
            String employeeType = request.getParameter("employeeType");

            if (fullName == null || fullName.trim().isEmpty()) {
                request.setAttribute("error", "Họ tên không được để trống!");
                return;
            }

            EmployeeDAO employeeDAO = new EmployeeDAO();
            boolean success = employeeDAO.updateEmployeeProfile(
                    userId, fullName, phone, identityCard, homeBranchId, positionId, departmentId, employeeType);

            request.setAttribute(success ? "message" : "error",
                    success ? "Cập nhật hồ sơ thành công!" : "Cập nhật hồ sơ thất bại!");

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu nhập không hợp lệ!");
        }
    }

    private void handleAddContract(HttpServletRequest request, int userId) {
        String contractType = request.getParameter("contractType");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String status = request.getParameter("status");

        if (contractType == null || contractType.trim().isEmpty() || startDate == null || startDate.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập loại hợp đồng và ngày bắt đầu!");
            return;
        }

        ContractDAO contractDAO = new ContractDAO();
        boolean success = contractDAO.addContract(userId, contractType, startDate, endDate, status);

        request.setAttribute(success ? "message" : "error",
                success ? "Đã thêm hợp đồng lao động mới!" : "Thêm hợp đồng thất bại!");
    }

    private void loadDetailData(HttpServletRequest request, int userId) {
        EmployeeDAO employeeDAO = new EmployeeDAO();
        ContractDAO contractDAO = new ContractDAO();

        Employee employee = employeeDAO.getEmployeeById(userId);

        request.setAttribute("employee", employee);
        request.setAttribute("contracts", contractDAO.getContractsByUser(userId));
        request.setAttribute("branches", employeeDAO.getAllBranchesFull());
        request.setAttribute("departments", employeeDAO.getAllDepartmentsFull());
        request.setAttribute("positions", employeeDAO.getAllPositionsFull());
    }
}
