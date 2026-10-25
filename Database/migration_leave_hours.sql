-- ============================================================
-- MIGRATION: Nghỉ phép theo mô hình "C trên nền B"
--   B = đơn vị đo chuẩn là GIỜ (khớp với salary_rules.hourly_rate)
--   C = mỗi đơn nghỉ gắn với danh sách CA cụ thể bị ảnh hưởng
--
-- Thay đổi:
--   1. employee_profiles.standard_hours_per_day
--        - FULL_TIME = 10 (Ca Full-time 07:00-17:00 / 12:00-22:00)
--        - PART_TIME = 5  (Ca Sáng / Chiều / Tối)
--   2. leave_balances.total_hours / used_hours  (đơn vị đo mới)
--        - Giữ total_days / used_days để tương thích ngược & lịch sử
--   3. leave_requests.total_hours  (giờ nghỉ thực tế của đơn)
--        - Giữ total_days để tương thích ngược
--   4. leave_types.notice_hours_part_time  (hạn gửi riêng cho part-time)
--   5. Bảng mới leave_request_shifts  (chi tiết ca của từng đơn)
--
-- Migration idempotent - chạy lại nhiều lần vẫn an toàn.
-- ============================================================

DROP PROCEDURE IF EXISTS `sp_leave_hours_migration`;

DELIMITER $$

