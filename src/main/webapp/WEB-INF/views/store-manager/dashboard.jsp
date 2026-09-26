<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng Điều Khiển - Quản Lý Cửa Hàng</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Roboto', sans-serif; background-color: #f4f7f6; color: #333; }
        
        /* Top Navigation Bar đồng bộ */
        .top-navbar { background-color: #2c3e50; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .top-navbar h1 { font-size: 20px; font-weight: 500; }
        .user-info { display: flex; gap: 15px; align-items: center; font-size: 14px; }
        .btn-logout { color: #e74c3c; text-decoration: none; background: rgba(255,255,255,0.1); padding: 6px 12px; border-radius: 4px; transition: background 0.2s; }
        .btn-logout:hover { background: rgba(255,255,255,0.2); }

        /* Container & Welcome Banner */
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        .welcome-banner { background: linear-gradient(135deg, #3498db, #2980b9); color: white; padding: 25px 30px; border-radius: 8px; margin-bottom: 30px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .welcome-banner h2 { font-size: 24px; margin-bottom: 8px; font-weight: 500; }
        .welcome-banner p { font-size: 14px; opacity: 0.9; line-height: 1.5; }

        /* Grid Cards Chức năng */
        .menu-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 20px; }
        .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); transition: transform 0.2s, box-shadow 0.2s; border-left: 4px solid #3498db; display: flex; flex-direction: column; justify-content: space-between; }
        .card:hover { transform: translateY(-3px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        .card h3 { font-size: 18px; color: #2c3e50; margin-bottom: 10px; }
        .card p { font-size: 14px; color: #666; margin-bottom: 20px; line-height: 1.4; }
        
        /* Links & Buttons */
        .card-link { display: inline-block; color: #3498db; text-decoration: none; font-weight: 500; font-size: 14px; transition: color 0.2s; }
        .card-link:hover { color: #2980b9; text-decoration: underline; }
    </style>
</head>
<body>

    <!-- Thanh Header đồng bộ hệ thống -->
    <div class="top-navbar">
        <h1>Hệ Thống Quản Lý Siêu Thị - Cửa Hàng</h1>
        <div class="user-info">
            <span>Xin chào, <b>${sessionScope.user.username != null ? sessionScope.user.username : 'Store Manager'}</b></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
        </div>
    </div>

    <div class="container">

        <!-- Banner chào mừng -->
        <div class="welcome-banner">
            <h2>Khu Vực Quản Lý Cơ Sở Trực Thuộc</h2>
            <p>Chào mừng bạn đến với bảng điều khiển cửa hàng. Từ đây, bạn có thể giám sát nhân sự tại cơ sở, thực hiện khóa tài khoản khẩn cấp và gửi các đề xuất nhân sự trực tiếp lên cấp trên (HR) xét duyệt.</p>
        </div>

        <!-- Khối danh sách các chức năng chính -->
        <div class="menu-grid">
            
            <!-- Tính năng 1: Xem danh sách nhân sự & Khóa khẩn cấp -->
            <div class="card" style="border-left-color: #3498db;">
                <div>
                    <h3>Quản Lý Nhân Sự Cơ Sở</h3>
                    <p>Xem danh sách toàn bộ nhân viên đang làm việc tại cơ sở của bạn, theo dõi thông tin liên lạc và thực hiện khóa tài khoản khẩn cấp khi cần thiết.</p>
                </div>
                <a href="${pageContext.request.contextPath}/store-manager/branch-employees" class="card-link">Xem danh sách nhân sự →</a>
            </div>

            <!-- Tính năng 2: Đề xuất nhân sự gửi lên HR -->
            <div class="card" style="border-left-color: #f39c12;">
                <div>
                    <h3>Gửi Đề Xuất Nhân Sự</h3>
                    <p>Lập các yêu cầu tuyển dụng mới, đề xuất điều chuyển nhân sự hoặc thay đổi vị trí công việc gửi trực tiếp lên bộ phận Nhân sự (HR) xem xét và phê duyệt.</p>
                </div>
                <a href="${pageContext.request.contextPath}/store-manager/recruitment-proposal" class="card-link">Tạo đề xuất mới →</a>
            </div>

            <!-- Tính năng 3: Giám sát ca làm & Chấm công -->
            <div class="card" style="border-left-color: #2ecc71;">
                <div>
                    <h3>Chấm Công & Ca Làm Việc</h3>
                    <p>Theo dõi bảng điểm danh hàng ngày của nhân viên tại cơ sở, kiểm tra giờ giấc và duyệt các đơn từ liên quan đến ca làm.</p>
                </div>
                <a href="${pageContext.request.contextPath}/store-manager/attendance" class="card-link">Xem bảng công →</a>
            </div>

        </div>

    </div>

</body>
</html>