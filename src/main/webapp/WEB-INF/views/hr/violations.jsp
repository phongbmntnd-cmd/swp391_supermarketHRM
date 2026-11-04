<%-- 
    Document   : violations
    Created on : Oct 27, 2026, 10:18:16 PM
    Author     : Lenovo
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Xác minh vi phạm - HR Management</title>
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
            .page-title {
                background: linear-gradient(135deg,#0284c7,#0369a1);
                color: #fff;
                padding: 25px 30px;
                border-radius: 12px;
                margin-bottom: 25px;
                box-shadow: 0 10px 15px -3px rgba(2,132,199,.2);
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
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fa-solid fa-user-tie"></i><span>HR Management</span></div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/hr/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/recruitment"><i class="fa-solid fa-user-plus"></i> Phê duyệt đề xuất</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/transfer-requests"><i class="fa-solid fa-right-left"></i> Phê duyệt điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/employee-management"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/attendance-management"><i class="fa-solid fa-clock"></i> Chấm công & Ca làm</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Xác minh vi phạm</a></li>
            </ul>
        </aside>
        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Trị Nhân Sự Toàn Hệ Thống (HR Portal)</h1>
                <div class="user-info"><span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span><a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a></div>
            </header>
            <main class="page-content">
                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-scale-balanced me-2"></i>Xác minh báo cáo vi phạm</h2>
                        <p class="mb-0">HR xem xét thông tin, lưu quyết định và lịch sử xử lý minh bạch.</p>
                    </div>
                    <button class="btn btn-light text-primary fw-semibold shadow-sm px-3 py-2" onclick="history.back()">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </button>
                </div>
                <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
                <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>
                    <div class="alert alert-info"><i class="fa-solid fa-circle-info me-2"></i>Báo cáo chờ xác minh chưa phải kết luận vi phạm; hệ thống không tự động trừ tiền.</div>
                    <h2 class="h5 mb-3">Đang chờ xử lý</h2>
                <c:forEach items="${pendingViolations}" var="v">
                    <article class="card shadow-sm mb-3">
                        <div class="card-header d-flex justify-content-between gap-2 flex-wrap"><strong><c:out value="${v.title}"/></strong><span><c:out value="${v.categoryLabel}"/> · <c:out value="${v.violationDate}"/></span></div>
                        <div class="card-body p-4">
                            <p class="mb-1"><strong>Nhân viên:</strong> <c:out value="${v.employeeName}"/> — <c:out value="${v.branchName}"/></p>
                            <p class="mb-1"><strong>Người báo cáo:</strong> <c:out value="${v.reporterName}"/></p>
                            <p class="mb-2"><strong>Mô tả:</strong> <c:out value="${v.description}"/></p>
                            <c:if test="${not empty v.evidenceUrl}"><p><strong>Bằng chứng:</strong> <a href="<c:out value='${v.evidenceUrl}'/>" target="_blank" rel="noopener noreferrer">Mở liên kết</a></p></c:if>
                                <div class="row g-3">
                                    <div class="col-lg-6"><form method="post" action="${pageContext.request.contextPath}/hr/violations" class="border rounded p-3 h-100"><input type="hidden" name="violationId" value="${v.id}"><input type="hidden" name="action" value="approve"><label class="form-label" for="disciplinary-${v.id}">Kết luận / hình thức xử lý</label><textarea class="form-control mb-2" id="disciplinary-${v.id}" name="disciplinaryAction" rows="3" maxlength="1000" required placeholder="Ghi rõ quyết định xử lý."></textarea><label class="form-label" for="note-approve-${v.id}">Ghi chú cho nhân viên (không bắt buộc)</label><textarea class="form-control mb-3" id="note-approve-${v.id}" name="reviewNote" rows="2" maxlength="1000"></textarea><button class="btn btn-success" type="submit"><i class="fa-solid fa-check me-1"></i>Xác minh và lưu quyết định</button></form></div>
                                <div class="col-lg-6"><form method="post" action="${pageContext.request.contextPath}/hr/violations" class="border rounded p-3 h-100"><input type="hidden" name="violationId" value="${v.id}"><input type="hidden" name="action" value="reject"><label class="form-label" for="note-reject-${v.id}">Lý do từ chối báo cáo</label><textarea class="form-control mb-3" id="note-reject-${v.id}" name="reviewNote" rows="4" maxlength="1000" required></textarea><button class="btn btn-outline-danger" type="submit"><i class="fa-solid fa-xmark me-1"></i>Từ chối báo cáo</button></form></div>
                            </div>
                        </div>
                    </article>
                </c:forEach>
                <c:if test="${empty pendingViolations}"><div class="alert alert-info">Không có báo cáo nào đang chờ HR xác minh.</div></c:if>
                    <details class="card shadow-sm mt-4">
                        <summary class="card-header fw-semibold"><i class="fa-solid fa-clock-rotate-left text-primary me-2"></i>Lịch sử quyết định</summary>
                        <div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th>Ngày xảy ra</th><th>Nhân viên / chi nhánh</th><th>Sự việc</th><th>Trạng thái</th><th>Quyết định / lý do</th><th>Người duyệt</th></tr></thead><tbody><c:forEach items="${reviewedViolations}" var="v"><tr><td><c:out value="${v.violationDate}"/></td><td><c:out value="${v.employeeName}"/> / <c:out value="${v.branchName}"/></td><td><c:out value="${v.categoryLabel}"/> — <c:out value="${v.title}"/></td><td><c:out value="${v.status}"/></td><td><c:out value="${v.disciplinaryAction}"/><c:if test="${not empty v.reviewNote}"><br><small><c:out value="${v.reviewNote}"/></small></c:if></td><td><c:out value="${v.reviewerName}"/></td></tr></c:forEach><c:if test="${empty reviewedViolations}"><tr><td colspan="6" class="text-center text-secondary py-3">Chưa có quyết định trước đây.</td></tr></c:if></tbody></table></div>
                </details>
            </main>
        </div>
    </body>
</html>
