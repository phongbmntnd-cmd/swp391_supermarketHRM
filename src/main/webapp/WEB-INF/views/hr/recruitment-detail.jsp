<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
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

<div class="page" style="max-width:780px;">

<c:if test="${empty proposal}">
    <div class="alert alert-error">Không tìm thấy đề xuất.</div>
</c:if>

<c:if test="${not empty proposal}">

    <div class="page-header">
        <h2>${proposal.candidate.fullName} &middot; ${proposal.positionTitle}</h2>
        <p>Đề xuất #${proposal.id} &nbsp;&middot;&nbsp; gửi lúc <fmt:formatDate value="${proposal.createdAt}" pattern="HH:mm, dd/MM/yyyy"/> bởi ${proposal.createdByName}</p>
    </div>

    <%-- Thông báo lỗi tương ứng từng mã lỗi servlet trả về --%>
    <c:if test="${param.err == '1'}">
        <div class="alert alert-error">Xử lý thất bại! Đề xuất có thể đã được xử lý trước đó.</div>
    </c:if>
    <c:if test="${param.err == 'phone_exists'}">
        <div class="alert alert-error">Số điện thoại của ứng viên đã tồn tại trong hệ thống (nhân viên khác đang dùng)!</div>
    </c:if>
    <c:if test="${param.err == 'id_exists'}">
        <div class="alert alert-error">Số CCCD/CMND của ứng viên đã tồn tại trong hệ thống!</div>
    </c:if>
    <c:if test="${param.err == 'email_exists'}">
        <div class="alert alert-error">Email của ứng viên đã được sử dụng bởi tài khoản khác!</div>
    </c:if>
    <c:if test="${param.err == 'err_note'}">
        <div class="alert alert-error">Vui lòng nhập lý do khi từ chối đề xuất!</div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <h3>👤 Thông tin ứng viên</h3>
            <span class="badge badge-${proposal.status}">${proposal.status}</span>
        </div>
        <div class="card-body">
            <div class="form-grid">
                <div class="field">
                    <label>Họ tên</label>
                    <div>${proposal.candidate.fullName}</div>
                </div>
                <div class="field">
                    <label>Số điện thoại</label>
                    <div>${proposal.candidate.phone}</div>
                </div>
                <div class="field">
                    <label>CCCD/CMND</label>
                    <div>${proposal.candidate.identityCard}</div>
                </div>
                <div class="field">
                    <label>Email</label>
                    <div>${empty proposal.candidate.email ? '(Không có)' : proposal.candidate.email}</div>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h3>📋 Thông tin đề xuất</h3></div>
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
                    <div>
                        <c:choose>
                            <c:when test="${proposal.employmentType == 'FULL_TIME'}">Toàn thời gian</c:when>
                            <c:when test="${proposal.employmentType == 'PART_TIME'}">Bán thời gian</c:when>
                            <c:when test="${proposal.employmentType == 'CASUAL'}">Thời vụ</c:when>
                            <c:otherwise>${proposal.employmentType}</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <c:if test="${proposal.employmentType == 'PART_TIME' && not empty proposal.shiftType}">
                    <div class="field">
                        <label>Ca làm việc</label>
                        <div>${proposal.shiftType}</div>
                    </div>
                </c:if>
                <c:if test="${proposal.employmentType == 'CASUAL' && not empty proposal.expirationDate}">
                    <div class="field">
                        <label>Ngày hết hạn hợp đồng thời vụ</label>
                        <div><fmt:formatDate value="${proposal.expirationDate}" pattern="dd/MM/yyyy"/></div>
                    </div>
                </c:if>
                <div class="field">
                    <label>Ngày mong muốn có nhân sự</label>
                    <div><fmt:formatDate value="${proposal.targetDate}" pattern="dd/MM/yyyy"/></div>
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
            <div class="card-header"><h3>✅ Phê duyệt</h3></div>
            <div class="card-body">
                <p style="margin:0 0 14px; color:var(--text-muted); font-size:13.5px;">
                    Duyệt đề xuất sẽ chuyển sang bước cấp tài khoản nhân sự cho ứng viên này.
                </p>
                <form method="post" action="${pageContext.request.contextPath}/hr/recruitment">
                    <input type="hidden" name="proposalId" value="${proposal.id}">
                    <input type="hidden" name="action" value="approve">
                    <button type="submit" class="btn btn-success">✅ Duyệt &amp; Tạo tài khoản</button>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><h3>❌ Từ chối</h3></div>
            <div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/hr/recruitment">
                    <input type="hidden" name="proposalId" value="${proposal.id}">
                    <input type="hidden" name="action" value="reject">
                    <div class="field">
                        <label>Lý do từ chối (bắt buộc)</label>
                        <textarea name="hrNote" placeholder="VD: Vị trí này đã đủ nhân sự trong quý..." required></textarea>
                    </div>
                    <div style="margin-top:14px;">
                        <button type="submit" class="btn btn-danger">❌ Từ chối đề xuất</button>
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
