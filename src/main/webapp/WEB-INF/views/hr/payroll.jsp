<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tính lương - HR Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --ink: #1e293b; --muted: #64748b; --line: #e8edf3; --blue: #0284c7; }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; background: #f4f7f6; color: var(--ink); font-family: 'Roboto', sans-serif; }
        .sidebar { width: 260px; position: fixed; inset: 0 auto 0 0; z-index: 100; display: flex; flex-direction: column; background: #1e293b; color: #94a3b8; box-shadow: 2px 0 12px rgba(15,23,42,.08); }
        .sidebar-brand { display: flex; align-items: center; gap: 12px; padding: 24px 22px; background: #0f172a; color: #fff; font-size: 17px; font-weight: 700; }
        .brand-icon { display: grid; width: 38px; height: 38px; place-items: center; border-radius: 11px; background: rgba(56,189,248,.14); color: #38bdf8; font-size: 17px; }
        .sidebar-caption { margin: 25px 22px 10px; color: #64748b; font-size: 10px; font-weight: 700; letter-spacing: 1.2px; text-transform: uppercase; }
        .sidebar ul { list-style: none; margin: 0; padding: 0 12px; }
        .sidebar a { display: flex; align-items: center; gap: 13px; margin: 3px 0; padding: 12px 13px; border-left: 3px solid transparent; border-radius: 8px; color: #b6c2d0; font-size: 13px; font-weight: 500; text-decoration: none; transition: .18s ease; }
        .sidebar a i { width: 18px; text-align: center; }
        .sidebar a:hover { background: rgba(255,255,255,.06); color: #fff; }
        .sidebar .active a { border-left-color: #38bdf8; background: rgba(56,189,248,.12); color: #fff; }
        .main { min-height: 100vh; margin-left: 260px; padding: 0 32px 40px; }
        .topbar { display: flex; min-height: 68px; align-items: center; justify-content: space-between; gap: 16px; margin: 0 -32px 28px; padding: 0 32px; border-bottom: 1px solid var(--line); background: #fff; }
        .topbar-title { color: #475569; font-size: 13px; font-weight: 500; }
        .topbar-user { color: var(--muted); font-size: 13px; }
        .page-heading { display: flex; align-items: flex-end; justify-content: space-between; gap: 18px; margin-bottom: 22px; }
        .eyebrow { margin-bottom: 7px; color: var(--blue); font-size: 11px; font-weight: 700; letter-spacing: 1.1px; text-transform: uppercase; }
        .page-heading h1 { margin: 0; color: var(--ink); font-size: clamp(24px, 3vw, 30px); font-weight: 700; letter-spacing: -.5px; }
        .page-heading p { margin: 7px 0 0; color: var(--muted); font-size: 14px; }
        .card { overflow: hidden; border: 1px solid #edf1f5; border-radius: 14px; background: #fff; box-shadow: 0 5px 18px rgba(15,23,42,.045); }
        .payroll-card { padding: 22px 24px; }
        .section-heading { display: flex; align-items: center; gap: 12px; margin-bottom: 18px; }
        .section-icon { display: grid; width: 40px; height: 40px; flex: 0 0 40px; place-items: center; border-radius: 11px; background: #eaf6ff; color: #0284c7; }
        .section-heading h2 { margin: 0; color: var(--ink); font-size: 16px; font-weight: 700; }
        .section-heading p { margin: 4px 0 0; color: var(--muted); font-size: 12px; }
        .formula-note { display: flex; gap: 13px; margin-bottom: 20px; padding: 15px 17px; border: 1px solid #dbeafe; border-radius: 11px; background: #eff8ff; color: #334155; font-size: 13px; line-height: 1.65; }
        .formula-note > i { margin-top: 3px; color: #0284c7; }
        .formula-note strong { color: #0f4c81; }
        .summary-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 14px; margin-bottom: 20px; }
        .summary-item { display: flex; align-items: center; gap: 13px; padding: 16px 18px; border: 1px solid var(--line); border-radius: 12px; background: #fff; }
        .summary-icon { display: grid; width: 42px; height: 42px; flex: 0 0 42px; place-items: center; border-radius: 12px; background: #eff6ff; color: #2563eb; }
        .summary-item:nth-child(2) .summary-icon { background: #ecfdf5; color: #059669; }
        .summary-item:nth-child(3) .summary-icon { background: #fff7ed; color: #ea580c; }
        .summary-label { color: var(--muted); font-size: 11px; }
        .summary-value { margin-top: 3px; color: var(--ink); font-size: 17px; font-weight: 700; }
        .table { margin-bottom: 0; --bs-table-hover-bg: #f8fbff; }
        .table thead th { padding: 12px 14px; border-bottom: 1px solid #e8edf3; background: #f8fafc; color: #64748b; font-size: 10px; font-weight: 700; letter-spacing: .55px; text-transform: uppercase; white-space: nowrap; }
        .table tbody td { padding: 14px; border-color: #edf1f5; color: #334155; font-size: 13px; }
        .employee-name { color: var(--ink); font-size: 13px; font-weight: 600; }
        .employee-meta { margin-top: 4px; color: #94a3b8; font-size: 11px; }
        .type-pill { display: inline-flex; padding: 5px 9px; border-radius: 20px; background: #eff6ff; color: #1d4ed8; font-size: 10px; font-weight: 700; white-space: nowrap; }
        .type-pill.part-time { background: #f5f3ff; color: #6d28d9; }
        .config-form { display: grid; grid-template-columns: minmax(130px,1fr) minmax(130px,1fr) 92px; align-items: end; gap: 9px; min-width: 390px; }
        .salary-field label { display: block; margin-bottom: 5px; color: #64748b; font-size: 10px; font-weight: 600; }
        .salary-field .form-control { min-height: 36px; border-color: #dbe3ec; border-radius: 7px; font-size: 12px; }
        .salary-field .form-control:focus { border-color: #38bdf8; box-shadow: 0 0 0 3px rgba(56,189,248,.13); }
        .salary-status { grid-column: 1 / -1; margin-top: 0; }
        .salary-status .badge { padding: 5px 8px; font-size: 10px; font-weight: 600; }
        .save-button { min-height: 36px; border-radius: 7px; font-size: 12px; font-weight: 600; white-space: nowrap; }
        .period-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 18px; margin-bottom: 18px; }
        .period-filter { display: flex; align-items: flex-end; gap: 9px; }
        .period-filter label { display: block; margin-bottom: 5px; color: #64748b; font-size: 10px; font-weight: 600; }
        .period-filter .form-control { min-height: 38px; width: 100px; border-color: #dbe3ec; border-radius: 8px; font-size: 13px; }
        .period-status { display: inline-flex; align-items: center; gap: 7px; padding: 7px 10px; border-radius: 20px; background: #fff7ed; color: #c2410c; font-size: 11px; font-weight: 700; }
        .period-status.finalized { background: #ecfdf5; color: #047857; }
        .table-wrap { overflow: auto; border: 1px solid var(--line); border-radius: 10px; }
        .net-salary { color: #047857 !important; font-weight: 700; white-space: nowrap; }
        .history-link { color: #0369a1; font-size: 12px; font-weight: 600; text-decoration: none; }
        .history-link:hover { color: #075985; text-decoration: underline; }
        .empty-cell { padding: 30px !important; color: #94a3b8 !important; text-align: center; }
        .alert { border: 0; border-radius: 10px; font-size: 13px; }
        .btn { border-radius: 8px; font-weight: 600; }
        @media (max-width: 1100px) { .main { padding-right: 22px; padding-left: 22px; } .topbar { margin-right: -22px; margin-left: -22px; padding-right: 22px; padding-left: 22px; } }
        @media (max-width: 800px) { .sidebar { position: static; width: auto; } .sidebar ul { display: flex; overflow-x: auto; padding: 4px 10px 10px; } .sidebar-caption { display: none; } .sidebar a { white-space: nowrap; } .main { margin: 0; padding: 0 16px 28px; } .topbar { min-height: 56px; margin: 0 -16px 20px; padding: 0 16px; } .summary-grid { grid-template-columns: 1fr; gap: 9px; } .period-toolbar { align-items: flex-start; flex-direction: column; } .page-heading { align-items: flex-start; flex-direction: column; } }
        @media (max-width: 480px) { .payroll-card { padding: 17px 14px; } .config-form { min-width: 340px; grid-template-columns: 1fr 1fr 80px; gap: 7px; } .period-filter .form-control { width: 86px; } }
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
                <li><a href="${pageContext.request.contextPath}/hr/branch-request"><i class="fa-solid fa-store"></i>Yêu cầu mở chi nhánh</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/hr/payroll"><i class="fa-solid fa-money-bill-wave"></i> Tính lương</a></li>
                <li><a href="${pageContext.request.contextPath}/director/reports"><i class="fa-solid fa-chart-pie"></i> Báo cáo toàn chuỗi</a></li>
            </ul>
        </aside>
<main class="main">
    <header class="topbar">
        <span class="topbar-title">Hệ thống quản trị nhân sự</span>
        <span class="topbar-user"><i class="fa-regular fa-circle-user me-1"></i><c:out value="${sessionScope.account.username}"/></span>
    </header>
    <div class="page-heading">
        <div>
            <div class="eyebrow">Payroll management</div>
            <h1>Tính lương nhân viên</h1>
            <p>Cấu hình mức lương, rà soát bảng nháp và chốt kỳ lương.</p>
        </div>
        <a class="btn btn-outline-secondary btn-sm px-3 py-2" href="${pageContext.request.contextPath}/hr/dashboard"><i class="fa-solid fa-house me-1"></i>Dashboard</a>
    </div>

    <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
    <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

    <section class="card payroll-card mb-4">
        <div class="period-toolbar mb-0">
            <div class="section-heading mb-0">
                <span class="section-icon"><i class="fa-regular fa-calendar"></i></span>
                <div><h2>Chọn kỳ lương</h2><p>Lọc bảng lương theo tháng và năm.</p></div>
            </div>
            <form method="get" action="${pageContext.request.contextPath}/hr/payroll" class="period-filter">
                <div><label for="month">Tháng</label><input class="form-control" id="month" type="number" name="month" min="1" max="12" value="${selectedMonth}" required></div>
                <div><label for="year">Năm</label><input class="form-control" id="year" type="number" name="year" min="2000" max="9999" value="${selectedYear}" required></div>
                <button class="btn btn-primary" type="submit"><i class="fa-solid fa-filter me-1"></i>Lọc</button>
            </form>
        </div>
    </section>

    <div class="summary-grid">
        <div class="summary-item"><span class="summary-icon"><i class="fa-regular fa-calendar"></i></span><div><div class="summary-label">Kỳ đang xem</div><div class="summary-value">${selectedMonth}/${selectedYear}</div></div></div>
        <div class="summary-item"><span class="summary-icon"><i class="fa-solid fa-list-check"></i></span><div><div class="summary-label">Phiếu lương kỳ này</div><div class="summary-value"><c:out value="${payrollPeriod == null ? 0 : payrollPeriod.payslipCount}"/> nhân viên</div></div></div>
        <div class="summary-item"><span class="summary-icon"><i class="fa-solid fa-file-circle-check"></i></span><div><div class="summary-label">Trạng thái</div><div class="summary-value"><c:choose><c:when test="${payrollPeriod == null}">Chưa tạo</c:when><c:when test="${payrollPeriod.status == 'FINALIZED'}">Đã chốt</c:when><c:otherwise>Bản nháp</c:otherwise></c:choose></div></div></div>
    </div>

    <div class="formula-note">
        <i class="fa-solid fa-circle-info"></i>
        <div><strong>Cách tính:</strong> FULL_TIME nhận lương tháng cố định; PART_TIME/CASUAL tính theo giờ chấm công hợp lệ × đơn giá giờ. Phụ cấp được cộng, vi phạm chưa bị từ chối được tính khấu trừ. Chưa áp dụng tăng ca, thuế, thưởng hoặc nghỉ phép có lương.</div>
    </div>

    <section class="card payroll-card mb-4">
        <div class="section-heading">
            <span class="section-icon"><i class="fa-solid fa-sliders"></i></span>
            <div><h2>Cấu hình lương nhân viên</h2><p>Thiết lập mức lương và phụ cấp cho từng nhân viên.</p></div>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle config-table">
                <thead><tr><th>Nhân viên</th><th>Chi nhánh</th><th>Loại nhân viên</th><th>Cấu hình và lưu</th></tr></thead>
                <tbody>
                <c:forEach items="${salaryEmployees}" var="employee">
                    <tr>
                        <td><div class="employee-name"><c:out value="${employee.fullName}"/></div><div class="employee-meta"><c:out value="${employee.username}"/></div></td>
                        <td><c:out value="${employee.branchName}"/></td>
                        <td><span class="type-pill ${employee.employeeType == 'FULL_TIME' ? 'full-time' : 'part-time'}"><c:choose>
                            <c:when test="${employee.employeeType == 'FULL_TIME'}">Toàn thời gian</c:when>
                            <c:when test="${employee.employeeType == 'PART_TIME'}">Bán thời gian</c:when>
                            <c:otherwise>Thời vụ</c:otherwise>
                        </c:choose></span></td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/hr/payroll" class="config-form">
                                <input type="hidden" name="action" value="saveSalary">
                                <input type="hidden" name="employeeId" value="${employee.userId}">
                                <input type="hidden" name="month" value="${selectedMonth}">
                                <input type="hidden" name="year" value="${selectedYear}">
                                <c:choose>
                                    <c:when test="${employee.employeeType == 'FULL_TIME'}">
                                        <div class="salary-field"><label>Lương tháng (đ)</label><input class="form-control" type="text" inputmode="decimal" name="monthlySalary" maxlength="13" pattern="[0-9]{1,10}(\.[0-9]{1,2})?" title="Chỉ nhập số, tối đa 10 chữ số nguyên và 2 chữ số thập phân." value="${employee.monthlySalary}" required></div>
                                        <input type="hidden" name="hourlyRate" value="0">
                                    </c:when>
                                    <c:otherwise>
                                        <input type="hidden" name="monthlySalary" value="">
                                        <div class="salary-field"><label>Đơn giá giờ (đ)</label><input class="form-control" type="text" inputmode="decimal" name="hourlyRate" maxlength="13" pattern="[0-9]{1,10}(\.[0-9]{1,2})?" title="Chỉ nhập số, tối đa 10 chữ số nguyên và 2 chữ số thập phân." value="${employee.hourlyRate}" required></div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="salary-field"><label>Phụ cấp tháng (đ)</label><input class="form-control" type="text" inputmode="decimal" name="monthlyAllowance" maxlength="13" pattern="[0-9]{1,10}(\.[0-9]{1,2})?" title="Chỉ nhập số, tối đa 10 chữ số nguyên và 2 chữ số thập phân." value="${employee.monthlyAllowance}" required></div>
                                <button class="btn btn-primary save-button" type="submit"><i class="fa-solid fa-floppy-disk me-1"></i>Lưu</button>
                                <div class="salary-status">
                                    <c:choose>
                                        <c:when test="${employee.salaryConfigured}"><span class="badge text-bg-success">Đã cấu hình</span></c:when>
                                        <c:otherwise><span class="badge text-bg-warning">Chưa cấu hình</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty salaryEmployees}"><tr><td colspan="4" class="empty-cell"><i class="fa-solid fa-users d-block fs-4 mb-2"></i>Chưa có nhân viên thuộc phạm vi tính lương.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </section>

    <section class="card payroll-card mb-4">
        <div class="period-toolbar">
            <div class="section-heading mb-0">
                <span class="section-icon"><i class="fa-solid fa-calculator"></i></span>
                <div><h2>Bảng lương theo kỳ</h2><p>Tạo, rà soát và chốt bảng lương đã lọc.</p></div>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty payrollPeriod || payrollPeriod.status == 'DRAFT'}">
                <form method="post" action="${pageContext.request.contextPath}/hr/payroll" class="mb-3">
                    <input type="hidden" name="action" value="generate">
                    <input type="hidden" name="month" value="${selectedMonth}">
                    <input type="hidden" name="year" value="${selectedYear}">
                    <button class="btn btn-primary" type="submit"><i class="fa-solid fa-rotate me-1"></i>
                        <c:choose><c:when test="${empty payrollPeriod}">Tạo bảng lương nháp</c:when><c:otherwise>Tính lại bảng nháp</c:otherwise></c:choose>
                    </button>
                </form>
            </c:when>
            <c:otherwise><span class="badge text-bg-success mb-3">Kỳ lương đã chốt</span></c:otherwise>
        </c:choose>

        <c:if test="${not empty payrollPeriod}">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
                <div class="d-flex align-items-center gap-2">
                    <span class="fw-bold">Kỳ lương ${payrollPeriod.month}/${payrollPeriod.year}</span>
                    <c:choose><c:when test="${payrollPeriod.status == 'FINALIZED'}"><span class="period-status finalized"><i class="fa-solid fa-circle-check"></i>Đã chốt</span></c:when><c:otherwise><span class="period-status"><i class="fa-solid fa-pen-to-square"></i>Bản nháp</span></c:otherwise></c:choose>
                </div>
                <span class="text-secondary small">${payrollPeriod.payslipCount} phiếu lương</span>
            </div>
            <div class="table-responsive table-wrap">
                <table class="table table-striped table-hover align-middle">
                    <thead><tr><th>Nhân viên</th><th>Loại</th><th class="text-end">Giờ công</th><th class="text-end">Lương cơ bản</th><th class="text-end">Phụ cấp</th><th class="text-end">Khấu trừ</th><th class="text-end">Thực nhận</th></tr></thead>
                    <tbody>
                    <c:forEach items="${payslips}" var="slip">
                        <tr>
                            <td><div class="employee-name"><c:out value="${slip.fullName}"/></div><div class="employee-meta"><c:out value="${slip.branchName}"/> · <c:out value="${slip.username}"/></div></td>
                            <td><span class="type-pill ${slip.employeeType == 'FULL_TIME' ? 'full-time' : 'part-time'}"><c:out value="${slip.employeeType == 'FULL_TIME' ? 'Toàn thời gian' : 'Bán thời gian/Thời vụ'}"/></span></td>
                            <td class="text-end"><fmt:formatNumber value="${slip.totalHours}" minFractionDigits="2" maxFractionDigits="2"/></td>
                            <td class="text-end"><fmt:formatNumber value="${slip.baseSalary}" maxFractionDigits="0"/> đ</td>
                            <td class="text-end"><fmt:formatNumber value="${slip.allowances}" maxFractionDigits="0"/> đ</td>
                            <td class="text-end text-danger"><fmt:formatNumber value="${slip.deductions}" maxFractionDigits="0"/> đ</td>
                            <td class="text-end net-salary"><fmt:formatNumber value="${slip.netSalary}" maxFractionDigits="0"/> đ</td>
                        </tr>
                    </c:forEach>
                    <c:if test="${not empty payslips}">
                        <tr class="table-light fw-bold">
                            <td colspan="2">Tổng cộng</td>
                            <td class="text-end"><fmt:formatNumber value="${totalHours}" minFractionDigits="2" maxFractionDigits="2"/> giờ</td>
                            <td class="text-end"><fmt:formatNumber value="${totalBaseSalary}" maxFractionDigits="0"/> đ</td>
                            <td class="text-end"><fmt:formatNumber value="${totalAllowances}" maxFractionDigits="0"/> đ</td>
                            <td class="text-end text-danger"><fmt:formatNumber value="${totalDeductions}" maxFractionDigits="0"/> đ</td>
                            <td class="text-end net-salary"><fmt:formatNumber value="${totalNetSalary}" maxFractionDigits="0"/> đ</td>
                        </tr>
                    </c:if>
                    <c:if test="${empty payslips}"><tr><td colspan="7" class="empty-cell"><i class="fa-solid fa-file-invoice-dollar d-block fs-4 mb-2"></i>Chưa có phiếu lương. Hãy tạo bảng nháp.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
            <c:if test="${payrollPeriod.status == 'DRAFT' and not empty payslips}">
                <form method="post" action="${pageContext.request.contextPath}/hr/payroll" onsubmit="return confirm('Chốt kỳ lương này? Sau khi chốt sẽ không thể tính lại.');">
                    <input type="hidden" name="action" value="finalize">
                    <input type="hidden" name="periodId" value="${payrollPeriod.id}">
                    <input type="hidden" name="month" value="${selectedMonth}">
                    <input type="hidden" name="year" value="${selectedYear}">
                    <button class="btn btn-success" type="submit"><i class="fa-solid fa-lock me-1"></i>Chốt bảng lương</button>
                </form>
            </c:if>
        </c:if>
    </section>

    <section class="card payroll-card">
        <div class="section-heading">
            <span class="section-icon"><i class="fa-solid fa-clock-rotate-left"></i></span>
            <div><h2>Lịch sử kỳ lương</h2><p>Tra cứu các bảng lương đã tạo trước đây.</p></div>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead><tr><th>Kỳ</th><th>Trạng thái</th><th>Số nhân viên</th><th></th></tr></thead>
                <tbody>
                <c:forEach items="${payrollPeriods}" var="pastPeriod">
                    <tr>
                        <td><c:out value="${pastPeriod.month}"/>/<c:out value="${pastPeriod.year}"/></td>
                        <td><c:out value="${pastPeriod.status}"/></td>
                        <td><c:out value="${pastPeriod.payslipCount}"/></td>
                        <td class="text-end"><a class="history-link" href="${pageContext.request.contextPath}/hr/payroll?month=${pastPeriod.month}&amp;year=${pastPeriod.year}">Xem bảng lương <i class="fa-solid fa-arrow-right ms-1"></i></a></td>
                    </tr>
                </c:forEach>
                <c:if test="${empty payrollPeriods}"><tr><td colspan="4" class="empty-cell">Chưa có kỳ lương nào.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </section>
</main>
</body>
</html>
