<%--
    Shared password change screen for Admin / Director / HR Manager / Store Manager.
    Path: /WEB-INF/views/change_password/change_password.jsp
    Servlet: ChangePasswordServlet2 -> /account/change-password
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Đổi mật khẩu - Supermarket HRM</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                margin: 0;
                font-family: Arial, sans-serif;
                background: #f4f7f6;
                color: #1e293b;
                min-height: 100vh;
            }
            .sidebar {
                width: 260px;
                position: fixed;
                inset: 0 auto 0 0;
                background: #0f172a;
                color: #fff;
            }
            .brand {
                background: #020617;
                padding: 25px 20px;
                font-size: 18px;
                font-weight: bold;
            }
            .brand i {
                color: #ef4444;
                margin-right: 10px;
            }
            .sidebar a {
                display: block;
                padding: 15px 24px;
                text-decoration: none;
                color: #94a3b8;
                border-left: 4px solid transparent;
            }
            .sidebar a i {
                width: 25px;
            }
            .sidebar a:hover, .sidebar a.active {
                background: #1e293b;
                color: #fff;
                border-left-color: #ef4444;
            }
            .main {
                margin-left: 260px;
            }
            .top {
                background: #fff;
                padding: 22px 32px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 16px;
                box-shadow: 0 1px 4px #ddd;
            }
            .top h1 {
                font-size: 19px;
                margin: 0;
            }
            .top .user {
                font-size: 14px;
                color: #475569;
            }
            .card {
                background: #fff;
                max-width: 670px;
                margin: 36px auto;
                padding: 34px;
                border-radius: 12px;
                box-shadow: 0 4px 14px #0000000d;
            }
            .card h2 {
                font-size: 24px;
                margin: 0 0 10px;
            }
            .card p {
                color: #64748b;
                line-height: 1.5;
                margin: 0 0 24px;
            }
            label {
                display: block;
                font-weight: 600;
                font-size: 14px;
                margin: 18px 0 8px;
            }
            .field {
                display: flex;
                border: 1px solid #cbd5e1;
                border-radius: 8px;
                overflow: hidden;
            }
            .field:focus-within {
                border-color: #dc2626;
                box-shadow: 0 0 0 2px #fee2e2;
            }
            .field input {
                width: 100%;
                padding: 14px;
                border: none;
                outline: none;
                font-size: 15px;
                min-width: 0;
            }
            .field button {
                background: #fff;
                border: 0;
                cursor: pointer;
                padding: 0 16px;
                color: #64748b;
            }
            .hint {
                font-size: 12px;
                color: #64748b;
                margin-top: 7px;
            }
            .actions {
                display: flex;
                align-items: center;
                gap: 20px;
                margin-top: 26px;
            }
            .save {
                background: #dc2626;
                color: #fff;
                padding: 13px 20px;
                border: 0;
                border-radius: 8px;
                font-size: 14px;
                cursor: pointer;
            }
            .save:hover {
                background: #b91c1c;
            }
            .cancel {
                color: #475569;
                text-decoration: none;
                font-size: 14px;
            }
            .msg {
                border-radius: 8px;
                padding: 14px;
                margin-bottom: 14px;
            }
            .msg.error {
                background: #fef2f2;
                color: #991b1b;
            }
            .msg.success {
                background: #f0fdf4;
                color: #166534;
            }
            @media(max-width: 800px) {
                .sidebar {
                    width: 100%;
                    height: auto;
                    position: static;
                }
                .main {
                    margin-left: 0;
                }
                .card {
                    margin: 20px 12px;
                    padding: 22px;
                }
                .top {
                    padding: 18px;
                    flex-wrap: wrap;
                }
            }
        </style>
    </head>
    <body>
        <aside class="sidebar">
            <div class="brand">
                <i class="fa-solid fa-shield-halved"></i>
                <c:out value="${roleLabel}" />
            </div>
            <a href="<c:out value='${dashboardUrl}'/>">
                <i class="fa-solid fa-gauge-high"></i> Tổng quan
            </a>
            <a class="active" href="${pageContext.request.contextPath}/account/change-password" aria-current="page">
                <i class="fa-solid fa-key"></i> Đổi mật khẩu
            </a>
        </aside>

        <div class="main">
            <header class="top">
                <h1>Bảo mật tài khoản</h1>
                <div class="user">Xin chào, <b><c:out value="${sessionScope.account.username}" /></b></div>
            </header>

            <main class="card">
                <h2><i class="fa-solid fa-key" style="color:#dc2626"></i> Đổi mật khẩu</h2>
                <p>Nhập mật khẩu hiện tại và mật khẩu mới để cập nhật mật khẩu đăng nhập của bạn.</p>

                <c:if test="${not empty error}">
                    <div class="msg error" role="alert"><c:out value="${error}" /></div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="msg success" role="status"><c:out value="${success}" /></div>
                </c:if>

                <form id="changePasswordForm" method="post"
                      action="${pageContext.request.contextPath}/account/change-password"
                      autocomplete="off">
                    <input type="hidden" name="csrfToken" value="<c:out value='${sessionScope.changePasswordCsrf}'/>">

                    <label for="currentPassword">Mật khẩu hiện tại</label>
                    <div class="field">
                        <input id="currentPassword" name="currentPassword" type="password"
                               autocomplete="current-password" required maxlength="128">
                        <button type="button" class="toggle" data-for="currentPassword" aria-label="Hiện hoặc ẩn mật khẩu hiện tại">
                            <i class="fa-regular fa-eye"></i>
                        </button>
                    </div>

                    <label for="newPassword">Mật khẩu mới</label>
                    <div class="field">
                        <input id="newPassword" name="newPassword" type="password"
                               autocomplete="new-password" required minlength="8" maxlength="128">
                        <button type="button" class="toggle" data-for="newPassword" aria-label="Hiện hoặc ẩn mật khẩu mới">
                            <i class="fa-regular fa-eye"></i>
                        </button>
                    </div>
                    <div class="hint">Từ 8 đến 128 ký tự, khác mật khẩu hiện tại.</div>

                    <label for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <div class="field">
                        <input id="confirmPassword" name="confirmPassword" type="password"
                               autocomplete="new-password" required minlength="8" maxlength="128">
                        <button type="button" class="toggle" data-for="confirmPassword" aria-label="Hiện hoặc ẩn mật khẩu xác nhận">
                            <i class="fa-regular fa-eye"></i>
                        </button>
                    </div>

                    <div class="msg error" id="clientError" style="display:none" role="alert"></div>
                    <div class="actions">
                        <button class="save" type="submit"><i class="fa-solid fa-floppy-disk"></i> Lưu mật khẩu mới</button>
                        <a class="cancel" href="<c:out value='${dashboardUrl}'/>">Hủy</a>
                    </div>
                </form>
            </main>
        </div>

        <script>
            document.querySelectorAll('.toggle').forEach(function (button) {
                button.addEventListener('click', function () {
                    var input = document.getElementById(button.dataset.for);
                    input.type = input.type === 'password' ? 'text' : 'password';
                    button.querySelector('i').className = input.type === 'password'
                            ? 'fa-regular fa-eye' : 'fa-regular fa-eye-slash';
                });
            });

            document.getElementById('changePasswordForm').addEventListener('submit', function (event) {
                var oldPassword = document.getElementById('currentPassword').value;
                var newPassword = document.getElementById('newPassword').value;
                var confirmPassword = document.getElementById('confirmPassword').value;
                var message = '';

                if (!oldPassword || !newPassword || !confirmPassword) {
                    message = 'Vui lòng nhập đầy đủ các ô mật khẩu.';
                } else if (newPassword.length < 8 || newPassword.length > 128) {
                    message = 'Mật khẩu mới phải từ 8 đến 128 ký tự.';
                } else if (oldPassword === newPassword) {
                    message = 'Mật khẩu mới phải khác mật khẩu hiện tại.';
                } else if (newPassword !== confirmPassword) {
                    message = 'Xác nhận mật khẩu mới không khớp.';
                }

                var errorBox = document.getElementById('clientError');
                errorBox.textContent = message;
                errorBox.style.display = message ? 'block' : 'none';
                if (message)
                    event.preventDefault();
            });
        </script>
    </body>
</html>
