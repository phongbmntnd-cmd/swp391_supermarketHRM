-- =============================================
-- KIỂM TRA BRANCH CỦA TẤT CẢ ROLE
-- =============================================

-- 1. Xem tất cả users với branch
SELECT 
    u.id,
    u.username,
    u.role_id,
    r.name AS role_name,
    ep.home_branch_id,
    b.name AS branch_name,
    b.code AS branch_code
FROM users u
JOIN roles r ON u.role_id = r.id
JOIN employee_profiles ep ON u.id = ep.user_id
LEFT JOIN branches b ON ep.home_branch_id = b.id
ORDER BY u.role_id, u.id;

-- =============================================
-- 2. Xem Store Manager (role_id = 4)
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
WHERE u.role_id = 4;

-- =============================================
-- 3. Xem nhân viên (role_id = 5) - để so sánh branch
-- =============================================
SELECT 
    u.id,
    u.username,
    ep.full_name,
    ep.home_branch_id,
    b.name AS branch_name,
    u.status
FROM users u
JOIN employee_profiles ep ON u.id = ep.user_id
LEFT JOIN branches b ON ep.home_branch_id = b.id
WHERE u.role_id = 5;
