<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:07:11
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Employee Dashboard - Vận Hành</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <!-- FontAwesome cho các icon sinh động -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <!-- Sidebar dùng chung (Employee / Store Manager) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
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
                overflow-x: hidden;
            }

            /* --- MAIN WRAPPER CHUẨN RESPONSIVE --- */
            .main-wrapper {
                flex: 1;
                display: flex;
                flex-direction: column;
                min-width: 0; /* Tránh tràn layout flex item */
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
                flex-wrap: wrap;
                gap: 15px;
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
            .container {
                max-width: 1400px;
                width: 100%;
                margin: 0 auto;
                padding: 30px;
            }

            /* --- THANH HIỂN THỊ CƠ SỞ & VỊ TRÍ --- */
            .branch-info-bar {
                background-color: #e2f8eb;
                border: 1px solid #bbf7d0;
                color: #166534;
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
                color: #16a34a;
                font-size: 16px;
            }

            /* --- WELCOME BANNER --- */
            .welcome-banner {
                background: linear-gradient(135deg, #16a34a, #15803d);
                color: white;
                padding: 30px 35px;
                border-radius: 12px;
                margin-bottom: 30px;
                box-shadow: 0 10px 15px -3px rgba(22, 163, 74, 0.2);
                position: relative;
                overflow: hidden;
            }
            .welcome-banner::after {
                content: "\f5fc";
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
                min-width: 50px;
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
                font-size: 16px;
                font-weight: 700;
                color: #1e293b;
            }

            /* --- MENU GRID CARDS --- */
            .menu-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
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
                min-width: 45px;
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
                color: #16a34a;
                text-decoration: none;
                font-weight: 500;
                font-size: 14px;
                transition: gap 0.2s;
            }
            .card-link:hover {
                gap: 12px;
                color: #15803d;
            }

            /* Responsive điều chỉnh padding khi màn hình nhỏ */
            @media (max-width: 768px) {
                .container {
                    padding: 15px;
                }
                .top-navbar {
                    padding: 12px 20px;
                }
                .welcome-banner {
                    padding: 20px;
                }
                .welcome-banner h2 {
                    font-size: 22px;
                }
            }
        </style>
    </head>
    <body>

        <!-- Sidebar Điều Hướng Trái (Nhân viên dùng chung qua fragment) -->
        <jsp:include page="/WEB-INF/views/fragments/employee-sidebar.jsp"/>

        <!-- Main Content Wrapper -->
        <div class="main-wrapper">

            <!-- Top Header -->
            <div class="top-navbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Không Gian Nhân Viên</h1>
                <div class="user-info">
                    <div class="notification-badge" title="Thông báo mới">
                        <i class="fa-regular fa-bell"></i>
                    </div>
                    <div class="user-profile">
                        <img src="https://ui-avatars.com/api/?name=${emp != null && emp.fullName != null ? emp.fullName : 'Employee'}&background=16a34a&color=fff" alt="Avatar">
                        <span>Xin chào, <b>${emp != null && emp.fullName != null ? emp.fullName : sessionScope.account.username}</b></span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </div>

            <div class="container">

                <!-- Thanh hiển thị Cơ sở làm việc và Vị trí của nhân viên -->
                <div class="branch-info-bar">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>Cơ sở làm việc: <b>${emp != null && emp.branchName != null ? emp.branchName : 'Chưa phân công'}</b> \vert{} Vị trí: <b>${emp != null && emp.positionTitle != null ? emp.positionTitle : 'Nhân viên vận hành'}</b></span>
                </div>

                <!-- Banner chào mừng -->
                <div class="welcome-banner">
                    <h2>Trang Nhân Viên Vận Hành (Employee Portal)</h2>
                    <p>Chào mừng bạn đến với không gian làm việc cá nhân. Tại đây bạn có thể chủ động đăng ký lịch rảnh, theo dõi lịch làm việc tổng thể sau khi được quản lý phê duyệt và thực hiện các thao tác chấm công, gửi đơn từ nhanh chóng.</p>
                </div>

                <!-- Thống kê nhanh KPI cá nhân -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #f0fdf4; color: #16a34a;">
                            <i class="fa-solid fa-calendar-day"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Ca Trực Hôm Nay</h4>
                            <c:choose>
                                <c:when test="${not empty todayShifts}">
                                    <ul style="list-style-type: none; padding: 0; margin: 0;">
                                        <c:forEach var="shift" items="${todayShifts}">
                                            <li style="font-weight: 700; color: #16a34a; font-size: 14px;">${shift}</li>
                                        </c:forEach>
                                    </ul>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: #64748b; font-weight: 500;">Hôm nay nghỉ</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #eff6ff; color: #2563eb;">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Trạng Thái Chấm Công</h4>
                            <span>Chưa Check-in</span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #fdf4ff; color: #c084fc;">
                            <i class="fa-solid fa-envelope-open-text"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Đơn Từ / Khiếu Nại</h4>
                            <span>
                                <c:choose>
                                    <c:when test="${pendingRequestCount > 0}">
                                        ${pendingRequestCount} Đơn chờ duyệt
                                    </c:when>
                                    <c:otherwise>
                                        0 Đơn chờ duyệt
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon" style="background: #fff7ed; color: #f97316;">
                            <i class="fa-solid fa-shield-halved"></i>
                        </div>
                        <div class="stat-info">
                            <h4>Trạng Thái Tài Khoản</h4>
                            <span style="color: #16a34a;">Hoạt động (Active)</span>
                        </div>
                    </div>
                </div>

                <!-- Khối danh sách các chức năng chính (Menu Grid) -->
                <div class="menu-grid">

                    <!-- Tính năng 1: Khai báo lịch rảnh -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #16a34a;">
                                    <i class="fa-solid fa-calendar-plus"></i>
                                </div>
                                <h3>Khai Báo Lịch Rảnh</h3>
                            </div>
                            <p>Đăng ký lịch làm việc rảnh trong tuần của bạn để Quản lý cửa hàng (Store Manager) căn cứ vào đó sắp xếp và phân công ca trực hợp lý.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/employee/availability" class="card-link">Đăng ký lịch rảnh ngay <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 2: Xem lịch làm việc cá nhân -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #3b82f6;">
                                    <i class="fa-solid fa-calendar-check"></i>
                                </div>
                                <h3>Lịch Làm Việc Cá Nhân</h3>
                            </div>
                            <p>Xem tổng thể lịch trình các ca làm việc của bạn sau khi quản lý đã hoàn tất sắp xếp và chính thức công bố (Publish).</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/employee/my-schedule" class="card-link">Xem lịch làm việc ngay <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 3: Chấm công Check-in / Check-out -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #f59e0b;">
                                    <i class="fa-solid fa-fingerprint"></i>
                                </div>
                                <h3>Chấm Công Trực Tuyến</h3>
                            </div>
                            <p>Thực hiện thao tác điểm danh check-in và check-out vào ca làm việc hằng ngày tại cơ sở của bạn.</p>
                        </div>
                        <a href="#" class="card-link">Truy cập chấm công <i class="fa-solid fa-arrow-right"></i></a>
                    </div>

                    <!-- Tính năng 4: Gửi đơn xin nghỉ / đổi ca -->
                    <div class="card">
                        <div>
                            <div class="card-icon-title">
                                <div class="card-icon" style="background-color: #ef4444;">
                                    <i class="fa-solid fa-file-lines"></i>
                                </div>
                                <h3>Đơn Từ & Khiếu Nại Ca</h3>
                            </div>
                            <p>Gửi các yêu cầu xin nghỉ phép, đổi ca làm việc hoặc phản hồi về lịch trực lên cấp trên xét duyệt.</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/employee/forms" class="card-link">Quản lý đơn từ →</a>
                    </div>
                </div>

            </div>
        </div>

    <script src="${pageContext.request.contextPath}/js/sidebar.js"></script>

    </body>
</html>