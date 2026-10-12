<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản lý Hồ sơ Nhân sự</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

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
