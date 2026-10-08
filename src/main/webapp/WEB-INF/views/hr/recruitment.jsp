<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

            <c:if test="${param.msg == 'approved'}"><div class="alert alert-success">Đã phê duyệt và khởi tạo quy trình cấp tài khoản thành công!</div></c:if>
            <c:if test="${param.msg == 'rejected'}"><div class="alert alert-success">Đã từ chối đề xuất tuyển dụng!</div></c:if>
            <c:if test="${param.err == '1'}"><div class="alert alert-error">Xử lý thất bại! Vui lòng thử lại.</div></c:if>

            <div class="tabs">
                <a href="${pageContext.request.contextPath}/hr/recruitment?filter=pending"
                   class="${empty filter || filter == 'pending' ? 'active' : ''}">Đang chờ duyệt</a>
                <a href="${pageContext.request.contextPath}/hr/recruitment?filter=all"
                   class="${filter == 'all' ? 'active' : ''}">Tất cả</a>
            </div>

            <div class="card">
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
                                    <td style="font-weight: 600; color: #0d6efd;">${empty rp.candidate.fullName ? 'N/A' : rp.candidate.fullName}</td>
                                    <td title="${rp.positionTitle}">${rp.positionTitle}</td>
                                    <td>${rp.employmentType == 'FULL_TIME' ? 'Toàn thời gian' : 'Bán thời gian'}</td>
                                    <td title="${rp.createdByName}">${rp.createdByName}</td>
                                    <td class="no-clip"><span class="badge badge-${rp.status}">${rp.status}</span></td>
                                    <td class="no-clip">
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
                            <div>
                                <c:choose>
                                    <c:when test="${filter == 'all'}">Hệ thống chưa ghi nhận đề xuất tuyển dụng nào.</c:when>
                                    <c:otherwise>Hiện không có đề xuất nào đang chờ xử lý.</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>

        </div>

    </body>
</html>