-- ============================================================
-- DỮ LIỆU MẪU cho mô hình nghỉ phép "C trên nền B"
--
-- Tạo:
--   1. 2 nhân viên PART_TIME ở chi nhánh 1 (để demo luồng tick ca)
--   2. Lịch làm việc tuần tới cho các nhân viên (full-time + part-time)
--   3. Quota nghỉ phép (giờ) cho các nhân viên mới
--   4. Định mức nhân sự (shift_requirements) để demo cảnh báo thiếu người
--
-- Script IDEMPOTENT - chạy lại nhiều lần không sinh trùng.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Tài khoản part-time
-- ------------------------------------------------------------
INSERT INTO `users`
    (`username`, `password_hash`, `email`, `status`, `role_id`, `is_first_login`)
SELECT 'pt_user1', '123456', 'pt1@supermarket.vn', 'ACTIVE', 5, 1
WHERE NOT EXISTS (SELECT 1 FROM `users` WHERE `username` = 'pt_user1');

INSERT INTO `users`
    (`username`, `password_hash`, `email`, `status`, `role_id`, `is_first_login`)
SELECT 'pt_user2', '123456', 'pt2@supermarket.vn', 'ACTIVE', 5, 1
WHERE NOT EXISTS (SELECT 1 FROM `users` WHERE `username` = 'pt_user2');

SET @pt1 = (SELECT id FROM `users` WHERE `username` = 'pt_user1');
SET @pt2 = (SELECT id FROM `users` WHERE `username` = 'pt_user2');

-- Hồ sơ part-time (định mức 5 giờ/ngày theo migration)
INSERT INTO `employee_profiles`
    (`user_id`, `full_name`, `phone`, `identity_card`, `home_branch_id`,
     `position_id`, `department_id`, `employee_type`, `shift_type`,
     `standard_hours_per_day`)
SELECT @pt1, 'Nguyễn Minh Anh (Part-time)', '0901110001', 'PT0000001', 1,
       7, 5, 'PART_TIME', 'PT_FIXED_EVENING', 5.00
WHERE NOT EXISTS (SELECT 1 FROM `employee_profiles` WHERE `user_id` = @pt1);

INSERT INTO `employee_profiles`
    (`user_id`, `full_name`, `phone`, `identity_card`, `home_branch_id`,
     `position_id`, `department_id`, `employee_type`, `shift_type`,
     `standard_hours_per_day`)
SELECT @pt2, 'Trần Thị Bình (Part-time)', '0901110002', 'PT0000002', 1,
       7, 5, 'PART_TIME', 'PT_FIXED_MORNING', 5.00
WHERE NOT EXISTS (SELECT 1 FROM `employee_profiles` WHERE `user_id` = @pt2);

-- ------------------------------------------------------------
-- 2. Quota nghỉ phép (đơn vị giờ)
--    Part-time: 12 ca x 5h = 60 giờ (năm), 30 ca x 5h = 150 giờ (ốm)
--    Full-time: 12 ngày x 10h = 120 giờ, 30 x 10 = 300 giờ
-- ------------------------------------------------------------
INSERT INTO `leave_balances`
    (`user_id`, `leave_type_id`, `year`, `total_days`, `used_days`,
     `total_hours`, `used_hours`)
SELECT @pt1, lt.id, YEAR(CURDATE()), lt.default_days, 0,
       lt.default_days * 5.00, 0
FROM `leave_types` lt
WHERE lt.code IN ('ANNUAL', 'SICK', 'FUNERAL')
  AND NOT EXISTS (
      SELECT 1 FROM `leave_balances` b
      WHERE b.user_id = @pt1
        AND b.leave_type_id = lt.id
        AND b.year = YEAR(CURDATE())
  );

INSERT INTO `leave_balances`
    (`user_id`, `leave_type_id`, `year`, `total_days`, `used_days`,
     `total_hours`, `used_hours`)
SELECT @pt2, lt.id, YEAR(CURDATE()), lt.default_days, 0,
       lt.default_days * 5.00, 0
FROM `leave_types` lt
WHERE lt.code IN ('ANNUAL', 'SICK', 'FUNERAL')
  AND NOT EXISTS (
      SELECT 1 FROM `leave_balances` b
      WHERE b.user_id = @pt2
        AND b.leave_type_id = lt.id
        AND b.year = YEAR(CURDATE())
  );

-- Quota cho nhân viên full-time đã có (user 5) nếu chưa đủ loại
INSERT INTO `leave_balances`
    (`user_id`, `leave_type_id`, `year`, `total_days`, `used_days`,
     `total_hours`, `used_hours`)
SELECT 5, lt.id, YEAR(CURDATE()), lt.default_days, 0,
       lt.default_days * 10.00, 0
