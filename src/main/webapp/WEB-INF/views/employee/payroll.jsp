<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Phiếu lương của tôi</title>
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
                <li><a href="${pageContext.request.contextPath}/employee/attendance"><i class="fa-solid fa-fingerprint"></i> Chấm công trực tuyến</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/employee/payroll"><i class="fa-solid fa-money-bill-wave"></i> Phiếu lương</a></li>
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
                        <h2><i class="fa-solid fa-money-bill-wave me-2"></i>Phiếu lương của tôi</h2>
                        <p>Theo dõi giờ công, phụ cấp, khấu trừ và số tiền thực nhận trong các kỳ đã chốt.</p>
                    </div>
                    <a class="btn btn-light text-success fw-semibold" href="${pageContext.request.contextPath}/employee/dashboard">
                        <i class="fa-solid fa-arrow-left me-1"></i>Quay lại Dashboard
                    </a>
                </div>

                <div class="alert alert-info">
                    <i class="fa-solid fa-circle-info me-2"></i>Các kỳ lương nháp chưa được hiển thị. Nếu có thắc mắc về số liệu, vui lòng liên hệ HR.
                </div>

                <c:forEach items="${payslips}" var="slip">
                    <section class="card p-3 p-lg-4 mb-3">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                            <h2 class="h5 mb-0">Kỳ lương tháng <c:out value="${slip.month}"/>/<c:out value="${slip.year}"/></h2>
                            <span class="badge text-bg-success">Đã chốt</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table mb-0">
                                <tbody>
                                    <tr>
                                        <th>Giờ công hợp lệ</th>
                                        <td class="text-end">
                                            <fmt:formatNumber value="${slip.totalHours}" minFractionDigits="2" maxFractionDigits="2"/> giờ
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Lương cơ bản</th>
                                        <td class="text-end">
                                            <fmt:formatNumber value="${slip.baseSalary}" maxFractionDigits="0"/> đ
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Phụ cấp</th>
                                        <td class="text-end">
                                            <fmt:formatNumber value="${slip.allowances}" maxFractionDigits="0"/> đ
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Khấu trừ</th>
                                        <td class="text-end text-danger">
                                            <fmt:formatNumber value="${slip.deductions}" maxFractionDigits="0"/> đ
                                        </td>
                                    </tr>
                                    <tr class="table-light">
                                        <th>Thực nhận</th>
                                        <td class="text-end fw-bold text-success">
                                            <fmt:formatNumber value="${slip.netSalary}" maxFractionDigits="0"/> đ
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </c:forEach>

                <c:if test="${empty payslips}">
                    <div class="card p-4 text-center text-secondary">
                        Chưa có phiếu lương đã chốt.
                    </div>
                </c:if>
            </main>
        </div>
    </body>
</html>