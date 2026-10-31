
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

            <c:if test="${param.openCreated eq '1'}">
                <div class="alert alert-success">
                    Đã tạo ca trống. Nhân viên có thể đề nghị
                    chuyển ca sang ca này.
                </div>
            </c:if>

            <!-- ============ Tạo ca trống ============ -->
            <div class="card shadow-sm mb-4">
                <div class="card-body">
                    <h4>
                        <i class="fa-solid fa-inbox text-primary"></i>
                        Quản lý ca trống
                    </h4>

                    <p class="text-muted" style="font-size: 13px;">
                        Ca trống là ca đang thiếu người làm.
                        Tạo ca trống để nhân viên có thể đề nghị
                        chuyển ca của họ sang ca này.
                    </p>

                    <form method="post"
                          action="${pageContext.request.contextPath}/store-manager/shift-requests"
                          class="row g-2 align-items-end mb-3">

                        <input type="hidden"
                               name="action"
                               value="createOpenShift">

                        <div class="col-md-3">
                            <label class="form-label">Ca làm việc</label>
                            <select name="shiftId"
                                    class="form-select" required>
                                <option value="">-- Chọn ca --</option>
                                <c:forEach var="s" items="${allShifts}">
                                    <option value="${s.id}">
                                        <c:out value="${s.name}"/>
                                        (<c:out value="${s.startTime}"/>
                                        - <c:out value="${s.endTime}"/>)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Vị trí công tác</label>
                            <select name="positionId"
                                    class="form-select" required>
                                <option value="">-- Chọn vị trí --</option>
                                <c:forEach var="p" items="${allPositions}">
                                    <option value="${p.id}">
                                        <c:out value="${p.title}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Ngày làm việc</label>
                            <input type="date"
                                   name="workDate"
                                   class="form-control"
                                   min="<%= java.time.LocalDate.now() %>"
                                   required>
                        </div>

                        <div class="col-md-3">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-plus"></i>
                                Tạo ca trống
                            </button>
                        </div>
                    </form>

                    <div class="table-responsive">
                        <table class="table table-bordered table-sm">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Ngày</th>
                                    <th>Ca</th>
                                    <th>Vị trí</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="os" items="${openShiftList}">
                                    <tr>
                                        <td>${os.id}</td>
                                        <td>
                                            <c:out value="${os.workDate}"/>
                                        </td>
                                        <td>
                                            <c:out value="${os.shiftName}"/>
                                        </td>
                                        <td>
                                            <c:out value="${os.positionTitle}"/>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${os.status eq 'OPEN'}">
                                                    <span class="badge bg-success">
                                                        Đang mở
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">
                                                        Đã đóng
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty openShiftList}">
                                    <tr>
                                        <td colspan="5" class="text-center">
                                            Chưa có ca trống nào.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

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
                                                    <span class="badge bg-info">
                                                        Đổi với đồng nghiệp
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-primary">
                                                        Chuyển sang ca trống
                                                    </span>
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
                                            <c:choose>
                                                <c:when test="${r.status eq 'WAITING_COLLEAGUE'}">
                                                    <span class="badge bg-warning">
                                                        Chờ đồng nghiệp
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.status eq 'PENDING'}">
                                                    <span class="badge bg-warning">
                                                        Chờ duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.status eq 'APPROVED'}">
                                                    <span class="badge bg-success">
                                                        Đã duyệt
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.status eq 'REJECTED'}">
                                                    <span class="badge bg-danger">
                                                        Bị từ chối
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.status eq 'DECLINED'}">
                                                    <span class="badge bg-danger">
                                                        Đồng nghiệp từ chối
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.status eq 'CANCELLED'}">
                                                    <span class="badge bg-secondary">
                                                        Đã hủy
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-dark">
                                                        <c:out value="${r.status}"/>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
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
