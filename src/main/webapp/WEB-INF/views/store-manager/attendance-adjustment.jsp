<%-- 
    Document   : attendance-adjustment
    Created on : Oct 30, 2026, 7:20:37 PM
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
    <title>Điều chỉnh chấm công</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .adjustment-page { max-width: 860px; }
        .attendance-summary { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px 24px; }
        .summary-item { min-width: 0; }
        .summary-value { color: var(--text); font-weight: 600; overflow-wrap: anywhere; }
        .summary-value small { color: var(--text-muted); font-weight: 400; }
        .current-times { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
        .adjustment-actions { display: flex; justify-content: flex-end; gap: 10px; flex-wrap: wrap; margin-top: 20px; }
        .history-note { white-space: pre-wrap; overflow-wrap: anywhere; }
        @media (max-width: 600px) {
            .attendance-summary, .current-times { grid-template-columns: 1fr; }
            .adjustment-actions { justify-content: stretch; }
            .adjustment-actions .btn { flex: 1 1 100%; justify-content: center; }
        }
    </style>
</head>
<body>
<c:url var="reportUrl" value="/store-manager/attendance">
    <c:param name="date" value="${selectedDate}"/>
</c:url>
<div class="topbar">
    <a class="back-link" href="${reportUrl}">&larr; Danh sách chấm công</a>
    <h1>Quản lý điều chỉnh chấm công</h1>
</div>

<main class="page adjustment-page">
    <div class="page-header">
        <h2>Điều chỉnh dữ liệu chấm công</h2>
        <p>Quản lý cửa hàng cập nhật giờ vào/ra và ghi rõ lý do xử lý sai lệch.</p>
    </div>

    <c:if test="${not empty errorMessage}"><div class="alert alert-error"><c:out value="${errorMessage}"/></div></c:if>

    <section class="card">
        <div class="card-header">
            <h3>Thông tin nhân viên và ca làm</h3>
            <span class="badge badge-${attendance.status}"><c:out value="${attendance.status}"/></span>
        </div>
        <div class="card-body">
            <div class="attendance-summary">
                <div class="summary-item">
                    <div class="field"><label>Nhân viên</label></div>
                    <div class="summary-value"><c:out value="${attendance.fullName}"/> <small>(<c:out value="${attendance.username}"/>)</small></div>
                </div>
                <div class="summary-item">
                    <div class="field"><label>Ngày làm</label></div>
                    <div class="summary-value"><fmt:formatDate value="${attendance.workDate}" pattern="dd/MM/yyyy"/></div>
                </div>
                <div class="summary-item">
                    <div class="field"><label>Chi nhánh</label></div>
                    <div class="summary-value"><c:out value="${attendance.branchName}"/></div>
                </div>
                <div class="summary-item">
                    <div class="field"><label>Ca làm</label></div>
                    <div class="summary-value">
                        <c:out value="${attendance.shiftName}"/>
                        · <fmt:formatDate value="${attendance.shiftStart}" pattern="HH:mm"/>–<fmt:formatDate value="${attendance.shiftEnd}" pattern="HH:mm"/>
                    </div>
                </div>
                <div class="summary-item">
                    <div class="field"><label>Giờ vào hiện tại</label></div>
                    <div class="summary-value">
                        <c:choose><c:when test="${not empty attendance.checkIn}"><fmt:formatDate value="${attendance.checkIn}" pattern="HH:mm"/></c:when><c:otherwise>Chưa có dữ liệu</c:otherwise></c:choose>
                    </div>
                </div>
                <div class="summary-item">
                    <div class="field"><label>Giờ ra hiện tại</label></div>
                    <div class="summary-value">
                        <c:choose><c:when test="${not empty attendance.checkOut}"><fmt:formatDate value="${attendance.checkOut}" pattern="HH:mm"/></c:when><c:otherwise>Chưa có dữ liệu</c:otherwise></c:choose>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="card">
        <div class="card-header"><h3>Thông tin điều chỉnh</h3></div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/store-manager/attendance">
                <input type="hidden" name="action" value="adjust">
                <input type="hidden" name="attendanceId" value="${attendance.id}">
                <input type="hidden" name="date" value="${selectedDate}">
                <div class="current-times">
                    <div class="field">
                        <label for="checkIn">Giờ vào sau điều chỉnh</label>
                        <fmt:formatDate value="${attendance.checkIn}" pattern="HH:mm" var="checkInTime"/>
                        <input id="checkIn" type="time" name="checkIn" value="${checkInTime}">
                    </div>
                    <div class="field">
                        <label for="checkOut">Giờ ra sau điều chỉnh</label>
                        <fmt:formatDate value="${attendance.checkOut}" pattern="HH:mm" var="checkOutTime"/>
                        <input id="checkOut" type="time" name="checkOut" value="${checkOutTime}">
                    </div>
                    <div class="field full">
                        <label for="adjustmentNote">Lý do điều chỉnh <span class="text-danger">*</span></label>
                        <textarea id="adjustmentNote" name="adjustmentNote" rows="5" maxlength="1000" required placeholder="Nêu rõ lý do và căn cứ điều chỉnh giờ công."></textarea>
                        <div class="helper-text">Lý do, người quản lý thực hiện và thời điểm điều chỉnh sẽ được lưu vào lịch sử chấm công.</div>
                    </div>
                </div>
                <div class="adjustment-actions">
                    <a class="btn btn-ghost" href="${reportUrl}">Hủy</a>
                    <button class="btn btn-primary" type="submit">Lưu điều chỉnh</button>
                </div>
            </form>
        </div>
    </section>

    <c:if test="${not empty attendance.adjustmentNote}">
        <section class="card">
            <div class="card-header"><h3>Lần điều chỉnh gần nhất</h3></div>
            <div class="card-body">
                <div class="field"><label>Lý do đã ghi nhận</label><div class="summary-value history-note"><c:out value="${attendance.adjustmentNote}"/></div></div>
                <div class="helper-text">
                    Người điều chỉnh: <strong><c:out value="${attendance.adjustedBy}"/></strong>
                    · <fmt:formatDate value="${attendance.adjustedAt}" pattern="dd/MM/yyyy HH:mm"/>
                </div>
            </div>
        </section>
    </c:if>
</main>
</body>
</html>

