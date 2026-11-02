<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<<<<<<< Updated upstream
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Phê duyệt đề xuất tuyển dụng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
=======
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
                <li><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Quản lý vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/payroll"><i class="fa-solid fa-money-bill-wave"></i> Tính lương</a></li>
            </ul>
        </aside>
>>>>>>> Stashed changes

<div class="topbar">
    <a class="back-link" href="${pageContext.request.contextPath}/hr/dashboard">&larr; Dashboard</a>
    <h1>Phê duyệt đề xuất tuyển dụng</h1>
</div>

<div class="page">

    <div class="page-header">
        <h2>Đề xuất tuyển dụng từ các chi nhánh</h2>
        <p>Xem xét và phê duyệt yêu cầu tuyển dụng do Store Manager các cơ sở gửi lên.</p>
    </div>

    <c:if test="${param.msg == 'rejected'}"><div class="alert alert-success">Đã từ chối đề xuất tuyển dụng!</div></c:if>

    <div class="tabs">
        <a href="?filter=pending&branchId=${branchId}&positionId=${positionId}&employmentType=${employmentType}&status=${status}"
           class="${filter == 'pending' ? 'active' : ''}">Đang chờ duyệt</a>
        <a href="?filter=all&branchId=${branchId}&positionId=${positionId}&employmentType=${employmentType}&status=${status}"
           class="${filter == 'all' ? 'active' : ''}">Tất cả</a>
    </div>

    <div class="card">
        <div class="card-header"><h3>🔍 Lọc</h3></div>
        <div class="card-body" style="border-bottom:1px solid var(--border-light); padding-top:16px; padding-bottom:16px;">
            <form method="get" action="${pageContext.request.contextPath}/hr/recruitment">
                <input type="hidden" name="filter" value="${filter}">
                <div class="filter-row">
                    <div class="field">
                        <label for="branchId">📍 Chi nhánh</label>
                        <select id="branchId" name="branchId">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="b" items="${branches}">
                                <option value="${b.id}" ${branchId == b.id ? 'selected' : ''}>${b.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="field">
                        <label for="positionId">📌 Vị trí</label>
                        <select id="positionId" name="positionId">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="p" items="${positions}">
                                <option value="${p.id}" ${positionId == p.id ? 'selected' : ''}>${p.title}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="field">
                        <label for="employmentType">🕒 Hình thức</label>
                        <select id="employmentType" name="employmentType">
                            <option value="">-- Tất cả --</option>
                            <option value="FULL_TIME" ${employmentType == 'FULL_TIME' ? 'selected' : ''}>Toàn thời gian</option>
                            <option value="PART_TIME" ${employmentType == 'PART_TIME' ? 'selected' : ''}>Bán thời gian</option>
                            <option value="CASUAL" ${employmentType == 'CASUAL' ? 'selected' : ''}>Thời vụ</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="status">📊 Trạng thái</label>
                        <select id="status" name="status">
                            <option value="">-- Tất cả --</option>
                            <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>PENDING</option>
                            <option value="APPROVED" ${status == 'APPROVED' ? 'selected' : ''}>APPROVED</option>
                            <option value="REJECTED" ${status == 'REJECTED' ? 'selected' : ''}>REJECTED</option>
                        </select>
                    </div>
                    <div class="filter-actions">
                        <button type="submit" class="btn btn-primary">🔍 Lọc</button>
                        <a href="${pageContext.request.contextPath}/hr/recruitment?filter=${filter}" class="btn btn-ghost">🗑️ Xóa lọc</a>
                    </div>
                </div>
            </form>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>Ngày tạo</th>
                    <th>Chi nhánh</th>
                    <th>Ứng viên đề xuất</th>
                    <th>Vị trí</th>
                    <th>Hình thức</th>
                    <th>Người đề xuất</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="rp" items="${proposals}">
                    <tr>
                        <td><fmt:formatDate value="${rp.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                        <td title="${rp.branchName}">${rp.branchName}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/hr/recruitment?id=${rp.id}" style="color:var(--primary); font-weight:bold; text-decoration:none;">
                                ${rp.candidate.fullName}
                            </a>
                        </td>
                        <td title="${rp.positionTitle}">${rp.positionTitle}</td>
                        <td>
                            <c:choose>
                                <c:when test="${rp.employmentType == 'FULL_TIME'}">Toàn thời gian</c:when>
                                <c:when test="${rp.employmentType == 'PART_TIME'}">Bán thời gian</c:when>
                                <c:when test="${rp.employmentType == 'CASUAL'}">Thời vụ</c:when>
                                <c:otherwise>${rp.employmentType}</c:otherwise>
                            </c:choose>
                        </td>
                        <td title="${rp.createdByName}">${rp.createdByName}</td>
                        <td><span class="badge badge-${rp.status}">${rp.status}</span></td>
                        <td>
                            <a class="btn btn-primary" href="${pageContext.request.contextPath}/hr/recruitment?id=${rp.id}">
                                Xem chi tiết
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:if test="${empty proposals}">
                <div class="empty-state">
                    <div class="empty-title">Không có đề xuất nào</div>
                    <div>Thử thay đổi bộ lọc hoặc chuyển sang tab khác.</div>
                </div>
            </c:if>
        </div>
    </div>

</div>

</body>
</html>
