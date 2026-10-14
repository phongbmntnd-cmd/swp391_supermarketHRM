<%--
    Document   : dashboard
    Created on : 13 thg 10, 2026
    Author     : Admin
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Bảng Điều Khiển - Quản Trị Hệ Thống</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
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
            }

            /* Top Navigation Bar đồng bộ */
            .top-navbar {
                background-color: #2c3e50;
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            }
            .top-navbar h1 {
                font-size: 20px;
                font-weight: 500;
            }
            .user-info {
                display: flex;
                gap: 15px;
                align-items: center;
                font-size: 14px;
            }
            .btn-logout {
                color: #e74c3c;
                text-decoration: none;
                background: rgba(255,255,255,0.1);
                padding: 6px 12px;
                border-radius: 4px;
                transition: background 0.2s;
            }
            .btn-logout:hover {
                background: rgba(255,255,255,0.2);
            }

            /* Container & Welcome Banner */
            .container {
                max-width: 1200px;
                margin: 30px auto;
                padding: 0 20px;
            }
            .welcome-banner {
                background: linear-gradient(135deg, #3498db, #2980b9);
                color: white;
                padding: 25px 30px;
                border-radius: 8px;
                margin-bottom: 30px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            }
            .welcome-banner h2 {
                font-size: 24px;
                margin-bottom: 8px;
                font-weight: 500;
            }
            .welcome-banner p {
                font-size: 14px;
                opacity: 0.9;
                line-height: 1.5;
            }

            /* Grid Cards Chức năng */
            .menu-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
                gap: 20px;
            }
            .card {
                background: white;
                padding: 25px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
                transition: transform 0.2s, box-shadow 0.2s;
                border-left: 4px solid #3498db;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
            }
            .card:hover {
                transform: translateY(-3px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }
            .card h3 {
                font-size: 18px;
                color: #2c3e50;
                margin-bottom: 10px;
            }
            .card p {
                font-size: 14px;
                color: #666;
                margin-bottom: 20px;
                line-height: 1.4;
            }

            /* Links & Buttons */
            .card-link {
                display: inline-block;
                color: #3498db;
                text-decoration: none;
                font-weight: 500;
                font-size: 14px;
                transition: color 0.2s;
            }
            .card-link:hover {
                color: #2980b9;
                text-decoration: underline;
            }
        </style>
    </head>
    <body>

        <!-- Thanh Header đồng bộ hệ thống -->
        <div class="top-navbar">
            <h1>Hệ Thống Quản Lý Siêu Thị - Quản Trị Viên</h1>
            <div class="user-info">
                <span>Xin chào, <b>${sessionScope.account.username != null ? sessionScope.account.username : 'Admin'}</b></span>
                <a href="${pageContext.request.contextPath}/logout"
                   style="background-color: #dc3545; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-weight: bold;">
                    Đăng xuất
                </a>
            </div>
        </div>

        <div class="container">

            <!-- Banner chào mừng -->
            <div class="welcome-banner">
                <h2>Khu Vực Quản Trị Hệ Thống</h2>
                <p>Chào mừng bạn đến với bảng điều khiển Quản trị viên. Từ đây, bạn có toàn quyền quản lý tài khoản người dùng, dữ liệu nền tảng (phòng ban, vị trí, vai trò) và giám sát mọi hoạt động trong hệ thống.</p>
            </div>

            <!-- Khối danh sách các chức năng chính -->
            <div class="menu-grid">

                <!-- Tính năng 1: Quản lý Tài khoản toàn hệ thống -->
                <div class="card" style="border-left-color: #e74c3c;">
                    <div>
                        <h3>Quản Lý Tài Khoản</h3>
                        <p>Xem, tạo mới, cập nhật thông tin tài khoản cho mọi đối tượng trong hệ thống. Thực hiện khóa/mở khóa khẩn cấp và đặt lại mật khẩu cho người dùng.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/accounts" class="card-link">Quản lý tài khoản →</a>
                </div>

                <!-- Tính năng 2: Quản lý Master Data -->
                <div class="card" style="border-left-color: #f39c12;">
                    <div>
                        <h3>Quản Lý Dữ Liệu Nền</h3>
                        <p>Thiết lập và chỉnh sửa các dữ liệu nền tảng: phòng ban, vị trí công việc, vai trò người dùng. Đảm bảo hệ thống luôn có cấu trúc tổ chức rõ ràng.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/master-data" class="card-link">Quản lý Master Data →</a>
                </div>

                <!-- Tính năng 3: Xem Audit Log -->
                <div class="card" style="border-left-color: #9b59b6;">
                    <div>
                        <h3>Nhật Ký Hoạt Động (Audit Log)</h3>
                        <p>Theo dõi toàn bộ thao tác của người dùng trong hệ thống: khóa/mở khóa tài khoản, tạo mới, cập nhật. Hỗ trợ truy vết và kiểm tra an toàn thông tin.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/audit-logs" class="card-link">Xem nhật ký →</a>
                </div>

            </div>

        </div>

    </body>
</html>
