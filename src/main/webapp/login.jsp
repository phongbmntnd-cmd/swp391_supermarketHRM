<%-- 
    Document   : login
    Created on : 23 thg 9, 2026, 00:23:56
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập | Hệ Thống Quản Lý Nhân Sự Siêu Thị</title>
    
    <!-- Google Font & Bootstrap Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .login-wrapper {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3), 0 8px 10px -6px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 440px;
            padding: 40px;
        }

        .brand-header {
            text-align: center;
            margin-bottom: 32px;
        }

        .brand-logo {
            width: 56px;
            height: 56px;
            background: #2563eb;
            color: #ffffff;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            margin-bottom: 12px;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
        }

        .brand-title {
            font-size: 22px;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 6px;
        }

        .brand-subtitle {
            font-size: 14px;
            color: #64748b;
        }

        .alert-danger {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            color: #334155;
            margin-bottom: 8px;
        }

        .input-group {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            color: #94a3b8;
            font-size: 18px;
        }

        .form-control {
            width: 100%;
            padding: 12px 14px 12px 42px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 15px;
            color: #0f172a;
            transition: all 0.2s ease;
            outline: none;
        }

        .form-control:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
        }

        .btn-primary {
            width: 100%;
            padding: 12px;
            background-color: #2563eb;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s ease;
            margin-top: 8px;
        }

        .btn-primary:hover {
            background-color: #1d4ed8;
        }

        .demo-accounts {
            margin-top: 32px;
            padding-top: 20px;
            border-top: 1px dashed #e2e8f0;
        }

        .demo-title {
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            color: #94a3b8;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
            text-align: center;
        }

        .demo-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 8px;
            font-size: 12px;
        }

        .demo-item {
            background-color: #f8fafc;
            padding: 8px 10px;
            border-radius: 6px;
            border: 1px solid #f1f5f9;
            color: #475569;
        }

        .demo-role {
            font-weight: 600;
            color: #2563eb;
            display: block;
            margin-bottom: 2px;
        }
    </style>
</head>
<body>

<div class="login-wrapper">
    <!-- Header Logo & Title -->
    <div class="brand-header">
        <div class="brand-logo">
            <i class="bi bi-cart-check-fill"></i>
        </div>
        <h1 class="brand-title">Supermarket HRM</h1>
        <p class="brand-subtitle">Hệ thống quản lý nhân sự 3 cơ sở</p>
    </div>

    <!-- Thông báo lỗi -->
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert-danger">
            <i class="bi bi-exclamation-circle-fill"></i>
            <span><%= request.getAttribute("error") %></span>
        </div>
    <% } %>

    <!-- Form Đăng nhập -->
    <form action="login" method="post">
        <div class="form-group">
            <label class="form-label" for="username">Tên đăng nhập</label>
            <div class="input-group">
                <i class="bi bi-person input-icon"></i>
                <input type="text" id="username" name="username" class="form-control" 
                       placeholder="Nhập tài khoản của bạn" required autocomplete="off">
            </div>
        </div>

        <div class="form-group">
            <label class="form-label" for="password">Mật khẩu</label>
            <div class="input-group">
                <i class="bi bi-lock input-icon"></i>
                <input type="password" id="password" name="password" class="form-control" 
                       placeholder="••••••••" required>
            </div>
        </div>

        <button type="submit" class="btn-primary">
            Đăng Nhập <i class="bi bi-arrow-right-short"></i>
        </button>
    </form>

    <!-- Bảng gợi ý tài khoản mẫu để Test nhanh -->
    <div class="demo-accounts">
        <div class="demo-title">Tài khoản thử nghiệm (Pass: 123456)</div>
        <div class="demo-grid">
            <div class="demo-item">
                <span class="demo-role">System Admin</span>
                <code>admin_user</code>
            </div>
            <div class="demo-item">
                <span class="demo-role">Director</span>
                <code>director_user</code>
            </div>
            <div class="demo-item">
                <span class="demo-role">HR Manager</span>
                <code>hrm_user</code>
            </div>
            <div class="demo-item">
                <span class="demo-role">Store Manager</span>
                <code>sm_user</code>
            </div>
            <div class="demo-item" style="grid-column: span 2;">
                <span class="demo-role">Employee</span>
                <code>emp_user</code>
            </div>
        </div>
    </div>
</div>

</body>
</html>
