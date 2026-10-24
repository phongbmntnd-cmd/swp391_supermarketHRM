-- ============================================================
-- MIGRATION: Bổ sung cột cho bảng leave_requests
-- DAO LeaveRequestDAO sử dụng các cột:
--   leave_type_id, total_days, manager_response,
--   reviewed_by, reviewed_at, created_at
-- và status có thêm giá trị 'CANCELLED'
--
-- MySQL 8.0 không hỗ trợ "ADD COLUMN IF NOT EXISTS" nên
-- dùng procedure trợ giúp. Migration idempotent.
-- ============================================================

DROP PROCEDURE IF EXISTS `sp_leave_requests_migration`;

DELIMITER $$

CREATE PROCEDURE `sp_leave_requests_migration`()
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- 1. Thêm cột mới nếu chưa có
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_requests'
      AND COLUMN_NAME  = 'leave_type_id';

    IF v_exists = 0 THEN
        -- Cột bắt buộc nhưng dữ liệu cũ có thể NULL ->
        -- thêm nullable trước, gán giá trị mặc định sau.
        ALTER TABLE `leave_requests`
            ADD COLUMN `leave_type_id` int DEFAULT NULL
            AFTER `user_id`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_requests'
      AND COLUMN_NAME  = 'total_days';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD COLUMN `total_days` int DEFAULT 0 AFTER `end_date`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_requests'
      AND COLUMN_NAME  = 'manager_response';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD COLUMN `manager_response` varchar(255) DEFAULT NULL
            AFTER `status`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_requests'
      AND COLUMN_NAME  = 'reviewed_by';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD COLUMN `reviewed_by` int DEFAULT NULL
            AFTER `manager_response`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_requests'
      AND COLUMN_NAME  = 'reviewed_at';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD COLUMN `reviewed_at` timestamp NULL DEFAULT NULL
            AFTER `reviewed_by`;
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_requests'
      AND COLUMN_NAME  = 'created_at';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD COLUMN `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
            AFTER `reviewed_at`;
    END IF;

    -- 2. Gán leave_type_id mặc định cho dữ liệu cũ (nếu có)
    UPDATE `leave_requests` lr
    SET lr.leave_type_id = (
        SELECT MIN(lt.id) FROM `leave_types` lt
    )
    WHERE lr.leave_type_id IS NULL;

    -- 3. total_days cho dữ liệu cũ: tính số ngày inclusive
    UPDATE `leave_requests`
    SET total_days = DATEDIFF(end_date, start_date) + 1
    WHERE total_days IS NULL OR total_days = 0;

    -- 4. Cho phép giá trị 'CANCELLED' trong status
    ALTER TABLE `leave_requests`
        MODIFY COLUMN `status`
            enum('PENDING','APPROVED','REJECTED','CANCELLED')
            CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
            DEFAULT 'PENDING';

    -- 5. Không null cho các cột bắt buộc
    ALTER TABLE `leave_requests`
        MODIFY COLUMN `leave_type_id` int NOT NULL;

    ALTER TABLE `leave_requests`
        MODIFY COLUMN `total_days` int NOT NULL DEFAULT 0;

    -- 6. Index + Foreign key
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_requests'
      AND COLUMN_NAME  = 'leave_type_id';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD INDEX `leave_type_id` (`leave_type_id`);
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME      = 'leave_requests'
      AND CONSTRAINT_NAME = 'leave_requests_ibfk_2'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD CONSTRAINT `leave_requests_ibfk_2`
                FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`id`);
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME      = 'leave_requests'
      AND CONSTRAINT_NAME = 'leave_requests_ibfk_3'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_requests`
            ADD CONSTRAINT `leave_requests_ibfk_3`
                FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`);
    END IF;
END$$

DELIMITER ;

CALL `sp_leave_requests_migration`();

DROP PROCEDURE IF EXISTS `sp_leave_requests_migration`;
