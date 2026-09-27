-- Kiểm tra role_id của nhân viên test
SELECT 
    u.id,
    u.username,
    ep.full_name,
    u.role_id,
    r.name AS role_name,
    ep.home_branch_id
FROM users u
JOIN roles r ON u.role_id = r.id
JOIN employee_profiles ep ON u.id = ep.user_id
WHERE u.username IN ('NV001', 'test_nv01', 'test_nv02', 'test_nv03');

-- Kiểm tra xem có user nào không có employee_profile không
SELECT u.id, u.username, u.role_id, r.name AS role_name
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN employee_profiles ep ON u.id = ep.user_id
WHERE ep.user_id IS NULL;
