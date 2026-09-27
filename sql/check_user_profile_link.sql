-- =============================================
-- KIỂM TRA: User có employee_profile chưa?
-- =============================================

-- 1. Nhân viên (role_id = 5) có employee_profile không?
SELECT 
    u.id,
    u.username,
    u.role_id,
    r.name AS role_name,
    CASE WHEN ep.user_id IS NOT NULL THEN 'CO' ELSE 'CHUA CO EP' END AS co_profile
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN employee_profiles ep ON u.id = ep.user_id
WHERE u.role_id = 5;

-- 2. User nào CHƯA có employee_profile?
SELECT 
    u.id,
    u.username,
    u.role_id,
    r.name AS role_name
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN employee_profiles ep ON u.id = ep.user_id
WHERE ep.user_id IS NULL;
