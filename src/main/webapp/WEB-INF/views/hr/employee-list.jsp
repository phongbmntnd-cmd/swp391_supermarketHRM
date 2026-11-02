<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<<<<<<< Updated upstream
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý Hồ sơ Nhân sự</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
=======
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Quản lý Hồ sơ Nhân sự - HR Management</title>
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
                <li class="active"><a href="${pageContext.request.contextPath}/hr/employee-list"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Quản lý vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/payroll"><i class="fa-solid fa-money-bill-wave"></i> Tính lương</a></li>
            </ul>
        </aside>
>>>>>>> Stashed changes

<div class="topbar">
    <a class="back-link" href="${pageContext.request.contextPath}/hr/dashboard">&larr; Dashboard</a>
    <h1>Quản lý Hồ sơ Nhân sự</h1>
</div>

<div class="page">

    <div class="page-header">
        <h2>📋 Danh sách nhân sự toàn hệ thống</h2>
        <p>Thêm mới, cập nhật thông tin chi tiết, theo dõi hợp đồng và thông tin liên lạc của nhân viên các cơ sở.</p>
    </div>

    <div class="card">
        <div class="card-header">
            <h3>🔍 Tìm kiếm &amp; lọc</h3>
        </div>
        <div class="card-body" style="border-bottom:1px solid var(--border-light); padding-top:16px; padding-bottom:16px;">
            <form method="get" action="${pageContext.request.contextPath}/hr/employee-management">
                <div class="filter-row">
                    <div class="field">
                        <label for="keyword">🔍 Tìm kiếm</label>
                        <input type="text" id="keyword" name="keyword"
                               placeholder="Tên, username, SĐT, CCCD..." value="${keyword}">
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
                        <label for="departmentId">🏢 Phòng ban</label>
                        <select id="departmentId" name="departmentId">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="d" items="${departments}">
                                <option value="${d.id}" ${departmentId == d.id ? 'selected' : ''}>${d.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="field">
                        <label for="employeeType">👤 Loại nhân viên</label>
                        <select id="employeeType" name="employeeType">
                            <option value="">-- Tất cả --</option>
                            <option value="FULL_TIME" ${employeeType == 'FULL_TIME' ? 'selected' : ''}>Toàn thời gian</option>
                            <option value="PART_TIME" ${employeeType == 'PART_TIME' ? 'selected' : ''}>Bán thời gian</option>
                            <option value="SEASONAL" ${employeeType == 'SEASONAL' ? 'selected' : ''}>Thời vụ</option>
                        </select>
                    </div>
                    <div class="filter-actions">
                        <button type="submit" class="btn btn-primary">🔍 Lọc</button>
                        <a href="${pageContext.request.contextPath}/hr/employee-management" class="btn btn-ghost">🗑️ Xóa lọc</a>
                    </div>
                </div>
            </form>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                <tr>
                    <th>Username</th>
                    <th>Họ tên</th>
                    <th>SĐT</th>
                    <th>CCCD/CMND</th>
                    <th>Chi nhánh</th>
                    <th>Phòng ban</th>
                    <th>Vị trí</th>
                    <th>Loại HĐ</th>
                    <th>Trạng thái TK</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="e" items="${employees}">
                    <tr>
                        <td>${e.username}</td>
                        <td class="clip" title="${e.fullName}">${e.fullName}</td>
                        <td>${e.phone}</td>
                        <td>${e.identityCard}</td>
                        <td class="clip" title="${e.branchName}">${e.branchName}</td>
                        <td class="clip" title="${e.departmentName}">${e.departmentName}</td>
                        <td class="clip" title="${e.positionTitle}">${e.positionTitle}</td>
                        <td>${e.employeeType}</td>
                        <td><span class="badge badge-${e.userStatus}">${e.userStatus}</span></td>
                        <td>
                            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/hr/employee-detail?id=${e.userId}">
                                ✏️ Xem / Sửa
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            <c:if test="${empty employees}">
                <div class="empty-state">
                    <div class="empty-title">Không tìm thấy nhân viên</div>
                    <div>Thử một từ khoá khác hoặc xoá bộ lọc tìm kiếm.</div>
                </div>
            </c:if>
        </div>
    </div>

</div>

</body>
</html>
