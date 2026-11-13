<%-- 
    Document   : recruitment
    Created on : Oct 27, 2026, 10:18:16 PM
    Author     : Lenovo
--%>

<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- Flash data after POST -> redirect: preserve once for this render, then remove session data --%>
<c:if test="${not empty sessionScope.hireError}">
    <c:set var="hireError" value="${sessionScope.hireError}" scope="request"/>
    <c:set var="hireRequestId" value="${sessionScope.hireRequestId}" scope="request"/>
    <c:set var="hireFullName" value="${sessionScope.hireFullName}" scope="request"/>
    <c:set var="hirePhone" value="${sessionScope.hirePhone}" scope="request"/>
    <c:set var="hireIdentityCard" value="${sessionScope.hireIdentityCard}" scope="request"/>
    <c:set var="hireEmail" value="${sessionScope.hireEmail}" scope="request"/>
    <c:set var="hireExpirationDate" value="${sessionScope.hireExpirationDate}" scope="request"/>
    <c:if test="${empty requestScope.hireContractType}">
        <c:set var="hireContractType" value="${sessionScope.hireContractType}" scope="request"/>
    </c:if>
    <c:remove var="hireError" scope="session"/>
    <c:remove var="hireRequestId" scope="session"/>
    <c:remove var="hireFullName" scope="session"/>
    <c:remove var="hirePhone" scope="session"/>
    <c:remove var="hireIdentityCard" scope="session"/>
    <c:remove var="hireEmail" scope="session"/>
    <c:remove var="hireExpirationDate" scope="session"/>
    <c:remove var="hireContractType" scope="session"/>
</c:if>
<c:if test="${sessionScope.createRecruitmentSuccess eq true}">
    <c:set var="createRecruitmentSuccess" value="${sessionScope.createRecruitmentSuccess}" scope="request"/>
    <c:set var="createdEmployeeUsername" value="${sessionScope.createdEmployeeUsername}" scope="request"/>
    <c:set var="createdEmployeeFullName" value="${sessionScope.createdEmployeeFullName}" scope="request"/>
    <c:remove var="createRecruitmentSuccess" scope="session"/>
    <c:remove var="createdEmployeeUsername" scope="session"/>
    <c:remove var="createdEmployeeFullName" scope="session"/>
