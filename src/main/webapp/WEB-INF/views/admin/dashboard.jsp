<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:58:07
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Trang Quản Trị Hệ Thống (System Admin)</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
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
                background-color: #0f172a;
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
                background-color: #020617;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .sidebar-brand i {
                color: #ef4444;
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
                border-left-color: #ef4444;
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

            /* --- WELCOME BANNER --- */
            .welcome-banner {
                background: linear-gradient(135deg, #dc2626, #991b1b);
                color: white;
                padding: 30px 35px;
                border-radius: 12px;
                margin-bottom: 30px;
                box-shadow: 0 10px 15px -3px rgba(220, 38, 38, 0.2);
                position: relative;
                overflow: hidden;
            }
            .welcome-banner::after {
                content: "\f085";
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
                position: relative;
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
                color: #dc2626;
                text-decoration: none;
                font-weight: 500;
                font-size: 14px;
                transition: gap 0.2s;
            }
            .card-link:hover {
                gap: 12px;
                color: #991b1b;
            }
        </style>
    </head>
    <body>

        <!-- Sidebar Điều Hướng Trái (Admin Portal) -->
        <div class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-shield-halved"></i>
                <span>Admin Control</span>
            </div>
            <ul class="sidebar-menu">
                <li class="active"><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-gauge-high"></i> Tổng quan hệ thống</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/accounts"><i class="fa-solid fa-users-gear"></i> Quản lý tài khoản</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/master-data"><i class="fa-solid fa-database"></i> Quản lý Master Data</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/audit-logs"><i class="fa-solid fa-shield-cat"></i> Audit Log & Giám sát</a></li>
            </ul>
        </div>

        <!-- Main Content Wrapper -->
        <div class="main-wrapper">

            <!-- Top Header -->
            <div class="top-navbar">
                <h1>Hệ Thống Quản Trị Cấp Cao (System Admin Portal)</h1>
                <div class="user-info">
                    <div class="user-profile">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.account.username != null ? sessionScope.account.username : 'Admin'}&background=dc2626&color=fff" alt="Avatar">
                        <span>Xin chào, <b>${sessionScope.account.username != null ? sessionScope.account.username : 'Admin'}</b></span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </div>

            <div class="container">

                <!-- Banner chào mừng -->
                <div class="welcome-banner">
                    <h2>Trung Tâm Quản Trị Hệ Thống (System Administration)</h2>
                    <p>Chào mừng bạn đến với khu vực kiểm soát tối cao của hệ thống chuỗi siêu thị. Từ đây, bạn có thể thực hiện quản lý toàn bộ tài khoản người dùng, phân quyền, cấu hình dữ liệu nền tảng và giám sát nhật ký hoạt động hệ thống.</p>
                </div>

                <!-- Thống kê nhanh KPI hệ thống -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #fef2f2; color: #dc2626;">
                            <i class="fa-solid fa-users"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tổng Tài Khoản</h4>
                            <span>${totalAccounts} Tài khoản</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #fff7ed; color: #f97316;">
                            <i class="fa-solid fa-user-lock"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tài Khoản Đang Khóa</h4>
                            <span>${lockedAccounts} Khóa khẩn cấp</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #eff6ff; color: #2563eb;">
                            <i class="fa-solid fa-shop"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Tổng Chi Nhánh Chuỗi</h4>
                            <span>${totalBranches} Cơ sở</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #f0fdf4; color: #16a34a;">
                            <i class="fa-solid fa-server"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Trạng Thái Máy Chủ</h4>
                            <span style="color: #16a34a;">Hoạt động (Stable)</span>
                        </div>
                    </div>
                </div>

                <!-- Khối danh sách các chức năng cốt lõi dựa trên yêu cầu -->
                <div class="menu-grid">

                    <!-- Tính năng 1: Quản lý tài khoản toàn hệ thống -->
                    <div class="card" style="border-left-color: #dc2626;">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #dc2626;">
                                    <i class="fa-solid fa-users-gear"></i>
                                </div>
                                <h3>Quản Lý Tài Khoản Toàn Hệ Thống</h3>
                            </div>
                            <p>Thực hiện các thao tác CRUD người dùng, khóa/mở khóa tài khoản (Lock/Unlock) khẩn cấp và hỗ trợ reset mật khẩu khi cần thiết.</p>
                        </div>
                        <li><a href="${pageContext.request.contextPath}/admin/accounts"><i class="fa-solid fa-users-gear"></i> Quản lý tài khoản</a>
                    </div>

                    <!-- Tính năng 2: Quản lý Master Data -->
                    <div class="card" style="border-left-color: #f59e0b;">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #f59e0b;">
                                    <i class="fa-solid fa-database"></i>
                                </div>
                                <h3>Quản Lý Master Data</h3>
                            </div>
                            <p>Cấu hình và quản lý dữ liệu nền tảng hệ thống bao gồm danh mục phòng ban, vị trí công việc, loại nhân sự và các thông số cấu hình chung.</p>
                        </div>
                       <a href="${pageContext.request.contextPath}/admin/master-data"><i class="fa-solid fa-database"></i> Quản lý Master Data</a>
                    </div>

                    <!-- Tính năng 3: Giám sát Audit Log -->
                    <div class="card" style="border-left-color: #2563eb;">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #2563eb;">
                                    <i class="fa-solid fa-file-shield"></i>
                                </div>
                                <h3>Audit Log & System Monitoring</h3>
                            </div>
                            <p>Theo dõi lịch sử truy cập, nhật ký thay đổi dữ liệu (Audit Log) và giám sát trạng thái hoạt động bảo mật của toàn bộ hệ thống chuỗi.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/audit-logs"><i class="fa-solid fa-shield-cat"></i> Audit Log & Giám sát</a>
                    </div>

                </div>

            </div>
        </div>

    </body>
</html>