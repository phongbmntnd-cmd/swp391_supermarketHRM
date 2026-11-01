<%-- 
    Document   : violations
    Created on : Oct 27, 2026, 10:19:16 PM
    Author     : Lenovo
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Báo cáo vi phạm - Store Portal</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                margin: 0;
                font-family: 'Roboto', sans-serif;
                background: #f4f7f6;
                color: #333;
                display: flex;
                min-height: 100vh;
            }
            .sidebar {
                width: 260px;
                background: #1e293b;
                color: #94a3b8;
                display: flex;
                flex-direction: column;
                position: fixed;
                inset: 0 auto 0 0;
                z-index: 100;
                box-shadow: 2px 0 10px rgba(0,0,0,.1);
            }
            .sidebar-brand {
                padding: 25px 20px;
                font-size: 18px;
                font-weight: 700;
                color: #fff;
                background: #0f172a;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .sidebar-brand i {
                color: #38bdf8;
                font-size: 22px;
            }
            .sidebar-menu {
                list-style: none;
                padding: 20px 0;
                margin: 0;
                overflow-y: auto;
            }
            .sidebar-menu a {
                display: flex;
                align-items: center;
                gap: 15px;
                padding: 14px 25px;
                color: #94a3b8;
                text-decoration: none;
                font-size: 14px;
                font-weight: 500;
                border-left: 4px solid transparent;
            }
            .sidebar-menu a:hover, .sidebar-menu .active a {
                color: #fff;
                background: rgba(255,255,255,.05);
                border-left-color: #38bdf8;
            }
            .sidebar-menu i {
                width: 20px;
                text-align: center;
            }
            .main-wrapper {
                margin-left: 260px;
                flex: 1;
                min-width: 0;
                display: flex;
                flex-direction: column;
            }
            .top-navbar {
                background: #fff;
                color: #1e293b;
                padding: 15px 35px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 20px;
                box-shadow: 0 1px 3px rgba(0,0,0,.05);
                position: sticky;
                top: 0;
                z-index: 99;
            }
            .top-navbar h1 {
                margin: 0;
                font-size: 18px;
                font-weight: 500;
                color: #334155;
            }
            .user-info {
                display: flex;
                align-items: center;
                gap: 20px;
                font-size: 14px;
            }
            .btn-logout {
                color: #ef4444;
                text-decoration: none;
                background: #ffeeef;
                padding: 6px 14px;
                border-radius: 6px;
                font-weight: 500;
                font-size: 13px;
                white-space: nowrap;
            }
            .page-content {
                max-width: 1400px;
                margin: 30px;
            }
            .branch-info-bar {
                background-color: #eef2ff;
                border: 1px solid #c7d2fe;
                color: #3730a3;
                padding: 12px 20px;
                border-radius: 8px;
                font-size: 14px;
                margin-bottom: 25px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 500;
            }
            .branch-info-bar i {
                color: #2563eb;
                font-size: 16px;
            }
            .page-title {
                background: linear-gradient(135deg,#2563eb,#1d4ed8);
                color: #fff;
                padding: 25px 30px;
                border-radius: 12px;
                margin-bottom: 25px;
                box-shadow: 0 10px 15px -3px rgba(37,99,235,.2);
            }
            .page-title h2 {
                margin: 0 0 8px;
                font-size: 24px;
            }
            .page-title p {
                margin: 0;
                opacity: .9;
            }
            .card {
                border: 0;
                border-radius: 10px;
            }
            .card-header {
                background: #fff;
                padding: 16px 20px;
            }
            @media (max-width: 900px) {
                .sidebar {
                    width: 220px;
                }
                .main-wrapper {
                    margin-left: 220px;
                }
                .top-navbar {
                    padding: 14px 20px;
                }
                .page-content {
                    margin: 20px;
                }
            }
            @media (max-width: 650px) {
                body {
                    display: block;
                }
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
                }
                .main-wrapper {
                    margin-left: 0;
                }
                .top-navbar {
                    position: static;
                    flex-wrap: wrap;
                }
                .page-content {
                    margin: 15px;
                }
            }
        </style>
    </head>
    <body>
        <!-- Sidebar Điều Hướng Trái (Store Manager) -->
        <aside class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-store"></i>
                <span>Store Manager</span>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/store-manager/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/employees"><i class="fa-solid fa-users-gear"></i> Nhân sự cơ sở</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/recruitment"><i class="fa-solid fa-file-pen"></i> Đề xuất tuyển dụng</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i> Quản lý điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/attendance"><i class="fa-solid fa-clock-rotate-left"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-week"></i> Xếp lịch & Phân ca</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/store-manager/violations"><i class="fa-solid fa-triangle-exclamation"></i> Báo cáo vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/leave-requests"><i class="fa-solid fa-plane-departure"></i> Duyệt nghỉ phép</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/shift-requests"><i class="fa-solid fa-rotate"></i> Duyệt đổi ca</a></li>
            </ul>
        </aside>
        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Chi Nhánh Trực Thuộc</h1>
                <div class="user-info"><span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span><a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a></div>
            </header>
            <main class="page-content">

                <!-- Thanh hiển thị Cơ sở hiện tại -->
                <div class="branch-info-bar">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>Cơ sở hiện tại: <b><c:choose>
                                <c:when test="${not empty currentBranch}">
                                    <c:out value="${currentBranch.name}"/> (<c:out value="${currentBranch.code}"/>) - <c:out value="${currentBranch.address}"/>
                                </c:when>
                                <c:otherwise>Không xác định được cơ sở của bạn</c:otherwise>
                            </c:choose></b></span>
                </div>

                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-triangle-exclamation me-2"></i>Báo cáo vi phạm</h2>
                        <p class="mb-0">Ghi nhận sự việc để HR xác minh trước khi có quyết định xử lý.</p>
                    </div>
                    <button class="btn btn-light text-primary fw-semibold shadow-sm px-3 py-2" onclick="history.back()">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </button>
                </div>
                <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
                <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

                    <section class="card shadow-sm mb-4">
                        <div class="card-header fw-semibold"><i class="fa-solid fa-file-circle-plus text-primary me-2"></i>Ghi nhận sự việc</div>
                        <div class="card-body p-4">
                            <form method="post" action="${pageContext.request.contextPath}/store-manager/violations">
                            <div class="row g-3">
                                <div class="col-md-6"><label class="form-label" for="employeeId">Nhân viên</label><select class="form-select" id="employeeId" name="employeeId" required><option value="">-- Chọn nhân viên trong chi nhánh --</option><c:forEach items="${employees}" var="employee"><option value="${employee.id}"><c:out value="${employee.fullName}"/> (<c:out value="${employee.username}"/>)</option></c:forEach></select></div>
                                    <div class="col-md-6"><label class="form-label" for="category">Loại vi phạm</label><select class="form-select" id="category" name="category" required><option value="ATTENDANCE">Attendance Violation - Chấm công</option><option value="WORKPLACE_CONDUCT">Workplace Conduct - Tác phong</option><option value="WORK_PERFORMANCE">Work Performance - Hiệu suất công việc</option><option value="OPERATIONAL">Operational Violation - Quy trình vận hành</option></select></div>
                                    <div class="col-md-6"><label class="form-label" for="title">Tiêu đề sự việc</label><input class="form-control" id="title" name="title" maxlength="100" required></div>
                                    <div class="col-md-6"><label class="form-label" for="violationDate">Ngày xảy ra</label><input class="form-control" type="date" id="violationDate" name="violationDate" max="${today}" required></div>
                                <div class="col-12"><label class="form-label" for="description">Mô tả và thông tin xác minh ban đầu</label><textarea class="form-control" id="description" name="description" rows="4" maxlength="2000" required></textarea></div>
                                <div class="col-md-6"><label class="form-label" for="deductionAmount">Khoản khấu trừ lương (đồng)</label><input class="form-control" type="number" id="deductionAmount" name="deductionAmount" min="0" max="9999999999.99" step="0.01" value="0" required><div class="form-text">Ghi nhận ngay cùng báo cáo để tổng hợp khi tính lương; nhập 0 nếu không áp dụng khấu trừ.</div></div>
                                <div class="col-md-6"><label class="form-label" for="evidenceUrl">Liên kết bằng chứng (không bắt buộc)</label><input class="form-control" type="url" id="evidenceUrl" name="evidenceUrl" maxlength="255" placeholder="https://..."></div>
                            </div>
                            <div class="alert alert-warning mt-3 mb-3"><i class="fa-solid fa-circle-info me-2"></i>Khoản khấu trừ được lưu ngay khi gửi báo cáo, không chờ HR duyệt. HR xác minh nội dung báo cáo riêng.</div>
                            <button class="btn btn-primary" type="submit"><i class="fa-solid fa-paper-plane me-2"></i>Ghi nhận vi phạm</button>
                        </form>
                    </div>
                </section>

                <section class="card shadow-sm">
                    <div class="card-header fw-semibold"><i class="fa-solid fa-clock-rotate-left text-primary me-2"></i>Báo cáo của chi nhánh</div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light"><tr><th>Ngày xảy ra</th><th>Nhân viên</th><th>Loại / sự việc</th><th>Khấu trừ lương</th><th>Người ghi nhận</th><th>Trạng thái</th><th>Kết quả HR</th></tr></thead>
                            <tbody><c:forEach items="${violations}" var="v"><tr><td><c:out value="${v.violationDate}"/></td><td><c:out value="${v.employeeName}"/></td><td><c:out value="${v.categoryLabel}"/> — <c:out value="${v.title}"/><br><small class="text-secondary"><c:out value="${v.description}"/></small></td><td><c:out value="${v.deductionAmount}"/> đ</td><td><c:out value="${v.reporterName}"/></td><td><c:choose><c:when test="${v.status == 'PENDING_REVIEW'}"><span class="badge text-bg-warning">Chờ HR xác minh</span></c:when><c:when test="${v.status == 'APPROVED'}"><span class="badge text-bg-success">Đã xác minh</span></c:when><c:when test="${v.status == 'REJECTED'}"><span class="badge text-bg-secondary">Đã từ chối</span></c:when><c:otherwise>Dữ liệu lịch sử</c:otherwise></c:choose></td><td><c:out value="${v.disciplinaryAction}"/><c:if test="${not empty v.reviewNote}"><br><small class="text-secondary"><c:out value="${v.reviewNote}"/></small></c:if></td></tr></c:forEach><c:if test="${empty violations}"><tr><td colspan="7" class="text-center text-secondary py-4">Chưa có báo cáo.</td></tr></c:if></tbody>
                        </table>
                    </div>
                </section>
            </main>
        </div>
    </body>
</html>