<%-- 
    Document   : leave-requests
    Created on : Oct 31, 2026
    Author     : DatLT
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Quản lý nghỉ phép - Store Portal</title>
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
            .shift-chip-list {
                display: flex;
                flex-wrap: wrap;
                gap: 4px;
                margin-top: 4px;
            }
            .shift-chip {
                display: inline-block;
                background: #eff6ff;
                border: 1px solid #bfdbfe;
                color: #1e40af;
                border-radius: 6px;
                padding: 2px 8px;
                font-size: 11.5px;
                white-space: nowrap;
            }
            .shift-chip .chip-hours {
                color: #64748b;
                margin-left: 4px;
            }
            .coverage-warning {
                color: #b45309;
                background: #fffbeb;
                border: 1px solid #fde68a;
                border-radius: 6px;
                padding: 4px 8px;
                font-size: 11.5px;
                display: inline-block;
            }
            .type-badge {
                font-size: 11px;
                padding: 2px 7px;
                border-radius: 12px;
                font-weight: 500;
            }
            .type-full {
                background: #dcfce7;
                color: #166534;
            }
            .type-part {
                background: #fef3c7;
                color: #92400e;
            }
            .no-shift {
                font-size: 11.5px;
                color: #94a3b8;
                font-style: italic;
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
                <li><a href="${pageContext.request.contextPath}/store-manager/employees"><i class="fa-solid fa-users-gear"></i> Nhân sự cơ sở</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/recruitment"><i class="fa-solid fa-file-pen"></i> Đề xuất tuyển dụng</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i> Quản lý điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/attendance"><i class="fa-solid fa-clock-rotate-left"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-week"></i> Xếp lịch & Phân ca</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/violations"><i class="fa-solid fa-triangle-exclamation"></i> Báo cáo vi phạm</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/store-manager/leave-requests"><i class="fa-solid fa-plane-departure"></i> Duyệt nghỉ phép</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/shift-requests"><i class="fa-solid fa-rotate"></i> Duyệt đổi ca</a></li>
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
                    <span>Cơ sở hiện tại: <b><c:choose>
                            <c:when test="${not empty currentBranch}">
                                <c:out value="${currentBranch.name}"/> (<c:out value="${currentBranch.code}"/>) - <c:out value="${currentBranch.address}"/>
                            </c:when>
                            <c:otherwise>Không xác định được cơ sở của bạn</c:otherwise>
                        </c:choose></b></span>
                </div>

                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-plane-departure me-2"></i>Quản lý đơn nghỉ phép</h2>
                        <p class="mb-0">Xét duyệt đơn xin nghỉ phép của nhân viên và theo dõi tải trọng nghỉ của chi nhánh.</p>
                    </div>
                    <button class="btn btn-light text-primary fw-semibold shadow-sm px-3 py-2" onclick="history.back()">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </button>
                </div>

                <c:if test="${param.success eq '1'}">
                    <div class="alert alert-success">Thao tác thành công.</div>
                </c:if>

                <c:if test="${param.invalid eq '1'}">
                    <div class="alert alert-warning">Không thể thực hiện. Vui lòng kiểm tra lại trạng thái đơn.</div>
                </c:if>

                <c:if test="${not empty param.warn}">
                    <div class="alert alert-warning">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                        <c:out value="${param.warn}"/>
                        <div class="mt-1 small">Các ca trống đã được đưa vào danh sách ca trống của chi nhánh để nhân viên khác có thể nhận cover.</div>
                    </div>
                </c:if>

                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger"><c:out value="${param.error}"/></div>
                </c:if>

                <c:if test="${not empty param.msg}">
                    <div class="alert alert-info">
                        <i class="fa-solid fa-circle-info"></i>
                        <c:out value="${param.msg}"/>
                    </div>
                </c:if>

                <!-- Tổng hợp thời gian nghỉ theo từng loại -->
                <div class="card shadow-sm mb-4">
                    <div class="card-header fw-semibold">
                        <i class="fa-solid fa-chart-pie text-primary me-2"></i>Tổng thời gian nghỉ theo từng loại
                        <small class="text-muted fw-normal" style="font-size: 13px;">
                            &middot; năm <%= java.time.LocalDate.now().getYear() %>
                        </small>
                    </div>
                    <div class="card-body p-4">
                        <div class="row g-3 mb-3">
                            <div class="col-md-4">
                                <div class="alert alert-secondary mb-0 py-2">
                                    <i class="fa-solid fa-clock"></i>
                                    <strong>Tổng thời gian nghỉ của chi nhánh:</strong>
                                    <span style="font-size: 18px;"><c:out value="${branchTotalHours}"/></span> giờ
                                </div>
                            </div>
                        </div>

                        <p class="text-muted" style="font-size: 13px;">
                            <i class="fa-solid fa-circle-info"></i>
                            <strong>Tổng</strong> = thời gian nghỉ đã duyệt + thời gian nghỉ đang chờ duyệt. Giúp Store Manager nắm được tải trọng nghỉ phép sắp tới của từng loại trước khi duyệt.
                        </p>

                        <div class="table-responsive">
                            <table class="table table-bordered table-hover mb-0 align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>Loại nghỉ phép</th>
                                        <th>Có lương</th>
                                        <th>Đã duyệt (giờ)</th>
                                        <th>Chờ duyệt (giờ)</th>
                                        <th>Tổng (giờ)</th>
                                        <th>Số đơn</th>
                                        <th>Số NV</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="s" items="${leaveSummary}">
                                        <tr>
                                            <td>
                                                <c:out value="${s.leaveTypeName}"/>
                                                <small class="text-muted">(<c:out value="${s.leaveTypeCode}"/>)</small>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${s.paidLeave}">
                                                        <span class="badge bg-success">Có</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">Không</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${s.approvedHours}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${s.pendingHours gt 0}">
                                                        <span class="badge bg-warning text-dark"><c:out value="${s.pendingHours}"/></span>
                                                    </c:when>
                                                    <c:otherwise>0</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><strong><c:out value="${s.totalHours}"/></strong></td>
                                            <td><c:out value="${s.requestCount}"/></td>
                                            <td><c:out value="${s.employeeCount}"/></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty leaveSummary}">
                                        <tr>
                                            <td colspan="7" class="text-center text-muted py-4">Chi nhánh chưa có đơn nghỉ phép nào trong năm.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>

                        <c:if test="${not empty shiftDefinitions}">
                            <hr class="my-4">
                            <strong class="d-block mb-2">
                                <i class="fa-solid fa-clock text-primary"></i> Định nghĩa các ca làm việc
                            </strong>
                            <div class="table-responsive">
                                <table class="table table-sm table-bordered mb-0 align-middle" style="font-size: 13px;">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Ca</th>
                                            <th>Khung giờ</th>
                                            <th>Thời lượng</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="sd" items="${shiftDefinitions}">
                                            <tr>
                                                <td><c:out value="${sd.shiftName}"/></td>
                                                <td><c:out value="${sd.startTime}"/> &ndash; <c:out value="${sd.endTime}"/></td>
                                                <td><strong><c:out value="${sd.hours}"/></strong> giờ</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Danh sách đơn nghỉ phép -->
                <div class="card shadow-sm">
                    <div class="card-header fw-semibold">
                        <i class="fa-solid fa-list-check text-primary me-2"></i>Danh sách đơn nghỉ phép của chi nhánh
                    </div>
                    <div class="card-body p-4">
                        <p class="text-muted mb-4" style="font-size: 13px;">
                            Quota nghỉ phép được tính theo <strong>giờ làm việc</strong>. Mỗi đơn gắn với các <strong>ca cụ thể</strong> bị ảnh hưởng - khi duyệt, các ca đó sẽ được chuyển sang ca trống để tìm người cover.
                        </p>

                        <div class="table-responsive">
                            <table class="table table-bordered table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>ID</th>
                                        <th>Nhân viên</th>
                                        <th>Loại nghỉ</th>
                                        <th>Từ ngày</th>
                                        <th>Đến ngày</th>
                                        <th>Thời lượng</th>
                                        <th>Ca bị nghỉ</th>
                                        <th>Lý do</th>
                                        <th>Trạng thái</th>
                                        <th>Phản hồi</th>
                                        <th>Ngày tạo</th>
                                        <th>Xử lý</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${requestList}">
                                        <tr>
                                            <td>${r.id}</td>
                                            <td>
                                                <c:out value="${r.userName}"/><br>
                                                <c:choose>
                                                    <c:when test="${r.employeeType eq 'PART_TIME'}">
                                                        <span class="type-badge type-part">Part-time</span>
                                                    </c:when>
                                                    <c:when test="${r.employeeType eq 'CASUAL'}">
                                                        <span class="type-badge type-part">Casual</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="type-badge type-full">Full-time</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:out value="${r.leaveTypeName}"/>
                                                <small class="text-muted">(<c:out value="${r.leaveTypeCode}"/>)</small>
                                            </td>
                                            <td><c:out value="${r.startDate}"/></td>
                                            <td><c:out value="${r.endDate}"/></td>
                                            <td>
                                                <strong><c:out value="${r.totalHours}"/> giờ</strong>
                                                <c:if test="${r.totalDays gt 0}">
                                                    <br><small class="text-muted">(<c:out value="${r.totalDays}"/> ngày)</small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.shiftCount gt 0}">
                                                        <div class="shift-chip-list">
                                                            <c:forEach var="s" items="${r.shiftDetails}">
                                                                <span class="shift-chip">
                                                                    <c:out value="${s.workDate}"/> &middot; <c:out value="${s.shiftName}"/>
                                                                    <span class="chip-hours"><c:out value="${s.hours}"/>h</span>
                                                                </span>
                                                            </c:forEach>
                                                        </div>
                                                        <c:if test="${r.hasCoverageWarning}">
                                                            <div class="coverage-warning mt-1">
                                                                <i class="fa-solid fa-triangle-exclamation"></i> Cần tìm người cover: <strong><c:out value="${r.coverageWarningCount}"/></strong> ca sẽ thiếu người
                                                            </div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="no-shift">Theo ngày (chưa có lịch chi tiết)</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><c:out value="${r.reason}"/></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.status eq 'PENDING'}">
                                                        <span class="badge bg-warning text-dark">Chờ duyệt</span>
                                                    </c:when>
                                                    <c:when test="${r.status eq 'APPROVED'}">
                                                        <span class="badge bg-success">Đã duyệt</span>
                                                    </c:when>
                                                    <c:when test="${r.status eq 'REJECTED'}">
                                                        <span class="badge bg-danger">Từ chối</span>
                                                    </c:when>
                                                    <c:when test="${r.status eq 'CANCELLED'}">
                                                        <span class="badge bg-secondary">Đã hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-light text-dark"><c:out value="${r.status}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:if test="${not empty r.managerResponse}">
                                                    <c:out value="${r.managerResponse}"/>
                                                </c:if>
                                            </td>
                                            <td><c:out value="${r.createdAt}"/></td>
                                            <td>
                                                <c:if test="${r.status eq 'PENDING'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/store-manager/leave-requests">
                                                        <input type="hidden" name="requestId" value="${r.id}">
                                                        <input type="text" name="response" maxlength="255" class="form-control form-control-sm mb-2" placeholder="Ghi chú (tùy chọn)">
                                                        <button name="action" value="approve" type="submit" class="btn btn-success btn-sm mb-1 w-100">Duyệt</button>
                                                        <button name="action" value="reject" type="submit" class="btn btn-danger btn-sm mb-1 w-100">Từ chối</button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${r.status eq 'APPROVED'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/store-manager/leave-requests" onsubmit="return confirm('Thu hồi đơn này?\n\nQuota sẽ được hoàn lại, các ca bị nghỉ sẽ được mở lại và ca trống tương ứng sẽ được đóng.\n\nBạn có chắc chắn không?');">
                                                        <input type="hidden" name="requestId" value="${r.id}">
                                                        <input type="text" name="response" maxlength="255" class="form-control form-control-sm mb-2" placeholder="Lý do thu hồi">
                                                        <button name="action" value="revoke" type="submit" class="btn btn-warning btn-sm mb-1 w-100">
                                                            <i class="fa-solid fa-rotate-left"></i> Thu hồi
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty requestList}">
                                        <tr>
                                            <td colspan="12" class="text-center text-secondary py-4">Chưa có đơn nghỉ phép nào.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>