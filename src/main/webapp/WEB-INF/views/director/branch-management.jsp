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
                padding: 5px 10px;
                border-radius: 4px;
                font-weight: 500;
                font-size: 12px;
                cursor: pointer;
                border: none;
            }
            .badge-inactive {
                background-color: #fde8e8;
                color: #c0392b;
                padding: 5px 10px;
                border-radius: 4px;
                font-weight: 500;
                font-size: 12px;
                cursor: pointer;
                border: none;
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

            <!-- Form Thêm mới / Cập nhật Cơ sở dạng Card đồng bộ -->

            <!-- Form tạo yêu cầu mở chi nhánh -->
            <div class="card-section">
                <h3>+ Tạo Yêu Cầu Mở Chi Nhánh Mới</h3>

                <c:if test="${not empty error}">
                    <p style="color: red; margin-bottom: 15px;">
                        <c:out value="${error}" />
                    </p>
                </c:if>

                <c:if test="${param.success == '1'}">
                    <p style="color: green; margin-bottom: 15px;">
                        Gửi yêu cầu mở chi nhánh thành công!
                    </p>
                </c:if>

                <form action="${pageContext.request.contextPath}/director/branch-management"
                      method="POST" class="form-inline">

                    <input type="hidden" name="action" value="createRequest">

                    <div class="form-group">
                        <label>Tên chi nhánh:</label>
                        <input type="text" name="name"
                               placeholder="Siêu thị Cơ sở 4" required>
                    </div>

                    <div class="form-group" style="flex-grow: 1;">
                        <label>Địa chỉ:</label>
                        <input type="text" name="address"
                               placeholder="Nhập địa chỉ chi nhánh..."
                               style="width: 100%;" required>
                    </div>

                    <div class="form-group">
                        <label>Ngày dự kiến khai trương:</label>
                        <input type="date" name="openingDate" required>
                    </div>

                    <div class="form-group" style="flex-grow: 1;">
                        <label>Lý do mở chi nhánh:</label>
                        <input type="text" name="reason"
                               placeholder="Nhập lý do..."
                               style="width: 100%;" required>
                    </div>

                    <button type="submit" class="btn-submit">
                        Gửi Yêu Cầu
                    </button>
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
                            <th>Người Quản Lý</th>
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
                                    <form action="${pageContext.request.contextPath}/director/branch-management" method="POST" style="margin: 0;"
                                          onsubmit="return confirm('${b.status == 'ACTIVE' ? 'Bạn có chắc chắn muốn dừng hoạt động cơ sở này không?' : 'Bạn có muốn kích hoạt lại cơ sở này không?'}');">
                                        <input type="hidden" name="action" value="toggleStatus">
                                        <input type="hidden" name="branchId" value="${b.id}">
                                        <input type="hidden" name="currentStatus" value="${b.status}">

                                        <button type="submit" class="${b.status == 'ACTIVE' ? 'badge-active' : 'badge-inactive'}" style="cursor: pointer; border: none;" title="Nhấn để đổi trạng thái">
                                            ${b.status} 🔄
                                        </button>
                                    </form>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${not empty b.managerName}">
                                            <div class="fw-semibold">
                                                <c:out value="${b.managerName}"/>
                                            </div>

                                            <c:choose>
                                                <c:when test="${b.temporaryManager}">
                                                    <span class="badge bg-info text-dark">
                                                        Quản lý kiêm nhiệm
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-success">
                                                        Quản lý chính
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>

                                        <c:otherwise>
                                            <span class="text-muted">
                                                Chưa phân công
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <a href="${pageContext.request.contextPath}/director/branch-management?action=viewEmployees&id=${b.id}" class="link-detail">Xem Nhân Sự</a>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 5px;">
                                        <!-- Nút Sửa -->
                                        <a href="${pageContext.request.contextPath}/director/branch-management?action=edit&id=${b.id}" class="btn-edit" style="padding: 5px 10px; background-color: #f39c12; color: white; border-radius: 3px; text-decoration: none; font-size: 13px; font-weight: 500;">Sửa</a>

                                        <!-- Nút Xóa -->
                                        <form action="${pageContext.request.contextPath}/director/branch-management" method="POST" style="margin: 0;" onsubmit="return confirm('Bạn có chắc chắn muốn dừng hoạt động cơ sở này không?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="branchId" value="${b.id}">
                                            <button type="submit" class="btn-delete">Xóa</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

        </div>

    </body>
</html>
