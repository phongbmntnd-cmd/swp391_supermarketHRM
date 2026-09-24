<%-- 
    Document   : branch-management
    Created on : 24 Sept 2026, 09:18:44
    Author     : nguyn
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản Lý Cơ Sở - Giám Đốc</title>
    <!-- Gắn link CSS Bootstrap của bạn tại đây nếu có -->
    <style>
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .form-section { margin-bottom: 20px; padding: 15px; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <h2>Quản Lý Danh Sách Chi Nhánh</h2>
    <a href="${pageContext.request.contextPath}/director/dashboard">← Trở về Dashboard</a>

    <!-- Tính năng Thêm mới Cơ sở -->
    <div class="form-section">
        <h3>Thêm Cơ Sở Mới</h3>
        <form action="${pageContext.request.contextPath}/director/branch-management" method="POST">
            <input type="hidden" name="action" value="add">
            <label>Mã cơ sở:</label>
            <input type="text" name="code" required placeholder="VD: BR004">
            
            <label>Tên cơ sở:</label>
            <input type="text" name="name" required placeholder="Siêu thị Cơ sở 4">
            
            <label>Địa chỉ:</label>
            <input type="text" name="address" required>
            
            <button type="submit">Thêm Mới</button>
        </form>
    </div>

    <!-- Tính năng Hiển thị danh sách & Các thao tác khác -->
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Mã CS</th>
                <th>Tên Cơ Sở</th>
                <th>Địa Chỉ</th>
                <th>Trạng Thái</th>
                <th>Mã Quản Lý</th>
                <th>Hành Động</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${branchList}" var="b">
                <tr>
                    <td>${b.id}</td>
                    <td>${b.code}</td>
                    <td>${b.name}</td>
                    <td>${b.address}</td>
                    <td>${b.status}</td>
                    <td>
                        <!-- Form Gán Quản Lý trực tiếp trong bảng -->
                        <form action="${pageContext.request.contextPath}/director/branch-management" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="assign">
                            <input type="hidden" name="branchId" value="${b.id}">
                            <input type="number" name="managerId" value="${b.storeManagerId}" placeholder="Nhập ID User" style="width: 100px;" required>
                            <button type="submit">Gán / Đổi QL</button>
                        </form>
                    </td>
                    <td>
                        <!-- Nút Xem danh sách nhân viên -->
                        <a href="${pageContext.request.contextPath}/director/branch-management?action=viewEmployees&id=${b.id}">Xem Nhân Sự</a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</body>
</html>
