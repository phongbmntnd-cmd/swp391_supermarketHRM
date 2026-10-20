<%-- 
    Document   : transfer-requests (HR)
    Created on : 19 thg 10, 2026, 11:38:22
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>HR Phê Duyệt Điều Chuyển - Supermarket HRM</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <!-- Bootstrap 5 -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- FontAwesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f4f7f6;
                color: #333;
                display: flex;
                min-height: 100vh;
            }

            /* --- SIDEBAR --- */
            .sidebar {
                width: 260px;
                background-color: #1e293b;
                color: #94a3b8;
                display: flex;
                flex-direction: column;
                position: fixed;
                top: 0;
                bottom: 0;
                left: 0;
                z-index: 100;
                box-shadow: 2px 0 10px rgba(0,0,0,0.1);
            }
            .sidebar-brand {
                padding: 25px 20px;
                font-size: 18px;
                font-weight: 700;
                color: #ffffff;
                background-color: #0f172a;
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
                flex-grow: 1;
            }
            .sidebar-menu li a {
                display: flex;
                align-items: center;
                gap: 15px;
                padding: 14px 25px;
                color: #94a3b8;
                text-decoration: none;
                font-size: 14px;
                font-weight: 500;
                transition: all 0.3s ease;
                border-left: 4px solid transparent;
            }
            .sidebar-menu li a:hover, .sidebar-menu li.active a {
                color: #ffffff;
                background-color: rgba(255, 255, 255, 0.05);
                border-left-color: #38bdf8;
            }
            .sidebar-menu li a i {
                font-size: 16px;
                width: 20px;
                text-align: center;
            }

            /* --- MAIN CONTENT WRAPPER --- */
            .main-wrapper {
                margin-left: 260px;
                flex-grow: 1;
                display: flex;
                flex-direction: column;
            }

            /* --- TOP NAVBAR --- */
            .top-navbar {
                background-color: #ffffff;
                color: #1e293b;
                padding: 15px 35px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 1px 3px rgba(0,0,0,0.05);
                position: sticky;
                top: 0;
                z-index: 99;
            }
            .top-navbar h1 {
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
            .user-info .notification-badge {
                position: relative;
                color: #64748b;
                font-size: 18px;
                cursor: pointer;
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
                transition: all 0.2s;
            }
            .btn-logout:hover {
                background: #ef4444;
                color: white;
            }

            /* --- CONTAINER --- */
            .container-dashboard {
                max-width: 1400px;
                margin: 30px;
                padding: 0;
            }

            /* --- PAGE HEADER CARD --- */
            .page-header-card {
                background: white;
                padding: 25px 30px;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                border: 1px solid #f1f5f9;
                margin-bottom: 25px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .page-header-card h2 {
                font-size: 20px;
                font-weight: 600;
                color: #1e293b;
                display: flex;
                align-items: center;
                gap: 10px;
                margin: 0;
            }
            .page-header-card h2 i {
                color: #0284c7;
            }

            /* --- CONTENT CARD --- */
            .content-card {
                background: white;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                border: 1px solid #f1f5f9;
            }

            /* Custom table styling */
            .table th {
                font-weight: 600;
                color: #475569;
                background-color: #f8fafc !important;
                font-size: 13px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .table td {
                font-size: 14px;
                color: #334155;
            }
        </style>
    </head>
    <body>

        <!-- Sidebar Điều Hướng Trái (HR Portal) -->
        <div class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-user-tie"></i>
                <span>HR Management</span>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/hr/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/recruitment"><i class="fa-solid fa-user-plus"></i> Phê duyệt đề xuất</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/hr/transfer-requests"><i class="fa-solid fa-right-left"></i> Phê duyệt điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/employee-management"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/attendance-management"><i class="fa-solid fa-clock"></i> Chấm công & Ca làm</a></li>
            </ul>
        </div>

        <!-- Main Content Wrapper -->
        <div class="main-wrapper">

            <!-- Top Header -->
            <div class="top-navbar">
                <h1>Hệ Thống Quản Trị Nhân Sự Toàn Hệ Thống (HR Portal)</h1>
                <div class="user-info">
                    <div class="notification-badge" title="Thông báo mới">
                        <i class="fa-regular fa-bell"></i>
                    </div>
                    <div class="user-profile">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.account.username != null ? sessionScope.account.username : 'HR+Manager'}&background=0284c7&color=fff" alt="Avatar">
                        <span>Xin chào, <b>${sessionScope.account.username != null ? sessionScope.account.username : 'HR Manager'}</b></span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </div>

            <!-- Main Container -->
            <div class="container-dashboard">

                <!-- Page Header với nút Quay về (onclick) -->
                <div class="page-header-card">
                    <h2><i class="fa-solid fa-right-left"></i> Phê Duyệt Điều Chuyển Nhân Sự (HR)</h2>
                    <button class="btn btn-outline-secondary btn-sm" onclick="history.back()">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </button>
                </div>

                <!-- Thông báo Thành công / Lỗi -->
                <c:if test="${not empty message}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i><c:out value="${message}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${error}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- Bảng Danh Sách Đơn Điều Chuyển -->
                <div class="content-card">
                    <div class="table-responsive">
                        <table class="table table-bordered align-middle">
                            <thead>
                                <tr>
                                    <th style="width: 20%;">Mã Đơn & Lý Do</th>
                                    <th style="width: 20%;">Từ → Đến Cơ Sở</th>
                                    <th style="width: 22%;">Thời Gian / Ca / Vị Trí</th>
                                    <th style="width: 18%;">Nhân Viên Đề Cử</th>
                                    <th style="width: 20%;">Thao Tác Xử Lý</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${requests}">
                                    <tr>
                                        <td>
                                            <strong class="text-primary">#${t.id}</strong> 
                                            <span class="badge bg-light text-dark border ms-1">${t.requestedCount} người</span>
                                            <div class="text-muted small mt-1"><i class="fa-regular fa-comment-dots me-1"></i><c:out value="${t.reason}"/></div>
                                        </td>
                                        <td>
                                            <div class="d-flex flex-column gap-1">
                                                <span class="badge bg-secondary text-start"><i class="fa-solid fa-shop me-1"></i> <c:out value="${t.sourceStoreName}"/></span>
                                                <div class="text-center text-muted py-1"><i class="fa-solid fa-arrow-down fa-xs"></i></div>
                                                <span class="badge bg-success text-start"><i class="fa-solid fa-shop-lock me-1"></i> <c:out value="${t.destinationStoreName}"/></span>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="small"><strong>Ngày:</strong> ${t.workDate}</div>
                                            <div class="small"><strong>Ca:</strong> <c:out value="${t.shiftName}"/></div>
                                            <div class="small"><strong>Vị trí:</strong> <span class="text-info fw-semibold"><c:out value="${t.positionName}"/></span></div>
                                        </td>
                                        <td>
                                            <c:forEach var="e" items="${selectedByTransfer[t.id]}">
                                                <div class="small mb-1"><i class="fa-solid fa-user text-secondary me-1"></i> <c:out value="${e.fullName}"/></div>
                                            </c:forEach>
                                        </td>
                                        <td>
                                            <!-- Form Duyệt -->
                                            <form method="POST" action="${pageContext.request.contextPath}/hr/transfer-requests" class="mb-2" onsubmit="return confirm('Duyệt và chuyển phân công ca?')">
                                                <input type="hidden" name="action" value="approve">
                                                <input type="hidden" name="requestId" value="${t.id}">
                                                <button class="btn btn-success btn-sm w-100 shadow-sm"><i class="fa-solid fa-check me-1"></i> Duyệt đơn</button>
                                            </form>
                                            <!-- Form Từ chối -->
                                            <form method="POST" action="${pageContext.request.contextPath}/hr/transfer-requests">
                                                <input type="hidden" name="action" value="reject">
                                                <input type="hidden" name="requestId" value="${t.id}">
                                                <textarea class="form-control form-control-sm mb-2" name="rejectReason" placeholder="Nhập lý do từ chối..." required maxlength="500" rows="1" style="font-size: 12px;"></textarea>
                                                <button class="btn btn-outline-danger btn-sm w-100 shadow-sm"><i class="fa-solid fa-xmark me-1"></i> Từ chối</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty requests}">
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-5">
                                            <i class="fa-regular fa-folder-open fa-2x mb-2 text-secondary"></i>
                                            <p class="mb-0">Không có đề xuất đang chờ HR xử lý</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>

        <!-- Bootstrap JS Bundle -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>