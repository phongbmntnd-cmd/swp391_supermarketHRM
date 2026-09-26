/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.User;

/**
 *
 * @author nguyn
 */
@WebServlet(name = "StoreManagerBranchEmployeesServlet", urlPatterns = {"/store-manager/branch-employees"})
public class StoreManagerBranchEmployeesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Lấy branchId của Store Manager đang đăng nhập (giả sử User có lưu homeBranchId)
        int branchId = currentUser.getHomeBranchId(); 
        
        UserDAO userDAO = new UserDAO();
        List<User> employees = (List<User>) userDAO.getUsersByBranch(branchId);
        
        request.setAttribute("employeeList", employees);
        request.getRequestDispatcher("/WEB-INF/views/store-manager/branch-employees.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("lock".equals(action)) {
            int userId = Integer.parseInt(request.getParameter("userId"));
            UserDAO userDAO = new UserDAO();
            userDAO.updateStatus(userId, "LOCKED"); // Khóa tài khoản khẩn cấp
            response.sendRedirect(request.getContextPath() + "/store-manager/branch-employees");
        }
    }
}
