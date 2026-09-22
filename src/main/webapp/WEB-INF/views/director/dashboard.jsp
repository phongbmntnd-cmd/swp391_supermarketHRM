<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:05:27
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Director Dashboard</title>
</head>
<body>
    <h2>Trang Giám Đốc Chuỗi (Director)</h2>
    <p>Xin chào, <strong>${sessionScope.account.username}</strong>!</p>
    <ul>
        <li>Xem báo cáo tổng quan toàn chuỗi 3 cơ sở</li>
        <li>Quản lý danh sách chi nhánh</li>
    </ul>
</body>
</html>