</c:if>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Phê duyệt đề xuất tiếp nhận nhân sự - HR Management</title>
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
            .page-title {
                background: linear-gradient(135deg,#0284c7,#0369a1);
                color: #fff;
                padding: 25px 30px;
                border-radius: 12px;
                margin-bottom: 25px;
                box-shadow: 0 10px 15px -3px rgba(2,132,199,.2);
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

            /* Modal thêm nhân viên - luôn giữ footer trong màn hình */
            .hire-dialog {
                margin-top: 16px;
                margin-bottom: 16px;
            }

            .hire-dialog .modal-content {
                max-height: calc(100dvh - 32px);
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }

            .hire-dialog .modal-body {
                overflow-y: auto;
                min-height: 0;
                flex: 1 1 auto;
            }

            .hire-dialog .modal-header,
            .hire-dialog .modal-footer {
                flex-shrink: 0;
            }

        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fa-solid fa-user-tie"></i><span>HR Management</span></div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/hr/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/hr/recruitment"><i class="fa-solid fa-user-plus"></i> Phê duyệt đề xuất</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/transfer-requests"><i class="fa-solid fa-right-left"></i> Phê duyệt điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/employee-list"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Quản lý vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/branch-request"><i class="fa-solid fa-store"></i>Yêu cầu mở chi nhánh</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/payroll"><i class="fa-solid fa-money-bill-wave"></i> Tính lương</a></li>
                <li><a href="${pageContext.request.contextPath}/director/reports"><i class="fa-solid fa-chart-pie"></i> Báo cáo toàn chuỗi</a></li>
            </ul>
        </aside>

        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Trị Nhân Sự Toàn Hệ Thống (HR Portal)</h1>
                <div class="user-info">
                    <span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a>
                </div>
            </header>

            <main class="page-content">
                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-user-plus me-2"></i>Quản lý đề xuất tiếp nhận / tuyển dụng</h2>
                        <p class="mb-0">Xem xét hồ sơ tiếp nhận ứng viên và nhu cầu tuyển thêm nhân sự từ các cơ sở.</p>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/hr/dashboard" class="btn btn-outline-light px-3 py-2 fw-semibold">
                            <i class="fa-solid fa-arrow-left me-1"></i> Dashboard
                        </a>
                    </div>
                </div>

                <c:if test="${param.type eq 'hiring' and param.msg eq 'approved'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">Đã phê duyệt nhu cầu tuyển dụng.<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button></div>
                    </c:if>
                    <c:if test="${param.type eq 'hiring' and param.msg eq 'rejected'}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">Đã từ chối nhu cầu tuyển dụng.<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button></div>
                    </c:if>
                    <c:if test="${param.type eq 'hiring' and param.err eq 'review'}">
                    <div class="alert alert-warning">Không xử lý được đề xuất. Có thể đề xuất đã được duyệt hoặc từ chối trước đó.</div>
                </c:if>
                <c:if test="${param.type ne 'hiring' and param.msg eq 'rejected'}">
                    <div class="alert alert-success">Đã từ chối đề xuất tiếp nhận nhân sự.</div>
                </c:if>

                <div class="d-flex flex-wrap align-items-center gap-2 mb-3">
                    <a href="#hiring-requests" class="btn btn-outline-primary btn-sm"><i class="fa-solid fa-users me-1"></i>Nhu cầu tuyển dụng</a>
                    <a href="#intake-proposals" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-address-card me-1"></i>Tiếp nhận ứng viên</a>
                </div>


                <!-- THÔNG BÁO CẤP TÀI KHOẢN THÀNH CÔNG -->
                <c:if test="${requestScope.createRecruitmentSuccess eq true}">

                    <div class="alert alert-success shadow-sm mb-4">

                        <h5 class="fw-bold mb-3">
                            <i class="fa-solid fa-circle-check me-2"></i>
                            Cấp tài khoản nhân viên thành công!
                        </h5>

                        <p>
                            Đã tạo tài khoản cho nhân viên
                            <strong>
                                <c:out value="${requestScope.createdEmployeeFullName}"/>
                            </strong>
                            và phân về chi nhánh theo đề xuất tuyển dụng.
                        </p>

                        <div class="bg-white border rounded p-3">

                            <p class="mb-2">
                                <strong>Tên đăng nhập:</strong>
                                <span class="text-primary fw-bold">
                                    <c:out value="${requestScope.createdEmployeeUsername}"/>
                                </span>
                            </p>

                            <p class="mb-2">
                                <strong>Mật khẩu mặc định:</strong>
                                <code>123456</code>
                            </p>

                            <p class="small text-muted mb-0">
                                HR bàn giao thông tin đăng nhập trực tiếp cho nhân viên.
                                Nhân viên cần đổi mật khẩu khi đăng nhập lần đầu.
                            </p>

                        </div>
                    </div>

                </c:if>

                <!-- Tabs lọc nhanh áp dụng cho cả hai loại đề xuất -->
                <ul class="nav nav-pills mb-4">
                    <li class="nav-item me-2">
                        <a class="nav-link ${filter == 'pending' ? 'active' : 'bg-white text-dark shadow-sm'}" 
                           href="?filter=pending&branchId=${branchId}&positionId=${positionId}&employmentType=${employmentType}&status=${status}">
                            Đang chờ duyệt
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${filter == 'all' ? 'active' : 'bg-white text-dark shadow-sm'}" 
                           href="?filter=all&branchId=${branchId}&positionId=${positionId}&employmentType=${employmentType}&status=${status}">
                            Tất cả
                        </a>
                    </li>
                </ul>

                <!-- Form Lọc -->
                <div class="card shadow-sm mb-4">
                    <div class="card-header fw-semibold"><i class="fa-solid fa-filter text-primary me-2"></i>Bộ lọc tìm kiếm</div>
                    <div class="card-body">
                        <form method="get" action="${pageContext.request.contextPath}/hr/recruitment">
                            <input type="hidden" name="filter" value="${filter}">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label for="branchId" class="form-label">📍 Chi nhánh</label>
                                    <select id="branchId" name="branchId" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="b" items="${branches}">
                                            <option value="${b.id}" ${branchId == b.id ? 'selected' : ''}>${b.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label for="positionId" class="form-label">📌 Vị trí</label>
                                    <select id="positionId" name="positionId" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <c:forEach var="p" items="${positions}">
                                            <option value="${p.id}" ${positionId == p.id ? 'selected' : ''}>${p.title}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="employmentType" class="form-label">🕒 Hình thức</label>
                                    <select id="employmentType" name="employmentType" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <option value="FULL_TIME" ${employmentType == 'FULL_TIME' ? 'selected' : ''}>Toàn thời gian</option>
                                        <option value="PART_TIME" ${employmentType == 'PART_TIME' ? 'selected' : ''}>Bán thời gian</option>
                                        <!--<option value="CASUAL" ${employmentType == 'CASUAL' ? 'selected' : ''}>Thời vụ</option>-->
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label for="status" class="form-label">📊 Trạng thái</label>
                                    <select id="status" name="status" class="form-select">
                                        <option value="">-- Tất cả --</option>
                                        <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>PENDING</option>
                                        <option value="APPROVED" ${status == 'APPROVED' ? 'selected' : ''}>APPROVED</option>
                                        <option value="REJECTED" ${status == 'REJECTED' ? 'selected' : ''}>REJECTED</option>
                                    </select>
                                </div>
                                <div class="col-md-2 d-flex align-items-end gap-2">
                                    <button type="submit" class="btn btn-primary w-100"><i class="fa-solid fa-magnifying-glass me-1"></i> Lọc</button>
                                    <a href="${pageContext.request.contextPath}/hr/recruitment?filter=${filter}" class="btn btn-outline-secondary" title="Xóa lọc"><i class="fa-solid fa-rotate-right"></i></a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Bảng danh sách đề xuất tiếp nhận ứng viên -->
                <div id="intake-proposals" class="card shadow-sm">
                    <div class="card-header fw-semibold"><i class="fa-solid fa-address-card text-primary me-2"></i>Đề xuất tiếp nhận ứng viên</div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Ngày tạo</th>
                                    <th>Chi nhánh</th>
                                    <th>Ứng viên đề xuất</th>
                                    <th>Vị trí</th>
                                    <th>Hình thức</th>
                                    <th>Người đề xuất</th>
                                    <th>Trạng thái</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rp" items="${proposals}">
                                    <tr>
                                        <td><fmt:formatDate value="${rp.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td><c:out value="${rp.branchName}"/></td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/hr/recruitment?id=${rp.id}" class="text-decoration-none fw-bold text-primary">
                                                <c:out value="${rp.candidate.fullName}"/>
                                            </a>
                                        </td>
                                        <td><c:out value="${rp.positionTitle}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rp.employmentType == 'FULL_TIME'}">Toàn thời gian</c:when>
                                                <c:when test="${rp.employmentType == 'PART_TIME'}">Bán thời gian</c:when>
                                                <c:when test="${rp.employmentType == 'CASUAL'}">Thời vụ</c:when>
                                                <c:otherwise><c:out value="${rp.employmentType}"/></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${rp.createdByName}"/></td>
                                        <td>
                                            <span class="badge bg-${rp.status == 'APPROVED' ? 'success' : (rp.status == 'REJECTED' ? 'danger' : 'warning text-dark')}">
                                                <c:out value="${rp.status}"/>
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/hr/recruitment?id=${rp.id}">
                                                <i class="fa-solid fa-eye me-1"></i> Chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty proposals}">
                                    <tr>
                                        <td colspan="8" class="text-center text-secondary py-4">
                                            <div class="py-3">
                                                <i class="fa-solid fa-folder-open fs-2 mb-2 text-muted"></i>
                                                <p class="mb-0">Không có đề xuất nào. Thử thay đổi bộ lọc hoặc chuyển sang tab khác.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>


                <!-- Đề xuất tuyển dụng theo nhu cầu, độc lập với đề xuất tiếp nhận -->
                <div id="hiring-requests" class="card shadow-sm mt-4">
                    <div class="card-header d-flex align-items-center justify-content-between gap-2 flex-wrap">
                        <span class="fw-semibold"><i class="fa-solid fa-people-group text-primary me-2"></i>Đề xuất tuyển dụng theo nhu cầu</span>
                        <span class="small text-muted">Phê duyệt nhu cầu không tự động tạo tài khoản nhân viên</span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Ngày tạo</th>
                                    <th>Chi nhánh</th>
                                    <th>Vị trí</th>
                                    <th class="text-center">Số lượng</th>
                                    <th>Hình thức / Ca</th>
                                    <th>Ngày cần</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                    <th>Ghi chú HR</th>
                                    <th class="text-center">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rr" items="${recruitmentRequests}">
                                    <tr>
                                        <td class="text-nowrap"><fmt:formatDate value="${rr.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td><c:out value="${rr.branchName}"/></td>
                                        <td class="fw-semibold"><c:out value="${rr.positionTitle}"/></td>
                                        <td class="text-center"><span class="badge bg-primary"><c:out value="${rr.quantity}"/> người</span></td>
                                        <td><span class="badge bg-info text-dark"><c:out value="${rr.employmentType}"/></span>
                                            <div class="small text-muted mt-1"><c:out value="${rr.shiftType}"/></div></td>
                                        <td class="text-nowrap"><c:out value="${rr.targetDate}"/></td>
                                        <td style="min-width:150px;max-width:260px;white-space:normal;overflow-wrap:anywhere;"><c:out value="${rr.reason}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${rr.status eq 'PENDING'}"><span class="badge bg-warning text-dark">Chờ duyệt</span></c:when>
                                                <c:when test="${rr.status eq 'APPROVED'}"><span class="badge bg-success">Đã duyệt</span></c:when>
                                                <c:when test="${rr.status eq 'REJECTED'}"><span class="badge bg-danger">Từ chối</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary"><c:out value="${rr.status}"/></span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small text-muted"><c:out value="${empty rr.hrNote ? '---' : rr.hrNote}"/></td>
                                        <td class="text-center text-nowrap">
                                            <c:if test="${rr.status eq 'PENDING'}">
                                                <button type="button" class="btn btn-sm btn-outline-success mb-1" data-bs-toggle="modal" data-bs-target="#hiringReviewModal" data-review-action="approveRecruitmentRequest" data-request-id="${rr.id}" data-position="<c:out value='${rr.positionTitle}'/>" aria-label="Duyệt đề xuất tuyển dụng"><i class="fa-solid fa-check me-1"></i>Duyệt</button>
                                                <button type="button" class="btn btn-sm btn-outline-danger mb-1" data-bs-toggle="modal" data-bs-target="#hiringReviewModal" data-review-action="rejectRecruitmentRequest" data-request-id="${rr.id}" data-position="<c:out value='${rr.positionTitle}'/>" aria-label="Từ chối đề xuất tuyển dụng"><i class="fa-solid fa-xmark me-1"></i>Từ chối</button>
                                            </c:if>

                                            <c:if test="${rr.status eq 'APPROVED'}">
                                                <button type="button"
                                                        class="btn btn-sm btn-outline-success"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#hireModal${rr.id}">
                                                    <i class="fa-solid fa-user-plus me-1"></i>
                                                    Thêm nhân viên
                                                </button>
                                            </c:if>

                                            <c:if test="${rr.status eq 'REJECTED'}">
                                                <span class="text-muted small">Đã từ chối</span>
                                            </c:if>

                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recruitmentRequests}">
                                    <tr><td colspan="10" class="text-center text-muted py-4">Chưa có đề xuất tuyển dụng nào từ các chi nhánh.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <c:forEach var="rr" items="${recruitmentRequests}">
                    <c:if test="${rr.status eq 'APPROVED'}">

                        <div class="modal fade"
                             id="hireModal${rr.id}"
                             tabindex="-1">
                            <div class="modal-dialog modal-lg modal-dialog-scrollable hire-dialog">
                                <div class="modal-content">

                                    <form method="post"
                                          action="${pageContext.request.contextPath}/hr/create-user">

                                        <input type="hidden"
                                               name="recruitmentRequestId"
                                               value="${rr.id}">

                                        <div class="modal-header">
                                            <h5 class="modal-title text-primary">
                                                <i class="fa-solid fa-user-plus me-2"></i>
                                                Thêm nhân viên đã tuyển
                                            </h5>
                                            <button type="button"
                                                    class="btn-close"
                                                    data-bs-dismiss="modal">
                                            </button>
                                        </div>

                                        <div class="modal-body">

                                            <c:if test="${not empty hireError and hireRequestId eq rr.id}">
                                                <div class="alert alert-danger">
                                                    <i class="fa-solid fa-circle-exclamation me-2"></i>
                                                    <c:out value="${hireError}"/>
                                                </div>
                                            </c:if>


                                            <div class="alert alert-info small">
                                                <strong>Chi nhánh:</strong>
                                                <c:out value="${rr.branchName}"/>

                                                <div>
                                                    <strong>Vị trí:</strong>
                                                    <c:out value="${rr.positionTitle}"/>
                                                </div>

                                                <div>
                                                    <strong>Hình thức:</strong>
                                                    <c:out value="${rr.employmentType}"/>
                                                    -
                                                    <c:out value="${rr.shiftType}"/>
                                                </div>
                                            </div>

                                            <div class="row g-3 mb-3">

                                                <div class="col-md-5">
                                                    <label class="form-label fw-bold small">
                                                        Họ và tên *
                                                    </label>
                                                    <input type="text"
                                                           name="fullName"
                                                           class="form-control"
                                                           value="${hireRequestId eq rr.id ? hireFullName : ''}"
                                                           required>
                                                </div>

                                                <div class="col-md-3">
                                                    <label class="form-label fw-bold small">
                                                        Số điện thoại *
                                                    </label>
                                                    <input type="text"
                                                           name="phone"
                                                           class="form-control"
                                                           pattern="0[0-9]{9}"
                                                           value="${hireRequestId eq rr.id ? hirePhone : ''}"
                                                           required>
                                                </div>

                                                <div class="col-md-4">
                                                    <label class="form-label fw-bold small">
                                                        CCCD/CMND *
                                                    </label>
                                                    <input type="text"
                                                           name="identityCard"
                                                           class="form-control"
                                                           pattern="([0-9]{9}|[0-9]{12})"
                                                           value="${hireRequestId eq rr.id ? hireIdentityCard : ''}"
                                                           required>
                                                </div>

                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-bold small">
                                                    Email (tùy chọn)
                                                </label>
                                                <input type="email"
                                                       name="email"
                                                       value="${hireRequestId eq rr.id ? hireEmail : ''}"
                                                       class="form-control">
                                            </div>

                                            <div class="mb-3">
                                                <label class="form-label fw-bold small">
                                                    Mã nhân viên / Username
                                                </label>

                                                <input type="text"
                                                       class="form-control"
                                                       placeholder="Hệ thống tự động cấp mã khi tạo tài khoản"
                                                       readonly>

                                                <div class="form-text">
                                                    Mã nhân viên được hệ thống tự động tạo.
                                                </div>
                                            </div>

                                            <div class="row g-3 mb-3">
                                                <div class="col-md-6">
                                                    <label class="form-label fw-bold small">
                                                        Loại hợp đồng *
                                                    </label>
                                                    <select class="form-select" name="contractType"
                                                            onchange="
                                                                    const input = this.form.querySelector('[name=expirationDate]');
                                                                    const seasonal = this.value === 'THOI_VU';
                                                                    input.disabled = !seasonal;
                                                                    input.required = seasonal;
                                                                    if (!seasonal)
                                                                        input.value = '';
                                                            ">
                                                        <option value="CHINH_THUC" ${hireRequestId eq rr.id and hireContractType eq 'THOI_VU' ? '' : 'selected'}>
                                                            Hợp đồng chính thức
                                                        </option>
                                                        <option value="THOI_VU" ${hireRequestId eq rr.id and hireContractType eq 'THOI_VU' ? 'selected' : ''}>
                                                            Hợp đồng thời vụ
                                                        </option>
                                                    </select>
                                                </div>

                                                <div class="col-md-6">
                                                    <label class="form-label fw-bold small">
                                                        Ngày kết thúc hợp đồng
                                                    </label>
                                                    <input type="date"
                                                           name="expirationDate"
                                                           class="form-control"
                                                           value="${hireRequestId eq rr.id ? hireExpirationDate : ''}"
                                                           ${hireRequestId eq rr.id and hireContractType eq 'THOI_VU' ? 'required' : 'disabled'}>
                                                </div>
                                            </div>

                                        </div>

                                        <div class="modal-footer">
                                            <button type="button"
                                                    class="btn btn-secondary"
                                                    data-bs-dismiss="modal">
                                                Đóng
                                            </button>

                                            <button type="submit"
                                                    class="btn btn-primary">
                                                <i class="fa-solid fa-user-check me-1"></i>
                                                Tạo tài khoản nhân viên
                                            </button>
                                        </div>

                                    </form>
                                </div>
                            </div>
                        </div>

                    </c:if>
                </c:forEach>

            </main>
        </div>

        <!-- Modal xác nhận duyệt/từ chối nhu cầu tuyển dụng -->
        <div class="modal fade" id="hiringReviewModal" tabindex="-1" aria-labelledby="hiringReviewTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <form method="post" action="${pageContext.request.contextPath}/hr/recruitment" id="hiringReviewForm">
                        <div class="modal-header">
                            <h5 class="modal-title" id="hiringReviewTitle">Xử lý đề xuất tuyển dụng</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="requestId" id="hiringRequestId">
                            <input type="hidden" name="action" id="hiringReviewAction">
                            <p class="text-secondary small mb-3" id="hiringReviewDescription"></p>
                            <label for="hiringHrNote" class="form-label fw-semibold">Ghi chú của HR <span id="hiringNoteRequired" class="text-danger" style="display:none">*</span></label>
                            <textarea id="hiringHrNote" name="hrNote" rows="3" maxlength="2000" class="form-control" placeholder="Nhập ghi chú; bắt buộc nếu từ chối"></textarea>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                            <button type="submit" class="btn btn-success" id="hiringSubmit">Xác nhận duyệt</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>


        <c:if test="${not empty hireError and hireRequestId gt 0}">
            <script>
                                                                document.addEventListener("DOMContentLoaded", function () {
                                                                    const modalElement = document.getElementById(
                                                                            "hireModal${hireRequestId}"
                                                                            );

                                                                    if (modalElement) {
                                                                        const modal = new bootstrap.Modal(modalElement);
                                                                        modal.show();
                                                                    }
                                                                });
            </script>
        </c:if>


        <script>
            // Sync temporary contract fields; backend remains the final validator.
            document.querySelectorAll('[id^="hireModal"]').forEach(function (modalElement) {
                const form = modalElement.querySelector('form');
                if (!form) return;
                const typeSelect = form.querySelector('[name="contractType"]');
                const dateInput = form.querySelector('[name="expirationDate"]');
                if (!typeSelect || !dateInput) return;

                function syncContractFields() {
                    const temporary = typeSelect.value === 'THOI_VU';
                    dateInput.disabled = !temporary;
                    dateInput.required = temporary;
                    // On re-open after a server rejection, retain user-entered date.
                    if (!temporary) dateInput.value = '';
                }
                typeSelect.addEventListener('change', syncContractFields);
                modalElement.addEventListener('show.bs.modal', syncContractFields);
                syncContractFields();
            });
        </script>

        <script>
            document.getElementById('hiringReviewModal').addEventListener('show.bs.modal', function (event) {
                const button = event.relatedTarget;
                if (!button)
                    return;
                const action = button.getAttribute('data-review-action');
                const reject = action === 'rejectRecruitmentRequest';
                document.getElementById('hiringRequestId').value = button.getAttribute('data-request-id');
                document.getElementById('hiringReviewAction').value = action;
                document.getElementById('hiringReviewTitle').textContent = reject ? 'Từ chối đề xuất tuyển dụng' : 'Phê duyệt đề xuất tuyển dụng';
                document.getElementById('hiringReviewDescription').textContent = 'Đề xuất #' + button.getAttribute('data-request-id') + ' - ' + button.getAttribute('data-position');
                const note = document.getElementById('hiringHrNote');
                note.value = '';
                note.required = reject;
                document.getElementById('hiringNoteRequired').style.display = reject ? 'inline' : 'none';
                const submit = document.getElementById('hiringSubmit');
                submit.className = reject ? 'btn btn-danger' : 'btn btn-success';
                submit.textContent = reject ? 'Xác nhận từ chối' : 'Xác nhận duyệt';
            });
        </script>
    </body>
</html>