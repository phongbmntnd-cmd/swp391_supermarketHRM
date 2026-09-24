
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author nguyn
 */
import dao.BranchDAO;
import model.Branch;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DirectorController", urlPatterns = {"/director/branch-management"})
public class DirectorController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        BranchDAO branchDAO = new BranchDAO();

        if (action == null || action.equals("list")) {
            // Hiển thị danh sách cơ sở
            List<Branch> branches = branchDAO.getAllBranches();
            request.setAttribute("branchList", branches);
            request.getRequestDispatcher("/WEB-INF/views/director/branch-management.jsp").forward(request, response);

        } else if (action.equals("viewEmployees")) {
            // Xem danh sách nhân viên của cơ sở
            int branchId = Integer.parseInt(request.getParameter("id"));
            List<User> employees = branchDAO.getEmployeesByBranch(branchId);
            request.setAttribute("employeeList", employees);
            request.setAttribute("branchId", branchId);
            request.getRequestDispatcher("/WEB-INF/views/director/branch-employees.jsp").forward(request, response);
        } else if ("delete".equals(action)) {
            // Tính năng: Xóa / Hủy kích hoạt cơ sở
            int branchId = Integer.parseInt(request.getParameter("branchId"));
            branchDAO.deleteBranch(branchId);
            response.sendRedirect(request.getContextPath() + "/director/branch-management");
        } 

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        BranchDAO branchDAO = new BranchDAO();

        if (action.equals("add")) {
            // Thêm mới cơ sở
            String code = request.getParameter("code");
            String name = request.getParameter("name");
            String address = request.getParameter("address");

            branchDAO.insertBranch(code, name, address);
            response.sendRedirect(request.getContextPath() + "/director/branch-management?action=list");

        } else if (action.equals("assign")) {
            // Gán quản lý cho cơ sở
            int branchId = Integer.parseInt(request.getParameter("branchId"));
            int managerId = Integer.parseInt(request.getParameter("managerId"));

            branchDAO.assignStoreManager(branchId, managerId);
            response.sendRedirect(request.getContextPath() + "/director/branch-management?action=list");
        } else if ("toggleStatus".equals(action)) {
            int branchId = Integer.parseInt(request.getParameter("branchId"));
            String currentStatus = request.getParameter("currentStatus");

            branchDAO.toggleBranchStatus(branchId, currentStatus);
            response.sendRedirect(request.getContextPath() + "/director/branch-management");
        } else if ("toggleStatus".equals(action)) {
            int branchId = Integer.parseInt(request.getParameter("branchId"));
            String currentStatus = request.getParameter("currentStatus");

            // Gọi DAO để đảo ngược trạng thái (ACTIVE <-> INACTIVE)
            branchDAO.toggleBranchStatus(branchId, currentStatus);

            // Chuyển hướng lại trang danh sách để load lại dữ liệu mới
            response.sendRedirect(request.getContextPath() + "/director/branch-management");
        }
    }
}

