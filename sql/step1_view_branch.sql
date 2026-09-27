-- =============================================
-- BƯỚC 1: Xem Store Manager và Branch của bạn
-- home_branch_id nằm trong employee_profiles!
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
