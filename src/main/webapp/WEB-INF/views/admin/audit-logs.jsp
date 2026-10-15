<%--
    Module 3: Audit Log & System Monitoring
    Xem nhật ký toàn hệ thống + thống kê + filter
--%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="ctx" content="${pageContext.request.contextPath}">
    <title>Nhật ký hệ thống - Audit Log</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f4f7f6; color: #333;
        }
        .top-navbar {
            background: #2c3e50; color: white; padding: 15px 30px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .top-navbar h1 { font-size: 20px; font-weight: 500; }
        .user-info { display: flex; gap: 15px; align-items: center; font-size: 14px; }
        .user-info a {
            color: white; text-decoration: none;
            background: #e74c3c; padding: 6px 12px;
            border-radius: 4px; font-weight: bold;
        }
        .container { max-width: 1400px; margin: 30px auto; padding: 0 20px; }
        .page-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px;
        }
        .page-header h2 { color: #2c3e50; font-size: 24px; }
        .back-link {
            color: #3498db; text-decoration: none; font-size: 14px;
            background: white; padding: 8px 16px; border-radius: 4px;
            border: 1px solid #3498db;
        }
        .back-link:hover { background: #3498db; color: white; }

        .alert {
            padding: 12px 20px; border-radius: 6px; margin-bottom: 20px;
            font-size: 14px;
        }
        .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
        .alert-error   { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }

        /* Stats cards */
        .stats-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px; margin-bottom: 24px;
        }
        .stat-card {
            background: white; padding: 20px; border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            border-left: 4px solid #3498db;
        }
        .stat-card .label { font-size: 13px; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-card .value { font-size: 32px; font-weight: 700; color: #2c3e50; margin-top: 8px; }
        .stat-card .sub { font-size: 12px; color: #95a5a6; margin-top: 4px; }
        .stat-card.green  { border-left-color: #27ae60; }
        .stat-card.orange { border-left-color: #f39c12; }
        .stat-card.purple { border-left-color: #9b59b6; }
        .stat-card.red    { border-left-color: #e74c3c; }

        /* Action breakdown */
        .action-breakdown {
            background: white; padding: 20px; border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            margin-bottom: 24px;
        }
        .action-breakdown h3 { color: #2c3e50; margin-bottom: 14px; font-size: 16px; }
        .action-bar {
            display: flex; align-items: center; gap: 10px;
            padding: 6px 0; border-bottom: 1px solid #f0f0f0;
        }
        .action-bar:last-child { border-bottom: none; }
        .action-bar .name {
            width: 200px; font-size: 13px; font-weight: 500;
            color: #34495e;
        }
        .action-bar .bar {
            flex: 1; height: 18px; background: #ecf0f1;
            border-radius: 9px; overflow: hidden; position: relative;
        }
        .action-bar .fill {
            height: 100%; background: linear-gradient(90deg, #3498db, #2980b9);
            border-radius: 9px;
        }
        .action-bar .count {
            min-width: 40px; text-align: right; font-weight: 600;
            color: #2c3e50; font-size: 13px;
        }

        /* Filter */
        .filter-section {
            background: white; padding: 20px; border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        .filter-section h3 { color: #2c3e50; margin-bottom: 12px; font-size: 16px; }
        .filter-form {
            display: grid; grid-template-columns: repeat(4, 1fr) auto;
            gap: 12px; align-items: end;
        }
        .form-group label {
            display: block; font-size: 12px; color: #555;
            font-weight: 500; margin-bottom: 4px;
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .form-group input, .form-group select {
            width: 100%; padding: 8px 12px; border: 1px solid #ddd;
            border-radius: 4px; font-size: 14px;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none; border-color: #3498db;
        }
        .btn {
            padding: 8px 16px; border: none; border-radius: 4px;
            cursor: pointer; font-size: 14px; font-weight: 500;
            text-decoration: none; display: inline-block;
            text-align: center; transition: all 0.2s;
        }
        .btn-primary { background: #3498db; color: white; }
        .btn-primary:hover { background: #2980b9; }
        .btn-secondary { background: #95a5a6; color: white; }
        .btn-secondary:hover { background: #7f8c8d; }
        .btn-sm { padding: 5px 10px; font-size: 13px; }

        /* Table */
        .data-table {
            width: 100%; border-collapse: collapse;
            background: white; border-radius: 8px; overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .data-table th, .data-table td {
            padding: 10px 12px; text-align: left;
            border-bottom: 1px solid #f0f0f0; font-size: 13px;
        }
        .data-table th {
            background: #2c3e50; color: white; font-weight: 600;
            font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px;
        }
        .data-table tbody tr:hover { background: #f8f9fa; }

        .action-tag {
            display: inline-block; padding: 3px 10px; border-radius: 12px;
            font-size: 11px; font-weight: 600; text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .tag-LOCK    { background: #f8d7da; color: #721c24; }
        .tag-UNLOCK  { background: #d4edda; color: #155724; }
        .tag-RESET   { background: #fff3cd; color: #856404; }
        .tag-CREATE  { background: #d1ecf1; color: #0c5460; }
        .tag-UPDATE  { background: #cce5ff; color: #004085; }
        .tag-DELETE  { background: #f5c6cb; color: #721c24; }
        .tag-LOGIN   { background: #d6d8db; color: #383d41; }
        .tag-LOGOUT  { background: #e2e3e5; color: #383d41; }
        .tag-DEFAULT { background: #ecf0f1; color: #2c3e50; }

        .user-cell { display: flex; flex-direction: column; }
        .user-cell .name { font-weight: 500; color: #2c3e50; font-size: 13px; }
        .user-cell .username { color: #7f8c8d; font-size: 11px; font-family: monospace; }
        .role-badge {
            display: inline-block; padding: 1px 6px; border-radius: 3px;
            background: #ecf0f1; color: #555; font-size: 10px; margin-top: 2px;
        }
        .id-cell { color: #95a5a6; font-family: monospace; }
        .ip-cell { font-family: monospace; color: #7f8c8d; font-size: 12px; }
        .desc-cell {
            color: #555; font-size: 12px; line-height: 1.4;
            max-width: 350px; word-break: break-word;
        }
        .time-cell { color: #7f8c8d; font-size: 12px; white-space: nowrap; }

        /* Pagination */
        .pagination {
            display: flex; justify-content: space-between; align-items: center;
            margin-top: 20px; padding: 15px; background: white;
            border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .pagination .info { color: #7f8c8d; font-size: 14px; }
        .pagination .info strong { color: #2c3e50; }
        .pagination .pages { display: flex; gap: 4px; }
        .pagination a, .pagination span {
            padding: 6px 12px; border: 1px solid #ddd; border-radius: 4px;
            color: #3498db; text-decoration: none; font-size: 13px;
        }
        .pagination a:hover { background: #3498db; color: white; }
        .pagination .current {
            background: #3498db; color: white; border-color: #3498db;
            font-weight: 600;
        }
        .pagination .disabled { color: #bbb; cursor: not-allowed; }

        .empty-state {
            text-align: center; padding: 40px; color: #7f8c8d;
            background: white; border-radius: 8px;
        }

        /* Recent activity card */
        .recent-card {
            background: white; padding: 20px; border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            margin-bottom: 24px;
        }
        .recent-card h3 { color: #2c3e50; margin-bottom: 14px; font-size: 16px; }
        .recent-item {
            display: flex; gap: 10px; padding: 8px 0;
            border-bottom: 1px solid #f0f0f0; font-size: 13px;
        }
        .recent-item:last-child { border-bottom: none; }
        .recent-item .time { color: #95a5a6; min-width: 80px; font-size: 12px; }
        .recent-item .msg { color: #2c3e50; }
    </style>
</head>
<body>

<div class="top-navbar">
    <h1>Hệ Thống Quản Lý Siêu Thị - Quản Trị Viên</h1>
    <div class="user-info">
        <span>Xin chào, <b>${sessionScope.account.username}</b></span>
        <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
    </div>
</div>

<div class="container">

    <div class="page-header">
        <h2>📋 Nhật Ký Hoạt Động Hệ Thống (Audit Log)</h2>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="back-link">← Quay về Dashboard</a>
    </div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">✅ ${successMessage}</div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">❌ ${errorMessage}</div>
    </c:if>

    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="label">Tổng sự kiện</div>
            <div class="value">${totalAll}</div>
            <div class="sub">Toàn bộ lịch sử</div>
        </div>
        <div class="stat-card green">
            <div class="label">Hôm nay</div>
            <div class="value">${totalToday}</div>
            <div class="sub">Sự kiện trong 24h qua</div>
        </div>
        <div class="stat-card orange">
            <div class="label">7 ngày qua</div>
            <div class="value">${totalWeek}</div>
            <div class="sub">Hoạt động tuần này</div>
        </div>
        <div class="stat-card purple">
            <div class="label">Kết quả trả về</div>
            <div class="value">${totalRecords}</div>
            <div class="sub">Khớp bộ lọc hiện tại</div>
        </div>
    </div>

    <!-- Action breakdown -->
    <c:if test="${not empty statsByAction}">
        <div class="action-breakdown">
            <h3>📊 Thống kê theo loại hành động</h3>
            <c:set var="maxCount" value="0"/>
            <c:forEach var="entry" items="${statsByAction}">
                <c:if test="${entry.value > maxCount}"><c:set var="maxCount" value="${entry.value}"/></c:if>
            </c:forEach>
            <c:forEach var="entry" items="${statsByAction}">
                <c:set var="pct" value="${maxCount > 0 ? (entry.value * 100 / maxCount) : 0}"/>
                <div class="action-bar">
                    <div class="name">${entry.key}</div>
                    <div class="bar">
                        <div class="fill" style="width: ${pct}%;"></div>
                    </div>
                    <div class="count">${entry.value}</div>
                </div>
            </c:forEach>
        </div>
    </c:if>

    <!-- Recent activity -->
    <c:if test="${not empty recentLogs}">
        <div class="recent-card">
            <h3>⚡ Hoạt động gần đây (5 mới nhất)</h3>
            <c:forEach var="r" items="${recentLogs}">
                <div class="recent-item">
                    <div class="time"><fmt:formatDate value="${r.createdAt}" pattern="HH:mm:ss"/></div>
                    <div class="msg">
                        <span class="action-tag tag-${fn:toUpperCase(fn:substring(r.action, 0, 4))}">${r.action}</span>
                        <c:choose>
                            <c:when test="${r.actorName != null}">${fn:escapeXml(r.actorName)}</c:when>
                            <c:when test="${r.actorUsername != null}">${fn:escapeXml(r.actorUsername)}</c:when>
                            <c:otherwise><em style="color:#999;">system</em></c:otherwise>
                        </c:choose>
                        <c:if test="${r.targetUserName != null || r.targetUsername != null}">
                            → <strong>
                                <c:choose>
                                    <c:when test="${r.targetUserName != null}">${fn:escapeXml(r.targetUserName)}</c:when>
                                    <c:otherwise>${fn:escapeXml(r.targetUsername)}</c:otherwise>
                                </c:choose>
                            </strong>
                        </c:if>
                        <c:if test="${r.description != null}">
                            <span style="color:#7f8c8d; font-size:12px;">— ${fn:escapeXml(r.description)}</span>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:if>

    <!-- Filter -->
    <div class="filter-section">
        <h3>🔍 Bộ lọc nâng cao</h3>
        <form class="filter-form" method="GET"
              action="${pageContext.request.contextPath}/admin/audit-logs">
            <div class="form-group">
                <label>Hành động</label>
                <select name="action">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="a" items="${distinctActions}">
                        <option value="${a}" ${a == action ? 'selected' : ''}>${a}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label>Người thực hiện (username)</label>
                <input type="text" name="actor" value="${actor}" placeholder="VD: admin">
            </div>
            <div class="form-group">
                <label>Đối tượng bị tác động (username)</label>
                <input type="text" name="target" value="${target}" placeholder="VD: emp_user">
            </div>
            <div class="form-group">
                <label>Từ khóa (mô tả/IP)</label>
                <input type="text" name="keyword" value="${keyword}" placeholder="Tìm trong mô tả...">
            </div>
            <div style="display: flex; gap: 6px;">
                <button type="submit" class="btn btn-primary">🔎 Lọc</button>
                <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-secondary">🗑 Xóa lọc</a>
            </div>
        </form>
        <form class="filter-form" method="GET"
              action="${pageContext.request.contextPath}/admin/audit-logs"
              style="grid-template-columns: 1fr 1fr 1fr auto; margin-top: 10px;">
            <div class="form-group">
                <label>Từ ngày</label>
                <input type="date" name="fromDate" value="${fromDate}">
            </div>
            <div class="form-group">
                <label>Đến ngày</label>
                <input type="date" name="toDate" value="${toDate}">
            </div>
            <div class="form-group">
                <label>Số dòng / trang</label>
                <select name="size">
                    <c:forEach var="ps" items="${pageSizes}">
                        <option value="${ps}" ${ps == pageSize ? 'selected' : ''}>${ps}</option>
                    </c:forEach>
                </select>
            </div>
            <div style="display: flex; gap: 6px;">
                <button type="submit" class="btn btn-primary">📅 Lọc ngày</button>
            </div>
        </form>
    </div>

    <!-- Main table -->
    <c:choose>
        <c:when test="${not empty logs}">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">ID</th>
                        <th style="width: 110px;">Thời gian</th>
                        <th style="width: 120px;">Hành động</th>
                        <th style="width: 180px;">Người thực hiện</th>
                        <th style="width: 180px;">Đối tượng</th>
                        <th>Mô tả chi tiết</th>
                        <th style="width: 110px;">IP</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="log" items="${logs}">
                        <tr>
                            <td class="id-cell">#${log.id}</td>
                            <td class="time-cell">
                                <fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy"/>
                                <br>
                                <fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss"/>
                            </td>
                            <td>
                                <c:set var="actionPrefix" value="${fn:toUpperCase(fn:substring(log.action, 0, 4))}"/>
                                <span class="action-tag tag-${actionPrefix}">${log.action}</span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${log.actorId == null}">
                                        <em style="color:#999;">—</em>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="user-cell">
                                            <span class="name">
                                                ${log.actorName != null ? fn:escapeXml(log.actorName) : '<em>Không rõ</em>'}
                                            </span>
                                            <span class="username">@${log.actorUsername != null ? fn:escapeXml(log.actorUsername) : 'id='.concat(log.actorId)}</span>
                                            <c:if test="${log.actorRoleName != null}">
                                                <span class="role-badge">${log.actorRoleName}</span>
                                            </c:if>
                                            <c:if test="${log.actorBranchName != null}">
                                                <span style="color:#95a5a6; font-size:10px;">📍 ${fn:escapeXml(log.actorBranchName)}</span>
                                            </c:if>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${log.targetUserId == null}">
                                        <em style="color:#999;">—</em>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="user-cell">
                                            <span class="name">
                                                ${log.targetUserName != null ? fn:escapeXml(log.targetUserName) : '<em>Không rõ</em>'}
                                            </span>
                                            <span class="username">@${log.targetUsername != null ? fn:escapeXml(log.targetUsername) : 'id='.concat(log.targetUserId)}</span>
                                            <c:if test="${log.targetRoleName != null}">
                                                <span class="role-badge">${log.targetRoleName}</span>
                                            </c:if>
                                            <c:if test="${log.targetBranchName != null}">
                                                <span style="color:#95a5a6; font-size:10px;">📍 ${fn:escapeXml(log.targetBranchName)}</span>
                                            </c:if>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="desc-cell">${fn:escapeXml(log.description)}</td>
                            <td class="ip-cell">${log.ipAddress != null ? fn:escapeXml(log.ipAddress) : '—'}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <!-- Pagination -->
            <div class="pagination">
                <div class="info">
                    Hiển thị <strong>${displayStart}</strong> -
                    <strong>${displayEnd}</strong>
                    trong <strong>${totalRecords}</strong> bản ghi
                </div>
                <div class="pages">
                    <c:choose>
                        <c:when test="${currentPage <= 1}">
                            <span class="disabled">«</span>
                        </c:when>
                        <c:otherwise>
                            <a href="?page=1&size=${pageSize}&action=${action}&actor=${actor}&target=${target}&keyword=${keyword}&fromDate=${fromDate}&toDate=${toDate}">«</a>
                            <a href="?page=${currentPage - 1}&size=${pageSize}&action=${action}&actor=${actor}&target=${target}&keyword=${keyword}&fromDate=${fromDate}&toDate=${toDate}">‹</a>
                        </c:otherwise>
                    </c:choose>
                        <c:forEach var="i" begin="${pagerStart}" end="${pagerEnd}">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <span class="current">${i}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?page=${i}&size=${pageSize}&action=${action}&actor=${actor}&target=${target}&keyword=${keyword}&fromDate=${fromDate}&toDate=${toDate}">${i}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                    <c:choose>
                        <c:when test="${currentPage >= totalPages}">
                            <span class="disabled">»</span>
                        </c:when>
                        <c:otherwise>
                            <a href="?page=${currentPage + 1}&size=${pageSize}&action=${action}&actor=${actor}&target=${target}&keyword=${keyword}&fromDate=${fromDate}&toDate=${toDate}">›</a>
                            <a href="?page=${totalPages}&size=${pageSize}&action=${action}&actor=${actor}&target=${target}&keyword=${keyword}&fromDate=${fromDate}&toDate=${toDate}">»</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                📭 Không có bản ghi nào phù hợp với bộ lọc hiện tại.
            </div>
        </c:otherwise>
    </c:choose>

</div>

<script>
    // Tự ẩn alert sau 5s
    setTimeout(function() {
        document.querySelectorAll('.alert').forEach(function(a) {
            a.style.transition = 'opacity 0.3s';
            a.style.opacity = '0';
            setTimeout(function() { a.style.display = 'none'; }, 300);
        });
    }, 5000);

    // Lưu trạng thái filter vào URL hash (optional)
    (function() {
        var filterInputs = document.querySelectorAll('.filter-form input, .filter-form select');
        filterInputs.forEach(function(inp) {
            inp.addEventListener('change', function() {
                // Có thể thêm auto-submit nếu muốn
            });
        });
    })();
</script>

</body>
</html>
