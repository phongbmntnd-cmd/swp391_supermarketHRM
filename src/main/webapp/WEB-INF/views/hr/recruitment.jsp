<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Phê duyệt đề xuất tuyển dụng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

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
