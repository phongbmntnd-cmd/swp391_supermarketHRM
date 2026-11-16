
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đổi Mật Khẩu</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <style>
        body {
            background: #f4f6f9;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }
        .card-custom {
            width: 100%;
            max-width: 420px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>

<div class="card card-custom p-4 bg-white">

    <h4 class="text-center text-primary mb-3">
        <c:choose>
            <c:when test="${sessionScope.account.firstLogin}">
                Đổi Mật Khẩu Lần Đầu
            </c:when>
            <c:otherwise>
                Đổi Mật Khẩu
            </c:otherwise>
        </c:choose>
    </h4>

    <c:if test="${sessionScope.account.firstLogin}">
        <div class="alert alert-warning text-center small" role="alert">
            Đây là lần đầu đăng nhập.
            Bạn bắt buộc phải đổi mật khẩu để tiếp tục.
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger text-center small" role="alert">
            <c:out value="${error}" />
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/change-password"
          method="post">

        <div class="mb-3">
            <label class="form-label">Mật khẩu hiện tại</label>

            <c:choose>
                <c:when test="${sessionScope.account.firstLogin}">
                    <input type="password"
                           class="form-control"
                           value="••••••"
                           disabled>
                    <div class="form-text">
                        Mật khẩu khởi tạo đã được xác nhận khi đăng nhập.
                    </div>
                </c:when>

                <c:otherwise>
                    <input type="password"
                           name="oldPassword"
                           class="form-control"
                           placeholder="Nhập mật khẩu hiện tại"
                           autocomplete="current-password"
                           required>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="mb-3">
            <label class="form-label">Mật khẩu mới</label>
            <input type="password"
                   name="newPassword"
                   class="form-control"
                   placeholder="Tối thiểu 6 ký tự"
                   minlength="6"
                   autocomplete="new-password"
                   required>
        </div>

        <div class="mb-4">
            <label class="form-label">Xác nhận mật khẩu mới</label>
            <input type="password"
                   name="confirmPassword"
                   class="form-control"
                   placeholder="Nhập lại mật khẩu mới"
                   autocomplete="new-password"
                   required>
        </div>

        <button type="submit" class="btn btn-primary w-100 py-2">
            Xác Nhận Đổi Mật Khẩu
        </button>
    </form>

</div>

</body>
</html>
