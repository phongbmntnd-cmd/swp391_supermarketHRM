<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết hồ sơ nhân viên</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background:#f5f6fa; }
        .card { background:#fff; padding:20px; border-radius:8px; box-shadow:0 1px 4px rgba(0,0,0,.1); margin-bottom:24px; }
        label { display:block; margin-top:12px; font-weight:bold; }
        input, select { width:100%; padding:8px; margin-top:4px; box-sizing:border-box; }
        button { margin-top:16px; padding:10px 20px; background:#2d6cdf; color:#fff; border:none; border-radius:4px; cursor:pointer; }
        table { width:100%; border-collapse:collapse; margin-top:10px; }
        th, td { padding:8px; border-bottom:1px solid #ddd; text-align:left; font-size:14px; }
        .msg-ok { color:#1a7f37; } .msg-err { color:#c62828; }
        a.back { display:inline-block; margin-bottom:16px; color:#2d6cdf; text-decoration:none; }
        .status-ACTIVE { color:#1a7f37; font-weight:bold; }
        .status-EXPIRED { color:#888; font-weight:bold; }
        .status-TERMINATED { color:#c62828; font-weight:bold; }
    </style>
</head>
<body>

<a class="back" href="${pageContext.request.contextPath}/hr/employee-management">&larr; Quay lại danh sách</a>

<c:if test="${empty employee}">
    <p class="msg-err">Không tìm thấy nhân viên.</p>
</c:if>

<c:if test="${not empty employee}">

<h2>${employee.fullName} <small>(${employee.username})</small></h2>

<c:if test="${not empty message}"><p class="msg-ok">${message}</p></c:if>
<c:if test="${not empty error}"><p class="msg-err">${error}</p></c:if>

<div class="card">
    <h3>Thông tin chi tiết & liên lạc</h3>
    <form method="post" action="${pageContext.request.contextPath}/hr/employee-detail">
        <input type="hidden" name="formType" value="profile">
        <input type="hidden" name="userId" value="${employee.userId}">

        <label>Họ tên</label>
        <input type="text" name="fullName" value="${employee.fullName}" required>

        <label>Số điện thoại</label>
        <input type="text" name="phone" value="${employee.phone}">

        <label>CCCD/CMND</label>
        <input type="text" name="identityCard" value="${employee.identityCard}">

        <label>Chi nhánh</label>
        <select name="homeBranchId">
            <c:forEach var="b" items="${branches}">
                <option value="${b.id}" ${b.id == employee.homeBranchId ? 'selected' : ''}>${b.name}</option>
            </c:forEach>
        </select>

        <label>Phòng ban</label>
        <select name="departmentId">
            <c:forEach var="d" items="${departments}">
                <option value="${d.id}" ${d.id == employee.departmentId ? 'selected' : ''}>${d.name}</option>
            </c:forEach>
        </select>

        <label>Vị trí</label>
        <select name="positionId">
            <c:forEach var="p" items="${positions}">
                <option value="${p.id}" ${p.id == employee.positionId ? 'selected' : ''}>${p.title}</option>
            </c:forEach>
        </select>

        <label>Loại hình nhân viên</label>
        <select name="employeeType">
            <option value="FULL_TIME" ${employee.employeeType == 'FULL_TIME' ? 'selected' : ''}>Toàn thời gian</option>
            <option value="PART_TIME" ${employee.employeeType == 'PART_TIME' ? 'selected' : ''}>Bán thời gian</option>
            <option value="SEASONAL" ${employee.employeeType == 'SEASONAL' ? 'selected' : ''}>Thời vụ</option>
        </select>

        <button type="submit">Lưu thay đổi</button>
    </form>
</div>

<div class="card">
    <h3>Hợp đồng lao động</h3>
    <table>
        <tr>
            <th>Loại hợp đồng</th>
            <th>Ngày bắt đầu</th>
            <th>Ngày kết thúc</th>
            <th>Trạng thái</th>
        </tr>
        <c:forEach var="c" items="${contracts}">
            <tr>
                <td>${c.contractType}</td>
                <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
                <td><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></td>
                <td class="status-${c.status}">${c.status}</td>
            </tr>
        </c:forEach>
        <c:if test="${empty contracts}">
            <tr><td colspan="4">Chưa có hợp đồng nào.</td></tr>
        </c:if>
    </table>

    <h4>Thêm hợp đồng mới</h4>
    <form method="post" action="${pageContext.request.contextPath}/hr/employee-detail">
        <input type="hidden" name="formType" value="contract">
        <input type="hidden" name="userId" value="${employee.userId}">

        <label>Loại hợp đồng</label>
        <input type="text" name="contractType" placeholder="VD: Hợp đồng chính thức" required>

        <label>Ngày bắt đầu</label>
        <input type="date" name="startDate" required>

        <label>Ngày kết thúc (nếu có)</label>
        <input type="date" name="endDate">

        <label>Trạng thái</label>
        <select name="status">
            <option value="ACTIVE">ACTIVE</option>
            <option value="EXPIRED">EXPIRED</option>
            <option value="TERMINATED">TERMINATED</option>
        </select>

        <button type="submit">Thêm hợp đồng</button>
    </form>
</div>

</c:if>

</body>
</html>
