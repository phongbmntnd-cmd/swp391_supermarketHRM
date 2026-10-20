
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Yêu cầu đổi ca</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet">

        <style>
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
                    <h4 class="text-primary">
                        Tạo đơn đổi ca với đồng nghiệp
                    </h4>

                    <div class="alert alert-info py-2">
                        Đơn đổi ca phải được gửi trước ít nhất
                        24 giờ.
                    </div>

                    <form method="post"
                          action="${pageContext.request.contextPath}/employee/request-shift">

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


                        <div class="mb-4">
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

                            <input type="hidden"
                                   id="targetScheduleId"
                                   name="targetScheduleId"
                                   required>
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
                return `${year}-${month}-${day}`;
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

                    swapForm.addEventListener("submit", e => {
                        if (!targetInput.value) {
                            e.preventDefault();
                            alert("Vui lòng chọn nhân viên muốn đổi ca.");
                        }
                    });

                    renderWeek();
        </script>
    </body>
</html>
