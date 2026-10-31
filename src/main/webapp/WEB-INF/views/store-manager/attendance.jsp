<%-- 
    Document   : attendance
    Created on : 23 thg 9, 2026, 00:06:33
    Author     : phong
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Quản lý chấm công - Store Manager</title>
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
                color: #1e293b;
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
                flex-grow: 1;
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
                transition: all 0.3s ease;
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

            /* --- MAIN WRAPPER & TOPBAR --- */
            .main-wrapper {
                margin-left: 260px;
                flex: 1;
                min-width: 0;
                display: flex;
                flex-direction: column;
            }
            .topbar {
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
            .topbar h1 {
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
            .logout {
                color: #ef4444;
                text-decoration: none;
                background: #ffeeef;
                padding: 6px 14px;
                border-radius: 6px;
                font-weight: 500;
                font-size: 13px;
                white-space: nowrap;
                transition: all 0.2s;
            }
            .logout:hover {
                background: #ef4444;
                color: white;
            }

            /* --- CONTAINER & CONTENT --- */
            .dashboard-container {
                max-width: 1400px;
                margin: 30px;
            }
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
                background: linear-gradient(135deg, #10b981, #059669);
                color: white;
                border-radius: 12px;
                padding: 25px 30px;
                margin-bottom: 25px;
                box-shadow: 0 10px 15px -3px rgba(16, 185, 129, 0.2);
            }
            .page-title h2 {
                font-size: 24px;
                margin: 0 0 6px;
                font-weight: 600;
            }
            .card {
                border: 0;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                border: 1px solid #f1f5f9;
            }
            .table th {
                white-space: nowrap;
                color: #475569;
                font-size: 13px;
                background-color: #f8fafc;
            }
            .table td {
                vertical-align: middle;
            }
            @media (max-width: 900px) {
                .sidebar {
                    width: 220px;
                }
                .main-wrapper {
                    margin-left: 220px;
                }
                .dashboard-container {
                    margin: 20px;
                }
            }
            @media (max-width: 650px) {
                body {
                    display: block;
                }
                .sidebar {
                    position: static;
                    width: 100%;
                }
                .sidebar-menu {
                    display: flex;
                    overflow-x: auto;
                    padding: 5px 0;
                }
                .sidebar-menu li {
                    flex: 0 0 auto;
                }
                .main-wrapper {
                    margin-left: 0;
                }
                .topbar {
                    position: static;
                    flex-wrap: wrap;
                }
                .dashboard-container {
                    margin: 15px;
                }
            }
        </style>
    </head>
    <body>

        <!-- Sidebar Điều Hướng Trái -->
        <aside class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-store"></i>
                <span>Store Manager</span>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/store-manager/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/employees"><i class="fa-solid fa-users-gear"></i> Nhân sự cơ sở</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/recruitment"><i class="fa-solid fa-file-pen"></i> Đề xuất tuyển dụng</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i> Quản lý điều chuyển</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/store-manager/attendance"><i class="fa-solid fa-clock-rotate-left"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-week"></i> Xếp lịch & Phân ca</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/violations"><i class="fa-solid fa-triangle-exclamation"></i> Báo cáo vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/leave-requests"><i class="fa-solid fa-plane-departure"></i> Duyệt nghỉ phép</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/shift-requests"><i class="fa-solid fa-rotate"></i> Duyệt đổi ca</a></li>
            </ul>
        </aside>

        <!-- Main Wrapper -->
        <div class="main-wrapper">
            <header class="topbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Chi Nhánh Trực Thuộc</h1>
                <div class="user-info">
                    <div class="user-profile">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.username != null ? sessionScope.user.username : (sessionScope.account.username != null ? sessionScope.account.username : 'Store+Manager')}&background=2563eb&color=fff" alt="Avatar">
                        <span>Xin chào, <b><c:out value="${sessionScope.user.username != null ? sessionScope.user.username : (sessionScope.account.username != null ? sessionScope.account.username : 'Store Manager')}"/></b></span>
                    </div>
                    <a class="logout" href="${pageContext.request.contextPath}/logout">
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

                <!-- Page Title Header với Nút Dashboard -->
                <div class="page-title d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h2><i class="fa-solid fa-clipboard-check me-2"></i>Duyệt Chấm Công & Ca Làm</h2>
                        <p class="mb-0">Kiểm tra giờ vào/ra và xác nhận tính hợp lệ của bản ghi trong ca đã công bố.</p>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/store-manager/dashboard" class="btn btn-outline-light px-3 py-2 fw-semibold">
                            <i class="fa-solid fa-arrow-left me-1"></i> Dashboard
                        </a>
                    </div>
                </div>

                <!-- Alerts -->
                <c:if test="${not empty successMessage}"><div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert"><i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
                <c:if test="${not empty errorMessage}"><div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert"><i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
                <c:if test="${not empty dateError}"><div class="alert alert-warning alert-dismissible fade show shadow-sm" role="alert"><i class="fa-solid fa-triangle-exclamation me-2"></i><c:out value="${dateError}"/><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

                    <!-- Main Content Card -->
                    <section class="card shadow-sm">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap gap-3 p-3">
                            <strong><i class="fa-regular fa-calendar me-2 text-primary"></i>Bảng chấm công theo ngày</strong>
                            <form method="get" action="${pageContext.request.contextPath}/store-manager/attendance" class="d-flex gap-2">
                            <input class="form-control form-control-sm" type="date" name="date" value="${selectedDate}" required>
                            <button class="btn btn-primary btn-sm px-3" type="submit"><i class="fa-solid fa-filter me-1"></i>Lọc</button>
                        </form>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Nhân viên</th>
                                    <th>Chi nhánh</th>
                                    <th>Ca làm</th>
                                    <th>Giờ dự kiến</th>
                                    <th>Giờ vào</th>
                                    <th>Giờ ra</th>
                                    <th>Trạng thái</th>
                                    <th>Lý do điều chỉnh</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${attendances}" var="record">
                                    <tr>
                                        <td><strong><c:out value="${record.fullName}"/></strong><br><small class="text-secondary"><c:out value="${record.username}"/></small></td>
                                        <td><c:out value="${record.branchName}"/></td>
                                        <td><c:out value="${record.shiftName}"/></td>
                                        <td><fmt:formatDate value="${record.shiftStart}" pattern="HH:mm"/> – <fmt:formatDate value="${record.shiftEnd}" pattern="HH:mm"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty record.checkIn}"><fmt:formatDate value="${record.checkIn}" pattern="HH:mm:ss"/></c:when>
                                                <c:otherwise><span class="text-danger small fw-semibold">Thiếu giờ vào</span></c:otherwise>
                                            </c:choose>
                                            <c:if test="${record.late}"><br><span class="badge bg-warning text-dark mt-1">Đi trễ</span></c:if>
                                            </td>
                                            <td>
                                            <c:choose>
                                                <c:when test="${not empty record.checkOut}"><fmt:formatDate value="${record.checkOut}" pattern="HH:mm:ss"/></c:when>
                                                <c:otherwise><span class="text-secondary small">Chưa chấm ra</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${record.status == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ duyệt</span></c:when>
                                                <c:when test="${record.status == 'VALID'}"><span class="badge bg-success">Hợp lệ</span></c:when>
                                                <c:when test="${record.status == 'ADJUSTED'}"><span class="badge bg-info text-dark">Đã điều chỉnh</span></c:when>
                                                <c:otherwise><span class="badge bg-danger">Không hợp lệ</span></c:otherwise>
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
                                                <c:otherwise><span class="text-secondary small">Chưa có</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <div class="d-flex justify-content-center gap-1">
                                                <form method="post" action="${pageContext.request.contextPath}/store-manager/attendance" class="d-inline">
                                                    <input type="hidden" name="attendanceId" value="${record.id}">
                                                    <input type="hidden" name="date" value="${selectedDate}">
                                                    <button class="btn btn-sm btn-success" name="status" value="VALID" type="submit" title="Xác nhận hợp lệ"><i class="fa-solid fa-check"></i></button>
                                                </form>
                                                <form method="post" action="${pageContext.request.contextPath}/store-manager/attendance" class="d-inline">
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
                                    <tr><td colspan="9" class="text-center text-secondary py-4"><i class="fa-regular fa-folder-open fa-2x mb-2 d-block"></i>Ngày này chưa có bản ghi chấm công trong phạm vi chi nhánh.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>