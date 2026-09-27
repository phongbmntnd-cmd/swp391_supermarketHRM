<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:06:33
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Store Manager Dashboard</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 20px;
                background-color: #f5f5f5;
            }
            .container {
                max-width: 800px;
                margin: 0 auto;
                background: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h2 {
                color: #333;
                border-bottom: 2px solid #3498db;
                padding-bottom: 10px;
            }
            .menu-section {
                margin-top: 20px;
            }
            .menu-item {
                display: block;
                padding: 15px 20px;
                margin: 10px 0;
                background: #f8f9fa;
                border-left: 4px solid #3498db;
                text-decoration: none;
                color: #333;
                border-radius: 4px;
                transition: all 0.3s;
            }
            .menu-item:hover {
                background: #e8f4fc;
                transform: translateX(5px);
            }
            .menu-item .icon {
                font-size: 20px;
                margin-right: 10px;
            }
            .menu-item .title {
                font-weight: bold;
            }
            .menu-item .desc {
                color: #666;
                font-size: 14px;
                margin-top: 5px;
            }
            .menu-item.employee {
                border-left-color: #27ae60;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h2>🏪 Trang Quản Lý Cửa Hàng (Store Manager)</h2>
            <p>Xin chào, <strong>${sessionScope.account.username}</strong>!</p>
            
            <div class="menu-section">
                <!-- PHẦN ĐẠT 2 - Nhân sự -->
                <a href="${pageContext.request.contextPath}/store-manager/employees" class="menu-item employee">
                    <span class="icon">👥</span>
                    <div>
                        <div class="title">Quản lý Nhân sự</div>
                        <div class="desc">Xem danh sách nhân viên, Emergency Lock/Unlock</div>
                    </div>
                </a>
                
                <!-- Các chức năng khác của Store Manager -->
                <a href="#" class="menu-item">
                    <span class="icon">📅</span>
                    <div>
                        <div class="title">Lập lịch làm việc tuần & Open Shift</div>
                        <div class="desc">Quản lý ca làm việc</div>
                    </div>
                </a>
                
                <a href="#" class="menu-item">
                    <span class="icon">✅</span>
                    <div>
                        <div class="title">Giám sát điểm danh & chấm công</div>
                        <div class="desc">Theo dõi giờ làm việc</div>
                    </div>
                </a>
                
                <a href="#" class="menu-item">
                    <span class="icon">📋</span>
                    <div>
                        <div class="title">Duyệt đơn nghỉ phép / đổi ca</div>
                        <div class="desc">Xử lý yêu cầu từ nhân viên</div>
                    </div>
                </a>
            </div>
        </div>
    </body>
</html>
