<%-- 
    Document   : branch-management
    Created on : 24 Sept 2026, 09:18:44
    Author     : nguyn
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Cơ Sở - Giám Đốc</title>
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

            /* Header Bar (Đồng bộ chuẩn màu với Dashboard) */
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
            .btn-back {
                color: #ecf0f1;
                text-decoration: none;
                font-size: 14px;
                background: rgba(255,255,255,0.1);
                padding: 6px 12px;
                border-radius: 4px;
                transition: background 0.2s;
            }
            .btn-back:hover {
                background: rgba(255,255,255,0.2);
            }

            /* Container */
            .container {
                max-width: 1200px;
                margin: 30px auto;
                padding: 0 20px;
            }

            /* Card Section cho Form thêm mới */
            .card-section {
                background: white;
                padding: 25px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
                margin-bottom: 25px;
                border-left: 4px solid #3498db;
            }
            .card-section h3 {
                font-size: 18px;
                color: #2c3e50;
                margin-bottom: 15px;
            }

            .form-inline {
                display: flex;
                flex-wrap: wrap;
                gap: 15px;
                align-items: flex-end;
            }
            .form-group {
                display: flex;
                flex-direction: column;
                gap: 5px;
            }
            .form-group label {
                font-size: 13px;
                font-weight: 500;
                color: #555;
            }
            .form-group input {
                padding: 8px 12px;
                border: 1px solid #ccc;
                border-radius: 4px;
                font-size: 14px;
                width: 220px;
            }

            .btn-submit {
                background-color: #2ecc71;
                color: white;
                border: none;
                padding: 9px 20px;
                border-radius: 4px;
                font-size: 14px;
                font-weight: 500;
                cursor: pointer;
                transition: background 0.2s;
            }
            .btn-submit:hover {
                background-color: #27ae60;
            }

            /* Bảng dữ liệu */
            .table-container {
                background: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
                overflow-x: auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 5px;
            }
            th, td {
                border-bottom: 1px solid #eee;
                padding: 12px 15px;
                text-align: left;
                font-size: 14px;
            }
            th {
                background-color: #f8f9fa;
                color: #2c3e50;
                font-weight: 600;
            }
            tr:hover {
                background-color: #fcfcfc;
            }

            /* Các nút hành động trong bảng */
            .input-group {
                display: flex;
                gap: 5px;
                align-items: center;
            }
            .input-group input {
                width: 65px;
                padding: 5px;
                border: 1px solid #ccc;
                border-radius: 3px;
                text-align: center;
            }

            .btn-action {
                padding: 5px 10px;
                background-color: #f39c12;
                color: white;
                border: none;
                border-radius: 3px;
                cursor: pointer;
                font-size: 13px;
                font-weight: 500;
                transition: background 0.2s;
            }
            .btn-action:hover {
                background-color: #d68910;
            }

            .link-detail {
                color: #3498db;
                text-decoration: none;
                font-weight: 500;
            }
            .link-detail:hover {
                text-decoration: underline;
                color: #2980b9;
            }

            .badge-active {
                background-color: #e8f8f5;
                color: #27ae60;
                padding: 4px 8px;
                border-radius: 4px;
                font-weight: 500;
                font-size: 12px;
            }
            /*nut xoa*/
            .btn-delete {
                padding: 5px 10px;
                background-color: #e74c3c;
                color: white;
                border: none;
                border-radius: 3px;
                cursor: pointer;
                font-size: 13px;
                font-weight: 500;
                transition: background 0.2s;
            }
            .btn-delete:hover {
                background-color: #c0392b;
            }
            .badge-active {
                background-color: #e8f8f5;
                color: #27ae60;
                padding: 4px 8px;
                border-radius: 4px;
                font-weight: 500;
                font-size: 12px;
            }
            .badge-inactive {
                background-color: #ffadad55;
                color: #c0392b;
                padding: 4px 8px;
                border-radius: 4px;
                font-weight: 500;
                font-size: 12px;
            }
        </style>
    </head>
    <body>

        <!-- Thanh Header đồng bộ -->
        <div class="top-navbar">
            <h1>Quản Lý Danh Sách Chi Nhánh</h1>
            <a href="${pageContext.request.contextPath}/director/dashboard" class="btn-back">← Trở về Dashboard</a>
        </div>

        <div class="container">

            <!-- Form Thêm mới cơ sở dạng Card -->
            <div class="card-section">
                <h3>+ Thêm Cơ Sở Mới</h3>
                <form action="${pageContext.request.contextPath}/director/branch-management" method="POST" class="form-inline">
                    <input type="hidden" name="action" value="add">

                    <div class="form-group">
                        <label>Mã cơ sở:</label>
                        <input type="text" name="code" required placeholder="VD: BR004">
                    </div>

                    <div class="form-group">
                        <label>Tên cơ sở:</label>
                        <input type="text" name="name" required placeholder="Siêu thị Cơ sở 4">
                    </div>

                    <div class="form-group" style="flex-grow: 1;">
                        <label>Địa chỉ:</label>
                        <input type="text" name="address" required placeholder="Nhập địa chỉ chi nhánh..." style="width: 100%;">
                    </div>

                    <button type="submit" class="btn-submit">Lưu Cơ Sở</button>
                </form>
            </div>

            <!-- Bảng danh sách cơ sở -->
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Mã CS</th>
                            <th>Tên Cơ Sở</th>
                            <th>Địa Chỉ</th>
                            <th>Trạng Thái</th>
                            <th>Mã Quản Lý</th>
                            <th>Thao Tác Quản Lý</th>
                            <th>Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${branchList}" var="b">
                            <tr>
                                <td>${b.id}</td>
                                <td><b>${b.code}</b></td>
                                <td>${b.name}</td>
                                <td>${b.address}</td>
                                <td>
                                    <span class="${b.status == 'ACTIVE' ? 'badge-active' : 'badge-inactive'}">
                                        ${b.status}
                                    </span>
                                </td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/director/branch-management" method="POST" class="input-group" style="margin: 0;">
                                        <input type="hidden" name="action" value="assign">
                                        <input type="hidden" name="branchId" value="${b.id}">
                                        <input type="number" name="managerId" value="${b.storeManagerId}" required>
                                        <button type="submit" class="btn-action">Gán / Đổi</button>
                                    </form>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/director/branch-management?action=viewEmployees&id=${b.id}" class="link-detail">Xem Nhân Sự</a>
                                </td>
                                <td>
                                    <!-- Nút Xóa cơ sở -->
                                    <form action="${pageContext.request.contextPath}/director/branch-management" method="POST" style="margin: 0;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa/ngừng hoạt động cơ sở này không?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="branchId" value="${b.id}">
                                        <button type="submit" class="btn-delete">Xóa</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

        </div>

    </body>
</html>