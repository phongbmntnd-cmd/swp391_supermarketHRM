-- Kiểm tra chi tiết sm_user
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
WHERE u.username = 'sm_user';

-- So sánh branch của sm_user với nhân viên
SELECT 
    'sm_user (Store Manager)' AS user_type,
    ep.home_branch_id,
    b.name AS branch_name
FROM users u
JOIN employee_profiles ep ON u.id = ep.user_id
LEFT JOIN branches b ON ep.home_branch_id = b.id
WHERE u.username = 'sm_user'

UNION ALL

SELECT 
    CONCAT(u.username, ' (Employee)') AS user_type,
    ep.home_branch_id,
    b.name AS branch_name
FROM users u
JOIN employee_profiles ep ON u.id = ep.user_id
LEFT JOIN branches b ON ep.home_branch_id = b.id
WHERE u.role_id = 5 AND ep.home_branch_id = (
    SELECT ep2.home_branch_id 
    FROM users u2 
    JOIN employee_profiles ep2 ON u2.id = ep2.user_id 
    WHERE u2.username = 'sm_user'
);
