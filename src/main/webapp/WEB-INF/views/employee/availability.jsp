<%-- 
    Document   : availability
    Created on : 10 thg 10, 2026, 21:56:50
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Đăng Ký Lịch Rảnh - Hệ Thống Siêu Thị</title>
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
            .top-navbar h1 {
                font-size: 20px;
                font-weight: 500;
                margin: 0;
            }
            .main-container {
                max-width: 1200px;
                margin: 40px auto;
                padding: 0 20px;
            }
            .card-custom {
                background: white;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.05);
                border: none;
                overflow: hidden;
            }
            .card-header-custom {
                background: linear-gradient(135deg, #27ae60, #2ecc71);
                color: white;
                padding: 25px 30px;
            }
            .card-header-custom h2 {
                font-size: 22px;
                font-weight: 500;
                margin: 0 0 8px 0;
            }
            .badge-status {
                font-size: 13px;
                padding: 6px 12px;
                border-radius: 20px;
                font-weight: 500;
            }
            .table-container {
                padding: 25px;
            }
            .table > thead > tr > th {
                background-color: #f8f9fa;
                color: #2c3e50;
                font-weight: 600;
                text-transform: uppercase;
                font-size: 13px;
                padding: 15px 10px;
                border-bottom: 2px solid #e9ecef;
            }
            .table tbody td {
                padding: 18px 10px;
                vertical-align: middle;
            }
            .shift-info {
                font-weight: 600;
                color: #2c3e50;
            }
            .shift-time {
                font-size: 12px;
                color: #7f8c8d;
                display: block;
                margin-top: 3px;
            }
            .form-check-input {
                width: 22px;
                height: 22px;
                cursor: pointer;
                border: 2px solid #cbd5e1;
            }
            .form-check-input:checked {
                background-color: #27ae60;
                border-color: #27ae60;
            }
            .checkbox-cell {
                text-align: center;
            }
            .btn-save {
                background-color: #27ae60;
                border: none;
                padding: 12px 30px;
                font-weight: 500;
                border-radius: 6px;
            }
            .btn-save:hover {
                background-color: #219653;
            }
            .btn-back {
                color: white;
                text-decoration: none;
                font-weight: 500;
                display: inline-flex;
                align-items: center;
                gap: 8px;
            }
        </style>
    </head>
    <body>

        <!-- Top Header -->
        <div class="top-navbar">
            <h1><i class="fa-solid fa-store me-2"></i> Hệ Thống Quản Lý Siêu Thị - Nhân Viên</h1>
            <a href="dashboard" class="btn-back"><i class="fa-solid fa-arrow-left"></i> Quay lại Dashboard</a>
        </div>

        <div class="main-container">

            <c:if test="${param.success eq 'true'}">
                <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i> Lưu lịch rảnh thành công! Hệ thống đã cập nhật trạng thái của bạn.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.error eq 'closed'}">
                <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i> Đã hết thời gian đăng ký lịch rảnh (Hạn chót: 23:59 Thứ Bảy hàng tuần).
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <%
                String[] days = {"MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"};
                String[] dayNames = {"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"};
                pageContext.setAttribute("days", days);
                pageContext.setAttribute("dayNames", dayNames);
            %>

            <div class="card card-custom">
                <div class="card-header-custom d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h2><i class="fa-regular fa-calendar-days me-2"></i> Đăng Ký Lịch Rảnh Tuần Tới</h2>
                        <p class="mb-0"><i class="fa-solid fa-clock-rotate-left me-1"></i> Áp dụng cho tuần từ: <strong>${startDate}</strong> đến <strong>${endDate}</strong> &nbsp;|&nbsp; <span class="text-warning fw-bold">Hạn chót đăng ký: 23:59 Thứ Bảy</span></p>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${hasRegistered}">
                                <span class="badge bg-light text-success badge-status"><i class="fa-solid fa-circle-check me-1"></i> Đã đăng ký (Chờ quản lý xếp lịch)</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-warning text-dark badge-status"><i class="fa-solid fa-clock me-1"></i> Chưa đăng ký lịch rảnh</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="table-container">
                    <form action="availability" method="POST">
                        <div class="table-responsive">
                            <table class="table table-bordered text-center align-middle mb-4">
                                <thead>
                                    <tr>
                                        <th style="width: 22%; text-align: left; padding-left: 20px;">Ca Làm Việc</th>
                                        <c:forEach var="dName" items="${dayNames}">
                                            <th>${dName}</th>
                                        </c:forEach>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="shift" items="${shifts}">
                                        <tr>
                                            <td style="text-align: left; padding-left: 20px;">
                                                <span class="shift-info">
                                                    <c:choose>
                                                        <c:when test="${shift.name.toLowerCase().contains('sáng')}">
                                                            <i class="fa-solid fa-sun text-warning me-2"></i>
                                                        </c:when>
                                                        <c:when test="${shift.name.toLowerCase().contains('chiều')}">
                                                            <i class="fa-solid fa-cloud-sun text-info me-2"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fa-solid fa-moon text-primary me-2"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    ${shift.name}
                                                </span>
                                                <span class="shift-time">${shift.startTime} - ${shift.endTime}</span>
                                            </td>
                                            <c:forEach var="day" items="${days}">
                                                <td class="checkbox-cell">
                                                    <input class="form-check-input" type="checkbox" name="availabilities" value="${day}_${shift.id}"
                                                           <c:forEach var="ca" items="${currentAvailabilities}">
                                                               <c:if test="${ca.dayOfWeek eq day and ca.shiftId eq shift.id}">checked</c:if>
                                                           </c:forEach>
                                                           <c:if test="${!isRegistrationOpen}">disabled</c:if>
                                                           >
                                                </td>
                                            </c:forEach>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <span class="text-muted small"><i class="fa-solid fa-circle-info me-1"></i> Bạn có thể thay đổi lịch rảnh bất cứ lúc nào trước khi hết hạn deadline.</span>
                            <c:if test="${isRegistrationOpen}">
                                <button type="submit" class="btn btn-save btn-primary text-white">
                                    <i class="fa-solid fa-floppy-disk me-2"></i> Lưu Đăng Ký Lịch Rảnh
                                </button>
                            </c:if>
                        </div>
                    </form>
                </div>
            </div>

        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>