<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý Hồ sơ Nhân sự</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 30px; background:#f5f6fa; }
        .card { background:#fff; padding:20px; border-radius:8px; box-shadow:0 1px 4px rgba(0,0,0,.1); }
        table { width:100%; border-collapse:collapse; margin-top:10px; }
        th, td { padding:8px; border-bottom:1px solid #ddd; text-align:left; font-size:14px; }
        input[type="text"] { padding:8px; width:280px; }
        button { padding:8px 16px; background:#2d6cdf; color:#fff; border:none; border-radius:4px; cursor:pointer; }
        a.btn-view { padding:5px 10px; background:#2d6cdf; color:#fff; border-radius:4px; text-decoration:none; font-size:13px; }
        .status-ACTIVE { color:#1a7f37; font-weight:bold; }
        .status-INACTIVE { color:#888; font-weight:bold; }
        .status-EMERGENCY_LOCKED { color:#c62828; font-weight:bold; }
    </style>
</head>
<body>

<h2>Quản lý Hồ sơ Nhân sự</h2>
<p>Danh sách, cập nhật thông tin chi tiết và theo dõi hợp đồng của nhân viên các cơ sở.</p>

<div class="card">
    <form method="get" action="${pageContext.request.contextPath}/hr/employee-management">
        <input type="text" name="keyword" placeholder="Tìm theo tên, username, SĐT, CCCD..." value="${keyword}">
        <button type="submit">Tìm kiếm</button>
    </form>

    <table>
        <tr>
            <th>Username</th>
            <th>Họ tên</th>
            <th>SĐT</th>
            <th>Chi nhánh</th>
            <th>Phòng ban</th>
            <th>Vị trí</th>
            <th>Loại HĐ</th>
            <th>Trạng thái TK</th>
            <th></th>
        </tr>
        <c:forEach var="e" items="${employees}">
            <tr>
                <td>${e.username}</td>
                <td>${e.fullName}</td>
                <td>${e.phone}</td>
                <td>${e.branchName}</td>
                <td>${e.departmentName}</td>
                <td>${e.positionTitle}</td>
                <td>${e.employeeType}</td>
                <td class="status-${e.userStatus}">${e.userStatus}</td>
                <td>
                    <a class="btn-view" href="${pageContext.request.contextPath}/hr/employee-detail?id=${e.userId}">
                        Xem / Sửa
                    </a>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty employees}">
            <tr><td colspan="9">Không tìm thấy nhân viên nào.</td></tr>
        </c:if>
    </table>
</div>

</body>
</html>
