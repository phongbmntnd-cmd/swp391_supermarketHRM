
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý đổi ca</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f4f7f6;
            }

            .page-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 12px;
                margin-bottom: 25px;
            }

            .page-header h2 {
                font-size: 24px;
                font-weight: 600;
                color: #1e293b;
                margin: 0;
            }

            .page-actions {
                display: flex;
                gap: 10px;
            }

            .btn-soft {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                text-decoration: none;
                font-size: 13px;
                font-weight: 500;
                padding: 8px 16px;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
                background: #ffffff;
                color: #475569;
                transition: all 0.2s;
            }

            .btn-soft:hover {
                border-color: #2563eb;
                color: #2563eb;
            }

            .card {
                border: none;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            }
        </style>
    </head>

    <body>

    <%-- Sidebar dùng chung --%>
    <jsp:include page="/WEB-INF/views/fragments/store-manager-sidebar.jsp"/>

    <div class="main-wrapper">
        <div class="container py-4">

            <div class="page-header">
                <h2>Quản lý yêu cầu đổi ca</h2>
                <div class="page-actions">
                    <a class="btn-soft"
                       href="${pageContext.request.contextPath}/store-manager/forms">
                        <i class="fa-solid fa-arrow-left"></i> Đơn từ &amp; Khiếu nại
                    </a>
                    <a class="btn-soft"
                       href="${pageContext.request.contextPath}/store-manager/schedule">
                        <i class="fa-solid fa-calendar-days"></i> Lịch làm việc
                    </a>
                </div>
            </div>

            <c:if test="${param.success eq '1'}">
                <div class="alert alert-success">
                    Thao tác thành công.
                </div>
            </c:if>

            <c:if test="${param.invalid eq '1'}">
                <div class="alert alert-warning">
                    Không thể thực hiện. Vui lòng kiểm tra lại
                    trạng thái đơn hoặc lịch làm việc.
                </div>
            </c:if>

            <!-- Danh sách yêu cầu -->
            <div class="card shadow-sm mb-4">
                <div class="card-body">
                    <h4>Danh sách đơn chờ xử lý</h4>

                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Nhân viên</th>
                                    <th>Hình thức</th>
                                    <th>Ca hiện tại</th>
                                    <th>Ca muốn đổi</th>
                                    <th>Đồng nghiệp</th>
                                    <th>Lý do</th>
                                    <th>Trạng thái</th>
                                    <th>Xử lý</th>
                                </tr>
                            </thead>

                            <tbody>
                                <c:forEach var="r" items="${requestList}">
                                    <tr>
                                        <td>${r.id}</td>
                                        <td><c:out value="${r.employeeName}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.requestType eq 'SWAP'}">
                                                    Đổi với đồng nghiệp
                                                </c:when>
                                                <c:otherwise>
                                                    Chuyển sang ca trống
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:out value="${r.myDate}"/>
                                            -
                                            <c:out value="${r.myShift}"/>
                                        </td>
                                        <td>
                                            <c:out value="${r.targetDate}"/>
                                            -
                                            <c:out value="${r.targetShift}"/>
                                        </td>
                                        <td><c:out value="${r.colleagueName}"/></td>
                                        <td><c:out value="${r.reason}"/></td>
                                        <td>
                                            <c:out value="${r.status}"/>
                                            <c:if test="${not empty r.response}">
                                                <div class="small text-muted">
                                                    <c:out value="${r.response}"/>
                                                </div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${r.status eq 'PENDING'}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/store-manager/shift-requests">

                                                    <input type="hidden"
                                                           name="requestId"
                                                           value="${r.id}">

                                                    <input type="text"
                                                           name="response"
                                                           maxlength="255"
                                                           class="form-control form-control-sm mb-2"
                                                           placeholder="Ghi chú của quản lý">

                                                    <button name="action"
                                                            value="approve"
                                                            type="submit"
                                                            class="btn btn-success btn-sm mb-1">
                                                        Duyệt
                                                    </button>

                                                    <button name="action"
                                                            value="reject"
                                                            type="submit"
                                                            class="btn btn-danger btn-sm mb-1">
                                                        Từ chối
                                                    </button>
                                                </form>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty requestList}">
                                    <tr>
                                        <td colspan="9" class="text-center">
                                            Chưa có đơn đổi ca.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/sidebar.js"></script>
    </body>
</html>
