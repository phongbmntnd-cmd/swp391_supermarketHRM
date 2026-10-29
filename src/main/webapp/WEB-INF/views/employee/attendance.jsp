<%-- 
    Document   : attendance
    Created on : Oct 29, 2026, 6:45:58 PM
    Author     : Lenovo
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chấm công cá nhân</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: #f4f7f6; color: #1e293b; }
        .topbar { background: #1e293b; color: white; padding: 18px max(20px, calc((100% - 1120px) / 2)); display: flex; justify-content: space-between; align-items: center; gap: 16px; }
        .topbar h1 { font-size: 20px; margin: 0; }
        .topbar a { color: white; text-decoration: none; }
        main { max-width: 1120px; margin: 32px auto; padding: 0 18px; }
        .card { border: 0; border-radius: 12px; box-shadow: 0 4px 18px rgba(15, 23, 42, .06); }
        .card-header { background: white; font-weight: 700; padding: 18px 22px; }
        .table th { white-space: nowrap; color: #475569; font-size: 13px; }
        .table td { vertical-align: middle; }
        .status { font-weight: 600; }
    </style>
</head>
<body>
    <header class="topbar">
        <h1><i class="fa-solid fa-fingerprint me-2"></i>Chấm công cá nhân</h1>
        <a href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-arrow-left me-1"></i>Trang chủ</a>
    </header>
    <main>
        <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
        <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

        <section class="card mb-4">
            <div class="card-header"><i class="fa-regular fa-calendar-check text-primary me-2"></i>Ca làm hôm nay — <c:out value="${today}"/></div>
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead><tr><th>Ca làm</th><th>Giờ dự kiến</th><th>Giờ vào</th><th>Giờ ra</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
                    <tbody>
                        <c:forEach items="${todayShifts}" var="shift">
                            <tr>
                                <td><c:out value="${shift.shiftName}"/></td>
                                <td><fmt:formatDate value="${shift.shiftStart}" pattern="HH:mm"/> – <fmt:formatDate value="${shift.shiftEnd}" pattern="HH:mm"/></td>
                                <td><c:choose><c:when test="${not empty shift.checkIn}"><fmt:formatDate value="${shift.checkIn}" pattern="HH:mm:ss"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                <td><c:choose><c:when test="${not empty shift.checkOut}"><fmt:formatDate value="${shift.checkOut}" pattern="HH:mm:ss"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${shift.status == 'PENDING'}"><span class="badge text-bg-warning">Chờ quản lý duyệt</span></c:when>
                                        <c:when test="${shift.status == 'VALID'}"><span class="badge text-bg-success">Hợp lệ</span></c:when>
                                        <c:when test="${shift.status == 'INVALID'}"><span class="badge text-bg-danger">Không hợp lệ</span></c:when>
                                        <c:when test="${not empty shift.checkIn}"><span class="badge text-bg-info">Đã ghi nhận</span></c:when>
                                        <c:otherwise><span class="text-secondary">Chưa chấm công</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty shift.checkIn}">
                                            <form method="post" action="${pageContext.request.contextPath}/employee/attendance">
                                                <input type="hidden" name="shiftScheduleId" value="${shift.shiftScheduleId}">
                                                <button class="btn btn-primary btn-sm" name="action" value="checkIn" type="submit"><i class="fa-solid fa-right-to-bracket me-1"></i>Chấm công vào</button>
                                            </form>
                                        </c:when>
                                        <c:when test="${empty shift.checkOut}">
                                            <form method="post" action="${pageContext.request.contextPath}/employee/attendance">
                                                <input type="hidden" name="shiftScheduleId" value="${shift.shiftScheduleId}">
                                                <button class="btn btn-outline-primary btn-sm" name="action" value="checkOut" type="submit"><i class="fa-solid fa-right-from-bracket me-1"></i>Chấm công ra</button>
                                            </form>
                                        </c:when>
                                        <c:otherwise><span class="text-success"><i class="fa-solid fa-circle-check me-1"></i>Hoàn tất</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty todayShifts}">
                            <tr><td colspan="6" class="text-center text-secondary py-4">Bạn chưa có ca làm đã công bố hôm nay nên chưa thể chấm công.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="card">
            <div class="card-header"><i class="fa-solid fa-clock-rotate-left text-primary me-2"></i>Lịch sử chấm công</div>
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead><tr><th>Ngày</th><th>Ca làm</th><th>Giờ vào</th><th>Giờ ra</th><th>Trạng thái</th></tr></thead>
                    <tbody>
                        <c:forEach items="${recentAttendance}" var="record">
                            <tr>
                                <td><fmt:formatDate value="${record.workDate}" pattern="dd/MM/yyyy"/></td>
                                <td><c:out value="${record.shiftName}"/></td>
                                <td><c:choose><c:when test="${not empty record.checkIn}"><fmt:formatDate value="${record.checkIn}" pattern="HH:mm:ss"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                <td><c:choose><c:when test="${not empty record.checkOut}"><fmt:formatDate value="${record.checkOut}" pattern="HH:mm:ss"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${record.status == 'PENDING'}"><span class="badge text-bg-warning">Chờ duyệt</span></c:when>
                                        <c:when test="${record.status == 'VALID'}"><span class="badge text-bg-success">Hợp lệ</span></c:when>
                                        <c:otherwise><span class="badge text-bg-danger">Không hợp lệ</span></c:otherwise>
                                    </c:choose>
                                    <c:if test="${record.late}"><span class="badge text-bg-secondary ms-1">Đi trễ</span></c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty recentAttendance}">
                            <tr><td colspan="5" class="text-center text-secondary py-4">Chưa có dữ liệu chấm công trước ngày hôm nay.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</body>
</html>
