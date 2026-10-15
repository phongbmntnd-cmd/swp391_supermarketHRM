
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý đổi ca</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">
    </head>

    <body class="bg-light">
        <div class="container py-4">

            <div class="d-flex justify-content-between mb-4">
                <h2>Quản lý yêu cầu đổi ca</h2>
                <a class="btn btn-secondary"
                   href="${pageContext.request.contextPath}/store-manager/schedule">
                    Quản lý lịch làm việc
                </a>
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

            <!-- Tạo ca trống -->
            <div class="card shadow-sm mb-4">
                <div class="card-body">
                    <h4 class="text-primary">Mở ca trống cho nhân viên</h4>

                    <p class="text-muted">
                        Tạo ca trống để Employee có thể đề nghị
                        chuyển từ ca hiện tại sang ca mới.
                    </p>

                    <form method="post"
                          action="${pageContext.request.contextPath}/store-manager/shift-requests"
                          class="row g-3">

                        <input type="hidden" name="action" value="createOpen">

                        <div class="col-md-4">
                            <label class="form-label">Ngày làm việc</label>
                            <input type="date" name="workDate"
                                   class="form-control" required>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Ca làm</label>

                            <select name="shiftId" class="form-select" required>
                                <option value="">-- Chọn ca làm --</option>

                                <c:forEach var="s" items="${shifts}">
                                    <option value="${s.id}">
                                        <c:out value="${s.name}"/>
                                        (<c:out value="${s.startTime}"/> -
                                        <c:out value="${s.endTime}"/>)
                                    </option>
                                </c:forEach>
                            </select>

                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Vị trí công việc</label>
                            <select name="positionId"
                                    class="form-select" required>
                                <option value="">-- Chọn vị trí --</option>
                                <c:forEach var="p" items="${positions}">
                                    <option value="${p.id}">
                                        <c:out value="${p.title}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-12">
                            <button type="submit" class="btn btn-primary">
                                Công bố ca trống
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Các ca trống đã công bố -->
            <div class="card shadow-sm">
                <div class="card-body">
                    <h4>Ca trống của chi nhánh</h4>

                    <table class="table table-striped">
                        <thead class="table-dark">
                            <tr>
                                <th>ID</th>
                                <th>Ngày</th>
                                <th>Ca làm</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${openShifts}">
                                <tr>
                                    <td>${s.id}</td>
                                    <td><c:out value="${s.workDate}"/></td>
                                    <td><c:out value="${s.shiftName}"/></td>
                                    <td><c:out value="${s.status}"/></td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty openShifts}">
                                <tr>
                                    <td colspan="4" class="text-center">
                                        Chưa có ca trống.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </body>
</html>
