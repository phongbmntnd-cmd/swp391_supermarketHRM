<%-- 
    Document   : reports
    Created on : Nov 4, 2026, 8:13:43 PM
    Author     : Lenovo
--%>

<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Báo cáo hoạt động - Supermarket HRM</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <style>
            * { box-sizing: border-box; }
            body { margin: 0; background: #f4f7f6; color: #1e293b; font-family: 'Roboto', sans-serif; }
            .topbar { background: #1e293b; color: #fff; padding: 18px max(24px, calc((100% - 1440px) / 2)); }
            .topbar a { color: #fbbf24; text-decoration: none; font-size: 14px; }
            .topbar h1 { margin: 12px 0 0; font-size: 22px; }
            main { max-width: 1440px; margin: 28px auto; padding: 0 24px; }
            .filters, .panel, .stat { background: #fff; border: 1px solid #e2e8f0; border-radius: 10px; }
            .filters { display: flex; flex-wrap: wrap; align-items: end; gap: 14px; padding: 18px; margin-bottom: 20px; }
            .field { display: grid; gap: 6px; }
            label { color: #475569; font-size: 13px; font-weight: 500; }
            input, select, button { min-height: 38px; border: 1px solid #cbd5e1; border-radius: 6px; padding: 8px 10px; font: inherit; }
            button { color: #fff; background: #b45309; border-color: #b45309; cursor: pointer; font-weight: 500; }
            .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 14px; margin-bottom: 20px; }
            .stat { padding: 18px; border-left: 4px solid #d97706; }
            .stat span { display: block; color: #64748b; font-size: 13px; margin-bottom: 8px; }
            .stat strong { font-size: 22px; }
            .panel { padding: 20px; overflow-x: auto; }
            .panel h2 { margin: 0 0 14px; font-size: 18px; }
            table { width: 100%; border-collapse: collapse; min-width: 1120px; }
            th, td { padding: 11px 10px; border-bottom: 1px solid #e2e8f0; text-align: left; vertical-align: top; font-size: 13px; }
            th { background: #f8fafc; color: #475569; white-space: nowrap; }
            td.number, th.number { text-align: right; white-space: nowrap; }
            .muted { display: block; margin-top: 4px; color: #64748b; font-size: 12px; }
            .badge { display: inline-block; padding: 4px 8px; border-radius: 999px; background: #f1f5f9; color: #475569; font-size: 12px; }
            .empty { padding: 28px; color: #64748b; text-align: center; }
            @media (max-width: 640px) { main { padding: 0 12px; } .filters { align-items: stretch; } .field, .field select, .field input, button { width: 100%; } }
        </style>
    </head>
    <body>
        <header class="topbar">
            <a href="${pageContext.request.contextPath}${reportHomePath}">← Về bảng điều khiển</a>
            <h1><c:choose><c:when test="${storeManagerReport}">Báo cáo chi nhánh</c:when><c:otherwise>Báo cáo hoạt động</c:otherwise></c:choose></h1>
        </header>
        <main>
            <form class="filters" method="get" action="${pageContext.request.contextPath}/director/reports">
                <div class="field">
                    <label for="month">Tháng</label>
                    <input id="month" name="month" type="number" min="1" max="12" value="${selectedMonth}" required>
                </div>
                <div class="field">
                    <label for="year">Năm</label>
                    <input id="year" name="year" type="number" min="2000" max="9999" value="${selectedYear}" required>
                </div>
                <c:choose>
                    <c:when test="${storeManagerReport}">
                        <c:forEach items="${branches}" var="branch">
                            <div class="field">
                                <label>Chi nhánh</label>
                                <span><c:out value="${branch.code}"/> - <c:out value="${branch.name}"/></span>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="field">
                            <label for="branchId">Chi nhánh</label>
                            <select id="branchId" name="branchId">
                                <option value="0" ${selectedBranchId == 0 ? 'selected' : ''}>Toàn chuỗi</option>
                                <c:forEach items="${branches}" var="branch">
                                    <option value="${branch.id}" ${selectedBranchId == branch.id ? 'selected' : ''}>
                                        <c:out value="${branch.code}"/> - <c:out value="${branch.name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:otherwise>
                </c:choose>
                <button type="submit">Xem báo cáo</button>
            </form>

            <section class="stats">
                <div class="stat"><span>Nhân sự đang hoạt động</span><strong><c:out value="${employeeCount}"/></strong></div>
                <div class="stat"><span>Ca đã lên lịch</span><strong><c:out value="${scheduledShifts}"/></strong></div>
                <div class="stat"><span>Lượt chấm công</span><strong><c:out value="${recordedAttendances}"/></strong></div>
                <div class="stat"><span>Vi phạm trong tháng</span><strong><c:out value="${violationCount}"/></strong><span class="muted"><c:out value="${pendingViolations}"/> đang chờ duyệt</span></div>
                <div class="stat"><span>Lương đã chốt</span><strong><fmt:formatNumber value="${finalizedPayroll}" maxFractionDigits="0"/> ₫</strong><span class="muted"><c:out value="${payrollPayslips}"/> phiếu lương</span></div>
            </section>

            <section class="panel">
                <h2>Chi tiết theo chi nhánh</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Chi nhánh</th>
                            <th>Trạng thái</th>
                            <th class="number">Nhân sự</th>
                            <th class="number">Chấm công (đã ghi / ca)</th>
                            <th class="number">Vi phạm</th>
                            <th class="number">Phiếu lương</th>
                            <th class="number">Lương đã chốt</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${reports}" var="report">
                            <tr>
                                <td><strong><c:out value="${report.branchCode}"/></strong><span class="muted"><c:out value="${report.branchName}"/></span></td>
                                <td><span class="badge"><c:out value="${report.branchStatus}"/></span></td>
                                <td class="number"><c:out value="${report.employeeCount}"/></td>
                                <td class="number">
                                    <c:out value="${report.recordedAttendances}"/> / <c:out value="${report.scheduledShifts}"/>
                                    <span class="muted">Hợp lệ: <c:out value="${report.validAttendances}"/> · Điều chỉnh: <c:out value="${report.adjustedAttendances}"/> · Không hợp lệ: <c:out value="${report.invalidAttendances}"/> · Chờ xử lý: <c:out value="${report.pendingAttendances}"/></span>
                                </td>
                                <td class="number">
                                    <c:out value="${report.violationCount}"/>
                                    <span class="muted">Chờ duyệt: <c:out value="${report.pendingViolations}"/> · Đã duyệt: <c:out value="${report.approvedViolations}"/></span>
                                </td>
                                <td class="number"><c:out value="${report.payrollPayslips}"/></td>
                                <td class="number"><fmt:formatNumber value="${report.finalizedPayroll}" maxFractionDigits="0"/> ₫</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty reports}">
                            <tr><td class="empty" colspan="7">Không tìm thấy chi nhánh phù hợp với bộ lọc.</td></tr>
                        </c:if>
                    </tbody>
                </table>
                <p class="muted">Chi phí lương chỉ tính các kỳ đã chốt. Nhân sự tính theo quản lý cửa hàng và nhân viên đang hoạt động tại chi nhánh.</p>
            </section>
        </main>
    </body>
</html>
