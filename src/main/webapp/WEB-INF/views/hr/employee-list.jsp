<%-- 
    Document   : employee-list
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
                <li><a href="${pageContext.request.contextPath}/hr/attendance-management"><i class="fa-solid fa-clock"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Quản lý vi phạm</a></li>
            </ul>
        </aside>

        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Trị Nhân Sự Toàn Hệ Thống (HR Portal)</h1>
                <div class="user-info">
                    <span>Xin chào, <b><c:out value="${sessionScope.account.username != null ? sessionScope.account.username : 'HR Manager'}"/></b></span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a>
                </div>
            </header>

            <main class="page-content">
                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-address-book me-2"></i>Quản lý Hồ sơ Nhân sự</h2>
                        <p class="mb-0">Thêm mới, cập nhật thông tin chi tiết, theo dõi hợp đồng và thông tin liên lạc của nhân viên các cơ sở.</p>
                    </div>
                    <button class="btn btn-light text-primary fw-semibold shadow-sm px-3 py-2" onclick="history.back()">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </button>
                </div>

                <!-- Form Tìm kiếm & Lọc -->
                <div class="card shadow-sm mb-4">
                    <div class="card-header fw-semibold"><i class="fa-solid fa-filter text-primary me-2"></i>Tìm kiếm & lọc</div>
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/hr/employee-list">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label for="keyword" class="form-label">🔍 Tìm kiếm</label>
                                    <input type="text" id="keyword" name="keyword" class="form-control"
                                           placeholder="Tên, username, SĐT, CCCD..." value="<c:out value='${keyword}'/>">
                                </div>
                                <div class="col-md-2">
                                    <label for="positionId" class="form-label">📌 Vị trí</label>
                                    <select id="positionId" name="positionId" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="p" items="${positions}">
                                            <option value="${p.id}" ${positionId == p.id ? 'selected' : ''}><c:out value="${p.title}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="departmentId" class="form-label">🏢 Phòng ban</label>
                                    <select id="departmentId" name="departmentId" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="d" items="${departments}">
                                            <option value="${d.id}" ${departmentId == d.id ? 'selected' : ''}><c:out value="${d.name}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="employeeType" class="form-label">👤 Loại nhân viên</label>
                                    <select id="employeeType" name="employeeType" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <option value="FULL_TIME" ${employeeType == 'FULL_TIME' ? 'selected' : ''}>Toàn thời gian</option>
                                        <option value="PART_TIME" ${employeeType == 'PART_TIME' ? 'selected' : ''}>Bán thời gian</option>
                                        <option value="SEASONAL" ${employeeType == 'SEASONAL' ? 'selected' : ''}>Thời vụ</option>
                                    </select>
                                </div>
                                <div class="col-md-3 d-flex align-items-end gap-2">
                                    <button type="submit" class="btn btn-primary w-100"><i class="fa-solid fa-magnifying-glass me-1"></i> Lọc</button>
                                    <a href="${pageContext.request.contextPath}/hr/employee-list" class="btn btn-outline-secondary" title="Xóa lọc"><i class="fa-solid fa-rotate-right"></i></a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Bảng Danh sách Nhân sự -->
                <div class="card shadow-sm">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
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
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="e" items="${employees}">
                                    <tr>
                                        <td><c:out value="${e.username}"/></td>
                                        <td class="fw-semibold text-primary"><c:out value="${e.fullName}"/></td>
                                        <td><c:out value="${e.phone}"/></td>
                                        <td><c:out value="${e.identityCard}"/></td>
                                        <td><c:out value="${e.branchName}"/></td>
                                        <td><c:out value="${e.departmentName}"/></td>
                                        <td><c:out value="${e.positionTitle}"/></td>
                                        <td><c:out value="${e.employeeType}"/></td>
                                        <td>
                                            <span class="badge bg-${e.userStatus == 'ACTIVE' ? 'success' : 'secondary'}">
                                                <c:out value="${e.userStatus}"/>
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/hr/employee-detail?id=${e.userId}">
                                                <i class="fa-solid fa-pen-to-square me-1"></i> Xem / Sửa
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <c:if test="${empty employees}">
                        <div class="text-center py-5">
                            <i class="fa-regular fa-folder-open fs-2 mb-2 text-muted"></i>
                            <p class="text-secondary mb-0">Không tìm thấy nhân viên nào. Thử một từ khoá khác hoặc xoá bộ lọc tìm kiếm.</p>
                        </div>
                    </c:if>
                </div>
            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>