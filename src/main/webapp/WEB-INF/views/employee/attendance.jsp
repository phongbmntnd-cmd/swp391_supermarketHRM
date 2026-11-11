<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Chấm công cá nhân</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                margin: 0;
                min-height: 100vh;
                background: #f4f7f6;
                color: #1e293b;
                font-family: Roboto, Arial, sans-serif;
            }
            .sidebar {
                position: fixed;
                inset: 0 auto 0 0;
                width: 285px;
                background: #1e293b;
                color: #94a3b8;
                z-index: 100;
                box-shadow: 2px 0 10px #00000016;
            }
            .sidebar-brand {
                padding: 26px 22px;
                background: #0f172a;
                display: flex;
                align-items: center;
                gap: 12px;
                color: white;
                font-size: 18px;
                font-weight: 700;
            }
            .sidebar-brand i {
                color: #22c55e;
                font-size: 22px;
            }
            .sidebar-menu {
                list-style: none;
                margin: 0;
                padding: 22px 0;
            }
            .sidebar-menu a {
                display: flex;
                align-items: center;
                gap: 15px;
                padding: 14px 26px;
                color: #94a3b8;
                font-size: 14px;
                font-weight: 500;
                text-decoration: none;
                border-left: 4px solid transparent;
            }
            .sidebar-menu a i {
                width: 20px;
                text-align: center;
            }
            .sidebar-menu a:hover, .sidebar-menu .active a {
                color: white;
                background: #ffffff10;
                border-left-color: #22c55e;
            }
            .main-wrapper {
                margin-left: 285px;
                min-width: 0;
                min-height: 100vh;
            }
            .top-navbar {
                position: sticky;
                top: 0;
                z-index: 90;
                background: white;
                padding: 16px 32px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 16px;
                box-shadow: 0 1px 3px #0000000d;
            }
            .top-navbar h1 {
                font-size: 18px;
                font-weight: 500;
                margin: 0;
                color: #334155;
            }
            .user-info {
                display: flex;
                align-items: center;
                gap: 15px;
                font-size: 14px;
            }
            .user-avatar {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                display: grid;
                place-items: center;
                background: #16a34a;
                color: white;
                font-weight: 700;
                font-size: 12px;
            }
            .btn-logout {
                padding: 7px 13px;
                background: #ffeeef;
                color: #ef4444;
                text-decoration: none;
                border-radius: 6px;
                font-weight: 500;
                font-size: 13px;
            }
            .page-content {
                max-width: 1400px;
                margin: 30px auto;
                padding: 0 30px 35px;
            }
            .page-title {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 18px;
                flex-wrap: wrap;
                background: linear-gradient(135deg, #16a34a, #15803d);
                color: white;
                padding: 25px 30px;
                border-radius: 12px;
                margin-bottom: 25px;
                box-shadow: 0 10px 15px -3px #16a34a33;
            }
            .page-title h2 {
                margin: 0 0 8px;
                font-size: 24px;
                font-weight: 700;
            }
            .page-title p {
                margin: 0;
                opacity: .92;
                font-size: 14px;
            }
            .card {
                border: 0;
                border-radius: 12px;
                box-shadow: 0 4px 18px #0f172a0f;
            }
            .card-header {
                background: white;
                font-weight: 700;
                padding: 18px 22px;
            }
            .table th {
                white-space: nowrap;
                color: #475569;
                font-size: 13px;
            }
            .table td {
                vertical-align: middle;
            }
            @media(max-width: 900px) {
                .sidebar {
                    width: 225px;
                }
                .main-wrapper {
                    margin-left: 225px;
                }
                .top-navbar {
                    padding: 14px 20px;
                }
                .page-content {
                    padding: 0 20px;
                }
            }
            @media(max-width: 650px) {
                .sidebar {
                    position: static;
                    width: 100%;
                }
                .sidebar-menu {
                    display: flex;
                    overflow-x: auto;
                    padding: 5px 0;
                }
                .sidebar-menu li {
                    flex: 0 0 auto;
                }
                .sidebar-menu a {
                    padding: 12px;
                    white-space: nowrap;
                }
                .main-wrapper {
                    margin: 0;
                }
                .top-navbar {
                    position: static;
                    flex-wrap: wrap;
                }
                .page-content {
                    padding: 0 15px;
                }
                .page-title {
                    padding: 20px;
                }
            }
        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-id-badge"></i>
                <span>Employee Portal</span>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-house"></i> Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/availability"><i class="fa-solid fa-calendar-plus"></i> Khai báo lịch rảnh</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/my-schedule"><i class="fa-solid fa-calendar-check"></i> Lịch làm việc</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/employee/attendance"><i class="fa-solid fa-fingerprint"></i> Chấm công trực tuyến</a></li>
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
                <div class="user-info">
                    <span class="user-avatar">NV</span>
                    <span>Xin chào, <strong><c:out value="${sessionScope.account.username}"/></strong></span>
                    <a class="btn-logout" href="${pageContext.request.contextPath}/logout">
                        <i class="fa-solid fa-right-from-bracket me-1"></i>Đăng xuất
                    </a>
                </div>
            </header>

            <main class="page-content">
                <div class="page-title">
                    <div>
                        <h2><i class="fa-solid fa-fingerprint me-2"></i>Chấm công cá nhân</h2>
                        <p>Theo dõi ca làm hôm nay, chấm công vào/ra và kiểm tra lịch sử.</p>
                    </div>
                    <a class="btn btn-light text-success fw-semibold" href="${pageContext.request.contextPath}/employee/dashboard">
                        <i class="fa-solid fa-arrow-left me-1"></i>Quay lại Dashboard
                    </a>
                </div>

                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success"><c:out value="${successMessage}"/></div>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger"><c:out value="${errorMessage}"/></div>
                </c:if>

                <!-- Ca làm hôm nay -->
                <section class="card mb-4">
                    <div class="card-header">
                        <i class="fa-regular fa-calendar-check text-success me-2"></i>Ca làm hôm nay — <c:out value="${today}"/>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Ca làm</th>
                                    <th>Giờ dự kiến</th>
                                    <th>Giờ vào</th>
                                    <th>Giờ ra</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${todayShifts}" var="shift">
                                    <tr>
                                        <td><c:out value="${shift.shiftName}"/></td>
                                        <td>
                                            <fmt:formatDate value="${shift.shiftStart}" pattern="HH:mm"/> – 
                                            <fmt:formatDate value="${shift.shiftEnd}" pattern="HH:mm"/>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty shift.checkIn}">
                                                    <fmt:formatDate value="${shift.checkIn}" pattern="HH:mm:ss"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty shift.checkOut}">
                                                    <fmt:formatDate value="${shift.checkOut}" pattern="HH:mm:ss"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${shift.status == 'PENDING'}">
                                                    <span class="badge text-bg-warning">Chờ quản lý duyệt</span>
                                                </c:when>
                                                <c:when test="${shift.status == 'VALID'}">
                                                    <span class="badge text-bg-success">Hợp lệ</span>
                                                </c:when>
                                                <c:when test="${shift.status == 'INVALID'}">
                                                    <span class="badge text-bg-danger">Không hợp lệ</span>
                                                </c:when>
                                                <c:when test="${not empty shift.checkIn}">
                                                    <span class="badge text-bg-info">Đã ghi nhận</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-secondary">Chưa chấm công</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${empty shift.checkIn}">
                                                    <form method="post" action="${pageContext.request.contextPath}/employee/attendance">
                                                        <input type="hidden" name="shiftScheduleId" value="${shift.shiftScheduleId}">
                                                        <button class="btn btn-primary btn-sm" name="action" value="checkIn" type="submit">
                                                            <i class="fa-solid fa-right-to-bracket me-1"></i>Chấm công vào
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${empty shift.checkOut}">
                                                    <form method="post" action="${pageContext.request.contextPath}/employee/attendance">
                                                        <input type="hidden" name="shiftScheduleId" value="${shift.shiftScheduleId}">
                                                        <button class="btn btn-outline-primary btn-sm" name="action" value="checkOut" type="submit">
                                                            <i class="fa-solid fa-right-from-bracket me-1"></i>Chấm công ra
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-success"><i class="fa-solid fa-circle-check me-1"></i>Hoàn tất</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty todayShifts}">
                                    <tr>
                                        <td colspan="6" class="text-center text-secondary py-4">
                                            Bạn chưa có ca làm đã công bố hôm nay nên chưa thể chấm công.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- Lịch sử chấm công -->
                <section class="card">
                    <div class="card-header">
                        <i class="fa-solid fa-clock-rotate-left text-success me-2"></i>Lịch sử chấm công
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Ngày</th>
                                    <th>Ca làm</th>
                                    <th>Giờ vào</th>
                                    <th>Giờ ra</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${recentAttendance}" var="record">
                                    <tr>
                                        <td><fmt:formatDate value="${record.workDate}" pattern="dd/MM/yyyy"/></td>
                                        <td><c:out value="${record.shiftName}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty record.checkIn}">
                                                    <fmt:formatDate value="${record.checkIn}" pattern="HH:mm:ss"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty record.checkOut}">
                                                    <fmt:formatDate value="${record.checkOut}" pattern="HH:mm:ss"/>
                                                </c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${record.status == 'PENDING'}">
                                                    <span class="badge text-bg-warning">Chờ duyệt</span>
                                                </c:when>
                                                <c:when test="${record.status == 'VALID'}">
                                                    <span class="badge text-bg-success">Hợp lệ</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge text-bg-danger">Không hợp lệ</span>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${record.late}">
                                                <span class="badge text-bg-secondary ms-1">Đi trễ</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recentAttendance}">
                                    <tr>
                                        <td colspan="5" class="text-center text-secondary py-4">
                                            Chưa có dữ liệu chấm công trước ngày hôm nay.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </section>
            </main>
        </div>
    </body>
</html>