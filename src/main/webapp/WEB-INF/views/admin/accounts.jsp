<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="ctx" content="${pageContext.request.contextPath}">
    <title>Quản lý Tài khoản - Admin</title>
    <style>
        * {
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        body {
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
            margin-top: 0;
        }

        /* Messages */
        .alert {
            padding: 12px 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* Filter Section */
        .filter-section {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            align-items: flex-end;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        .filter-group label {
            font-size: 12px;
            color: #666;
            font-weight: bold;
        }
        .filter-group input,
        .filter-group select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            min-width: 150px;
        }
        .filter-group input:focus,
        .filter-group select:focus {
            outline: none;
            border-color: #3498db;
        }
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        .btn-primary {
            background-color: #3498db;
            color: white;
        }
        .btn-primary:hover {
            background-color: #2980b9;
        }
        .btn-secondary {
            background-color: #95a5a6;
            color: white;
        }
        .btn-secondary:hover {
            background-color: #7f8c8d;
        }
        .btn-sm {
            padding: 5px 10px;
            font-size: 12px;
        }

        /* Table */
        .table-container {
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f8f9fa;
            font-weight: bold;
            color: #333;
            white-space: nowrap;
        }
        th a {
            color: #333;
            text-decoration: none;
        }
        th a:hover {
            color: #3498db;
        }
        th a.active {
            color: #3498db;
        }
        th a.active::after {
            content: " \25B2";
            font-size: 10px;
        }
        th a.active.desc::after {
            content: " \25BC";
        }
        tbody tr:hover {
            background-color: #f8f9fa;
        }

        /* Status Badges */
        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        .status-locked {
            background-color: #f8d7da;
            color: #721c24;
        }
        .status-inactive {
            background-color: #e2e3e5;
            color: #383d41;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }
        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }
        .btn-danger:hover {
            background-color: #c0392b;
        }
        .btn-success {
            background-color: #27ae60;
            color: white;
        }
        .btn-success:hover {
            background-color: #229954;
        }
        .btn-warning {
            background-color: #f39c12;
            color: white;
        }
        .btn-warning:hover {
            background-color: #d68910;
        }

        /* Pagination */
        .pagination-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #ddd;
        }
        .pagination-info {
            color: #666;
            font-size: 14px;
        }
        .pagination-controls {
            display: flex;
            gap: 5px;
            align-items: center;
        }
        .pagination-controls a,
        .pagination-controls span {
            padding: 6px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-decoration: none;
            color: #333;
            font-size: 14px;
        }
        .pagination-controls a:hover {
            background-color: #3498db;
            color: white;
            border-color: #3498db;
        }
        .pagination-controls .current {
            background-color: #3498db;
            color: white;
            border-color: #3498db;
        }
        .pagination-controls .disabled {
            color: #ccc;
            pointer-events: none;
        }
        .page-size-form {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .page-size-form select {
            padding: 6px 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        /* =============================================
           LOCKED ACCOUNTS SECTION
           ============================================= */
        .locked-section {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 2px dashed #e0e0e0;
        }
        .locked-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
        }
        .locked-section h2 {
            color: #c0392b;
            margin-bottom: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .locked-section h2 .count {
            background: #e74c3c;
            color: white;
            padding: 2px 10px;
            border-radius: 12px;
            font-size: 14px;
        }
        .locked-filter {
            background: #fff5f5;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 15px;
            display: flex;
            gap: 12px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        .locked-filter-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 180px;
            flex: 1;
        }
        .locked-filter-group label {
            font-size: 12px;
            color: #c0392b;
            font-weight: bold;
        }
        .locked-filter-group input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            width: 100%;
        }
        .locked-filter-group input:focus {
            outline: none;
            border-color: #e74c3c;
        }
        .locked-filter-buttons {
            display: flex;
            gap: 6px;
            align-items: flex-end;
        }
        .table-locked {
            width: 100%;
            border-collapse: collapse;
        }
        .table-locked th {
            background-color: #ffe6e6;
            color: #c0392b;
        }
        .table-locked td {
            padding: 10px 12px;
            border-bottom: 1px solid #ffcccc;
        }
        .table-locked tr:hover {
            background-color: #fff5f5;
        }
        .reason-cell {
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .reason-cell:hover {
            overflow: visible;
            white-space: normal;
            word-wrap: break-word;
        }
        .locked-pagination {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid #ffcccc;
        }
        .locked-pagination a,
        .locked-pagination span {
            padding: 4px 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-decoration: none;
            color: #333;
            font-size: 13px;
        }
        .locked-pagination a:hover {
            background-color: #27ae60;
            color: white;
            border-color: #27ae60;
        }
        .empty-locked {
            text-align: center;
            padding: 30px;
            color: #888;
            background: #fff5f5;
            border-radius: 4px;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 50px;
            color: #666;
        }
        .empty-state h3 {
            color: #999;
        }

        /* Confirmation Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            z-index: 1000;
        }
        .modal-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 30px;
            border-radius: 8px;
            max-width: 500px;
            width: 90%;
        }
        .modal h3 {
            margin-top: 0;
            color: #333;
        }
        .modal-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }
        .modal textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            resize: vertical;
            min-height: 80px;
            font-family: inherit;
        }
        .modal label {
            font-weight: bold;
            margin-bottom: 5px;
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Navigation Breadcrumb -->
        <div style="margin-bottom: 15px;">
            <a href="${pageContext.request.contextPath}/admin/dashboard" style="color: #3498db; text-decoration: none;">&larr; Quay về Dashboard</a>
        </div>

        <h1>&#128203; Quản lý Tài khoản Toàn hệ thống</h1>

        <!-- Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">
                &#9989; ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                &#10060; ${errorMessage}
            </div>
        </c:if>

        <!-- Filter Section -->
        <div class="filter-section">
            <form method="GET" action="${pageContext.request.contextPath}/admin/accounts" id="filterForm">
                <div class="filter-row">
                    <div class="filter-group">
                        <label for="search">&#128269; Tìm kiếm</label>
                        <input type="text" id="search" name="search" placeholder="Họ tên, username, email, SĐT..."
                               value="${search}">
                    </div>
                    <div class="filter-group">
                        <label for="roleId">&#128100; Vai trò</label>
                        <select id="roleId" name="roleId">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="role" items="${roles}">
                                <option value="${role.id}" ${roleId == role.id ? 'selected' : ''}>${role.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="branchId">&#127970; Chi nhánh</label>
                        <select id="branchId" name="branchId">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="branch" items="${branches}">
                                <option value="${branch.id}" ${branchId == branch.id ? 'selected' : ''}>${branch.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="status">&#128202; Trạng thái</label>
                        <select id="status" name="status">
                            <option value="">-- Tất cả --</option>
                            <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                            <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                            <option value="EMERGENCY_LOCKED" ${status == 'EMERGENCY_LOCKED' ? 'selected' : ''}>EMERGENCY_LOCKED</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>&nbsp;</label>
                        <div style="display: flex; gap: 5px;">
                            <button type="submit" class="btn btn-primary">&#128269; Lọc</button>
                            <a href="${pageContext.request.contextPath}/admin/accounts" class="btn btn-secondary">&#128465; Xóa lọc</a>
                        </div>
                    </div>
                </div>
                <input type="hidden" name="sort" value="${sortColumn}">
                <input type="hidden" name="dir" value="${sortDirection}">
            </form>
        </div>

        <!-- Account Table -->
        <div class="table-container">
            <c:choose>
                <c:when test="${not empty users}">
                    <table>
                        <thead>
                            <tr>
                                <th>STT</th>
                                <th>
                                    <a href="?search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=username&dir=${usernameDir}&page=1&size=${pageSize}">
                                        Username <c:if test="${isUsernameSort}">${sortDirection == 'DESC' ? '&#9660;' : '&#9650;'}</c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="?search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=full_name&dir=${fullNameDir}&page=1&size=${pageSize}">
                                        Họ và tên <c:if test="${isFullNameSort}">${sortDirection == 'DESC' ? '&#9660;' : '&#9650;'}</c:if>
                                    </a>
                                </th>
                                <th>Email</th>
                                <th>Số điện thoại</th>
                                <th>Vai trò</th>
                                <th>Chi nhánh</th>
                                <th>
                                    <a href="?search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=status&dir=${statusDir}&page=1&size=${pageSize}">
                                        Trạng thái <c:if test="${isStatusSort}">${sortDirection == 'DESC' ? '&#9660;' : '&#9650;'}</c:if>
                                    </a>
                                </th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${users}" varStatus="loop">
                                <tr>
                                    <td>${(currentPage - 1) * pageSize + loop.index + 1}</td>
                                    <td><strong>${u.username}</strong></td>
                                    <td>${u.fullName != null ? u.fullName : '<em style="color:#999;">(chưa cập nhật)</em>'}</td>
                                    <td>${u.email}</td>
                                    <td>${u.phone}</td>
                                    <td>
                                        <span class="status-badge status-active" style="background-color:#e8f4fc;color:#2980b9;">${u.role.name}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty u.branchName}">${u.branchName}</c:when>
                                            <c:otherwise><em style="color:#999;">--</em></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.status == 'ACTIVE'}">
                                                <span class="status-badge status-active">ACTIVE</span>
                                            </c:when>
                                            <c:when test="${u.status == 'INACTIVE'}">
                                                <span class="status-badge status-inactive">INACTIVE</span>
                                            </c:when>
                                            <c:when test="${u.status == 'EMERGENCY_LOCKED'}">
                                                <span class="status-badge status-locked">EMERGENCY_LOCKED</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge status-inactive">${u.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <c:choose>
                                                <c:when test="${u.status == 'ACTIVE'}">
                                                    <button type="button" class="btn btn-danger btn-sm lock-btn"
                                                            data-userid="${u.id}"
                                                            data-name="${fn:escapeXml(u.fullName != null ? u.fullName : u.username)}">
                                                        &#128274; Khóa
                                                    </button>
                                                </c:when>
                                                <c:when test="${u.status == 'EMERGENCY_LOCKED'}">
                                                    <button type="button" class="btn btn-success btn-sm unlock-btn"
                                                            data-userid="${u.id}"
                                                            data-name="${fn:escapeXml(u.fullName != null ? u.fullName : u.username)}">
                                                        &#128275; Mở khóa
                                                    </button>
                                                </c:when>
                                            </c:choose>
                                            <button type="button" class="btn btn-warning btn-sm reset-pw-btn"
                                                    data-userid="${u.id}"
                                                    data-name="${fn:escapeXml(u.fullName != null ? u.fullName : u.username)}">
                                                &#128273; Reset MK
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <h3>&#128269; Không tìm thấy tài khoản nào</h3>
                        <p>Vui lòng thay đổi điều kiện lọc hoặc thêm tài khoản mới.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Pagination -->
        <c:if test="${not empty users}">
            <div class="pagination-container">
                <div class="pagination-info">
                    Hiển thị <strong>${(currentPage - 1) * pageSize + 1}</strong> -
                    <strong>${displayEnd}</strong>
                    trong <strong>${totalRecords}</strong> tài khoản
                </div>

                <div class="pagination-controls">
                    <form method="GET" class="page-size-form" id="pageSizeForm">
                        <span>Hiển thị:</span>
                        <select name="size" onchange="document.getElementById('pageSizeForm').submit()">
                            <c:forEach var="ps" items="${pageSizes}">
                                <option value="${ps}" ${pageSize == ps ? 'selected' : ''}>${ps}</option>
                            </c:forEach>
                        </select>
                        <input type="hidden" name="search" value="${search}">
                        <input type="hidden" name="roleId" value="${roleId}">
                        <input type="hidden" name="branchId" value="${branchId}">
                        <input type="hidden" name="status" value="${status}">
                        <input type="hidden" name="sort" value="${sortColumn}">
                        <input type="hidden" name="dir" value="${sortDirection}">
                    </form>

                    <c:if test="${currentPage > 1}">
                        <a href="?page=1&size=${pageSize}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">&laquo;</a>
                        <a href="?page=${currentPage - 1}&size=${pageSize}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">&lsaquo;</a>
                    </c:if>

                    <c:forEach var="i" begin="${pagerStart}" end="${pagerEnd}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="current">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="?page=${i}&size=${pageSize}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <c:if test="${currentPage < totalPages}">
                        <a href="?page=${currentPage + 1}&size=${pageSize}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">&rsaquo;</a>
                        <a href="?page=${totalPages}&size=${pageSize}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">&raquo;</a>
                    </c:if>
                </div>
            </div>
        </c:if>

        <!-- =============================================
             PHẦN TÀI KHOẢN BỊ KHÓA - LUÔN HIỂN THỊ KHI CÓ
             ============================================= -->
        <div class="locked-section" id="lockedAccountsSection" style="display: none;">
            <div class="locked-header" onclick="toggleLockedSection()" style="cursor: pointer; user-select: none;">
                <h2>&#128274; Tài khoản đã bị khóa <span class="count" id="lockedCount">0</span></h2>
                <span id="toggleIcon" style="font-size: 24px;">&#9660;</span>
            </div>

            <div id="lockedContent">

            <form method="GET" action="${pageContext.request.contextPath}/admin/accounts" class="locked-filter">
                <div class="locked-filter-group">
                    <label>&#128269; Tìm tài khoản</label>
                    <input type="text" name="lockedSearch" placeholder="Tên, username, email, SĐT..." value="${lockedSearch}">
                </div>
                <div class="locked-filter-group">
                    <label>&#128221; Lý do khóa</label>
                    <input type="text" name="lockedReasonSearch" placeholder="Nhập từ khóa trong lý do..." value="${lockedReasonSearch}">
                </div>
                <div class="locked-filter-group">
                    <label>&#128119; Người khóa</label>
                    <input type="text" name="lockedBySearch" placeholder="Tên người đã khóa..." value="${lockedBySearch}">
                </div>
                <input type="hidden" name="search" value="${search}">
                <input type="hidden" name="roleId" value="${roleId}">
                <input type="hidden" name="branchId" value="${branchId}">
                <input type="hidden" name="status" value="${status}">
                <input type="hidden" name="sort" value="${sortColumn}">
                <input type="hidden" name="dir" value="${sortDirection}">
                <input type="hidden" name="page" value="${currentPage}">
                <input type="hidden" name="size" value="${pageSize}">
                <div class="locked-filter-buttons">
                    <button type="submit" class="btn btn-primary">&#128270; Lọc</button>
                    <a href="${pageContext.request.contextPath}/admin/accounts#lockedAccountsSection" class="btn btn-secondary">&#128465; Xóa lọc</a>
                </div>
            </form>

            <c:choose>
                <c:when test="${not empty lockedAccounts}">
                    <table class="table-locked">
                        <thead>
                            <tr>
                                <th>STT</th>
                                <th>Username</th>
                                <th>Họ tên</th>
                                <th>Email</th>
                                <th>SĐT</th>
                                <th>Vai trò</th>
                                <th>Chi nhánh</th>
                                <th>Người khóa</th>
                                <th>Thời gian bị khóa</th>
                                <th>Lý do</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="lock" items="${lockedAccounts}" varStatus="loop">
                                <tr>
                                    <td>${(currentLockedPage - 1) * lockedPageSize + loop.index + 1}</td>
                                    <td><strong>${lock.username}</strong></td>
                                    <td>${lock.userName}</td>
                                    <td>${lock.email}</td>
                                    <td>${lock.phone}</td>
                                    <td>${lock.roleName}</td>
                                    <td>${lock.branchName}</td>
                                    <td>${lock.lockedByName}</td>
                                    <td><fmt:formatDate value="${lock.lockedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    <td class="reason-cell" title="${lock.reason}">
                                        <c:choose>
                                            <c:when test="${not empty lock.reason}">${lock.reason}</c:when>
                                            <c:otherwise><em style="color: #999;">Không có</em></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <button type="button" class="btn btn-success btn-sm unlock-btn"
                                                    data-userid="${lock.userId}"
                                                    data-name="${fn:escapeXml(lock.userName != null ? lock.userName : lock.username)}">
                                                &#128275; Mở khóa
                                            </button>
                                            <button type="button" class="btn btn-warning btn-sm reset-pw-btn"
                                                    data-userid="${lock.userId}"
                                                    data-name="${fn:escapeXml(lock.userName != null ? lock.userName : lock.username)}">
                                                &#128273; Reset MK
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <c:if test="${totalLockedPages > 1}">
                        <div class="locked-pagination">
                            <span style="color: #666; font-size: 13px;">
                                Trang ${currentLockedPage}/${totalLockedPages} (${totalLockedRecords} tài khoản bị khóa)
                            </span>
                            <div style="display: flex; gap: 5px;">
                                <c:if test="${currentLockedPage > 1}">
                                    <a href="?lockedPage=1&lockedSearch=${lockedSearch}&lockedReasonSearch=${lockedReasonSearch}&lockedBySearch=${lockedBySearch}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}#lockedAccountsSection">&laquo;</a>
                                    <a href="?lockedPage=${currentLockedPage - 1}&lockedSearch=${lockedSearch}&lockedReasonSearch=${lockedReasonSearch}&lockedBySearch=${lockedBySearch}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}#lockedAccountsSection">&lsaquo;</a>
                                </c:if>

                                <c:forEach var="i" begin="${lockedPagerStart}" end="${lockedPagerEnd}">
                                    <c:choose>
                                        <c:when test="${i == currentLockedPage}">
                                            <span style="background: #e74c3c; color: white;">${i}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="?lockedPage=${i}&lockedSearch=${lockedSearch}&lockedReasonSearch=${lockedReasonSearch}&lockedBySearch=${lockedBySearch}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}#lockedAccountsSection">${i}</a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>

                                <c:if test="${currentLockedPage < totalLockedPages}">
                                    <a href="?lockedPage=${currentLockedPage + 1}&lockedSearch=${lockedSearch}&lockedReasonSearch=${lockedReasonSearch}&lockedBySearch=${lockedBySearch}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}#lockedAccountsSection">&rsaquo;</a>
                                    <a href="?lockedPage=${totalLockedPages}&lockedSearch=${lockedSearch}&lockedReasonSearch=${lockedReasonSearch}&lockedBySearch=${lockedBySearch}&search=${search}&roleId=${roleId}&branchId=${branchId}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}#lockedAccountsSection">&raquo;</a>
                                </c:if>
                            </div>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="empty-locked">
                        <p style="margin: 0;">&#9989; Không có tài khoản nào bị khóa</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        </div><!-- đóng lockedContent -->

        <script>
            var totalLocked = ${totalLockedRecords != null ? totalLockedRecords : 0};
            if (totalLocked > 0) {
                var section = document.getElementById('lockedAccountsSection');
                section.style.display = 'block';
                document.getElementById('lockedCount').textContent = totalLocked;
                var content = document.getElementById('lockedContent');
                content.style.display = 'block';
                document.getElementById('toggleIcon').textContent = '\u25BC';
            }

            function toggleLockedSection() {
                var content = document.getElementById('lockedContent');
                var icon = document.getElementById('toggleIcon');
                if (content.style.display === 'none') {
                    content.style.display = 'block';
                    icon.textContent = '\u25BC';
                } else {
                    content.style.display = 'none';
                    icon.textContent = '\u25B6';
                }
            }
        </script>
    </div>

    <!-- =============================================
         MODAL: Nhập lý do khóa tài khoản (thay thế prompt())
         ============================================= -->
    <div id="lockModal" class="modal" style="display: none;">
        <div class="modal-content">
            <h3>🔒 Khóa tài khoản</h3>
            <p style="color:#666; margin-top: 0;">
                Bạn đang khóa tài khoản: <strong id="lockModalName"></strong>
            </p>
            <form method="POST" action="${pageContext.request.contextPath}/admin/accounts" id="lockModalForm">
                <input type="hidden" name="action" value="lock">
                <input type="hidden" name="userId" id="lockModalUserId">
                <label for="lockModalReason">Lý do khóa (không bắt buộc):</label>
                <textarea name="reason" id="lockModalReason" placeholder="Nhập lý do khóa tài khoản..."></textarea>
                <div class="modal-buttons">
                    <button type="button" class="btn btn-secondary" id="lockModalCancel">Hủy</button>
                    <button type="submit" class="btn btn-danger">🔒 Xác nhận khóa</button>
                </div>
            </form>
        </div>
    </div>

    <!-- =============================================
         MODAL: Xác nhận mở khóa (thay thế confirm())
         ============================================= -->
    <div id="unlockModal" class="modal" style="display: none;">
        <div class="modal-content">
            <h3>🔓 Mở khóa tài khoản</h3>
            <p style="color:#666; margin-top: 0;">
                Bạn có chắc muốn mở khóa tài khoản: <strong id="unlockModalName"></strong>?
            </p>
            <form method="POST" action="${pageContext.request.contextPath}/admin/accounts" id="unlockModalForm">
                <input type="hidden" name="action" value="unlock">
                <input type="hidden" name="userId" id="unlockModalUserId">
                <div class="modal-buttons">
                    <button type="button" class="btn btn-secondary" id="unlockModalCancel">Hủy</button>
                    <button type="submit" class="btn btn-success">🔓 Xác nhận mở khóa</button>
                </div>
            </form>
        </div>
    </div>

    <!-- =============================================
         MODAL: Xác nhận reset mật khẩu (thay thế confirm())
         ============================================= -->
    <div id="resetPwModal" class="modal" style="display: none;">
        <div class="modal-content">
            <h3>🔑 Reset mật khẩu</h3>
            <p style="color:#666; margin-top: 0;">
                Đặt lại mật khẩu của tài khoản: <strong id="resetPwModalName"></strong>
            </p>
            <p style="color:#e67e22;">
                ⚠ Mật khẩu sẽ được đặt về mặc định: <strong>123456</strong><br>
                Người dùng sẽ được yêu cầu đổi mật khẩu khi đăng nhập lần sau.
            </p>
            <form method="POST" action="${pageContext.request.contextPath}/admin/accounts" id="resetPwModalForm">
                <input type="hidden" name="action" value="resetPassword">
                <input type="hidden" name="userId" id="resetPwModalUserId">
                <div class="modal-buttons">
                    <button type="button" class="btn btn-secondary" id="resetPwModalCancel">Hủy</button>
                    <button type="submit" class="btn btn-warning">🔑 Xác nhận reset</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // =============================================
        //  MODAL HANDLERS - thay thế prompt() và confirm()
        //  Bằng modal HTML thật, không bị browser chặn
        // =============================================
        function openLockModal(userId, fullName) {
            document.getElementById('lockModalUserId').value = userId;
            document.getElementById('lockModalName').textContent = fullName || 'tài khoản này';
            document.getElementById('lockModalReason').value = '';
            document.getElementById('lockModal').style.display = 'block';
        }
        function closeLockModal() {
            document.getElementById('lockModal').style.display = 'none';
        }
        function openUnlockModal(userId, fullName) {
            document.getElementById('unlockModalUserId').value = userId;
            document.getElementById('unlockModalName').textContent = fullName || 'tài khoản này';
            document.getElementById('unlockModal').style.display = 'block';
        }
        function closeUnlockModal() {
            document.getElementById('unlockModal').style.display = 'none';
        }
        function openResetPwModal(userId, fullName) {
            document.getElementById('resetPwModalUserId').value = userId;
            document.getElementById('resetPwModalName').textContent = fullName || 'tài khoản này';
            document.getElementById('resetPwModal').style.display = 'block';
        }
        function closeResetPwModal() {
            document.getElementById('resetPwModal').style.display = 'none';
        }

        // Đóng modal khi bấm nút Hủy
        document.addEventListener('DOMContentLoaded', function() {
            var c1 = document.getElementById('lockModalCancel');
            if (c1) c1.addEventListener('click', closeLockModal);
            var c2 = document.getElementById('unlockModalCancel');
            if (c2) c2.addEventListener('click', closeUnlockModal);
            var c3 = document.getElementById('resetPwModalCancel');
            if (c3) c3.addEventListener('click', closeResetPwModal);

            // Đóng modal khi click ra ngoài
            ['lockModal', 'unlockModal', 'resetPwModal'].forEach(function(id) {
                var modal = document.getElementById(id);
                if (modal) {
                    modal.addEventListener('click', function(e) {
                        if (e.target === modal) modal.style.display = 'none';
                    });
                }
            });
        });

        // =============================================
        //  EVENT DELEGATION - bắt mọi click trên document
        // =============================================
        document.addEventListener('click', function(event) {
            var target = event.target;
            if (!target) return;

            // Tìm phần tử gốc có class lock-btn / unlock-btn / reset-pw-btn
            // (vì click có thể rơi vào icon/emoji bên trong button)
            var btn = target;
            while (btn && btn !== document.body) {
                if (btn.classList && (
                    btn.classList.contains('lock-btn') ||
                    btn.classList.contains('unlock-btn') ||
                    btn.classList.contains('reset-pw-btn'))) {
                    break;
                }
                btn = btn.parentNode;
            }
            if (!btn || btn === document.body) return;

            console.log('[AdminAccounts] clicked:', btn.className, 'userId=', btn.getAttribute('data-userid'));

            event.preventDefault();
            event.stopPropagation();

            var userId = btn.getAttribute('data-userid');
            var name   = btn.getAttribute('data-name');
            if (!userId) {
                alert('Lỗi: không lấy được ID tài khoản. Vui lòng reload trang (Ctrl+F5).');
                return;
            }

            if (btn.classList.contains('lock-btn')) {
                openLockModal(userId, name);
                return;
            }
            if (btn.classList.contains('unlock-btn')) {
                openUnlockModal(userId, name);
                return;
            }
            if (btn.classList.contains('reset-pw-btn')) {
                openResetPwModal(userId, name);
                return;
            }
        });

        // =============================================
        //  TỰ ẨN ALERT sau 5 giây
        // =============================================
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(function() {
                var alerts = document.querySelectorAll('.alert');
                alerts.forEach(function(alert) {
                    alert.style.opacity = '0';
                    setTimeout(function() { alert.style.display = 'none'; }, 300);
                });
            }, 5000);
        });
    </script>
</body>
</html>
