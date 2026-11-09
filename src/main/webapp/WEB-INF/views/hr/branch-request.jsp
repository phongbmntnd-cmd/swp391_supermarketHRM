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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Yêu cầu mở chi nhánh - HR</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                margin: 0;
                background: #f4f7f6;
                color: #334155;
                font-family: Roboto, Arial, sans-serif;
            }
            .topbar {
                background: #1e293b;
                color: white;
                padding: 18px 32px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 16px;
            }
            .topbar h1 {
                font-size: 19px;
                margin: 0;
            }
            .back {
                color: white;
                text-decoration: none;
                border: 1px solid #64748b;
                border-radius: 6px;
                padding: 9px 13px;
                font-size: 13px;
            }
            .wrap {
                max-width: 1200px;
                margin: 30px auto;
                padding: 0 20px;
            }
            .panel {
                background: white;
                border-radius: 10px;
                padding: 24px;
                box-shadow: 0 3px 15px rgba(15,23,42,.06);
            }
            h2 {
                margin: 0 0 8px;
                font-size: 20px;
            }
            .sub {
                color: #64748b;
                font-size: 14px;
                margin: 0 0 22px;
            }
            .notice {
                border-radius: 6px;
                padding: 12px 14px;
                margin-bottom: 15px;
                background: #fef2f2;
                color: #991b1b;
            }
            .table-scroll {
                overflow-x: auto;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                min-width: 870px;
            }
            th, td {
                border-bottom: 1px solid #e2e8f0;
                padding: 13px 12px;
                text-align: left;
                font-size: 14px;
                vertical-align: top;
            }
            th {
                background: #f8fafc;
                font-weight: 600;
            }
            .badge {
                display: inline-block;
                font-size: 12px;
                padding: 5px 8px;
                border-radius: 5px;
                background: #fef3c7;
                color: #92400e;
                font-weight: 600;
            }
            .badge.progress {
                background: #dbeafe;
                color: #1d4ed8;
            }
            .badge.completed {
                background: #dcfce7;
                color: #166534;
            }
            .empty {
                color: #64748b;
                text-align: center;
                padding: 25px;
            }
            .muted {
                color: #64748b;
                font-size: 12px;
            }
        </style>
    </head>
    <body>
        <header class="topbar">
            <h1><i class="fa-solid fa-store"></i> Yêu cầu mở chi nhánh</h1>
            <a class="back" href="${pageContext.request.contextPath}/hr/dashboard">
                <i class="fa-solid fa-arrow-left"></i> Về HR Dashboard
            </a>
        </header>
        <main class="wrap">
            <section class="panel">
                <h2>Danh sách yêu cầu từ Director</h2>
                <p class="sub">Theo dõi các yêu cầu mở chi nhánh mới. Yêu cầu mới có trạng thái PENDING_HR.</p>


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
                <div class="table-scroll">
                    <table>
                        <thead>
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
                                        <span class="badge ${r.status == 'IN_PROGRESS' ? 'progress' : (r.status == 'COMPLETED' ? 'completed' : '')}">
                                            <c:out value="${r.status}" />
                                        </span>
                                    </td>
                                    <td><c:out value="${r.createdAt}" /></td>

                                    <td>
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
                                                        style="padding:7px 12px; background:#0284c7;
                                                        color:white; border:none; border-radius:5px;">
                                                    Bổ nhiệm quản lý
                                                </button>
                                            </c:if>

                                            <!-- Đã bổ nhiệm quản lý -->
                                            <c:if test="${not empty r.storeManagerId}">
                                                <button type="button"
                                                        onclick="showExtendForm('${r.id}', '${r.branchName}')"
                                                        style="padding:7px 12px; background:#f59e0b;
                                                        color:white; border:none; border-radius:5px;">
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
                                                                style="background:#16a34a; color:white;
                                                                border:none; padding:8px 12px;
                                                                border-radius:5px; cursor:pointer;">
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
                                <tr><td class="empty" colspan="8">Chưa có yêu cầu mở chi nhánh nào.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
                <p class="muted" style="margin:16px 0 0;">Bước này chỉ hiển thị yêu cầu. Chức năng Start Processing sẽ được bổ sung sau.</p>
            </section>
        </main>

        <div id="assignModal" style="display:none; position:fixed;
             inset:0; background:rgba(0,0,0,0.5);
             align-items:center; justify-content:center; z-index:9999;">

            <div style="background:white; padding:25px;
                 border-radius:10px; width:420px; max-width:95%;">

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

                    <button type="submit"
                            style="background:#16a34a; color:white;
                            border:none; padding:9px 15px;
                            border-radius:5px;">
                        Xác nhận bổ nhiệm
                    </button>

                    <button type="button" onclick="closeAssignForm()"
                            style="padding:9px 15px;">
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
        <div id="extendModal"
             style="display:none; position:fixed; inset:0;
             background:rgba(0,0,0,0.5);
             align-items:center; justify-content:center; z-index:9999;">

            <div style="background:white; padding:25px;
                 border-radius:10px; width:420px; max-width:95%;">

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

                    <button type="submit"
                            style="background:#16a34a; color:white;
                            border:none; padding:9px 15px;
                            border-radius:5px;">
                        Xác nhận gia hạn
                    </button>

                    <button type="button"
                            onclick="closeExtendForm()"
                            style="padding:9px 15px;">
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

