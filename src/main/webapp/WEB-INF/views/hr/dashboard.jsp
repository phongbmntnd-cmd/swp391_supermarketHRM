<%-- 
    Document   : dashboard
    Created on : 23 thg 9, 2026, 00:05:59
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>HR Manager Dashboard</title>
</head>
<body>
    <h2>Trang Quản Lý Nhân Sự (HR Manager)</h2>
    <p>Xin chào, <strong>${sessionScope.account.username}</strong>!</p>
    <ul>
        <li>Quản lý hồ sơ nhân viên & hợp đồng</li>
        <li>Duyệt đề xuất tuyển dụng & điều chuyển</li>
        <li>Cấu hình công thức lương & chốt Payroll</li>
    </ul>
</body>
</html>
