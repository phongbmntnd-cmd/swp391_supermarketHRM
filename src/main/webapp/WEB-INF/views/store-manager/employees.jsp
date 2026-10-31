<%-- 
    Document   : store-manager-employees
    Created on : Oct 27, 2026, 10:18:16 PM
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Quản lý Nhân sự cơ sở - Store Manager</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                margin: 0;
                font-family: 'Roboto', sans-serif;
                background: #f4f7f6;
                color: #333;
                display: flex;
                min-height: 100vh;
            }
            /* --- SIDEBAR --- */
            .sidebar {
                width: 260px;
                background: #1e293b;
                color: #94a3b8;
                display: flex;
                flex-direction: column;
                position: fixed;
                inset: 0 auto 0 0;
                z-index: 100;
                box-shadow: 2px 0 10px rgba(0,0,0,.1);
            }
            .sidebar-brand {
                padding: 25px 20px;
                font-size: 18px;
                font-weight: 700;
                color: #fff;
                background: #0f172a;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .sidebar-brand i {
                color: #38bdf8;
                font-size: 22px;
            }
            .sidebar-menu {
                list-style: none;
                padding: 20px 0;
                margin: 0;
                overflow-y: auto;
            }
            .sidebar-menu a {
                display: flex;
                align-items: center;
                gap: 15px;
                padding: 14px 25px;
                color: #94a3b8;
                text-decoration: none;
                font-size: 14px;
                font-weight: 500;
                border-left: 4px solid transparent;
            }
            .sidebar-menu a:hover, .sidebar-menu .active a {
                color: #fff;
                background: rgba(255,255,255,.05);
                border-left-color: #38bdf8;
            }
            .sidebar-menu i {
                width: 20px;
                text-align: center;
            }
            /* --- MAIN WRAPPER & TOP NAVBAR --- */
            .main-wrapper {
                margin-left: 260px;
                flex: 1;
                min-width: 0;
            }
            .top-navbar {
                background: #fff;
                color: #1e293b;
                padding: 15px 35px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 20px;
                box-shadow: 0 1px 3px rgba(0,0,0,.05);
                position: sticky;
                top: 0;
                z-index: 99;
            }
            .top-navbar h1 {
                margin: 0;
                font-size: 18px;
                font-weight: 500;
                color: #334155;
            }
            .user-info {
                display: flex;
                align-items: center;
                gap: 20px;
                font-size: 14px;
            }
            .user-profile {
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .user-profile img {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                object-fit: cover;
                border: 2px solid #e2e8f0;
            }
            .btn-logout {
                color: #ef4444;
                text-decoration: none;
                background: #ffeeef;
                padding: 6px 14px;
                border-radius: 6px;
                font-weight: 500;
                font-size: 13px;
                white-space: nowrap;
            }
            .dashboard-container {
                max-width: 1400px;
                margin: 30px;
            }
            /* --- PAGE HEADER & BRANCH BAR --- */
            .branch-info-bar {
                background-color: #eef2ff;
                border: 1px solid #c7d2fe;
                color: #3730a3;
                padding: 12px 20px;
                border-radius: 8px;
                font-size: 14px;
                margin-bottom: 25px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 500;
            }
            .branch-info-bar i {
                color: #2563eb;
                font-size: 16px;
            }
            .page-title {
                background: linear-gradient(135deg,#0284c7,#0369a1);
                color: #fff;
                padding: 25px 30px;
                border-radius: 12px;
                margin-bottom: 25px;
                box-shadow: 0 10px 15px -3px rgba(2,132,199,.2);
            }
            .page-title h2 {
                margin: 0 0 8px;
                font-size: 24px;
            }
            .page-title p {
                margin: 0;
                opacity: .9;
            }
            .card {
                border: 0;
                border-radius: 10px;
            }
            .card-header {
                background: #fff;
                padding: 16px 20px;
            }
            /* Table & Badges */
            .status-badge {
                display: inline-block;
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: bold;
            }
            .status-active { background-color: #d4edda; color: #155724; }
            .status-locked { background-color: #f8d7da; color: #721c24; }
            .status-inactive { background-color: #e2e3e5; color: #383d41; }
            
            /* Locked Section Specifics */
            .locked-section {
                margin-top: 40px;
                padding-top: 30px;
                border-top: 2px dashed #cbd5e1;
            }
            .locked-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 12px 20px;
                background: #fff1f2;
                border: 1px solid #fecdd3;
                border-radius: 8px;
                cursor: pointer;
                user-select: none;
            }
            .locked-section h2 {
                color: #e11d48;
                margin: 0;
                font-size: 18px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .locked-section h2 .count {
                background: #e11d48;
                color: white;
                padding: 2px 10px;
                border-radius: 12px;
                font-size: 13px;
            }
            .locked-filter {
                background: #fff5f5;
                padding: 20px;
                border-radius: 0 0 8px 8px;
                border: 1px solid #fecdd3;
                border-top: none;
                margin-bottom: 20px;
            }
            .table-locked th {
                background-color: #ffe4e6 !important;
                color: #be123c !important;
            }
            .reason-cell {
                max-width: 200px;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }
            .reason-cell:hover {
                overflow: visible;
                white-space: normal;
                word-wrap: break-word;
            }
            /* Modal Styles */
            .modal {
                display: none;
                position: fixed;
                top: 0; left: 0; width: 100%; height: 100%;
                background-color: rgba(0,0,0,0.5);
                z-index: 1000;
            }
            .modal-content {
                position: absolute;
                top: 50%; left: 50%;
                transform: translate(-50%, -50%);
                background: white;
                padding: 30px;
                border-radius: 10px;
                max-width: 500px;
                width: 90%;
                box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            }
            @media (max-width: 900px) {
                .sidebar { width: 220px; }
                .main-wrapper { margin-left: 220px; }
                .dashboard-container { margin: 20px; }
            }
            @media (max-width: 650px) {
                body { display: block; }
                .sidebar { position: static; width: 100%; }
                .sidebar-menu { display: flex; overflow-x: auto; padding: 5px 0; }
                .sidebar-menu li { flex: 0 0 auto; }
                .main-wrapper { margin-left: 0; }
                .top-navbar { position: static; flex-wrap: wrap; }
                .dashboard-container { margin: 15px; }
            }
        </style>
    </head>
    <body>

        <!-- Sidebar Điều Hướng Trái (Store Manager) -->
        <aside class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-store"></i>
                <span>Store Manager</span>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/store-manager/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/store-manager/employees"><i class="fa-solid fa-users-gear"></i> Nhân sự cơ sở</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/recruitment"><i class="fa-solid fa-file-pen"></i> Đề xuất tuyển dụng</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i> Quản lý điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/attendance"><i class="fa-solid fa-clock-rotate-left"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-week"></i> Xếp lịch & Phân ca</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/violations"><i class="fa-solid fa-triangle-exclamation"></i> Báo cáo vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/leave-requests"><i class="fa-solid fa-plane-departure"></i> Duyệt nghỉ phép</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/shift-requests"><i class="fa-solid fa-rotate"></i> Duyệt đổi ca</a></li>
            </ul>
        </aside>

        <!-- Main Content Wrapper -->
        <div class="main-wrapper">

            <!-- Top Header -->
            <header class="top-navbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Chi Nhánh Trực Thuộc</h1>
                <div class="user-info">
                    <div class="user-profile">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.username != null ? sessionScope.user.username : 'Store+Manager'}&background=2563eb&color=fff" alt="Avatar">
                        <span>Xin chào, <b><c:out value="${sessionScope.user.username != null ? sessionScope.user.username : 'Store Manager'}"/></b></span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </header>

            <div class="dashboard-container">

                <!-- Thanh hiển thị Cơ sở hiện tại -->
                <div class="branch-info-bar">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>Cơ sở hiện tại: <b><c:choose>
                        <c:when test="${not empty currentBranch}">
                            <c:out value="${currentBranch.name}"/> (<c:out value="${currentBranch.code}"/>) - <c:out value="${currentBranch.address}"/>
                        </c:when>
                        <c:otherwise>Không xác định được cơ sở của bạn</c:otherwise>
                    </c:choose></b></span>
                </div>

                <!-- Page Header Banner -->
                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-users-gear me-2"></i>Quản lý Nhân sự cơ sở</h2>
                        <p class="mb-0">Xem danh sách nhân viên đang làm việc, theo dõi liên lạc và thực hiện khóa tài khoản khẩn cấp.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/store-manager/dashboard" class="btn btn-light text-primary fw-semibold shadow-sm px-3 py-2">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay về Dashboard
                    </a>
                </div>
                
                <!-- Messages -->
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <!-- Filter Section -->
                <div class="card shadow-sm mb-4">
                    <div class="card-header fw-semibold"><i class="fa-solid fa-filter text-primary me-2"></i>Tìm kiếm & lọc nhân sự</div>
                    <div class="card-body">
                        <form method="GET" action="${pageContext.request.contextPath}/store-manager/employees" id="filterForm">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label for="search" class="form-label">🔍 Tìm kiếm</label>
                                    <input type="text" id="search" name="search" class="form-control" placeholder="Họ tên, username, email, SĐT..." value="<c:out value='${search}'/>">
                                </div>
                                <div class="col-md-2">
                                    <label for="positionId" class="form-label">📌 Vị trí</label>
                                    <select id="positionId" name="positionId" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="pos" items="${positions}">
                                            <option value="${pos.id}" ${positionId == pos.id ? 'selected' : ''}><c:out value="${pos.title}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="departmentId" class="form-label">🏢 Phòng ban</label>
                                    <select id="departmentId" name="departmentId" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="dept" items="${departments}">
                                            <option value="${dept.id}" ${departmentId == dept.id ? 'selected' : ''}><c:out value="${dept.name}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="employeeType" class="form-label">👤 Loại nhân viên</label>
                                    <select id="employeeType" name="employeeType" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <option value="Full-time" ${employeeType == 'FULL_TIME' || employeeType == 'Full-time' ? 'selected' : ''}>Full-time</option>
                                        <option value="Part-time" ${employeeType == 'PART_TIME' || employeeType == 'Part-time' ? 'selected' : ''}>Part-time</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label for="status" class="form-label">📊 Trạng thái</label>
                                    <div class="input-group">
                                        <select id="status" name="status" class="form-select">
                                            <option value="">-- Tất cả --</option>
                                            <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                            <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                            <option value="EMERGENCY_LOCKED" ${status == 'EMERGENCY_LOCKED' ? 'selected' : ''}>EMERGENCY_LOCKED</option>
                                        </select>
                                        <button type="submit" class="btn btn-primary"><i class="fa-solid fa-magnifying-glass"></i></button>
                                        <a href="${pageContext.request.contextPath}/store-manager/employees" class="btn btn-outline-secondary" title="Xóa lọc"><i class="fa-solid fa-rotate-right"></i></a>
                                    </div>
                                </div>
                            </div>
                            <input type="hidden" name="sort" value="<c:out value='${sortColumn}'/>">
                            <input type="hidden" name="dir" value="<c:out value='${sortDirection}'/>">
                        </form>
                    </div>
                </div>
                
                <!-- Employee Table Card -->
                <div class="card shadow-sm mb-4">
                    <div class="table-responsive">
                        <c:choose>
                            <c:when test="${not empty employees}">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>STT</th>
                                            <th>
                                                <a href="?search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=full_name&dir=${sortColumn == 'full_name' && sortDirection == 'ASC' ? 'DESC' : 'ASC'}&page=1&size=${pageSize}" class="text-decoration-none text-dark">
                                                    Họ và tên ${sortColumn == 'full_name' ? (sortDirection == 'ASC' ? '▲' : '▼') : ''}
                                                </a>
                                            </th>
                                            <th>
                                                <a href="?search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=username&dir=${sortColumn == 'username' && sortDirection == 'ASC' ? 'DESC' : 'ASC'}&page=1&size=${pageSize}" class="text-decoration-none text-dark">
                                                    Username ${sortColumn == 'username' ? (sortDirection == 'ASC' ? '▲' : '▼') : ''}
                                                </a>
                                            </th>
                                            <th>Email</th>
                                            <th>Số điện thoại</th>
                                            <th>Vị trí</th>
                                            <th>Phòng ban</th>
                                            <th>Loại NV</th>
                                            <th>Trạng thái</th>
                                            <th class="text-center">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="emp" items="${employees}" varStatus="loop">
                                            <tr>
                                                <td>${(currentPage - 1) * pageSize + loop.index + 1}</td>
                                                <td><strong><c:out value="${emp.fullName}"/></strong></td>
                                                <td><c:out value="${emp.username}"/></td>
                                                <td><c:out value="${emp.email}"/></td>
                                                <td><c:out value="${emp.phone}"/></td>
                                                <td><c:out value="${emp.positionName}"/></td>
                                                <td><c:out value="${emp.departmentName}"/></td>
                                                <td><c:out value="${emp.employeeType}"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${emp.status == 'ACTIVE'}">
                                                            <span class="status-badge status-active">ACTIVE</span>
                                                        </c:when>
                                                        <c:when test="${emp.status == 'INACTIVE'}">
                                                            <span class="status-badge status-inactive">INACTIVE</span>
                                                        </c:when>
                                                        <c:when test="${emp.status == 'EMERGENCY_LOCKED'}">
                                                            <span class="status-badge status-locked">EMERGENCY_LOCKED</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge status-inactive"><c:out value="${emp.status}"/></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <div class="action-buttons justify-content-center">
                                                        <c:choose>
                                                            <c:when test="${emp.status == 'ACTIVE'}">
                                                                <button type="button" class="btn btn-danger btn-sm"
                                                                        onclick="showLockModal(this)"
                                                                        data-userid="${emp.userId}"
                                                                        data-name="${fn:escapeXml(emp.fullName)}">
                                                                    <i class="fa-solid fa-lock me-1"></i> Khóa
                                                                </button>
                                                            </c:when>
                                                            <c:when test="${emp.status == 'EMERGENCY_LOCKED'}">
                                                                <button type="button" class="btn btn-success btn-sm"
                                                                        onclick="showUnlockModal(this)"
                                                                        data-userid="${emp.userId}"
                                                                        data-name="${fn:escapeXml(emp.fullName)}">
                                                                    <i class="fa-solid fa-lock-open me-1"></i> Mở khóa
                                                                </button>
                                                            </c:when>
                                                        </c:choose>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-5">
                                    <i class="fa-regular fa-folder-open fs-2 mb-2 text-muted"></i>
                                    <p class="text-secondary mb-0">Không tìm thấy nhân viên nào phù hợp với điều kiện tìm kiếm.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <!-- Pagination -->
                <c:if test="${not empty employees}">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div class="text-muted small">
                            Hiển thị <strong>${(currentPage - 1) * pageSize + 1}</strong> - <strong>${displayEnd}</strong> trong tổng số <strong>${totalRecords}</strong> nhân viên
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <form method="GET" class="d-flex align-items-center gap-2" id="pageSizeForm">
                                <span class="small text-muted">Hiển thị:</span>
                                <select name="size" class="form-select form-select-sm" onchange="document.getElementById('pageSizeForm').submit()">
                                    <c:forEach var="ps" items="${pageSizes}">
                                        <option value="${ps}" ${pageSize == ps ? 'selected' : ''}>${ps}</option>
                                    </c:forEach>
                                </select>
                                <input type="hidden" name="search" value="<c:out value='${search}'/>">
                                <input type="hidden" name="positionId" value="${positionId}">
                                <input type="hidden" name="departmentId" value="${departmentId}">
                                <input type="hidden" name="employeeType" value="${employeeType}">
                                <input type="hidden" name="status" value="<c:out value='${status}'/>">
                                <input type="hidden" name="sort" value="<c:out value='${sortColumn}'/>">
                                <input type="hidden" name="dir" value="<c:out value='${sortDirection}'/>">
                            </form>
                            
                            <ul class="pagination pagination-sm mb-0">
                                <c:if test="${currentPage > 1}">
                                    <li class="page-item"><a class="page-link" href="?page=1&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">«</a></li>
                                    <li class="page-item"><a class="page-link" href="?page=${currentPage - 1}&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">‹</a></li>
                                </c:if>
                                <c:forEach var="i" begin="${pagerStart}" end="${pagerEnd}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <c:choose>
                                            <c:when test="${i == currentPage}">
                                                <span class="page-link">${i}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="page-link" href="?page=${i}&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">${i}</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </li>
                                </c:forEach>
                                <c:if test="${currentPage < totalPages}">
                                    <li class="page-item"><a class="page-link" href="?page=${currentPage + 1}&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">›</a></li>
                                    <li class="page-item"><a class="page-link" href="?page=${totalPages}&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">»</a></li>
                                </c:if>
                            </ul>
                        </div>
                    </div>
                </c:if>
                
                <!-- LOCKED EMPLOYEES SECTION -->
                <div class="locked-section" id="lockedEmployeesSection" style="display: none;">
                    <div class="locked-header" onclick="toggleLockedSection()">
                        <h2><i class="fa-solid fa-triangle-exclamation"></i> Nhân viên đã bị khóa <span class="count" id="lockedCount">0</span></h2>
                        <span id="toggleIcon" class="fw-bold">▼</span>
                    </div>

                    <div id="lockedContent" class="card shadow-sm border-top-0 rounded-bottom">
                        <form method="GET" action="${pageContext.request.contextPath}/store-manager/employees" class="locked-filter">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label text-danger fw-bold small">🔍 Tìm nhân viên</label>
                                    <input type="text" name="lockedSearch" class="form-control form-control-sm" placeholder="Tên, username, email..." value="<c:out value='${lockedSearch}'/>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label text-danger fw-bold small">📝 Lý do khóa</label>
                                    <input type="text" name="lockedReasonSearch" class="form-control form-control-sm" placeholder="Từ khóa trong lý do..." value="<c:out value='${lockedReasonSearch}'/>">
                                </div>
                                <div class="col-md-4 d-flex align-items-end gap-2">
                                    <div class="flex-grow-1">
                                        <label class="form-label text-danger fw-bold small">👮 Người khóa</label>
                                        <input type="text" name="lockedBySearch" class="form-control form-control-sm" placeholder="Tên người khóa..." value="<c:out value='${lockedBySearch}'/>">
                                    </div>
                                    <button type="submit" class="btn btn-sm btn-danger"><i class="fa-solid fa-magnifying-glass"></i></button>
                                    <a href="${pageContext.request.contextPath}/store-manager/employees#lockedEmployeesSection" class="btn btn-sm btn-outline-secondary" title="Xóa lọc"><i class="fa-solid fa-rotate-right"></i></a>
                                </div>
                            </div>
                            <input type="hidden" name="search" value="<c:out value='${search}'/>">
                            <input type="hidden" name="positionId" value="${positionId}">
                            <input type="hidden" name="departmentId" value="${departmentId}">
                            <input type="hidden" name="employeeType" value="${employeeType}">
                            <input type="hidden" name="status" value="<c:out value='${status}'/>">
                            <input type="hidden" name="sort" value="<c:out value='${sortColumn}'/>">
                            <input type="hidden" name="dir" value="<c:out value='${sortDirection}'/>">
                            <input type="hidden" name="page" value="${currentPage}">
                            <input type="hidden" name="size" value="${pageSize}">
                        </form>

                        <div class="table-responsive">
                            <c:choose>
                                <c:when test="${not empty lockedEmployees}">
                                    <table class="table table-hover align-middle mb-0 table-locked">
                                        <thead>
                                            <tr>
                                                <th>STT</th>
                                                <th>Họ và tên</th>
                                                <th>Username</th>
                                                <th>Email</th>
                                                <th>SĐT</th>
                                                <th>Vị trí</th>
                                                <th>Phòng ban</th>
                                                <th>Người khóa</th>
                                                <th>Thời gian khóa</th>
                                                <th>Lý do</th>
                                                <th class="text-center">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="lock" items="${lockedEmployees}" varStatus="loop">
                                                <tr>
                                                    <td>${(currentLockedPage - 1) * lockedPageSize + loop.index + 1}</td>
                                                    <td><strong><c:out value="${lock.userName}"/></strong></td>
                                                    <td><c:out value="${lock.username}"/></td>
                                                    <td><c:out value="${lock.email}"/></td>
                                                    <td><c:out value="${lock.phone}"/></td>
                                                    <td><c:out value="${lock.positionName}"/></td>
                                                    <td><c:out value="${lock.departmentName}"/></td>
                                                    <td><c:out value="${lock.lockedByName}"/></td>
                                                    <td><fmt:formatDate value="${lock.lockedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                                    <td class="reason-cell" title="<c:out value='${lock.reason}'/>">
                                                        <c:choose>
                                                            <c:when test="${not empty lock.reason}"><c:out value="${lock.reason}"/></c:when>
                                                            <c:otherwise><em class="text-muted">Không có</em></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center">
                                                        <button type="button" class="btn btn-success btn-sm"
                                                                onclick="showUnlockModalFromLocked(this)"
                                                                data-userid="${lock.userId}"
                                                                data-name="${fn:escapeXml(lock.userName)}">
                                                            <i class="fa-solid fa-lock-open me-1"></i> Mở khóa
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-4 text-muted bg-white">
                                        <i class="fa-solid fa-circle-check text-success fs-4 mb-1"></i>
                                        <p class="mb-0">Không có nhân viên nào bị khóa phù hợp với bộ lọc.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        
        <!-- Lock Confirmation Modal -->
        <div id="lockModal" class="modal" onclick="closeLockModal()">
            <div class="modal-content" onclick="event.stopPropagation()">
                <h3 class="h5 text-danger mb-3"><i class="fa-solid fa-lock me-2"></i>Xác nhận Khóa Khẩn cấp</h3>
                <p class="mb-3">Bạn có chắc chắn muốn khóa tài khoản nhân viên <strong id="lockEmployeeName"></strong>?</p>
                <form method="POST" action="${pageContext.request.contextPath}/store-manager/employees">
                    <input type="hidden" name="action" value="lock">
                    <input type="hidden" name="userId" id="lockUserId">
                    <div class="mb-3">
                        <label for="lockReason" class="form-label small fw-bold">Lý do khóa (tùy chọn):</label>
                        <textarea name="reason" id="lockReason" class="form-control" rows="3" placeholder="Nhập lý do khóa tài khoản..."></textarea>
                    </div>
                    <div class="d-flex justify-content-end gap-2">
                        <button type="button" class="btn btn-secondary btn-sm" onclick="closeLockModal()">Hủy</button>
                        <button type="submit" class="btn btn-danger btn-sm">Xác nhận Khóa</button>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Unlock Confirmation Modal -->
        <div id="unlockModal" class="modal" onclick="closeUnlockModal()">
            <div class="modal-content" onclick="event.stopPropagation()">
                <h3 class="h5 text-success mb-3"><i class="fa-solid fa-lock-open me-2"></i>Xác nhận Mở khóa</h3>
                <p class="mb-3">Bạn có chắc chắn muốn mở khóa tài khoản nhân viên <strong id="unlockEmployeeName"></strong>?</p>
                <form method="POST" action="${pageContext.request.contextPath}/store-manager/employees">
                    <input type="hidden" name="action" value="unlock">
                    <input type="hidden" name="userId" id="unlockUserId">
                    <div class="d-flex justify-content-end gap-2">
                        <button type="button" class="btn btn-secondary btn-sm" onclick="closeUnlockModal()">Hủy</button>
                        <button type="submit" class="btn btn-success btn-sm">Xác nhận Mở khóa</button>
                    </div>
                </form>
            </div>
        </div>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            var totalLocked = ${totalLockedRecords != null ? totalLockedRecords : 0};
            if (totalLocked > 0) {
                var section = document.getElementById('lockedEmployeesSection');
                section.style.display = 'block';
                document.getElementById('lockedCount').textContent = totalLocked;
                var content = document.getElementById('lockedContent');
                content.style.display = 'block';
                document.getElementById('toggleIcon').textContent = '▼';
            }

            function toggleLockedSection() {
                var content = document.getElementById('lockedContent');
                var icon = document.getElementById('toggleIcon');
                if (content.style.display === 'none') {
                    content.style.display = 'block';
                    icon.textContent = '▼';
                } else {
                    content.style.display = 'none';
                    icon.textContent = '▶';
                }
            }
            
            function showLockModal(btn) {
                var userId = btn.getAttribute('data-userid');
                var fullName = btn.getAttribute('data-name');
                document.getElementById('lockUserId').value = userId;
                document.getElementById('lockEmployeeName').textContent = fullName || 'Nhân viên';
                document.getElementById('lockModal').style.display = 'block';
            }

            function closeLockModal() {
                document.getElementById('lockModal').style.display = 'none';
            }

            function showUnlockModal(btn) {
                var userId = btn.getAttribute('data-userid');
                var fullName = btn.getAttribute('data-name');
                document.getElementById('unlockUserId').value = userId;
                document.getElementById('unlockEmployeeName').textContent = fullName || 'Nhân viên';
                document.getElementById('unlockModal').style.display = 'block';
            }

            function showUnlockModalFromLocked(btn) {
                showUnlockModal(btn);
            }
            
            function closeUnlockModal() {
                document.getElementById('unlockModal').style.display = 'none';
            }
            
            document.addEventListener('click', function(event) {
                var lockModal = document.getElementById('lockModal');
                var unlockModal = document.getElementById('unlockModal');
                if (event.target === lockModal) closeLockModal();
                if (event.target === unlockModal) closeUnlockModal();
            });
            
            document.addEventListener('keydown', function(event) {
                if (event.key === 'Escape') {
                    closeLockModal();
                    closeUnlockModal();
                }
            });
            
            setTimeout(function() {
                var alerts = document.querySelectorAll('.alert');
                alerts.forEach(function(alert) {
                    alert.style.opacity = '0';
                    setTimeout(function() { alert.style.display = 'none'; }, 300);
                });
            }, 5000);
        </script>
    </body>
</html>