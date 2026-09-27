<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Nhân sự - Store Manager</title>
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
        
        /* Branch Info */
        .branch-info {
            background: #e8f4fc;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .branch-info strong {
            color: #2980b9;
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
            content: " ▲";
            font-size: 10px;
        }
        th a.active.desc::after {
            content: " ▼";
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
           LOCKED EMPLOYEES SECTION
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
            gap: 10px;
            align-items: flex-end;
        }
        .locked-filter input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            min-width: 200px;
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
            <a href="${pageContext.request.contextPath}/store-manager/dashboard" style="color: #3498db; text-decoration: none;">← Quay về Dashboard</a>
        </div>
        
        <h1>📋 Quản lý Nhân sự</h1>
        
        <!-- Branch Info -->
        <div class="branch-info">
            <strong>📍 Cơ sở hiện tại:</strong> 
            <c:choose>
                <c:when test="${not empty currentBranch}">
                    ${currentBranch.name} (${currentBranch.code}) - ${currentBranch.address}
                </c:when>
                <c:otherwise>
                    Không xác định được cơ sở của bạn
                </c:otherwise>
            </c:choose>
        </div>
        
        <!-- Messages -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">
                ✅ ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                ❌ ${errorMessage}
            </div>
        </c:if>
        
        <!-- Filter Section -->
        <div class="filter-section">
            <form method="GET" action="${pageContext.request.contextPath}/store-manager/employees" id="filterForm">
                <div class="filter-row">
                    <div class="filter-group">
                        <label for="search">🔍 Tìm kiếm</label>
                        <input type="text" id="search" name="search" placeholder="Họ tên, username, email, SĐT..." 
                               value="${search}">
                    </div>
                    <div class="filter-group">
                        <label for="positionId">📌 Vị trí</label>
                        <select id="positionId" name="positionId">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="pos" items="${positions}">
                                <option value="${pos.id}" ${positionId == pos.id ? 'selected' : ''}>${pos.title}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="departmentId">🏢 Phòng ban</label>
                        <select id="departmentId" name="departmentId">
                            <option value="">-- Tất cả --</option>
                            <c:forEach var="dept" items="${departments}">
                                <option value="${dept.id}" ${departmentId == dept.id ? 'selected' : ''}>${dept.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="employeeType">👤 Loại nhân viên</label>
                        <select id="employeeType" name="employeeType">
                            <option value="">-- Tất cả --</option>
                            <option value="Full-time" ${employeeType == 'FULL_TIME' || employeeType == 'Full-time' ? 'selected' : ''}>Full-time</option>
                            <option value="Part-time" ${employeeType == 'PART_TIME' || employeeType == 'Part-time' ? 'selected' : ''}>Part-time</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="status">📊 Trạng thái</label>
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
                            <button type="submit" class="btn btn-primary">🔍 Lọc</button>
                            <a href="${pageContext.request.contextPath}/store-manager/employees" class="btn btn-secondary">🗑️ Xóa lọc</a>
                        </div>
                    </div>
                </div>
                <!-- Hidden fields for pagination -->
                <input type="hidden" name="sort" value="${sortColumn}">
                <input type="hidden" name="dir" value="${sortDirection}">
            </form>
        </div>
        
        <!-- Employee Table -->
        <div class="table-container">
            <c:choose>
                <c:when test="${not empty employees}">
                    <table>
                        <thead>
                            <tr>
                                <th>STT</th>
                                <th>
                                    <a href="?search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=full_name&dir=${sortColumn == 'full_name' && sortDirection == 'ASC' ? 'DESC' : 'ASC'}&page=1&size=${pageSize}">
                                        Họ và tên ${sortColumn == 'full_name' ? (sortDirection == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>
                                <th>
                                    <a href="?search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=username&dir=${sortColumn == 'username' && sortDirection == 'ASC' ? 'DESC' : 'ASC'}&page=1&size=${pageSize}">
                                        Username ${sortColumn == 'username' ? (sortDirection == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>
                                <th>Email</th>
                                <th>Số điện thoại</th>
                                <th>
                                    <a href="?search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=position&dir=${sortColumn == 'position' && sortDirection == 'ASC' ? 'DESC' : 'ASC'}&page=1&size=${pageSize}">
                                        Vị trí ${sortColumn == 'position' ? (sortDirection == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>
                                <th>Phòng ban</th>
                                <th>
                                    <a href="?search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=type&dir=${sortColumn == 'type' && sortDirection == 'ASC' ? 'DESC' : 'ASC'}&page=1&size=${pageSize}">
                                        Loại NV ${sortColumn == 'type' ? (sortDirection == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>
                                <th>
                                    <a href="?search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=status&dir=${sortColumn == 'status' && sortDirection == 'ASC' ? 'DESC' : 'ASC'}&page=1&size=${pageSize}">
                                        Trạng thái ${sortColumn == 'status' ? (sortDirection == 'ASC' ? '▲' : '▼') : ''}
                                    </a>
                                </th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="emp" items="${employees}" varStatus="loop">
                                <tr>
                                    <td>${(currentPage - 1) * pageSize + loop.index + 1}</td>
                                    <td><strong>${emp.fullName}</strong></td>
                                    <td>${emp.username}</td>
                                    <td>${emp.email}</td>
                                    <td>${emp.phone}</td>
                                    <td>${emp.positionName}</td>
                                    <td>${emp.departmentName}</td>
                                    <td>${emp.employeeType}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${emp.status == 'ACTIVE'}">
                                                <span class="status-badge status-active">ACTIVE</span>
                                            </c:when>
                                            <c:when test="${emp.status == 'INACTIVE'}">
                                                <span class="status-badge status-inactive">INACTIVE</span>
                                            </c:when>
                                            <c:when test="${emp.status == 'EMERGENCY_LOCKED'}">
                                                <span class="status-badge status-locked">EMERGENCY_LOCKED</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge status-inactive">${emp.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <c:choose>
                                                <c:when test="${emp.status == 'ACTIVE'}">
                                                    <button type="button" class="btn btn-danger btn-sm" 
                                                            onclick="showLockModal(${emp.userId}, this.getAttribute('data-name'))"
                                                            data-name="${fn:escapeXml(emp.fullName)}">
                                                        🔒 Khóa
                                                    </button>
                                                </c:when>
                                                <c:when test="${emp.status == 'EMERGENCY_LOCKED'}">
                                                    <button type="button" class="btn btn-success btn-sm" 
                                                            onclick="showUnlockModal(${emp.userId}, this.getAttribute('data-name'))"
                                                            data-name="${fn:escapeXml(emp.fullName)}">
                                                        🔓 Mở khóa
                                                    </button>
                                                </c:when>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <h3>🔍 Không tìm thấy nhân viên nào</h3>
                        <p>Vui lòng thử thay đổi điều kiện lọc hoặc liên hệ quản trị viên.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        
        <!-- Pagination -->
        <c:if test="${not empty employees}">
            <div class="pagination-container">
                <div class="pagination-info">
                    Hiển thị <strong>${(currentPage - 1) * pageSize + 1}</strong> - 
                    <strong>${displayEnd}</strong> 
                    trong <strong>${totalRecords}</strong> nhân viên
                </div>
                
                <div class="pagination-controls">
                    <!-- Page Size -->
                    <form method="GET" class="page-size-form" id="pageSizeForm">
                        <span>Hiển thị:</span>
                        <select name="size" onchange="document.getElementById('pageSizeForm').submit()">
                            <c:forEach var="ps" items="${pageSizes}">
                                <option value="${ps}" ${pageSize == ps ? 'selected' : ''}>${ps}</option>
                            </c:forEach>
                        </select>
                        <!-- Preserve other params -->
                        <input type="hidden" name="search" value="${search}">
                        <input type="hidden" name="positionId" value="${positionId}">
                        <input type="hidden" name="departmentId" value="${departmentId}">
                        <input type="hidden" name="employeeType" value="${employeeType}">
                        <input type="hidden" name="status" value="${status}">
                        <input type="hidden" name="sort" value="${sortColumn}">
                        <input type="hidden" name="dir" value="${sortDirection}">
                    </form>
                    
                    <!-- Page Numbers -->
                    <c:if test="${currentPage > 1}">
                        <a href="?page=1&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">«</a>
                        <a href="?page=${currentPage - 1}&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">‹</a>
                    </c:if>
                    
                    <c:forEach var="i" begin="${pagerStart}" end="${pagerEnd}">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="current">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="?page=${i}&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    
                    <c:if test="${currentPage < totalPages}">
                        <a href="?page=${currentPage + 1}&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">›</a>
                        <a href="?page=${totalPages}&size=${pageSize}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}">»</a>
                    </c:if>
                </div>
            </div>
        </c:if>
        
        <!-- =============================================
             PHẦN NHÂN VIÊN BỊ KHÓA - THU GỌN
             ============================================= -->
        <div class="locked-section" id="lockedEmployeesSection" style="display: none;">
            <!-- Header có nút click để mở rộng/thu gọn -->
            <div class="locked-header" onclick="toggleLockedSection()" style="cursor: pointer; user-select: none;">
                <h2>🔒 Nhân viên đã bị khóa <span class="count" id="lockedCount">0</span></h2>
                <span id="toggleIcon" style="font-size: 24px;">▼</span>
            </div>
            
            <!-- Nội dung bên trong - có thể thu gọn -->
            <div id="lockedContent">
            
            <!-- Filter cho locked employees -->
            <form method="GET" action="${pageContext.request.contextPath}/store-manager/employees" class="locked-filter">
                <div style="flex: 1;">
                    <input type="text" name="lockedSearch" placeholder="🔍 Tìm kiếm nhân viên bị khóa..." value="${lockedSearch}">
                </div>
                <!-- Preserve other filter params -->
                <input type="hidden" name="search" value="${search}">
                <input type="hidden" name="positionId" value="${positionId}">
                <input type="hidden" name="departmentId" value="${departmentId}">
                <input type="hidden" name="employeeType" value="${employeeType}">
                <input type="hidden" name="status" value="${status}">
                <input type="hidden" name="sort" value="${sortColumn}">
                <input type="hidden" name="dir" value="${sortDirection}">
                <input type="hidden" name="page" value="${currentPage}">
                <input type="hidden" name="size" value="${pageSize}">
                <button type="submit" class="btn btn-primary">Tìm kiếm</button>
                <a href="${pageContext.request.contextPath}/store-manager/employees" class="btn btn-secondary">Xóa lọc</a>
            </form>
            
            <!-- Bảng locked employees -->
            <c:choose>
                <c:when test="${not empty lockedEmployees}">
                    <table class="table-locked">
                        <thead>
                            <tr>
                                <th>STT</th>
                                <th>Họ và tên</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>SĐT</th>
                                <th>Người khóa</th>
                                <th>Thời gian bị khóa</th>
                                <th>Lý do</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="lock" items="${lockedEmployees}" varStatus="loop">
                                <tr>
                                    <td>${(currentLockedPage - 1) * lockedPageSize + loop.index + 1}</td>
                                    <td><strong>${lock.userName}</strong></td>
                                    <td>${lock.username}</td>
                                    <td>${lock.email}</td>
                                    <td>${lock.phone}</td>
                                    <td>${lock.lockedByName}</td>
                                    <td><fmt:formatDate value="${lock.lockedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    <td class="reason-cell" title="${lock.reason}">
                                        <c:choose>
                                            <c:when test="${not empty lock.reason}">${lock.reason}</c:when>
                                            <c:otherwise><em style="color: #999;">Không có</em></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <button type="button" class="btn btn-success btn-sm" 
                                                onclick="showUnlockModalFromLocked(${lock.userId}, this.getAttribute('data-name'))"
                                                data-name="${fn:escapeXml(lock.userName)}">
                                            🔓 Mở khóa
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    
                    <!-- Pagination cho locked -->
                    <c:if test="${totalLockedPages > 1}">
                        <div class="locked-pagination">
                            <span style="color: #666; font-size: 13px;">
                                Trang ${currentLockedPage}/${totalLockedPages} (${totalLockedRecords} nhân viên bị khóa)
                            </span>
                            <div style="display: flex; gap: 5px;">
                                <c:if test="${currentLockedPage > 1}">
                                    <a href="?lockedPage=1&lockedSearch=${lockedSearch}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}">«</a>
                                    <a href="?lockedPage=${currentLockedPage - 1}&lockedSearch=${lockedSearch}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}">‹</a>
                                </c:if>
                                
                                <c:forEach var="i" begin="${lockedPagerStart}" end="${lockedPagerEnd}">
                                    <c:choose>
                                        <c:when test="${i == currentLockedPage}">
                                            <span style="background: #e74c3c; color: white;">${i}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="?lockedPage=${i}&lockedSearch=${lockedSearch}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}">${i}</a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                                
                                <c:if test="${currentLockedPage < totalLockedPages}">
                                    <a href="?lockedPage=${currentLockedPage + 1}&lockedSearch=${lockedSearch}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}">›</a>
                                    <a href="?lockedPage=${totalLockedPages}&lockedSearch=${lockedSearch}&search=${search}&positionId=${positionId}&departmentId=${departmentId}&employeeType=${employeeType}&status=${status}&sort=${sortColumn}&dir=${sortDirection}&page=${currentPage}&size=${pageSize}">»</a>
                                </c:if>
                            </div>
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="empty-locked">
                        <p style="margin: 0;">✅ Không có nhân viên nào bị khóa</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        </div><!-- đóng lockedContent -->
        
        <!-- Hiển thị phần locked nếu có nhân viên bị khóa -->
        <script>
            var totalLocked = ${totalLockedRecords != null ? totalLockedRecords : 0};
            if (totalLocked > 0) {
                document.getElementById('lockedEmployeesSection').style.display = 'block';
                document.getElementById('lockedCount').textContent = totalLocked;
            }
            
            // Toggle thu gọn/mở rộng phần locked
            function toggleLockedSection() {
                var content = document.getElementById('lockedContent');
                var icon = document.getElementById('toggleIcon');
                if (content.style.display === 'none') {
                    content.style.display = 'block';
                    icon.textContent = '▼';
                } else {
                    content.style.display = 'none';
                    icon.textContent = '▶';
                }
            }
        </script>
    </div>
    
    <!-- Lock Confirmation Modal -->
    <div id="lockModal" class="modal" onclick="closeLockModal()">
        <div class="modal-content" onclick="event.stopPropagation()">
            <h3>🔒 Xác nhận Khóa Khẩn cấp</h3>
            <p>Bạn có chắc chắn muốn khóa tài khoản nhân viên <strong id="lockEmployeeName"></strong>?</p>
            <form method="POST" action="${pageContext.request.contextPath}/store-manager/employees">
                <input type="hidden" name="action" value="lock">
                <input type="hidden" name="userId" id="lockUserId">
                <div style="margin-top: 15px;">
                    <label for="lockReason">Lý do khóa (tùy chọn):</label>
                    <textarea name="reason" id="lockReason" placeholder="Nhập lý do khóa tài khoản..."></textarea>
                </div>
                <div class="modal-buttons">
                    <button type="button" class="btn btn-secondary" onclick="closeLockModal()">Hủy</button>
                    <button type="submit" class="btn btn-danger">Xác nhận Khóa</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Unlock Confirmation Modal -->
    <div id="unlockModal" class="modal" onclick="closeUnlockModal()">
        <div class="modal-content" onclick="event.stopPropagation()">
            <h3>🔓 Xác nhận Mở khóa</h3>
            <p>Bạn có chắc chắn muốn mở khóa tài khoản nhân viên <strong id="unlockEmployeeName"></strong>?</p>
            <form method="POST" action="${pageContext.request.contextPath}/store-manager/employees">
                <input type="hidden" name="action" value="unlock">
                <input type="hidden" name="userId" id="unlockUserId">
                <div class="modal-buttons">
                    <button type="button" class="btn btn-secondary" onclick="closeUnlockModal()">Hủy</button>
                    <button type="submit" class="btn btn-success">Xác nhận Mở khóa</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        // =============================================
        // GLOBAL FUNCTIONS - Đặt RA NGOÀI để onclick gọi được
        // =============================================
        
        function showLockModal(userId, fullName) {
            document.getElementById('lockUserId').value = userId;
            document.getElementById('lockEmployeeName').textContent = fullName || 'Nhân viên';
            document.getElementById('lockModal').style.display = 'block';
        }
        
        function closeLockModal() {
            document.getElementById('lockModal').style.display = 'none';
        }
        
        function showUnlockModal(userId, fullName) {
            document.getElementById('unlockUserId').value = userId;
            document.getElementById('unlockEmployeeName').textContent = fullName || 'Nhân viên';
            document.getElementById('unlockModal').style.display = 'block';
        }
        
        function showUnlockModalFromLocked(userId, fullName) {
            showUnlockModal(userId, fullName);
        }
        
        function closeUnlockModal() {
            document.getElementById('unlockModal').style.display = 'none';
        }
        
        // =============================================
        // INITIALIZATION - Chạy khi DOM ready
        // =============================================
        document.addEventListener('DOMContentLoaded', function() {
            
            // Close modal when clicking outside
            document.addEventListener('click', function(event) {
                var lockModal = document.getElementById('lockModal');
                var unlockModal = document.getElementById('unlockModal');
                
                if (event.target === lockModal) {
                    closeLockModal();
                }
                if (event.target === unlockModal) {
                    closeUnlockModal();
                }
            });
            
            // Close modal with Escape key
            document.addEventListener('keydown', function(event) {
                if (event.key === 'Escape') {
                    closeLockModal();
                    closeUnlockModal();
                }
            });
            
            // Auto-hide alerts after 5 seconds
            setTimeout(function() {
                var alerts = document.querySelectorAll('.alert');
                alerts.forEach(function(alert) {
                    alert.style.opacity = '0';
                    setTimeout(function() {
                        alert.style.display = 'none';
                    }, 300);
                });
            }, 5000);
        });
    </script>
</body>
</html>
