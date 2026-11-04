<%--
    Chi tiết 1 dòng audit log + các log liên quan
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
    <title>Chi tiết nhật ký #${log.id}</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #f4f7f6; color: #333; }
        .top-navbar {
            background: #2c3e50; color: white; padding: 15px 30px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .top-navbar h1 { font-size: 20px; font-weight: 500; }
        .user-info { display: flex; gap: 15px; align-items: center; font-size: 14px; }
        .user-info a {
            color: white; text-decoration: none; background: #e74c3c;
            padding: 6px 12px; border-radius: 4px; font-weight: bold;
        }
        .container { max-width: 1000px; margin: 30px auto; padding: 0 20px; }
        .page-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;
        }
        .page-header h2 { color: #2c3e50; font-size: 24px; }
        .back-link {
            color: #3498db; text-decoration: none; font-size: 14px;
            background: white; padding: 8px 16px; border-radius: 4px; border: 1px solid #3498db;
        }
        .back-link:hover { background: #3498db; color: white; }

        .alert { padding: 12px 20px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; }
        .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
        .alert-error   { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }

        .card {
            background: white; border-radius: 8px; padding: 24px; margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }
        .card h3 { color: #2c3e50; font-size: 17px; margin-bottom: 16px; padding-bottom: 10px; border-bottom: 2px solid #ecf0f1; }

        .detail-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .detail-table td { padding: 10px 12px; border-bottom: 1px solid #ecf0f1; vertical-align: top; }
        .detail-table tr:last-child td { border-bottom: none; }
        .detail-table td.label {
            width: 180px; font-weight: 600; color: #566573; background: #fafafa;
        }
        .mono {
            font-family: Consolas, 'Courier New', monospace; font-size: 13px;
            background: #f8f9fa; padding: 10px 12px; border-radius: 4px;
            white-space: pre-wrap; word-break: break-word;
        }
        .action-tag {
            display: inline-block; padding: 3px 10px; border-radius: 12px;
            font-size: 12px; font-weight: bold; background: #ecf0f1; color: #566573;
        }
        .tag-LOGI { background: #d4edda; color: #155724; }
        .tag-CREA { background: #d1ecf1; color: #0c5460; }
        .tag-UPD { background: #fff3cd; color: #856404; }
        .tag-DELE { background: #f8d7da; color: #721c24; }
        .tag-EMER { background: #f5c6cb; color: #721c24; }
        .tag-RESE { background: #e2e3e5; color: #383d41; }

        .related-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .related-table th {
            text-align: left; padding: 8px 10px; background: #f8f9fa;
            border-bottom: 2px solid #dee2e6; font-size: 12px; color: #566573;
        }
        .related-table td { padding: 8px 10px; border-bottom: 1px solid #ecf0f1; }
        .related-table tr:hover td { background: #f8f9fa; }
        .related-table a { color: #3498db; text-decoration: none; }

        .empty-state {
            text-align: center; padding: 40px; color: #95a5a6;
            background: white; border-radius: 8px;
        }
        .hint { font-size: 12px; color: #95a5a6; margin-top: 6px; }
    </style>
</head>
<body>

<div class="top-navbar">
    <h1>Chi tiết nhật ký hệ thống</h1>
    <div class="user-info">
        <span>Xin chào, <b>${sessionScope.account.username}</b></span>
        <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
    </div>
</div>

<div class="container">

    <div class="page-header">
        <h2>🔍 Nhật ký #${log.id}</h2>
        <a href="${pageContext.request.contextPath}/admin/audit-logs" class="back-link">← Quay về danh sách</a>
    </div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">✅ ${successMessage}</div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">❌ ${errorMessage}</div>
    </c:if>

    <!-- Thông tin chi tiết -->
    <div class="card">
        <h3>Thông tin sự kiện</h3>
        <table class="detail-table">
            <tr>
                <td class="label">Mã log</td>
                <td>#${log.id}</td>
            </tr>
            <tr>
                <td class="label">Thời điểm</td>
                <td>
                    <fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                    <span class="hint">${log.createdAt}</span>
                </td>
            </tr>
            <tr>
                <td class="label">Hành động</td>
                <td>
                    <c:set var="actionPrefix" value="${fn:toUpperCase(fn:substring(log.action, 0, 4))}"/>
                    <span class="action-tag tag-${actionPrefix}">${log.action}</span>
                </td>
            </tr>
            <tr>
                <td class="label">Loại đối tượng</td>
                <td>
                    <c:choose>
                        <c:when test="${log.entityType != null}">
                            <span class="action-tag">${log.entityType}</span>
                            <c:if test="${log.entityId != null}">
                                <span style="color:#7f8c8d;"> — id=${log.entityId}</span>
                            </c:if>
                        </c:when>
                        <c:otherwise><em style="color:#999;">Không áp dụng</em></c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <td class="label">Người thực hiện</td>
                <td>
                    <c:choose>
                        <c:when test="${log.actorId == null}">
                            <em style="color:#999;">— (hệ thống / không xác định)</em>
                        </c:when>
                        <c:otherwise>
                            <strong>${log.actorName != null ? fn:escapeXml(log.actorName) : 'Không rõ'}</strong>
                            <span style="color:#7f8c8d;"> (@${log.actorUsername != null ? fn:escapeXml(log.actorUsername) : log.actorId})</span>
                            <c:if test="${log.actorRoleName != null}">
                                <span class="action-tag">${log.actorRoleName}</span>
                            </c:if>
                            <c:if test="${log.actorBranchName != null}">
                                <span style="color:#95a5a6; font-size:12px;"> 📍 ${fn:escapeXml(log.actorBranchName)}</span>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <td class="label">Đối tượng bị tác động</td>
                <td>
                    <c:choose>
                        <c:when test="${log.targetUserId == null}">
                            <em style="color:#999;">—</em>
                        </c:when>
                        <c:otherwise>
                            <strong>${log.targetUserName != null ? fn:escapeXml(log.targetUserName) : 'Không rõ'}</strong>
                            <span style="color:#7f8c8d;"> (@${log.targetUsername != null ? fn:escapeXml(log.targetUsername) : log.targetUserId})</span>
                            <c:if test="${log.targetRoleName != null}">
                                <span class="action-tag">${log.targetRoleName}</span>
                            </c:if>
                            <c:if test="${log.targetBranchName != null}">
                                <span style="color:#95a5a6; font-size:12px;"> 📍 ${fn:escapeXml(log.targetBranchName)}</span>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <td class="label">Địa chỉ IP</td>
                <td>${log.ipAddress != null ? fn:escapeXml(log.ipAddress) : '—'}</td>
            </tr>
            <tr>
                <td class="label">Mô tả chi tiết</td>
                <td>
                    <div class="mono">${fn:escapeXml(log.description)}</div>
                    <div class="hint">
                        Định dạng chuẩn: Đối tượng | Hành động | Trường: cũ -&gt; mới | Ghi chú
                    </div>
                </td>
            </tr>
        </table>
    </div>

    <!-- Log liên quan -->
    <div class="card">
        <h3>🕐 Sự kiện liên quan (trong vòng ±${relatedMinutes} phút)</h3>
        <c:choose>
            <c:when test="${not empty relatedLogs}">
                <table class="related-table">
                    <thead>
                        <tr>
                            <th style="width:60px;">ID</th>
                            <th style="width:150px;">Thời gian</th>
                            <th style="width:150px;">Hành động</th>
                            <th style="width:180px;">Người thực hiện</th>
                            <th>Mô tả</th>
                            <th style="width:80px;"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${relatedLogs}">
                            <tr>
                                <td>#${r.id}</td>
                                <td>
                                    <fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy"/>
                                    <br>
                                    <fmt:formatDate value="${r.createdAt}" pattern="HH:mm:ss"/>
                                </td>
                                <td>
                                    <c:set var="rp" value="${fn:toUpperCase(fn:substring(r.action, 0, 4))}"/>
                                    <span class="action-tag tag-${rp}">${r.action}</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.actorName != null}">${fn:escapeXml(r.actorName)}</c:when>
                                        <c:when test="${r.actorUsername != null}">${fn:escapeXml(r.actorUsername)}</c:when>
                                        <c:otherwise><em style="color:#999;">system</em></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${fn:escapeXml(r.description)}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/admin/audit-log-detail?id=${r.id}">🔍 Xem</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    Không có sự kiện liên quan nào trong khoảng thời gian này.
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</div>

</body>
</html>
