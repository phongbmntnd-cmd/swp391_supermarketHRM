-- Kiểm tra: Đếm nhân viên role 5 thuộc branch 1
SELECT COUNT(*) AS total_employees
FROM employee_profiles ep
JOIN users u ON ep.user_id = u.id
WHERE u.role_id = 5 AND ep.home_branch_id = 1;
