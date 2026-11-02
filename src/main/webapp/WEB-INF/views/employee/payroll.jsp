<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Phiếu lương của tôi</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { margin: 0; min-height: 100vh; display: flex; background: #f4f7f6; color: #1e293b; font-family: Arial, sans-serif; }
        .sidebar { width: 250px; position: fixed; inset: 0 auto 0 0; background: #1e293b; color: #fff; padding: 22px 0; }
        .sidebar-brand { padding: 0 22px 22px; font-size: 18px; font-weight: 700; }
        .sidebar ul { list-style: none; padding: 0; }
        .sidebar a { display: block; padding: 12px 22px; color: #cbd5e1; text-decoration: none; }
        .sidebar a:hover, .sidebar .active a { color: #fff; background: #334155; }
        .main { margin-left: 250px; padding: 28px; width: calc(100% - 250px); }
        .card { border: 0; border-radius: 12px; box-shadow: 0 4px 16px rgba(15,23,42,.06); }
        @media (max-width: 800px) { body { display: block; } .sidebar { position: static; width: auto; } .main { margin: 0; padding: 16px; width: auto; } }
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="sidebar-brand"><i class="fa-solid fa-id-badge me-2"></i>Employee Portal</div>
    <ul>
        <li><a href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-house me-2"></i>Trang chủ</a></li>
        <li><a href="${pageContext.request.contextPath}/employee/my-schedule"><i class="fa-solid fa-calendar-check me-2"></i>Lịch làm việc</a></li>
        <li><a href="${pageContext.request.contextPath}/employee/attendance"><i class="fa-solid fa-fingerprint me-2"></i>Chấm công</a></li>
        <li class="active"><a href="${pageContext.request.contextPath}/employee/payroll"><i class="fa-solid fa-money-bill-wave me-2"></i>Phiếu lương</a></li>
        <li><a href="${pageContext.request.contextPath}/employee/violations"><i class="fa-solid fa-triangle-exclamation me-2"></i>Vi phạm &amp; kết quả</a></li>
    </ul>
</aside>
<main class="main">
    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
        <div><h1 class="h3 mb-1">Phiếu lương của tôi</h1><p class="text-secondary mb-0">Chỉ hiển thị kỳ lương đã được HR chốt.</p></div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-house me-1"></i>Trang chủ</a>
    </div>
    <div class="alert alert-info">Các kỳ lương nháp chưa được hiển thị. Nếu có thắc mắc về số liệu, vui lòng liên hệ HR.</div>
    <c:forEach items="${payslips}" var="slip">
        <section class="card p-3 p-lg-4 mb-3">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                <h2 class="h5 mb-0">Kỳ lương tháng <c:out value="${slip.month}"/>/<c:out value="${slip.year}"/></h2>
                <span class="badge text-bg-success">Đã chốt</span>
            </div>
            <div class="table-responsive">
                <table class="table mb-0">
                    <tbody>
                        <tr><th>Giờ công hợp lệ</th><td class="text-end"><fmt:formatNumber value="${slip.totalHours}" minFractionDigits="2" maxFractionDigits="2"/> giờ</td></tr>
                        <tr><th>Lương cơ bản</th><td class="text-end"><fmt:formatNumber value="${slip.baseSalary}" maxFractionDigits="0"/> đ</td></tr>
                        <tr><th>Phụ cấp</th><td class="text-end"><fmt:formatNumber value="${slip.allowances}" maxFractionDigits="0"/> đ</td></tr>
                        <tr><th>Khấu trừ</th><td class="text-end text-danger"><fmt:formatNumber value="${slip.deductions}" maxFractionDigits="0"/> đ</td></tr>
                        <tr class="table-light"><th>Thực nhận</th><td class="text-end fw-bold"><fmt:formatNumber value="${slip.netSalary}" maxFractionDigits="0"/> đ</td></tr>
                    </tbody>
                </table>
            </div>
        </section>
    </c:forEach>
    <c:if test="${empty payslips}"><div class="card p-4 text-center text-secondary">Chưa có phiếu lương đã chốt.</div></c:if>
</main>
</body>
</html>
