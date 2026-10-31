<%-- 
    Document   : transfer-requests (HR)
    Created on : 19 thg 10, 2026, 11:38:22
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Phê duyệt điều chuyển - HR Management</title>
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
        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fa-solid fa-user-tie"></i><span>HR Management</span></div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/hr/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/recruitment"><i class="fa-solid fa-user-plus"></i> Phê duyệt đề xuất</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/hr/transfer-requests"><i class="fa-solid fa-right-left"></i> Phê duyệt điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/employee-management"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/attendance-management"><i class="fa-solid fa-clock"></i> Chấm công & Ca làm</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Quản lý vi phạm</a></li>
            </ul>
        </aside>

        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Trị Nhân Sự Toàn Hệ Thống (HR Portal)</h1>
                <div class="user-info">
                    <span>Xin chào, <b><c:out value="${sessionScope.account.username != null ? sessionScope.account.username : 'HR Manager'}"/></b></span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a>
                </div>
            </header>

            <main class="page-content">
                <div class="page-title d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-right-left me-2"></i>Phê Duyệt Điều Chuyển Nhân Sự (HR)</h2>
                        <p class="mb-0">Xem xét và phê duyệt các yêu cầu điều chuyển nhân sự giữa các cơ sở trong hệ thống.</p>
                    </div>
                    <button class="btn btn-light text-primary fw-semibold shadow-sm px-3 py-2" onclick="history.back()">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </button>
                </div>

                <c:if test="${not empty message}">
                    <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i><c:out value="${message}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                        <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${error}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <div class="card shadow-sm">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 20%;">Mã Đơn & Lý Do</th>
                                    <th style="width: 20%;">Từ → Đến Cơ Sở</th>
                                    <th style="width: 22%;">Thời Gian / Ca / Vị Trí</th>
                                    <th style="width: 18%;">Nhân Viên Đề Cử</th>
                                    <th style="width: 20%;" class="text-center">Thao Tác Xử Lý</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${requests}">
                                    <tr>
                                        <td>
                                            <strong class="text-primary">#<c:out value="${t.id}"/></strong> 
                                            <span class="badge bg-light text-dark border ms-1"><c:out value="${t.requestedCount}"/> người</span>
                                            <div class="text-muted small mt-1"><i class="fa-regular fa-comment-dots me-1"></i><c:out value="${t.reason}"/></div>
                                        </td>
                                        <td>
                                            <div class="d-flex flex-column gap-1">
                                                <span class="badge bg-secondary text-start"><i class="fa-solid fa-shop me-1"></i> <c:out value="${t.sourceStoreName}"/></span>
                                                <div class="text-center text-muted py-1"><i class="fa-solid fa-arrow-down fa-xs"></i></div>
                                                <span class="badge bg-success text-start"><i class="fa-solid fa-shop-lock me-1"></i> <c:out value="${t.destinationStoreName}"/></span>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="small"><strong>Ngày:</strong> <c:out value="${t.workDate}"/></div>
                                            <div class="small"><strong>Ca:</strong> <c:out value="${t.shiftName}"/></div>
                                            <div class="small"><strong>Vị trí:</strong> <span class="text-info fw-semibold"><c:out value="${t.positionName}"/></span></div>
                                        </td>
                                        <td>
                                            <c:forEach var="e" items="${selectedByTransfer[t.id]}">
                                                <div class="small mb-1"><i class="fa-solid fa-user text-secondary me-1"></i> <c:out value="${e.fullName}"/></div>
                                            </c:forEach>
                                        </td>
                                        <td>
                                            <form method="POST" action="${pageContext.request.contextPath}/hr/transfer-requests" class="mb-2" onsubmit="return confirm('Duyệt và chuyển phân công ca?')">
                                                <input type="hidden" name="action" value="approve">
                                                <input type="hidden" name="requestId" value="${t.id}">
                                                <button class="btn btn-success btn-sm w-100 shadow-sm"><i class="fa-solid fa-check me-1"></i> Duyệt đơn</button>
                                            </form>
                                            <form method="POST" action="${pageContext.request.contextPath}/hr/transfer-requests">
                                                <input type="hidden" name="action" value="reject">
                                                <input type="hidden" name="requestId" value="${t.id}">
                                                <textarea class="form-control form-control-sm mb-2" name="rejectReason" placeholder="Nhập lý do từ chối..." required maxlength="500" rows="1" style="font-size: 12px;"></textarea>
                                                <button class="btn btn-outline-danger btn-sm w-100 shadow-sm"><i class="fa-solid fa-xmark me-1"></i> Từ chối</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty requests}">
                                    <tr>
                                        <td colspan="5" class="text-center text-secondary py-5">
                                            <div class="py-3">
                                                <i class="fa-regular fa-folder-open fs-2 mb-2 text-muted"></i>
                                                <p class="mb-0">Không có đề xuất đang chờ HR xử lý.</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>