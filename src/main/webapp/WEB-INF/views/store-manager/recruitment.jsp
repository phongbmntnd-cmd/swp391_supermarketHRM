<%-- 
    Document   : recruitment
    Created on : 23 thg 9, 2026, 00:06:33
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Quản lý đề xuất tiếp nhận / tuyển dụng - Store Manager</title>
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
            /* --- SIDEBAR --- */
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
            /* --- MAIN WRAPPER & TOP NAVBAR --- */
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
                white-space: nowrap;
            }
            .dashboard-container {
                max-width: 1400px;
                margin: 30px;
            }
            /* --- PAGE STYLES --- */
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
                background: linear-gradient(135deg, #f59e0b, #d97706);
                color: #fff;
                padding: 25px 30px;
                border-radius: 12px;
                margin-bottom: 25px;
                box-shadow: 0 10px 15px -3px rgba(245, 158, 11, 0.2);
            }
            .page-title h2 {
                margin: 0 0 8px;
                font-size: 24px;
            }
            .page-title p {
                margin: 0;
                opacity: 0.9;
            }
            .status-PENDING {
                color: #d97706;
                background: #fef3c7;
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: bold;
            }
            .status-APPROVED {
                color: #16a34a;
                background: #dcfce7;
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: bold;
            }
            .status-REJECTED {
                color: #dc2626;
                background: #fee2e2;
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: bold;
            }
            /* Nhóm thao tác đề xuất: hai nút xếp dọc, giữ phong cách gốc */
            .proposal-actions {
                display: flex;
                flex-direction: column;
                align-items: stretch;
                gap: 10px;
                min-width: 242px;
            }
            .proposal-actions .btn {
                text-align: left;
                border-radius: 8px;
                padding: 10px 14px;
                white-space: nowrap;
                font-size: 13px;
            }
            .proposal-actions .btn i {
                width: 18px;
                text-align: center;
            }
            .proposal-actions .btn-recruitment {
                background: rgba(255,255,255,.12);
                border: 1px solid rgba(255,255,255,.8);
                color: #fff;
            }
            .proposal-actions .btn-recruitment:hover {
                background: #fff;
                color: #b45309;
            }
            .proposal-actions .btn-dashboard {
                align-self: flex-end;
            }
            @media (max-width: 900px) {
                .sidebar {
                    width: 220px;
                }
                .main-wrapper {
                    margin-left: 220px;
                }
                .dashboard-container {
                    margin: 20px;
                }
            }
            @media (max-width: 650px) {
                .page-title {
                    flex-direction: column;
                    align-items: stretch !important;
                    gap: 18px;
                }
                .proposal-actions {
                    width: 100%;
                    min-width: 0;
                }
                .proposal-actions .btn-dashboard {
                    align-self: stretch;
                }
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
                .main-wrapper {
                    margin-left: 0;
                }
                .top-navbar {
                    position: static;
                    flex-wrap: wrap;
                }
                .dashboard-container {
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
                <li class="active"><a href="${pageContext.request.contextPath}/store-manager/recruitment"><i class="fa-solid fa-file-pen"></i> Đề xuất tuyển dụng/tiếp nhận</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/transfer-requests"><i class="fa-solid fa-right-left"></i> Quản lý điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/attendance"><i class="fa-solid fa-clock-rotate-left"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/schedule"><i class="fa-solid fa-calendar-week"></i> Xếp lịch & Phân ca</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/violations"><i class="fa-solid fa-triangle-exclamation"></i> Báo cáo vi phạm</a></li>
                <li><a href="${pageContext.request.contextPath}/director/reports"><i class="fa-solid fa-chart-pie"></i> Báo cáo chi nhánh</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/leave-requests"><i class="fa-solid fa-plane-departure"></i> Duyệt nghỉ phép</a></li>
                <li><a href="${pageContext.request.contextPath}/store-manager/shift-requests"><i class="fa-solid fa-rotate"></i> Duyệt đổi ca</a></li>
            </ul>
        </aside>

        <!-- Main Content Wrapper -->
        <div class="main-wrapper">

            <!-- Top Header -->
            <header class="top-navbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Chi Nhánh Trực Thuộc</h1>
                <div class="user-info">
                    <div class="user-profile">
                        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.username != null ? sessionScope.user.username : 'Store+Manager'}&background=2563eb&color=fff" alt="Avatar">
                        <span>Xin chào, <b><c:out value="${sessionScope.user.username != null ? sessionScope.user.username : 'Store Manager'}"/></b></span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </header>

            <div class="dashboard-container">

                <!-- Thanh hiển thị Cơ sở hiện tại (Đầy đủ Tên, Mã Code và Địa chỉ) -->
                <div class="branch-info-bar">
                    <i class="fa-solid fa-location-dot"></i>
                    <span>Cơ sở hiện tại: <b><c:out value="${not empty displayBranchInfo ? displayBranchInfo : (currentBranch != null ? currentBranch.name += ' (' += currentBranch.code += ') - ' += currentBranch.address : 'Đang cập nhật')}"/></b></span>
                </div>

                <!-- Page Header Banner -->
                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-file-pen me-2"></i>Quản Lý Đề Xuất Tiếp Nhận / Tuyển Dụng Nhân Sự</h2>
                        <p class="mb-0">Tạo đề xuất tiếp nhận ứng viên cụ thể hoặc đề xuất nhu cầu tuyển thêm nhân sự để HR xem xét.</p>
                    </div>
                    <div class="proposal-actions">
                        <button type="button" class="btn btn-light text-warning fw-semibold shadow-sm" data-bs-toggle="modal" data-bs-target="#createProposalModal">
                            <i class="fa-solid fa-user-check me-1"></i> Tạo đề xuất tiếp nhận
                        </button>
                        <button type="button" class="btn btn-recruitment fw-semibold" data-bs-toggle="modal" data-bs-target="#createHiringRequestModal">
                            <i class="fa-solid fa-users me-1"></i> Tạo đề xuất tuyển dụng
                        </button>
                        <a href="${pageContext.request.contextPath}/store-manager/dashboard" class="btn btn-outline-light btn-dashboard px-3 py-2">
                            <i class="fa-solid fa-arrow-left me-1"></i> Quay về Dashboard
                        </a>
                    </div>
                </div>

                <!-- THÔNG BÁO THÀNH CÔNG CHUNG -->
                <c:if test="${not empty message}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i>${message}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- BẢNG LỊCH SỬ ĐỀ XUẤT TIẾP NHẬN -->
                <div class="card shadow-sm border-0 p-3 bg-white rounded-3">
                    <h5 class="text-secondary mb-3"><i class="fa-solid fa-clock-rotate-left me-2 text-warning"></i>Lịch sử đề xuất tiếp nhận của chi nhánh (đã triển khai)</h5>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Ngày tạo</th>
                                    <th>Họ tên ứng viên</th>
                                    <th>Vị trí</th>
                                    <th>Hình thức & Ca làm</th>
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
                                            <small class="text-muted"><i class="fa-solid fa-phone-flip me-1"></i>${not empty rp.candidate ? rp.candidate.phone : ''}</small>
                                        </td>
                                        <td>${rp.positionTitle}</td>
                                        <td>
                                            <span class="badge bg-info text-dark">${rp.employmentType}</span><br>
                                            <small class="text-muted">Ca: ${rp.shiftType}</small>
                                        </td>
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
                                                <button class="btn btn-sm btn-warning text-white fw-semibold" 
                                                        data-proposal-id="<c:out value="${rp.id}"/>"
                                                        data-full-name="<c:out value="${rp.candidate.fullName}"/>"
                                                        data-phone="<c:out value="${rp.candidate.phone}"/>"
                                                        data-identity-card="<c:out value="${rp.candidate.identityCard}"/>"
                                                        data-email="<c:out value="${rp.candidate.email}"/>"
                                                        data-position-id="<c:out value="${rp.positionId}"/>"
                                                        data-employment-type="<c:out value="${rp.employmentType}"/>"
                                                        data-shift-type="<c:out value="${rp.shiftType}"/>"
                                                        data-target-date="<c:out value="${rp.targetDate}"/>"
                                                        data-reason="<c:out value="${rp.reason}"/>"
                                                        data-expiration-date="<c:out value="${expirationDateByProposal[rp.id]}"/>"
                                                        onclick="openResubmitModal(this)">
                                                    <i class="fa-solid fa-pen-to-square me-1"></i> Sửa & Gửi lại
                                                </button>
                                            </c:if>
                                            <c:if test="${rp.status == 'APPROVED'}">
                                                <span class="text-success small fw-semibold"><i class="fa-solid fa-check me-1"></i>Đã cấp tài khoản</span>
                                            </c:if>
                                            <c:if test="${rp.status == 'PENDING'}">
                                                <span class="text-muted small">Đang chờ xử lý</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty proposals}">
                                    <tr><td colspan="7" class="text-center text-muted py-4">Chưa có đề xuất tiếp nhận nào.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>


                <!-- LỊCH SỬ ĐỀ XUẤT TUYỂN DỤNG THEO NHU CẦU -->
                <div class="card shadow-sm border-0 p-3 bg-white rounded-3 mt-4">

                    <h5 class="text-secondary mb-3">
                        <i class="fa-solid fa-users text-warning me-2"></i>
                        Lịch sử đề xuất tuyển dụng nhân sự
                    </h5>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">

                            <thead class="table-light">
                                <tr>
                                    <th>Ngày tạo</th>
                                    <th>Vị trí cần tuyển</th>
                                    <th>Số lượng</th>
                                    <th>Hình thức & Ca làm</th>
                                    <th>Ngày cần nhân sự</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                    <th>Ghi chú từ HR</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="rr" items="${recruitmentRequests}">
                                    <tr>
                                        <td>
                                            <fmt:formatDate
                                                value="${rr.createdAt}"
                                                pattern="dd/MM/yyyy HH:mm"/>
                                        </td>

                                        <td class="fw-semibold">
                                            <c:out value="${rr.positionTitle}"/>
                                        </td>

                                        <td>
                                            <span class="badge bg-primary">
                                                <c:out value="${rr.quantity}"/> người
                                            </span>
                                        </td>

                                        <td>
                                            <span class="badge bg-info text-dark">
                                                <c:out value="${rr.employmentType}"/>
                                            </span>
                                            <div class="small text-muted mt-1">
                                                Ca: <c:out value="${rr.shiftType}"/>
                                            </div>
                                        </td>

                                        <td>
                                            <c:out value="${rr.targetDate}"/>
                                        </td>

                                        <td>
                                            <c:out value="${rr.reason}"/>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${rr.status eq 'PENDING'}">
                                                    <span class="status-PENDING">
                                                        Chờ duyệt
                                                    </span>
                                                </c:when>

                                                <c:when test="${rr.status eq 'APPROVED'}">
                                                    <span class="status-APPROVED">
                                                        Đã duyệt
                                                    </span>
                                                </c:when>

                                                <c:when test="${rr.status eq 'REJECTED'}">
                                                    <span class="status-REJECTED">
                                                        Từ chối
                                                    </span>
                                                </c:when>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <small class="text-muted">
                                                <c:out value="${empty rr.hrNote ? '---' : rr.hrNote}"/>
                                            </small>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty recruitmentRequests}">
                                    <tr>
                                        <td colspan="8"
                                            class="text-center text-muted py-4">
                                            Chưa có đề xuất tuyển dụng nào.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>

                        </table>
                    </div>
                </div>


            </div>
        </div>

        <!-- MODAL TẠO ĐỀ XUẤT TIẾP NHẬN (luồng hiện có) -->
        <div class="modal fade" id="createProposalModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <form action="${pageContext.request.contextPath}/store-manager/recruitment" method="post">
                        <div class="modal-header">
                            <h5 class="modal-title text-primary"><i class="fa-solid fa-file-circle-plus me-2"></i>Tạo Đề Xuất Tiếp Nhận Nhân Sự</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="action" value="create">

                            <!-- HIỂN THỊ LỖI NGAY TRONG MODAL -->
                            <c:if test="${not empty error and errorModal eq 'create'}">
                                <div class="alert alert-danger py-2 mb-3" role="alert">
                                    <i class="fa-solid fa-circle-exclamation me-2"></i>${error}
                                </div>
                            </c:if>

                            <div class="row g-3 mb-3">
                                <div class="col-md-5">
                                    <label class="form-label small fw-bold">Họ và tên ứng viên <span class="text-danger">*</span></label>
                                    <input type="text" name="fullName" class="form-control" required>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">Số điện thoại <span class="text-danger">*</span></label>
                                    <input type="text" name="phone" class="form-control" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-bold">Số CCCD/CMND <span class="text-danger">*</span></label>
                                    <input type="text" name="identityCard" class="form-control" required>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Email ứng viên (Tùy chọn)</label>
                                <input type="email" name="email" class="form-control" placeholder="nguyenvana@gmail.com">
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold">Vị trí công việc <span class="text-danger">*</span></label>
                                    <select name="positionId" class="form-select" required>
                                        <option value="">-- Chọn vị trí --</option>
                                        <c:forEach var="p" items="${positions}">
                                            <option value="${p.id}">${p.title}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold">Hình thức làm việc <span class="text-danger">*</span></label>
                                    <select id="employeeTypeSelect" name="employeeType" class="form-select" onchange="updateShiftOptions('employeeTypeSelect', 'shiftTypeSelect')" required>
                                        <option value="FULL_TIME">FULL_TIME (Toàn thời gian)</option>
                                        <option value="PART_TIME">PART_TIME (Bán thời gian)</option>
                                    </select>
                                </div>
                            </div>

                            <!-- PHÂN LOẠI CA LÀM THEO HÌNH THỨC NHÂN SỰ -->
                            <div class="row g-3 mb-3">
                                <div class="col-md-12">
                                    <label class="form-label small fw-bold">Loại ca làm việc <span class="text-danger">*</span></label>
                                    <select id="shiftTypeSelect" name="shiftType" class="form-select" required>
                                        <option value="FT_ROTATING">Ca xoay linh hoạt (Sáng - Chiều - Tối)</option>
                                        <option value="FT_FIXED_MORNING">Ca cố định sáng</option>
                                        <option value="FT_FIXED_EVENING">Ca cố định tối</option>
                                    </select>
                                </div>
                            </div>

                            <!-- LOẠI HỢP ĐỒNG VÀ NGÀY HẾT HẠN -->
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold">Loại hợp đồng <span class="text-danger">*</span></label>
                                    <select id="contractTypeSelect" name="contractType" class="form-select" onchange="handleContractTypeChange('contractTypeSelect', 'expContainer')" required>
                                        <option value="CHINH_THUC">Hợp đồng chính thức</option>
                                        <option value="THOI_VU">Hợp đồng thời vụ (Casual)</option>
                                    </select>
                                </div>
                                <div class="col-md-6" id="expContainer" style="display: none;">
                                    <label class="form-label small fw-bold">Ngày kết thúc HĐ <span class="text-danger">*</span></label>
                                    <input type="date" id="expirationDateInput" name="expirationDate" class="form-control">
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-12">
                                    <label class="form-label small fw-bold">Ngày mong muốn có nhân sự <span class="text-danger">*</span></label>
                                    <input type="date" id="targetDateInput" name="targetDate" class="form-control" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold">Lý do đề xuất <span class="text-danger">*</span></label>
                                <textarea name="reason" rows="2" class="form-control" required></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                            <button type="submit" class="btn btn-primary btn-sm">Gửi Đề Xuất</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>


        <!-- MODAL ĐỀ XUẤT TUYỂN DỤNG: UI trước, backend nối sau -->
        <div class="modal fade" id="createHiringRequestModal" tabindex="-1" aria-labelledby="createHiringRequestLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content border-0 shadow">
                    <form id="createHiringRequestForm" method="post" action="${pageContext.request.contextPath}/store-manager/recruitment">
                        <input type="hidden" name="action" value="createRecruitmentRequest">
                        <div class="modal-header" style="background:#fff7ed; border-bottom:1px solid #fed7aa;">
                            <div>
                                <h5 class="modal-title fw-semibold" id="createHiringRequestLabel" style="color:#b45309;">
                                    <i class="fa-solid fa-users me-2"></i>Tạo đề xuất tuyển dụng nhân sự
                                </h5>
                                <small class="text-muted">Đề xuất nhu cầu tuyển người, chưa cần thông tin ứng viên cụ thể.</small>
                            </div>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                        </div>
                        <div class="modal-body p-4">
                            <div class="row g-3">
                                <div class="col-md-7">
                                    <label class="form-label small fw-bold">Vị trí cần tuyển <span class="text-danger">*</span></label>
                                    <select name="positionId" class="form-select" required>
                                        <option value="">-- Chọn vị trí --</option>
                                        <c:forEach var="p" items="${positions}">
                                            <option value="${p.id}"><c:out value="${p.title}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-5">
                                    <label class="form-label small fw-bold">Số lượng cần tuyển <span class="text-danger">*</span></label>
                                    <input type="number" name="quantity" min="1" max="100" step="1" class="form-control" placeholder="VD: 3" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold">Hình thức làm việc <span class="text-danger">*</span></label>
                                    <select name="employeeType" id="hiringEmployeeType" class="form-select" onchange="updateShiftOptions('hiringEmployeeType', 'hiringShiftType')" required>
                                        <option value="FULL_TIME">FULL_TIME (Toàn thời gian)</option>
                                        <option value="PART_TIME">PART_TIME (Bán thời gian)</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold">Loại ca dự kiến <span class="text-danger">*</span></label>
                                    <select name="shiftType" id="hiringShiftType" class="form-select" required></select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label small fw-bold">Ngày mong muốn có nhân sự <span class="text-danger">*</span></label>
                                    <input type="date" name="targetDate" id="hiringTargetDate" class="form-control" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label small fw-bold">Lý do tuyển dụng <span class="text-danger">*</span></label>
                                    <textarea name="reason" class="form-control" rows="3" maxlength="2000" placeholder="Ví dụ: Thiếu nhân viên thu ngân cho ca chiều..." required></textarea>
                                </div>
                            </div>
                            <c:if test="${not empty error and errorModal eq 'recruitmentRequest'}">
                                <div class="alert alert-danger mt-3 mb-0" role="alert">
                                    <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${error}"/>
                                </div>
                            </c:if>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                            <button type="submit" class="btn btn-warning text-white btn-sm">Gửi đề xuất tuyển dụng</button>
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
                            <h5 class="modal-title text-warning"><i class="fa-solid fa-pen-to-square me-2"></i>Chỉnh Sửa & Gửi Lại Đề Xuất</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="action" value="resubmit">
                            <input type="hidden" id="editProposalId" name="proposalId" value="<c:out value="${errorModal eq 'resubmit' ? param.proposalId : ''}"/>">
                            <c:if test="${not empty error and errorModal eq 'resubmit'}">
                                <div class="alert alert-danger py-2 mb-3" role="alert"><c:out value="${error}"/></div>
                            </c:if>

                            <div class="row g-3 mb-3">
                                <div class="col-md-5">
                                    <label class="form-label small fw-bold">Họ và tên ứng viên <span class="text-danger">*</span></label>
                                    <input type="text" id="editFullName" name="fullName" class="form-control" required value="<c:out value="${errorModal eq 'resubmit' ? param.fullName : ''}"/>">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">Số điện thoại <span class="text-danger">*</span></label>
                                    <input type="text" id="editPhone" name="phone" class="form-control" required value="<c:out value="${errorModal eq 'resubmit' ? param.phone : ''}"/>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small fw-bold">Số CCCD/CMND <span class="text-danger">*</span></label>
                                    <input type="text" id="editIdentityCard" name="identityCard" class="form-control" required value="<c:out value="${errorModal eq 'resubmit' ? param.identityCard : ''}"/>">
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Email ứng viên (Tùy chọn)</label>
                                <input type="email" id="editEmail" name="email" class="form-control" value="<c:out value="${errorModal eq 'resubmit' ? param.email : ''}"/>">
                            </div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold">Vị trí công việc <span class="text-danger">*</span></label>
                                    <select id="editPositionId" name="positionId" class="form-select" required>
                                        <option value="">-- Chọn vị trí --</option>
                                        <c:forEach var="p" items="${positions}">
                                            <option value="${p.id}" <c:if test="${errorModal eq 'resubmit' and param.positionId eq p.id}">selected</c:if>><c:out value="${p.title}"/></option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold">Hình thức làm việc <span class="text-danger">*</span></label>
                                    <select id="editEmployeeType" name="employeeType" class="form-select" onchange="updateShiftOptions('editEmployeeType', 'editShiftType')" required>
                                        <option value="FULL_TIME" <c:if test="${errorModal eq 'resubmit' and param.employeeType eq 'FULL_TIME'}">selected</c:if>>FULL_TIME</option>
                                        <option value="PART_TIME" <c:if test="${errorModal eq 'resubmit' and param.employeeType eq 'PART_TIME'}">selected</c:if>>PART_TIME</option>
                                    </select>
                                </div>
                            </div>

                            <!-- PHÂN LOẠI CA LÀM (EDIT) -->
                            <div class="row g-3 mb-3">
                                <div class="col-md-12">
                                    <label class="form-label small fw-bold">Loại ca làm việc <span class="text-danger">*</span></label>
                                    <select id="editShiftType" name="shiftType" class="form-select" data-selected-shift="<c:out value="${errorModal eq 'resubmit' ? param.shiftType : ''}"/>" required>
                                    </select>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold">Loại hợp đồng <span class="text-danger">*</span></label>
                                    <select id="editContractType" name="contractType" class="form-select" onchange="handleContractTypeChange('editContractType', 'editExpContainer')" required>
                                        <option value="CHINH_THUC" <c:if test="${errorModal eq 'resubmit' and param.contractType eq 'CHINH_THUC'}">selected</c:if>>Hợp đồng chính thức</option>
                                        <option value="THOI_VU" <c:if test="${errorModal eq 'resubmit' and param.contractType eq 'THOI_VU'}">selected</c:if>>Hợp đồng thời vụ (Casual)</option>
                                    </select>
                                </div>
                                <div class="col-md-6" id="editExpContainer" style="display: none;">
                                    <label class="form-label small fw-bold">Ngày kết thúc HĐ <span class="text-danger">*</span></label>
                                    <input type="date" id="editExpirationDate" name="expirationDate" class="form-control" value="<c:out value="${errorModal eq 'resubmit' ? param.expirationDate : ''}"/>">
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-12">
                                    <label class="form-label small fw-bold">Ngày mong muốn có nhân sự <span class="text-danger">*</span></label>
                                    <input type="date" id="editTargetDate" name="targetDate" class="form-control" required value="<c:out value="${errorModal eq 'resubmit' ? param.targetDate : ''}"/>">
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Lý do đề xuất chỉnh sửa <span class="text-danger">*</span></label>
                                <textarea id="editReason" name="reason" rows="2" class="form-control" required><c:out value="${errorModal eq 'resubmit' ? param.reason : ''}"/></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Đóng</button>
                            <button type="submit" class="btn btn-warning text-white btn-sm">Gửi Lại Đề Xuất</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                        function updateShiftOptions(employeeTypeId, shiftTypeId, selectedValue = '') {
                                            const empType = document.getElementById(employeeTypeId).value;
                                            const shiftSelect = document.getElementById(shiftTypeId);

                                            shiftSelect.innerHTML = '';

                                            if (empType === 'FULL_TIME') {
                                                shiftSelect.innerHTML = `
                        <option value="FT_ROTATING">Ca xoay linh hoạt (Sáng - Chiều - Tối)</option>
                        <option value="FT_FIXED_MORNING">Ca cố định sáng</option>
                        <option value="FT_FIXED_EVENING">Ca cố định tối</option>
                    `;
                                            } else if (empType === 'PART_TIME') {
                                                shiftSelect.innerHTML = `
                        <option value="PT_FLEXIBLE">Ca xoay linh hoạt (Theo lịch rảnh hàng tuần)</option>
                        <option value="PT_FIXED_MORNING">Chỉ làm ca sáng</option>
                        <option value="PT_FIXED_AFTERNOON">Chỉ làm ca chiều</option>
                        <option value="PT_FIXED_EVENING">Chỉ làm ca tối</option>
                        <option value="PT_SEASONAL_WEEKEND">Thời vụ / Cuối tuần</option>
                    `;
                                            }

                                            if (selectedValue) {
                                                shiftSelect.value = selectedValue;
                                        }
                                        }

                                        function handleContractTypeChange(selectId, expContId) {
                                            const contractType = document.getElementById(selectId).value;
                                            const expContainer = document.getElementById(expContId);
                                            const expInput = expContainer.querySelector('input');

                                            if (contractType === 'THOI_VU') {
                                                expContainer.style.display = 'block';
                                                expInput.required = true;
                                            } else {
                                                expContainer.style.display = 'none';
                                                expInput.required = false;
                                                expInput.value = '';
                                            }
                                        }

                                        document.addEventListener("DOMContentLoaded", function () {
                                            const today = new Date().toISOString().split('T')[0];

                                            const targetDateInput = document.getElementById('targetDateInput');
                                            if (targetDateInput)
                                                targetDateInput.min = today;

                                            const expirationDateInput = document.getElementById('expirationDateInput');
                                            if (expirationDateInput)
                                                expirationDateInput.min = today;

                                            const editTargetDate = document.getElementById('editTargetDate');
                                            if (editTargetDate)
                                                editTargetDate.min = today;

                                            const editExpirationDate = document.getElementById('editExpirationDate');
                                            if (editExpirationDate)
                                                editExpirationDate.min = today;

                                            updateShiftOptions('employeeTypeSelect', 'shiftTypeSelect');
                                            updateShiftOptions('hiringEmployeeType', 'hiringShiftType');
                                            const hiringTargetDate = document.getElementById('hiringTargetDate');
                                            if (hiringTargetDate)
                                                hiringTargetDate.min = today;

            <c:if test="${not empty error}">
                                            var errorModalId = "${errorModal eq 'recruitmentRequest' ? 'createHiringRequestModal' : (errorModal eq 'resubmit' ? 'resubmitModal' : 'createProposalModal')}";
                                            if (errorModalId === 'resubmitModal') {
                                                updateShiftOptions('editEmployeeType', 'editShiftType',
                                                    document.getElementById('editShiftType').dataset.selectedShift);
                                                handleContractTypeChange('editContractType', 'editExpContainer');
                                            }
                                            var errorModal = new bootstrap.Modal(document.getElementById(errorModalId));
                                            errorModal.show();
            </c:if>
                                        });

                                        function openResubmitModal(button) {
                                            const data = button.dataset;
                                            document.getElementById('editProposalId').value = data.proposalId || '';
                                            document.getElementById('editFullName').value = data.fullName || '';
                                            document.getElementById('editPhone').value = data.phone || '';
                                            document.getElementById('editIdentityCard').value = data.identityCard || '';
                                            document.getElementById('editEmail').value = data.email || '';
                                            document.getElementById('editPositionId').value = data.positionId || '';
                                            document.getElementById('editEmployeeType').value = data.employmentType || 'FULL_TIME';
                                            updateShiftOptions('editEmployeeType', 'editShiftType', data.shiftType || '');
                                            document.getElementById('editTargetDate').value = data.targetDate || '';
                                            document.getElementById('editReason').value = data.reason || '';

                                            // DB lưu expiration_date cho hợp đồng thời vụ, NULL cho chính thức.
                                            const isCasual = Boolean(data.expirationDate && data.expirationDate !== 'null');
                                            document.getElementById('editContractType').value = isCasual ? 'THOI_VU' : 'CHINH_THUC';
                                            handleContractTypeChange('editContractType', 'editExpContainer');
                                            document.getElementById('editExpirationDate').value = isCasual ? data.expirationDate : '';

                                            const modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('resubmitModal'));
                                            modal.show();
                                        }
        </script>
    </body>
</html>