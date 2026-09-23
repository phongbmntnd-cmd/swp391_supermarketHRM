<%-- 
    Document   : create-user
    Created on : 23 thg 9, 2026, 09:24:43
    Author     : phong
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tạo Tài Khoản Nhân Sự Mới</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .card-custom { max-width: 850px; margin: 30px auto; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .section-title { font-size: 16px; font-weight: 600; color: #0d6efd; margin-bottom: 15px; border-bottom: 2px solid #e9ecef; padding-bottom: 5px; }
    </style>
</head>
<body>

<div class="container">
    <div class="card card-custom p-4 bg-white">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="mb-0 text-primary">Tạo Tài Khoản Nhân Sự Mới</h3>
            <a href="${pageContext.request.contextPath}/hr/dashboard" class="btn btn-outline-secondary btn-sm">Quay lại Dashboard</a>
        </div>

        <c:if test="${not empty message}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/hr/create-user" method="post">
            
            <!-- THÔNG TIN TÀI KHOẢN -->
            <div class="section-title">1. Thông tin tài khoản & Đăng nhập</div>
            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <label class="form-label font-semibold">Mã nhân viên (Username) <span class="text-danger">*</span></label>
                    <input type="text" name="username" class="form-control" placeholder="VD: NV006" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Email (Tùy chọn)</label>
                    <input type="email" name="email" class="form-control" placeholder="nguyenvana@gmail.com">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Vai trò (Role) <span class="text-danger">*</span></label>
                    <select name="roleId" class="form-select" required>
                        <c:forEach var="r" items="${roles}">
                            <option value="${r.id}">${r.name} (${r.description})</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- THÔNG TIN CÁ NHÂN -->
            <div class="section-title">2. Thông tin cá nhân</div>
            <div class="row g-3 mb-3">
                <div class="col-md-5">
                    <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                    <input type="text" name="fullName" class="form-control" placeholder="Nguyễn Văn A" required>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Số điện thoại <span class="text-danger">*</span></label>
                    <input type="text" name="phone" class="form-control" placeholder="090XXXXXXX" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Số CCCD/CMND <span class="text-danger">*</span></label>
                    <input type="text" name="identityCard" class="form-control" placeholder="001090XXXXXX" required>
                </div>
            </div>

            <!-- THÔNG TIN TỔ CHỨC -->
            <div class="section-title">3. Phân công tổ chức</div>
            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <label class="form-label">Cơ sở làm việc <span class="text-danger">*</span></label>
                    <select name="homeBranchId" class="form-select" required>
                        <c:forEach var="b" items="${branches}">
                            <option value="${b.id}">${b.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Phòng ban <span class="text-danger">*</span></label>
                    <select id="departmentSelect" name="departmentId" class="form-select" onchange="filterPositions()" required>
                        <option value="">-- Chọn phòng ban --</option>
                        <c:forEach var="d" items="${departments}">
                            <option value="${d.id}">${d.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Vị trí công việc <span class="text-danger">*</span></label>
                    <select id="positionSelect" name="positionId" class="form-select" required>
                        <option value="">-- Chọn vị trí --</option>
                        <c:forEach var="p" items="${positions}">
                            <option value="${p.id}" data-dept="${p.departmentId}">${p.title}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- LOẠI NHÂN SỰ -->
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <label class="form-label">Loại nhân sự <span class="text-danger">*</span></label>
                    <select id="employeeTypeSelect" name="employeeType" class="form-select" onchange="toggleExpirationDate()" required>
                        <option value="FULL_TIME">FULL_TIME (Chính thức)</option>
                        <option value="PART_TIME">PART_TIME (Thời vụ)</option>
                    </select>
                </div>
                <div class="col-md-6" id="expirationDateContainer" style="display: none;">
                    <label class="form-label">Ngày hết hạn tài khoản <span class="text-danger">*</span></label>
                    <input type="date" id="expirationDateInput" name="expirationDate" class="form-control">
                </div>
            </div>

            <div class="text-end">
                <button type="submit" class="btn btn-primary px-4">Tạo Tài Khoản</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Tự động lọc Vị trí theo Phòng ban được chọn
    function filterPositions() {
        const deptId = document.getElementById('departmentSelect').value;
        const positionSelect = document.getElementById('positionSelect');
        const options = positionSelect.querySelectorAll('option');

        options.forEach(opt => {
            if (opt.value === "") return;
            if (deptId === "" || opt.getAttribute('data-dept') === deptId) {
                opt.style.display = "block";
            } else {
                opt.style.display = "none";
            }
        });
        positionSelect.value = "";
    }

    // Dynamic Ẩn/Hiện chọn Hạn ngày khi chọn PART_TIME
    function toggleExpirationDate() {
        const type = document.getElementById('employeeTypeSelect').value;
        const container = document.getElementById('expirationDateContainer');
        const input = document.getElementById('expirationDateInput');

        if (type === 'PART_TIME') {
            container.style.display = 'block';
            input.required = true;
        } else {
            container.style.display = 'none';
            input.required = false;
            input.value = '';
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
