<%-- 
    Document   : branch-employee
    Created on : 24 Sept 2026, 10:16:24
    Author     : nguyn
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Danh Sách Nhân Sự Cơ Sở</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f8f9fa; }
        .container { max-width: 1100px; margin: auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .btn-back { text-decoration: none; color: #fff; background-color: #6c757d; padding: 8px 12px; border-radius: 4px; display: inline-block; margin-bottom: 20px;}
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #dee2e6; padding: 10px; text-align: left; }
        th { background-color: #17a2b8; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Danh Sách Nhân Sự - Cơ Sở ID: ${branchId}</h2>
        <a href="${pageContext.request.contextPath}/director/branch-management" class="btn-back">← Quay lại danh sách chi nhánh</a>

        <table>
            <thead>
                <tr>
                    <th>ID Nhân Viên</th>
                    <th>Họ và Tên</th>
                    <th>Email</th>
                    <th>Số Điện Thoại</th>
                    <th>Vị Trí Công Việc</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${employeeList}" var="emp">
                    <tr>
                        <td>${emp.id}</td>
                        <td><b>${emp.fullName}</b></td>
                        <td>${emp.email}</td>
                        <td>${emp.phone}</td>
                        <td>${emp.positionName}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty employeeList}">
                    <tr>
                        <td colspan="5" style="text-align: center; color: #dc3545; font-weight: bold;">Chưa có nhân sự nào được phân bổ về cơ sở này.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</body>
</html>
