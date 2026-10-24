package controller.hr;

import controller.base.BaseServlet;
import dao.TemporaryTransferDAO;
import model.TemporaryTransfer;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

@WebServlet(name="HRTransferRequestsServlet",urlPatterns="/hr/transfer-requests")
public class HRTransferRequestsServlet extends BaseServlet {
    private boolean allowed(HttpServletRequest r){User u=getCurrentUser(r);return u!=null&&(u.getRoleId()==ROLE_HR_MANAGER||u.getRoleId()==ROLE_ADMIN);}
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        if(getCurrentUser(req)==null){redirectToLogin(req,resp);return;}
        if(!allowed(req)){sendForbidden(req,resp,"Chỉ HR mới được xét duyệt điều chuyển");return;}
        TemporaryTransferDAO dao=new TemporaryTransferDAO();
        List<TemporaryTransfer> list=dao.getPendingHR();Map<Integer,List<Map<String,Object>>> selected=new HashMap<>();
        for(TemporaryTransfer t:list)selected.put(t.getId(),dao.getSelectedEmployees(t.getId()));
        req.setAttribute("requests",list);req.setAttribute("selectedByTransfer",selected);
        req.setAttribute("message",req.getSession().getAttribute("transferMessage"));req.getSession().removeAttribute("transferMessage");
        req.setAttribute("error",req.getSession().getAttribute("transferError"));req.getSession().removeAttribute("transferError");
        req.getRequestDispatcher("/WEB-INF/views/hr/transfer-requests.jsp").forward(req,resp);
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        if(getCurrentUser(req)==null){redirectToLogin(req,resp);return;}
        if(!allowed(req)){sendForbidden(req,resp,"Bạn không có quyền duyệt HR");return;}
        int id=getIntParameter(req,"requestId",-1);
        String action=getStringParameter(req,"action");TemporaryTransferDAO dao=new TemporaryTransferDAO();boolean ok;
        if("approve".equals(action))ok=dao.approveHR(id,getCurrentUser(req).getId());
        else if("reject".equals(action))ok=dao.rejectHR(id,getCurrentUser(req).getId(),getStringParameter(req,"rejectReason"));
        else{resp.sendError(400,"Action không hợp lệ");return;}
        req.getSession().setAttribute(ok?"transferMessage":"transferError",ok?"HR đã xử lý đề xuất thành công.":"Không xử lý được: dữ liệu, lịch hoặc quân số đã thay đổi. Xem log server.");
        resp.sendRedirect(req.getContextPath()+"/hr/transfer-requests");
    }
}
