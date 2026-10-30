<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý chấm công</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f4f7f6; color: #1e293b; }
        .sidebar { width: 250px; background: #1e293b; color: #94a3b8; position: fixed; inset: 0 auto 0 0; overflow-y: auto; }
        .sidebar-brand { padding: 24px 20px; background: #0f172a; color: white; font-weight: 700; font-size: 18px; }
        .sidebar-menu { list-style: none; padding: 18px 0; margin: 0; }
        .sidebar-menu a { display: block; padding: 13px 20px; color: #cbd5e1; text-decoration: none; border-left: 4px solid transparent; }
        .sidebar-menu a:hover, .sidebar-menu .active a { color: white; background: rgba(255,255,255,.06); border-left-color: #38bdf8; }
        .sidebar-menu i { width: 22px; }
        .main-wrapper { margin-left: 250px; min-height: 100vh; }
        .topbar { background: white; padding: 16px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 4px #0000000d; }
        .topbar h1 { font-size: 18px; margin: 0; }
        .logout { color: #dc3545; text-decoration: none; }
        main { max-width: 1450px; margin: 28px auto; padding: 0 24px; }
        .page-title { background: linear-gradient(135deg,#2563eb,#1d4ed8); color: white; border-radius: 12px; padding: 24px 28px; margin-bottom: 22px; }
        .page-title h2 { font-size: 24px; margin: 0 0 6px; }
        .card { border: 0; border-radius: 12px; box-shadow: 0 4px 18px rgba(15, 23, 42, .06); }
        .table th { white-space: nowrap; color: #475569; font-size: 13px; }
        .table td { vertical-align: middle; }
        @media (max-width: 800px) { .sidebar { position: static; width: 100%; } .sidebar-menu { display: flex; overflow-x: auto; padding: 4px; } .sidebar-menu li { flex: 0 0 auto; } .main-wrapper { margin-left: 0; } .topbar { gap: 12px; flex-wrap: wrap; } }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-brand"><i class="fa-solid fa-store me-2"></i>Store Portal</div>
        <ul class="sidebar-menu">
            <li><a href="${pageContext.request.contextPath}/store-manager/dashboard"><i class="fa-solid fa-chart-pie"></i>Bảng điều khiển</a></li>
            <li><a href="${pageContext.request.contextPath}/store-manager/employees"><i class="fa-solid fa-users"></i>Quản lý nhân sự</a></li>
            <li><a href="${pageContext.request.contextPath}/store-manager/recruitment"><i class="fa-solid fa-file-invoice"></i>Đề xuất nhân sự</a></li>
            <li><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i>Quản lý điều chuyển</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/store-manager/attendance"><i class="fa-solid fa-clipboard-user"></i>Chấm công & Ca làm</a></li>
            <li><a href="${pageContext.request.contextPath}/store-manager/violations"><i class="fa-solid fa-triangle-exclamation"></i>Báo cáo vi phạm</a></li>
            <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-days"></i>Xếp lịch trực tuần</a></li>
            <li><a href="${pageContext.request.contextPath}/store-manager/shift-requests"><i class="fa-solid fa-exchange-alt"></i>Quản lý đổi ca</a></li>
        </ul>
    </aside>
    <div class="main-wrapper">
        <header class="topbar">
            <h1>Hệ Thống Quản Lý Siêu Thị - Chấm công</h1>
            <div>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b> <a class="logout ms-3" href="${pageContext.request.contextPath}/logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a></div>
        </header>
        <main>
            <div class="page-title">
                <h2><i class="fa-solid fa-clipboard-check me-2"></i>Duyệt chấm công</h2>
                <p class="mb-0">Kiểm tra giờ vào/ra và xác nhận tính hợp lệ của bản ghi trong ca đã công bố.</p>
            </div>
            <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>
            <c:if test="${not empty dateError}"><div class="alert alert-warning"><c:out value="${dateError}"/></div></c:if>

            <section class="card">
                <div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap gap-3 p-3">
                    <strong><i class="fa-regular fa-calendar me-2 text-primary"></i>Bảng chấm công theo ngày</strong>
                    <form method="get" action="${pageContext.request.contextPath}/store-manager/attendance" class="d-flex gap-2">
                        <input class="form-control" type="date" name="date" value="${selectedDate}" required>
                        <button class="btn btn-primary" type="submit"><i class="fa-solid fa-filter me-1"></i>Lọc</button>
                    </form>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr><th>Nhân viên</th><th>Chi nhánh</th><th>Ca làm</th><th>Giờ dự kiến</th><th>Giờ vào</th><th>Giờ ra</th><th>Trạng thái</th><th>Lý do điều chỉnh</th><th>Thao tác</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${attendances}" var="record">
                                <tr>
                                    <td><strong><c:out value="${record.fullName}"/></strong><br><small class="text-secondary"><c:out value="${record.username}"/></small></td>
                                    <td><c:out value="${record.branchName}"/></td>
                                    <td><c:out value="${record.shiftName}"/></td>
                                    <td><fmt:formatDate value="${record.shiftStart}" pattern="HH:mm"/> – <fmt:formatDate value="${record.shiftEnd}" pattern="HH:mm"/></td>
                                    <td>
                                        <c:choose><c:when test="${not empty record.checkIn}"><fmt:formatDate value="${record.checkIn}" pattern="HH:mm:ss"/></c:when><c:otherwise><span class="text-danger">Thiếu giờ vào</span></c:otherwise></c:choose>
                                        <c:if test="${record.late}"><br><span class="badge text-bg-warning">Đi trễ</span></c:if>
                                    </td>
                                    <td><c:choose><c:when test="${not empty record.checkOut}"><fmt:formatDate value="${record.checkOut}" pattern="HH:mm:ss"/></c:when><c:otherwise><span class="text-secondary">Chưa chấm ra</span></c:otherwise></c:choose></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${record.status == 'PENDING'}"><span class="badge text-bg-warning">Chờ duyệt</span></c:when>
                                            <c:when test="${record.status == 'VALID'}"><span class="badge text-bg-success">Hợp lệ</span></c:when>
                                            <c:when test="${record.status == 'ADJUSTED'}"><span class="badge text-bg-info">Đã điều chỉnh</span></c:when>
                                            <c:otherwise><span class="badge text-bg-danger">Không hợp lệ</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty record.adjustmentNote}">
                                                <c:out value="${record.adjustmentNote}"/><br>
                                                <small class="text-secondary">
                                                    <c:out value="${record.adjustedBy}"/>
                                                    <c:if test="${not empty record.adjustedAt}"> · <fmt:formatDate value="${record.adjustedAt}" pattern="dd/MM/yyyy HH:mm"/></c:if>
                                                </small>
                                            </c:when>
                                            <c:otherwise><span class="text-secondary">Chưa có</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex gap-1">
                                            <form method="post" action="${pageContext.request.contextPath}/store-manager/attendance">
                                                <input type="hidden" name="attendanceId" value="${record.id}">
                                                <input type="hidden" name="date" value="${selectedDate}">
                                                <button class="btn btn-sm btn-success" name="status" value="VALID" type="submit" title="Xác nhận hợp lệ"><i class="fa-solid fa-check"></i></button>
                                            </form>
                                            <form method="post" action="${pageContext.request.contextPath}/store-manager/attendance">
                                                <input type="hidden" name="attendanceId" value="${record.id}">
                                                <input type="hidden" name="date" value="${selectedDate}">
                                                <button class="btn btn-sm btn-outline-danger" name="status" value="INVALID" type="submit" title="Đánh dấu không hợp lệ"><i class="fa-solid fa-xmark"></i></button>
                                            </form>
                                            <a class="btn btn-sm btn-outline-primary"
                                               href="${pageContext.request.contextPath}/store-manager/attendance?adjustmentId=${record.id}&amp;date=${selectedDate}"
                                               title="Điều chỉnh giờ và ghi lý do">
                                                <i class="fa-solid fa-pen-to-square"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty attendances}">
                                <tr><td colspan="9" class="text-center text-secondary py-4">Ngày này chưa có bản ghi chấm công trong phạm vi chi nhánh.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>
</body>
</html>
