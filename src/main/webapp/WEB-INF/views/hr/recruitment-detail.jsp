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

        <div class="page" style="max-width:780px;">

            <c:if test="${empty proposal}">
                <div class="alert alert-error">Không tìm thấy đề xuất.</div>
            </c:if>

            <c:if test="${not empty proposal}">

                <div class="page-header">
                    <h2>${proposal.positionTitle} &middot; ${proposal.branchName}</h2>
                    <p>Đề xuất #${proposal.id} &nbsp;&middot;&nbsp; gửi lúc <fmt:formatDate value="${proposal.createdAt}" pattern="HH:mm, dd/MM/yyyy"/></p>
                </div>

                <!-- HIỂN THỊ CÁC THÔNG BÁO LỖI VALIDATE -->
                <c:if test="${param.err == '1'}">
                    <div class="alert alert-error" style="background-color: #f8d7da; color: #842029; padding: 12px; margin-bottom: 20px; border-radius: 4px; border: 1px solid #f5c2c7;">
                        Xử lý thất bại! Đề xuất có thể đã được xử lý trước đó.
                    </div>
                </c:if>
                <c:if test="${param.err == 'phone_exists'}">
                    <div class="alert alert-error" style="background-color: #f8d7da; color: #842029; padding: 12px; margin-bottom: 20px; border-radius: 4px; border: 1px solid #f5c2c7;">
                        <strong>Phê duyệt thất bại:</strong> Số điện thoại ứng viên đã tồn tại trong hệ thống nhân viên! Vui lòng từ chối đề xuất này.
                    </div>
                </c:if>
                <c:if test="${param.err == 'id_exists'}">
                    <div class="alert alert-error" style="background-color: #f8d7da; color: #842029; padding: 12px; margin-bottom: 20px; border-radius: 4px; border: 1px solid #f5c2c7;">
                        <strong>Phê duyệt thất bại:</strong> Số CCCD/CMND ứng viên đã tồn tại trong hệ thống nhân viên! Vui lòng từ chối đề xuất này.
                    </div>
                </c:if>
                <c:if test="${param.err == 'email_exists'}">
                    <div class="alert alert-error" style="background-color: #f8d7da; color: #842029; padding: 12px; margin-bottom: 20px; border-radius: 4px; border: 1px solid #f5c2c7;">
                        <strong>Phê duyệt thất bại:</strong> Email ứng viên đã được sử dụng trong hệ thống nhân viên! Vui lòng từ chối đề xuất này.
                    </div>
                </c:if>
                <c:if test="${param.err == 'err_note'}">
                    <div class="alert alert-error" style="background-color: #f8d7da; color: #842029; padding: 12px; margin-bottom: 20px; border-radius: 4px; border: 1px solid #f5c2c7;">
                        Vui lòng nhập lý do cụ thể khi từ chối đề xuất!
                    </div>
                </c:if>

                <!-- 1. THÔNG TIN ỨNG VIÊN ĐƯỢC ĐỀ XUẤT -->
                <div class="card">
                    <div class="card-header">
                        <h3>1. Thông tin ứng viên đề xuất</h3>
                        <span class="badge badge-${proposal.status}">${proposal.status}</span>
                    </div>
                    <div class="card-body">
                        <div class="form-grid">
                            <div class="field">
                                <label>Họ và tên ứng viên</label>
                                <div style="font-weight:600; color:#0d6efd;">
                                    ${empty proposal.candidate || empty proposal.candidate.fullName ? 'Chưa cập nhật' : proposal.candidate.fullName}
                                </div>
                            </div>
                            <div class="field">
                                <label>Số điện thoại</label>
                                <div>
                                    ${empty proposal.candidate || empty proposal.candidate.phone ? 'Chưa cập nhật' : proposal.candidate.phone}
                                </div>
                            </div>
                            <div class="field">
                                <label>Số CCCD/CMND</label>
                                <div>
                                    ${empty proposal.candidate || empty proposal.candidate.identityCard ? 'Chưa cập nhật' : proposal.candidate.identityCard}
                                </div>
                            </div>
                            <div class="field">
                                <label>Email liên hệ</label>
                                <div>
                                    ${empty proposal.candidate || empty proposal.candidate.email ? 'Chưa cập nhật' : proposal.candidate.email}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 2. THÔNG TIN VỊ TRÍ & PHÂN CÔNG -->
                <div class="card">
                    <div class="card-header">
                        <h3>2. Thông tin phân công & Đề xuất</h3>
                    </div>
                    <div class="card-body">
                        <div class="form-grid">
                            <div class="field">
                                <label>Cơ sở / Chi nhánh</label>
                                <div>${proposal.branchName}</div>
                            </div>
                            <div class="field">
                                <label>Vị trí tuyển dụng</label>
                                <div>${proposal.positionTitle}</div>
                            </div>
                            
                            <div class="field">
                                <label>Hình thức làm việc</label>
                                <div>
                                    <c:choose>
                                        <c:when test="${proposal.employmentType == 'FULL_TIME'}">
                                            Toàn thời gian (Full-time)
                                        </c:when>
                                        <c:when test="${proposal.employmentType == 'PART_TIME'}">
                                            Bán thời gian (Part-time)
                                        </c:when>
                                        <c:when test="${proposal.employmentType == 'CASUAL'}">
                                            <strong style="color: #d63384;">Thời vụ (Casual)</strong>
                                        </c:when>
                                        <c:otherwise>
                                            ${proposal.employmentType}
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="field">
                                <label>Ca làm việc / Hạn HĐ</label>
                                <div>
                                    <c:choose>
                                        <c:when test="${proposal.employmentType == 'PART_TIME'}">
                                            ${empty proposal.shiftType ? 'Theo phân công chi nhánh' : proposal.shiftType}
                                        </c:when>
                                        <c:when test="${proposal.employmentType == 'CASUAL'}">
                                            <c:if test="${not empty proposal.expirationDate}">
                                                Hạn HĐ: <strong style="color: #dc3545;"><fmt:formatDate value="${proposal.expirationDate}" pattern="dd/MM/yyyy"/></strong>
                                            </c:if>
                                            <c:if test="${empty proposal.expirationDate}">
                                                Không xác định
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            Theo phân công chi nhánh
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="field">
                                <label>Người đề xuất (Store Manager)</label>
                                <div>${proposal.createdByName}</div>
                            </div>
                            <div class="field full">
                                <label>Lý do đề xuất</label>
                                <div>${proposal.reason}</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 3. XỬ LÝ ĐỀ XUẤT (DÀNH CHO HR) -->
                <c:if test="${proposal.status == 'PENDING'}">
                    <div class="card">
                        <div class="card-header"><h3>3. Phê duyệt & Cấp tài khoản tự động</h3></div>
                        <div class="card-body">
                            <!-- Form Phê duyệt trực tiếp -->
                            <form method="post" action="${pageContext.request.contextPath}/hr/recruitment" style="margin-bottom: 20px;">
                                <input type="hidden" name="proposalId" value="${proposal.id}">
                                <input type="hidden" name="action" value="approve">
                                <button type="submit" class="btn btn-success" style="padding: 10px 20px;">
                                    &check; Phê duyệt & Tự động cấp tài khoản nhân sự
                                </button>
                            </form>

                            <hr style="margin: 20px 0; border: 0; border-top: 1px solid #eee;">

                            <!-- Form Từ chối đề xuất (Bắt buộc nhập lý do) -->
                            <form method="post" action="${pageContext.request.contextPath}/hr/recruitment">
                                <input type="hidden" name="proposalId" value="${proposal.id}">
                                <input type="hidden" name="action" value="reject">

                                <div class="field">
                                    <label style="font-weight:600; color:#dc3545;">Nêu rõ lý do từ chối (Nếu không duyệt) <span style="color:red;">*</span></label>
                                    <textarea name="hrNote" required rows="3" style="width:100%; padding:8px; border-radius:4px; border:1px solid #ccc;" 
                                              placeholder="Nhập lý do phản hồi cho Store Manager (VD: CCCD đã tồn tại trong hệ thống, thông tin ứng viên không khớp...)"></textarea>
                                </div>

                                <div style="margin-top:12px;">
                                    <button type="submit" class="btn btn-danger">
                                        &cross; Từ chối đề xuất này
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:if>

                <!-- KẾT QUẢ ĐÃ XỬ LÝ -->
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
                                    <label>Ghi chú phản hồi từ HR</label>
                                    <div style="color: ${proposal.status == 'REJECTED' ? '#dc3545' : '#198754'}; font-weight: 500;">
                                        ${empty proposal.hrNote ? '(Không có ghi chú)' : proposal.hrNote}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>

            </c:if>

        </div>

    </body>
</html>