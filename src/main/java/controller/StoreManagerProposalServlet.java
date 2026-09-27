/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dao.ProposalDAO;
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
@WebServlet(name = "StoreManagerProposalServlet", urlPatterns = {"/store-manager/recruitment-proposal"})
public class StoreManagerProposalServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Hiển thị form tạo đề xuất và danh sách các đề xuất đã gửi
        request.getRequestDispatcher("/WEB-INF/views/store-manager/recruitment-proposal.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        
        ProposalDAO proposalDAO = new ProposalDAO();
        proposalDAO.insertProposal(currentUser.getHomeBranchId(), currentUser.getId(), title, content);
        
        response.sendRedirect(request.getContextPath() + "/store-manager/recruitment-proposal");
    }
}
