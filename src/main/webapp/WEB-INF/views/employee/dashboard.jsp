<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:07:11
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Employee Dashboard - Vận Hành</title>
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

            /* Container & Welcome Banner */
            .container {
                max-width: 1200px;
                margin: 30px auto;
                padding: 0 20px;
            }
            .welcome-banner {
                background: linear-gradient(135deg, #27ae60, #2ecc71);
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
                border-left: 4px solid #2ecc71;
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
                color: #27ae60;
                text-decoration: none;
                font-weight: 500;
                font-size: 14px;
                transition: color 0.2s;
            }
            .card-link:hover {
                color: #219653;
                text-decoration: underline;
            }
        </style>
    </head>
    <body>

        <!-- Thanh Header đồng bộ hệ thống -->
        <div class="top-navbar">
            <h1>Hệ Thống Quản Lý Siêu Thị - Nhân Viên</h1>
            <div class="user-info">
                <span>Xin chào, <b>${sessionScope.account.username != null ? sessionScope.account.username : 'Employee'}</b></span>
                <a href="${pageContext.request.contextPath}/logout" 
                   style="background-color: #dc3545; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-weight: bold;">
                    Đăng xuất
                </a>
            </div>
        </div>

        <div class="container">

            <!-- Banner chào mừng -->
            <div class="welcome-banner">
                <h2>Trang Nhân Viên Vận Hành (Employee)</h2>
                <p>Chào mừng bạn đến với không gian làm việc cá nhân. Tại đây bạn có thể chủ động đăng ký lịch rảnh, theo dõi lịch làm việc tổng thể sau khi được quản lý phê duyệt và quản lý các công việc ca trực.</p>
            </div>

            <!-- Khối danh sách các chức năng chính -->
            <div class="menu-grid">

                <!-- Tính năng 1: Khai báo thời gian rảnh / Đăng ký lịch -->
                <div class="card" style="border-left-color: #27ae60;">
                    <div>
                        <h3>Khai Báo Lịch Rảnh</h3>
                        <p>Đăng ký lịch làm việc rảnh trong tuần của bạn để Quản lý cửa hàng (Store Manager) căn cứ vào đó sắp xếp và phân công ca trực hợp lý.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/employee/availability" class="card-link">Đăng ký lịch rảnh ngay →</a>
                </div>

                <!-- Tính năng 2: Xem lịch làm việc cá nhân -->
                <div class="card" style="border-left-color: #3498db;">
                    <div>
                        <h3>Lịch Làm Việc Cá Nhân</h3>
                        <p>Xem tổng thể lịch trình các ca làm việc của bạn sau khi quản lý đã hoàn tất sắp xếp và chính thức công bố (Publish).</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/employee/schedule" class="card-link">Xem lịch làm việc ngay</a>
                </div>

                <!-- Tính năng 3: Chấm công Check-in / Check-out -->
                <div class="card" style="border-left-color: #f39c12;">
                    <div>
                        <h3>Chấm Công Trực Tuyến</h3>
                        <p>Thực hiện thao tác điểm danh check-in và check-out vào ca làm việc hằng ngày tại cơ sở của bạn.</p>
                    </div>
                    <a href="#" class="card-link">Truy cập chấm công →</a>
                </div>

                <!-- Tính năng 4: Gửi đơn xin nghỉ / đổi ca -->
                <div class="card" style="border-left-color: #e74c3c;">
                    <div>
                        <h3>Đơn Từ & Khiếu Nại Ca</h3>
                        <p>Gửi các yêu cầu xin nghỉ phép, đổi ca làm việc hoặc phản hồi về lịch trực lên cấp trên xét duyệt.</p>
                    </div>
                    <a href="#" class="card-link">Quản lý đơn từ →</a>
                </div>

            </div>

        </div>

    </body>
</html>