FROM `leave_types` lt
WHERE lt.code IN ('ANNUAL', 'SICK', 'FUNERAL')
  AND NOT EXISTS (
      SELECT 1 FROM `leave_balances` b
      WHERE b.user_id = 5
        AND b.leave_type_id = lt.id
        AND b.year = YEAR(CURDATE())
  );

-- ------------------------------------------------------------
-- 3. Lịch làm việc tuần tới (PUBLISHED)
--
--    Tuần tính từ Thứ Hai gần nhất.
--    - Full-time (user 5): ca Full-time Sáng-Chiều (id 4) 10h/ngày, T2->T6
--    - Part-time 1 (Anh):  ca Tối (id 3) 5h, T2/T4/T6/CN
--    - Part-time 2 (Bình): ca Sáng (id 1) 5h, T3/T5/T7
-- ------------------------------------------------------------
-- Thứ Hai của tuần hiện tại.
-- MySQL WEEKDAY(): Monday=0 .. Sunday=6.
-- Với thứ Hai = 0, số ngày lùi về Thứ Hai là WEEKDAY() (đã đúng thứ tự).
-- Ví dụ: CURDATE() = Thứ Bảy -> WEEKDAY() = 5 -> lùi 5 ngày -> Thứ Hai.
SET @mon = DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);

-- ------------------------------------------------------------
-- 3a. Dọn lịch làm việc cũ của nhân viên DEMO
--
--     Lý do: seed chạy lại nhiều lần có thể để lại ca KHÔNG NHẤT
--     quán (ví dụ part-time bị gán cả ca Full-time lẫn Ca Sáng
--     cùng ngày -> chồng lấn giờ, làm hỏng chức năng đổi ca).
--
--     Quy tắc: part-time (PART_TIME/CASUAL) KHÔNG được xếp ca
--     full-time (ca 10h). Xóa các ca full-time đó đi.
--
--     Các bản ghi chấm công tham chiếu shift_schedule_id nên
--     xóa luôn chấm công của ca bị xóa (tránh dữ liệu mồ côi).
--     Tương tự, các đơn đổi ca / nhận ca trống cũng tham chiếu
--     shift_schedule_id -> phải dọn trước để không vi phạm FK.
-- ------------------------------------------------------------
DELETE a FROM `attendances` a
JOIN `shift_schedules` ss ON ss.id = a.shift_schedule_id
JOIN `employee_profiles` ep ON ep.user_id = ss.user_id
WHERE ep.employee_type IN ('PART_TIME', 'CASUAL')
  AND ss.shift_id IN (4, 5);

-- Dọn đơn đổi ca / nhận ca trống tham chiếu ca sắp bị xóa
DELETE scr FROM `shift_change_requests` scr
JOIN `shift_schedules` ss ON ss.id = scr.shift_schedule_id
JOIN `employee_profiles` ep ON ep.user_id = ss.user_id
WHERE ep.employee_type IN ('PART_TIME', 'CASUAL')
  AND ss.shift_id IN (4, 5);

DELETE scr FROM `shift_change_requests` scr
JOIN `shift_schedules` ss ON ss.id = scr.target_shift_schedule_id
JOIN `employee_profiles` ep ON ep.user_id = ss.user_id
WHERE ep.employee_type IN ('PART_TIME', 'CASUAL')
  AND ss.shift_id IN (4, 5);

DELETE ss FROM `shift_schedules` ss
JOIN `employee_profiles` ep ON ep.user_id = ss.user_id
WHERE ep.employee_type IN ('PART_TIME', 'CASUAL')
  AND ss.shift_id IN (4, 5);

-- ------------------------------------------------------------
-- 3b. Sinh lịch cho 3 TUẦN: tuần hiện tại + 2 tuần kế tiếp.
--
-- Lý do: nhân viên cần xin nghỉ TRƯỚC cho các tuần sau, và
-- Store Manager cần lịch đã publish để duyệt đơn / đổi ca.
-- Mỗi tuần vẫn giữ đúng quy tắc T2/T4/T6/CN và T3/T5/T7.
--
-- @w = so tuần (0 = tuần hien tai).
-- Quy uoc moi tuan: n = 0 la Thu Hai, n = 6 la Chu Nhat.
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_weeks (w INT);
DELETE FROM tmp_weeks;
INSERT INTO tmp_weeks (w)
SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2;

-- Full-time: T2 -> T6, ca 4 (07:00-17:00)
INSERT INTO `shift_schedules`
    (`branch_id`, `user_id`, `shift_id`, `work_date`, `position_id`, `status`)
