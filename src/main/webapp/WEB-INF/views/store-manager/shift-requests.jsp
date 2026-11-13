<%-- 
    Document   : shift-requests
    Created on : Oct 31, 2026
    Author     : phong
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Quản lý đổi ca - Store Portal</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                margin: 0;
                font-family: 'Roboto', sans-serif;
                background: #f4f7f6;
                color: #333;
                display: flex;
                min-height: 100vh;
            }
            .sidebar {
                width: 260px;
                background: #1e293b;
                color: #94a3b8;
                display: flex;
                flex-direction: column;
                position: fixed;
                inset: 0 auto 0 0;
                z-index: 100;
                box-shadow: 2px 0 10px rgba(0,0,0,.1);
            }
            .sidebar-brand {
                padding: 25px 20px;
                font-size: 18px;
                font-weight: 700;
                color: #fff;
                background: #0f172a;
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
                margin: 0;
                overflow-y: auto;
            }
            .sidebar-menu a {
                display: flex;
                align-items: center;
                gap: 15px;
                padding: 14px 25px;
                color: #94a3b8;
                text-decoration: none;
                font-size: 14px;
                font-weight: 500;
                border-left: 4px solid transparent;
            }
            .sidebar-menu a:hover, .sidebar-menu .active a {
                color: #fff;
                background: rgba(255,255,255,.05);
                border-left-color: #38bdf8;
            }
            .sidebar-menu i {
                width: 20px;
                text-align: center;
            }
            .main-wrapper {
                margin-left: 260px;
                flex: 1;
                min-width: 0;
                display: flex;
                flex-direction: column;
            }
            .top-navbar {
                background: #fff;
                color: #1e293b;
                padding: 15px 35px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 20px;
                box-shadow: 0 1px 3px rgba(0,0,0,.05);
                position: sticky;
                top: 0;
                z-index: 99;
            }
            .top-navbar h1 {
                margin: 0;
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
            .btn-logout {
                color: #ef4444;
                text-decoration: none;
                background: #ffeeef;
                padding: 6px 14px;
                border-radius: 6px;
                font-weight: 500;
                font-size: 13px;
                white-space: nowrap;
            }
            .page-content {
                max-width: 1400px;
                margin: 30px;
            }
            .branch-info-bar {
                background-color: #eef2ff;
                border: 1px solid #c7d2fe;
                color: #3730a3;
                padding: 12px 20px;
                border-radius: 8px;
                font-size: 14px;
                margin-bottom: 25px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-weight: 500;
            }
            .branch-info-bar i {
                color: #2563eb;
                font-size: 16px;
            }
            .page-title {
                background: linear-gradient(135deg,#2563eb,#1d4ed8);
                color: #fff;
                padding: 25px 30px;
                border-radius: 12px;
                margin-bottom: 25px;
                box-shadow: 0 10px 15px -3px rgba(37,99,235,.2);
            }
            .page-title h2 {
                margin: 0 0 8px;
                font-size: 24px;
            }
            .page-title p {
                margin: 0;
                opacity: .9;
            }
            .card {
                border: 0;
                border-radius: 10px;
            }
            .card-header {
                background: #fff;
                padding: 16px 20px;
            }
            @media (max-width: 900px) {
                .sidebar {
                    width: 220px;
                }
                .main-wrapper {
                    margin-left: 220px;
                }
                .top-navbar {
                    padding: 14px 20px;
                }
                .page-content {
                    margin: 20px;
                }
            }
            @media (max-width: 650px) {
                body {
                    display: block;
                }
                .sidebar {
                    position: static;
                    width: 100%;
                }
                .sidebar-menu {
                    display: flex;
                    overflow-x: auto;
                    padding: 5px 0;
                }
                .sidebar-menu li {
                    flex: 0 0 auto;
                }
                .sidebar-menu a {
                    padding: 12px;
                }
                .main-wrapper {
                    margin-left: 0;
                }
                .top-navbar {
                    position: static;
                    flex-wrap: wrap;
                }
                .page-content {
                    margin: 15px;
                }
            }
        </style>
    </head>

    <body>

        <!-- Sidebar Điều Hướng Trái (Store Manager) -->
        <aside class="sidebar">
            <div class="sidebar-brand">
                <i class="fa-solid fa-store"></i>
                <span>Store Manager</span>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/store-manager/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/employees"><i class="fa-solid fa-users-gear"></i> Quản lí nhân sự cơ sở</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/recruitment"><i class="fa-solid fa-file-pen"></i> Đề xuất tuyển dụng/tiếp nhận</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i> Quản lý điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/attendance"><i class="fa-solid fa-clock-rotate-left"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-week"></i> Xếp lịch & Phân ca</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/violations"><i class="fa-solid fa-triangle-exclamation"></i> Báo cáo vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/director/reports"><i class="fa-solid fa-chart-pie"></i> Báo cáo chi nhánh</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/leave-requests"><i class="fa-solid fa-plane-departure"></i> Duyệt nghỉ phép</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/store-manager/shift-requests"><i class="fa-solid fa-rotate"></i> Duyệt đổi ca</a></li>
            </ul>
        </aside>

        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Chi Nhánh Trực Thuộc</h1>
                <div class="user-info">
                    <span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a>
                </div>
            </header>

            <main class="page-content">
                <!-- Thanh hiển thị Cơ sở hiện tại -->
                <div class="branch-info-bar">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>Cơ sở hiện tại: <strong>
                            <c:out value="${displayBranchInfo}"
                                   default="Không xác định được cơ sở của bạn"/>
                        </strong></span>
                </div>

                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-rotate me-2"></i>Quản lý ca thiếu &amp; duyệt đổi ca</h2>
                        <p class="mb-0">Tạo, đóng ca thiếu và xử lý yêu cầu nhận ca / đổi ca của nhân viên.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/store-manager/dashboard" class="btn btn-outline-light btn-dashboard px-3 py-2">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay về Dashboard
                    </a>
                </div>

                <c:if test="${param.success eq '1'}">
                    <div class="alert alert-success">Đã xử lý yêu cầu thành công.</div>
                </c:if>
                <c:if test="${param.openCreated eq '1'}">
                    <div class="alert alert-success">Đã tạo ca thiếu thành công.</div>
                </c:if>
                <c:if test="${param.openClosed eq '1'}">
                    <div class="alert alert-success">Đã đóng ca thiếu thành công.</div>
                </c:if>
                <c:if test="${param.invalid eq '1'}">
                    <div class="alert alert-warning">
                        Không thể thực hiện. Vui lòng kiểm tra dữ liệu và trạng thái hiện tại.
                        <c:if test="${param.reason eq 'missing'}">
                            <div class="small">Vui lòng chọn đầy đủ ca, vị trí và ngày làm việc.</div>
                        </c:if>
                        <c:if test="${param.reason eq 'date'}">
                            <div class="small">Ngày làm việc không hợp lệ.</div>
                        </c:if>
                    </div>
                </c:if>

                <section class="card shadow-sm mb-4">
                    <div class="card-header fw-semibold">
                        <i class="fa-solid fa-inbox text-primary me-2"></i>Quản lý ca thiếu
                    </div>
                    <div class="card-body p-4">
                        <p class="text-muted small">Ca thiếu là ca chưa có đủ người làm. Nhân viên phù hợp có thể đăng ký nhận ca.</p>
                        <form method="post" action="${pageContext.request.contextPath}/store-manager/shift-requests" class="row g-3 align-items-end mb-4">
                            <input type="hidden" name="action" value="createOpenShift">
                            <div class="col-md-4">
                                <label class="form-label">Ca làm việc</label>
                                <select name="shiftId" class="form-select" required>
                                    <option value="">-- Chọn ca --</option>
                                    <c:forEach var="s" items="${allShifts}">
                                        <option value="${s.id}"><c:out value="${s.name}"/> (<c:out value="${s.startTime}"/> - <c:out value="${s.endTime}"/>)</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Vị trí công tác</label>
                                <select name="positionId" class="form-select" required>
                                    <option value="">-- Chọn vị trí --</option>
                                    <c:forEach var="p" items="${allPositions}">
                                        <option value="${p.id}"><c:out value="${p.title}"/></option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Ngày làm việc</label>
                                <input type="date" name="workDate" class="form-control" min="<%= java.time.LocalDate.now() %>" required>
                            </div>
                            <div class="col-md-2">
                                <button type="submit" class="btn btn-primary w-100"><i class="fa-solid fa-plus me-1"></i>Tạo ca</button>
                            </div>
                        </form>
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover align-middle">
                                <thead class="table-light"><tr><th>ID</th><th>Ngày</th><th>Ca</th><th>Vị trí</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
                                <tbody>
                                    <c:forEach var="os" items="${openShiftList}">
                                        <tr>
                                            <td><c:out value="${os.id}"/></td>
                                            <td><c:out value="${os.workDate}"/></td>
                                            <td><c:out value="${os.shiftName}"/></td>
                                            <td><c:out value="${os.positionTitle}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${os.status eq 'OPEN'}"><span class="badge bg-success">Đang mở</span></c:when>
                                                    <c:otherwise><span class="badge bg-secondary">Đã đóng</span></c:otherwise>
                                                </c:choose>
                                                <c:if test="${os.status eq 'OPEN' and os.past eq '1'}">
                                                    <div class="small text-warning">Đã qua ngày làm việc</div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:if test="${os.status eq 'OPEN'}">
                                                    <c:choose>
                                                        <c:when test="${not empty os.leaveRequestId}">
                                                            <span class="text-muted small">Từ đơn nghỉ phép</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form method="post" action="${pageContext.request.contextPath}/store-manager/shift-requests" onsubmit="return confirm('Bạn muốn đóng ca thiếu này?');">
                                                                <input type="hidden" name="action" value="closeOpenShift">
                                                                <input type="hidden" name="openShiftId" value="${os.id}">
                                                                <button type="submit" class="btn btn-outline-danger btn-sm">Đóng</button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty openShiftList}">
                                        <tr><td colspan="6" class="text-center text-muted py-3">Chưa có ca thiếu nào.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <section class="card shadow-sm mb-4">
                    <div class="card-header fw-semibold"><i class="fa-solid fa-list-check text-primary me-2"></i>Danh sách yêu cầu đổi / nhận ca</div>
                    <div class="card-body p-4">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover align-middle">
                                <thead class="table-light">
                                    <tr><th>ID</th><th>Nhân viên</th><th>Loại yêu cầu</th><th>Ca hiện tại</th><th>Ca mong muốn</th><th>Đồng nghiệp</th><th>Lý do</th><th>Trạng thái</th><th>Thao tác</th></tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${requestList}">
                                        <tr>
                                            <td><c:out value="${r.id}"/></td>
                                            <td><c:out value="${r.employeeName}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.requestType eq 'SWAP'}"><span class="badge bg-info text-dark">Đổi với đồng nghiệp</span></c:when>
                                                    <c:when test="${r.requestType eq 'EXTRA'}"><span class="badge bg-success">Nhận thêm ca</span></c:when>
                                                    <c:otherwise><span class="badge bg-primary">Chuyển sang ca thiếu</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.requestType eq 'EXTRA'}"><span class="text-muted small">Giữ nguyên lịch hiện tại</span></c:when>
                                                    <c:otherwise><c:out value="${r.myDate}"/> - <c:out value="${r.myShift}"/></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${r.targetDate}"/> - <c:out value="${r.targetShift}"/></td>
                                            <td><c:out value="${r.colleagueName}"/></td>
                                            <td><c:out value="${r.reason}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.status eq 'WAITING_COLLEAGUE'}"><span class="badge bg-warning text-dark">Chờ đồng nghiệp</span></c:when>
                                                    <c:when test="${r.status eq 'PENDING'}"><span class="badge bg-warning text-dark">Chờ duyệt</span></c:when>
                                                    <c:when test="${r.status eq 'APPROVED'}"><span class="badge bg-success">Đã duyệt</span></c:when>
                                                    <c:when test="${r.status eq 'REJECTED'}"><span class="badge bg-danger">Bị từ chối</span></c:when>
                                                    <c:when test="${r.status eq 'DECLINED'}"><span class="badge bg-danger">Đồng nghiệp từ chối</span></c:when>
                                                    <c:when test="${r.status eq 'CANCELLED'}"><span class="badge bg-secondary">Đã hủy</span></c:when>
                                                    <c:otherwise><span class="badge bg-light text-dark"><c:out value="${r.status}"/></span></c:otherwise>
                                                </c:choose>
                                                <c:if test="${not empty r.response}"><div class="small text-muted"><c:out value="${r.response}"/></div></c:if>
                                                </td>
                                                <td>
                                                <c:if test="${r.status eq 'PENDING'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/store-manager/shift-requests">
                                                        <input type="hidden" name="requestId" value="${r.id}">
                                                        <input type="text" name="response" maxlength="255" class="form-control form-control-sm mb-2" placeholder="Ghi chú">
                                                        <button type="submit" name="action" value="approve" class="btn btn-success btn-sm mb-1">Duyệt</button>
                                                        <button type="submit" name="action" value="reject" class="btn btn-danger btn-sm mb-1">Từ chối</button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty requestList}">
                                        <tr><td colspan="9" class="text-center text-muted py-4">Chưa có yêu cầu đổi / nhận ca.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
            </main>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/js/sidebar.js"></script>
    </body>
</html>
