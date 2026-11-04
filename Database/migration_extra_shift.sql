-- ============================================================
-- MIGRATION: tính năng "Nhận ca làm thêm" (EXTRA SHIFT)
--
-- MỤC ĐÍCH
--   Cho phép nhân viên xem các ca trống của tuần (do đồng nghiệp
--   nghỉ phép, nghỉ tang, ốm...) và ĐĂNG KÝ NHẬN THÊM ca đó.
--   Khác với tính năng "Chuyển sang ca trống" (request_type='OPEN'):
--   - OPEN  : nhân viên MẤT ca cũ, được chuyển sang ca trống.
--   - EXTRA : nhân viên GIỮ NGUYÊN lịch cũ, chỉ được THÊM ca trống.
--
--   Khi Store duyệt đơn EXTRA:
--   1. Tạo bản ghi mới trong `shift_schedules` (status='PUBLISHED')
--      cho nhân viên đó tại ca trống đã nhận.
--   2. Đóng ca trống tương ứng trong `open_shifts`.
--   Lịch cũ của nhân viên KHÔNG bị thay đổi.
--
-- THAY ĐỔI CẦN THỰC HIỆN
--   1. Thêm giá trị 'EXTRA' vào enum `request_type`.
--   2. Cho phép `shift_schedule_id` NULL: đơn EXTRA không đi kèm
--      ca cũ nào (nhân viên không mất ca nào), nên không có
--      `shift_schedule_id` để trỏ tới.
--
-- SCRIPT IDEMPOTENT - chạy lại nhiều lần vẫn an toàn.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Thêm 'EXTRA' vào enum request_type
-- ------------------------------------------------------------
-- Kiểm tra xem 'EXTRA' đã có chưa.
SET @has_extra := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'shift_change_requests'
    AND COLUMN_NAME = 'request_type'
    AND COLUMN_TYPE LIKE '%EXTRA%'
);

SET @sql1 := IF(@has_extra > 0,
  'DO 1',
  'ALTER TABLE `shift_change_requests` MODIFY COLUMN `request_type` enum(''SWAP'',''OPEN'',''EXTRA'') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ''SWAP''');

PREPARE stmt1 FROM @sql1;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

-- ------------------------------------------------------------
-- 2. Cho phép shift_schedule_id NULL
--    (đơn EXTRA không có ca cũ)
-- ------------------------------------------------------------
SET @has_nullable := (
  SELECT IS_NULLABLE FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'shift_change_requests'
    AND COLUMN_NAME = 'shift_schedule_id'
);

SET @sql2 := IF(@has_nullable = 'NO',
  'ALTER TABLE `shift_change_requests` MODIFY COLUMN `shift_schedule_id` int DEFAULT NULL',
  'DO 1');

PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- ------------------------------------------------------------
-- 3. Kết quả
-- ------------------------------------------------------------
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'shift_change_requests'
  AND COLUMN_NAME IN ('request_type', 'shift_schedule_id');

SELECT id, requester_id, request_type, shift_schedule_id,
       open_shift_id, status
FROM `shift_change_requests`
ORDER BY id DESC
LIMIT 10;
