<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Chấm công &amp; Ca làm</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f4f7f6;
        }

        .stat-card {
            border: none;
            border-radius: 12px;
            padding: 18px 20px;
            color: #fff;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
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

        .stat-card .stat-sub { font-size: 12px; opacity: 0.85; margin-top: 4px; }

        .stat-blue  { background: linear-gradient(135deg, #2563eb, #3b82f6); }
        .stat-green { background: linear-gradient(135deg, #059669, #10b981); }
        .stat-amber { background: linear-gradient(135deg, #d97706, #f59e0b); }
        .stat-slate { background: linear-gradient(135deg, #475569, #64748b); }

        .panel {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid #f1f5f9;
        }

        .panel-title {
            font-size: 17px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .panel-title i { color: #0284c7; }

        .table thead th {
            background: #1e293b;
            color: #fff;
            font-size: 13px;
            font-weight: 500;
        }

        .table tbody td { font-size: 13px; vertical-align: middle; }

        .badge-status { font-size: 11px; padding: 4px 9px; border-radius: 20px; font-weight: 500; }
        .badge-valid    { background: #dcfce7; color: #15803d; }
        .badge-invalid  { background: #fee2e2; color: #b91c1c; }
        .badge-adjusted { background: #dbeafe; color: #1d4ed8; }

        .method-tag {
            font-size: 11px;
            padding: 3px 8px;
            border-radius: 6px;
            background: #f1f5f9;
            color: #475569;
            font-weight: 500;
        }

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

        .empty-state { text-align: center; padding: 45px 20px; color: #94a3b8; }
        .empty-state i { font-size: 42px; margin-bottom: 12px; opacity: 0.5; display: block; }
    </style>
</head>
<body>

<!-- Sidebar HR Portal -->
<div class="sidebar">
    <div class="sidebar-brand">
        <i class="fa-solid fa-user-tie"></i>
        <span>HR Management</span>
    </div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/hr/dashboard"><i class="fa-solid fa-chart-line"></i> Bảng điều khiển</a></li>
        <li><a href="${pageContext.request.contextPath}/hr/recruitment"><i class="fa-solid fa-user-plus"></i> Phê duyệt đề xuất</a></li>
        <li><a href="${pageContext.request.contextPath}/hr/transfer-requests"><i class="fa-solid fa-right-left"></i> Phê duyệt điều chuyển</a></li>
        <li><a href="${pageContext.request.contextPath}/hr/employee-management"><i class="fa-solid fa-address-book"></i> Quản lý hồ sơ</a></li>
        <li class="active"><a href="${pageContext.request.contextPath}/hr/attendance-management"><i class="fa-solid fa-clock"></i> Chấm công &amp; Ca làm</a></li>
    </ul>
</div>

<div class="main-wrapper">
<div class="container py-4">

    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
        <h2 style="font-size: 24px; font-weight: 600; color: #1e293b; margin: 0;">
            Chấm công &amp; Ca làm
        </h2>
        <a class="btn btn-sm btn-outline-secondary"
           href="${pageContext.request.contextPath}/hr/dashboard">
            <i class="fa-solid fa-house"></i> Dashboard
        </a>
    </div>

    <!-- ===== Thống kê ===== -->
    <div class="row g-3 mb-4">
        <div class="col-md-3 col-sm-6">
            <div class="stat-card stat-blue">
                <div class="stat-label">Tổng bản ghi</div>
                <div class="stat-value"><c:out value="${totalRecords}"/></div>
                <div class="stat-sub">
                    <c:out value="${from}"/> &rarr; <c:out value="${to}"/>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card stat-green">
                <div class="stat-label">Bản ghi đủ cặp</div>
                <div class="stat-value"><c:out value="${completeRecords}"/></div>
                <div class="stat-sub">có check-in &amp; check-out</div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card stat-amber">
                <div class="stat-label">Tổng giờ làm</div>
                <div class="stat-value"><c:out value="${totalHours}"/></div>
                <div class="stat-sub">giờ trong khoảng lọc</div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6">
            <div class="stat-card stat-slate">
                <div class="stat-label">Số ngày có dữ liệu</div>
                <div class="stat-value"><c:out value="${dailySummary.size()}"/></div>
                <div class="stat-sub">ngày được ghi nhận</div>
            </div>
        </div>
    </div>

    <!-- ===== Bộ lọc ===== -->
    <div class="panel mb-4" style="padding: 18px;">
        <form method="get"
              action="${pageContext.request.contextPath}/hr/attendance-management"
              class="row g-3 align-items-end">
            <div class="col-md-3">
                <label class="form-label" for="branchId">Chi nhánh</label>
                <select class="form-select form-select-sm" id="branchId" name="branchId">
                    <option value="-1">Tất cả chi nhánh</option>
                    <c:forEach var="b" items="${branchList}">
                        <option value="${b.id}"
                            <c:if test="${branchId eq b.id}">selected</c:if>>
                            <c:out value="${b.name}"/> (<c:out value="${b.code}"/>)
                        </option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label" for="from">Từ ngày</label>
                <input type="date" class="form-control form-control-sm"
                       id="from" name="from" value="<c:out value="${from}"/>">
            </div>
            <div class="col-md-2">
                <label class="form-label" for="to">Đến ngày</label>
                <input type="date" class="form-control form-control-sm"
                       id="to" name="to" value="<c:out value="${to}"/>">
            </div>
            <div class="col-md-2">
                <label class="form-label" for="status">Trạng thái</label>
                <select class="form-select form-select-sm" id="status" name="status">
                    <option value="">Tất cả</option>
                    <option value="VALID" <c:if test="${statusFilter eq 'VALID'}">selected</c:if>>Hợp lệ</option>
                    <option value="INVALID" <c:if test="${statusFilter eq 'INVALID'}">selected</c:if>>Không hợp lệ</option>
                    <option value="ADJUSTED" <c:if test="${statusFilter eq 'ADJUSTED'}">selected</c:if>>Đã điều chỉnh</option>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label" for="q">Tìm nhân viên</label>
                <input type="text" class="form-control form-control-sm"
                       id="q" name="q" placeholder="Tên hoặc username"
                       value="<c:out value="${keyword}"/>">
            </div>
            <div class="col-md-1">
                <button type="submit" class="btn btn-primary btn-sm w-100">
                    <i class="fa-solid fa-filter"></i>
                </button>
            </div>
        </form>
    </div>

    <!-- ===== Tổng hợp theo ngày ===== -->
    <c:if test="${not empty dailySummary}">
    <div class="panel mb-4" style="padding: 20px;">
        <div class="panel-title"><i class="fa-solid fa-chart-simple"></i> Tổng hợp theo ngày</div>
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
                            <td><c:out value="${d.workDateText}"/></td>
                            <td><c:out value="${d.total}"/></td>
                            <td class="text-success fw-medium"><c:out value="${d.present}"/></td>
                            <td class="text-warning fw-medium"><c:out value="${d.late}"/></td>
                            <td class="text-danger fw-medium"><c:out value="${d.absent}"/></td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="ratio-bar">
                                        <span style="width: ${d.presentRatio}%;"></span>
                                    </div>
                                    <small class="text-muted"><c:out value="${d.presentRatio}"/>%</small>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    </c:if>

    <!-- ===== Chi tiết ===== -->
    <div class="panel" style="padding: 20px;">
        <div class="panel-title"><i class="fa-solid fa-list"></i> Chi tiết chấm công</div>

        <c:choose>
            <c:when test="${empty attendanceList}">
                <div class="empty-state">
                    <i class="fa-solid fa-clipboard-user"></i>
                    Không có bản ghi chấm công nào khớp bộ lọc hiện tại.
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
                                    <td class="text-muted"><c:out value="${a.id}"/></td>
                                    <td>
                                        <c:out value="${a.fullName}"/>
                                        <small class="text-muted d-block"><c:out value="${a.username}"/></small>
                                    </td>
                                    <td><c:out value="${a.dateText}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty a.checkIn}">
                                                <c:out value="${a.checkInText}"/>
                                            </c:when>
                                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty a.checkOut}">
                                                <c:out value="${a.checkOutText}"/>
                                            </c:when>
                                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${a.complete}">
                                                <strong><c:out value="${a.workedHoursText}"/></strong>
                                                <small class="text-muted">h</small>
                                            </c:when>
                                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><span class="method-tag"><c:out value="${a.method}"/></span></td>
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
                                            <c:otherwise><span class="text-muted">—</span></c:otherwise>
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

</body>
</html>
