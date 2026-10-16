
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Yêu cầu đổi ca</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
</head>

<body class="bg-light">
<div class="container py-4">

    <div class="d-flex justify-content-between mb-4">
        <h2>Yêu cầu đổi ca làm việc</h2>
        <a class="btn btn-secondary"
           href="${pageContext.request.contextPath}/employee/dashboard">
            Về Dashboard
        </a>
    </div>

    <c:if test="${param.success eq '1'}">
        <div class="alert alert-success">
            Gửi đơn thành công. Đang chờ Store Manager duyệt.
        </div>
    </c:if>

    <c:if test="${param.invalid eq '1'}">
        <div class="alert alert-warning">
            Không thể gửi đơn. Vui lòng kiểm tra ca đã chọn.
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <c:out value="${error}"/>
        </div>
    </c:if>

    <div class="card mb-4 shadow-sm">
        <div class="card-body">
            <h4 class="text-primary">Tạo đơn đổi ca</h4>

            <form method="post"
                  action="${pageContext.request.contextPath}/employee/request-shift">

                <div class="mb-3">
                    <label class="form-label">Hình thức đổi ca</label>
                    <select id="requestType"
                            name="requestType"
                            class="form-select"
                            onchange="changeType()"
                            required>
                        <option value="SWAP">Đổi với đồng nghiệp</option>
                        <option value="OPEN">Chuyển sang ca trống</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        Ca làm hiện tại của bạn
                    </label>
                    <select name="myScheduleId"
                            class="form-select" required>
                        <option value="">-- Chọn ca hiện tại --</option>
                        <c:forEach var="s" items="${mySchedules}">
                            <option value="${s.id}">
                                <c:out value="${s.workDate}"/>
                                -
                                <c:out value="${s.shiftName}"/>
                                (<c:out value="${s.startTime}"/>
                                -
                                <c:out value="${s.endTime}"/>)
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div id="swapSection" class="mb-3">
                    <label class="form-label">
                        Ca của đồng nghiệp muốn đổi
                    </label>
                    <select id="targetScheduleId"
                            name="targetScheduleId"
                            class="form-select" required>
                        <option value="">-- Chọn ca đồng nghiệp --</option>
                        <c:forEach var="s" items="${colleagueSchedules}">
                            <option value="${s.id}">
                                <c:out value="${s.colleagueName}"/>
                                -
                                <c:out value="${s.workDate}"/>
                                -
                                <c:out value="${s.shiftName}"/>
                                (<c:out value="${s.startTime}"/>
                                -
                                <c:out value="${s.endTime}"/>)
                            </option>
                        </c:forEach>
                    </select>

                    <div class="form-check mt-2">
                        <input class="form-check-input"
                               type="checkbox"
                               id="agreed" required>
                        <label class="form-check-label" for="agreed">
                            Tôi xác nhận đã trao đổi và được đồng nghiệp đồng ý.
                        </label>
                    </div>
                </div>

                <div id="openSection"
                     class="mb-3" style="display:none">
                    <label class="form-label">
                        Ca trống muốn chuyển sang
                    </label>
                    <select id="openShiftId"
                            name="openShiftId"
                            class="form-select" disabled>
                        <option value="">-- Chọn ca trống --</option>
                        <c:forEach var="s" items="${openShifts}">
                            <option value="${s.id}">
                                <c:out value="${s.workDate}"/>
                                -
                                <c:out value="${s.shiftName}"/>
                                (<c:out value="${s.startTime}"/>
                                -
                                <c:out value="${s.endTime}"/>)
                                -
                                <c:out value="${s.branchName}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label">Lý do đổi ca</label>
                    <textarea name="reason" rows="3"
                              maxlength="255"
                              class="form-control" required></textarea>
                </div>

                <button type="submit" class="btn btn-success">
                    Gửi yêu cầu
                </button>
            </form>
        </div>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <h4>Lịch sử yêu cầu</h4>

            <div class="table-responsive">
                <table class="table table-bordered">
                    <thead class="table-dark">
                        <tr>
                            <th>ID</th>
                            <th>Loại</th>
                            <th>Ca hiện tại</th>
                            <th>Ca muốn đổi</th>
                            <th>Đồng nghiệp</th>
                            <th>Lý do</th>
                            <th>Trạng thái</th>
                            <th>Phản hồi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${myRequests}">
                            <tr>
                                <td>${r.id}</td>
                                <td><c:out value="${r.requestType}"/></td>
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
                                <td><c:out value="${r.status}"/></td>
                                <td><c:out value="${r.response}"/></td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty myRequests}">
                            <tr>
                                <td colspan="8" class="text-center">
                                    Chưa có đơn nào.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>

<script>
function changeType() {
    const isSwap =
        document.getElementById("requestType").value === "SWAP";

    const swap = document.getElementById("swapSection");
    const open = document.getElementById("openSection");
    const target = document.getElementById("targetScheduleId");
    const openId = document.getElementById("openShiftId");
    const agreed = document.getElementById("agreed");

    swap.style.display = isSwap ? "block" : "none";
    open.style.display = isSwap ? "none" : "block";

    target.disabled = !isSwap;
    target.required = isSwap;

    openId.disabled = isSwap;
    openId.required = !isSwap;

    agreed.required = isSwap;
}
changeType();
</script>

</body>
</html>
