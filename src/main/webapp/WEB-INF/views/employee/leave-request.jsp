<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xin nghỉ phép</title>
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
            border-color: #16a34a;
            color: #16a34a;
        }

        .btn-soft.primary {
            background: #16a34a;
            border-color: #16a34a;
            color: #ffffff;
        }

        .btn-soft.primary:hover {
            background: #15803d;
            color: #ffffff;
        }

        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        }

        .card-header-custom {
            background: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            font-weight: 600;
            color: #1e293b;
            border-radius: 12px 12px 0 0 !important;
        }

        .empty-row {
            color: #94a3b8;
            font-style: italic;
        }

        /* ---- Ca nghỉ ---- */
        .shift-picker {
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            overflow: hidden;
        }

        .shift-picker-header {
            background: #f8fafc;
            padding: 10px 14px;
            border-bottom: 1px solid #e2e8f0;
            font-weight: 600;
            color: #1e293b;
            font-size: 14px;
        }

        .shift-list {
            max-height: 340px;
            overflow-y: auto;
        }

        .shift-row {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 14px;
            border-bottom: 1px solid #f1f5f9;
            cursor: pointer;
            transition: background 0.15s;
        }

        .shift-row:last-child {
            border-bottom: none;
        }

        .shift-row:hover {
            background: #f0fdf4;
        }

        .shift-row.on-leave {
            background: #fef2f2;
            cursor: not-allowed;
            opacity: 0.75;
        }

        .shift-row input[type=checkbox] {
            width: 17px;
            height: 17px;
            accent-color: #16a34a;
            cursor: pointer;
        }

        .shift-row.on-leave input[type=checkbox] {
            cursor: not-allowed;
        }

        .shift-day {
            min-width: 108px;
            font-weight: 500;
            color: #334155;
            font-size: 13px;
        }

        .shift-name {
            flex: 1;
            font-size: 13px;
            color: #475569;
        }

        .shift-hours {
            font-size: 12px;
            color: #64748b;
            background: #f1f5f9;
            padding: 2px 9px;
            border-radius: 20px;
            white-space: nowrap;
        }

        .summary-box {
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 8px;
            padding: 10px 14px;
            font-size: 14px;
            color: #166534;
        }

        .summary-box strong {
            font-size: 16px;
        }

        .legend-note {
            font-size: 12.5px;
            color: #64748b;
        }
    </style>
</head>

<body>

<%-- Sidebar dùng chung --%>
<jsp:include page="/WEB-INF/views/fragments/employee-sidebar.jsp"/>

