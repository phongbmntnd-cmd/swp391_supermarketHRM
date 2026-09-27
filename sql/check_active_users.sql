-- =============================================
-- KIỂM TRA: TÀI KHOẢN ĐANG ACTIVE
-- =============================================

-- 1. Tất cả user đang ACTIVE
SELECT 
    u.id,
    u.username,
    u.role_id,
    r.name AS role_name,
    u.status,
    u.is_first_login,
    ep.home_branch_id,
    b.name AS branch_name
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN employee_profiles ep ON u.id = ep.user_id
LEFT JOIN branches b ON ep.home_branch_id = b.id
WHERE u.status = 'ACTIVE'
ORDER BY u.role_id, u.id;

-- 2. Tài khoản nào LOCKED?
SELECT 
    u.id,
    u.username,
    u.role_id,
    r.name AS role_name,
    u.status,
    ep.home_branch_id,
    b.name AS branch_name
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN employee_profiles ep ON u.id = ep.user_id
LEFT JOIN branches b ON ep.home_branch_id = b.id
WHERE u.status = 'LOCKED';
