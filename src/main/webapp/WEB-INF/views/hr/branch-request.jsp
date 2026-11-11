<%-- 
    Document   : branch-request
    Created on : 3 thg 11, 2026, 23:11:43
    Author     : phong
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Yêu cầu mở chi nhánh - HR Management</title>
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
        
            /* Branch requests - style aligned with HR violation page */
            .branch-card { border: 0; border-radius: 10px; overflow: hidden; }
            .branch-card .card-header { border-bottom: 1px solid #e2e8f0; }
            .branch-table { min-width: 1120px; font-size: 14px; }
            .branch-table th { background: #f8fafc; white-space: nowrap; color: #334155; font-weight: 600; }
            .branch-table td { vertical-align: middle; }
            .branch-table td.actions { min-width: 175px; }
            .branch-table .badge { font-size: 12px; padding: 6px 9px; font-weight: 600; }
            .branch-table .badge-progress { background: #dbeafe; color: #1d4ed8; }
            .branch-table .badge-completed { background: #dcfce7; color: #166534; }
            .branch-table .badge-pending { background: #fef3c7; color: #92400e; }
            .branch-table .btn { white-space: nowrap; }
            .muted { color: #64748b; font-size: 12px; }
            .notice { border-radius: 6px; padding: 12px 14px; margin-bottom: 15px; background: #fef2f2; color: #991b1b; }
            .assignment-modal-overlay { display: none; position: fixed; inset: 0; background: rgba(15,23,42,.55); align-items: center; justify-content: center; z-index: 9999; padding: 18px; }
            .assignment-modal-dialog { background: white; padding: 25px; border-radius: 12px; width: 450px; max-width: 100%; max-height: calc(100dvh - 36px); overflow-y: auto; box-shadow: 0 16px 45px rgba(0,0,0,.22); }
            .assignment-modal-dialog label { display: block; font-weight: 500; margin-bottom: 6px; }
            .assignment-modal-dialog input, .assignment-modal-dialog select, .assignment-modal-dialog textarea { width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 6px; }
            .assignment-modal-dialog input:focus, .assignment-modal-dialog select:focus, .assignment-modal-dialog textarea:focus { border-color: #0284c7; outline: 2px solid rgba(2,132,199,.1); }
            .assignment-modal-dialog .modal-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="sidebar-brand"><i class="fa-solid fa-user-tie"></i><span>HR Management</span></div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/hr/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/recruitment"><i class="fa-solid fa-user-plus"></i> Phê duyệt đề xuất</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/transfer-requests"><i class="fa-solid fa-right-left"></i> Phê duyệt điều chuyển</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/employee-list"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/violations"><i class="fa-solid fa-scale-balanced"></i> Quản lý vi phạm</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/hr/branch-request"><i class="fa-solid fa-store"></i> Yêu cầu mở chi nhánh</a></li>
                <li><a href="${pageContext.request.contextPath}/hr/payroll"><i class="fa-solid fa-money-bill-wave"></i> Tính lương</a></li>
                <li><a href="${pageContext.request.contextPath}/director/reports"><i class="fa-solid fa-chart-pie"></i> Báo cáo toàn chuỗi</a></li> 
            </ul>
        </aside>
        <div class="main-wrapper">
            <header class="top-navbar">
                <h1>Hệ Thống Quản Trị Nhân Sự Toàn Hệ Thống (HR Portal)</h1>
                <div class="user-info">
                    <span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                        <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                    </a>
                </div>
            </header>
            <main class="page-content">
                <div class="page-title d-flex justify-content-between align-items-center gap-3 flex-wrap">
                    <div>
                        <h2 class="mb-1"><i class="fa-solid fa-store me-2"></i>Yêu cầu mở chi nhánh</h2>
                        <p class="mb-0">Tiếp nhận và xử lý yêu cầu mở cơ sở mới từ Director, bổ nhiệm quản lý và kích hoạt chi nhánh.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/hr/dashboard"
                       class="btn btn-light text-primary fw-semibold shadow-sm px-3 py-2">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </a>
                </div>
                <!-- Hiển thị lỗi khi gia hạn kiêm nhiệm -->
                <c:if test="${not empty sessionScope.extendError}">
                    <div style="background:#fee2e2;
                         color:#991b1b;
                         padding:12px 15px;
                         border-radius:6px;
                         margin:15px 0;">
                        <c:out value="${sessionScope.extendError}"/>
                    </div>

                    <c:remove var="extendError" scope="session"/>
                </c:if>

                <!-- Thông báo lỗi kích hoạt chi nhánh -->
                <c:if test="${not empty sessionScope.activationError}">
                    <div class="alert alert-danger" role="alert">
                        <c:out value="${sessionScope.activationError}"/>
                    </div>

                    <c:remove var="activationError" scope="session"/>
                </c:if>

                <c:if test="${not empty error}">
                    <div class="notice"><c:out value="${error}" /></div>
                </c:if>
                <section class="card branch-card shadow-sm">
                    <div class="card-header d-flex justify-content-between align-items-center gap-2 flex-wrap">
                        <div>
                            <h3 class="h5 mb-1"><i class="fa-solid fa-list-check text-primary me-2"></i>Danh sách yêu cầu từ Director</h3>
                            <p class="text-secondary small mb-0">Theo dõi tình trạng tiếp nhận, bổ nhiệm quản lý và tiến độ kích hoạt chi nhánh.</p>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 branch-table">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Tên chi nhánh</th>
                                <th>Địa chỉ</th>
                                <th>Ngày dự kiến</th>
                                <th>Lý do</th>
                                <th>Director ID</th>
                                <th>Trạng thái</th>
                                <th>Ngày gửi</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${branchRequests}">
                                <tr>
                                    <td><c:out value="${r.id}" /></td>
                                    <td><strong><c:out value="${r.branchName}" /></strong></td>
                                    <td><c:out value="${r.branchAddress}" /></td>
                                    <td><c:out value="${r.expectedOpeningDate}" /></td>
                                    <td><c:out value="${r.reason}" /></td>
                                    <td><c:out value="${r.requestedBy}" /></td>
                                    <td>
                                        <span class="badge ${r.status == 'IN_PROGRESS' ? 'badge-progress' : (r.status == 'COMPLETED' ? 'badge-completed' : 'badge-pending')}">
                                            <c:out value="${r.status}" />
                                        </span>
                                    </td>
                                    <td><c:out value="${r.createdAt}" /></td>

                                    <td class="actions">
                                        <c:if test="${r.status == 'PENDING_HR'}">
                                            <form action="${pageContext.request.contextPath}/hr/branch-request"
                                                  method="POST"
                                                  onsubmit="return confirm('Bắt đầu xử lý yêu cầu mở chi nhánh này?');">

                                                <input type="hidden" name="action"
                                                       value="startProcessing">

                                                <input type="hidden" name="requestId"
                                                       value="${r.id}">

                                                <button type="submit" class="btn btn-success btn-sm">
                                                    Bắt đầu xử lý
                                                </button>
                                            </form>
                                        </c:if>



                                        <c:if test="${r.status == 'IN_PROGRESS'}">

                                            <!-- Chưa bổ nhiệm quản lý -->
                                            <c:if test="${empty r.storeManagerId}">
                                                <button type="button"
                                                        onclick="showAssignForm('${r.id}', '${r.branchName}')"
                                                        class="btn btn-primary btn-sm">
                                                    Bổ nhiệm quản lý
                                                </button>
                                            </c:if>

                                            <!-- Đã bổ nhiệm quản lý -->
                                            <c:if test="${not empty r.storeManagerId}">
                                                <button type="button"
                                                        onclick="showExtendForm('${r.id}', '${r.branchName}')"
                                                        class="btn btn-warning btn-sm">
                                                    Gia hạn kiêm nhiệm
                                                </button>

                                                <div style="font-size:12px; margin-top:6px; color:#64748b;">
                                                    Hết hạn:
                                                    <c:out value="${r.assignmentEndDate}"/>
                                                </div>


                                                <!-- Kích hoạt chi nhánh mới -->
                                                <c:if test="${r.branchStatus == 'PREPARING'}">
                                                    <form action="${pageContext.request.contextPath}/hr/branch-request"
                                                          method="POST"
                                                          style="margin-top:10px;"
                                                          onsubmit="return confirm('Xác nhận khai trương và kích hoạt chi nhánh này?');">

                                                        <input type="hidden" name="action" value="activateBranch">
                                                        <input type="hidden" name="requestId" value="${r.id}">

                                                        <button type="submit"
                                                                class="btn btn-success btn-sm">
                                                            Kích hoạt chi nhánh
                                                        </button>
                                                    </form>
                                                </c:if>

                                            </c:if>

                                        </c:if>


                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty branchRequests}">
                                <tr><td class="text-center text-secondary py-4" colspan="9">Chưa có yêu cầu mở chi nhánh nào.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                        </div>
                    </div>
                </section>
            </main>
        </div>

        <div id="assignModal" class="assignment-modal-overlay">

            <div class="assignment-modal-dialog">

                <h3>Bổ nhiệm Store Manager kiêm nhiệm</h3>

                <p id="assignBranchName" style="margin:12px 0;"></p>

                <form action="${pageContext.request.contextPath}/hr/branch-request"
                      method="POST" onsubmit="return validateAssignmentDates();">

                    <input type="hidden" name="action"
                           value="assignManager">

                    <input type="hidden" name="requestId"
                           id="assignRequestId">

                    <div style="margin-bottom:15px;">
                        <label>Store Manager:</label>
                        <select name="managerId" required
                                style="width:100%; padding:8px;">
                            <option value="">-- Chọn quản lý --</option>

                            <c:forEach items="${availableManagers}" var="m">
                                <option value="${m.id}">
                                    <c:out value="${m.fullName}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div style="margin-bottom:15px;">
                        <label>Ngày bắt đầu:</label>
                        <input type="date" name="startDate"
                               required style="width:100%; padding:8px;">
                    </div>

                    <div style="margin-bottom:15px;">
                        <label>Ngày kết thúc:</label>
                        <input type="date" name="endDate"
                               required style="width:100%; padding:8px;">
                    </div>

                    <button type="submit" class="btn btn-success">
                        Xác nhận bổ nhiệm
                    </button>

                    <button type="button" onclick="closeAssignForm()" class="btn btn-outline-secondary">
                        Hủy
                    </button>
                </form>
            </div>
        </div>

        <script>
            function showAssignForm(requestId, branchName) {
                document.getElementById("assignRequestId").value = requestId;
                document.getElementById("assignBranchName").textContent =
                        "Chi nhánh: " + branchName;
                document.getElementById("assignModal").style.display = "flex";
            }

            function closeAssignForm() {
                document.getElementById("assignModal").style.display = "none";
            }


            function validateAssignmentDates() {
                const startInput = document.querySelector(
                        '#assignModal input[name="startDate"]'
                        );
                const endInput = document.querySelector(
                        '#assignModal input[name="endDate"]'
                        );

                const startDate = startInput.value;
                const endDate = endInput.value;

                const today = new Date();
                const todayString = [
                    today.getFullYear(),
                    String(today.getMonth() + 1).padStart(2, '0'),
                    String(today.getDate()).padStart(2, '0')
                ].join('-');

                if (!startDate || !endDate) {
                    alert("Vui lòng nhập đầy đủ ngày bắt đầu và kết thúc.");
                    return false;
                }

                if (startDate < todayString) {
                    alert("Ngày bắt đầu không được trước ngày hiện tại.");
                    return false;
                }

                if (endDate <= startDate) {
                    alert("Ngày kết thúc phải sau ngày bắt đầu.");
                    return false;
                }

                return true;
            }

        </script>


        <!-- Modal gia hạn Store Manager kiêm nhiệm -->
        <div id="extendModal" class="assignment-modal-overlay">

            <div class="assignment-modal-dialog">

                <h3>Gia hạn Store Manager kiêm nhiệm</h3>

                <p id="extendBranchName" style="margin:12px 0;"></p>

                <form action="${pageContext.request.contextPath}/hr/branch-request"
                      method="POST"
                      onsubmit="return validateExtendDate();">

                    <input type="hidden" name="action" value="extendAssignment">

                    <input type="hidden" name="requestId" id="extendRequestId">

                    <div style="margin-bottom:15px;">
                        <label>Ngày kết thúc mới:</label>
                        <input type="date" name="newEndDate"
                               id="newEndDate" required
                               style="width:100%; padding:8px;">
                    </div>

                    <div style="margin-bottom:15px;">
                        <label>Lý do gia hạn:</label>
                        <textarea name="extendReason" required
                                  rows="3"
                                  style="width:100%; padding:8px;"
                                  placeholder="Nhập lý do gia hạn..."></textarea>
                    </div>

                    <button type="submit" class="btn btn-success">
                        Xác nhận gia hạn
                    </button>

                    <button type="button" onclick="closeExtendForm()" class="btn btn-outline-secondary">
                        Hủy
                    </button>
                </form>
            </div>
        </div>

        <script>
            function showExtendForm(requestId, branchName) {
                document.getElementById("extendRequestId").value = requestId;
                document.getElementById("extendBranchName").textContent =
                        "Chi nhánh: " + branchName;

                document.getElementById("extendModal").style.display = "flex";
            }

            function closeExtendForm() {
                document.getElementById("extendModal").style.display = "none";
            }

            function validateExtendDate() {
                const newEndDate =
                        document.getElementById("newEndDate").value;

                if (!newEndDate) {
                    alert("Vui lòng chọn ngày kết thúc mới.");
                    return false;
                }

                return true;
            }
        </script>

    </body>
</html>

