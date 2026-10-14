<%--
    Module 2: Quản lý Master Data
    Departments + Positions + Roles
--%>
<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="ctx" content="${pageContext.request.contextPath}">
    <title>Quản lý Master Data - Admin</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
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
        .top-navbar h1 { font-size: 20px; font-weight: 500; }
        .user-info { display: flex; gap: 15px; align-items: center; font-size: 14px; }
        .user-info a {
            color: white; text-decoration: none;
            background: #e74c3c; padding: 6px 12px;
            border-radius: 4px; font-weight: bold;
        }
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }

        .page-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px;
        }
        .page-header h2 { color: #2c3e50; font-size: 24px; }
        .back-link {
            color: #3498db; text-decoration: none; font-size: 14px;
            background: white; padding: 8px 16px; border-radius: 4px;
            border: 1px solid #3498db;
        }
        .back-link:hover { background: #3498db; color: white; }

        /* Alerts */
        .alert {
            padding: 12px 20px; border-radius: 6px; margin-bottom: 20px;
            font-size: 14px; transition: opacity 0.3s;
        }
        .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
        .alert-error   { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }

        /* Tabs */
        .tabs {
            display: flex; gap: 4px; margin-bottom: 0;
            border-bottom: 2px solid #e0e0e0;
        }
        .tab-btn {
            padding: 12px 24px; cursor: pointer; background: transparent;
            border: none; font-size: 15px; font-weight: 500; color: #7f8c8d;
            border-bottom: 3px solid transparent; margin-bottom: -2px;
            transition: all 0.2s;
        }
        .tab-btn:hover { color: #2c3e50; }
        .tab-btn.active {
            color: #2c3e50; border-bottom-color: #3498db;
            background: white;
        }
        .tab-content {
            display: none; background: white; padding: 25px;
            border-radius: 0 0 8px 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .tab-content.active { display: block; }

        /* Form inline */
        .inline-form {
            display: grid; grid-template-columns: 2fr 1fr 1fr auto auto;
            gap: 10px; padding: 15px; background: #f8f9fa;
            border-radius: 6px; margin-bottom: 20px; align-items: end;
        }
        .inline-form.dept-form { grid-template-columns: 3fr auto auto; }
        .inline-form.role-form { grid-template-columns: 2fr 3fr auto auto; }
        .form-group label {
            display: block; margin-bottom: 5px; font-size: 13px;
            font-weight: 500; color: #555;
        }
        .form-group input, .form-group select {
            width: 100%; padding: 8px 12px; border: 1px solid #ddd;
            border-radius: 4px; font-size: 14px;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none; border-color: #3498db;
        }
        .btn {
            padding: 8px 16px; border: none; border-radius: 4px;
            cursor: pointer; font-size: 14px; font-weight: 500;
            transition: all 0.2s; text-decoration: none;
            display: inline-block; text-align: center;
        }
        .btn-primary { background: #3498db; color: white; }
        .btn-primary:hover { background: #2980b9; }
        .btn-success { background: #27ae60; color: white; }
        .btn-success:hover { background: #1e8449; }
        .btn-danger { background: #e74c3c; color: white; }
        .btn-danger:hover { background: #c0392b; }
        .btn-secondary { background: #95a5a6; color: white; }
        .btn-secondary:hover { background: #7f8c8d; }
        .btn-sm { padding: 5px 10px; font-size: 13px; }
        .btn:disabled { opacity: 0.5; cursor: not-allowed; }

        /* Table */
        .data-table {
            width: 100%; border-collapse: collapse; margin-top: 10px;
        }
        .data-table th, .data-table td {
            padding: 10px 12px; text-align: left; border-bottom: 1px solid #eee;
            font-size: 14px;
        }
        .data-table th {
            background: #ecf0f1; color: #2c3e50; font-weight: 600;
            font-size: 13px; text-transform: uppercase;
        }
        .data-table tr:hover { background: #f8f9fa; }
        .action-cell { display: flex; gap: 6px; }

        .empty-state {
            text-align: center; padding: 40px; color: #7f8c8d;
        }
        .count-badge {
            background: #ecf0f1; color: #2c3e50; padding: 2px 8px;
            border-radius: 12px; font-size: 12px; margin-left: 8px;
        }
        .id-cell { color: #95a5a6; font-family: monospace; }
        .desc-cell { color: #555; font-style: italic; }

        /* Edit mode row */
        .edit-row { background: #fff3cd !important; }
        .edit-row input, .edit-row select {
            width: 100%; padding: 6px 8px; border: 1px solid #f39c12;
            border-radius: 3px; font-size: 14px;
        }
    </style>
</head>
<body>

<div class="top-navbar">
    <h1>Hệ Thống Quản Lý Siêu Thị - Quản Trị Viên</h1>
    <div class="user-info">
        <span>Xin chào, <b>${sessionScope.account.username}</b></span>
        <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
    </div>
</div>

<div class="container">

    <div class="page-header">
        <h2>⚙ Quản Lý Dữ Liệu Nền (Master Data)</h2>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="back-link">← Quay về Dashboard</a>
    </div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">✅ ${successMessage}</div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">❌ ${errorMessage}</div>
    </c:if>

    <!-- Tabs -->
    <div class="tabs">
        <button class="tab-btn active" onclick="openTab('departments', this)">
            🏢 Phòng Ban <span class="count-badge">${fn:length(departments)}</span>
        </button>
        <button class="tab-btn" onclick="openTab('positions', this)">
            💼 Vị Trí <span class="count-badge">${fn:length(positions)}</span>
        </button>
        <button class="tab-btn" onclick="openTab('roles', this)">
            👤 Vai Trò <span class="count-badge">${fn:length(roles)}</span>
        </button>
    </div>

    <!-- TAB 1: DEPARTMENTS -->
    <div id="tab-departments" class="tab-content active">
        <h3 style="margin-bottom: 15px; color: #2c3e50;">🏢 Danh sách Phòng Ban</h3>

        <form class="inline-form dept-form" method="POST"
              action="${pageContext.request.contextPath}/admin/master-data"
              onsubmit="return validateDeptForm(this)">
            <input type="hidden" name="action" value="createDepartment">
            <div class="form-group">
                <label>Tên phòng ban mới *</label>
                <input type="text" name="name" placeholder="VD: Phòng Kế Toán" required maxlength="100">
            </div>
            <button type="submit" class="btn btn-primary">+ Thêm</button>
            <button type="reset" class="btn btn-secondary">Làm mới</button>
        </form>

        <c:choose>
            <c:when test="${not empty departments}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">ID</th>
                            <th>Tên phòng ban</th>
                            <th style="width: 200px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="d" items="${departments}">
                            <tr id="dept-row-${d.id}">
                                <td class="id-cell">#${d.id}</td>
                                <td>
                                    <span class="display-name">${fn:escapeXml(d.name)}</span>
                                    <form class="edit-form" method="POST"
                                          action="${pageContext.request.contextPath}/admin/master-data"
                                          style="display: none;">
                                        <input type="hidden" name="action" value="updateDepartment">
                                        <input type="hidden" name="id" value="${d.id}">
                                        <input type="text" name="name" value="${fn:escapeXml(d.name)}" required maxlength="100">
                                    </form>
                                </td>
                                <td>
                                    <div class="action-cell">
                                        <button type="button" class="btn btn-primary btn-sm"
                                                onclick="toggleEditDept(${d.id})">✏ Sửa</button>
                                        <button type="button" class="btn btn-success btn-sm"
                                                style="display: none;"
                                                onclick="document.getElementById('dept-row-${d.id}').querySelector('.edit-form').submit();">💾 Lưu</button>
                                        <button type="button" class="btn btn-secondary btn-sm"
                                                style="display: none;"
                                                onclick="cancelEditDept(${d.id})">Hủy</button>
                                        <button type="button" class="btn btn-danger btn-sm"
                                                onclick="doDeleteDept(${d.id}, '${fn:escapeXml(d.name)}')">🗑 Xóa</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">Chưa có phòng ban nào.</div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- TAB 2: POSITIONS -->
    <div id="tab-positions" class="tab-content">
        <h3 style="margin-bottom: 15px; color: #2c3e50;">💼 Danh sách Vị Trí Công Việc</h3>

        <form class="inline-form" method="POST"
              action="${pageContext.request.contextPath}/admin/master-data"
              onsubmit="return validatePosForm(this)">
            <input type="hidden" name="action" value="createPosition">
            <div class="form-group">
                <label>Tên vị trí *</label>
                <input type="text" name="title" placeholder="VD: Nhân viên IT" required maxlength="100">
            </div>
            <div class="form-group">
                <label>Phòng ban *</label>
                <select name="departmentId" required>
                    <option value="">-- Chọn phòng ban --</option>
                    <c:forEach var="d" items="${allDepts}">
                        <option value="${d.id}">${fn:escapeXml(d.name)}</option>
                    </c:forEach>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">+ Thêm</button>
            <button type="reset" class="btn btn-secondary">Làm mới</button>
        </form>

        <c:choose>
            <c:when test="${not empty positions}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">ID</th>
                            <th>Tên vị trí</th>
                            <th>Phòng ban</th>
                            <th style="width: 220px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${positions}">
                            <tr id="pos-row-${p.id}">
                                <td class="id-cell">#${p.id}</td>
                                <td>
                                    <span class="display-title">${fn:escapeXml(p.title)}</span>
                                    <form class="edit-form" method="POST"
                                          action="${pageContext.request.contextPath}/admin/master-data"
                                          style="display: none;">
                                        <input type="hidden" name="action" value="updatePosition">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <input type="text" name="title" value="${fn:escapeXml(p.title)}" required maxlength="100">
                                    </form>
                                </td>
                                <td>
                                    <span class="display-dept">
                                        <c:set var="foundDept" value="false"/>
                                        <c:forEach var="d" items="${allDepts}">
                                            <c:if test="${d.id == p.departmentId}">
                                                ${fn:escapeXml(d.name)}
                                                <c:set var="foundDept" value="true"/>
                                            </c:if>
                                        </c:forEach>
                                        <c:if test="${foundDept == 'false'}">
                                            <em style="color:#999;">(chưa gán)</em>
                                        </c:if>
                                    </span>
                                    <form class="edit-form" method="POST"
                                          action="${pageContext.request.contextPath}/admin/master-data"
                                          style="display: none;">
                                        <input type="hidden" name="action" value="updatePosition">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <select name="departmentId" required>
                                            <c:forEach var="d" items="${allDepts}">
                                                <option value="${d.id}" ${d.id == p.departmentId ? 'selected' : ''}>
                                                    ${fn:escapeXml(d.name)}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </form>
                                </td>
                                <td>
                                    <div class="action-cell">
                                        <button type="button" class="btn btn-primary btn-sm"
                                                onclick="toggleEditPos(${p.id})">✏ Sửa</button>
                                        <button type="button" class="btn btn-success btn-sm"
                                                style="display: none;"
                                                onclick="document.getElementById('pos-row-${p.id}').querySelectorAll('.edit-form')[1].submit();">💾 Lưu</button>
                                        <button type="button" class="btn btn-secondary btn-sm"
                                                style="display: none;"
                                                onclick="cancelEditPos(${p.id})">Hủy</button>
                                        <button type="button" class="btn btn-danger btn-sm"
                                                onclick="doDeletePos(${p.id}, '${fn:escapeXml(p.title)}')">🗑 Xóa</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">Chưa có vị trí nào.</div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- TAB 3: ROLES -->
    <div id="tab-roles" class="tab-content">
        <h3 style="margin-bottom: 15px; color: #2c3e50;">👤 Danh sách Vai Trò</h3>

        <form class="inline-form role-form" method="POST"
              action="${pageContext.request.contextPath}/admin/master-data"
              onsubmit="return validateRoleForm(this)">
            <input type="hidden" name="action" value="createRole">
            <div class="form-group">
                <label>Tên vai trò *</label>
                <input type="text" name="name" placeholder="VD: STORE_MANAGER" required maxlength="50">
            </div>
            <div class="form-group">
                <label>Mô tả</label>
                <input type="text" name="description" placeholder="Mô tả ngắn về vai trò..." maxlength="255">
            </div>
            <button type="submit" class="btn btn-primary">+ Thêm</button>
            <button type="reset" class="btn btn-secondary">Làm mới</button>
        </form>

        <c:choose>
            <c:when test="${not empty roles}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">ID</th>
                            <th>Tên vai trò</th>
                            <th>Mô tả</th>
                            <th style="width: 200px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${roles}">
                            <tr id="role-row-${r.id}" ${r.id <= 5 ? 'style="background:#fafafa;"' : ''}>
                                <td class="id-cell">
                                    #${r.id}
                                    <c:if test="${r.id <= 5}">
                                        <span style="color:#27ae60; font-size:11px; margin-left:4px;">🔒 mặc định</span>
                                    </c:if>
                                </td>
                                <td>
                                    <span class="display-name">${fn:escapeXml(r.name)}</span>
                                    <form class="edit-form" method="POST"
                                          action="${pageContext.request.contextPath}/admin/master-data"
                                          style="display: none;">
                                        <input type="hidden" name="action" value="updateRole">
                                        <input type="hidden" name="id" value="${r.id}">
                                        <input type="text" name="name" value="${fn:escapeXml(r.name)}" required maxlength="50">
                                    </form>
                                </td>
                                <td>
                                    <span class="desc-cell display-desc">${fn:escapeXml(r.description != null ? r.description : '')}</span>
                                    <form class="edit-form" method="POST"
                                          action="${pageContext.request.contextPath}/admin/master-data"
                                          style="display: none;">
                                        <input type="hidden" name="action" value="updateRole">
                                        <input type="hidden" name="id" value="${r.id}">
                                        <input type="text" name="description" value="${fn:escapeXml(r.description != null ? r.description : '')}" maxlength="255">
                                    </form>
                                </td>
                                <td>
                                    <div class="action-cell">
                                        <c:choose>
                                            <c:when test="${r.id <= 5}">
                                                <button type="button" class="btn btn-primary btn-sm" disabled title="Vai trò hệ thống không thể sửa">🔒 Cố định</button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="btn btn-primary btn-sm"
                                                        onclick="toggleEditRole(${r.id})">✏ Sửa</button>
                                                <button type="button" class="btn btn-success btn-sm"
                                                        style="display: none;"
                                                        onclick="document.getElementById('role-row-${r.id}').querySelectorAll('.edit-form')[1].submit();">💾 Lưu</button>
                                                <button type="button" class="btn btn-secondary btn-sm"
                                                        style="display: none;"
                                                        onclick="cancelEditRole(${r.id})">Hủy</button>
                                                <button type="button" class="btn btn-danger btn-sm"
                                                        onclick="doDeleteRole(${r.id}, '${fn:escapeXml(r.name)}')">🗑 Xóa</button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">Chưa có vai trò nào.</div>
            </c:otherwise>
        </c:choose>
    </div>

</div>

<script>
    // =============================================
    // TAB SWITCHING
    // =============================================
    function openTab(name, btn) {
        document.querySelectorAll('.tab-content').forEach(function(el) { el.classList.remove('active'); });
        document.querySelectorAll('.tab-btn').forEach(function(el) { el.classList.remove('active'); });
        document.getElementById('tab-' + name).classList.add('active');
        if (btn) btn.classList.add('active');
        // Lưu tab hiện tại vào hash
        history.replaceState(null, '', '#' + name);
    }
    // Mở tab theo URL hash (nếu có)
    (function() {
        var hash = window.location.hash.replace('#', '');
        if (hash === 'positions' || hash === 'roles' || hash === 'departments') {
            var btns = document.querySelectorAll('.tab-btn');
            var tabs = {'departments':0,'positions':1,'roles':2};
            openTab(hash, btns[tabs[hash]]);
        }
    })();

    // =============================================
    // VALIDATE FORM
    // =============================================
    function validateDeptForm(f) {
        var name = f.querySelector('input[name="name"]').value.trim();
        if (!name) { alert('Vui lòng nhập tên phòng ban!'); return false; }
        if (name.length > 100) { alert('Tên phòng ban tối đa 100 ký tự!'); return false; }
        return true;
    }
    function validatePosForm(f) {
        var title = f.querySelector('input[name="title"]').value.trim();
        var deptId = f.querySelector('select[name="departmentId"]').value;
        if (!title) { alert('Vui lòng nhập tên vị trí!'); return false; }
        if (!deptId) { alert('Vui lòng chọn phòng ban!'); return false; }
        return true;
    }
    function validateRoleForm(f) {
        var name = f.querySelector('input[name="name"]').value.trim();
        if (!name) { alert('Vui lòng nhập tên vai trò!'); return false; }
        if (name.length > 50) { alert('Tên vai trò tối đa 50 ký tự!'); return false; }
        return true;
    }

    // =============================================
    // INLINE EDIT (DEPARTMENTS)
    // =============================================
    function toggleEditDept(id) {
        var row = document.getElementById('dept-row-' + id);
        var btns = row.querySelectorAll('.action-cell button');
        // 0: Sửa, 1: Lưu, 2: Hủy, 3: Xóa
        btns[0].style.display = 'none';
        btns[1].style.display = '';
        btns[2].style.display = '';
        row.classList.add('edit-row');
        row.querySelector('.display-name').style.display = 'none';
        row.querySelector('.edit-form').style.display = 'block';
    }
    function cancelEditDept(id) {
        var row = document.getElementById('dept-row-' + id);
        var btns = row.querySelectorAll('.action-cell button');
        btns[0].style.display = '';
        btns[1].style.display = 'none';
        btns[2].style.display = 'none';
        row.classList.remove('edit-row');
        row.querySelector('.display-name').style.display = '';
        row.querySelector('.edit-form').style.display = 'none';
    }

    // =============================================
    // INLINE EDIT (POSITIONS)
    // =============================================
    function toggleEditPos(id) {
        var row = document.getElementById('pos-row-' + id);
        var btns = row.querySelectorAll('.action-cell button');
        btns[0].style.display = 'none';
        btns[1].style.display = '';
        btns[2].style.display = '';
        row.classList.add('edit-row');
        row.querySelectorAll('.display-title, .display-dept').forEach(function(el){ el.style.display = 'none'; });
        row.querySelectorAll('.edit-form').forEach(function(el){ el.style.display = 'block'; });
    }
    function cancelEditPos(id) {
        var row = document.getElementById('pos-row-' + id);
        var btns = row.querySelectorAll('.action-cell button');
        btns[0].style.display = '';
        btns[1].style.display = 'none';
        btns[2].style.display = 'none';
        row.classList.remove('edit-row');
        row.querySelectorAll('.display-title, .display-dept').forEach(function(el){ el.style.display = ''; });
        row.querySelectorAll('.edit-form').forEach(function(el){ el.style.display = 'none'; });
    }

    // =============================================
    // INLINE EDIT (ROLES)
    // =============================================
    function toggleEditRole(id) {
        var row = document.getElementById('role-row-' + id);
        var btns = row.querySelectorAll('.action-cell button');
        btns[0].style.display = 'none';
        btns[1].style.display = '';
        btns[2].style.display = '';
        row.classList.add('edit-row');
        row.querySelectorAll('.display-name, .display-desc').forEach(function(el){ el.style.display = 'none'; });
        row.querySelectorAll('.edit-form').forEach(function(el){ el.style.display = 'block'; });
    }
    function cancelEditRole(id) {
        var row = document.getElementById('role-row-' + id);
        var btns = row.querySelectorAll('.action-cell button');
        btns[0].style.display = '';
        btns[1].style.display = 'none';
        btns[2].style.display = 'none';
        row.classList.remove('edit-row');
        row.querySelectorAll('.display-name, .display-desc').forEach(function(el){ el.style.display = ''; });
        row.querySelectorAll('.edit-form').forEach(function(el){ el.style.display = 'none'; });
    }

    // =============================================
    // DELETE - dùng confirm() + form động (chắc chắn chạy)
    // =============================================
    function getCtx() {
        var m = document.querySelector('meta[name="ctx"]');
        return m ? m.content : '';
    }
    function submitForm(action, fields) {
        var f = document.createElement('form');
        f.method = 'POST';
        f.action = getCtx() + '/admin/master-data';
        var html = '<input name="action" value="' + action + '">';
        for (var k in fields) {
            if (fields.hasOwnProperty(k)) {
                html += '<input name="' + k + '" value="' + (fields[k] || '') + '">';
            }
        }
        f.innerHTML = html;
        document.body.appendChild(f);
        f.submit();
    }

    function doDeleteDept(id, name) {
        if (!confirm('XÁC NHẬN XÓA PHÒNG BAN\n\n"' + name + '"\n\nLưu ý: Phòng ban chỉ xóa được khi KHÔNG còn vị trí nào thuộc phòng ban này.\n\nNhấn OK để xóa, Cancel để hủy.')) return;
        submitForm('deleteDepartment', { id: id });
    }
    function doDeletePos(id, name) {
        if (!confirm('XÁC NHẬN XÓA VỊ TRÍ\n\n"' + name + '"\n\nLưu ý: Vị trí chỉ xóa được khi KHÔNG còn nhân viên nào đang giữ vị trí này.\n\nNhấn OK để xóa, Cancel để hủy.')) return;
        submitForm('deletePosition', { id: id });
    }
    function doDeleteRole(id, name) {
        if (!confirm('XÁC NHẬN XÓA VAI TRÒ\n\n"' + name + '"\n\nLưu ý: Vai trò chỉ xóa được khi KHÔNG còn tài khoản nào sử dụng vai trò này.\n\nNhấn OK để xóa, Cancel để hủy.')) return;
        submitForm('deleteRole', { id: id });
    }

    // =============================================
    // TỰ ẨN ALERT sau 5 giây
    // =============================================
    setTimeout(function() {
        document.querySelectorAll('.alert').forEach(function(alert) {
            alert.style.opacity = '0';
            setTimeout(function() { alert.style.display = 'none'; }, 300);
        });
    }, 5000);
</script>

</body>
</html>
