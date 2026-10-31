<%-- 
    Document   : recruitment
    Created on : Oct 27, 2026, 10:18:16 PM
    Author     : Lenovo
--%>

<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Phê duyệt đề xuất tiếp nhận nhân sự - HR Management</title>
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
                <li class="active"><a href="${pageContext.request.contextPath}/hr/recruitment"><i class="fa-solid fa-user-plus"></i> Phê duyệt đề xuất</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/transfer-requests"><i class="fa-solid fa-right-left"></i> Phê duyệt điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/employee-management"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/attendance-management"><i class="fa-solid fa-clock"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Quản lý vi phạm</a></li>
            </ul>
        </aside>

        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Trị Nhân Sự Toàn Hệ Thống (HR Portal)</h1>
                <div class="user-info">
                    <span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a>
                </div>
            </header>

            <main class="page-content">
                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-user-plus me-2"></i>Phê duyệt đề xuất tuyển dụng</h2>
                        <p class="mb-0">Xem xét và phê duyệt yêu cầu tuyển dụng do Store Manager các cơ sở gửi lên.</p>
                    </div>
                    <button class="btn btn-light text-primary fw-semibold shadow-sm px-3 py-2" onclick="history.back()">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </button>
                </div>

                <c:if test="${param.msg == 'rejected'}">
                    <div class="alert alert-success">Đã từ chối đề xuất tuyển dụng!</div>
                </c:if>

                <!-- Tabs lọc nhanh -->
                <ul class="nav nav-pills mb-4">
                    <li class="nav-item me-2">
                        <a class="nav-link ${filter == 'pending' ? 'active' : 'bg-white text-dark shadow-sm'}" 
                           href="?filter=pending&branchId=${branchId}&positionId=${positionId}&employmentType=${employmentType}&status=${status}">
                            Đang chờ duyệt
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${filter == 'all' ? 'active' : 'bg-white text-dark shadow-sm'}" 
                           href="?filter=all&branchId=${branchId}&positionId=${positionId}&employmentType=${employmentType}&status=${status}">
                            Tất cả
                        </a>
                    </li>
                </ul>

                <!-- Form Lọc -->
                <div class="card shadow-sm mb-4">
                    <div class="card-header fw-semibold"><i class="fa-solid fa-filter text-primary me-2"></i>Bộ lọc tìm kiếm</div>
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/hr/recruitment">
                            <input type="hidden" name="filter" value="${filter}">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label for="branchId" class="form-label">📍 Chi nhánh</label>
                                    <select id="branchId" name="branchId" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="b" items="${branches}">
                                            <option value="${b.id}" ${branchId == b.id ? 'selected' : ''}>${b.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label for="positionId" class="form-label">📌 Vị trí</label>
                                    <select id="positionId" name="positionId" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="p" items="${positions}">
                                            <option value="${p.id}" ${positionId == p.id ? 'selected' : ''}>${p.title}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="employmentType" class="form-label">🕒 Hình thức</label>
                                    <select id="employmentType" name="employmentType" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <option value="FULL_TIME" ${employmentType == 'FULL_TIME' ? 'selected' : ''}>Toàn thời gian</option>
                                        <option value="PART_TIME" ${employmentType == 'PART_TIME' ? 'selected' : ''}>Bán thời gian</option>
                                        <option value="CASUAL" ${employmentType == 'CASUAL' ? 'selected' : ''}>Thời vụ</option>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="status" class="form-label">📊 Trạng thái</label>
                                    <select id="status" name="status" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>PENDING</option>
                                        <option value="APPROVED" ${status == 'APPROVED' ? 'selected' : ''}>APPROVED</option>
                                        <option value="REJECTED" ${status == 'REJECTED' ? 'selected' : ''}>REJECTED</option>
                                    </select>
                                </div>
                                <div class="col-md-2 d-flex align-items-end gap-2">
                                    <button type="submit" class="btn btn-primary w-100"><i class="fa-solid fa-magnifying-glass me-1"></i> Lọc</button>
                                    <a href="${pageContext.request.contextPath}/hr/recruitment?filter=${filter}" class="btn btn-outline-secondary" title="Xóa lọc"><i class="fa-solid fa-rotate-right"></i></a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Bảng danh sách đề xuất -->
                <div class="card shadow-sm">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Ngày tạo</th>
                                    <th>Chi nhánh</th>
                                    <th>Ứng viên đề xuất</th>
                                    <th>Vị trí</th>
                                    <th>Hình thức</th>
                                    <th>Người đề xuất</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rp" items="${proposals}">
                                    <tr>
                                        <td><fmt:formatDate value="${rp.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td><c:out value="${rp.branchName}"/></td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/hr/recruitment?id=${rp.id}" class="text-decoration-none fw-bold text-primary">
                                                <c:out value="${rp.candidate.fullName}"/>
                                            </a>
                                        </td>
                                        <td><c:out value="${rp.positionTitle}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rp.employmentType == 'FULL_TIME'}">Toàn thời gian</c:when>
                                                <c:when test="${rp.employmentType == 'PART_TIME'}">Bán thời gian</c:when>
                                                <c:when test="${rp.employmentType == 'CASUAL'}">Thời vụ</c:when>
                                                <c:otherwise><c:out value="${rp.employmentType}"/></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${rp.createdByName}"/></td>
                                        <td>
                                            <span class="badge bg-${rp.status == 'APPROVED' ? 'success' : (rp.status == 'REJECTED' ? 'danger' : 'warning text-dark')}">
                                                <c:out value="${rp.status}"/>
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/hr/recruitment?id=${rp.id}">
                                                <i class="fa-solid fa-eye me-1"></i> Chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty proposals}">
                                    <tr>
                                        <td colspan="8" class="text-center text-secondary py-4">
                                            <div class="py-3">
                                                <i class="fa-solid fa-folder-open fs-2 mb-2 text-muted"></i>
                                                <p class="mb-0">Không có đề xuất nào. Thử thay đổi bộ lọc hoặc chuyển sang tab khác.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </main>
        </div>
    </body>
</html>