<div class="main-wrapper">
<div class="container py-4">

    <div class="page-header">
        <h2>Xin nghỉ phép</h2>
        <div class="page-actions">
            <a class="btn-soft"
               href="${pageContext.request.contextPath}/employee/forms">
                <i class="fa-solid fa-arrow-left"></i> Đơn từ &amp; Khiếu nại
            </a>
            <a class="btn-soft"
               href="${pageContext.request.contextPath}/employee/leave-request">
                <i class="fa-solid fa-rotate"></i> Tải lại
            </a>
        </div>
    </div>

    <c:if test="${param.success eq '1'}">
        <div class="alert alert-success">
            Gửi đơn thành công. Đang chờ Store Manager duyệt.
        </div>
    </c:if>

    <c:if test="${param.invalid eq '1'}">
        <div class="alert alert-warning">
            Không thể gửi đơn. Vui lòng kiểm tra lại thông tin.
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <c:out value="${error}"/>
        </div>
    </c:if>

    <!-- Thông tin loại nhân viên -->
    <div class="alert alert-light border d-flex align-items-center gap-2 mb-4">
        <i class="fa-solid fa-id-badge text-primary"></i>
        <span>
            Bạn là nhân viên
            <strong>
                <c:choose>
                    <c:when test="${isPartTime}">Part-time</c:when>
                    <c:otherwise>Full-time</c:otherwise>
                </c:choose>
            </strong>
            &nbsp;|&nbsp; Định mức làm việc:
            <strong><c:out value="${standardHoursPerDay}"/> giờ/ngày</strong>
            &nbsp;|&nbsp;
            <c:choose>
                <c:when test="${isPartTime}">
                    Quota nghỉ phép được tính theo <strong>CA</strong> bạn đã được xếp.
                </c:when>
                <c:otherwise>
                    Quota nghỉ phép được tính theo <strong>NGÀY</strong> và quy ra ca thực tế.
                </c:otherwise>
            </c:choose>
        </span>
    </div>

    <!-- Quota nghỉ phép -->
    <div class="card mb-4 shadow-sm">
        <div class="card-body">
            <h4 class="text-primary">
                Quota nghỉ phép năm <%= java.time.LocalDate.now().getYear() %>
                <small class="text-muted" style="font-size: 13px; font-weight: 400;">
                    (đơn vị: giờ làm việc)
                </small>
            </h4>

            <div class="table-responsive">
                <table class="table table-bordered mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Loại nghỉ phép</th>
                            <th>Tổng (giờ)</th>
                            <th>Đã dùng (giờ)</th>
                            <th>Còn lại (giờ)</th>
                            <th>Tương đương</th>
                            <th>Hưởng lương</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="b" items="${myBalances}">
                            <tr>
                                <td>
                                    <c:out value="${b.leaveTypeName}"/>
                                    <small class="text-muted">
                                        (<c:out value="${b.leaveTypeCode}"/>)
                                    </small>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${b.totalHours gt 0}">
                                            <c:out value="${b.totalHours}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">Không giới hạn</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:out value="${b.usedHours}"/>
                                    <small class="text-muted d-block">
                                        (đã duyệt + đang chờ duyệt)
                                    </small>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${b.totalHours gt 0}">
                                            <strong>
                                                <c:out value="${b.remainingHours}"/>
                                            </strong>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <small class="text-muted">
                                        <c:if test="${b.totalDays gt 0}">
                                            ~ <c:out value="${b.totalDays}"/>
                                            <c:choose>
                                                <c:when test="${isPartTime}">ca</c:when>
                                                <c:otherwise>ngày</c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </small>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${b.paidLeave}">
                                            <span class="badge bg-success">Có</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">Không</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty myBalances}">
                            <tr>
                                <td colspan="6" class="text-center text-muted">
                                    Chưa có quota nghỉ phép.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Tổng thời gian nghỉ theo từng loại -->
    <div class="card mb-4 shadow-sm">
        <div class="card-body">
            <h4 class="text-primary">
                Tổng thời gian nghỉ theo từng loại
                <small class="text-muted" style="font-size: 13px; font-weight: 400;">
                    năm <%= java.time.LocalDate.now().getYear() %>
                    (đơn vị: giờ làm việc)
                </small>
            </h4>

            <p class="text-muted" style="font-size: 13px;">
                <i class="fa-solid fa-circle-info"></i>
                <strong>Tổng</strong> = thời gian nghỉ đã được duyệt
                + thời gian nghỉ đang chờ duyệt.
                Đơn bị từối hoặc đã hủy không được tính vào tổng.
            </p>

            <div class="table-responsive">
                <table class="table table-bordered mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Loại nghỉ phép</th>
                            <th>Đã duyệt (giờ)</th>
                            <th>Chờ duyệt (giờ)</th>
                            <th>Tổng (giờ)</th>
                            <th>Số đơn</th>
                            <th>Chi tiết</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="s" items="${myLeaveSummary}">
                            <tr>
                                <td>
                                    <c:out value="${s.leaveTypeName}"/>
                                    <small class="text-muted">
                                        (<c:out value="${s.leaveTypeCode}"/>)
                                    </small>
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
                                <td>
                                    <small class="text-muted">
                                        <c:if test="${s.rejectedHours gt 0}">
                                            Bị từ chối:
                                            <c:out value="${s.rejectedHours}"/> giờ
                                            &nbsp;|&nbsp;
                                        </c:if>
                                        <c:if test="${s.cancelledHours gt 0}">
                                            Đã hủy:
                                            <c:out value="${s.cancelledHours}"/> giờ
                                        </c:if>
                                        <c:if test="${s.rejectedHours le 0 and s.cancelledHours le 0}">
                                            Không có đơn bị từ chối/hủy
                                        </c:if>
                                    </small>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty myLeaveSummary}">
                            <tr>
                                <td colspan="6" class="text-center text-muted">
                                    Chưa có đơn nghỉ phép nào trong năm.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Form tạo đơn -->
    <div class="card mb-4 shadow-sm">
        <div class="card-body">
            <h4 class="text-primary">Tạo đơn nghỉ phép</h4>

            <form method="post" id="leaveForm"
                  action="${pageContext.request.contextPath}/employee/leave-request">

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Loại nghỉ phép</label>
                        <select name="leaveTypeId" id="leaveTypeId"
                                class="form-select" required>
                            <option value="">-- Chọn loại nghỉ --</option>
                            <c:forEach var="t" items="${leaveTypes}">
                                <option value="${t.id}"
                                        data-notice="${t.noticeHours}"
                                        data-notice-pt="${t.noticeHoursPartTime}"
                                        data-same-day="${t.sameDayAllowed}">
                                    <c:out value="${t.name}"/>
                                    (<c:out value="${t.code}"/>)
                                    - <c:out value="${t.defaultDays}"/>
                                    <c:choose>
                                        <c:when test="${isPartTime}">ca</c:when>
                                        <c:otherwise>ngày</c:otherwise>
                                    </c:choose>/năm
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <c:if test="${not isPartTime}">
                        <div class="col-md-3 mb-3">
                            <label class="form-label">Từ ngày</label>
                            <input type="date" name="startDate" id="startDate"
                                   class="form-control" required
                                   min="<%= java.time.LocalDate.now() %>">
                        </div>

                        <div class="col-md-3 mb-3">
                            <label class="form-label">Đến ngày</label>
                            <input type="date" name="endDate" id="endDate"
                                   class="form-control" required
                                   min="<%= java.time.LocalDate.now() %>">
                        </div>
                    </c:if>
                </div>

                <%-- ============ PART-TIME: chọn theo CA ============ --%>
                <c:if test="${isPartTime}">
                    <div class="mb-3">
                        <label class="form-label">
                            Chọn ca muốn nghỉ
                            <span class="text-muted" style="font-weight: 400;">
                                (tuần bắt đầu từ <c:out value="${leaveWeekStart}"/>)
                            </span>
                        </label>

                        <div class="shift-picker">
                            <div class="shift-picker-header">
                                <c:choose>
                                    <c:when test="${hasPublishedSchedule}">
                                        <i class="fa-solid fa-calendar-check text-success"></i>
                                        Ca của bạn đã được xếp trong tuần này
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-solid fa-calendar-day text-warning"></i>
                                        Lịch tuần này chưa được công bố -
                                        chọn ca theo ca cố định của bạn
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="shift-list">
                                <%-- Ca đã được xếp + ca cố định cho ngày chưa có lịch --%>
                                <c:forEach var="s" items="${shiftChoices}">
                                    <label class="shift-row ${s.onLeave ? 'on-leave' : ''}">
                                        <input type="checkbox"
                                               name="selectedShifts"
                                               value="${s.workDate}_${s.shiftId}"
                                               data-date="${s.workDate}"
                                               data-on-leave="${s.onLeave}"
                                               data-hours="${s.hours}"
                                               <c:if test="${s.onLeave}">disabled</c:if>>
                                        <span class="shift-day">
                                            <c:out value="${s.workDate}"/>
                                            <c:if test="${!s.scheduled}">
                                                <small class="text-muted">(dự kiến)</small>
                                            </c:if>
                                        </span>
                                        <span class="shift-name">
                                            <c:out value="${s.shiftName}"/>
                                            (<c:out value="${s.startTime}"/>
                                            - <c:out value="${s.endTime}"/>)
                                            <c:if test="${s.onLeave}">
                                                <span class="badge bg-secondary">Đã nghỉ</span>
                                            </c:if>
                                        </span>
                                        <span class="shift-hours">
                                            <c:out value="${s.hours}"/> giờ
                                        </span>
                                    </label>
                                </c:forEach>

                                <c:if test="${empty shiftChoices}">
                                    <div class="p-3 text-center text-muted"
                                         style="font-style: italic;">
                                        Bạn chưa có ca nào được xếp.
                                        Vui lòng liên hệ Store Manager.
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <div class="summary-box mt-2" id="shiftSummary"
                             style="display:none;">
                            <i class="fa-solid fa-calculator"></i>
                            Đã chọn <strong id="selectedCount">0</strong> ca
                            &nbsp;=&nbsp; tổng
                            <strong id="selectedHours">0</strong> giờ nghỉ
                        </div>

                        <div class="legend-note mt-1">
                            <i class="fa-solid fa-info-circle"></i>
                            Chỉ những ca đã được xếp mới có thể xin nghỉ.
                            Nếu tuần lịch chưa được công bố, hệ thống sẽ
                            khớp lại khi lịch được publish.
                        </div>
                    </div>
                </c:if>

                <div class="alert alert-info py-2 mb-3">
                    <i class="fa-solid fa-circle-info"></i>
                    <strong>Quy định:</strong> mỗi loại nghỉ có thời hạn
                    gửi đơn khác nhau. Bạn được gửi đơn <strong>sớm bất cứ
                    lúc nào</strong>, hệ thống chỉ chặn khi bạn gửi
                    <strong>quá muộn</strong>.
                    <ul class="mb-0 mt-1">
                        <c:forEach var="t" items="${leaveTypes}">
                            <li>
                                <strong><c:out value="${t.name}"/>:</strong>
                                <c:choose>
                                    <c:when test="${t.sameDayAllowed}">
                                        gửi trong ngày được
                                        (không kiểm tra hạn báo trước)
                                    </c:when>
                                    <c:when test="${isPartTime}">
                                        báo trước tối thiểu
                                        <c:out value="${t.noticeHoursPartTime}"/>
                                        giờ
                                        <c:if test="${t.noticeHoursPartTime ne t.noticeHours}">
                                            (quy định riêng cho nhân viên part-time)
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        báo trước tối thiểu
                                        <c:out value="${t.noticeHours}"/>
                                        giờ
                                    </c:otherwise>
                                </c:choose>
                            </li>
                        </c:forEach>
                    </ul>
                    <c:if test="${isPartTime}">
                        <div class="mt-1 fst-italic">
                            Quy định cho part-time được cấu hình riêng trong
                            hệ thống. Nếu thời hạn ngắn hơn quy định của
                            nhân viên full-time, bạn cần gửi đơn sớm hơn.
                        </div>
                    </c:if>
                    <div id="deadlineHint" class="mt-1"></div>

                    <%-- Định nghĩa ca: giúp nhân viên hiểu 1 ca nghỉ
                         được tính bao nhiêu giờ (đơn vị quota là GIỜ) --%>
                    <c:if test="${not empty shiftDefinitions}">
                        <hr class="my-2">
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
                        <div class="legend-note mt-1">
                            <i class="fa-solid fa-circle-info"></i>
                            Quota nghỉ phép được tính theo <strong>giờ</strong>.
                            Ví dụ nghỉ 1 ca Sáng = 5 giờ, nghỉ 1 ca Full-time
                            = 10 giờ.
                        </div>
                    </c:if>
                </div>

                <div id="clientError" class="alert alert-danger py-2 mb-3"
                     style="display:none;"></div>

                <div class="mb-3">
                    <label class="form-label">Lý do nghỉ phép</label>
                    <textarea name="reason" rows="3"
                              maxlength="500"
                              class="form-control"
                              placeholder="Nhập lý do nghỉ phép (tối đa 500 ký tự)..."
                              required></textarea>
                </div>

                <button type="submit" class="btn btn-success" id="submitBtn">
                    Gửi đơn xin nghỉ phép
                </button>
            </form>
        </div>
    </div>

    <!-- Lịch sử đơn -->
    <div class="card shadow-sm">
        <div class="card-body">
            <h4>Lịch sử đơn nghỉ phép</h4>

            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Loại</th>
                            <th>Từ ngày</th>
                            <th>Đến ngày</th>
                            <th>Thời lượng</th>
                            <th>Lý do</th>
                            <th>Trạng thái</th>
                            <th>Phản hồi</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${myRequests}">
                            <tr>
                                <td>${r.id}</td>
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
                                <td>
                                    <c:if test="${r.status eq 'PENDING'}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/employee/leave-request"
                                              style="display:inline">
                                            <input type="hidden"
                                                   name="action"
                                                   value="cancel">
                                            <input type="hidden"
                                                   name="requestId"
                                                   value="${r.id}">
                                            <button type="submit"
                                                    class="btn btn-outline-danger btn-sm"
                                                    onclick="return confirm('Hủy đơn này?');">
                                                Hủy đơn
                                            </button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty myRequests}">
                            <tr>
                                <td colspan="9" class="text-center text-muted">
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
<script>
    (function () {
        var IS_PART_TIME = <c:out value="${isPartTime}"/>;

        var VN_WEEKDAYS = [
            'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm',
            'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'
        ];

        var typeEl = document.getElementById('leaveTypeId');
        var startEl = document.getElementById('startDate');
        var endEl = document.getElementById('endDate');
        var hintEl = document.getElementById('deadlineHint');
        var clientErrorEl = document.getElementById('clientError');
        var submitBtn = document.getElementById('submitBtn');

        function parseISO(s) {
            if (!s) {
                return null;
            }
            var p = s.split('-');
            if (p.length !== 3) {
                return null;
            }
            return new Date(
                parseInt(p[0], 10),
                parseInt(p[1], 10) - 1,
                parseInt(p[2], 10)
            );
        }

        function toISO(d) {
            var m = String(d.getMonth() + 1).padStart(2, '0');
            var day = String(d.getDate()).padStart(2, '0');
            return d.getFullYear() + '-' + m + '-' + day;
        }

        function fmtVn(d) {
            var dd = String(d.getDate()).padStart(2, '0');
            var mm = String(d.getMonth() + 1).padStart(2, '0');
            var wd = VN_WEEKDAYS[(d.getDay() + 6) % 7];
            return wd + ' (' + dd + '/' + mm + '/' + d.getFullYear() + ')';
        }

        function fmtHours(h) {
            if (h % 24 === 0) {
                return (h / 24) + ' ngày';
            }
            return h + ' giờ';
        }

        // ---------------- Thông tin loại nghỉ đang chọn ----------------
        function currentOption() {
            if (!typeEl) {
                return null;
            }
            var opt = typeEl.options[typeEl.selectedIndex];
            if (!opt || !opt.value) {
                return null;
            }
            return opt;
        }

        // Số giờ báo trước của loại nghỉ đang chọn (theo loại nhân viên)
        function getNoticeHours() {
            var opt = currentOption();
            if (!opt) {
                return null;
            }
            var attr = IS_PART_TIME
                ? opt.getAttribute('data-notice-pt')
                : opt.getAttribute('data-notice');
            var v = parseInt(attr, 10);
            return isNaN(v) ? null : v;
        }

        // Loại nghỉ được làm đơn trong ngày (nghỉ ốm, nghỉ tang)
        // -> KHÔNG validate hạn báo trước.
        function isSameDayAllowed() {
            var opt = currentOption();
            if (!opt) {
                return false;
            }
            return opt.getAttribute('data-same-day') === 'true';
        }

        // Số ngày tối thiểu phải báo trước (0 nếu notice < 24 giờ)
        function getLeadDays(notice) {
            if (notice === null || notice < 24) {
                return 0;
            }
            return Math.ceil(notice / 24);
        }

        // Hạn gửi đơn cho ngày nghỉ D.
        // Trả về:
        //   {date: LocalDate}  -> hạn theo NGÀY (gửi được đến hết ngày)
        //   {dt: DateTime}     -> hạn theo GIỜ cụ thể
        function getDeadline(leaveDate, notice) {
            if (notice >= 24) {
                var d = new Date(leaveDate.getTime());
                d.setDate(d.getDate() - getLeadDays(notice));
                d.setHours(0, 0, 0, 0);
                return {date: d};
            }
            var dt = new Date(leaveDate.getTime());
            dt.setHours(0, 0, 0, 0);
            dt.setHours(dt.getHours() - notice);
            return {dt: dt};
        }

        function isOverdue(deadline) {
            var now = new Date();
            if (deadline.date) {
                // Được gửi đến hết ngày hạn (23:59).
                var endOfDeadline = new Date(deadline.date.getTime());
                endOfDeadline.setHours(23, 59, 59, 999);
                return now.getTime() > endOfDeadline.getTime();
            }
            return now.getTime() > deadline.dt.getTime();
        }

        // Chỉ hiện lỗi sau khi người dùng đã tương tác với form
        // (tránh báo lỗi ngay khi vừa mở trang).
        var touched = false;

        function setClientError(msg) {
            if (!clientErrorEl) {
                return;
            }
            if (msg && touched) {
                clientErrorEl.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> '
                    + msg;
                clientErrorEl.style.display = 'block';
            } else {
                clientErrorEl.innerHTML = '';
                clientErrorEl.style.display = 'none';
            }
        }

        // ---------------- PART-TIME: tính tổng giờ đã chọn -------------
        function refreshShiftSummary() {
            var boxes = document.querySelectorAll(
                'input[name="selectedShifts"]');
            var countEl = document.getElementById('selectedCount');
            var hoursEl = document.getElementById('selectedHours');
            var sumEl = document.getElementById('shiftSummary');

            var count = 0;
            var hours = 0;

            Array.prototype.forEach.call(boxes, function (b) {
                if (b.checked) {
                    count++;
                    hours += parseFloat(b.getAttribute('data-hours')) || 0;
                }
            });

            if (countEl) {
                countEl.textContent = count;
            }
            if (hoursEl) {
                hoursEl.textContent = (hours % 1 === 0)
                    ? hours
                    : Math.round(hours * 100) / 100;
            }
            if (sumEl) {
                sumEl.style.display = count > 0 ? 'block' : 'none';
            }
            return count;
        }

        function initShiftPicker() {
            var boxes = document.querySelectorAll(
                'input[name="selectedShifts"]');
            if (!boxes.length) {
                return;
            }

            Array.prototype.forEach.call(boxes, function (b) {
                b.addEventListener('change', refreshShiftSummary);
            });

            refreshShiftSummary();
        }

        // =============== VALIDATE TOÀN BỘ FORM =====================
        function validate() {
            if (!typeEl) {
                return;
            }

            var opt = currentOption();
            var notice = getNoticeHours();
            var todayISO = toISO(new Date());
            var today = parseISO(todayISO);
            var error = null;

            // Chưa chọn loại nghỉ
            if (!opt) {
                if (startEl) {
                    startEl.min = todayISO;
                    endEl.min = todayISO;
                }
                if (hintEl) {
                    hintEl.textContent =
                        'Vui lòng chọn loại nghỉ để xem hạn chót gửi đơn.';
                }
                setClientError('');
                if (submitBtn) {
                    submitBtn.disabled = true;
                }
                return;
            }

            // Ngày nghỉ không được nằm trong quá khứ
            if (startEl) {
                startEl.min = todayISO;
                endEl.min = todayISO;
            }

            // ---- Loại nghỉ ốm / nghỉ tang: làm đơn trong ngày, KHÔNG
            //      validate hạn báo trước ----
            if (isSameDayAllowed()) {
                if (hintEl) {
                    hintEl.innerHTML =
                        '<span class="text-success fw-bold">'
                        + 'Loại nghỉ này được <strong>gửi đơn trong ngày</strong>'
                        + ' (không kiểm tra hạn báo trước).</span>';
                }
                setClientError('');

                if (IS_PART_TIME) {
                    validatePartTime(notice, true);
                } else {
                    validateFullTime(notice, true);
                }
                return;
            }

            // ---- Loại nghỉ có hạn báo trước ----
            var extra = IS_PART_TIME
                ? ' (quy định cho nhân viên part-time)'
                : '';

            if (notice === null || notice <= 0) {
                if (hintEl) {
                    hintEl.innerHTML =
                        'Loại nghỉ này <strong>gửi đơn trong ngày được</strong>.';
                }
                setClientError('');
                if (IS_PART_TIME) {
                    validatePartTime(0, false);
                } else {
                    validateFullTime(0, false);
                }
                return;
            }

            var hintText = 'Loại nghỉ này yêu cầu báo trước <strong>tối thiểu '
                + fmtHours(notice) + '</strong>' + extra
                + '. Bạn được gửi đơn sớm bất cứ lúc nào; '
                + 'hệ thống chỉ chặn khi gửi quá muộn.';

            // Full-time: hiển thị hạn cụ thể cho ngày đã chọn
            if (!IS_PART_TIME && startEl) {
                var picked = parseISO(startEl.value);
                if (picked) {
                    var dl = getDeadline(picked, notice);
                    hintText += '<br>Đơn cho ngày <strong>' + fmtVn(picked)
                        + '</strong> được gửi từ <strong>'
                        + (dl.date ? fmtVn(dl.date) : fmtVn(dl.dt))
                        + '</strong> trở đi.';
                }
            }

            if (hintEl) {
                hintEl.innerHTML = hintText;
            }

            if (IS_PART_TIME) {
                validatePartTime(notice, false);
            } else {
                validateFullTime(notice, false);
            }
        }

        // -------- Full-time: chọn khoảng ngày --------
        function validateFullTime(notice, sameDay) {
            var error = null;

            var start = startEl ? parseISO(startEl.value) : null;
            var end = endEl ? parseISO(endEl.value) : null;

            if (!start) {
                error = 'Vui lòng chọn ngày bắt đầu nghỉ.';
            } else if (startEl.value < toISO(new Date())) {
                error = 'Không thể xin nghỉ cho ngày trong quá khứ.';
            } else if (end && endEl.value < startEl.value) {
                error = 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.';
            } else if (!sameDay && notice > 0) {
                var dl = getDeadline(start, notice);
                if (isOverdue(dl)) {
                    if (dl.date) {
                        error = 'Đơn nghỉ phép đã quá hạn gửi. Loại nghỉ này yêu cầu '
                            + 'báo trước tối thiểu ' + getLeadDays(notice)
                            + ' ngày. Đơn cho ngày ' + fmtVn(start)
                            + ' chỉ được gửi từ <strong>'
                            + fmtVn(dl.date) + '</strong> trở đi.';
                    } else {
                        error = 'Đơn nghỉ phép đã quá hạn gửi. Loại nghỉ này yêu cầu '
                            + 'báo trước tối thiểu ' + notice
                            + ' giờ. Đơn cho ngày ' + fmtVn(start)
                            + ' chỉ được gửi trước <strong>'
                            + fmtVn(dl.dt) + '</strong>.';
                    }
                }
            }

            setClientError(error);
            if (submitBtn) {
                submitBtn.disabled = !!error;
            }
        }

        // -------- Part-time: tick ca --------
        function validatePartTime(notice, sameDay) {
            var boxes = document.querySelectorAll(
                'input[name="selectedShifts"]');
            var error = null;
            var count = 0;
            var overdueCount = 0;
            var pastCount = 0;
            var today = parseISO(toISO(new Date()));

            Array.prototype.forEach.call(boxes, function (b) {
                var onLeave = b.getAttribute('data-on-leave') === 'true';
                var d = parseISO(b.getAttribute('data-date'));

                // Ca đang ON_LEAVE: không bao giờ tick được
                if (onLeave) {
                    b.disabled = true;
                    b.checked = false;
                    b.title = 'Ca này bạn đang nghỉ.';
                    return;
                }

                b.disabled = false;
                b.title = '';

                if (!d) {
                    return;
                }

                // Ngày trong quá khứ -> không được tick
                if (d < today) {
                    b.disabled = true;
                    b.checked = false;
                    b.title = 'Không thể xin nghỉ cho ngày trong quá khứ.';
                    pastCount++;
                    return;
                }

                // Quá hạn báo trước -> không được tick
                if (!sameDay && notice > 0) {
                    var dl = getDeadline(d, notice);
                    if (isOverdue(dl)) {
                        b.disabled = true;
                        b.checked = false;
                        b.title = dl.date
                            ? 'Đã quá hạn gửi đơn (hạn: ' + fmtVn(dl.date) + ')'
                            : 'Đã quá hạn gửi đơn';
                        overdueCount++;
                        return;
                    }
                }

                if (b.checked) {
                    count++;
                }
            });

            refreshShiftSummary();

            if (overdueCount > 0) {
                error = 'Có <strong>' + overdueCount + '</strong> ca đã quá hạn '
                    + 'gửi đơn nên không thể chọn. '
                    + 'Loại nghỉ này yêu cầu báo trước tối thiểu '
                    + fmtHours(notice) + '.';
            } else if (pastCount > 0) {
                error = 'Có <strong>' + pastCount + '</strong> ca thuộc ngày '
                    + 'trong quá khứ nên không thể chọn.';
            }

            setClientError(error);
            if (submitBtn) {
                submitBtn.disabled = (count === 0);
            }
        }

        if (typeEl) {
            typeEl.addEventListener('change', function () {
                touched = true;
                validate();
            });
        }
        if (startEl) {
            startEl.addEventListener('change', function () {
                touched = true;
                validate();
            });
        }
        if (endEl) {
            endEl.addEventListener('change', function () {
                touched = true;
                if (startEl.value && endEl.value < startEl.value) {
                    endEl.value = startEl.value;
                }
                validate();
            });
        }

        // Chặn submit nếu còn lỗi validate
        var form = document.getElementById('leaveForm');
        if (form) {
            form.addEventListener('submit', function (e) {
                touched = true;
                validate();
                if (submitBtn && submitBtn.disabled) {
                    e.preventDefault();
                }
            });
        }

        initShiftPicker();
        validate();
    })();
</script>
</body>
</html>
