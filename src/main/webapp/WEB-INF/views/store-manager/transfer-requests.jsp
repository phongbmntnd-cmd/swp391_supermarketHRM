<%-- 
    Document   : transfer-requests
    Created on : 19 thg 10, 2026, 11:38:22
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản Lý Điều Chuyển Nhân Sự - Supermarket HRM</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <!-- Bootstrap 5 -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- FontAwesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f4f7f6;
                color: #333;
                display: flex;
                min-height: 100vh;
            }

            /* --- SIDEBAR --- */
            .sidebar {
                width: 260px;
                background-color: #1e293b;
                color: #94a3b8;
                display: flex;
                flex-direction: column;
                position: fixed;
                top: 0;
                bottom: 0;
                left: 0;
                z-index: 100;
                box-shadow: 2px 0 10px rgba(0,0,0,0.1);
            }
            .sidebar-brand {
                padding: 25px 20px;
                font-size: 18px;
                font-weight: 700;
                color: #ffffff;
                background-color: #0f172a;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .sidebar-brand i {
                color: #38bdf8;
                font-size: 22px;
            }
            .sidebar-menu {
                list-style: none;
                padding: 20px 0;
                flex-grow: 1;
            }
            .sidebar-menu li a {
                display: flex;
                align-items: center;
                gap: 15px;
                padding: 14px 25px;
                color: #94a3b8;
                text-decoration: none;
                font-size: 14px;
                font-weight: 500;
                transition: all 0.3s ease;
                border-left: 4px solid transparent;
            }
            .sidebar-menu li a:hover, .sidebar-menu li.active a {
                color: #ffffff;
                background-color: rgba(255, 255, 255, 0.05);
                border-left-color: #38bdf8;
            }
            .sidebar-menu li a i {
                font-size: 16px;
                width: 20px;
                text-align: center;
            }

            /* --- MAIN CONTENT WRAPPER --- */
            .main-wrapper {
                margin-left: 260px;
                flex-grow: 1;
                display: flex;
                flex-direction: column;
            }

            /* --- TOP NAVBAR --- */
            .top-navbar {
                background-color: #ffffff;
                color: #1e293b;
                padding: 15px 35px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 1px 3px rgba(0,0,0,0.05);
                position: sticky;
                top: 0;
                z-index: 99;
            }
            .top-navbar h1 {
                font-size: 18px;
                font-weight: 500;
                color: #334155;
            }
            .user-info {
                display: flex;
                align-items: center;
                gap: 20px;
                font-size: 14px;
            }
            .user-info .notification-badge {
                position: relative;
                color: #64748b;
                font-size: 18px;
                cursor: pointer;
            }
            .user-profile {
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .user-profile img {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                object-fit: cover;
                border: 2px solid #e2e8f0;
            }
            .btn-logout {
                color: #ef4444;
                text-decoration: none;
                background: #ffeeef;
                padding: 6px 14px;
                border-radius: 6px;
                font-weight: 500;
                font-size: 13px;
                transition: all 0.2s;
            }
            .btn-logout:hover {
                background: #ef4444;
                color: white;
            }

            /* --- CONTAINER --- */
            .container-dashboard {
                max-width: 1400px;
                margin: 30px;
                padding: 0;
            }

            /* --- PAGE HEADER CARD --- */
            .page-header-card {
                background: white;
                padding: 25px 30px;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                border: 1px solid #f1f5f9;
                margin-bottom: 25px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .page-header-card h2 {
                font-size: 22px;
                font-weight: 600;
                color: #1e293b;
                display: flex;
                align-items: center;
                gap: 12px;
                margin: 0;
            }
            .page-header-card h2 i {
                color: #0284c7;
            }

            /* --- SECTION CARD --- */
            .content-card {
                background: white;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                border: 1px solid #f1f5f9;
                margin-bottom: 30px;
            }
            .section-title {
                font-size: 18px;
                font-weight: 600;
                color: #1e293b;
                margin-bottom: 20px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .section-title i {
                color: #0284c7;
            }
        </style>
    </head>
    <body>

        <!-- Sidebar Điều Hướng Trái (Store Manager Portal) -->
        <div class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-shop"></i>
                <span>Store Manager</span>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-days"></i> Xếp lịch ca làm</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i> Quản lý điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/employees"><i class="fa-solid fa-users"></i> Nhân sự chi nhánh</a></li>
            </ul>
        </div>

        <!-- Main Content Wrapper -->
        <div class="main-wrapper">

            <!-- Top Header -->
            <div class="top-navbar">
                <h1>Hệ Thống Quản Trị Cửa Hàng (Store Manager Portal)</h1>
                <div class="user-info">
                    <div class="notification-badge" title="Thông báo mới">
                        <i class="fa-regular fa-bell"></i>
                    </div>
                    <div class="user-profile">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.account.username != null ? sessionScope.account.username : 'Manager'}&background=0284c7&color=fff" alt="Avatar">
                        <span>Xin chào, <b>${sessionScope.account.username != null ? sessionScope.account.username : 'Store Manager'}</b></span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </div>

            <!-- Main Container -->
            <div class="container-dashboard">

                <!-- Page Header -->
                <div class="page-header-card">
                    <h2><i class="fa-solid fa-right-left"></i> Quản Lý Điều Chuyển Nhân Sự</h2>
                    <a href="${pageContext.request.contextPath}/store-manager/schedule" class="btn btn-outline-secondary btn-sm">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay về xếp lịch
                    </a>
                </div>

                <!-- Thông báo Thành công / Lỗi chung -->
                <c:if test="${not empty message}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i><c:out value="${message}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${error}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- KHỐI 1: Đề xuất cơ sở của tôi gửi đi -->
                <div class="content-card">
                    <h3 class="section-title"><i class="fa-solid fa-paper-plane"></i> Đề Xuất Cơ Sở Của Tôi Gửi Đi</h3>
                    <div class="table-responsive">
                        <table class="table table-bordered align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 10%;">Mã Đơn</th>
                                    <th style="width: 18%;">Cơ Sở Cho Mượn</th>
                                    <th style="width: 20%;">Vị Trí / Ca Làm</th>
                                    <th style="width: 12%;">Ngày Làm</th>
                                    <th style="width: 10%;">Số Lượng</th>
                                    <th style="width: 15%;">Trạng Thái</th>
                                    <th style="width: 15%;">Lý Do / Nhân Sự</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${outgoingRequests}">
                                    <tr>
                                        <td><strong class="text-primary">#${t.id}</strong></td>
                                        <td><span class="badge bg-secondary"><i class="fa-solid fa-shop me-1"></i> <c:out value="${t.sourceStoreName}"/></span></td>
                                        <td><span class="fw-semibold"><c:out value="${t.positionName}"/></span> / <c:out value="${t.shiftName}"/></td>
                                        <td>${t.workDate}</td>
                                        <td><span class="badge bg-light text-dark border">${t.requestedCount} người</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${t.status eq 'PENDING_MANAGER'}"><span class="badge bg-warning text-dark">Chờ cơ sở cho mượn</span></c:when>
                                                <c:when test="${t.status eq 'PENDING_HR'}"><span class="badge bg-info text-dark">Chờ HR duyệt</span></c:when>
                                                <c:when test="${t.status eq 'APPROVED'}"><span class="badge bg-success">HR đã duyệt</span></c:when>
                                                <c:when test="${t.status eq 'REJECTED_MANAGER'}"><span class="badge bg-danger">Cơ sở từ chối</span></c:when>
                                                <c:when test="${t.status eq 'REJECTED_HR'}"><span class="badge bg-danger">HR từ chối</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary"><c:out value="${t.status}"/></span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:if test="${not empty t.rejectReason}">
                                                <div class="text-danger small mb-1"><i class="fa-solid fa-circle-exclamation me-1"></i><c:out value="${t.rejectReason}"/></div>
                                            </c:if>
                                            <c:forEach var="e" items="${selectedByTransfer[t.id]}">
                                                <div class="small"><i class="fa-solid fa-user text-secondary me-1"></i> <c:out value="${e.fullName}"/></div>
                                            </c:forEach>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty outgoingRequests}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">
                                            <i class="fa-regular fa-folder-open fa-2x mb-2 text-secondary"></i>
                                            <p class="mb-0">Không có yêu cầu điều chuyển nào được gửi đi.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- KHỐI 2: Cơ sở khác yêu cầu chúng tôi cho mượn -->
                <div class="content-card">
                    <h3 class="section-title"><i class="fa-solid fa-handshake-angle"></i> Cơ Sở Khác Yêu Cầu Cho Mượn Nhân Sự</h3>
                    <div class="table-responsive">
                        <table class="table table-bordered align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 15%;">Mã & Cơ Sở Xin</th>
                                    <th style="width: 20%;">Thời Gian / Vị Trí / Ca</th>
                                    <th style="width: 10%;">Số Lượng</th>
                                    <th style="width: 18%;">Lý Do Xin</th>
                                    <th style="width: 15%;">Trạng Thái</th>
                                    <th style="width: 22%;">Nhân Viên Đề Cử & Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${incomingRequests}">
                                    <tr>
                                        <td>
                                            <strong class="text-primary">#${t.id}</strong>
                                            <div class="small text-muted mt-1"><i class="fa-solid fa-shop me-1"></i><c:out value="${t.destinationStoreName}"/></div>
                                        </td>
                                        <td>
                                            <div class="small"><strong>Ngày:</strong> ${t.workDate}</div>
                                            <div class="small"><strong>Vị trí:</strong> <c:out value="${t.positionName}"/></div>
                                            <div class="small"><strong>Ca:</strong> <c:out value="${t.shiftName}"/></div>
                                        </td>
                                        <td><span class="badge bg-primary">${t.requestedCount} người</span></td>
                                        <td><c:out value="${t.reason}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${t.status eq 'PENDING_MANAGER'}"><span class="badge bg-warning text-dark">Chờ xử lý</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary"><c:out value="${t.status}"/></span></c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty t.rejectReason}">
                                                <div class="text-danger small mt-1"><i class="fa-solid fa-circle-exclamation me-1"></i><c:out value="${t.rejectReason}"/></div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${t.status eq 'PENDING_MANAGER'}">
                                                    <!-- Form Phê duyệt & Chọn nhân sự -->
                                                    <form action="${pageContext.request.contextPath}/store-manager/transfer-requests" method="POST" class="mb-2">
                                                        <input type="hidden" name="action" value="approveTransfer">
                                                        <input type="hidden" name="requestId" value="${t.id}">
                                                        
                                                        <label class="form-label small fw-semibold text-secondary mb-1">
                                                            Chọn từ 1 đến ${t.requestedCount} nhân sự hỗ trợ:
                                                        </label>
                                                        
                                                        <div class="border rounded p-2 mb-2 bg-white" style="max-height:180px; overflow-y:auto; font-size: 13px;">
                                                            <c:forEach var="e" items="${eligibleByTransfer[t.id]}">
                                                                <div class="form-check py-1 border-bottom border-light">
                                                                    <input class="form-check-input transfer-person" type="checkbox" name="selectedUserId"
                                                                           value="${e.id}" id="transfer_${t.id}_employee_${e.id}"
                                                                           data-transfer="${t.id}" onchange="updateTransferSelection(${t.id}, ${t.requestedCount})">
                                                                    <label class="form-check-label" for="transfer_${t.id}_employee_${e.id}">
                                                                        <span class="fw-medium"><c:out value="${e.fullName}"/></span> 
                                                                        <span class="text-muted small">(${e.employeeType})</span>
                                                                    </label>
                                                                </div>
                                                            </c:forEach>
                                                            <c:if test="${empty eligibleByTransfer[t.id]}">
                                                                <div class="text-muted small text-center py-2">Không có nhân viên có lịch nháp phù hợp và không xung đột.</div>
                                                            </c:if>
                                                        </div>
                                                        
                                                        <div class="small text-secondary mb-1" id="transfer_count_${t.id}">Đã chọn 0 / <c:out value="${t.requestedCount}"/> người được yêu cầu.</div>
                                                        <div class="small text-danger mb-1" id="transfer_error_${t.id}" aria-live="polite"></div>
                                                        
                                                        <button class="btn btn-success btn-sm w-100 shadow-sm" id="transfer_submit_${t.id}" type="submit" disabled>
                                                            <i class="fa-solid fa-check me-1"></i> Xác nhận và gửi HR
                                                        </button>
                                                    </form>

                                                    <!-- Form Từ chối -->
                                                    <form action="${pageContext.request.contextPath}/store-manager/transfer-requests" method="POST">
                                                        <input type="hidden" name="action" value="rejectTransfer">
                                                        <input type="hidden" name="requestId" value="${t.id}">
                                                        <textarea name="rejectReason" class="form-control form-control-sm mb-2" maxlength="500" placeholder="Lý do từ chối..." required rows="1" style="font-size: 12px;"></textarea>
                                                        <button class="btn btn-outline-danger btn-sm w-100"><i class="fa-solid fa-xmark me-1"></i> Từ chối</button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="e" items="${selectedByTransfer[t.id]}">
                                                        <div class="small"><i class="fa-solid fa-user text-success me-1"></i> <c:out value="${e.fullName}"/></div>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty incomingRequests}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">
                                            <i class="fa-regular fa-folder-open fa-2x mb-2 text-secondary"></i>
                                            <p class="mb-0">Không có yêu cầu mượn nhân sự nào từ cơ sở khác.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>

        <!-- Bootstrap JS Bundle -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
            function updateTransferSelection(id, max) {
                const boxes = document.querySelectorAll('input.transfer-person[data-transfer="' + id + '"]');
                const count = Array.from(boxes).filter(box => box.checked).length;
                document.getElementById('transfer_count_' + id).textContent =
                        'Đã chọn ' + count + ' / ' + max + ' người được yêu cầu.';
                document.getElementById('transfer_error_' + id).textContent =
                        count > max ? 'Không được chọn nhiều hơn số người cơ sở yêu cầu.' : '';
                document.getElementById('transfer_submit_' + id).disabled = !(count >= 1 && count <= max);
            }
        </script>
    </body>
</html>