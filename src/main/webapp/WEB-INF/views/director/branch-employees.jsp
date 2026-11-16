<%-- 
    Document   : branch-employee
    Created on : 24 Sept 2026, 10:16:24
    Author     : nguyn
--%>


<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport"
              content="width=device-width, initial-scale=1.0">

        <title>Chi tiết chi nhánh</title>

        <style>
            * {
                box-sizing: border-box;
            }

            body {
                margin: 0;
                padding: 32px 20px;
                background: #f3f6fa;
                font-family: Arial, sans-serif;
                color: #243247;
            }

            .container {
                max-width: 1200px;
                margin: auto;
            }

            .page-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 16px;
                margin-bottom: 24px;
            }

            .page-header h1 {
                margin: 0 0 8px;
                font-size: 27px;
            }

            .subtitle {
                color: #718096;
                font-size: 14px;
            }

            .btn-back {
                display: inline-block;
                text-decoration: none;
                color: #334155;
                background: white;
                border: 1px solid #d7dfe8;
                border-radius: 8px;
                padding: 11px 17px;
                font-size: 14px;
                font-weight: bold;
            }

            .btn-back:hover {
                background: #edf2f7;
            }

            .card {
                background: white;
                border-radius: 12px;
                padding: 24px;
                margin-bottom: 22px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            }

            .card-title {
                font-size: 19px;
                font-weight: bold;
                margin: 0 0 22px;
            }

            .info-grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 24px;
            }

            .info-label {
                color: #718096;
                font-size: 13px;
                margin-bottom: 7px;
            }

            .info-value {
                font-size: 16px;
                font-weight: 600;
                overflow-wrap: anywhere;
            }

            .section-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 12px;
                margin-bottom: 18px;
            }

            .section-header h2 {
                margin: 0;
                font-size: 19px;
            }

            .count {
                background: #e7f0ff;
                color: #2563eb;
                border-radius: 20px;
                padding: 8px 14px;
                font-weight: bold;
                font-size: 13px;
            }

            .table-wrapper {
                overflow-x: auto;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                font-size: 14px;
            }

            th {
                background: #f4f7fb;
                color: #475569;
                font-weight: 600;
                padding: 15px 12px;
                text-align: left;
                border-bottom: 1px solid #dce3eb;
            }

            td {
                padding: 15px 12px;
                border-bottom: 1px solid #edf1f5;
            }

            tbody tr:hover {
                background: #f8fbff;
            }

            .employee-name {
                font-weight: bold;
                color: #1f2937;
            }

            .empty {
                text-align: center;
                color: #64748b;
                padding: 35px 12px;
            }

            @media (max-width: 700px) {
                .page-header {
                    align-items: flex-start;
                }

                .info-grid {
                    grid-template-columns: 1fr;
                }

                .card {
                    padding: 18px;
                }
            }
        </style>
    </head>

    <body>
        <div class="container">

            <div class="page-header">
                <div>
                    <h1>Chi tiết chi nhánh</h1>
                    <div class="subtitle">
                        Thông tin chi nhánh và danh sách nhân sự
                    </div>
                </div>

                <a class="btn-back"
                   href="${pageContext.request.contextPath}/director/branch-management">
                    &larr; Quay lại danh sách chi nhánh
                </a>
            </div>

            <!-- Branch information -->
            <div class="card">
                <h2 class="card-title">Thông tin chi nhánh</h2>

                <div class="info-grid">

                    <div>
                        <div class="info-label">Mã chi nhánh</div>
                        <div class="info-value">
                            <c:out value="${branchDetail.code}"
                                   default="—"/>
                        </div>
                    </div>

                    <div>
                        <div class="info-label">Tên chi nhánh</div>
                        <div class="info-value">
                            <c:out value="${branchDetail.name}"
                                   default="—"/>
                        </div>
                    </div>

                    <div>
                        <div class="info-label">Địa chỉ</div>
                        <div class="info-value">
                            <c:out value="${branchDetail.address}"
                                   default="—"/>
                        </div>
                    </div>

                    <div>
                        <div class="info-label">ID chi nhánh</div>
                        <div class="info-value">
                            <c:out value="${branchId}"/>
                        </div>
                    </div>

                    <div>
                        <div class="info-label">Trạng thái chi nhánh</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${branchDetail.status == 'ACTIVE'}">
                                    Đang hoạt động
                                </c:when>
                                <c:when test="${branchDetail.status == 'INACTIVE'}">
                                    Ngừng hoạt động
                                </c:when>
                                <c:when test="${branchDetail.status == 'PREPARING'}">
                                    Đang chuẩn bị
                                </c:when>
                                <c:otherwise>
                                    <c:out value="${branchDetail.status}" default="—"/>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>


                </div>
            </div>

            <!-- Employee list -->
            <div class="card">

                <div class="section-header">
                    <h2>Danh sách nhân sự</h2>

                    <span class="count">
                        Tổng: ${employeeList.size()} nhân viên
                    </span>
                </div>

                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>STT</th>
                                <th>ID nhân viên</th>
                                <th>Họ và tên</th>
                                <th>Email</th>
                                <th>Số điện thoại</th>
                                <th>Vị trí công việc</th>
                            </tr>
                        </thead>

                        <tbody>
                            <c:forEach var="emp"
                                       items="${employeeList}"
                                       varStatus="loop">
                                <tr>
                                    <td>${loop.count}</td>
                                    <td><c:out value="${emp.id}"/></td>

                                    <td class="employee-name">
                                        <c:out value="${emp.fullName}"/>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty emp.email}">
                                                <c:out value="${emp.email}"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty emp.phone}">
                                                <c:out value="${emp.phone}"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <c:out value="${emp.positionName}"
                                               default="—"/>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty employeeList}">
                                <tr>
                                    <td colspan="6" class="empty">
                                        Chưa có nhân viên nào tại chi nhánh này.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>

                    </table>
                </div>
            </div>

        </div>
    </body>
</html>
