<%-- 
    Document   : newjsp
    Created on : Oct 27, 2026, 10:09:50 PM
    Author     : Lenovo
--%>

<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Vi phạm và kết quả - Employee Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Roboto', sans-serif; background: #f4f7f6; color: #333; display: flex; min-height: 100vh; }
        .sidebar { width: 260px; background: #1e293b; color: #94a3b8; display: flex; flex-direction: column; position: fixed; inset: 0 auto 0 0; z-index: 100; box-shadow: 2px 0 10px rgba(0,0,0,.1); }
        .sidebar-brand { padding: 25px 20px; font-size: 18px; font-weight: 700; color: #fff; background: #0f172a; display: flex; align-items: center; gap: 10px; }
        .sidebar-brand i { color: #22c55e; font-size: 22px; }
        .sidebar-menu { list-style: none; padding: 20px 0; margin: 0; overflow-y: auto; }
        .sidebar-menu a { display: flex; align-items: center; gap: 15px; padding: 14px 25px; color: #94a3b8; text-decoration: none; font-size: 14px; font-weight: 500; border-left: 4px solid transparent; }
        .sidebar-menu a:hover, .sidebar-menu .active a { color: #fff; background: rgba(255,255,255,.05); border-left-color: #22c55e; }
        .sidebar-menu i { width: 20px; text-align: center; }
        .main-wrapper { margin-left: 260px; flex: 1; min-width: 0; }
        .top-navbar { background: #fff; color: #1e293b; padding: 15px 35px; display: flex; justify-content: space-between; align-items: center; gap: 20px; box-shadow: 0 1px 3px rgba(0,0,0,.05); position: sticky; top: 0; z-index: 99; }
        .top-navbar h1 { margin: 0; font-size: 18px; font-weight: 500; color: #334155; }
        .user-info { display: flex; align-items: center; gap: 20px; font-size: 14px; }
        .btn-logout { color: #ef4444; text-decoration: none; background: #ffeeef; padding: 6px 14px; border-radius: 6px; font-weight: 500; font-size: 13px; white-space: nowrap; }
        .page-content { max-width: 1400px; margin: 30px; }
        .page-title { background: linear-gradient(135deg,#16a34a,#15803d); color: #fff; padding: 25px 30px; border-radius: 12px; margin-bottom: 25px; box-shadow: 0 10px 15px -3px rgba(22,163,74,.2); }
        .page-title h2 { margin: 0 0 8px; font-size: 24px; }
        .page-title p { margin: 0; opacity: .9; }
        .card { border: 0; border-radius: 10px; }
        .card-header { background: #fff; padding: 16px 20px; }
        @media (max-width: 900px) { .sidebar { width: 220px; } .main-wrapper { margin-left: 220px; } .top-navbar { padding: 14px 20px; } .page-content { margin: 20px; } }
        @media (max-width: 650px) { body { display: block; } .sidebar { position: static; width: 100%; } .sidebar-menu { display: flex; overflow-x: auto; padding: 5px 0; } .sidebar-menu li { flex: 0 0 auto; } .sidebar-menu a { padding: 12px; } .main-wrapper { margin-left: 0; } .top-navbar { position: static; flex-wrap: wrap; } .page-content { margin: 15px; } }
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="sidebar-brand"><i class="fa-solid fa-id-badge"></i><span>Employee Portal</span></div>
    <ul class="sidebar-menu">
        <li><a href="${pageContext.request.contextPath}/employee/dashboard"><i class="fa-solid fa-house"></i> Trang chủ</a></li>
        <li><a href="${pageContext.request.contextPath}/employee/availability"><i class="fa-solid fa-calendar-plus"></i> Khai báo lịch rảnh</a></li>
        <li><a href="${pageContext.request.contextPath}/employee/my-schedule"><i class="fa-solid fa-calendar-check"></i> Lịch làm việc</a></li>
        <li><a href="#"><i class="fa-solid fa-fingerprint"></i> Chấm công trực tuyến</a></li>
        <li><a href="#"><i class="fa-solid fa-file-lines"></i> Đơn từ & Khiếu nại</a></li>
        <li class="active"><a href="${pageContext.request.contextPath}/employee/violations"><i class="fa-solid fa-triangle-exclamation"></i> Vi phạm & kết quả</a></li>
    </ul>
</aside>
<div class="main-wrapper">
    <header class="top-navbar">
        <h1>Hệ Thống Quản Lý Siêu Thị - Không Gian Nhân Viên</h1>
        <div class="user-info"><span>Xin chào, <b><c:out value="${sessionScope.account.username}"/></b></span><a href="${pageContext.request.contextPath}/logout" class="btn-logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a></div>
    </header>
    <main class="page-content">
        <div class="page-title"><h2><i class="fa-solid fa-triangle-exclamation me-2"></i>Vi phạm và kết quả xử lý</h2><p>Bạn có thể theo dõi báo cáo, trạng thái xác minh và kết quả HR.</p></div>
        <div class="alert alert-info"><i class="fa-solid fa-circle-info me-2"></i>Báo cáo đang chờ HR xác minh chưa phải là kết luận vi phạm.</div>
        <c:forEach items="${violations}" var="v">
            <article class="card shadow-sm mb-3">
                <div class="card-header d-flex justify-content-between gap-2 flex-wrap"><strong><c:out value="${v.title}"/></strong><span><c:out value="${v.violationDate}"/></span></div>
                <div class="card-body p-4">
                    <p><strong>Loại:</strong> <c:out value="${v.categoryLabel}"/> · <strong>Chi nhánh:</strong> <c:out value="${v.branchName}"/></p>
                    <p><strong>Nội dung báo cáo:</strong> <c:out value="${v.description}"/></p>
                    <p><strong>Trạng thái:</strong> <c:choose><c:when test="${v.status == 'PENDING_REVIEW'}"><span class="badge text-bg-warning">Đang chờ HR xác minh</span> — chưa có quyết định kỷ luật.</c:when><c:when test="${v.status == 'APPROVED'}"><span class="badge text-bg-success">Đã được HR xác minh</span></c:when><c:when test="${v.status == 'REJECTED'}"><span class="badge text-bg-secondary">HR đã từ chối báo cáo</span></c:when><c:otherwise>Bản ghi lịch sử.</c:otherwise></c:choose></p>
                    <c:if test="${not empty v.disciplinaryAction}"><p><strong>Quyết định xử lý:</strong> <c:out value="${v.disciplinaryAction}"/></p></c:if>
                    <c:if test="${v.deductionAmount > 0}"><p><strong>Khoản khấu trừ lương đã ghi nhận:</strong> <c:out value="${v.deductionAmount}"/> đ <span class="text-secondary">(tính vào kỳ lương theo tháng xảy ra vi phạm)</span></p></c:if>
                    <c:if test="${not empty v.reviewNote}"><p class="mb-0"><strong>Ghi chú HR:</strong> <c:out value="${v.reviewNote}"/></p></c:if>
                </div>
            </article>
        </c:forEach>
        <c:if test="${empty violations}"><div class="alert alert-info">Bạn chưa có báo cáo vi phạm nào.</div></c:if>
    </main>
</div>
</body>
</html>
