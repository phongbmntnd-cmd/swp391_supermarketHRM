-- ============================================================
-- MIGRATION: Bổ sung cột cho bảng shift_change_requests
-- DAO ShiftChangeRequestDAO sử dụng các cột:
--   request_type, target_shift_schedule_id, open_shift_id
--
-- Chạy 1 lần trên DB đã có dữ liệu.
-- MySQL 8.0 không hỗ trợ "ADD COLUMN IF NOT EXISTS" /
-- "DROP FOREIGN KEY IF EXISTS", nên dùng procedure trợ giúp.
-- Migration này idempotent: chạy lại nhiều lần vẫn an toàn.
-- ============================================================

DROP PROCEDURE IF EXISTS `sp_shift_change_requests_migration`;

DELIMITER $$

CREATE PROCEDURE `sp_shift_change_requests_migration`()
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- ---------------------------------------------------------
    -- 1. Thêm các cột mới nếu chưa có
    -- ---------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'shift_change_requests'
      AND COLUMN_NAME  = 'request_type';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD COLUMN `request_type`
                enum('SWAP','OPEN')
                CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
                NOT NULL DEFAULT 'SWAP' AFTER `shift_schedule_id`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'shift_change_requests'
      AND COLUMN_NAME  = 'target_shift_schedule_id';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD COLUMN `target_shift_schedule_id` int DEFAULT NULL
            AFTER `request_type`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'shift_change_requests'
      AND COLUMN_NAME  = 'open_shift_id';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD COLUMN `open_shift_id` int DEFAULT NULL
            AFTER `target_shift_schedule_id`;
    END IF;

    -- ---------------------------------------------------------
    -- 1b. Cột cho phản hồi của đồng nghiệp
    --     (đồng nghiệp B trả lời đơn đổi ca của A)
    -- ---------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'shift_change_requests'
      AND COLUMN_NAME  = 'colleague_response';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD COLUMN `colleague_response` varchar(255)
                CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
                DEFAULT NULL
            AFTER `response`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'shift_change_requests'
      AND COLUMN_NAME  = 'colleague_responded_at';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD COLUMN `colleague_responded_at` datetime DEFAULT NULL
            AFTER `colleague_response`;
    END IF;

    -- ---------------------------------------------------------
    -- 1c. Mở rộng ENUM status
    --     Luồng đổi ca đầy đủ cần các trạng thái:
    --       WAITING_COLLEAGUE -> đợi đồng nghiệp trả lời
    --       PENDING           -> chờ Store Manager duyệt
    --       APPROVED/REJECTED -> quyết định của Store Manager
    --       DECLINED         -> đồng nghiệp từ chối
    --       CANCELLED        -> người gửi tự hủy
    --     DB cũ chỉ có ('PENDING','APPROVED','REJECTED') nên
    --     INSERT 'WAITING_COLLEAGUE' bị lỗi "Data truncated".
    -- ---------------------------------------------------------
    ALTER TABLE `shift_change_requests`
        MODIFY COLUMN `status`
            enum('WAITING_COLLEAGUE','PENDING','APPROVED',
                 'REJECTED','DECLINED','CANCELLED')
            CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
            NOT NULL DEFAULT 'WAITING_COLLEAGUE';

    -- ---------------------------------------------------------
    -- 2. target_user_id cho phép NULL
    --    (đơn OPEN không có đồng nghiệp đích)
    -- ---------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME      = 'shift_change_requests'
      AND CONSTRAINT_NAME = 'shift_change_requests_ibfk_2'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    IF v_exists > 0 THEN
        ALTER TABLE `shift_change_requests`
            DROP FOREIGN KEY `shift_change_requests_ibfk_2`;
    END IF;

    ALTER TABLE `shift_change_requests`
        MODIFY COLUMN `target_user_id` int DEFAULT NULL;

    ALTER TABLE `shift_change_requests`
        ADD CONSTRAINT `shift_change_requests_ibfk_2`
            FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`);

    -- ---------------------------------------------------------
    -- 3. Index cho các cột mới
    -- ---------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'shift_change_requests'
      AND COLUMN_NAME  = 'target_shift_schedule_id';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD INDEX `target_shift_schedule_id` (`target_shift_schedule_id`);
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'shift_change_requests'
      AND COLUMN_NAME  = 'open_shift_id';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD INDEX `open_shift_id` (`open_shift_id`);
    END IF;

    -- ---------------------------------------------------------
    -- 4. Foreign key cho các cột mới
    -- ---------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME      = 'shift_change_requests'
      AND CONSTRAINT_NAME = 'shift_change_requests_ibfk_4'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD CONSTRAINT `shift_change_requests_ibfk_4`
                FOREIGN KEY (`target_shift_schedule_id`)
                REFERENCES `shift_schedules` (`id`);
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME      = 'shift_change_requests'
      AND CONSTRAINT_NAME = 'shift_change_requests_ibfk_5'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    IF v_exists = 0 THEN
        ALTER TABLE `shift_change_requests`
            ADD CONSTRAINT `shift_change_requests_ibfk_5`
                FOREIGN KEY (`open_shift_id`)
                REFERENCES `open_shifts` (`id`);
    END IF;
END$$

DELIMITER ;

CALL `sp_shift_change_requests_migration`();

DROP PROCEDURE IF EXISTS `sp_shift_change_requests_migration`;
