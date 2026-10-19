<%-- 
    Document   : schedule
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Shift" %>
<%@ page import="dao.ShiftScheduleDAO" %>

<html>
    <head>
        <meta charset="UTF-8">
        <title>Quản Lý Lịch Trực & Phân Công Ca - Store Manager</title>
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            body { font-family: 'Roboto', sans-serif; background-color: #f4f7f6; color: #333; }
            .top-navbar { background-color: #2c3e50; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
            .main-container { max-width: 1350px; margin: 40px auto; padding: 0 20px; }
            .card-custom { background: white; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); border: none; overflow: hidden; margin-bottom: 30px; }
            .card-header-custom { background: linear-gradient(135deg, #3498db, #2980b9); color: white; padding: 20px 30px; }
            .card-header-custom h2 { font-size: 20px; font-weight: 500; margin: 0; }
            .position-section-header { background-color: #e8f4fc; color: #2c3e50; padding: 12px 20px; font-weight: 700; font-size: 16px; border-left: 5px solid #3498db; margin-bottom: 15px; border-radius: 4px; }
            .btn-publish { background-color: #e67e22; border: none; padding: 10px 25px; font-weight: 500; color: white; border-radius: 6px; transition: background 0.2s; }
            .btn-publish:hover { background-color: #d35400; }
            .table > thead > tr > th { background-color: #f8f9fa; color: #2c3e50; font-weight: 600; text-transform: uppercase; font-size: 12px; padding: 12px 8px; }
            .table tbody td { padding: 10px; vertical-align: top; }
            .shift-info { font-weight: 600; color: #2c3e50; font-size: 14px; }
            .shift-time { font-size: 11px; color: #7f8c8d; display: block; margin-top: 2px; }
            .employee-tag { background: #ffffff; border: 1px solid #d1e7dd; border-radius: 6px; padding: 6px 8px; margin-bottom: 6px; font-size: 12px; text-align: left; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05); cursor: pointer; transition: all 0.2s; }
            .employee-tag:hover { background: #f8f9fa; }
            .employee-tag.assigned { background: #d1e7dd; border-color: #a3cfbb; color: #0f5132; }
            .employee-tag.assigned strong { color: #0f5132; }
        </style>
    </head>
    <body>

        <div class="top-navbar">
            <h1><i class="fa-solid fa-store me-2"></i> Quản Lý Phân Công Lịch Trực Theo Vị Trí</h1>
            <a href="dashboard" class="text-white text-decoration-none fw-medium"><i class="fa-solid fa-arrow-left me-1"></i> Quay lại Dashboard</a>
        </div>

        <div class="main-container">
            <c:if test="${param.success eq 'published'}">
                <div class="alert alert-success shadow-sm mb-4"><i class="fa-solid fa-circle-check me-2"></i> Đã công bố (Publish) lịch làm việc tuần này thành công! Nhân viên đã có thể xem lịch trên hệ thống.</div>
            </c:if>

            <div class="card card-custom">
                <div class="card-header-custom d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h2><i class="fa-solid fa-calendar-check me-2"></i> Bảng Phân Công Ca Làm Việc</h2>
                        <p class="mb-0 small mt-1"><i class="fa-solid fa-clock-rotate-left me-1"></i> Áp dụng từ: <strong>${startDate}</strong> đến <strong>${endDate}</strong></p>
                    </div>
                    
                    <div class="d-flex align-items-center gap-3">
                        <%-- Nút điều hướng Tuần trước / Tuần sau --%>
                        <div class="btn-group" role="group">
                            <a href="schedule?startDate=${prevWeekDate}" class="btn btn-outline-light btn-sm px-3">
                                <i class="fa-solid fa-chevron-left me-1"></i> Tuần trước
                            </a>
                            <a href="schedule?startDate=${nextWeekDate}" class="btn btn-outline-light btn-sm px-3">
                                Tuần sau <i class="fa-solid fa-chevron-right ms-1"></i>
                            </a>
                        </div>

                        <%-- Kiểm tra trạng thái đã Publish hay chưa để ẩn/hiện nút --%>
                        <c:choose>
                            <c:when test="${isPublished}">
                                <span class="badge bg-success p-2 px-3" style="font-size: 13px;">
                                    <i class="fa-solid fa-circle-check me-1"></i> Đã Publish Lịch
                                </span>
                            </c:when>
                            <c:otherwise>
                                <form action="schedule" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn công bố (Publish) toàn bộ lịch làm việc đã chọn cho nhân viên cơ sở không?');" class="mb-0">
                                    <input type="hidden" name="action" value="publish">
                                    <input type="hidden" name="branchId" value="${managerBranchId}">
                                    <input type="hidden" name="startDate" value="${startDateRaw}">
                                    <button type="submit" class="btn btn-publish">
                                        <i class="fa-solid fa-bullhorn me-2"></i> Publish Lịch Trực
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="p-4">
                    <p class="text-muted mb-4"><i class="fa-solid fa-circle-info me-1"></i> Bấm trực tiếp vào tên nhân viên để chọn hoặc hủy chọn phân công ca. Dữ liệu sẽ tự động lưu và chỉ hiển thị cho nhân viên khi bạn bấm <strong>Publish</strong>.</p>

                    <%-- Duyệt qua từng Vị trí công việc trong cửa hàng --%>
                    <c:forEach var="pos" items="${positions}">
                        <div class="position-section-header">
                            <i class="fa-solid fa-briefcase me-2"></i> Vị trí: ${pos.title}
                        </div>

                        <div class="table-responsive mb-5">
                            <table class="table table-bordered text-center align-middle">
                                <thead>
                                    <tr>
                                        <th style="width: 15%;">Ca Làm Việc</th>
                                        <c:forEach var="dName" items="${dayNames}">
                                            <th>${dName}</th>
                                        </c:forEach>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="shift" items="${shifts}">
                                        <tr>
                                            <td style="text-align: left; padding-left: 15px;">
                                                <span class="shift-info">
                                                    <c:choose>
                                                        <c:when test="${shift.name.toLowerCase().contains('sáng')}">
                                                            <i class="fa-solid fa-sun text-warning me-1"></i>
                                                        </c:when>
                                                        <c:when test="${shift.name.toLowerCase().contains('chiều')}">
                                                            <i class="fa-solid fa-cloud-sun text-info me-1"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fa-solid fa-moon text-primary me-1"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    ${shift.name}
                                                </span>
                                                <span class="shift-time">${shift.startTime} - ${shift.endTime}</span>
                                            </td>

                                            <%-- Duyệt các ngày trong tuần cho từng ca của vị trí này --%>
                                            <c:forEach var="day" items="${days}">
                                                <c:set var="workDate" value="${dayDateMap[day]}" />
                                                <c:set var="reqKey" value="${workDate}_${pos.id}_${shift.id}" />
                                                
                                                <%-- Lấy định mức từ DB hoặc gọi hàm gợi ý thông minh --%>
                                                <c:set var="reqData" value="${weeklyRequirements[reqKey]}" />
                                                <c:choose>
                                                    <c:when test="${not empty reqData}">
                                                        <c:set var="requiredCount" value="${reqData.requiredCount}" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <%
                                                            String wDate = (String) pageContext.getAttribute("workDate");
                                                            int pId = Integer.parseInt(String.valueOf(((Map)pageContext.getAttribute("pos")).get("id")));
                                                            int sId = ((Shift)pageContext.getAttribute("shift")).getId();
                                                            ShiftScheduleDAO tempDao = new ShiftScheduleDAO();
                                                            int smartCount = tempDao.getSmartDefaultRequirement(wDate, pId, sId);
                                                            pageContext.setAttribute("requiredCount", smartCount);
                                                        %>
                                                    </c:otherwise>
                                                </c:choose>
                                                
                                                <%-- Lấy số lượng thực tế đã được xếp --%>
                                                <c:set var="assignedCount" value="${weeklyAssignedCounts[reqKey]}" />
                                                <c:if test="${empty assignedCount}">
                                                    <c:set var="assignedCount" value="0" />
                                                </c:if>

                                                <%-- Xử lý màu sắc Badge: Đủ người = Xanh lá, Chưa đủ = Xám trung tính --%>
                                                <c:set var="badgeClass" value="bg-secondary" />
                                                <c:if test="${assignedCount ge requiredCount}">
                                                    <c:set var="badgeClass" value="bg-success" />
                                                </c:if>

                                                <td style="background-color: #fafbfc; min-width: 140px; vertical-align: top;">
                                                    <%-- Header hiển thị Đã xếp / Cần --%>
                                                    <div class="d-flex justify-content-between align-items-center mb-2 px-1 border-bottom pb-1">
                                                        <span class="badge ${badgeClass} fw-bold" style="font-size: 11px;" title="Đã xếp / Số lượng cần">
                                                            ${assignedCount} / ${requiredCount}
                                                        </span>
                                                        <button type="button" class="btn btn-sm btn-link p-0 text-muted" style="font-size: 11px;" 
                                                                onclick="openRequirementPrompt('${managerBranchId}', '${pos.id}', '${shift.id}', '${workDate}', '${requiredCount}')">
                                                            <i class="fa-solid fa-pen"></i>
                                                        </button>
                                                    </div>

                                                    <c:set var="hasEmployee" value="false" />

                                                    <%-- PHÂN TÁC CA: Nếu ca là ca Full-time thì chỉ hiển thị nhân viên Full-time --%>
                                                    <c:choose>
                                                        <c:when test="${shift.name.toLowerCase().contains('full-time') || shift.name.toLowerCase().contains('full time')}">
                                                            <c:forEach var="ft" items="${fullTimeEmployees}">
                                                                <c:if test="${ft.positionTitle eq pos.title}">
                                                                    <c:set var="currentKey" value="${ft.userId}_${shift.id}_${workDate}" />
                                                                    <c:set var="isAssigned" value="false" />
                                                                    <c:forEach var="asg" items="${assignedList}">
                                                                        <c:if test="${asg eq currentKey}">
                                                                            <c:set var="isAssigned" value="true" />
                                                                        </c:if>
                                                                    </c:forEach>

                                                                    <div class="employee-tag ${isAssigned ? 'assigned' : ''}" 
                                                                         onclick="toggleAssignment(this, '${ft.userId}', '${shift.id}', '${managerBranchId}', '${workDate}')">
                                                                        <div>
                                                                            <strong>${ft.fullName}</strong> <span class="badge bg-info text-dark" style="font-size: 9px;">FT</span>
                                                                        </div>
                                                                        <div>
                                                                            <i class="fa-solid ${isAssigned ? 'fa-check-circle text-success' : 'fa-circle text-muted'} check-icon"></i>
                                                                        </div>
                                                                    </div>
                                                                    <c:set var="hasEmployee" value="true" />
                                                                </c:if>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <%-- Nếu là ca thường (Part-time / Casual), chỉ hiển thị nhân viên đã đăng ký lịch rảnh --%>
                                                            <c:forEach var="reg" items="${branchRegistrations}">
                                                                <c:if test="${reg.positionTitle eq pos.title and reg.shiftName eq shift.name and reg.dayOfWeek eq day}">
                                                                    <c:set var="currentKey" value="${reg.userId}_${shift.id}_${workDate}" />
                                                                    <c:set var="isAssigned" value="false" />
                                                                    <c:forEach var="asg" items="${assignedList}">
                                                                        <c:if test="${asg eq currentKey}">
                                                                            <c:set var="isAssigned" value="true" />
                                                                        </c:if>
                                                                    </c:forEach>

                                                                    <div class="employee-tag ${isAssigned ? 'assigned' : ''}" 
                                                                         onclick="toggleAssignment(this, '${reg.userId}', '${shift.id}', '${managerBranchId}', '${workDate}')">
                                                                        <div>
                                                                            <strong>${reg.fullName}</strong> <span class="badge bg-light text-dark" style="font-size: 9px;">PT</span>
                                                                        </div>
                                                                        <div>
                                                                            <i class="fa-solid ${isAssigned ? 'fa-check-circle text-success' : 'fa-circle text-muted'} check-icon"></i>
                                                                        </div>
                                                                    </div>
                                                                    <c:set var="hasEmployee" value="true" />
                                                                </c:if>
                                                            </c:forEach>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    
                                                    <c:if test="${!hasEmployee}">
                                                        <div class="text-muted small fst-italic py-2">Không có nhân sự</div>
                                                    </c:if>
                                                </td>
                                            </c:forEach>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:forEach>

                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            function toggleAssignment(element, userId, shiftId, branchId, workDate) {
                const formData = new URLSearchParams();
                formData.append('action', 'assign');
                formData.append('userId', userId);
                formData.append('shiftId', shiftId);
                formData.append('branchId', branchId);
                formData.append('workDate', workDate);

                fetch('schedule', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                })
                .then(response => {
                    if (response.ok) return response.text();
                    throw new Error('Lỗi kết nối server.');
                })
                .then(result => {
                    const icon = element.querySelector('.check-icon');
                    if (result.trim() === 'added') {
                        element.classList.add('assigned');
                        icon.className = 'fa-solid fa-check-circle text-success check-icon';
                    } else if (result.trim() === 'removed') {
                        element.classList.remove('assigned');
                        icon.className = 'fa-solid fa-circle text-muted check-icon';
                    }
                    setTimeout(() => location.reload(), 300);
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Có lỗi xảy ra khi lưu phân công.');
                });
            }

            function openRequirementPrompt(branchId, positionId, shiftId, workDate, currentCount) {
                let newCount = prompt("Nhập số lượng nhân sự yêu cầu cho ca này:", currentCount);
                if (newCount !== null && newCount.trim() !== "") {
                    let parsedCount = parseInt(newCount);
                    if (isNaN(parsedCount) || parsedCount < 1) {
                        alert("Số lượng yêu cầu phải là số nguyên lớn hơn hoặc bằng 1!");
                        return;
                    }

                    const formData = new URLSearchParams();
                    formData.append('action', 'updateRequirement');
                    formData.append('branchId', branchId);
                    formData.append('positionId', positionId);
                    formData.append('shiftId', shiftId);
                    formData.append('workDate', workDate);
                    formData.append('requiredCount', parsedCount);

                    fetch('schedule', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: formData.toString()
                    })
                    .then(response => {
                        if (response.ok) return response.text();
                        throw new Error('Lỗi cập nhật định mức.');
                    })
                    .then(result => {
                        if (result.trim() === 'success') {
                            location.reload();
                        } else {
                            alert('Không thể cập nhật định mức.');
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('Có lỗi xảy ra khi kết nối server.');
                    });
                }
            }
        </script>
    </body>
</html>