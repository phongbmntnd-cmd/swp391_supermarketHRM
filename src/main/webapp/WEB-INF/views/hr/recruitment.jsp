<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Phê duyệt đề xuất tuyển dụng</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background:#f5f6fa; }
        .card { background:#fff; padding:20px; border-radius:8px; box-shadow:0 1px 4px rgba(0,0,0,.1); }
        table { width:100%; border-collapse:collapse; margin-top:10px; }
        th, td { padding:8px; border-bottom:1px solid #ddd; text-align:left; font-size:14px; vertical-align:top; }
        .status-PENDING { color:#b8860b; font-weight:bold; }
        .status-APPROVED { color:#1a7f37; font-weight:bold; }
        .status-REJECTED { color:#c62828; font-weight:bold; }
        .tabs a { margin-right:16px; text-decoration:none; color:#2d6cdf; font-weight:bold; }
        .tabs a.active { text-decoration:underline; }
        .msg-ok { color:#1a7f37; }
        .msg-err { color:#c62828; }
        .actions button { padding:6px 12px; margin-right:6px; border:none; border-radius:4px; color:#fff; cursor:pointer; }
        .btn-approve { background:#1a7f37; }
        .btn-reject { background:#c62828; }
        input[name="hrNote"] { width:160px; padding:4px; }
    </style>
</head>
<body>

<h2>Phê duyệt đề xuất tuyển dụng</h2>

<c:if test="${not empty message}"><p class="msg-ok">${message}</p></c:if>
<c:if test="${not empty error}"><p class="msg-err">${error}</p></c:if>

<div class="tabs">
    <a href="${pageContext.request.contextPath}/hr/recruitment?filter=pending"
       class="${filter == 'pending' ? 'active' : ''}">Đang chờ duyệt</a>
    <a href="${pageContext.request.contextPath}/hr/recruitment?filter=all"
       class="${filter == 'all' ? 'active' : ''}">Tất cả</a>
</div>

<div class="card">
    <table>
        <tr>
            <th>Ngày tạo</th>
            <th>Chi nhánh</th>
            <th>Vị trí</th>
            <th>Hình thức</th>
            <th>SL</th>
            <th>Ngày cần</th>
            <th>Lý do</th>
            <th>Người đề xuất</th>
            <th>Trạng thái</th>
            <th>Thao tác</th>
        </tr>
        <c:forEach var="rp" items="${proposals}">
            <tr>
                <td><fmt:formatDate value="${rp.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                <td>${rp.branchName}</td>
                <td>${rp.positionTitle}</td>
                <td>${rp.employmentType}</td>
                <td>${rp.quantity}</td>
                <td><fmt:formatDate value="${rp.targetDate}" pattern="dd/MM/yyyy"/></td>
                <td>${rp.reason}</td>
                <td>${rp.createdByName}</td>
                <td class="status-${rp.status}">${rp.status}</td>
                <td>
                    <c:if test="${rp.status == 'PENDING'}">
                        <form method="post" action="${pageContext.request.contextPath}/hr/recruitment" class="actions">
                            <input type="hidden" name="proposalId" value="${rp.id}">
                            <input type="text" name="hrNote" placeholder="Ghi chú (tuỳ chọn)">
                            <br>
                            <button type="submit" name="action" value="approve" class="btn-approve">Duyệt</button>
                            <button type="submit" name="action" value="reject" class="btn-reject">Từ chối</button>
                        </form>
                    </c:if>
                    <c:if test="${rp.status != 'PENDING'}">
                        ${rp.approvedByName} <br> <em>${rp.hrNote}</em>
                    </c:if>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty proposals}">
            <tr><td colspan="10">Không có đề xuất nào.</td></tr>
        </c:if>
    </table>
</div>

</body>
</html>
