<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

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

        .shift-grid {
            min-width: 850px;
            table-layout: fixed;
        }

        .shift-grid th,
        .shift-grid td {
            text-align: center;
            vertical-align: middle;
            padding: 8px;
        }

        .shift-grid th {
            background: #f3f6f9;
            font-weight: 600;
        }

        .shift-label {
            width: 170px;
            text-align: left !important;
        }

        .shift-slot {
            width: 100%;
            min-height: 75px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            background: #f5f6f8;
            cursor: pointer;
            color: #475569;
        }

        .shift-slot:hover:not(:disabled) {
            background: #dbeafe;
            border-color: #3b82f6;
        }

        .shift-slot.selected {
            background: #dcfce7;
            border: 2px solid #16a34a;
        }

        .shift-slot:disabled {
            opacity: .5;
            cursor: not-allowed;
        }

        .employee-option {
            display: block;
            padding: 12px;
            margin-top: 8px;
            border: 1px solid #ddd;
            border-radius: 8px;
            cursor: pointer;
        }

        .employee-option.selected {
            background: #ecfdf5;
            border-color: #16a34a;
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

    <c:if test="${param.responded eq '1'}">
        <div class="alert alert-success">
            Đã phản hồi yêu cầu đổi ca.
        </div>
    </c:if>

    <c:if test="${param.cancelled eq '1'}">
        <div class="alert alert-success">
            Đã hủy đơn.
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

    <%-- ============ ĐƠN ĐẾN TỪ ĐỒNG NGHIỆP ============ --%>
    <c:if test="${not empty incomingRequests}">
        <div class="alert alert-warning d-flex align-items-center
                    justify-content-between flex-wrap gap-2">
            <div>
                <i class="fa-solid fa-bell fa-lg me-2"></i>
                <strong>
                    Bạn có ${fn:length(incomingRequests)} yêu cầu đổi ca
                    đang chờ bạn phản hồi.
                </strong>
                <span class="d-block small ms-4 mt-1">
                    Bấm "Đồng ý" để đồng ý đổi ca (đơn sẽ chuyển lên
                    Store Manager duyệt), hoặc "Từ chối" nếu không đồng ý.
                </span>
            </div>
            <a href="#incomingRequests"
               class="btn btn-warning btn-sm">
                <i class="fa-solid fa-arrow-down"></i>
                Xem &amp; phản hồi
            </a>
        </div>

        <div class="card mb-4 shadow-sm border-warning"
             id="incomingRequests">
            <div class="card-body">
                <h4 class="text-warning">
                    <i class="fa-solid fa-bell"></i>
                    Yêu cầu đổi ca từ đồng nghiệp
                    <span class="badge bg-warning">
                        ${fn:length(incomingRequests)}
                    </span>
                </h4>

                <p class="text-muted" style="font-size: 13px;">
                    Đồng nghiệp muốn đổi ca với bạn.
                    Nếu đồng ý, đơn sẽ được chuyển lên
                    Store Manager duyệt.
                </p>

                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>Người gửi</th>
                                <th>Ca của họ</th>
                                <th>Ca của bạn</th>
                                <th>Lý do</th>
                                <th>Trả lời</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${incomingRequests}">
                                <tr>
                                    <td>
                                        <strong>
                                            <c:out value="${r.requesterName}"/>
                                        </strong>
                                    </td>
                                    <td>
                                        <c:out value="${r.requesterDate}"/>
                                        -
                                        <c:out value="${r.requesterShift}"/>
                                    </td>
                                    <td>
                                        <c:out value="${r.myDate}"/>
                                        -
                                        <c:out value="${r.myShift}"/>
                                    </td>
                                    <td>
                                        <c:out value="${r.reason}"/>
                                    </td>
                                    <td>
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/employee/request-shift">
                                            <input type="hidden"
                                                   name="action"
                                                   value="respond">
                                            <input type="hidden"
                                                   name="requestId"
                                                   value="${r.id}">

                                            <input type="text"
                                                   name="message"
                                                   maxlength="255"
                                                   class="form-control form-control-sm mb-2"
                                                   placeholder="Lời nhắn (không bắt buộc)">

                                            <button name="decision"
                                                    value="accept"
                                                    type="submit"
                                                    class="btn btn-success btn-sm me-1">
                                                <i class="fa-solid fa-check"></i>
                                                Đồng ý
                                            </button>

                                            <button name="decision"
                                                    value="decline"
                                                    type="submit"
                                                    class="btn btn-outline-danger btn-sm">
                                                <i class="fa-solid fa-xmark"></i>
                                                Từ chối
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </c:if>

    <div class="card mb-4 shadow-sm">
        <div class="card-body">
            <h4 class="text-primary">
                Tạo đơn đổi ca
            </h4>

            <div class="alert alert-info py-2">
                <i class="fa-solid fa-circle-info"></i>
                Đơn đổi ca phải được gửi trước ít nhất
                <strong>48 giờ</strong> (2 ngày) kể từ ngày làm việc.
                Thời gian chờ đồng nghiệp trả lời cũng được tính
                trong thời hạn này.
            </div>

            <ul class="nav nav-tabs mb-3" id="requestTypeTabs">
                <li class="nav-item">
                    <button class="nav-link active"
                            type="button"
                            data-mode="swap"
                            id="tabSwap">
                        <i class="fa-solid fa-people-arrows"></i>
                        Đổi với đồng nghiệp
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link"
                            type="button"
                            data-mode="open"
                            id="tabOpen">
                        <i class="fa-solid fa-inbox"></i>
                        Chuyển sang ca trống
                    </button>
                </li>
            </ul>

            <form method="post" id="shiftForm"
                  action="${pageContext.request.contextPath}/employee/request-shift">

                <input type="hidden" name="action" id="formAction"
                       value="create">

                <div class="mb-3">
                    <label class="form-label">
                        Ca làm hiện tại của bạn
                    </label>
                    <select name="myScheduleId"
                            id="myScheduleId"
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

                <%-- ============ CHẾ ĐỘ 1: ĐỔI VỚI ĐỒNG NGHIỆP ============ --%>
                <div class="mb-4" id="swapMode">
                    <div class="d-flex justify-content-between
                         align-items-center mb-3">

                        <div>
                            <h5 class="fw-bold mb-1">
                                Bảng phân công ca làm việc
                            </h5>
                            <small class="text-muted" id="weekLabel"></small>
                        </div>

                        <div class="btn-group">
                            <button type="button"
                                    id="prevWeek"
                                    class="btn btn-outline-primary btn-sm">
                                Tuần trước
                            </button>

                            <button type="button"
                                    id="nextWeek"
                                    class="btn btn-outline-primary btn-sm">
                                Tuần sau
                            </button>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-bordered shift-grid">
                            <thead id="shiftWeekHead"></thead>
                            <tbody id="shiftWeekBody"></tbody>
                        </table>
                    </div>

                    <div id="selectedShiftInfo"
                         class="alert alert-secondary mt-3">
                        Nhấn vào một ô ca để xem các nhân viên đang làm.
                    </div>

                    <div id="employeePanel" class="card mt-3 d-none">
                        <div class="card-body">
                            <h5>Chọn nhân viên muốn đổi ca</h5>
                            <div id="employeeList"></div>
                        </div>
                    </div>
                </div>

                <input type="hidden"
                       id="targetScheduleId"
                       name="targetScheduleId">

                <%-- ============ CHẾ ĐỘ 2: CHUYỂN SANG CA TRỐNG ============ --%>
                <div class="mb-4 d-none" id="openMode">
                    <h5 class="fw-bold mb-2">
                        Chọn ca trống tại cơ sở
                    </h5>

                    <p class="text-muted" style="font-size: 13px;">
                        Ca trống là ca đang thiếu người làm
                        (do đồng nghiệp nghỉ phép, nghỉ tang, ốm...).
                        Khi Store Manager duyệt, ca của bạn sẽ được
                        chuyển sang ca trống này và ca cũ sẽ được
                        mở lại cho người khác nhận.
                    </p>

                    <c:choose>
                        <c:when test="${empty openShifts}">
                            <div class="alert alert-light border text-muted">
                                Hiện chưa có ca trống nào tại cơ sở
                                của bạn.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-bordered table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Ngày</th>
                                            <th>Ca</th>
                                            <th>Khung giờ</th>
                                            <th>Cơ sở</th>
                                            <th>Chọn</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="os" items="${openShifts}">
                                            <tr>
                                                <td>
                                                    <c:out value="${os.workDate}"/>
                                                </td>
                                                <td>
                                                    <c:out value="${os.shiftName}"/>
                                                </td>
                                                <td>
                                                    <c:out value="${os.startTime}"/>
                                                    -
                                                    <c:out value="${os.endTime}"/>
                                                </td>
                                                <td>
                                                    <c:out value="${os.branchName}"/>
                                                </td>
                                                <td>
                                                    <input type="radio"
                                                           class="form-check-input"
                                                           name="openShiftId"
                                                           value="${os.id}">
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
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
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${myRequests}">
                            <tr>
                                <td>${r.id}</td>
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
                                </td>
                                <td>
                                    <c:if test="${not empty r.response}">
                                        <c:out value="${r.response}"/>
                                    </c:if>
                                    <c:if test="${not empty r.colleagueResponse}">
                                        <div class="small text-muted">
                                            <i class="fa-solid fa-comment"></i>
                                            <c:out value="${r.colleagueResponse}"/>
                                        </div>
                                    </c:if>
                                </td>
                                <td>
                                    <c:if test="${r.status eq 'WAITING_COLLEAGUE'
                                                  or r.status eq 'PENDING'}">
                                        <form method="post"
                                              action="${pageContext.request.contextPath}/employee/request-shift"
                                              style="display:inline">
                                            <input type="hidden"
                                                   name="action"
                                                   value="cancel">
                                            <input type="hidden"
                                                   name="requestId"
                                                   value="${r.id}">
                                            <button type="submit"
                                                    class="btn btn-outline-danger btn-sm"
                                                    onclick="return confirm('Hủy đơn đổi ca này?');">
                                                Hủy đơn
                                            </button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty myRequests}">
                            <tr>
                                <td colspan="9" class="text-center">
                                    Chưa có đơn nào.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="shiftData" hidden>
        <c:forEach var="s" items="${allShifts}">
            <div class="shift-row"
                 data-id="${s.id}"
                 data-start="${s.startTime}"
                 data-end="${s.endTime}">
                <span><c:out value="${s.name}"/></span>
            </div>
        </c:forEach>
    </div>

    <div id="colleagueData" hidden>
        <c:forEach var="s" items="${colleagueSchedules}">
            <div class="colleague-row"
                 data-schedule="${s.id}"
                 data-shift="${s.shiftId}"
                 data-date="${s.workDate}">
                <span><c:out value="${s.colleagueName}"/></span>
            </div>
        </c:forEach>
    </div>

