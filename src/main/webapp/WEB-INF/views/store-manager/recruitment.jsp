<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đề xuất tuyển dụng</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background:#f5f6fa; }
        .card { background:#fff; padding:20px; border-radius:8px; box-shadow:0 1px 4px rgba(0,0,0,.1); margin-bottom:24px; }
        label { display:block; margin-top:12px; font-weight:bold; }
        input, select, textarea { width:100%; padding:8px; margin-top:4px; box-sizing:border-box; }
        button { margin-top:16px; padding:10px 20px; background:#2d6cdf; color:#fff; border:none; border-radius:4px; cursor:pointer; }
        table { width:100%; border-collapse:collapse; margin-top:10px; }
        th, td { padding:8px; border-bottom:1px solid #ddd; text-align:left; font-size:14px; }
        .status-PENDING { color:#b8860b; font-weight:bold; }
        .status-APPROVED { color:#1a7f37; font-weight:bold; }
        .status-REJECTED { color:#c62828; font-weight:bold; }
        .msg-ok { color:#1a7f37; }
        .msg-err { color:#c62828; }
    </style>
</head>
<body>

<h2>Đề xuất tuyển dụng nhân sự</h2>

<c:if test="${not empty message}"><p class="msg-ok">${message}</p></c:if>
<c:if test="${not empty error}"><p class="msg-err">${error}</p></c:if>

<div class="card">
    <h3>Tạo đề xuất mới</h3>
    <form method="post" action="${pageContext.request.contextPath}/store-manager/recruitment">
        <label>Vị trí cần tuyển</label>
        <select name="positionId" required>
            <c:forEach var="p" items="${positions}">
                <option value="${p.id}">${p.title}</option>
            </c:forEach>
        </select>

        <label>Hình thức làm việc</label>
        <select name="employmentType">
            <option value="FULL_TIME">Toàn thời gian</option>
            <option value="PART_TIME">Bán thời gian</option>
        </select>

        <label>Số lượng cần tuyển</label>
        <input type="number" name="quantity" min="1" value="1" required>

        <label>Ngày mong muốn có nhân sự</label>
        <input type="date" name="targetDate">

        <label>Lý do đề xuất</label>
        <textarea name="reason" rows="3" required></textarea>

        <button type="submit">Gửi đề xuất</button>
    </form>
</div>

<div class="card">
    <h3>Danh sách đề xuất đã gửi</h3>
    <table>
        <tr>
            <th>Ngày tạo</th>
            <th>Vị trí</th>
            <th>Hình thức</th>
            <th>SL</th>
            <th>Ngày cần</th>
            <th>Trạng thái</th>
            <th>Ghi chú HR</th>
        </tr>
        <c:forEach var="rp" items="${proposals}">
            <tr>
                <td><fmt:formatDate value="${rp.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                <td>${rp.positionTitle}</td>
                <td>${rp.employmentType}</td>
                <td>${rp.quantity}</td>
                <td><fmt:formatDate value="${rp.targetDate}" pattern="dd/MM/yyyy"/></td>
                <td class="status-${rp.status}">${rp.status}</td>
                <td>${rp.hrNote}</td>
            </tr>
        </c:forEach>
        <c:if test="${empty proposals}">
            <tr><td colspan="7">Chưa có đề xuất nào.</td></tr>
        </c:if>
    </table>
</div>

</body>
</html>