SELECT 1, 5, 4, DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY), 7, 'PUBLISHED'
FROM tmp_weeks w
JOIN (
    SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2
    UNION ALL SELECT 3 UNION ALL SELECT 4
) n
WHERE NOT EXISTS (
    SELECT 1 FROM `shift_schedules` s
    WHERE s.user_id = 5 AND s.shift_id = 4
      AND s.work_date = DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
);

-- Part-time 1: ca Tối (id 3), T2/T4/T6/CN
INSERT INTO `shift_schedules`
    (`branch_id`, `user_id`, `shift_id`, `work_date`, `position_id`, `status`)
SELECT 1, @pt1, 3, DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY), 7, 'PUBLISHED'
FROM tmp_weeks w
JOIN (
    SELECT 0 AS n UNION ALL SELECT 2 UNION ALL SELECT 4 UNION ALL SELECT 6
) n
WHERE NOT EXISTS (
    SELECT 1 FROM `shift_schedules` s
    WHERE s.user_id = @pt1 AND s.shift_id = 3
      AND s.work_date = DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
);

-- Part-time 2: ca Sáng (id 1), T3/T5/T7
INSERT INTO `shift_schedules`
    (`branch_id`, `user_id`, `shift_id`, `work_date`, `position_id`, `status`)
SELECT 1, @pt2, 1, DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY), 7, 'PUBLISHED'
FROM tmp_weeks w
JOIN (
    SELECT 1 AS n UNION ALL SELECT 3 UNION ALL SELECT 5
) n
WHERE NOT EXISTS (
    SELECT 1 FROM `shift_schedules` s
    WHERE s.user_id = @pt2 AND s.shift_id = 1
      AND s.work_date = DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
);

DROP TEMPORARY TABLE IF EXISTS tmp_weeks;

-- ------------------------------------------------------------
-- 4. Định mức nhân sự (shift_requirements)
--    Dùng để demo cảnh báo "thiếu người" khi Store Manager duyệt đơn.
--    Cũng phủ 3 tuần như lịch làm việc.
-- ------------------------------------------------------------
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_weeks2 (w INT);
DELETE FROM tmp_weeks2;
INSERT INTO tmp_weeks2 (w)
SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2;

INSERT INTO `shift_requirements`
    (`branch_id`, `position_id`, `shift_id`, `required_count`, `work_date`)
SELECT 1, 7, 3, 2, DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
FROM tmp_weeks2 w
JOIN (
    SELECT 0 AS n UNION ALL SELECT 2 UNION ALL SELECT 4 UNION ALL SELECT 6
) n
WHERE NOT EXISTS (
    SELECT 1 FROM `shift_requirements` r
    WHERE r.branch_id = 1 AND r.shift_id = 3
      AND r.work_date = DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
);

INSERT INTO `shift_requirements`
    (`branch_id`, `position_id`, `shift_id`, `required_count`, `work_date`)
SELECT 1, 7, 1, 2, DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
FROM tmp_weeks2 w
JOIN (
    SELECT 1 AS n UNION ALL SELECT 3 UNION ALL SELECT 5
) n
WHERE NOT EXISTS (
    SELECT 1 FROM `shift_requirements` r
    WHERE r.branch_id = 1 AND r.shift_id = 1
      AND r.work_date = DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
);

INSERT INTO `shift_requirements`
    (`branch_id`, `position_id`, `shift_id`, `required_count`, `work_date`)
SELECT 1, 7, 4, 3, DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
FROM tmp_weeks2 w
JOIN (
    SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2
    UNION ALL SELECT 3 UNION ALL SELECT 4
) n
WHERE NOT EXISTS (
    SELECT 1 FROM `shift_requirements` r
    WHERE r.branch_id = 1 AND r.shift_id = 4
      AND r.work_date = DATE_ADD(DATE_ADD(@mon, INTERVAL w.w WEEK), INTERVAL n.n DAY)
);

DROP TEMPORARY TABLE IF EXISTS tmp_weeks2;

-- ------------------------------------------------------------
-- 5. Kết quả
-- ------------------------------------------------------------
SELECT '--- Nhan vien part-time ---' AS '';
SELECT user_id, full_name, employee_type, shift_type, standard_hours_per_day
FROM `employee_profiles`
WHERE employee_type IN ('PART_TIME', 'CASUAL');

SELECT '--- Lich lam viec ---' AS '';
SELECT ss.user_id, ep.full_name, ss.work_date, s.name AS shift_name,
       TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time) / 60 AS hours, ss.status
FROM `shift_schedules` ss
JOIN `shifts` s ON s.id = ss.shift_id
JOIN `employee_profiles` ep ON ep.user_id = ss.user_id
ORDER BY ss.user_id, ss.work_date;
