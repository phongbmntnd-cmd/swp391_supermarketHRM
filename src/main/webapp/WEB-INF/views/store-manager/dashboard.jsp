<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:06:33
    Author     : phong
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bảng Điều Khiển - Quản Lý Siêu Thị</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
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
            .container {
                max-width: 1400px;
                margin: 30px;
                padding: 0;
            }

            /* --- THANH HIỂN THỊ CƠ SỞ HIỆN TẠI --- */
            .branch-info-bar {
                background-color: #eef2ff;
                border: 1px solid #c7d2fe;
                color: #3730a3;
                padding: 12px 20px;
                border-radius: 6px;
                font-size: 14px;
                margin-bottom: 25px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 500;
            }
            .branch-info-bar i {
                color: #ef4444;
                font-size: 16px;
            }

            /* --- WELCOME BANNER --- */
            .welcome-banner {
                background: linear-gradient(135deg, #2563eb, #1d4ed8);
                color: white;
                padding: 30px 35px;
                border-radius: 12px;
                margin-bottom: 30px;
                box-shadow: 0 10px 15px -3px rgba(37, 99, 235, 0.2);
                position: relative;
                overflow: hidden;
            }
            .welcome-banner::after {
                content: "\f57d";
                font-family: "Font Awesome 6 Free";
                font-weight: 900;
                position: absolute;
                right: -20px;
                bottom: -30px;
                font-size: 160px;
                color: rgba(255, 255, 255, 0.08);
            }
            .welcome-banner h2 {
                font-size: 24px;
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
            }
            .card {
                background: white;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                transition: all 0.3s ease;
                border: 1px solid #f1f5f9;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
            }
            .card:hover {
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
            .card h3 {
                font-size: 18px;
                color: #1e293b;
                font-weight: 600;
            }
            .card p {
                font-size: 14px;
                color: #64748b;
                margin-bottom: 25px;
                line-height: 1.5;
            }
            .card-link {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                color: #2563eb;
                text-decoration: none;
                font-weight: 500;
                font-size: 14px;
                transition: gap 0.2s;
            }
            .card-link:hover {
                gap: 12px;
                color: #1d4ed8;
            }
        </style>
    </head>
    <body>

        <!-- Sidebar Điều Hướng Trái -->
        <div class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-store"></i>
                <span>Store Portal</span>
            </div>
            <ul class="sidebar-menu">
                <li class="active"><a href="${pageContext.request.contextPath}/store-manager/dashboard"><i class="fa-solid fa-chart-pie"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/employees"><i class="fa-solid fa-users"></i> Quản lý nhân sự</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/recruitment"><i class="fa-solid fa-file-invoice"></i> Đề xuất tiếp nhận nhân sự</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i> Quản lý điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/attendance"><i class="fa-solid fa-clipboard-user"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/violations"><i class="fa-solid fa-triangle-exclamation"></i> Báo cáo vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-days"></i> Xếp lịch trực tuần</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/shift-requests"><i class="fa-solid fa-exchange-alt"></i> Quản lí đổi ca</a></li>
            </ul>
        </div>

        <!-- Main Content Wrapper -->
        <div class="main-wrapper">

            <!-- Top Header -->
            <div class="top-navbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Chi Nhánh Trực Thuộc</h1>
                <div class="user-info">
                    <div class="user-profile">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.username != null ? sessionScope.user.username : 'Store+Manager'}&background=2563eb&color=fff" alt="Avatar">
                        <span>Xin chào, <b>${sessionScope.user.username != null ? sessionScope.user.username : 'Store Manager'}</b></span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>

            </div>

            <div class="container">

                <!-- Thanh hiển thị Cơ sở hiện tại -->
                <div class="branch-info-bar">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>Cơ sở hiện tại: <b>${currentBranch != null ? currentBranch.name : 'Đang cập nhật'} (${currentBranch != null ? currentBranch.code : 'N/A'})</b></span>
                </div>

                <!-- Banner chào mừng -->
                <div class="welcome-banner">
                    <h2>Khu Vực Quản Lý Cơ Sở Trực Thuộc</h2>
                    <p>Chào mừng bạn đến với bảng điều khiển cửa hàng. Từ đây, bạn có thể giám sát nhân sự tại cơ sở, thực hiện khóa tài khoản khẩn cấp và gửi các đề xuất nhân sự trực tiếp lên cấp trên (HR) xét duyệt.</p>
                </div>

                <!-- Thống kê nhanh KPI -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #eff6ff; color: #2563eb;">
                            <i class="fa-solid fa-user-group"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tổng Nhân Sự Cơ Sở</h4>
                            <span>${totalEmployees} Nhân viên</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #fdf4ff; color: #c084fc;">
                            <i class="fa-solid fa-clipboard-list"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tổng Số Đề Xuất</h4>
                            <span>${totalProposals} Đơn</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #f0fdf4; color: #22c55e;">
                            <i class="fa-solid fa-calendar-check"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Ca Trực Hôm Nay</h4>
                            <span>${totalShifts} Ca làm</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #fff7ed; color: #f97316;">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tài Khoản Đang Khóa</h4>
                            <span>${lockedCount} Khóa khẩn cấp</span>
                        </div>
                    </div>
                </div>

                <!-- Khối danh sách các chức năng chính -->
                <div class="menu-grid">

                    <!-- Tính năng 1: Quản lý nhân sự cơ sở -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #3b82f6;">
                                    <i class="fa-solid fa-users-gear"></i>
                                </div>
                                <h3>Quản Lý Nhân Sự Cơ Sở</h3>
                            </div>
                            <p>Xem danh sách toàn bộ nhân viên đang làm việc tại cơ sở của bạn, theo dõi thông tin liên lạc và thực hiện khóa tài khoản khẩn cấp khi cần thiết.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/store-manager/employees" class="card-link">Xem danh sách nhân sự <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 2: Quản lý đề xuất tiếp nhận nhân sự -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #f59e0b;">
                                    <i class="fa-solid fa-file-pen"></i>
                                </div>
                                <h3>Quản Lý Đề Xuất Tiếp Nhận Nhân Sự</h3>
                            </div>
                            <p>Lập các yêu cầu tiếp nhận nhân sự mới, gửi trực tiếp lên bộ phận Nhân sự (HR) xem xét và phê duyệt.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/store-manager/recruitment" class="card-link">Thông tin chi tiết <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 3: Quản lý điều chuyển nhân sự -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #0ea5e9;">
                                    <i class="fa-solid fa-right-left"></i>
                                </div>
                                <h3>Quản Lý Điều Chuyển Nhân Sự</h3>
                            </div>
                            <p>Theo dõi các yêu cầu mượn nhân sự gửi đi và tiếp nhận, xem xét phê duyệt hoặc từ chối các yêu cầu điều chuyển từ các cơ sở khác gửi đến.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/store-manager/transfer-requests" class="card-link">Quản lý điều chuyển <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 4: Chấm công & Ca làm việc -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #10b981;">
                                    <i class="fa-solid fa-clock-rotate-left"></i>
                                </div>
                                <h3>Chấm Công & Ca Làm Việc</h3>
                            </div>
                            <p>Theo dõi bảng điểm danh hàng ngày của nhân viên tại cơ sở, kiểm tra giờ giấc và duyệt các đơn từ liên quan đến ca làm.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/store-manager/attendance" class="card-link">Xem bảng công <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 5: Xếp lịch & Phân công ca -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #8b5cf6;">
                                    <i class="fa-solid fa-calendar-week"></i>
                                </div>
                                <h3>Xếp Lịch & Phân Công Ca</h3>
                            </div>
                            <p>Xem lịch rảnh đã đăng ký của nhân viên, tiến hành xếp lịch trực tuần tới và Publish (công bố) lịch cho toàn nhân viên theo dõi.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/store-manager/schedule" class="card-link">Quản lý lịch làm việc <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 6: Quản lý đổi ca -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon"
                                     style="background-color: #10b981;">
                                    <i class="fa-solid fa-people-arrows-left-right"></i>
                                </div>
                                <h3>Quản Lý Đổi Ca</h3>
                            </div>
                            <p> Xem xét, tiếp nhận và phê duyệt các đơn đổi ca giữa nhân viên cùng chi nhánh.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/store-manager/shift-requests"
                           class="card-link">
                            Xem yêu cầu đổi ca
                            <i class="fa-solid fa-arrow-right"></i>
                        </a>
                    </div>

                    <!-- Tính năng 7: Báo cáo vi phạm -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon"
                                     style="background-color: #ef4444;">
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                </div>
                                <h3>Báo cáo vi phạm</h3>
                            </div>
                            <p> Ghi nhận sự việc để HR xác minh trước khi có quyết định xử lý.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/store-manager/violations"
                           class="card-link">
                            Thông tin chi tiết
                            <i class="fa-solid fa-arrow-right"></i>
                        </a>
                    </div>
                </div>

            </div>
        </div>

    </body>
</html>