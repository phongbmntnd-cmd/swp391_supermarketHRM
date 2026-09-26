/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dao.AttendanceDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

/**
 *
 * @author nguyn
 */
@WebServlet(name = "StoreManagerAttendanceServlet", urlPatterns = {"/store-manager/attendance"})
public class StoreManagerAttendanceServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Lấy dữ liệu bảng chấm công theo branchId của cửa hàng
        AttendanceDAO attendanceDAO = new AttendanceDAO();
        // List<Attendance> attendances = attendanceDAO.getByBranch(currentUser.getHomeBranchId());
        
        // request.setAttribute("attendanceList", attendances);
        request.getRequestDispatcher("/WEB-INF/views/store-manager/attendance.jsp").forward(request, response);
    }
}
