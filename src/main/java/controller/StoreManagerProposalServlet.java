package controller;

import dao.ProposalDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StoreManagerProposalServlet", urlPatterns = {"/store-manager/proposal"})
public class StoreManagerProposalServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ProposalDAO dao = new ProposalDAO();
        request.setAttribute("proposalList", dao.getAllProposals());
        request.getRequestDispatcher("/WEB-INF/views/store-manager/proposal.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String position = request.getParameter("position");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        String reason = request.getParameter("reason");
        int branchId = user.getHomeBranchId();

        ProposalDAO dao = new ProposalDAO();
        dao.createProposal(branchId, user.getId(), position, quantity, reason);
        response.sendRedirect("proposal");
    }
}