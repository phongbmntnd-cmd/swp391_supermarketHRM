<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chi tiết đề xuất tuyển dụng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<div class="topbar">
    <a class="back-link" href="${pageContext.request.contextPath}/hr/recruitment">&larr; Danh sách đề xuất</a>
    <h1>Chi tiết đề xuất tuyển dụng</h1>
</div>

<div class="page" style="max-width:720px;">

<c:if test="${empty proposal}">
    <div class="alert alert-error">Không tìm thấy đề xuất.</div>
</c:if>

<c:if test="${not empty proposal}">

    <div class="page-header">
        <h2>${proposal.positionTitle} &middot; ${proposal.branchName}</h2>
        <p>Đề xuất #${proposal.id} &nbsp;&middot;&nbsp; gửi lúc <fmt:formatDate value="${proposal.createdAt}" pattern="HH:mm, dd/MM/yyyy"/></p>
    </div>

    <c:if test="${param.err == '1'}">
        <div class="alert alert-error">Xử lý thất bại! Đề xuất có thể đã được xử lý trước đó.</div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <h3>Thông tin đề xuất</h3>
            <span class="badge badge-${proposal.status}">${proposal.status}</span>
        </div>
        <div class="card-body">
            <div class="form-grid">
                <div class="field">
                    <label>Chi nhánh</label>
                    <div>${proposal.branchName}</div>
                </div>
                <div class="field">
                    <label>Vị trí</label>
                    <div>${proposal.positionTitle}</div>
                </div>
                <div class="field">
                    <label>Hình thức làm việc</label>
                    <div>${proposal.employmentType == 'FULL_TIME' ? 'Toàn thời gian' : 'Bán thời gian'}</div>
                </div>
                <div class="field">
                    <label>Số lượng cần tuyển</label>
                    <div>${proposal.quantity}</div>
                </div>
                <div class="field">
                    <label>Ngày mong muốn có nhân sự</label>
                    <div><fmt:formatDate value="${proposal.targetDate}" pattern="dd/MM/yyyy"/></div>
                </div>
                <div class="field">
                    <label>Người đề xuất</label>
                    <div>${proposal.createdByName}</div>
                </div>
                <div class="field full">
                    <label>Lý do đề xuất</label>
                    <div>${proposal.reason}</div>
                </div>
            </div>
        </div>
    </div>

    <c:if test="${proposal.status == 'PENDING'}">
        <div class="card">
            <div class="card-header"><h3>Xử lý đề xuất</h3></div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/hr/recruitment">
                    <input type="hidden" name="proposalId" value="${proposal.id}">

                    <div class="field">
                        <label>Ghi chú (tuỳ chọn)</label>
                        <textarea name="hrNote" placeholder="VD: Đồng ý tuyển, ưu tiên ứng viên có kinh nghiệm..."></textarea>
                    </div>

                    <div style="margin-top:16px; display:flex; gap:10px;">
                        <button type="submit" name="action" value="approve" class="btn btn-success">Duyệt đề xuất</button>
                        <button type="submit" name="action" value="reject" class="btn btn-danger">Từ chối</button>
                    </div>
                </form>
            </div>
        </div>
    </c:if>

    <c:if test="${proposal.status != 'PENDING'}">
        <div class="card">
            <div class="card-header"><h3>Kết quả xử lý</h3></div>
            <div class="card-body">
                <div class="form-grid">
                    <div class="field">
                        <label>Người xử lý</label>
                        <div>${proposal.approvedByName}</div>
                    </div>
                    <div class="field">
                        <label>Thời gian xử lý</label>
                        <div><fmt:formatDate value="${proposal.updatedAt}" pattern="HH:mm, dd/MM/yyyy"/></div>
                    </div>
                    <div class="field full">
                        <label>Ghi chú của HR</label>
                        <div>${empty proposal.hrNote ? '(Không có ghi chú)' : proposal.hrNote}</div>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

</c:if>

</div>

</body>
</html>
