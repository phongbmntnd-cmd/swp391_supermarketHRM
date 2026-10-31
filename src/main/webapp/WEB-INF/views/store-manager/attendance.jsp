<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chấm công cửa hàng</title>
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

        /* ---- Thẻ thống kê ---- */
        .stat-card {
            border: none;
            border-radius: 12px;
            padding: 18px 20px;
            color: #fff;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            height: 100%;
        }

        .stat-card .stat-label {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            opacity: 0.9;
            margin-bottom: 6px;
        }

        .stat-card .stat-value {
            font-size: 26px;
            font-weight: 700;
            line-height: 1.1;
        }

        .stat-card .stat-sub {
            font-size: 12px;
            opacity: 0.85;
            margin-top: 4px;
        }

        .stat-blue   { background: linear-gradient(135deg, #2563eb, #3b82f6); }
        .stat-green  { background: linear-gradient(135deg, #059669, #10b981); }
        .stat-amber  { background: linear-gradient(135deg, #d97706, #f59e0b); }
        .stat-slate  { background: linear-gradient(135deg, #475569, #64748b); }

        /* ---- Bộ lọc ---- */
        .filter-bar {
            background: #ffffff;
            border-radius: 12px;
            padding: 16px 18px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        }

        .filter-bar .form-label {
            font-size: 12px;
            font-weight: 500;
            color: #64748b;
            margin-bottom: 4px;
        }

        .table thead th {
            background: #1e293b;
            color: #fff;
            font-size: 13px;
            font-weight: 500;
        }

        .table tbody td {
            font-size: 13px;
            vertical-align: middle;
        }

        .empty-state {
            text-align: center;
            padding: 45px 20px;
            color: #94a3b8;
        }

        .empty-state i {
            font-size: 42px;
            margin-bottom: 12px;
            opacity: 0.5;
            display: block;
        }

        /* ---- Badge trạng thái ---- */
        .badge-status {
            font-size: 11px;
            padding: 4px 9px;
            border-radius: 20px;
            font-weight: 500;
        }

        .badge-valid   { background: #dcfce7; color: #15803d; }
        .badge-invalid { background: #fee2e2; color: #b91c1c; }
        .badge-adjusted{ background: #dbeafe; color: #1d4ed8; }

        .method-tag {
            font-size: 11px;
            padding: 3px 8px;
            border-radius: 6px;
            background: #f1f5f9;
            color: #475569;
            font-weight: 500;
        }

        /* ---- Thanh tiến trình ---- */
        .ratio-bar {
            height: 6px;
            border-radius: 3px;
            background: #e2e8f0;
            overflow: hidden;
            min-width: 70px;
        }

        .ratio-bar > span {
            display: block;
            height: 100%;
            background: #10b981;
            border-radius: 3px;
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/fragments/store-manager-sidebar.jsp"/>

<div class="main-wrapper">
<div class="container py-4">

    <div class="page-header">
        <h2>Chấm công cửa hàng</h2>
        <div>
            <a class="btn-soft"
               href="${pageContext.request.contextPath}/store-manager/dashboard">
                <i class="fa-solid fa-house"></i> Dashboard
            </a>
        </div>
    </div>

    <!-- ===== Thống kê tổng quan ===== -->
    <div class="row g-3 mb-4">
        <div class="col-md-3 col-sm-6">
            <div class="stat-card stat-blue">
                <div class="stat-label">Tổng bản ghi</div>
                <div class="stat-value"><c:out value="${totalRecords}"/></div>
                <div class="stat-sub">
                    từ <c:out value="${from}"/> đến <c:out value="${to}"/>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card stat-green">
                <div class="stat-label">Bản ghi đủ cặp</div>
                <div class="stat-value"><c:out value="${completeRecords}"/></div>
                <div class="stat-sub">có cả check-in &amp; check-out</div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card stat-amber">
                <div class="stat-label">Tổng giờ làm</div>
                <div class="stat-value">
                    <c:out value="${totalHours}"/>
                </div>
                <div class="stat-sub">giờ trong khoảng lọc</div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card stat-slate">
                <div class="stat-label">Số ngày có dữ liệu</div>
                <div class="stat-value">
                    <c:out value="${dailySummary.size()}"/>
                </div>
                <div class="stat-sub">ngày được ghi nhận</div>
            </div>
        </div>
    </div>

    <!-- ===== Bộ lọc ===== -->
    <div class="filter-bar mb-4">
        <form method="get"
              action="${pageContext.request.contextPath}/store-manager/attendance"
              class="row g-3 align-items-end">
            <div class="col-md-3">
                <label class="form-label" for="from">Từ ngày</label>
                <input type="date" class="form-control form-control-sm"
                       id="from" name="from" value="<c:out value="${from}"/>">
            </div>
            <div class="col-md-3">
                <label class="form-label" for="to">Đến ngày</label>
                <input type="date" class="form-control form-control-sm"
                       id="to" name="to" value="<c:out value="${to}"/>">
            </div>
            <div class="col-md-3">
                <label class="form-label" for="status">Trạng thái</label>
                <select class="form-select form-select-sm"
                        id="status" name="status">
                    <option value="">Tất cả</option>
                    <option value="VALID"
                        <c:if test="${statusFilter eq 'VALID'}">selected</c:if>>
                        Hợp lệ
                    </option>
                    <option value="INVALID"
                        <c:if test="${statusFilter eq 'INVALID'}">selected</c:if>>
                        Không hợp lệ
                    </option>
                    <option value="ADJUSTED"
                        <c:if test="${statusFilter eq 'ADJUSTED'}">selected</c:if>>
                        Đã điều chỉnh
                    </option>
                </select>
            </div>
            <div class="col-md-3">
                <button type="submit" class="btn btn-primary btn-sm w-100">
                    <i class="fa-solid fa-filter"></i> Lọc
                </button>
            </div>
        </form>
    </div>

    <!-- ===== Tổng hợp theo ngày ===== -->
    <c:if test="${not empty dailySummary}">
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h4 style="font-size: 17px; font-weight: 600; color: #1e293b;">
                <i class="fa-solid fa-chart-simple"></i> Tổng hợp theo ngày
            </h4>
            <div class="table-responsive">
                <table class="table table-bordered table-hover mb-0">
                    <thead>
                        <tr>
                            <th>Ngày</th>
                            <th>Tổng bản ghi</th>
                            <th>Có mặt</th>
                            <th>Đi muộn</th>
                            <th>Vắng</th>
                            <th>Tỉ lệ có mặt</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="entry" items="${dailySummary}">
                            <c:set var="d" value="${entry.value}"/>
                            <tr>
                                <td>
                                    <c:out value="${d.workDateText}"/>
                                </td>
                                <td><c:out value="${d.total}"/></td>
                                <td class="text-success fw-medium">
                                    <c:out value="${d.present}"/>
                                </td>
                                <td class="text-warning fw-medium">
                                    <c:out value="${d.late}"/>
                                </td>
                                <td class="text-danger fw-medium">
                                    <c:out value="${d.absent}"/>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="ratio-bar">
                                            <span style="width: ${d.presentRatio}%;"></span>
                                        </div>
                                        <small class="text-muted">
                                            <c:out value="${d.presentRatio}"/>%
                                        </small>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    </c:if>

    <!-- ===== Danh sách chi tiết ===== -->
    <div class="card shadow-sm">
        <div class="card-body">
            <h4 style="font-size: 17px; font-weight: 600; color: #1e293b;">
                <i class="fa-solid fa-list"></i> Chi tiết chấm công
            </h4>

            <c:choose>
                <c:when test="${empty attendanceList}">
                    <div class="empty-state">
                        <i class="fa-solid fa-clipboard-user"></i>
                        Không có bản ghi chấm công nào trong khoảng thời gian
                        đã chọn.
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Nhân viên</th>
                                    <th>Ngày</th>
                                    <th>Check-in</th>
                                    <th>Check-out</th>
                                    <th>Giờ làm</th>
                                    <th>Phương thức</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="a" items="${attendanceList}">
                                    <tr>
                                        <td class="text-muted">
                                            <c:out value="${a.id}"/>
                                        </td>
                                        <td>
                                            <c:out value="${a.fullName}"/>
                                            <small class="text-muted d-block">
                                                <c:out value="${a.username}"/>
                                            </small>
                                        </td>
                                        <td><c:out value="${a.dateText}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty a.checkIn}">
                                                    <c:out value="${a.checkInText}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty a.checkOut}">
                                                    <c:out value="${a.checkOutText}"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.complete}">
                                                    <strong>
                                                        <c:out value="${a.workedHoursText}"/>
                                                    </strong>
                                                    <small class="text-muted">h</small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="method-tag">
                                                <c:out value="${a.method}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${a.status eq 'VALID'}">
                                                    <span class="badge-status badge-valid">Hợp lệ</span>
                                                </c:when>
                                                <c:when test="${a.status eq 'INVALID'}">
                                                    <span class="badge-status badge-invalid">Không hợp lệ</span>
                                                </c:when>
                                                <c:when test="${a.status eq 'ADJUSTED'}">
                                                    <span class="badge-status badge-adjusted">Đã điều chỉnh</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

</div>
</div>

</body>
</html>
