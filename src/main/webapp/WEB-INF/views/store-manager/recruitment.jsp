<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Đề Xuất Tuyển Dụng</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body { background-color: #f8f9fa; }
            .main-container { max-width: 1200px; margin: 30px auto; }
            .status-PENDING { color: #ffc107; font-weight: bold; }
            .status-APPROVED { color: #198754; font-weight: bold; }
            .status-REJECTED { color: #dc3545; font-weight: bold; }
        </style>
    </head>
    <body>
        <div class="container main-container">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="text-primary mb-0">Quản Lý Đề Xuất Tuyển Dụng Nhân Sự</h3>
                <div>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createProposalModal">
                        + Tạo Đề Xuất Mới
                    </button>
                    <a href="${pageContext.request.contextPath}/store-manager/dashboard" class="btn btn-outline-secondary ms-2">Dashboard</a>
                </div>
            </div>

            <!-- THÔNG BÁO THÀNH CÔNG CHUNG -->
            <c:if test="${not empty message}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- BẢNG LỊCH SỬ ĐỀ XUẤT -->
            <div class="card shadow-sm border-0 p-3 bg-white rounded-3">
                <h5 class="text-secondary mb-3">Lịch sử đề xuất tuyển dụng của chi nhánh</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Ngày tạo</th>
                                <th>Họ tên ứng viên</th>
                                <th>Vị trí</th>
                                <th>Hình thức</th>
                                <th>Trạng thái</th>
                                <th>Ghi chú từ HR</th>
                                <th class="text-center">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rp" items="${proposals}">
                                <tr>
                                    <td><fmt:formatDate value="${rp.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    <td>
                                        <span class="fw-semibold">${not empty rp.candidate ? rp.candidate.fullName : 'N/A'}</span><br>
                                        <small class="text-muted">${not empty rp.candidate ? rp.candidate.phone : ''}</small>
                                    </td>
                                    <td>${rp.positionTitle}</td>
                                    <td><span class="badge bg-info text-dark">${rp.employmentType}</span></td>
                                    <td>
                                        <span class="status-${rp.status}">
                                            <c:choose>
                                                <c:when test="${rp.status == 'PENDING'}">Chờ duyệt</c:when>
                                                <c:when test="${rp.status == 'APPROVED'}">Đã duyệt</c:when>
                                                <c:when test="${rp.status == 'REJECTED'}">Từ chối</c:when>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td><small class="text-muted">${empty rp.hrNote ? '---' : rp.hrNote}</small></td>
                                    <td class="text-center">
                                        <c:if test="${rp.status == 'REJECTED'}">
                                            <button class="btn btn-sm btn-warning text-white" 
                                                    onclick="openResubmitModal('${rp.id}', '${rp.candidate.fullName}', '${rp.candidate.phone}', '${rp.candidate.identityCard}', '${rp.candidate.email}', '${rp.positionId}', '${rp.employmentType}', '${rp.targetDate}', '${rp.reason}')">
                                                Sửa & Gửi lại
                                            </button>
                                        </c:if>
                                        <c:if test="${rp.status == 'APPROVED'}">
                                            <span class="text-success small fw-semibold">Đã cấp tài khoản</span>
                                        </c:if>
                                        <c:if test="${rp.status == 'PENDING'}">
                                            <span class="text-muted small">Đang chờ xử lý</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty proposals}">
                                <tr><td colspan="7" class="text-center text-muted py-4">Chưa có đề xuất tuyển dụng nào.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- MODAL TẠO ĐỀ XUẤT MỚI -->
        <div class="modal fade" id="createProposalModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/store-manager/recruitment" method="post">
                        <div class="modal-header">
                            <h5 class="modal-title text-primary">Tạo Đề Xuất Tuyển Dụng Mới</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="action" value="create">
                            
                            <!-- HIỂN THỊ LỖI NGAY TRONG MODAL -->
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger py-2 mb-3" role="alert">
                                    ${error}
                                </div>
                            </c:if>

                            <div class="row g-3 mb-3">
                                <div class="col-md-5">
                                    <label class="form-label">Họ và tên ứng viên <span class="text-danger">*</span></label>
                                    <input type="text" name="fullName" class="form-control" required>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                                    <input type="text" name="phone" class="form-control" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Số CCCD/CMND <span class="text-danger">*</span></label>
                                    <input type="text" name="identityCard" class="form-control" required>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email ứng viên (Tùy chọn)</label>
                                <input type="email" name="email" class="form-control" placeholder="nguyenvana@gmail.com">
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Vị trí công việc <span class="text-danger">*</span></label>
                                    <select name="positionId" class="form-select" required>
                                        <option value="">-- Chọn vị trí --</option>
                                        <c:forEach var="p" items="${positions}">
                                            <option value="${p.id}">${p.title}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Hình thức <span class="text-danger">*</span></label>
                                    <select id="employeeTypeSelect" name="employeeType" class="form-select" onchange="handleTypeChange('employeeTypeSelect', 'shiftContainer', 'expContainer')" required>
                                        <option value="FULL_TIME">FULL_TIME (Chính thức)</option>
                                        <option value="PART_TIME">PART_TIME (Bán thời gian)</option>
                                        <option value="CASUAL">CASUAL (Thời vụ)</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Ngày mong muốn có nhân sự <span class="text-danger">*</span></label>
                                    <input type="date" id="targetDateInput" name="targetDate" class="form-control" required>
                                </div>
                                <div class="col-md-6" id="shiftContainer" style="display: none;">
                                    <label class="form-label">Ca làm việc cố định <span class="text-danger">*</span></label>
                                    <select id="shiftSelect" name="shiftType" class="form-select">
                                        <option value="">-- Chọn ca --</option>
                                        <option value="SANG">Ca Sáng</option>
                                        <option value="CHIEU">Ca Chiều</option>
                                        <option value="TOI">Ca Tối</option>
                                    </select>
                                </div>
                                <div class="col-md-6" id="expContainer" style="display: none;">
                                    <label class="form-label">Ngày kết thúc HĐ <span class="text-danger">*</span></label>
                                    <input type="date" id="expirationDateInput" name="expirationDate" class="form-control">
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Lý do đề xuất <span class="text-danger">*</span></label>
                                <textarea name="reason" rows="2" class="form-control" required></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                            <button type="submit" class="btn btn-primary">Gửi Đề Xuất</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- MODAL CHỈNH SỬA & GỬI LẠI (RESUBMIT) -->
        <div class="modal fade" id="resubmitModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/store-manager/recruitment" method="post">
                        <div class="modal-header">
                            <h5 class="modal-title text-warning">Chỉnh Sửa & Gửi Lại Đề Xuất</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="action" value="resubmit">
                            <input type="hidden" id="editProposalId" name="proposalId">
                            
                            <div class="row g-3 mb-3">
                                <div class="col-md-5">
                                    <label class="form-label">Họ và tên ứng viên <span class="text-danger">*</span></label>
                                    <input type="text" id="editFullName" name="fullName" class="form-control" required>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                                    <input type="text" id="editPhone" name="phone" class="form-control" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Số CCCD/CMND <span class="text-danger">*</span></label>
                                    <input type="text" id="editIdentityCard" name="identityCard" class="form-control" required>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email ứng viên (Tùy chọn)</label>
                                <input type="email" id="editEmail" name="email" class="form-control">
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Vị trí công việc <span class="text-danger">*</span></label>
                                    <select id="editPositionId" name="positionId" class="form-select" required>
                                        <option value="">-- Chọn vị trí --</option>
                                        <c:forEach var="p" items="${positions}">
                                            <option value="${p.id}">${p.title}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Hình thức <span class="text-danger">*</span></label>
                                    <select id="editEmployeeType" name="employeeType" class="form-select" onchange="handleTypeChange('editEmployeeType', 'editShiftContainer', 'editExpContainer')" required>
                                        <option value="FULL_TIME">FULL_TIME</option>
                                        <option value="PART_TIME">PART_TIME</option>
                                        <option value="CASUAL">CASUAL</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Ngày mong muốn có nhân sự <span class="text-danger">*</span></label>
                                    <input type="date" id="editTargetDate" name="targetDate" class="form-control" required>
                                </div>
                                <div class="col-md-6" id="editShiftContainer" style="display: none;">
                                    <label class="form-label">Ca làm việc cố định <span class="text-danger">*</span></label>
                                    <select id="editShiftType" name="shiftType" class="form-select">
                                        <option value="">-- Chọn ca --</option>
                                        <option value="SANG">Ca Sáng</option>
                                        <option value="CHIEU">Ca Chiều</option>
                                        <option value="TOI">Ca Tối</option>
                                    </select>
                                </div>
                                <div class="col-md-6" id="editExpContainer" style="display: none;">
                                    <label class="form-label">Ngày kết thúc HĐ <span class="text-danger">*</span></label>
                                    <input type="date" id="editExpirationDate" name="expirationDate" class="form-control">
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Lý do đề xuất chỉnh sửa <span class="text-danger">*</span></label>
                                <textarea id="editReason" name="reason" rows="2" class="form-control" required></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                            <button type="submit" class="btn btn-warning text-white">Gửi Lại Đề Xuất</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            function handleTypeChange(selectId, shiftContId, expContId) {
                const type = document.getElementById(selectId).value;
                const shiftContainer = document.getElementById(shiftContId);
                const shiftSelect = shiftContainer.querySelector('select');
                const expContainer = document.getElementById(expContId);
                const expInput = expContainer.querySelector('input');

                if (type === 'PART_TIME') {
                    shiftContainer.style.display = 'block';
                    shiftSelect.required = true;
                    expContainer.style.display = 'none';
                    expInput.required = false;
                    expInput.value = '';
                } else if (type === 'CASUAL') {
                    shiftContainer.style.display = 'none';
                    shiftSelect.required = false;
                    shiftSelect.value = '';
                    expContainer.style.display = 'block';
                    expInput.required = true;
                } else {
                    shiftContainer.style.display = 'none';
                    shiftSelect.required = false;
                    shiftSelect.value = '';
                    expContainer.style.display = 'none';
                    expInput.required = false;
                    expInput.value = '';
                }
            }

            document.addEventListener("DOMContentLoaded", function () {
                const today = new Date().toISOString().split('T')[0];
                
                const targetDateInput = document.getElementById('targetDateInput');
                if (targetDateInput) targetDateInput.min = today;

                const expirationDateInput = document.getElementById('expirationDateInput');
                if (expirationDateInput) expirationDateInput.min = today;

                const editTargetDate = document.getElementById('editTargetDate');
                if (editTargetDate) editTargetDate.min = today;

                const editExpirationDate = document.getElementById('editExpirationDate');
                if (editExpirationDate) editExpirationDate.min = today;

                // Tự động bật lại Modal tạo mới nếu server trả về lỗi
                <c:if test="${not empty error}">
                    var createModal = new bootstrap.Modal(document.getElementById('createProposalModal'));
                    createModal.show();
                </c:if>
            });

            function openResubmitModal(id, fullName, phone, identityCard, email, positionId, employmentType, targetDate, reason) {
                document.getElementById('editProposalId').value = id;
                document.getElementById('editFullName').value = fullName;
                document.getElementById('editPhone').value = phone;
                document.getElementById('editIdentityCard').value = identityCard;
                document.getElementById('editEmail').value = (email !== 'null' && email !== 'undefined') ? email : '';
                document.getElementById('editPositionId').value = positionId;
                document.getElementById('editEmployeeType').value = employmentType;
                document.getElementById('editTargetDate').value = (targetDate !== 'null' && targetDate !== 'undefined') ? targetDate : '';
                document.getElementById('editReason').value = reason;

                handleTypeChange('editEmployeeType', 'editShiftContainer', 'editExpContainer');

                var resubmitModal = new bootstrap.Modal(document.getElementById('resubmitModal'));
                resubmitModal.show();
            }
        </script>
    </body>
</html>