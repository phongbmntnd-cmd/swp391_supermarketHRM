<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:05:59
    Author     : phong
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Trang Quản Trị Nhân Sự (HR) - Supermarket HRM</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <!-- Bootstrap 5 cho bảng và giao diện điều chuyển -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- FontAwesome cho các icon sinh động -->
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

            /* --- WELCOME BANNER --- */
            .welcome-banner {
                background: linear-gradient(135deg, #0284c7, #0369a1);
                color: white;
                padding: 30px 35px;
                border-radius: 12px;
                margin-bottom: 30px;
                box-shadow: 0 10px 15px -3px rgba(2, 132, 199, 0.2);
                position: relative;
                overflow: hidden;
            }
            .welcome-banner::after {
                content: "\f508";
                font-family: "Font Awesome 6 Free";
                font-weight: 900;
                position: absolute;
                right: -20px;
                bottom: -30px;
                font-size: 160px;
                color: rgba(255, 255, 255, 0.08);
            }
            .welcome-banner h2 {
                font-size: 26px;
                margin-bottom: 8px;
                font-weight: 600;
            }
            .welcome-banner p {
                font-size: 14px;
                opacity: 0.9;
                line-height: 1.6;
                max-width: 800px;
            }

            /* --- QUICK STATS / KPI CARDS --- */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }
            .stat-card {
                background: white;
                padding: 20px 25px;
                border-radius: 10px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.02);
                display: flex;
                align-items: center;
                gap: 20px;
                border: 1px solid #f1f5f9;
            }
            .stat-icon {
                width: 50px;
                height: 50px;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 20px;
            }
            .stat-info h4 {
                font-size: 13px;
                color: #64748b;
                margin-bottom: 4px;
                font-weight: 500;
            }
            .stat-info span {
                font-size: 20px;
                font-weight: 700;
                color: #1e293b;
            }

            /* --- MENU GRID CARDS --- */
            .menu-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                gap: 25px;
                margin-bottom: 40px;
            }
            .card-custom {
                background: white;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                transition: all 0.3s ease;
                border: 1px solid #f1f5f9;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                position: relative;
            }
            .card-custom:hover {
                transform: translateY(-5px);
                box-shadow: 0 12px 20px -3px rgba(0,0,0,0.08);
            }
            .card-icon-title {
                display: flex;
                align-items: center;
                gap: 15px;
                margin-bottom: 15px;
            }
            .card-icon {
                width: 45px;
                height: 45px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 18px;
                color: white;
            }
            .card-custom h3 {
                font-size: 18px;
                color: #1e293b;
                font-weight: 600;
            }
            .card-custom p {
                font-size: 14px;
                color: #64748b;
                margin-bottom: 25px;
                line-height: 1.5;
            }
            .card-link {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                color: #0284c7;
                text-decoration: none;
                font-weight: 500;
                font-size: 14px;
                transition: gap 0.2s;
            }
            .card-link:hover {
                gap: 12px;
                color: #0369a1;
            }

            /* --- SECTION PHÊ DUYỆT ĐIỀU CHUYỂN --- */
            .section-transfer {
                background: white;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                border: 1px solid #f1f5f9;
            }
            .section-transfer h3 {
                font-size: 20px;
                font-weight: 600;
                color: #1e293b;
                margin-bottom: 20px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .section-transfer h3 i {
                color: #0284c7;
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
                <li class="active"><a href="${pageContext.request.contextPath}/hr/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/recruitment"><i class="fa-solid fa-user-plus"></i> Phê duyệt đề xuất</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/transfer-requests"><i class="fa-solid fa-right-left"></i> Phê duyệt điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/employee-management"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/attendance-management"><i class="fa-solid fa-clock"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Xác minh vi phạm</a></li>
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

            <div class="container-dashboard">

                <!-- Banner chào mừng -->
                <div class="welcome-banner">
                    <h2>Khu Vực Quản Lý Nhân Sự Toàn Hệ Thống</h2>
                    <p>Chào mừng bạn đến với bảng điều khiển nhân sự cấp cao. Từ đây, bạn có thể thực hiện kiểm duyệt các đề xuất tuyển dụng từ các chi nhánh, quản lý hồ sơ toàn bộ nhân viên, theo dõi hợp đồng lao động và giám sát chấm công chuỗi.</p>
                </div>

                <!-- Thống kê nhanh KPI toàn hệ thống -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #eff6ff; color: #0284c7;">
                            <i class="fa-solid fa-users"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tổng Nhân Sự Chuỗi</h4>
                            <span>${totalEmployees} Nhân viên</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #fdf4ff; color: #c084fc;">
                            <i class="fa-solid fa-file-circle-exclamation"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Đề Xuất Chờ Duyệt</h4>
                            <span>${pendingProposals} Đơn mới</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #f0fdf4; color: #16a34a;">
                            <i class="fa-solid fa-shop"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tổng Số Cơ Sở</h4>
                            <span>${totalBranches} Siêu thị</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #fff7ed; color: #f97316;">
                            <i class="fa-solid fa-user-lock"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tài Khoản Đang Khóa</h4>
                            <span>${totalLocked} Tài khoản</span>
                        </div>
                    </div>
                </div>

                <!-- Khối danh sách các chức năng chính (Menu Grid) -->
                <div class="menu-grid">

                    <!-- Tính năng 1: Phê duyệt đề xuất & cấp tài khoản -->
                    <div class="card-custom">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #0284c7;">
                                    <i class="fa-solid fa-user-check"></i>
                                </div>
                                <h3>Phê Duyệt & Cấp Tài Khoản</h3>
                            </div>
                            <p>Xem xét danh sách đề xuất tuyển dụng từ Store Manager các chi nhánh, thực hiện phê duyệt và khởi tạo tài khoản nhân sự mới tự động.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/hr/recruitment" class="card-link">Phê duyệt đề xuất <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng mới: Phê duyệt điều chuyển nhân sự -->
                    <div class="card-custom">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #f59e0b;">
                                    <i class="fa-solid fa-right-left"></i>
                                </div>
                                <h3>Phê Duyệt Điều Chuyển</h3>
                            </div>
                            <p>Xử lý các yêu cầu điều chuyển nhân sự giữa các cơ sở/chi nhánh, xem xét nhân viên đề cử và cập nhật lịch phân công ca làm việc.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/hr/transfer-requests" class="card-link">Xem đơn điều chuyển <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 2: Quản lý hồ sơ nhân sự -->
                    <div class="card-custom">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #8b5cf6;">
                                    <i class="fa-solid fa-address-card"></i>
                                </div>
                                <h3>Quản Lý Hồ Sơ Nhân Sự</h3>
                            </div>
                            <p>Thêm mới, cập nhật thông tin chi tiết, theo dõi hợp đồng lao động và thông tin liên lạc của nhân viên trên toàn hệ thống các cơ sở.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/hr/employee-management" class="card-link">Quản lý nhân sự <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 3: Quản lý chấm công & ca làm -->
                    <div class="card-custom">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #10b981;">
                                    <i class="fa-solid fa-business-time"></i>
                                </div>
                                <h3>Quản Lý Chấm Công & Ca Làm</h3>
                            </div>
                            <p>Theo dõi bảng chấm công hàng ngày, phê duyệt các đơn từ nghỉ phép hoặc đổi ca và giám sát lịch làm việc chung của các chi nhánh.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/hr/attendance-management" class="card-link">Xem bảng công <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                </div>

                <!-- Section Tích hợp Bảng Phê Duyệt Điều Chuyển Nhân Sự Ngay Trên Dashboard -->
                <div class="section-transfer">
                    <h3><i class="fa-solid fa-list-check"></i> Đơn Đề Xuất Điều Chuyển Chờ Xử Lý</h3>
                    
                    <!-- Thông báo thành công / lỗi nếu có -->
                    <c:if test="${not empty message}"><div class="alert alert-success mt-3"><c:out value="${message}"/></div></c:if>
                    <c:if test="${not empty error}"><div class="alert alert-danger mt-3"><c:out value="${error}"/></div></c:if>

                    <div class="table-responsive mt-3">
                        <table class="table table-bordered align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Đơn</th>
                                    <th>Từ → Đến</th>
                                    <th>Ngày / Ca / Vị trí</th>
                                    <th>Nhân viên đề cử</th>
                                    <th>Xử lý</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${requests}">
                                    <tr>
                                        <td><strong>#${t.id}</strong> (${t.requestedCount} người)<div class="text-muted small"><c:out value="${t.reason}"/></div></td>
                                        <td><span class="badge bg-secondary"><c:out value="${t.sourceStoreName}"/></span> → <span class="badge bg-primary"><c:out value="${t.destinationStoreName}"/></span></td>
                                        <td>${t.workDate} / <c:out value="${t.shiftName}"/> / <span class="fw-semibold"><c:out value="${t.positionName}"/></span></td>
                                        <td>
                                            <c:forEach var="e" items="${selectedByTransfer[t.id]}">
                                                <div><i class="fa-solid fa-user text-secondary me-1"></i> <c:out value="${e.fullName}"/></div>
                                            </c:forEach>
                                        </td>
                                        <td>
                                            <form method="POST" action="${pageContext.request.contextPath}/hr/transfer-requests" class="mb-2" onsubmit="return confirm('Duyệt và chuyển phân công ca?')">
                                                <input type="hidden" name="action" value="approve">
                                                <input type="hidden" name="requestId" value="${t.id}">
                                                <button class="btn btn-success btn-sm w-100"><i class="fa-solid fa-check me-1"></i> Duyệt</button>
                                            </form>
                                            <form method="POST" action="${pageContext.request.contextPath}/hr/transfer-requests">
                                                <input type="hidden" name="action" value="reject">
                                                <input type="hidden" name="requestId" value="${t.id}">
                                                <textarea class="form-control form-control-sm mb-2" name="rejectReason" placeholder="Lý do từ chối" required maxlength="500" rows="1"></textarea>
                                                <button class="btn btn-danger btn-sm w-100"><i class="fa-solid fa-xmark me-1"></i> Từ chối</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty requests}">
                                    <tr><td colspan="5" class="text-center text-muted py-4">Không có đề xuất điều chuyển nào đang chờ HR xử lý</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>

    </body>
</html>