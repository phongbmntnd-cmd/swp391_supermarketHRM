<%--
    Fragment: Sidebar Employee Portal
    Dùng chung cho các trang: dashboard, leave-request, request-shift, availability...
    - Active state + tự mở submenu: js/sidebar.js
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="sidebar theme-employee">
    <div class="sidebar-brand">
        <i class="fa-solid fa-id-badge"></i>
        <span>Employee Portal</span>
    </div>

    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/employee/dashboard">
                <i class="fa-solid fa-house"></i> Trang chủ
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/employee/my-schedule">
                <i class="fa-solid fa-calendar-check"></i> Lịch làm việc
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/employee/availability">
                <i class="fa-solid fa-calendar-plus"></i> Khai báo lịch rảnh
            </a>
        </li>

        <%-- Đơn từ & Khiếu nại: bấm mũi tên để xổ loại đơn --%>
        <li>
            <a href="${pageContext.request.contextPath}/employee/forms">
                <i class="fa-solid fa-file-lines"></i> Đơn từ &amp; Khiếu nại
            </a>
            <button type="button"
                    class="submenu-toggle"
                    aria-label="Mở danh sách loại đơn"
                    aria-expanded="false">
                <i class="fa-solid fa-chevron-down chevron"></i>
            </button>
            <ul class="submenu">
                <li>
                    <a href="${pageContext.request.contextPath}/employee/leave-request">
                        <i class="fa-solid fa-plane-departure"></i> Xin nghỉ phép
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/employee/request-shift">
                        <i class="fa-solid fa-arrows-rotate"></i> Đổi ca làm
                        <c:if test="${not empty incomingSwapCount}">
                            <span class="badge rounded-pill text-bg-warning ms-1">
                                ${incomingSwapCount}
                            </span>
                        </c:if>
                    </a>
                </li>
            </ul>
        </li>

        <li>
            <a href="#">
                <i class="fa-solid fa-fingerprint"></i> Chấm công trực tuyến
            </a>
        </li>
    </ul>
</div>
