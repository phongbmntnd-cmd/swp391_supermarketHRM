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
        <h2>Danh sách nhân sự toàn hệ thống</h2>
        <p>Thêm mới, cập nhật thông tin chi tiết, theo dõi hợp đồng và thông tin liên lạc của nhân viên các cơ sở.</p>
    </div>

    <div class="card">
        <div class="card-header">
            <h3>Tìm kiếm</h3>
            <form method="get" action="${pageContext.request.contextPath}/hr/employee-management"
                  style="display:flex; gap:8px;">
                <input type="text" name="keyword" placeholder="Tên, username, SĐT, CCCD..." value="${keyword}"
                       style="padding:8px 12px; border:1px solid var(--slate-200); border-radius:8px; width:260px; font-family:inherit;">
                <button type="submit" class="btn btn-primary">Tìm kiếm</button>
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
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="e" items="${employees}">
                    <tr>
                        <td title="${e.username}">${e.username}</td>
                        <td title="${e.fullName}">${e.fullName}</td>
                        <td title="${e.phone}">${e.phone}</td>
                        <td title="${e.identityCard}">${e.identityCard}</td>
                        <td title="${e.branchName}">${e.branchName}</td>
                        <td title="${e.departmentName}">${e.departmentName}</td>
                        <td title="${e.positionTitle}">${e.positionTitle}</td>
                        <td>${e.employeeType}</td>
                        <td class="no-clip"><span class="badge badge-${e.userStatus}">${e.userStatus}</span></td>
                        <td class="no-clip">
                            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/hr/employee-detail?id=${e.userId}">
                                Xem / Sửa
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
