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

    <!-- Quota nghỉ phép -->
    <div class="card mb-4 shadow-sm">
        <div class="card-body">
            <h4 class="text-primary">Quota nghỉ phép năm <%= java.time.LocalDate.now().getYear() %></h4>

            <div class="table-responsive">
                <table class="table table-bordered mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Loại nghỉ phép</th>
                            <th>Tổng</th>
                            <th>Đã dùng</th>
                            <th>Còn lại</th>
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
                                <td>${b.totalDays}</td>
                                <td>${b.usedDays}</td>
                                <td><strong>${b.remainingDays}</strong></td>
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
                                <td colspan="5" class="text-center text-muted">
                                    Chưa có quota nghỉ phép.
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

            <form method="post"
                  action="${pageContext.request.contextPath}/employee/leave-request">

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Loại nghỉ phép</label>
                        <select name="leaveTypeId" id="leaveTypeId"
                                class="form-select" required>
                            <option value="">-- Chọn loại nghỉ --</option>
                            <c:forEach var="t" items="${leaveTypes}">
                                <option value="${t.id}"
                                        data-notice="${t.noticeHours}">
                                    <c:out value="${t.name}"/>
                                    (<c:out value="${t.code}"/>)
                                    - <c:out value="${t.defaultDays}"/> ngày/năm
                                </option>
                            </c:forEach>
                        </select>
                    </div>

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
                </div>

                <div class="alert alert-info py-2 mb-3">
                    <i class="fa-solid fa-circle-info"></i>
                    <strong>Quy định:</strong> mỗi loại nghỉ có thời hạn
                    gửi đơn khác nhau:
                    <ul class="mb-0 mt-1">
                        <li><strong>Nghỉ phép năm:</strong> báo trước 2 ngày
                            (nghỉ Thứ Hai phải gửi từ Thứ Bảy trở đi)</li>
                        <li><strong>Nghỉ không lương:</strong> báo trước 1 ngày</li>
                        <li><strong>Nghỉ ốm:</strong> báo trước tối thiểu 4 giờ</li>
                        <li><strong>Nghỉ tang:</strong> gửi trong ngày được</li>
                    </ul>
                    <div id="deadlineHint" class="mt-1"></div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Lý do nghỉ phép</label>
                    <textarea name="reason" rows="3"
                              maxlength="500"
                              class="form-control"
                              placeholder="Nhập lý do nghỉ phép (tối đa 500 ký tự)..."
                              required></textarea>
                </div>

                <button type="submit" class="btn btn-success">
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
                            <th>Số ngày</th>
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
                                <td>${r.totalDays}</td>
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
    // Quy định: hạn chót gửi đơn = ngày liền trước 2 ngày của ngày
    // bắt đầu nghỉ (nghỉ Thứ Hai => gửi từ Thứ Bảy trở đi).
    (function () {
        var VN_WEEKDAYS = [
            'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm',
            'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'
        ];

        var typeEl = document.getElementById('leaveTypeId');
        var startEl = document.getElementById('startDate');
        var endEl = document.getElementById('endDate');
        var hintEl = document.getElementById('deadlineHint');

        if (!typeEl || !startEl || !endEl) {
            return;
        }

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

        // Số giờ báo trước của loại nghỉ đang chọn
        function getNoticeHours() {
            var opt = typeEl.options[typeEl.selectedIndex];
            if (!opt || !opt.value) {
                return null;
            }
            var v = parseInt(opt.getAttribute('data-notice'), 10);
            return isNaN(v) ? null : v;
        }

        function update() {
            var start = parseISO(startEl.value);
            var notice = getNoticeHours();

            // Chưa chọn loại nghỉ: chỉ chặn ngày quá khứ
            if (notice === null) {
                var todayISO = toISO(new Date());
                startEl.min = todayISO;
                endEl.min = todayISO;
                if (hintEl) {
                    hintEl.textContent = 'Vui lòng chọn loại nghỉ để xem hạn chót gửi đơn.';
                }
                return;
            }

            // notice = 0: gửi trong ngày được -> chỉ chặn quá khứ
            if (notice === 0) {
                var t0 = toISO(new Date());
                startEl.min = t0;
                endEl.min = t0;
                if (hintEl) {
                    hintEl.innerHTML =
                        'Loại nghỉ này <strong>gửi đơn trong ngày được</strong>.';
                }
                return;
            }

            if (!start) {
                startEl.min = toISO(new Date());
                endEl.min = startEl.min;
                if (hintEl) {
                    hintEl.textContent = '';
                }
                return;
            }

            // Mốc chót: thời điểm SỚM NHẤT được gửi đơn
            // (00:00 ngày bắt đầu trừ notice giờ).
            var deadline = new Date(start);
            deadline.setHours(deadline.getHours() - notice);

            // Ngày bắt đầu tối thiểu hợp lệ:
            //  - loại >= 24h: phải nghỉ từ ngày mai trở đi
            //  - loại < 24h (vd nghỉ ốm 4h): nghỉ trong ngày vẫn được
            var today = new Date();
            today.setHours(0, 0, 0, 0);

            var minStart = new Date(today);
            if (notice >= 24) {
                minStart.setDate(minStart.getDate() + 1);
            }

            // Nếu mốc chót của ngày đã chọn còn ở tương lai
            // thì ngày đó chưa tới hạn gửi -> báo lỗi.
            var now = new Date();
            var tooEarly = now.getTime() < deadline.getTime();

            startEl.min = toISO(minStart);
            endEl.min = startEl.min;

            if (hintEl) {
                if (tooEarly || start < minStart) {
                    hintEl.innerHTML =
                        '<span class="text-danger fw-bold">'
                        + 'Chưa tới hạn gửi đơn. Loại nghỉ này yêu cầu báo trước '
                        + fmtHours(notice) + '. Đơn cho ngày '
                        + fmtVn(start) + ' chỉ được gửi từ <strong>'
                        + fmtVn(deadline) + '</strong> trở đi.</span>';
                } else {
                    hintEl.innerHTML =
                        'Loại nghỉ này yêu cầu báo trước <strong>'
                        + fmtHours(notice) + '</strong>. Đơn cho ngày '
                        + '<strong>' + fmtVn(start)
                        + '</strong> được gửi từ <strong>'
                        + fmtVn(deadline) + '</strong> trở đi.';
                }
            }
        }

        typeEl.addEventListener('change', update);
        startEl.addEventListener('change', update);
        endEl.addEventListener('change', function () {
            if (startEl.value && endEl.value < startEl.value) {
                endEl.value = startEl.value;
            }
            update();
        });

        update();
    })();
</script>
</body>
</html>