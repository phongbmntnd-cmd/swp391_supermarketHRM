-- =============================================
-- TRUY VẤN GIỐNG HỆT CODE JAVA
-- =============================================

-- sm_user có branch_id = 1, lấy branchId = 1
-- SQL: SELECT ... WHERE ep.home_branch_id = ? AND u.role_id = 5

SELECT 
    ep.user_id,
    ep.full_name,
    ep.home_branch_id,
    u.username,
    u.role_id,
    u.status
FROM employee_profiles ep
JOIN users u ON ep.user_id = u.id
WHERE ep.home_branch_id = 1 AND u.role_id = 5;
