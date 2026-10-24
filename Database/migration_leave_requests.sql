-- ============================================================
-- MIGRATION: Bổ sung cột cho bảng leave_requests
-- DAO LeaveRequestDAO sử dụng các cột:
--   leave_type_id, total_days, manager_response,
--   reviewed_by, reviewed_at, created_at
-- và status có thêm giá trị 'CANCELLED'
--
-- DAO LeaveTypeDAO / LeaveBalanceDAO cần 2 bảng:
--   leave_types, leave_balances
-- (được tạo ở phần 0 bên dưới nếu chưa tồn tại)
--
-- MySQL 8.0 không hỗ trợ "ADD COLUMN IF NOT EXISTS" nên
-- dùng procedure trợ giúp. Migration idempotent.
-- ============================================================

-- ------------------------------------------------------------
-- 0. Tạo bảng leave_types và leave_balances nếu chưa có
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `leave_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default_days` int NOT NULL DEFAULT 0,
  `paid_leave` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_leave_types_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `leave_balances` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `leave_type_id` int NOT NULL,
  `year` int NOT NULL,
  `total_days` int NOT NULL DEFAULT 0,
  `used_days` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_leave_balances` (`user_id`,`leave_type_id`,`year`),
  KEY `leave_balances_leave_type_id` (`leave_type_id`),
  CONSTRAINT `leave_balances_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `leave_balances_ibfk_2` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dữ liệu loại nghỉ phép mặc định
INSERT IGNORE INTO `leave_types`
  (`code`, `name`, `description`, `default_days`, `paid_leave`)
VALUES
  ('ANNUAL',   'Nghỉ phép năm',       'Nghỉ phép hằng năm theo chính sách công ty', 12, 1),
  ('SICK',     'Nghỉ ốm',            'Nghỉ do bệnh, có giấy từ bác sĩ',              8,  1),
  ('UNPAID',   'Nghỉ không phép lương','Nghỉ việc riêng không hưởng lương',            0,  0),
  ('BEREAVEMENT','Nghỉ tang',         'Nghỉ tang gia đình',                            5,  1),
  ('MATERNITY','Nghỉ thai sản',      'Nghỉ thai sản theo quy định',                    0,  1);

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