</div>
</div>

<script>
    const shifts = Array.from(
            document.querySelectorAll(".shift-row")
            ).map(el => ({
            id: Number(el.dataset.id),
            name: el.querySelector("span").textContent.trim(),
            start: el.dataset.start,
            end: el.dataset.end
        }));

    const colleagues = Array.from(
            document.querySelectorAll(".colleague-row")
            ).map(el => ({
            scheduleId: Number(el.dataset.schedule),
            shiftId: Number(el.dataset.shift),
            date: el.dataset.date,
            name: el.querySelector("span").textContent.trim()
        }));

    const targetInput = document.getElementById("targetScheduleId");
    const panel = document.getElementById("employeePanel");
    const employeeList = document.getElementById("employeeList");
    const selectedInfo = document.getElementById("selectedShiftInfo");

    function formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");
        // Lưu ý: KHÔNG dùng template literal trong file JSP này.
        // Biểu thức "{...}" trong JS sẽ bị JSP EL đọc nhầm là biến
        // server-side (không tồn tại) và thay bằng chuỗi rỗng,
        // khiến hàm trả về "--" và mọi ô ca bị disable.
        // Nối chuỗi thuần để tránh bị JSP đọc nhầm.
        return year + "-" + month + "-" + day;
    }

    function getMonday(date) {
        const d = new Date(date);
        const day = (d.getDay() + 6) % 7;
        d.setDate(d.getDate() - day);
        d.setHours(0, 0, 0, 0);
        return d;
    }

    let weekStart = getMonday(new Date());

    function resetSelection() {
        targetInput.value = "";
        panel.classList.add("d-none");
        employeeList.replaceChildren();
        selectedInfo.textContent =
                "Nhấn vào một ô ca để xem các nhân viên đang làm.";
    }

    function renderWeek() {
        const head = document.getElementById("shiftWeekHead");
        const body = document.getElementById("shiftWeekBody");

        head.replaceChildren();
        body.replaceChildren();

        const headerRow = document.createElement("tr");
        const firstHeader = document.createElement("th");
        firstHeader.textContent = "Ca làm việc";
        headerRow.appendChild(firstHeader);

        const dates = [];
        const labels = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];

        for (let i = 0; i < 7; i++) {
            const d = new Date(weekStart);
            d.setDate(weekStart.getDate() + i);

            const key = formatDate(d);
            dates.push(key);

            const th = document.createElement("th");
            th.textContent =
                    labels[i] + " " + d.getDate() + "/" + (d.getMonth() + 1);

            headerRow.appendChild(th);
        }

        head.appendChild(headerRow);

        document.getElementById("weekLabel").textContent =
                dates[0] + " đến " + dates[6];

        shifts.forEach(shift => {
            const tr = document.createElement("tr");

            const label = document.createElement("td");
            label.className = "shift-label";

            const title = document.createElement("strong");
            title.textContent = shift.name;

            const time = document.createElement("div");
            time.className = "small text-muted";
            time.textContent = shift.start + " - " + shift.end;

            label.append(title, time);
            tr.appendChild(label);

            dates.forEach(date => {
                const td = document.createElement("td");

                const people = colleagues.filter(p =>
                    p.shiftId === shift.id && p.date === date
                );

                const button = document.createElement("button");
                button.type = "button";
                button.className = "shift-slot";

                // Chỉ ca có người mới được chọn
                button.disabled = people.length === 0;
                button.textContent =
                        people.length ? "👥 Chọn ca" : "Không có nhân viên";

                if (people.length > 0) {
                    button.addEventListener("click", () => {
                        document.querySelectorAll(".shift-slot")
                                .forEach(b => b.classList.remove("selected"));

                        button.classList.add("selected");
                        showEmployees(shift, date, people);
                    });
                }

                td.appendChild(button);
                tr.appendChild(td);
            });

            body.appendChild(tr);
        });
    }

    function showEmployees(shift, date, people) {
        resetSelection();
        panel.classList.remove("d-none");

        selectedInfo.textContent =
                "Đã chọn " + shift.name + " - " + date
                + " (" + shift.start + " - " + shift.end + ")";

        people.forEach(p => {
            const label = document.createElement("label");
            label.className = "employee-option";

            const radio = document.createElement("input");
            radio.type = "radio";
            radio.name = "selectedEmployee";
            radio.value = String(p.scheduleId);
            radio.className = "form-check-input me-2";

            radio.addEventListener("change", () => {
                targetInput.value = String(p.scheduleId);

                document.querySelectorAll(".employee-option")
                        .forEach(el => el.classList.remove("selected"));

                label.classList.add("selected");
            });

            const name = document.createElement("span");
            name.textContent = p.name;

            label.append(radio, name);
            employeeList.appendChild(label);
        });
    }

    document.getElementById("prevWeek")
            .addEventListener("click", () => {
                weekStart.setDate(weekStart.getDate() - 7);
                resetSelection();
                renderWeek();
            });

    document.getElementById("nextWeek")
            .addEventListener("click", () => {
                weekStart.setDate(weekStart.getDate() + 7);
                resetSelection();
                renderWeek();
            });

    const swapForm = targetInput.closest("form");

    // ---- Chuyển tab: đổi với đồng nghiệp / chuyển sang ca trống ----
    const formAction = document.getElementById("formAction");
    const swapMode = document.getElementById("swapMode");
    const openMode = document.getElementById("openMode");
    const tabSwap = document.getElementById("tabSwap");
    const tabOpen = document.getElementById("tabOpen");
    let currentMode = "swap";

    function setMode(mode) {
        currentMode = mode;

        if (mode === "open") {
            formAction.value = "createOpen";
            swapMode.classList.add("d-none");
            openMode.classList.remove("d-none");
            tabSwap.classList.remove("active");
            tabOpen.classList.add("active");

            // Bỏ chọn ca đồng nghiệp khi chuyển sang ca trống
            resetSelection();
        } else {
            formAction.value = "create";
            openMode.classList.add("d-none");
            swapMode.classList.remove("d-none");
            tabOpen.classList.remove("active");
            tabSwap.classList.add("active");

            // Bỏ chọn ca trống khi chuyển sang đổi với đồng nghiệp
            document.querySelectorAll(
                    'input[name="openShiftId"]')
                    .forEach(r => r.checked = false);
        }
    }

    tabSwap.addEventListener("click", () => setMode("swap"));
    tabOpen.addEventListener("click", () => setMode("open"));

    swapForm.addEventListener("submit", e => {
        if (currentMode === "swap") {
            if (!targetInput.value) {
                e.preventDefault();
                alert("Vui lòng chọn nhân viên muốn đổi ca.");
            }
        } else {
            const openSelected = document.querySelector(
                    'input[name="openShiftId"]:checked');

            if (!openSelected) {
                e.preventDefault();
                alert("Vui lòng chọn một ca trống để chuyển sang.");
            }
        }
    });

    renderWeek();
</script>

<script src="${pageContext.request.contextPath}/js/sidebar.js"></script>

</body>
</html>
