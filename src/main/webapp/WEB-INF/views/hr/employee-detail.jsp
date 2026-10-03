<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết hồ sơ nhân viên</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<div class="topbar">
    <a class="back-link" href="${pageContext.request.contextPath}/hr/employee-management">&larr; Danh sách nhân sự</a>
    <h1>Chi tiết hồ sơ nhân viên</h1>
</div>

<div class="page">

<c:if test="${empty employee}">
    <div class="alert alert-error">Không tìm thấy nhân viên.</div>
</c:if>

<c:if test="${not empty employee}">

    <div class="page-header">
        <h2>${employee.fullName}</h2>
        <p>@${employee.username} &nbsp;&middot;&nbsp; ${employee.roleName}</p>
    </div>

    <c:if test="${not empty message}"><div class="alert alert-success">${message}</div></c:if>
    <c:if test="${not empty error}"><div class="alert alert-error">${error}</div></c:if>

    <div class="card">
        <div class="card-header"><h3>Thông tin chi tiết &amp; liên lạc</h3></div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/hr/employee-detail">
                <input type="hidden" name="formType" value="profile">
                <input type="hidden" name="userId" value="${employee.userId}">

                <div class="form-grid">
                    <div class="field">
                        <label>Họ tên</label>
                        <input type="text" name="fullName" value="${employee.fullName}" required>
                    </div>
                    <div class="field">
                        <label>Số điện thoại</label>
                        <input type="text" name="phone" value="${employee.phone}">
                    </div>
                    <div class="field">
                        <label>CCCD/CMND</label>
                        <input type="text" name="identityCard" value="${employee.identityCard}">
                    </div>
                    <div class="field">
                        <label>Loại hình nhân viên</label>
                        <select name="employeeType">
                            <option value="FULL_TIME" ${employee.employeeType == 'FULL_TIME' ? 'selected' : ''}>Toàn thời gian</option>
                            <option value="PART_TIME" ${employee.employeeType == 'PART_TIME' ? 'selected' : ''}>Bán thời gian</option>
                            <option value="SEASONAL" ${employee.employeeType == 'SEASONAL' ? 'selected' : ''}>Thời vụ</option>
                        </select>
                    </div>
                    <div class="field">
                        <label>Chi nhánh</label>
                        <select name="homeBranchId">
                            <c:forEach var="b" items="${branches}">
                                <option value="${b.id}" ${b.id == employee.homeBranchId ? 'selected' : ''}>${b.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="field">
                        <label>Phòng ban</label>
                        <select name="departmentId">
                            <c:forEach var="d" items="${departments}">
                                <option value="${d.id}" ${d.id == employee.departmentId ? 'selected' : ''}>${d.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="field full">
                        <label>Vị trí</label>
                        <select name="positionId">
                            <c:forEach var="p" items="${positions}">
                                <option value="${p.id}" ${p.id == employee.positionId ? 'selected' : ''}>${p.title}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div style="margin-top:20px;">
                    <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h3>Hợp đồng lao động</h3></div>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>Loại hợp đồng</th>
                    <th>Ngày bắt đầu</th>
                    <th>Ngày kết thúc</th>
                    <th>Trạng thái</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="c" items="${contracts}">
                    <tr>
                        <td>${c.contractType}</td>
                        <td><fmt:formatDate value="${c.startDate}" pattern="dd/MM/yyyy"/></td>
                        <td><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy"/></td>
                        <td><span class="badge badge-${c.status}">${c.status}</span></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:if test="${empty contracts}">
                <div class="empty-state">
                    <div class="empty-title">Chưa có hợp đồng nào</div>
                    <div>Thêm hợp đồng lao động đầu tiên cho nhân viên này bên dưới.</div>
                </div>
            </c:if>
        </div>

        <div class="card-body" style="border-top:1px solid var(--slate-200);">
            <h3 style="font-size:14px; margin:0 0 16px;">Thêm hợp đồng mới</h3>
            <form method="post" action="${pageContext.request.contextPath}/hr/employee-detail">
                <input type="hidden" name="formType" value="contract">
                <input type="hidden" name="userId" value="${employee.userId}">

                <div class="form-grid">
                    <div class="field full">
                        <label>Loại hợp đồng</label>
                        <input type="text" name="contractType" placeholder="VD: Hợp đồng chính thức" required>
                    </div>
                    <div class="field">
                        <label>Ngày bắt đầu</label>
                        <input type="date" name="startDate" value="<%= LocalDate.now() %>" required>
                    </div>
                    <div class="field">
                        <label>Ngày kết thúc (nếu có)</label>
                        <input type="date" name="endDate">
                    </div>
                    <div class="field">
                        <label>Trạng thái</label>
                        <select name="status">
                            <option value="ACTIVE">ACTIVE</option>
                            <option value="EXPIRED">EXPIRED</option>
                            <option value="TERMINATED">TERMINATED</option>
                        </select>
                    </div>
                </div>

                <div style="margin-top:20px;">
                    <button type="submit" class="btn btn-primary">Thêm hợp đồng</button>
                </div>
            </form>
        </div>
    </div>

</c:if>

</div>

</body>
</html>
