-- =============================================
-- FIX BRANCH_ID CHO NHÂN VIÊN
-- home_branch_id nằm trong BẢNG employee_profiles!
-- =============================================

-- =============================================
-- BƯỚC 1: Xem Store Manager và Branch của bạn
-- =============================================

SELECT 
    u.id,
    u.username,
    u.role_id,
    r.name AS role_name,
    ep.home_branch_id,
    b.name AS branch_name
FROM users u
JOIN roles r ON u.role_id = r.id
JOIN employee_profiles ep ON u.id = ep.user_id
LEFT JOIN branches b ON ep.home_branch_id = b.id
WHERE u.role_id = 3;

-- =============================================
-- BƯỚC 2: Lấy branch_id cần update
-- =============================================

-- Lấy branch_id của Store Manager đầu tiên
SET @correct_branch_id = (
    SELECT ep.home_branch_id 
    FROM users u
    JOIN employee_profiles ep ON u.id = ep.user_id
    WHERE u.role_id = 3 
    LIMIT 1
);

SELECT CONCAT('Branch ID sẽ sử dụng: ', @correct_branch_id) AS info;

-- =============================================
-- BƯỚC 3: UPDATE tất cả nhân viên vào đúng branch
-- =============================================

-- Xem nhân viên TRƯỚC KHI update
SELECT 
    ep.user_id,
    u.username,
    ep.full_name,
    ep.home_branch_id AS current_branch,
    u.status
FROM employee_profiles ep
JOIN users u ON ep.user_id = u.id
WHERE u.role_id = 5;

-- UPDATE
UPDATE employee_profiles ep
JOIN users u ON ep.user_id = u.id
SET ep.home_branch_id = @correct_branch_id
WHERE u.role_id = 5;

SELECT CONCAT('Da update ', ROW_COUNT(), ' nhan vien vao branch ', @correct_branch_id) AS result;

-- =============================================
-- BƯỚC 4: XÁC NHẬN SAU KHI UPDATE
-- =============================================

SELECT 
    ep.user_id,
    u.username,
    ep.full_name,
    ep.home_branch_id,
    b.name AS branch_name,
    u.status
FROM employee_profiles ep
JOIN users u ON ep.user_id = u.id
LEFT JOIN branches b ON ep.home_branch_id = b.id
WHERE u.role_id = 5
ORDER BY ep.user_id;
