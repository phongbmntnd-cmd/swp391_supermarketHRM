<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nghỉ phép</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f4f7f6;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 25px;
        }

        .page-header h2 {
            font-size: 24px;
            font-weight: 600;
            color: #1e293b;
            margin: 0;
        }

        .page-actions {
            display: flex;
            gap: 10px;
        }

        .btn-soft {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            padding: 8px 16px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            color: #475569;
            transition: all 0.2s;
        }

        .btn-soft:hover {
            border-color: #2563eb;
            color: #2563eb;
        }

        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        }

        /* ---- Danh sách ca bị nghỉ ---- */
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
    </style>
</head>

<body>

<%-- Sidebar dùng chung --%>
<jsp:include page="/WEB-INF/views/fragments/store-manager-sidebar.jsp"/>

<div class="main-wrapper">
<div class="container py-4">

    <div class="page-header">
        <h2>Quản lý đơn nghỉ phép</h2>
        <div class="page-actions">
            <a class="btn-soft"
               href="${pageContext.request.contextPath}/store-manager/forms">
                <i class="fa-solid fa-arrow-left"></i> Đơn từ &amp; Khiếu nại
            </a>
            <a class="btn-soft"
               href="${pageContext.request.contextPath}/store-manager/dashboard">
                <i class="fa-solid fa-house"></i> Dashboard
            </a>
        </div>
    </div>

    <c:if test="${param.success eq '1'}">
        <div class="alert alert-success">
            Thao tác thành công.
        </div>
    </c:if>

    <c:if test="${param.invalid eq '1'}">
        <div class="alert alert-warning">
            Không thể thực hiện. Vui lòng kiểm tra lại trạng thái đơn.
        </div>
    </c:if>

    <c:if test="${not empty param.warn}">
        <div class="alert alert-warning">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <c:out value="${param.warn}"/>
            <div class="mt-1 small">
                Các ca trống đã được đưa vào danh sách ca trống của chi nhánh
                để nhân viên khác có thể nhận cover.
            </div>
        </div>
    </c:if>

    <c:if test="${not empty param.error}">
        <div class="alert alert-danger">
            <c:out value="${param.error}"/>
        </div>
    </c:if>

    <c:if test="${not empty param.msg}">
        <div class="alert alert-info">
            <i class="fa-solid fa-circle-info"></i>
            <c:out value="${param.msg}"/>
        </div>
    </c:if>

    <!-- Tổng hợp thời gian nghỉ theo từng loại -->
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h4>
                Tổng thời gian nghỉ theo từng loại
                <small class="text-muted" style="font-size: 13px; font-weight: 400;">
                    chi nhánh &middot; năm <%= java.time.LocalDate.now().getYear() %>
                </small>
            </h4>

            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <div class="alert alert-secondary mb-0 py-2">
                        <i class="fa-solid fa-clock"></i>
                        <strong>Tổng thời gian nghỉ của chi nhánh:</strong>
                        <span style="font-size: 18px;">
                            <c:out value="${branchTotalHours}"/>
                        </span>
                        giờ
                    </div>
                </div>
            </div>

            <p class="text-muted" style="font-size: 13px;">
                <i class="fa-solid fa-circle-info"></i>
                <strong>Tổng</strong> = thời gian nghỉ đã duyệt
                + thời gian nghỉ đang chờ duyệt.
                Giúp Store Manager nắm được tải trọng nghỉ phép sắp tới
                của từng loại trước khi duyệt.
            </p>

            <div class="table-responsive">
                <table class="table table-bordered table-hover mb-0">
                    <thead class="table-dark">
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
                                    <small class="text-muted">
                                        (<c:out value="${s.leaveTypeCode}"/>)
                                    </small>
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
                                            <span class="badge bg-warning">
                                                <c:out value="${s.pendingHours}"/>
                                            </span>
                                        </c:when>
                                        <c:otherwise>0</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <strong><c:out value="${s.totalHours}"/></strong>
                                </td>
                                <td><c:out value="${s.requestCount}"/></td>
                                <td><c:out value="${s.employeeCount}"/></td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty leaveSummary}">
                            <tr>
                                <td colspan="7" class="text-center text-muted">
                                    Chi nhánh chưa có đơn nghỉ phép nào
                                    trong năm.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <c:if test="${not empty shiftDefinitions}">
                <hr>
                <strong class="d-block mb-1">
                    <i class="fa-solid fa-clock"></i>
                    Định nghĩa các ca làm việc
                </strong>
                <div class="table-responsive">
                    <table class="table table-sm table-bordered mb-0"
                           style="font-size: 13px;">
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
                                    <td>
                                        <c:out value="${sd.startTime}"/>
                                        &ndash;
                                        <c:out value="${sd.endTime}"/>
                                    </td>
                                    <td>
                                        <strong><c:out value="${sd.hours}"/></strong> giờ
                                    </td>
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
        <div class="card-body">
            <h4>Danh sách đơn nghỉ phép của chi nhánh</h4>
            <p class="text-muted" style="font-size: 13px;">
                Quota nghỉ phép được tính theo <strong>giờ làm việc</strong>.
                Mỗi đơn gắn với các <strong>ca cụ thể</strong> bị ảnh hưởng -
                khi duyệt, các ca đó sẽ được chuyển sang ca trống để tìm người cover.
            </p>

            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-dark">
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
                                    <c:out value="${r.userName}"/>
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
                                    <small class="text-muted">
                                        (<c:out value="${r.leaveTypeCode}"/>)
                                    </small>
                                </td>
                                <td><c:out value="${r.startDate}"/></td>
                                <td><c:out value="${r.endDate}"/></td>
                                <td>
                                    <strong><c:out value="${r.totalHours}"/> giờ</strong>
                                    <c:if test="${r.totalDays gt 0}">
                                        <small class="text-muted">
                                            (<c:out value="${r.totalDays}"/> ngày)
                                        </small>
                                    </c:if>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.shiftCount gt 0}">
                                            <div class="shift-chip-list">
                                                <c:forEach var="s" items="${r.shiftDetails}">
                                                    <span class="shift-chip">
                                                        <c:out value="${s.workDate}"/>
                                                        &middot;
                                                        <c:out value="${s.shiftName}"/>
                                                        <span class="chip-hours">
                                                            <c:out value="${s.hours}"/>h
                                                        </span>
                                                    </span>
                                                </c:forEach>
                                            </div>

                                            <%-- Cảnh báo thiếu người sau khi duyệt --%>
                                            <c:if test="${r.hasCoverageWarning}">
                                                <div class="coverage-warning mt-1">
                                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                                    Cần tìm người cover:
                                                    <strong>
                                                        <c:out value="${r.coverageWarningCount}"/>
                                                    </strong>
                                                    ca sẽ thiếu người
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="no-shift">
                                                Theo ngày (chưa có lịch chi tiết)
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><c:out value="${r.reason}"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.status eq 'PENDING'}">
                                            <span class="badge bg-warning">Chờ duyệt</span>
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
                                            <span class="badge bg-light text-dark">
                                                <c:out value="${r.status}"/>
                                            </span>
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
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/store-manager/leave-requests">

                                            <input type="hidden"
                                                   name="requestId"
                                                   value="${r.id}">

                                            <input type="text"
                                                   name="response"
                                                   maxlength="255"
                                                   class="form-control form-control-sm mb-2"
                                                   placeholder="Ghi chú (tùy chọn)">

                                            <button name="action"
                                                    value="approve"
                                                    type="submit"
                                                    class="btn btn-success btn-sm mb-1">
                                                Duyệt
                                            </button>

                                            <button name="action"
                                                    value="reject"
                                                    type="submit"
                                                    class="btn btn-danger btn-sm mb-1">
                                                Từ chối
                                            </button>
                                        </form>
                                    </c:if>

                                    <%-- Đơn đã duyệt: cho phép thu hồi.
                                         Thao tác này hoàn lại quota,
                                         gỡ ca ON_LEAVE và đóng ca
                                         trống phát sinh từ đơn. --%>
                                    <c:if test="${r.status eq 'APPROVED'}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/store-manager/leave-requests"
                                              onsubmit="return confirm('Thu hồi đơn này?\n\nQuota sẽ được hoàn lại, các ca bị nghỉ sẽ được mở lại và ca trống tương ứng sẽ được đóng.\n\nBạn có chắc chắn không?');">

                                            <input type="hidden"
                                                   name="requestId"
                                                   value="${r.id}">

                                            <input type="text"
                                                   name="response"
                                                   maxlength="255"
                                                   class="form-control form-control-sm mb-2"
                                                   placeholder="Lý do thu hồi (tùy chọn)">

                                            <button name="action"
                                                    value="revoke"
                                                    type="submit"
                                                    class="btn btn-warning btn-sm mb-1">
                                                <i class="fa-solid fa-rotate-left"></i>
                                                Thu hồi
                                            </button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty requestList}">
                            <tr>
                                <td colspan="12" class="text-center text-muted">
                                    Chưa có đơn nghỉ phép nào.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>
</div>

<script src="${pageContext.request.contextPath}/js/sidebar.js"></script>
</body>
</html>
