
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu cầu đổi ca</title>
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
            border-color: #16a34a;
            color: #16a34a;
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
<jsp:include page="/WEB-INF/views/fragments/employee-sidebar.jsp"/>

<div class="main-wrapper">
<div class="container py-4">

    <div class="page-header">
        <h2>Yêu cầu đổi ca làm việc</h2>
        <div class="page-actions">
            <a class="btn-soft"
               href="${pageContext.request.contextPath}/employee/forms">
                <i class="fa-solid fa-arrow-left"></i> Đơn từ &amp; Khiếu nại
            </a>
            <a class="btn-soft"
               href="${pageContext.request.contextPath}/employee/dashboard">
                <i class="fa-solid fa-house"></i> Dashboard
            </a>
        </div>
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

<script src="${pageContext.request.contextPath}/js/sidebar.js"></script>

</body>
</html>
