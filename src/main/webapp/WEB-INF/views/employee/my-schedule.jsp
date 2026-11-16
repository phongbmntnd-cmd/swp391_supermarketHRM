<%-- Employee my-schedule: giao diện đồng bộ Employee Portal --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Làm Việc Cá Nhân - Nhân Viên</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; background: #f4f7f6; color: #334155; font-family: 'Roboto', sans-serif; display: flex; }
        .sidebar { width: 280px; flex: 0 0 280px; min-height: 100vh; background: #1e293b; color: #94a3b8; }
        .sidebar-brand { display: flex; align-items: center; gap: 10px; padding: 25px 20px; background: #0f172a; color: white; font-size: 18px; font-weight: 700; }
        .sidebar-brand i { color: #22c55e; font-size: 22px; }
        .sidebar-menu { list-style: none; padding: 20px 0; margin: 0; }
        .sidebar-menu li a { display: flex; align-items: center; gap: 15px; padding: 14px 25px; color: #94a3b8; text-decoration: none; font-size: 14px; font-weight: 500; border-left: 4px solid transparent; }
        .sidebar-menu li a:hover, .sidebar-menu li.active a { color: #fff; background: rgba(255,255,255,.05); border-left-color: #22c55e; }
        .sidebar-menu i { width: 20px; text-align: center; }
        .main-wrapper { flex: 1; min-width: 0; }
        .top-navbar { background: #fff; padding: 17px 34px; display: flex; justify-content: space-between; align-items: center; gap: 15px; box-shadow: 0 1px 3px rgba(0,0,0,.05); position: sticky; top: 0; z-index: 20; }
        .top-navbar h1 { font-size: 18px; font-weight: 500; margin: 0; color: #334155; }
        .user-info { display: flex; align-items: center; gap: 16px; font-size: 14px; }
        .btn-logout { color: #ef4444; text-decoration: none; background: #ffeeef; padding: 7px 13px; border-radius: 6px; font-size: 13px; font-weight: 500; white-space: nowrap; }
        .btn-logout:hover { color: #fff; background: #ef4444; }
        .main-container { max-width: 1400px; margin: 30px auto; padding: 0 30px; }
        .page-heading { display: flex; align-items: center; justify-content: space-between; gap: 14px; flex-wrap: wrap; margin-bottom: 20px; }
        .page-heading h2 { margin: 0 0 5px; font-size: 23px; font-weight: 700; }
        .page-heading p { margin: 0; color: #64748b; font-size: 14px; }
        .card-custom { background: white; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,.05); border: none; overflow: hidden; margin-bottom: 30px; }
        .card-header-custom { background: linear-gradient(135deg,#16a34a,#15803d); color: #fff; padding: 23px 28px; }
        .card-header-custom h2 { font-size: 21px; font-weight: 600; margin: 0; }
        .table > thead > tr > th { background: #f8fafc; color: #334155; font-size: 12px; font-weight: 600; text-transform: uppercase; padding: 12px 8px; }
        .table tbody td { padding: 15px; vertical-align: middle; }
        .shift-info { font-weight: 600; color: #2c3e50; font-size: 14px; }
        .shift-time { font-size: 11px; color: #7f8c8d; display: block; margin-top: 2px; }
        .schedule-box { background: #e8f8f5; border: 2px dashed #27ae60; border-radius: 8px; padding: 10px; color: #1e8449; font-weight: 600; text-align: center; }
        .schedule-empty { color: #95a5a6; font-style: italic; font-size: 13px; text-align: center; }
        .branch-position-badge { white-space: normal; line-height: 1.6; text-align: left; }
        @media (max-width: 850px) {
            body { display: block; }
            .sidebar { width: 100%; min-height: auto; }
            .sidebar-menu { display: flex; overflow-x: auto; padding: 5px; }
            .sidebar-menu li { flex-shrink: 0; }
            .sidebar-menu li a { white-space: nowrap; padding: 12px; }
            .main-wrapper { width: 100%; }
            .top-navbar { position: static; padding: 15px 18px; flex-wrap: wrap; }
            .main-container { padding: 0 15px; margin-top: 20px; }
            .card-header-custom { padding: 18px; }
        }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-brand"><i class="fa-solid fa-id-badge"></i><span>Employee Portal</span></div>
        <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-house"></i> Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/availability"><i class="fa-solid fa-calendar-plus"></i> Khai báo lịch rảnh</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/employee/my-schedule"><i class="fa-solid fa-calendar-check"></i> Lịch làm việc</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/attendance"><i class="fa-solid fa-fingerprint"></i> Chấm công trực tuyến</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/payroll"><i class="fa-solid fa-money-bill-wave"></i> Phiếu lương</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/leave-request"><i class="fa-solid fa-plane-departure"></i> Xin nghỉ phép</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/forms"><i class="fa-solid fa-rotate"></i> Đổi ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/violations"><i class="fa-solid fa-triangle-exclamation"></i> Vi phạm & kết quả</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/profile"><i class="fa-solid fa-address-card"></i>Hồ sơ cá nhân</a></li>
            </ul>
    </aside>

    <div class="main-wrapper">
        <header class="top-navbar">
            <h1>Hệ Thống Quản Lý Siêu Thị - Không Gian Nhân Viên</h1>
            <div class="user-info">
                <span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket me-1"></i> Đăng xuất</a>
            </div>
        </header>

        <main class="main-container">
            <div class="page-heading">
                <div>
                    <h2>Lịch Làm Việc Của Tôi</h2>
                    <p>Theo dõi lịch trực chính thức đã được quản lý công bố.</p>
                </div>
                <a href="${pageContext.request.contextPath}/employee/dashboard" class="btn btn-outline-secondary btn-sm px-3 py-2"><i class="fa-solid fa-arrow-left me-1"></i> Quay lại Dashboard</a>
            </div>

            <div class="card card-custom">
                <div class="card-header-custom d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h2><i class="fa-solid fa-calendar-days me-2"></i> Lịch Trực Chính Thức</h2>
                        <p class="mb-0 small mt-1"><i class="fa-solid fa-clock-rotate-left me-1"></i> Áp dụng từ: <strong><c:out value="${startDate}"/></strong> đến <strong><c:out value="${endDate}"/></strong></p>
                    </div>
                    <div class="d-flex align-items-center gap-3 flex-wrap">
                        <div class="btn-group" role="group">
                            <a href="${pageContext.request.contextPath}/employee/my-schedule?startDate=${prevWeekDate}" class="btn btn-outline-light btn-sm px-3"><i class="fa-solid fa-chevron-left me-1"></i> Tuần trước</a>
                            <a href="${pageContext.request.contextPath}/employee/my-schedule?startDate=${nextWeekDate}" class="btn btn-outline-light btn-sm px-3">Tuần sau <i class="fa-solid fa-chevron-right ms-1"></i></a>
                        </div>
                        <span class="badge bg-light text-success p-2 fs-6 shadow-sm branch-position-badge">
                            <i class="fa-solid fa-store me-1"></i> <c:out value="${branchName}"/>
                            &nbsp;|&nbsp; <i class="fa-solid fa-briefcase me-1"></i> <c:out value="${positionTitle}"/>
                        </span>
                    </div>
                </div>
                <div class="p-4">
                    <p class="text-muted mb-4"><i class="fa-solid fa-circle-info me-1"></i> Dưới đây là các ca làm việc đã được Store Manager phê duyệt và công bố chính thức dành riêng cho bạn:</p>
                    <div class="table-responsive">
                        <table class="table table-bordered text-center align-middle">
                            <thead><tr>
                                <th style="width: 15%;">Ca Làm Việc</th>
                                <c:forEach var="dName" items="${dayNames}"><th><c:out value="${dName}"/></th></c:forEach>
                            </tr></thead>
                            <tbody>
                                <c:forEach var="shift" items="${shifts}">
                                    <tr>
                                        <td style="text-align:left; padding-left:15px;">
                                            <span class="shift-info">
                                                <c:choose>
                                                    <c:when test="${fn:contains(fn:toLowerCase(shift.name),'sáng')}"><i class="fa-solid fa-sun text-warning me-1"></i></c:when>
                                                    <c:when test="${fn:contains(fn:toLowerCase(shift.name),'chiều')}"><i class="fa-solid fa-cloud-sun text-info me-1"></i></c:when>
                                                    <c:otherwise><i class="fa-solid fa-moon text-primary me-1"></i></c:otherwise>
                                                </c:choose>
                                                <c:out value="${shift.name}"/>
                                            </span>
                                            <span class="shift-time"><c:out value="${shift.startTime}"/> - <c:out value="${shift.endTime}"/></span>
                                        </td>
                                        <c:forEach var="day" items="${days}">
                                            <td>
                                                <c:set var="cellKey" value="${shift.id}_${dayDateMap[day]}" />
                                                <c:set var="isAssigned" value="false" />
                                                <c:forEach var="asg" items="${mySchedules}">
                                                    <c:if test="${asg eq cellKey}"><c:set var="isAssigned" value="true" /></c:if>
                                                </c:forEach>
                                                <c:choose>
                                                    <c:when test="${isAssigned}">
                                                        <div class="schedule-box">
                                                            <i class="fa-solid fa-circle-check me-1"></i> Trực Ca
                                                            <c:if test="${not empty transferredBranches[cellKey]}">(<c:out value="${transferredBranches[cellKey]}"/>)</c:if>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise><div class="schedule-empty">Nghỉ</div></c:otherwise>
                                                </c:choose>
                                            </td>
                                        </c:forEach>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
