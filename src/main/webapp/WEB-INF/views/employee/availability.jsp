<%-- 
    Document   : availability
    Created on : 10 thg 10, 2026, 21:56:50
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng Ký Lịch Làm Việc - Hệ Thống Siêu Thị</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * { box-sizing: border-box; }
            body {
                margin: 0;
                font-family: 'Roboto', sans-serif;
                background: #f4f7f6;
                color: #333;
                min-height: 100vh;
            }
            .sidebar {
                width: 280px;
                position: fixed;
                inset: 0 auto 0 0;
                display: flex;
                flex-direction: column;
                background: #1e293b;
                z-index: 100;
                box-shadow: 2px 0 10px rgba(0,0,0,.08);
            }
            .sidebar-brand {
                background: #0f172a;
                color: #fff;
                padding: 25px 22px;
                display: flex;
                align-items: center;
                gap: 12px;
                font-size: 19px;
                font-weight: 700;
            }
            .sidebar-brand i { color: #22c55e; font-size: 22px; }
            .sidebar-menu { list-style: none; padding: 20px 0; margin: 0; overflow-y: auto; }
            .sidebar-menu a {
                display: flex;
                align-items: center;
                gap: 14px;
                padding: 15px 25px;
                border-left: 4px solid transparent;
                color: #94a3b8;
                font-size: 14px;
                font-weight: 500;
                text-decoration: none;
            }
            .sidebar-menu a i { width: 20px; text-align: center; }
            .sidebar-menu a:hover, .sidebar-menu .active a {
                color: white;
                background: rgba(255,255,255,.06);
                border-left-color: #22c55e;
            }
            .main-wrapper { min-width: 0; min-height: 100vh; margin-left: 280px; }
            .top-navbar {
                background: white;
                color: #334155;
                padding: 18px 32px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 12px;
                box-shadow: 0 1px 3px rgba(0,0,0,.06);
            }
            .top-navbar h1 { font-size: 18px; font-weight: 500; margin: 0; }
            .nav-actions { display: flex; align-items: center; gap: 18px; font-size: 14px; }
            .btn-logout {
                padding: 8px 13px; border-radius: 7px;
                background: #ffeeef; color: #ef4444;
                font-size: 13px; text-decoration: none; font-weight: 500;
            }
            .main-container { max-width: 1400px; margin: 30px auto; padding: 0 30px; }
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
            .btn-back { color: #0369a1; text-decoration: none; font-weight: 500; display: inline-flex; align-items: center; gap: 8px; }
            .btn-back:hover { text-decoration: underline; }
            @media (max-width: 900px) {
                .sidebar { width: 220px; }
                .main-wrapper { margin-left: 220px; }
                .main-container { padding: 0 20px; }
            }
            @media (max-width: 650px) {
                .sidebar { position: static; width: 100%; }
                .sidebar-menu { display: flex; overflow-x: auto; padding: 5px 0; }
                .sidebar-menu li { flex: 0 0 auto; }
                .sidebar-menu a { white-space: nowrap; padding: 12px; }
                .main-wrapper { margin-left: 0; }
                .top-navbar { padding: 15px 20px; }
                .main-container { margin: 20px auto; padding: 0 15px; }
            }
        </style>
    </head>
    <body>
        <!-- Sidebar đồng bộ với Dashboard nhân viên -->
        <aside class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-id-badge"></i>
                <span>Employee Portal</span>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-house"></i> Trang chủ</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/employee/availability"><i class="fa-solid fa-calendar-plus"></i> Khai báo lịch rảnh</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/my-schedule"><i class="fa-solid fa-calendar-check"></i> Lịch làm việc</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/attendance"><i class="fa-solid fa-fingerprint"></i> Chấm công trực tuyến</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/payroll"><i class="fa-solid fa-money-bill-wave"></i> Phiếu lương</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/leave-request"><i class="fa-solid fa-plane-departure"></i> Xin nghỉ phép</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/forms"><i class="fa-solid fa-rotate"></i> Đổi ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/violations"><i class="fa-solid fa-triangle-exclamation"></i> Vi phạm & kết quả</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/profile"><i class="fa-solid fa-address-card"></i>Hồ sơ cá nhân</a></li>
            </ul>
        </aside>

        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Không Gian Nhân Viên</h1>
                <div class="nav-actions">
                    <span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span>
                    <a class="btn-logout" href="${pageContext.request.contextPath}/logout"><i class="fa-solid fa-right-from-bracket me-1"></i> Đăng xuất</a>
                </div>
            </header>

            <main class="main-container">
                <div class="d-flex align-items-center justify-content-between gap-3 flex-wrap mb-4">
                    <div>
                        <h2 class="h4 fw-bold mb-1">Khai báo lịch rảnh</h2>
                        <p class="text-secondary mb-0">Đăng ký các ca có thể làm để quản lý sắp xếp lịch phù hợp.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/employee/dashboard" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-arrow-left me-1"></i> Quay lại Dashboard</a>
                </div>

            <c:if test="${param.success eq 'supplementary'}">
                <div class="alert alert-success"><i class="fa-solid fa-circle-check me-2"></i>Đăng ký ca bổ sung thành công. Quản lý sẽ xem xét và phân công.</div>
            </c:if>
            <c:if test="${param.error eq 'supplementary'}">
                <div class="alert alert-warning"><i class="fa-solid fa-triangle-exclamation me-2"></i>Không thể đăng ký ca này. Có thể hạn đăng ký đã hết, ca bị trùng hoặc bạn đã đăng ký trước đó.</div>
            </c:if>

            <c:if test="${param.error eq 'min_shifts'}">
                <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i> Bạn phải đăng ký tối thiểu <strong>${param.min} ca làm việc</strong> trong tuần!
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${param.success eq 'true'}">
                <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i> Lưu lịch rảnh thành công!
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
                        <h2><i class="fa-regular fa-calendar-days me-2"></i> 
                            <c:choose>
                                <c:when test="${employeeType eq 'FULL_TIME'}">Lịch Làm Việc Chính Thức (Full-time)</c:when>
                                <c:otherwise>Đăng Ký Lịch Rảnh Tuần Tới (Part-time - Hình thức: ${shiftType})</c:otherwise>
                            </c:choose>
                        </h2>
                        <p class="mb-0"><i class="fa-solid fa-clock-rotate-left me-1"></i> Áp dụng cho tuần: <strong>${startDate}</strong> đến <strong>${endDate}</strong></p>
                    </div>
                    <div>
                        <span class="badge bg-light text-primary badge-status">
                            <i class="fa-solid fa-user-shield me-1"></i> ${employeeType eq 'FULL_TIME' ? 'Nhân viên Toàn thời gian' : 'Nhân viên Bán thời gian'}
                        </span>
                    </div>
                </div>

                <div class="table-container">
                    <!-- Thông báo trạng thái thời gian mở/đóng cổng đăng ký -->
                    <div class="alert ${isRegistrationOpen ? 'alert-warning' : 'alert-secondary'} py-2 mb-4 d-flex align-items-center shadow-sm" role="alert">
                        <i class="fa-solid fa-clock fa-lg me-3"></i>
                        <div>
                            <c:choose>
                                <c:when test="${isRegistrationOpen}">
                                    <strong>Trạng thái đăng ký:</strong> Cổng mở từ <strong>Thứ Hai</strong> đến hết <strong>23:59 Thứ Tư</strong> hàng tuần. Bạn có thể thao tác chỉnh sửa lịch rảnh.
                                </c:when>
                                <c:otherwise>
                                    <strong>Trạng thái đăng ký:</strong> Cổng đăng ký lịch rảnh đã <strong>đóng</strong>. Hệ thống đang trong thời gian quản lý sắp xếp lịch trực.
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <c:if test="${not empty supplementaryRegistrations}">
                        <section class="mb-4">
                            <h5><i class="fa-solid fa-user-plus me-2 text-warning"></i>Ca đang mở đăng ký bổ sung</h5>
                            <div class="table-responsive">
                                <table class="table table-bordered align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th>Ngày</th>
                                            <th>Vị trí</th>
                                            <th>Ca</th>
                                            <th>Hạn đăng ký</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="registration" items="${supplementaryRegistrations}">
                                            <tr>
                                                <td><c:out value="${registration.workDate}"/></td>
                                                <td><c:out value="${registration.positionTitle}"/></td>
                                                <td><c:out value="${registration.shiftName}"/> <small class="text-muted">${registration.startTime} - ${registration.endTime}</small></td>
                                                <td><c:out value="${registration.deadline}"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${registration.applied}"><span class="badge bg-success">Đã đăng ký</span></c:when>
                                                        <c:when test="${registration.hasConflict}"><span class="badge bg-secondary">Đã bận / Trùng lịch rảnh</span></c:when>
                                                        <c:otherwise>
                                                            <form action="availability" method="POST" class="m-0">
                                                                <input type="hidden" name="action" value="applySupplementary">
                                                                <input type="hidden" name="registrationId" value="${registration.registrationId}">
                                                                <button type="submit" class="btn btn-sm btn-warning"><i class="fa-solid fa-plus me-1"></i>Đăng ký ca</button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </c:if>

                    <c:choose>
                        <%-- NẾU LÀ FULL-TIME: TUYỆT ĐỐI KHÔNG HIỆN BẢNG ĐĂNG KÝ, CHỈ HIỆN THÔNG BÁO --%>
                        <c:when test="${employeeType eq 'FULL_TIME'}">
                            <div class="alert alert-info py-4 text-center my-3">
                                <i class="fa-solid fa-circle-info fa-2x mb-3 text-primary"></i>
                                <h5>Thông báo dành cho nhân viên Toàn thời gian (Full-time)</h5>
                                <p class="text-muted mb-0">Bạn là nhân viên Full-time (Hình thức ca: <strong>${shiftType}</strong>). Lịch làm việc của bạn được quản lý chi nhánh trực tiếp phân công và sắp xếp trên hệ thống, bạn <strong>không cần</strong> thao tác đăng ký lịch rảnh hàng tuần.</p>
                            </div>
                        </c:when>

                        <%-- NẾU LÀ PART-TIME / CASUAL: MỚI CHO HIỆN BẢNG TÍCH CHỌN LỊCH RẢNH --%>
                        <c:otherwise>
                            <form action="availability" method="POST">
                                <!-- Truyền ẩn mốc tuần chuẩn để lưu trữ dữ liệu theo tuần -->
                                <input type="hidden" name="weekStartDate" value="${weekStartDate}">

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
                                                        <span class="shift-info">${shift.name}</span>
                                                        <span class="shift-time">${shift.startTime} - ${shift.endTime}</span>
                                                    </td>

                                                    <c:forEach var="day" items="${days}">
                                                        <c:set var="isDisabled" value="false" />

                                                        <%-- RÀNG BUỘC KHÓA MỜ THÔNG MINH DỰA TRÊN TÊN CA VÀ SHIFT_TYPE --%>
                                                        <c:if test="${not empty shiftType}">
                                                            <c:choose>
                                                                <c:when test="${shiftType eq 'PT_FIXED_MORNING' and not fn:contains(fn:toLowerCase(shift.name), 'sáng')}">
                                                                    <c:set var="isDisabled" value="true" />
                                                                </c:when>
                                                                <c:when test="${shiftType eq 'PT_FIXED_AFTERNOON' and not fn:contains(fn:toLowerCase(shift.name), 'chiều')}">
                                                                    <c:set var="isDisabled" value="true" />
                                                                </c:when>
                                                                <c:when test="${shiftType eq 'PT_FIXED_EVENING' and not fn:contains(fn:toLowerCase(shift.name), 'tối')}">
                                                                    <c:set var="isDisabled" value="true" />
                                                                </c:when>
                                                            </c:choose>
                                                        </c:if>

                                                        <td class="checkbox-cell ${isDisabled ? 'bg-light opacity-50' : ''}">
                                                            <input class="form-check-input" type="checkbox" name="availabilities" value="${day}_${shift.id}"
                                                                   <c:if test="${isDisabled}">disabled style="pointer-events: none; background-color: #e9ecef;"</c:if>
                                                                   <c:if test="${registeredKeySet.contains(day.concat('_').concat(shift.id))}">checked</c:if>
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
                                    <span class="text-muted small"><i class="fa-solid fa-circle-info me-1"></i> Lưu ý: Bạn cần đăng ký tối thiểu <strong>5 ca/tuần</strong>.</span>
                                    <c:if test="${isRegistrationOpen}">
                                        <button type="submit" class="btn btn-save btn-primary text-white">
                                            <i class="fa-solid fa-floppy-disk me-2"></i> Lưu Đăng Ký Lịch Rảnh
                                        </button>
                                    </c:if>
                                </div>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>