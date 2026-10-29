<%--
    Fragment: Sidebar Store Manager Portal
    Dùng chung cho các trang: dashboard, leave-requests, shift-requests, schedule...
    - Active state + tự mở submenu: js/sidebar.js
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="sidebar theme-store-manager">
    <div class="sidebar-brand">
        <i class="fa-solid fa-store"></i>
        <span>Store Portal</span>
    </div>

    <ul class="sidebar-menu">
        <li>
            <a href="${pageContext.request.contextPath}/store-manager/dashboard">
                <i class="fa-solid fa-chart-pie"></i> Bảng điều khiển
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/store-manager/employees">
                <i class="fa-solid fa-users"></i> Quản lý nhân sự
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/store-manager/recruitment">
                <i class="fa-solid fa-file-invoice"></i> Đề xuất nhân sự
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/store-manager/attendance">
                <i class="fa-solid fa-clipboard-user"></i> Chấm công &amp; Ca làm
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/store-manager/violations">
                <i class="fa-solid fa-triangle-exclamation"></i> Báo cáo vi phạm
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/store-manager/schedule">
                <i class="fa-solid fa-calendar-days"></i> Xếp lịch trực tuần
            </a>
        </li>

        <%-- Đơn từ & Khiếu nại: bấm mũi tên để xổ loại đơn --%>
        <li>
            <a href="${pageContext.request.contextPath}/store-manager/forms">
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
                    <a href="${pageContext.request.contextPath}/store-manager/leave-requests">
                        <i class="fa-solid fa-plane-departure"></i> Duyệt nghỉ phép
                    </a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/store-manager/shift-requests">
                        <i class="fa-solid fa-arrows-rotate"></i> Duyệt đổi ca
                    </a>
                </li>
            </ul>
        </li>
    </ul>
</div>
