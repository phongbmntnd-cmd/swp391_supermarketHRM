<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Đề Xuất Điều Chuyển</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            body { background-color: #f8f9fa; }
            .main-container { max-width: 1300px; margin: 30px auto; }
        </style>
    </head>
    <body>
        <div class="container main-container">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="text-primary mb-0"><i class="fa-solid fa-right-left"></i> Quản Lý Điều Chuyển Nhân Sự</h3>
                <a href="${pageContext.request.contextPath}/store-manager/dashboard" class="btn btn-outline-secondary">Dashboard</a>
            </div>

            <!-- THÔNG BÁO -->
            <c:if test="${not empty message}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- KHU VỰC 1: CÁC ĐƠN DO CƠ SỞ NÀY GỬI ĐI XIN MƯỢN -->
            <div class="card shadow-sm border-0 p-3 bg-white rounded-3 mb-4">
                <h5 class="text-secondary mb-3"><i class="fa-solid fa-paper-plane me-2"></i> Đề xuất mượn nhân sự từ cơ sở khác</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Mã đơn</th>
                                <th>Cơ sở cho mượn</th>
                                <th>Vị trí / Ca</th>
                                <th>Ngày cần</th>
                                <th>Lý do</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="tr" items="${outgoingRequests}">
                                <tr>
                                    <td>#${tr.id}</td>
                                    <td><strong>${tr.sourceStoreName}</strong></td>
                                    <td>${tr.positionName} <br><small class="text-muted">${tr.shiftName}</small></td>
                                    <td>${tr.workDate}</td>
                                    <td>${tr.reason}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${tr.status == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ cơ sở khác duyệt</span></c:when>
                                            <c:when test="${tr.status == 'APPROVED'}"><span class="badge bg-success">Đã được duyệt</span></c:when>
                                            <c:otherwise><span class="badge bg-danger">Từ chối</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty outgoingRequests}">
                                <tr><td colspan="6" class="text-center text-muted py-3">Chưa có đề xuất mượn nào được tạo.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- KHU VỰC 2: CÁC ĐƠN DO CƠ SỞ KHÁC GỬI ĐẾN (CƠ SỞ CHO MƯỢN XEM VÀ DUYỆT) -->
            <div class="card shadow-sm border-0 p-3 bg-white rounded-3">
                <h5 class="text-danger mb-3"><i class="fa-solid fa-inbox me-2"></i> Yêu cầu mượn nhân sự gửi đến cơ sở của bạn (Cơ sở cho mượn)</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Mã đơn</th>
                                <th>Cơ sở xin mượn</th>
                                <th>Vị trí / Ca</th>
                                <th>Ngày mượn</th>
                                <th>Lý do</th>
                                <th>Trạng thái</th>
                                <th class="text-center">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="incoming" items="${incomingRequests}">
                                <tr>
                                    <td>#${incoming.id}</td>
                                    <td><strong class="text-primary">${incoming.destinationStoreName}</strong></td>
                                    <td>${incoming.positionName} <br><small class="text-muted">${incoming.shiftName}</small></td>
                                    <td>${incoming.workDate}</td>
                                    <td>${incoming.reason}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${incoming.status == 'PENDING'}"><span class="badge bg-warning text-dark">Chờ bạn duyệt</span></c:when>
                                            <c:when test="${incoming.status == 'APPROVED'}"><span class="badge bg-success">Đã duyệt cho mượn</span></c:when>
                                            <c:otherwise><span class="badge bg-danger">Đã từ chối</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:if test="${incoming.status == 'PENDING'}">
                                            <!-- Nút mở Modal chọn nhân viên để cho mượn -->
                                            <button class="btn btn-sm btn-success" onclick="openApprovalModal('${incoming.id}')">
                                                <i class="fa-solid fa-check me-1"></i> Duyệt
                                            </button>
                                            <form action="${pageContext.request.contextPath}/store-manager/transfer-requests" method="POST" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn từ chối yêu cầu này không?');">
                                                <input type="hidden" name="action" value="rejectTransfer">
                                                <input type="hidden" name="requestId" value="${incoming.id}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger">
                                                    <i class="fa-solid fa-xmark"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty incomingRequests}">
                                <tr><td colspan="7" class="text-center text-muted py-3">Không có yêu cầu mượn nhân sự nào gửi đến cơ sở của bạn.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- MODAL CHỌN NHÂN VIÊN ĐỂ CHO MƯỢN KHI DUYỆT -->
        <div class="modal fade" id="approvalModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/store-manager/transfer-requests" method="POST">
                        <div class="modal-header bg-success text-white">
                            <h5 class="modal-title"><i class="fa-solid fa-user-check me-2"></i> Phê Duyệt Cho Mượn Nhân Sự</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="action" value="approveTransfer">
                            <input type="hidden" name="requestId" id="modalRequestId">

                            <div class="mb-3">
                                <label class="form-label">Chọn nhân viên của cơ sở bạn để cử sang hỗ trợ <span class="text-danger">*</span></label>
                                <select name="selectedUserId" class="form-select" required>
                                    <option value="" disabled selected>-- Chọn nhân viên phù hợp --</option>
                                    <c:forEach var="emp" items="${branchEmployees}">
                                        <option value="${emp.id}">${emp.fullName} (${emp.positionName})</option>
                                    </c:forEach>
                                </select>
                                <div class="form-text">Nhân viên được chọn sẽ được phân công sang ca làm việc tại cơ sở xin mượn.</div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-success">Xác nhận cho mượn</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            function openApprovalModal(requestId) {
                document.getElementById('modalRequestId').value = requestId;
                var myModal = new bootstrap.Modal(document.getElementById('approvalModal'));
                myModal.show();
            }
        </script>
    </body>
</html>