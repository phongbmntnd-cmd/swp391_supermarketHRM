<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:58:07
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
</head>
<body>
    <h2>Trang Quản Trị Hệ Thống (System Admin)</h2>
    <p>Xin chào, <strong>${sessionScope.account.username}</strong>!</p>
    <ul>
        <li>Quản lý tài khoản toàn hệ thống (CRUD, Lock/Unlock, Reset Password)</li>
        <li>Quản lý Master Data (Phòng ban, Vị trí, Loại nhân sự)</li>
        <li>Xem Audit Log & System Monitoring</li>
    </ul>
</body>
</html>
