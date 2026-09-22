<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:07:11
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Employee Dashboard</title>
</head>
<body>
    <h2>Trang Nhân Viên Vận Hành (Employee)</h2>
    <p>Xin chào, <strong>${sessionScope.account.username}</strong>!</p>
    <ul>
        <li>Xem lịch làm việc cá nhân</li>
        <li>Đăng ký Open Shift & khai báo thời gian rảnh</li>
        <li>Chấm công Check-in / Check-out</li>
        <li>Gửi đơn xin nghỉ / đổi ca</li>
    </ul>
</body>
</html>
