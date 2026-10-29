<%-- 
    Document   : attendance-management
    Created on : Oct 29, 2026, 7:01:39 PM
    Author     : Lenovo
--%>

<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý chấm công</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .attendance-table { min-width: 900px; }
        .attendance-table td { vertical-align: middle; }
        .employee-name { font-weight: 700; }
        .secondary-line { color: var(--text-muted); font-size: 12px; }
        .time-value { font-weight: 600; white-space: nowrap; }
        .attendance-filter { display: flex; flex-wrap: wrap; align-items: flex-end; gap: 10px; }
        .attendance-filter .field { min-width: 170px; }
        .attendance-actions { white-space: nowrap; }
        .status-note { max-width: 220px; margin-top: 5px; color: var(--text-muted); font-size: 12px; white-space: normal; }
        .helper-text { color: var(--text-muted); font-size: 12px; margin-top: 12px; }
        .badge-VALID { background: var(--green-bg); color: var(--green-text); }
        .badge-ADJUSTED { background: #d1ecf1; color: #0c5460; }
        .badge-INVALID { background: var(--red-bg); color: var(--red-text); }
        @media (max-width: 640px) {
            .attendance-filter { width: 100%; }
            .attendance-filter .field { flex: 1 1 140px; min-width: 0; }
            .attendance-filter .btn { flex: 1 1 auto; }
        }
    </style>
</head>
<body>
<div class="topbar">
    <a class="back-link" href="${pageContext.request.contextPath}/hr/dashboard">&larr; Dashboard</a>
    <h1>Quản lý chấm công</h1>
</div>

<main class="page">
    <div class="page-header">
        <h2>Kiểm tra dữ liệu chấm công</h2>
        <p>Tra cứu bản ghi toàn hệ thống và điều chỉnh sai lệch kèm lý do khi cần.</p>
    </div>

    <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
    <c:if test="${not empty errorMessage}"><div class="alert alert-error"><c:out value="${errorMessage}"/></div></c:if>
    <c:if test="${not empty dateError}"><div class="alert alert-error"><c:out value="${dateError}"/></div></c:if>

    <section class="card">
        <div class="card-header">
            <h3>Danh sách chấm công toàn hệ thống</h3>
        </div>
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/hr/attendance-management" class="attendance-filter">
                <div class="field">
                    <label for="recordFromDate">Từ ngày</label>
                    <input id="recordFromDate" type="date" name="fromDate" value="${fromDate}" required>
                </div>
                <div class="field">
                    <label for="recordToDate">Đến ngày</label>
                    <input id="recordToDate" type="date" name="toDate" value="${toDate}" required>
                </div>
                <button class="btn btn-primary" type="submit">Lọc dữ liệu</button>
                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/hr/attendance-management">Xóa lọc</a>
            </form>
        </div>
        <div class="table-wrap">
            <table class="attendance-table">
                <thead>
                    <tr>
                        <th>Ngày / nhân viên</th>
                        <th>Chi nhánh / ca</th>
                        <th>Giờ vào</th>
                        <th>Giờ ra</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${attendances}" var="record">
                        <tr>
                            <td>
                                <span class="employee-name"><fmt:formatDate value="${record.workDate}" pattern="dd/MM/yyyy"/></span><br>
                                <c:out value="${record.fullName}"/> <span class="secondary-line">(<c:out value="${record.username}"/>)</span>
                            </td>
                            <td><c:out value="${record.branchName}"/><br><span class="secondary-line"><c:out value="${record.shiftName}"/></span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty record.checkIn}"><span class="time-value"><fmt:formatDate value="${record.checkIn}" pattern="HH:mm"/></span></c:when>
                                    <c:otherwise><span class="badge badge-REJECTED">Thiếu giờ vào</span></c:otherwise>
                                </c:choose>
                                <c:if test="${record.late}"><br><span class="badge badge-PENDING">Đi trễ</span></c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty record.checkOut}"><span class="time-value"><fmt:formatDate value="${record.checkOut}" pattern="HH:mm"/></span></c:when>
                                    <c:otherwise><span class="secondary-line">Chưa chấm ra</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="badge badge-${record.status}"><c:out value="${record.status}"/></span>
                                <c:if test="${not empty record.adjustmentNote}">
                                    <div class="status-note">
                                        <c:out value="${record.adjustmentNote}"/><br>
                                        <c:out value="${record.adjustedBy}"/> · <fmt:formatDate value="${record.adjustedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </c:if>
                            </td>
                            <td class="attendance-actions">
                                <a class="btn btn-primary" href="${pageContext.request.contextPath}/hr/attendance-management?adjustmentId=${record.id}&amp;fromDate=${fromDate}&amp;toDate=${toDate}">
                                    Điều chỉnh
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty attendances}">
                        <tr><td colspan="6" class="empty-state">Không có dữ liệu chấm công trong khoảng ngày đã chọn.</td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </section>
</main>
</body>
</html>
