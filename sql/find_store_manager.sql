-- =============================================
-- Tìm Store Manager thật sự đang login
-- role_id = 4 là Store Manager
-- =============================================

-- Xem tất cả roles
SELECT id, name FROM roles;

-- Tìm Store Manager (role_id = 4)
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

-- Xem cả HR Manager và Store Manager
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
WHERE u.role_id IN (3, 4);
