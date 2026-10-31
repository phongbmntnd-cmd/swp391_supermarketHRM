<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn từ &amp; Khiếu nại - Nhân viên</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f4f7f6;
            color: #333;
            display: flex;
            min-height: 100vh;
            overflow-x: hidden; /* Ngăn chặn hoàn toàn thanh cuộn ngang */
        }

        /* --- MAIN WRAPPER --- */
        .main-wrapper {
            flex: 1;
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        /* --- TOP NAVBAR --- */
        .top-navbar {
            background-color: #ffffff;
            color: #1e293b;
            padding: 15px 35px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            position: sticky;
            top: 0;
            z-index: 99;
            flex-wrap: wrap;
            gap: 15px;
        }

        .top-navbar h1 {
            font-size: 18px;
            font-weight: 500;
            color: #334155;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
            font-size: 14px;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .user-profile img {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #e2e8f0;
        }

        .btn-logout {
            color: #ef4444;
            text-decoration: none;
            background: #ffeeef;
            padding: 6px 14px;
            border-radius: 6px;
            font-weight: 500;
            font-size: 13px;
            transition: all 0.2s;
        }

        .btn-logout:hover {
            background: #ef4444;
            color: white;
        }

        /* --- CONTAINER --- */
        .container {
            max-width: 1400px;
            width: 100%;
            margin: 0 auto;
            padding: 30px;
        }

        /* --- PAGE HEADER (Tiêu đề và nút quay lại cùng một hàng) --- */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .page-header-left h2 {
            font-size: 24px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 4px;
        }

        .page-header-left p {
            color: #64748b;
            font-size: 14px;
        }

        /* --- BUTTON QUAY LẠI DASHBOARD --- */
        .btn-back-dashboard {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background-color: #ffffff;
            color: #475569;
            border: 1px solid #cbd5e1;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.2s ease;
            box-shadow: 0 1px 2px rgba(0,0,0,0.02);
            white-space: nowrap;
        }

        .btn-back-dashboard:hover {
            background-color: #f8fafc;
            color: #16a34a;
            border-color: #16a34a;
        }

        /* --- GRID CÁC LOẠI ĐƠN --- */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 22px;
        }

        .form-card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            border: none;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .form-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.1);
        }

        .form-card-body {
            padding: 26px 26px 20px 26px;
            flex-grow: 1;
        }

        .form-card-icon {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            margin-bottom: 16px;
        }

        .form-card h3 {
            font-size: 17px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 8px;
        }

        .form-card p {
            font-size: 13px;
            color: #64748b;
            line-height: 1.6;
            margin-bottom: 14px;
        }

        .form-card-footer {
            padding: 16px 26px;
            background-color: #f8fafc;
            border-top: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }

        .btn-open-form {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #16a34a;
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            transition: gap 0.2s;
        }

        .btn-open-form:hover {
            gap: 12px;
        }

        .badge-pending {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background-color: #fef3c7;
            color: #92400e;
            font-size: 12px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 20px;
        }

        /* --- EMPTY --- */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        }

        .empty-state i {
            font-size: 52px;
            color: #cbd5e1;
            margin-bottom: 16px;
        }

        .empty-state h3 {
            font-size: 17px;
            color: #475569;
            margin-bottom: 8px;
        }

        .empty-state p {
            font-size: 14px;
            color: #94a3b8;
        }

        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }
            .top-navbar {
                padding: 12px 20px;
            }
        }
    </style>
</head>
<body>

<%-- Sidebar dùng chung --%>
<jsp:include page="/WEB-INF/views/fragments/employee-sidebar.jsp"/>

<div class="main-wrapper">

    <%-- Top Header --%>
    <div class="top-navbar">
        <h1>Hệ Thống Quản Lý Siêu Thị - Đơn Từ &amp; Khiếu Nại</h1>
        <div class="user-info">
            <div class="user-profile">
                <img src="https://ui-avatars.com/api/?name=${emp != null && emp.fullName != null ? emp.fullName : sessionScope.account.username}&background=16a34a&color=fff" alt="Avatar">
                <span>Xin chào, <b>${emp != null && emp.fullName != null ? emp.fullName : sessionScope.account.username}</b></span>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
            </a>
        </div>
    </div>

    <div class="container">

        <!-- Tiêu đề và nút quay lại nằm cùng một hàng -->
        <div class="page-header">
            <div class="page-header-left">
                <h2>Đơn từ &amp; Khiếu nại</h2>
                <p>Chọn loại đơn bạn muốn tạo. Đơn sẽ được gửi lên Store Manager để xét duyệt.</p>
            </div>
            <a href="${pageContext.request.contextPath}/employee/dashboard" class="btn-back-dashboard">
                <i class="fa-solid fa-arrow-left"></i> Quay lại Dashboard
            </a>
        </div>

        <c:choose>
            <c:when test="${not empty forms}">
                <div class="form-grid">
                    <c:forEach var="f" items="${forms}">
                        <div class="form-card">
                            <div class="form-card-body">
                                <div class="form-card-icon"
                                     style="background-color: ${f.color}1a; color: ${f.color};">
                                    <i class="fa-solid ${f.icon}"></i>
                                </div>
                                <h3><c:out value="${f.title}"/></h3>
                                <p><c:out value="${f.description}"/></p>
                            </div>
                            <div class="form-card-footer">
                                <a href="${pageContext.request.contextPath}${f.url}" class="btn-open-form">
                                    Tạo đơn <i class="fa-solid fa-arrow-right"></i>
                                </a>
                                <c:if test="${f.pendingCount > 0}">
                                    <span class="badge-pending">
                                        <i class="fa-solid fa-clock"></i>
                                        ${f.pendingCount} đang chờ
                                    </span>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>

            <c:otherwise>
                <div class="empty-state">
                    <i class="fa-solid fa-inbox"></i>
                    <h3>Chưa có loại đơn nào</h3>
                    <p>Liên hệ quản lý để được hỗ trợ.</p>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
</div>

<script src="${pageContext.request.contextPath}/js/sidebar.js"></script>
</body>
</html>