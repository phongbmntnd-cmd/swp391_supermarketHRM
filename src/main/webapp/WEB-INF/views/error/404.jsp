<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>404 - Không tìm thấy</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #f5f5f5;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
            }
            .error-container {
                text-align: center;
                background: white;
                padding: 40px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .error-code {
                font-size: 72px;
                font-weight: bold;
                color: #e67e22;
                margin: 0;
            }
            .error-title {
                font-size: 24px;
                color: #333;
                margin: 20px 0;
            }
            .error-message {
                color: #666;
                margin-bottom: 30px;
            }
            .btn {
                display: inline-block;
                padding: 12px 24px;
                background-color: #3498db;
                color: white;
                text-decoration: none;
                border-radius: 4px;
                transition: background-color 0.3s;
            }
            .btn:hover {
                background-color: #2980b9;
            }
        </style>
    </head>
    <body>
        <div class="error-container">
            <h1 class="error-code">404</h1>
            <h2 class="error-title">Không tìm thấy</h2>
            <p class="error-message">
                <%= request.getAttribute("errorMessage") != null 
                    ? request.getAttribute("errorMessage") 
                    : "Trang hoặc tài nguyên bạn yêu cầu không tồn tại." %>
            </p>
            <a href="${pageContext.request.contextPath}/login" class="btn">
                Quay về Trang chủ / Đăng nhập
            </a>
        </div>
    </body>
</html>
