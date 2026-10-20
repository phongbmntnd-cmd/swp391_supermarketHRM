<%-- 
    Document    : schedule
    Author      : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
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
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f4f7f6;
                color: #333;
            }
            .top-navbar {
                background-color: #2c3e50;
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            }
            .main-container {
                max-width: 1350px;
                margin: 40px auto;
                padding: 0 20px;
            }
            .card-custom {
                background: white;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.05);
                border: none;
                overflow: hidden;
                margin-bottom: 30px;
            }
            .card-header-custom {
                background: linear-gradient(135deg, #3498db, #2980b9);
                color: white;
                padding: 20px 30px;
            }
            .card-header-custom h2 {
                font-size: 20px;
                font-weight: 500;
                margin: 0;
            }
            .position-section-header {
                background-color: #e8f4fc;
                color: #2c3e50;
                padding: 12px 20px;
                font-weight: 700;
                font-size: 16px;
                border-left: 5px solid #3498db;
                margin-bottom: 15px;
                border-radius: 4px;
            }
            .btn-publish {
                background-color: #e67e22;
                border: none;
                padding: 10px 25px;
                font-weight: 500;
                color: white;
                border-radius: 6px;
                transition: background 0.2s;
            }
            .btn-publish:hover {
                background-color: #d35400;
            }
            .table > thead > tr > th {
                background-color: #f8f9fa;
                color: #2c3e50;
                font-weight: 600;
                text-transform: uppercase;
                font-size: 12px;
                padding: 12px 8px;
            }
            .table tbody td {
                padding: 10px;
                vertical-align: top;
            }
            .shift-info {
                font-weight: 600;
                color: #2c3e50;
                font-size: 14px;
            }
            .shift-time {
                font-size: 11px;
                color: #7f8c8d;
                display: block;
                margin-top: 2px;
            }
            .employee-tag {
                background: #ffffff;
                border: 1px solid #d1e7dd;
                border-radius: 6px;
                padding: 6px 8px;
                margin-bottom: 6px;
                font-size: 12px;
                text-align: left;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 1px 3px rgba(0,0,0,0.05);
                cursor: pointer;
                transition: all 0.2s;
            }
            .employee-tag:hover {
                background: #f8f9fa;
            }
            .employee-tag.assigned {
                background: #d1e7dd;
                border-color: #a3cfbb;
                color: #0f5132;
            }
            .employee-tag.assigned strong {
                color: #0f5132;
            }

            /* CSS khóa tương tác khi đã Published */
            .published-locked .employee-tag {
                cursor: not-allowed;
                opacity: 0.85;
            }
            .published-locked .employee-tag:hover {
                background: #ffffff;
            }

            /* Cảnh báo thiếu nhân sự */
            .staff-shortage-trigger {
                border: 0;
                border-radius: 6px;
                padding: 2px 7px;
                font-size: 11px;
                font-weight: 700;
                color: #fff;
                cursor: pointer;
                line-height: 1.6;
            }
            .staff-shortage-trigger.warning-yellow {
                background: #f0ad00;
                color: #212529;
            }
            .staff-shortage-trigger.warning-red {
                background: #dc3545;
            }
            .staff-shortage-trigger.warning-green {
                background: #198754;
                cursor: default;
            }
            .staff-shortage-trigger:hover:not(:disabled) {
                filter: brightness(.94);
            }
            .staff-shortage-trigger:disabled {
                opacity: .85;
                cursor: not-allowed;
            }
            .shortage-message {
                font-size: 12px;
                line-height: 1.35;
                margin-top: 8px;
            }
            .shortage-message.yellow {
                color: #997000;
            }
            .shortage-message.red {
                color: #b02a37;
            }
            .modal .form-label {
                font-weight: 600;
            }
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
            <c:if test="${param.success eq 'supplementary_opened'}">
                <div class="alert alert-success shadow-sm mb-4"><i class="fa-solid fa-circle-check me-2"></i> Đã mở đăng ký bổ sung. Nhân viên phù hợp có thể đăng ký tại trang lịch rảnh.</div>
            </c:if>
            <c:if test="${param.error eq 'supplementary_open_failed'}">
                <div class="alert alert-danger shadow-sm mb-4"><i class="fa-solid fa-triangle-exclamation me-2"></i> Không thể mở đăng ký. Hãy kiểm tra ca còn thiếu nhân sự, chưa publish và hạn đăng ký hợp lệ.</div>
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
                            <table class="table table-bordered text-center align-middle ${isPublished ? 'published-locked' : ''}">
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

                                                <%-- Trạng thái nhân sự: 0 người = đỏ; thiếu một phần = vàng; đủ người = xanh --%>
                                                <c:set var="shortageClass" value="warning-red" />
                                                <c:set var="shortageMessage" value="Chưa có nhân sự. Bấm để tạo đề xuất điều chuyển." />
                                                <c:if test="${assignedCount gt 0 and assignedCount lt requiredCount}">
                                                    <c:set var="shortageClass" value="warning-yellow" />
                                                    <c:set var="shortageMessage" value="Chưa đủ nhân sự. Bấm để mở đăng ký bổ sung." />
                                                </c:if>
                                                <c:if test="${assignedCount ge requiredCount}">
                                                    <c:set var="shortageClass" value="warning-green" />
                                                    <c:set var="shortageMessage" value="Đã đủ số lượng nhân sự." />
                                                </c:if>

                                                <td style="background-color: #fafbfc; min-width: 140px; vertical-align: top;">
                                                    <%-- Header hiển thị Đã xếp / Cần --%>
                                                    <div class="d-flex justify-content-between align-items-center mb-2 px-1 border-bottom pb-1">
                                                        <button type="button"
                                                                class="staff-shortage-trigger ${shortageClass}"
                                                                title="${shortageMessage}"
                                                                aria-label="Trạng thái nhân sự ${assignedCount} trên ${requiredCount}"
                                                                <c:if test="${isPublished or assignedCount ge requiredCount}">disabled</c:if>
                                                                onclick="openShortageModal('${managerBranchId}', '${pos.id}', '${shift.id}', '${workDate}', '${requiredCount}', '${assignedCount}', '${pos.title}', '${shift.name}')">
                                                            ${assignedCount} / ${requiredCount}
                                                        </button>
                                                        <c:if test="${!isPublished}">
                                                            <button type="button" class="btn btn-sm btn-link p-0 text-muted" style="font-size: 11px;" 
                                                                    onclick="openRequirementPrompt('${managerBranchId}', '${pos.id}', '${shift.id}', '${workDate}', '${requiredCount}')">
                                                                <i class="fa-solid fa-pen"></i>
                                                            </button>
                                                        </c:if>
                                                    </div>

                                                    <c:set var="hasEmployee" value="false" />

                                                    <%-- PHÂN TÁC CA: Nếu ca là ca Full-time thì chỉ hiển thị nhân viên Full-time (đã lọc theo shiftType cố định) --%>
                                                    <c:choose>
                                                        <c:when test="${shift.name.toLowerCase().contains('full-time') || shift.name.toLowerCase().contains('full time')}">
                                                            <c:forEach var="ft" items="${fullTimeEmployees}">
                                                                <c:if test="${ft.positionTitle eq pos.title}">
                                                                    <%-- Lọc ràng buộc cố định ca --%>
                                                                    <c:set var="ftShiftType" value="${not empty ft.shiftType ? fn:toUpperCase(ft.shiftType) : ''}" />
                                                                    <c:set var="showFt" value="true" />
                                                                    <c:set var="shiftNameLower" value="${fn:toLowerCase(shift.name)}" />

                                                                    <c:if test="${ftShiftType eq 'FT_FIXED_MORNING' and not fn:contains(shiftNameLower, 'sáng')}">
                                                                        <c:set var="showFt" value="false" />
                                                                    </c:if>
                                                                    <c:if test="${ftShiftType eq 'FT_FIXED_AFTERNOON' and not fn:contains(shiftNameLower, 'chiều')}">
                                                                        <c:set var="showFt" value="false" />
                                                                    </c:if>
                                                                    <c:if test="${ftShiftType eq 'FT_FIXED_EVENING' and not fn:contains(shiftNameLower, 'tối')}">
                                                                        <c:set var="showFt" value="false" />
                                                                    </c:if>

                                                                    <c:if test="${showFt}">
                                                                        <c:set var="currentKey" value="${ft.userId}_${shift.id}_${workDate}" />
                                                                        <c:set var="isAssigned" value="false" />
                                                                        <c:forEach var="asg" items="${assignedList}">
                                                                            <c:if test="${asg eq currentKey}">
                                                                                <c:set var="isAssigned" value="true" />
                                                                            </c:if>
                                                                        </c:forEach>

                                                                        <div class="employee-tag ${isAssigned ? 'assigned' : ''}" 
                                                                             onclick="toggleAssignment(this, '${ft.userId}', '${shift.id}', '${managerBranchId}', '${workDate}', '${pos.id}')">
                                                                            <div>
                                                                                <strong>${ft.fullName}</strong> <span class="badge bg-info text-dark" style="font-size: 9px;">FT</span>
                                                                            </div>
                                                                            <div>
                                                                                <i class="fa-solid ${isAssigned ? 'fa-check-circle text-success' : 'fa-circle text-muted'} check-icon"></i>
                                                                            </div>
                                                                        </div>
                                                                        <c:set var="hasEmployee" value="true" />
                                                                    </c:if>
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
                                                                         onclick="toggleAssignment(this, '${reg.userId}', '${shift.id}', '${managerBranchId}', '${workDate}', '${pos.id}')">
                                                                        <div>
                                                                            <strong>${reg.fullName}</strong>
                                                                            <c:choose>
                                                                                <c:when test="${reg.registrationType eq 'SUPPLEMENTARY'}"><span class="badge bg-warning text-dark" style="font-size: 9px;">Đăng ký bổ sung</span></c:when>
                                                                                <c:otherwise><span class="badge bg-light text-dark" style="font-size: 9px;">PT</span></c:otherwise>
                                                                            </c:choose>
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

                                                    <c:forEach var="borrowed" items="${borrowedAssignments[reqKey]}">
                                                        <div class="employee-tag assigned" style="border:2px solid #0d6efd;background:#e7f1ff;cursor:default">
                                                            <span><strong><c:out value="${borrowed.fullName}"/></strong><small class="d-block text-primary">Điều chuyển · <c:out value="${borrowed.sourceBranchName}"/></small></span>
                                                            <i class="fa-solid fa-arrow-right-arrow-left text-primary"></i>
                                                        </div>
                                                        <c:set var="hasEmployee" value="true" />
                                                    </c:forEach>
                                                    <c:if test="${!hasEmployee}">
                                                        <div class="text-muted small fst-italic py-2">Không có nhân sự</div>
                                                    </c:if>
                                                    <c:if test="${assignedCount lt requiredCount and !isPublished}">
                                                        <div class="shortage-message ${assignedCount eq 0 ? 'red' : 'yellow'}">
                                                            <i class="fa-solid ${assignedCount eq 0 ? 'fa-circle-exclamation' : 'fa-triangle-exclamation'} me-1"></i>
                                                            <c:out value="${shortageMessage}" />
                                                        </div>
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

        <%-- Modal vàng: mở đăng ký bổ sung --%>
        <div class="modal fade" id="supplementaryModal" tabindex="-1" aria-labelledby="supplementaryModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content">
                    <form action="schedule" method="POST" id="supplementaryForm">
                        <div class="modal-header bg-warning-subtle">
                            <h5 class="modal-title" id="supplementaryModalLabel">
                                <i class="fa-solid fa-user-plus me-2"></i>Mở đăng ký bổ sung ca thiếu
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="action" value="openSupplementaryRegistration">
                            <input type="hidden" name="branchId" id="suppBranchId">
                            <input type="hidden" name="positionId" id="suppPositionId">
                            <input type="hidden" name="shiftId" id="suppShiftId">
                            <input type="hidden" name="workDate" id="suppWorkDate">
                            <input type="hidden" name="startDate" value="${startDateRaw}">
                            <input type="hidden" name="requiredCount" id="suppRequiredCount">
                            <input type="hidden" name="assignedCount" id="suppAssignedCount">

                            <div class="alert alert-warning">
                                Ca này đã có người đăng ký/xếp ca nhưng số lượng vẫn thấp hơn nhu cầu. Hãy mở đăng ký bổ sung để nhân viên đủ điều kiện đăng ký.
                            </div>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Vị trí</label>
                                    <input type="text" class="form-control" id="suppPositionTitle" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Ca làm việc</label>
                                    <input type="text" class="form-control" id="suppShiftName" readonly>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Ngày làm việc</label>
                                    <input type="text" class="form-control" id="suppDateDisplay" readonly>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Số lượng đã xếp</label>
                                    <input type="text" class="form-control" id="suppAssignedDisplay" readonly>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Số lượng cần</label>
                                    <input type="text" class="form-control" id="suppRequiredDisplay" readonly>
                                </div>
                                <div class="col-12">
                                    <label for="supplementaryDeadline" class="form-label">Hạn đăng ký bổ sung</label>
                                    <input type="datetime-local" class="form-control" id="supplementaryDeadline" name="registrationDeadline" required>
                                    <div class="form-text">Chọn thời điểm kết thúc đăng ký. Backend cần kiểm tra hạn này không nằm trong quá khứ.</div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-warning"><i class="fa-solid fa-bullhorn me-1"></i>Mở đăng ký</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%-- Modal đỏ: tạo đề xuất điều chuyển --%>
        <div class="modal fade" id="transferProposalModal" tabindex="-1" aria-labelledby="transferProposalModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content">
                    <form action="transfer-requests" method="POST" id="transferProposalForm">
                        <div class="modal-header bg-danger-subtle">
                            <h5 class="modal-title" id="transferProposalModalLabel">
                                <i class="fa-solid fa-right-left me-2"></i>Tạo đề xuất điều chuyển nhân viên
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="action" value="createTransferProposal">
                            <input type="hidden" name="destinationStoreId" id="transferDestinationStoreId">
                            <input type="hidden" name="positionId" id="transferPositionId">
                            <input type="hidden" name="shiftId" id="transferShiftId">
                            <input type="hidden" name="workDate" id="transferWorkDate">
                            <input type="hidden" name="requiredCount" id="transferRequiredCount">
                            <input type="hidden" name="startDate" value="${startDateRaw}">

                            <div class="alert alert-danger">
                                Ca chưa có nhân sự được xếp. Tạo đề xuất để xin điều chuyển nhân viên từ một cơ sở khác.
                            </div>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Vị trí cần mượn</label>
                                    <input type="text" class="form-control" id="transferPositionTitle" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Ca làm việc</label>
                                    <input type="text" class="form-control" id="transferShiftName" readonly>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Ngày cần nhân sự</label>
                                    <input type="text" class="form-control" id="transferDateDisplay" readonly>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Số lượng hiện có</label>
                                    <input type="text" class="form-control" id="transferAssignedDisplay" value="0" readonly>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Số lượng cần</label>
                                    <input type="text" class="form-control" id="transferRequiredDisplay" readonly>
                                </div>
                                <div class="col-md-6"><label for="requestedCount" class="form-label">Số nhân viên muốn mượn</label><input type="number" min="1" value="1" id="requestedCount" name="requestedCount" class="form-control" required></div>
                                <div class="col-12">
                                    <label for="sourceStoreId" class="form-label">Cơ sở đề nghị cho mượn</label>
                                    <select class="form-select" id="sourceStoreId" name="sourceStoreId" required>
                                        <option value="" disabled selected>-- Chọn cơ sở cho mượn --</option>
                                        <c:forEach var="branch" items="${allBranches}">
                                            <%-- Kiểm tra nếu ID của cơ sở khác với cơ sở hiện tại (managerBranchId) thì mới hiển thị để chọn --%>
                                            <c:if test="${branch.id != managerBranchId}">
                                                <option value="${branch.id}">${branch.name}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                    <div class="form-text">Danh sách các cơ sở khác trong hệ thống có thể hỗ trợ điều chuyển nhân sự.</div>
                                </div>
                                <div class="col-12">
                                    <label for="transferReason" class="form-label">Lý do cần điều chuyển</label>
                                    <textarea class="form-control" id="transferReason" name="reason" rows="3" maxlength="500" required placeholder="Ví dụ: Ca làm đang thiếu nhân sự và đã mở đăng ký bổ sung nhưng chưa đủ số lượng."></textarea>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-danger"><i class="fa-solid fa-paper-plane me-1"></i>Gửi cơ sở cho mượn xác nhận</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                                                             // Biến trạng thái Publish từ Server truyền xuống JavaScript
                                                                             const isPublished = ${isPublished};

                                                                             function openShortageModal(branchId, positionId, shiftId, workDate, requiredCount, assignedCount, positionTitle, shiftName) {
                                                                                 if (isPublished) {
                                                                                     alert('Lịch làm việc tuần này đã được Publish. Không thể mở đăng ký bổ sung hoặc tạo đề xuất điều chuyển.');
                                                                                     return;
                                                                                 }

                                                                                 const required = parseInt(requiredCount, 10) || 0;
                                                                                 const assigned = parseInt(assignedCount, 10) || 0;
                                                                                 const dateText = workDate || '';

                                                                                 if (assigned >= required) {
                                                                                     alert('Ca này đã đủ số lượng nhân sự.');
                                                                                     return;
                                                                                 }

                                                                                 if (assigned === 0) {
                                                                                     document.getElementById('transferDestinationStoreId').value = branchId;
                                                                                     document.getElementById('transferPositionId').value = positionId;
                                                                                     document.getElementById('transferShiftId').value = shiftId;
                                                                                     document.getElementById('transferWorkDate').value = dateText;
                                                                                     document.getElementById('transferRequiredCount').value = requiredCount;
                                                                                     document.getElementById('transferPositionTitle').value = positionTitle;
                                                                                     document.getElementById('transferShiftName').value = shiftName;
                                                                                     document.getElementById('transferDateDisplay').value = dateText;
                                                                                     document.getElementById('transferAssignedDisplay').value = assigned;
                                                                                     document.getElementById('transferRequiredDisplay').value = required;
                                                                                     document.getElementById('requestedCount').max = Math.max(1, required - assigned);
                                                                                     document.getElementById('requestedCount').value = 1;
                                                                                     bootstrap.Modal.getOrCreateInstance(document.getElementById('transferProposalModal')).show();
                                                                                 } else {
                                                                                     document.getElementById('suppBranchId').value = branchId;
                                                                                     document.getElementById('suppPositionId').value = positionId;
                                                                                     document.getElementById('suppShiftId').value = shiftId;
                                                                                     document.getElementById('suppWorkDate').value = dateText;
                                                                                     document.getElementById('suppRequiredCount').value = requiredCount;
                                                                                     document.getElementById('suppAssignedCount').value = assignedCount;
                                                                                     document.getElementById('suppPositionTitle').value = positionTitle;
                                                                                     document.getElementById('suppShiftName').value = shiftName;
                                                                                     document.getElementById('suppDateDisplay').value = dateText;
                                                                                     document.getElementById('suppAssignedDisplay').value = assigned;
                                                                                     document.getElementById('suppRequiredDisplay').value = required;
                                                                                     bootstrap.Modal.getOrCreateInstance(document.getElementById('supplementaryModal')).show();
                                                                                 }
                                                                             }

                                                                             // Kiểm tra cơ bản ở giao diện; backend vẫn phải kiểm tra dữ liệu và quyền.
                                                                             document.getElementById('supplementaryForm').addEventListener('submit', function (event) {
                                                                                 const deadline = document.getElementById('supplementaryDeadline').value;
                                                                                 if (!deadline || new Date(deadline).getTime() <= Date.now()) {
                                                                                     event.preventDefault();
                                                                                     alert('Hạn đăng ký phải là thời điểm trong tương lai.');
                                                                                 }
                                                                             });

                                                                             document.getElementById('transferProposalForm').addEventListener('submit', function (event) {
                                                                                 const sourceStoreId = document.getElementById('sourceStoreId').value.trim();
                                                                                 const destinationStoreId = document.getElementById('transferDestinationStoreId').value.trim();
                                                                                 if (!sourceStoreId || sourceStoreId === destinationStoreId) {
                                                                                     event.preventDefault();
                                                                                     alert('Vui lòng chọn một cơ sở cho mượn khác cơ sở đang quản lý.');
                                                                                     return;
                                                                                 }
                                                                                 if (!document.getElementById('transferReason').value.trim()) {
                                                                                     event.preventDefault();
                                                                                     alert('Vui lòng nhập lý do cần điều chuyển.');
                                                                                 }
                                                                             });

                                                                             function toggleAssignment(element, userId, shiftId, branchId, workDate, positionId) {
                                                                                 // Nếu lịch đã được Publish, chặn tuyệt đối không cho thao tác click phân công
                                                                                 if (isPublished) {
                                                                                     alert('Lịch làm việc tuần này đã được Publish. Không thể thay đổi phân công ca!');
                                                                                     return;
                                                                                 }

                                                                                 const formData = new URLSearchParams();
                                                                                 formData.append('action', 'assign');
                                                                                 formData.append('userId', userId);
                                                                                 formData.append('positionId', positionId);
                                                                                 formData.append('shiftId', shiftId);
                                                                                 formData.append('branchId', branchId);
                                                                                 formData.append('workDate', workDate);

                                                                                 fetch('schedule', {
                                                                                     method: 'POST',
                                                                                     headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                                                                     body: formData.toString()
                                                                                 })
                                                                                         .then(response => {
                                                                                             if (response.ok)
                                                                                                 return response.text();
                                                                                             throw new Error('Lỗi kết nối server.');
                                                                                         })
                                                                                         .then(result => {
                                                                                             if (result.trim() === 'published_locked') {
                                                                                                 alert('Lịch đã được Publish, hệ thống từ chối cập nhật.');
                                                                                                 location.reload();
                                                                                                 return;
                                                                                             }
                                                                                             const icon = element.querySelector('.check-icon');
                                                                                             if (result.trim() === 'transfer_locked' || result.trim() === 'assignment_invalid') {
                                                                                                 alert('Nhân viên đang điều chuyển hoặc ca làm không hợp lệ.');
                                                                                                 location.reload();
                                                                                                 return;
                                                                                             }
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
                                                                                 if (isPublished) {
                                                                                     alert('Lịch làm việc tuần này đã được Publish. Không thể chỉnh sửa định mức!');
                                                                                     return;
                                                                                 }

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
                                                                                         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                                                                         body: formData.toString()
                                                                                     })
                                                                                             .then(response => {
                                                                                                 if (response.ok)
                                                                                                     return response.text();
                                                                                                 throw new Error('Lỗi cập nhật định mức.');
                                                                                             })
                                                                                             .then(result => {
                                                                                                 if (result.trim() === 'published_locked') {
                                                                                                     alert('Lịch đã được Publish, hệ thống từ chối cập nhật.');
                                                                                                     location.reload();
                                                                                                     return;
                                                                                                 }
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