-- =============================================
-- DỮ LIỆU TEST NHÂN VIÊN CHO STORE MANAGER
-- =============================================

-- Kiểm tra branch_id của store manager đang login
-- Thay 2 bằng branch_id của bạn
SET @branch_id = 2;

-- =============================================
-- TẠO USERS (Employee = role_id 5)
-- =============================================

-- User 1: FULL_TIME, ACTIVE
INSERT INTO users (username, email, password, role_id, status, created_at) 
VALUES ('nguyenvana', 'nguyenvana@supermarket.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3eDHxM7W7YJ5L6V5Y5Kq', 5, 'ACTIVE', NOW())
ON DUPLICATE KEY UPDATE username = username;

-- User 2: FULL_TIME, ACTIVE
INSERT INTO users (username, email, password, role_id, status, created_at) 
VALUES ('tranthib', 'tranthib@supermarket.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3eDHxM7W7YJ5L6V5Y5Kq', 5, 'ACTIVE', NOW())
ON DUPLICATE KEY UPDATE username = username;

-- User 3: PART_TIME, ACTIVE
INSERT INTO users (username, email, password, role_id, status, created_at) 
VALUES ('levanc', 'levanc@supermarket.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3eDHxM7W7YJ5L6V5Y5Kq', 5, 'ACTIVE', NOW())
ON DUPLICATE KEY UPDATE username = username;

-- User 4: FULL_TIME, EMERGENCY_LOCKED
INSERT INTO users (username, email, password, role_id, status, created_at) 
VALUES ('phamthid', 'phamthid@supermarket.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3eDHxM7W7YJ5L6V5Y5Kq', 5, 'EMERGENCY_LOCKED', NOW())
ON DUPLICATE KEY UPDATE username = username;

-- User 5: PART_TIME, ACTIVE
INSERT INTO users (username, email, password, role_id, status, created_at) 
VALUES ('hoangvane', 'hoangvane@supermarket.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3eDHxM7W7YJ5L6V5Y5Kq', 5, 'ACTIVE', NOW())
ON DUPLICATE KEY UPDATE username = username;

-- User 6: FULL_TIME, INACTIVE (đã nghỉ)
INSERT INTO users (username, email, password, role_id, status, created_at) 
VALUES ('dongthif', 'dongthif@supermarket.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3eDHxM7W7YJ5L6V5Y5Kq', 5, 'INACTIVE', NOW())
ON DUPLICATE KEY UPDATE username = username;

-- User 7: PART_TIME, ACTIVE
INSERT INTO users (username, email, password, role_id, status, created_at) 
VALUES ('dinhvang', 'dinhvang@supermarket.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3eDHxM7W7YJ5L6V5Y5Kq', 5, 'ACTIVE', NOW())
ON DUPLICATE KEY UPDATE username = username;

-- User 8: FULL_TIME, ACTIVE
INSERT INTO users (username, email, password, role_id, status, created_at) 
VALUES ('buiThih', 'buithih@supermarket.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3eDHxM7W7YJ5L6V5Y5Kq', 5, 'ACTIVE', NOW())
ON DUPLICATE KEY UPDATE username = username;

-- =============================================
-- TẠO EMPLOYEE PROFILES
-- =============================================

-- Lấy user_ids vừa insert
-- User 1: Nguyễn Văn A - FULL_TIME - Cashier - Hà Nội
INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, created_at)
SELECT u.id, 'Nguyễn Văn A', '0912345678', '123456789012', @branch_id, 8, 4, 'Full-time', NOW()
FROM users u WHERE u.username = 'nguyenvana'
ON DUPLICATE KEY UPDATE full_name = 'Nguyễn Văn A';

-- User 2: Trần Thị B - FULL_TIME - Shelf Stocker - Hà Nội
INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, created_at)
SELECT u.id, 'Trần Thị B', '0923456789', '234567890123', @branch_id, 9, 5, 'Full-time', NOW()
FROM users u WHERE u.username = 'tranthib'
ON DUPLICATE KEY UPDATE full_name = 'Trần Thị B';

-- User 3: Lê Văn C - PART_TIME - Cashier - Hà Nội
INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, created_at)
SELECT u.id, 'Lê Văn C', '0934567890', '345678901234', @branch_id, 8, 4, 'Part-time', NOW()
FROM users u WHERE u.username = 'levanc'
ON DUPLICATE KEY UPDATE full_name = 'Lê Văn C';

-- User 4: Phạm Thị D - FULL_TIME - Shelf Stocker - EMERGENCY_LOCKED
INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, created_at)
SELECT u.id, 'Phạm Thị D', '0945678901', '456789012345', @branch_id, 9, 5, 'Full-time', NOW()
FROM users u WHERE u.username = 'phamthid'
ON DUPLICATE KEY UPDATE full_name = 'Phạm Thị D';

-- User 5: Hoàng Văn E - PART_TIME - Cashier
INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, created_at)
SELECT u.id, 'Hoàng Văn E', '0956789012', '567890123456', @branch_id, 8, 4, 'Part-time', NOW()
FROM users u WHERE u.username = 'hoangvane'
ON DUPLICATE KEY UPDATE full_name = 'Hoàng Văn E';

-- User 6: Đỗ Thị F - FULL_TIME - INACTIVE (đã nghỉ)
INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, created_at)
SELECT u.id, 'Đỗ Thị F', '0967890123', '678901234567', @branch_id, 8, 4, 'Full-time', NOW()
FROM users u WHERE u.username = 'dongthif'
ON DUPLICATE KEY UPDATE full_name = 'Đỗ Thị F';

-- User 7: Đinh Văn G - PART_TIME - Shelf Stocker
INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, created_at)
SELECT u.id, 'Đinh Văn G', '0978901234', '789012345678', @branch_id, 9, 5, 'Part-time', NOW()
FROM users u WHERE u.username = 'dinhvang'
ON DUPLICATE KEY UPDATE full_name = 'Đinh Văn G';

-- User 8: Bùi Thị H - FULL_TIME - Cashier
INSERT INTO employee_profiles (user_id, full_name, phone, identity_card, home_branch_id, position_id, department_id, employee_type, created_at)
SELECT u.id, 'Bùi Thị H', '0989012345', '890123456789', @branch_id, 8, 4, 'Full-time', NOW()
FROM users u WHERE u.username = 'buithih'
ON DUPLICATE KEY UPDATE full_name = 'Bùi Thị H';

-- =============================================
-- XÁC NHẬN
-- =============================================
SELECT 'Đã tạo 8 nhân viên test!' AS status;
SELECT u.username, ep.full_name, ep.employee_type, u.status 
FROM users u 
JOIN employee_profiles ep ON u.id = ep.user_id 
WHERE u.role_id = 5 AND ep.home_branch_id = @branch_id;