CREATE PROCEDURE `sp_leave_hours_migration`()
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- ------------------------------------------------------------
    -- 1. employee_profiles.standard_hours_per_day
    -- ------------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'employee_profiles'
      AND COLUMN_NAME  = 'standard_hours_per_day';

    IF v_exists = 0 THEN
        ALTER TABLE `employee_profiles`
            ADD COLUMN `standard_hours_per_day`
                decimal(5,2) NOT NULL DEFAULT 10.00
                AFTER `shift_type`;
    END IF;

    -- Gán giá trị theo loại nhân viên (chỉ 1 lần, không ghi đè nếu
    -- người dùng đã chỉnh tay).
    UPDATE `employee_profiles`
    SET `standard_hours_per_day` = 10.00
    WHERE `employee_type` = 'FULL_TIME'
      AND (`standard_hours_per_day` IS NULL OR `standard_hours_per_day` = 0);

    UPDATE `employee_profiles`
    SET `standard_hours_per_day` = 5.00
    WHERE `employee_type` IN ('PART_TIME', 'CASUAL')
      AND (`standard_hours_per_day` IS NULL OR `standard_hours_per_day` = 0);

    -- ------------------------------------------------------------
    -- 2. leave_balances.total_hours / used_hours
    -- ------------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_balances'
      AND COLUMN_NAME  = 'total_hours';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_balances`
            ADD COLUMN `total_hours` decimal(8,2) DEFAULT NULL
            AFTER `total_days`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_balances'
      AND COLUMN_NAME  = 'used_hours';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_balances`
            ADD COLUMN `used_hours` decimal(8,2) DEFAULT NULL
            AFTER `used_days`;
    END IF;

    -- Quy đổi quota cũ (ngày) sang giờ dựa trên định mức của nhân viên.
    -- total_days = 0  => loại nghỉ không giới hạn => total_hours = 0.
    UPDATE `leave_balances` lb
    JOIN `employee_profiles` ep ON ep.user_id = lb.user_id
    SET lb.total_hours = lb.total_days * ep.standard_hours_per_day
    WHERE lb.total_hours IS NULL;

    UPDATE `leave_balances` lb
    JOIN `employee_profiles` ep ON ep.user_id = lb.user_id
    SET lb.used_hours = lb.used_days * ep.standard_hours_per_day
    WHERE lb.used_hours IS NULL;

    -- ------------------------------------------------------------
    -- 3. leave_requests.total_hours
    -- ------------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_requests'
      AND COLUMN_NAME  = 'total_hours';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD COLUMN `total_hours` decimal(8,2) DEFAULT NULL
            AFTER `total_days`;
    END IF;

    -- Quy đổi đơn cũ sang giờ theo định mức nhân viên.
    UPDATE `leave_requests` lr
    JOIN `employee_profiles` ep ON ep.user_id = lr.user_id
    SET lr.total_hours = lr.total_days * ep.standard_hours_per_day
    WHERE lr.total_hours IS NULL;

    -- ------------------------------------------------------------
    -- 4. leave_types.notice_hours_part_time
    -- ------------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_types'
      AND COLUMN_NAME  = 'notice_hours_part_time';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_types`
            ADD COLUMN `notice_hours_part_time` int NOT NULL DEFAULT 48
            AFTER `notice_hours`;
    END IF;

    -- Hạn gửi riêng cho part-time:
    --   Part-time báo trước TỐI THIỂU 48 giờ (2 ngày) cho nghỉ phép
    --   năm và nghỉ không lương - giống như full-time.
    --   Loại khác giữ nguyên theo quy định riêng.
    UPDATE `leave_types` SET `notice_hours_part_time` = 48  WHERE `code` = 'ANNUAL';
    UPDATE `leave_types` SET `notice_hours_part_time` = 48  WHERE `code` = 'UNPAID';
    UPDATE `leave_types` SET `notice_hours_part_time` = 4   WHERE `code` = 'SICK';
    UPDATE `leave_types` SET `notice_hours_part_time` = 0   WHERE `code` = 'FUNERAL';

    -- ------------------------------------------------------------
    -- 5. Bảng mới leave_request_shifts
    --    Chi tiết ca bị ảnh hưởng bởi mỗi đơn nghỉ.
    --    hours/ shift_name được snapshot tại thời điểm tạo đơn để
    --    lịch sử không bị ảnh hưởng khi ca được sửa sau này.
    -- ------------------------------------------------------------
    CREATE TABLE IF NOT EXISTS `leave_request_shifts` (
        `id` int NOT NULL AUTO_INCREMENT,
        `leave_request_id` int NOT NULL,
        `work_date` date NOT NULL,
        `shift_id` int NOT NULL,
        `shift_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
        `hours` decimal(5,2) NOT NULL DEFAULT 0,
        PRIMARY KEY (`id`),
        KEY `idx_lrs_request` (`leave_request_id`),
        KEY `idx_lrs_user_date` (`work_date`, `shift_id`),
        CONSTRAINT `leave_request_shifts_ibfk_1`
            FOREIGN KEY (`leave_request_id`) REFERENCES `leave_requests` (`id`)
            ON DELETE CASCADE,
        CONSTRAINT `leave_request_shifts_ibfk_2`
            FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    -- ------------------------------------------------------------
    -- 6. open_shifts.leave_request_id
    --    Liên kết ca trống được SINH RA từ một đơn nghỉ phép.
    --    Nhờ cột này, khi hủy đơn ta chỉ đóng đúng những ca trống
    --    do đơn đó tạo ra, không đụng tới ca trống Store Manager tự tạo.
    -- ------------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'open_shifts'
      AND COLUMN_NAME  = 'leave_request_id';

    IF v_exists = 0 THEN
        ALTER TABLE `open_shifts`
            ADD COLUMN `leave_request_id` int DEFAULT NULL AFTER `status`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'open_shifts'
      AND COLUMN_NAME  = 'leave_request_id';

    IF v_exists = 0 THEN
        ALTER TABLE `open_shifts`
            ADD INDEX `leave_request_id` (`leave_request_id`);
    END IF;

    -- ------------------------------------------------------------
    -- 7. Đơn cũ chưa có chi tiết ca: sinh lại từ lịch làm việc nếu có,
    --    nếu không thì để NULL (hệ thống sẽ fallback về công thức ngày).
    -- ------------------------------------------------------------
    INSERT INTO `leave_request_shifts`
        (`leave_request_id`, `work_date`, `shift_id`, `shift_name`, `hours`)
    SELECT lr.id,
           ss.work_date,
           ss.shift_id,
           s.name,
           (HOUR(s.end_time) * 60 + MINUTE(s.end_time)
            - HOUR(s.start_time) * 60 - MINUTE(s.start_time)) / 60.0
    FROM `leave_requests` lr
    JOIN `shift_schedules` ss
      ON ss.user_id = lr.user_id
     AND ss.work_date BETWEEN lr.start_date AND lr.end_date
     AND ss.status IN ('PUBLISHED', 'ON_LEAVE')
    JOIN `shifts` s ON s.id = ss.shift_id
    WHERE NOT EXISTS (
        SELECT 1 FROM `leave_request_shifts` x
        WHERE x.leave_request_id = lr.id
    );
END$$

DELIMITER ;

CALL `sp_leave_hours_migration`();

DROP PROCEDURE IF EXISTS `sp_leave_hours_migration`;
