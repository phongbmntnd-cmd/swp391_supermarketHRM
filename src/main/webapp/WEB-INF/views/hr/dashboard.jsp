<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:05:59
    Author     : phong
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Trang Quản Trị Nhân Sự (HR) - Supermarket HRM</title>
        <!-- Sử dụng Google Font cho đẹp mắt -->
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

            /* Header Bar (Đồng bộ chuẩn màu với trang Giám đốc) */
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
                align-items: center;
                gap: 15px;
            }
            .user-info span {
                font-weight: 400;
            }
            .btn-logout {
                background-color: #e74c3c;
                color: white;
                border: none;
                padding: 7px 15px;
                border-radius: 4px;
                cursor: pointer;
                text-decoration: none;
                font-size: 14px;
            }
            .btn-logout:hover {
                background-color: #c0392b;
            }

            /* Main Container */
            .container {
                max-width: 1100px;
                margin: 40px auto;
                padding: 0 20px;
            }

            /* Welcome Banner */
            .welcome-card {
                background: linear-gradient(135deg, #3498db, #2980b9);
                color: white;
                padding: 30px;
                border-radius: 8px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                margin-bottom: 30px;
            }
            .welcome-card h2 {
                font-size: 24px;
                margin-bottom: 10px;
            }
            .welcome-card p {
                font-size: 15px;
                opacity: 0.9;
            }

            /* Grid Menu Cards */
            .menu-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 20px;
            }
            .card {
                background: white;
                padding: 25px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
                transition: transform 0.2s, box-shadow 0.2s;
                border-left: 4px solid #3498db;
            }
            .card:hover {
                transform: translateY(-5px);
                box-shadow: 0 6px 12px rgba(0,0,0,0.1);
            }
            .card h3 {
                font-size: 18px;
                color: #2c3e50;
                margin-bottom: 10px;
            }
            .card p {
                font-size: 14px;
                color: #7f8c8d;
                margin-bottom: 20px;
                line-height: 1.4;
            }

            /* Action Button inside Card */
            .card-link {
                display: inline-block;
                background-color: #3498db;
                color: white;
                padding: 8px 16px;
                border-radius: 4px;
                text-decoration: none;
                font-size: 14px;
                font-weight: 500;
                transition: background-color 0.2s;
            }
            .card-link:hover {
                background-color: #2980b9;
            }
        </style>
    </head>
    <body>

        <!-- Thanh điều hướng phía trên -->
        <div class="top-navbar">
            <h1>Quản Trị Hệ Thống - Nhân Sự (HR)</h1>
            <div class="user-info">
                <span>Xin chào, <b>${sessionScope.account.username}</b></span>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn-logout">Đăng xuất</a>
            </div>
        </div>

        <!-- Nội dung chính -->
        <div class="container">

            <!-- Banner chào mừng -->
            <div class="welcome-card">
                <h2>Khu vực Quản lý Nhân sự toàn hệ thống</h2>
                <p>Chào mừng bạn đến với bảng điều khiển nhân sự. Từ đây, bạn có thể thực hiện các nghiệp vụ quản lý hồ sơ nhân viên, hợp đồng lao động, chấm công và tuyển dụng.</p>
            </div>

            <!-- Khối chức năng (Cards) dành riêng cho HR -->
            <div class="menu-grid">

                <!-- Chức năng 1: Thêm nhân viên / Tạo tài khoản mới -->
                <div class="card">
                    <h3>Thêm Nhân Viên Mới</h3>
                    <p>Đăng ký tài khoản hệ thống, phân quyền vai trò, gán phòng ban và cơ sở làm việc cho nhân sự mới.</p>
                    <a href="${pageContext.request.contextPath}/hr/create-user" class="card-link">Thêm nhân viên →</a>
                </div>

                <!-- Chức năng 2: Quản lý Hồ sơ nhân sự -->
                <div class="card">
                    <h3>Quản lý Hồ sơ Nhân sự</h3>
                    <p>Thêm mới, cập nhật thông tin chi tiết, theo dõi hợp đồng và thông tin liên lạc của nhân viên các cơ sở.</p>
                    <a href="${pageContext.request.contextPath}/hr/employee-management" class="card-link">Quản lý nhân sự →</a>
                </div>

                <!-- Chức năng 3: Quản lý Chấm công / Lịch làm việc -->
                <div class="card">
                    <h3>Quản lý Chấm công & Ca làm</h3>
                    <p>Theo dõi bảng chấm công hàng ngày, phê duyệt đơn nghỉ phép và xếp lịch làm việc cho các chi nhánh.</p>
                    <a href="${pageContext.request.contextPath}/hr/attendance-management" class="card-link">Xem bảng công →</a>
                </div>

            </div>
        </div>

    </body>
</html>
