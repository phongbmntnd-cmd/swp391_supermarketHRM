<%-- 
    Document   : my-schedule
    Created on : 10 thg 10, 2026, 01:35:43
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Lịch Làm Việc Cá Nhân - Nhân Viên</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f4f7f6;
                color: #333;
            }
            .top-navbar {
                background-color: #2c3e50;
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            }
            .main-container {
                max-width: 1350px;
                margin: 40px auto;
                padding: 0 20px;
            }
            .card-custom {
                background: white;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.05);
                border: none;
                overflow: hidden;
                margin-bottom: 30px;
            }
            .card-header-custom {
                background: linear-gradient(135deg, #27ae60, #2ecc71);
                color: white;
                padding: 20px 30px;
            }
            .card-header-custom h2 {
                font-size: 20px;
                font-weight: 500;
                margin: 0;
            }
            .table > thead > tr > th {
                background-color: #f8f9fa;
                color: #2c3e50;
                font-weight: 600;
                text-transform: uppercase;
                font-size: 12px;
                padding: 12px 8px;
            }
            .table tbody td {
                padding: 15px;
                vertical-align: middle;
            }
            .shift-info {
                font-weight: 600;
                color: #2c3e50;
                font-size: 14px;
            }
            .shift-time {
                font-size: 11px;
                color: #7f8c8d;
                display: block;
                margin-top: 2px;
            }
            .schedule-box {
                background: #e8f8f5;
                border: 2px dashed #27ae60;
                border-radius: 8px;
                padding: 10px;
                color: #1e8449;
                font-weight: 600;
                text-align: center;
            }
            .schedule-empty {
                color: #95a5a6;
                font-style: italic;
                font-size: 13px;
                text-align: center;
            }
        </style>
    </head>
    <body>

        <div class="top-navbar">
            <h1><i class="fa-solid fa-user-clock me-2"></i> Lịch Làm Việc Của Tôi</h1>
            <a href="dashboard" class="text-white text-decoration-none fw-medium"><i class="fa-solid fa-arrow-left me-1"></i> Quay lại Dashboard</a>
        </div>

        <div class="main-container">
            <div class="card card-custom">
                <div class="card-header-custom d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h2><i class="fa-solid fa-calendar-days me-2"></i> Lịch Trực Chính Thức</h2>
                        <p class="mb-0 small mt-1"><i class="fa-solid fa-clock-rotate-left me-1"></i> Áp dụng từ: <strong>${startDate}</strong> đến <strong>${endDate}</strong></p>
                    </div>

                    <div class="d-flex align-items-center gap-3">
                        <%-- Nút điều hướng Tuần trước / Tuần sau cho nhân viên --%>
                        <div class="btn-group" role="group">
                            <a href="my-schedule?startDate=${prevWeekDate}" class="btn btn-outline-light btn-sm px-3">
                                <i class="fa-solid fa-chevron-left me-1"></i> Tuần trước
                            </a>
                            <a href="my-schedule?startDate=${nextWeekDate}" class="btn btn-outline-light btn-sm px-3">
                                Tuần sau <i class="fa-solid fa-chevron-right ms-1"></i>
                            </a>
                        </div>

                        <div>
                            <span class="badge bg-light text-success p-2 fs-6 shadow-sm">
                                <i class="fa-solid fa-store me-1"></i> ${branchName} &nbsp;|&nbsp; <i class="fa-solid fa-briefcase me-1"></i> ${positionTitle}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="p-4">
                    <p class="text-muted mb-4"><i class="fa-solid fa-circle-info me-1"></i> Dưới đây là các ca làm việc đã được Store Manager phê duyệt và công bố chính thức dành riêng cho bạn:</p>

                    <div class="table-responsive">
                        <table class="table table-bordered text-center align-middle">
                            <thead>
                                <tr>
                                    <th style="width: 15%;">Ca Làm Việc</th>
                                        <c:forEach var="dName" items="${dayNames}">
                                        <th>${dName}</th>
                                        </c:forEach>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="shift" items="${shifts}">
                                    <tr>
                                        <td style="text-align: left; padding-left: 15px;">
                                            <span class="shift-info">
                                                <c:choose>
                                                    <c:when test="${shift.name.toLowerCase().contains('sáng')}">
                                                        <i class="fa-solid fa-sun text-warning me-1"></i>
                                                    </c:when>
                                                    <c:when test="${shift.name.toLowerCase().contains('chiều')}">
                                                        <i class="fa-solid fa-cloud-sun text-info me-1"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fa-solid fa-moon text-primary me-1"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                                ${shift.name}
                                            </span>
                                            <span class="shift-time">${shift.startTime} - ${shift.endTime}</span>
                                        </td>

                                        <%-- Duyệt từng ngày trong tuần --%>
                                        <c:forEach var="day" items="${days}">
                                            <td>
                                                <c:set var="cellKey" value="${shift.id}_${dayDateMap[day]}" />
                                                <c:set var="isAssigned" value="false" />

                                                <c:forEach var="asg" items="${mySchedules}">
                                                    <c:if test="${asg eq cellKey}">
                                                        <c:set var="isAssigned" value="true" />
                                                    </c:if>
                                                </c:forEach>
                                                <c:choose>
                                                    <c:when test="${isAssigned}">
                                                        <div class="schedule-box">
                                                            <i class="fa-solid fa-circle-check me-1"></i>
                                                            Trực Ca

                                                            <c:if test="${not empty transferredBranches[cellKey]}">
                                                                (<c:out value="${transferredBranches[cellKey]}"/>)
                                                            </c:if>
                                                        </div>
                                                    </c:when>

                                                    <c:otherwise>
                                                        <div class="schedule-empty">Nghỉ</div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </c:forEach>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>