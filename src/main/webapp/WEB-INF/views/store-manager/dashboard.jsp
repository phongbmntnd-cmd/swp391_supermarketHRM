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
</head>
<body>
    <h2>Trang Quản Lý Cửa Hàng (Store Manager)</h2>
    <p>Xin chào, <strong>${sessionScope.account.username}</strong>!</p>
    <ul>
        <li>Lập lịch làm việc tuần & Open Shift</li>
        <li>Giám sát điểm danh & chấm công</li>
        <li>Duyệt đơn nghỉ phép / đổi ca tại cơ sở</li>
    </ul>
</body>
</html>
