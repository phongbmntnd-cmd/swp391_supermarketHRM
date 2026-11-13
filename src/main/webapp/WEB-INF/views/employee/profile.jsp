<%-- 
    Document   : profile
    Created on : 11 thg 11, 2026, 00:00:32
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Hồ sơ cá nhân - Employee Portal</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                margin: 0;
                min-height: 100vh;
                background: #f4f7f6;
                color: #1e293b;
                font-family: Roboto, Arial, sans-serif;
            }
            .sidebar {
                position: fixed;
                inset: 0 auto 0 0;
                width: 280px;
                background: #1e293b;
                color: #94a3b8;
                box-shadow: 2px 0 10px rgba(0,0,0,.08);
                overflow-y: auto;
                z-index: 110;
            }
            .sidebar-brand {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 27px 22px;
                background: #0f172a;
                color: #fff;
                font-weight: 700;
                font-size: 18px;
            }
            .sidebar-brand i {
                color: #22c55e;
                font-size: 21px;
            }
            .sidebar-menu {
                list-style: none;
                margin: 0;
                padding: 18px 0;
            }
            .sidebar-menu a {
                display: flex;
                align-items: center;
                gap: 14px;
                padding: 15px 23px;
                border-left: 4px solid transparent;
                color: #94a3b8;
                font-weight: 500;
                font-size: 14px;
                text-decoration: none;
            }
            .sidebar-menu a i {
                width: 20px;
                text-align: center;
            }
            .sidebar-menu a:hover, .sidebar-menu .active a {
                background: rgba(255,255,255,.065);
                border-left-color: #22c55e;
                color: #fff;
            }
            .main-wrapper {
                margin-left: 280px;
                min-width: 0;
            }
            .top-navbar {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 16px;
                background: #fff;
                padding: 18px 32px;
                box-shadow: 0 1px 3px rgba(0,0,0,.05);
            }
            .top-navbar h1 {
                margin: 0;
                font-size: 18px;
                color: #334155;
                font-weight: 500;
            }
            .top-user {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 14px;
                font-size: 14px;
            }
            .avatar {
                width: 35px;
                height: 35px;
                display: grid;
                place-items: center;
                border-radius: 50%;
                background: #16a34a;
                color: #fff;
                font-weight: 700;
                font-size: 12px;
            }
            .logout {
                text-decoration: none;
                background: #fff1f2;
                color: #ef4444;
                padding: 8px 13px;
                border-radius: 7px;
                font-size: 13px;
                font-weight: 500;
            }
            .page-content {
                max-width: 1350px;
                margin: 30px auto;
                padding: 0 30px 30px;
            }
            .page-banner {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 16px;
                border-radius: 12px;
                padding: 26px 30px;
                background: linear-gradient(135deg,#16a34a,#15803d);
                color: #fff;
                margin-bottom: 24px;
                box-shadow: 0 10px 18px rgba(22,163,74,.12);
            }
            .page-banner h2 {
                margin: 0 0 6px;
                font-size: 25px;
                font-weight: 700;
            }
            .page-banner p {
                margin: 0;
                opacity: .95;
                font-size: 14px;
            }
            .profile-card {
                border: 0;
                border-radius: 12px;
                box-shadow: 0 4px 17px rgba(15,23,42,.055);
                overflow: hidden;
                margin-bottom: 22px;
            }
            .profile-card .card-header {
                padding: 18px 24px;
                background: #fff;
                border-color: #e8edf3;
                color: #1e293b;
                font-size: 17px;
                font-weight: 700;
            }
            .profile-card .card-body {
                padding: 25px;
            }
            .field-label {
                display: block;
                margin-bottom: 7px;
                font-size: 13px;
                font-weight: 600;
                color: #475569;
            }
            .form-control {
                border-radius: 8px;
                min-height: 43px;
            }
            .form-control[readonly] {
                background: #f1f5f9;
                color: #475569;
            }
            .hint {
                font-size: 12px;
                color: #64748b;
            }
            .btn-save {
                background: #16a34a;
                border-color: #16a34a;
                font-weight: 600;
            }
            .btn-save:hover {
                background: #15803d;
                border-color: #15803d;
            }
            @media (max-width: 900px) {
                .sidebar {
                    position: static;
                    width: 100%;
                }
                .sidebar-menu {
                    display: flex;
                    overflow-x: auto;
                    padding: 0 8px 8px;
                }
                .sidebar-menu li {
                    flex: 0 0 auto;
                }
                .sidebar-menu a {
                    padding: 12px;
                    white-space: nowrap;
                }
                .main-wrapper {
                    margin: 0;
                }
                .top-navbar {
                    padding: 15px 18px;
                }
                .page-content {
                    padding: 0 16px 20px;
                    margin: 20px auto;
                }
            }
        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fa-solid fa-id-badge"></i><span>Employee Portal</span></div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-house"></i> Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/availability"><i class="fa-solid fa-calendar-plus"></i> Khai báo lịch rảnh</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/my-schedule"><i class="fa-solid fa-calendar-check"></i> Lịch làm việc</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/attendance"><i class="fa-solid fa-fingerprint"></i> Chấm công trực tuyến</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/payroll"><i class="fa-solid fa-money-bill-wave"></i> Phiếu lương</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/leave-request"><i class="fa-solid fa-plane-departure"></i> Xin nghỉ phép</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/forms"><i class="fa-solid fa-rotate"></i> Đổi ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/employee/violations"><i class="fa-solid fa-triangle-exclamation"></i> Vi phạm & kết quả</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/employee/profile"><i class="fa-solid fa-address-card"></i>Hồ sơ cá nhân</a></li>
            </ul>
        </aside>

        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Lý Siêu Thị - Không Gian Nhân Viên</h1>
                <div class="top-user">
                    <span class="avatar">NV</span>
                    <span>Xin chào, <strong><c:out value="${sessionScope.account.username}"/></strong></span>
                    <a href="${pageContext.request.contextPath}/logout" class="logout"><i class="fa-solid fa-right-from-bracket me-1"></i>Đăng xuất</a>
                </div>
            </header>

            <main class="page-content">
                <div class="page-banner">
                    <div>
                        <h2><i class="fa-solid fa-address-card me-2"></i>Hồ sơ cá nhân</h2>
                        <p>Xem thông tin công việc và cập nhật thông tin liên hệ của bạn.</p>
                    </div>
                    <a class="btn btn-light text-success fw-semibold" href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-arrow-left me-1"></i>Quay lại Dashboard</a>
                </div>

                <c:if test="${not empty profileSuccess}"><div class="alert alert-success" role="alert"><i class="fa-solid fa-circle-check me-2"></i><c:out value="${profileSuccess}"/></div></c:if>
                <c:if test="${not empty profileError}"><div class="alert alert-danger" role="alert"><i class="fa-solid fa-triangle-exclamation me-2"></i><c:out value="${profileError}"/></div></c:if>

                <section class="card profile-card">
                    <div class="card-header"><i class="fa-solid fa-user me-2 text-success"></i>Thông tin cá nhân</div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/employee/profile">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="field-label" for="username">Mã nhân viên</label>
                                    <input id="username" class="form-control" value="<c:out value='${profile.username}'/>" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="field-label" for="fullName">Họ và tên</label>
                                    <input id="fullName" class="form-control" value="<c:out value='${profile.fullName}'/>" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="field-label" for="identityCard">CCCD/CMND</label>
                                    <input id="identityCard" class="form-control" value="<c:out value='${profile.identityCard}'/>" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="field-label" for="accountStatus">Trạng thái tài khoản</label>
                                    <input id="accountStatus" class="form-control" value="<c:out value='${profile.status}'/>" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="field-label" for="phone">Số điện thoại <span class="text-success">(được chỉnh sửa)</span></label>
                                    <input id="phone" name="phone" class="form-control" type="tel" maxlength="10" inputmode="numeric" pattern="0[0-9]{9}" title="Nhập 10 chữ số bắt đầu bằng số 0" value="<c:out value='${profile.phone}'/>" placeholder="Ví dụ: 0901234567">
                                </div>
                                <div class="col-md-6">
                                    <label class="field-label" for="email">Email <span class="text-success">(được chỉnh sửa)</span></label>
                                    <input id="email" name="email" class="form-control" type="email" maxlength="100" value="<c:out value='${profile.email}'/>" placeholder="Ví dụ: employee@example.com">
                                </div>
                            </div>
                            <p class="hint mt-3 mb-3"><i class="fa-solid fa-lock me-1"></i>Họ tên, CCCD, mã nhân viên và trạng thái tài khoản do bộ phận nhân sự quản lý.</p>
                            <button type="submit" class="btn btn-save text-white px-4"><i class="fa-solid fa-floppy-disk me-2"></i>Lưu thông tin liên hệ</button>
                        </form>
                    </div>
                </section>

                <section class="card profile-card">
                    <div class="card-header"><i class="fa-solid fa-briefcase me-2 text-success"></i>Thông tin công việc <span class="fw-normal text-secondary fs-6">(chỉ xem)</span></div>
                    <div class="card-body">
                        <div class="row g-3">
                            <div class="col-md-6"><label class="field-label">Mã chi nhánh gốc</label><input class="form-control" value="<c:out value='${profile.homeBranchId}'/>" readonly></div>
                            <div class="col-md-6"><label class="field-label">Vị trí</label><input class="form-control" value="<c:out value='${profile.positionName}'/>" readonly></div>
                            <div class="col-md-6"><label class="field-label">Phòng ban</label><input class="form-control" value="<c:out value='${profile.departmentName}'/>" readonly></div>
                            <div class="col-md-6"><label class="field-label">Loại nhân viên</label><input class="form-control" value="<c:out value='${profile.employeeType}'/>" readonly></div>
                            <div class="col-md-6"><label class="field-label">Hình thức ca làm</label><input class="form-control" value="<c:out value='${profile.shiftType}'/>" readonly></div>
                            <div class="col-md-6"><label class="field-label">Giờ tiêu chuẩn / ngày</label><input class="form-control" value="<c:out value='${profile.standardHoursPerDay}'/>" readonly></div>
                        </div>
                    </div>
                </section>

                <section class="card profile-card">
                    <div class="card-header"><i class="fa-solid fa-key me-2 text-success"></i>Đổi mật khẩu</div>
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/employee/profile">
                            <input type="hidden" name="action" value="changePassword">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="field-label" for="currentPassword">Mật khẩu hiện tại</label>
                                    <input class="form-control" id="currentPassword" name="currentPassword" type="password" autocomplete="current-password" required>
                                </div>
                                <div class="col-md-6"></div>
                                <div class="col-md-6">
                                    <label class="field-label" for="newPassword">Mật khẩu mới</label>
                                    <input class="form-control" id="newPassword" name="newPassword" type="password" minlength="8" maxlength="128" autocomplete="new-password" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="field-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                                    <input class="form-control" id="confirmPassword" name="confirmPassword" type="password" minlength="8" maxlength="128" autocomplete="new-password" required>
                                </div>
                            </div>
                            <button type="submit" class="btn btn-save text-white px-4 mt-4">
                                <i class="fa-solid fa-key me-2"></i>Đổi mật khẩu
                            </button>
                        </form>
                    </div>
                </section>
            </main>
        </div>
    </body>
</html>
