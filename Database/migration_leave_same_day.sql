-- ============================================================
-- MIGRATION: cột `same_day_allowed` cho bảng leave_types
--
-- MỤC ĐÍCH
--   1 = loại nghỉ được LÀM ĐƠN TRONG NGÀY, KHÔNG kiểm tra hạn báo trước
--       (nghỉ ốm, nghỉ tang)
--   0 = áp dụng hạn báo trước theo notice_hours (full-time)
--       hoặc notice_hours_part_time (part-time)
--
-- LUẬT "BÁO TRƯỚC" (sau khi migration này)
--   notice_hours = SỐ GIỜ TỐI THIỂU phải báo trước:
--     - Gửi SỚM thì vẫn OK (không giới hạn cửa sổ gửi đơn).
--     - Chỉ bị chặn khi gửi MUỘN hơn hạn.
--     - Hạn = cuối ngày (ngày nghỉ - ceil(notice_hours/24)).
--   notice_hours = 0  -> không kiểm tra hạn (gửi trong ngày được).
--
-- Script IDEMPOTENT - chạy lại nhiều lần vẫn an toàn.
-- Nếu bảng leave_types chưa tồn tại, chạy
-- Database/migration_leave_requests.sql TRƯỚC.
-- ============================================================

DROP PROCEDURE IF EXISTS `sp_leave_same_day_migration`;

DELIMITER $$

CREATE PROCEDURE `sp_leave_same_day_migration`()
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- ------------------------------------------------------------
    -- 1. Thêm cột same_day_allowed (nếu chưa có)
    -- ------------------------------------------------------------
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = 'leave_types'
      AND COLUMN_NAME  = 'same_day_allowed';

    IF v_exists = 0 THEN
        ALTER TABLE `leave_types`
            ADD COLUMN `same_day_allowed` tinyint(1) NOT NULL DEFAULT 0;
    END IF;

    -- ------------------------------------------------------------
    -- 2. Nghỉ ốm & nghỉ tang: làm đơn trong ngày, không validate hạn
    -- ------------------------------------------------------------
    UPDATE `leave_types`
    SET `same_day_allowed` = 1
    WHERE `code` IN ('SICK', 'FUNERAL', 'BEREAVEMENT');

    -- Các loại còn lại: áp dụng hạn báo trước
    UPDATE `leave_types`
    SET `same_day_allowed` = 0
    WHERE `code` NOT IN ('SICK', 'FUNERAL', 'BEREAVEMENT');

    -- ------------------------------------------------------------
    -- 3. Nghỉ tang: không giới hạn hạn báo trước (nhất quán với mục 2)
    -- ------------------------------------------------------------
    UPDATE `leave_types`
    SET `notice_hours` = 0,
        `notice_hours_part_time` = 0
    WHERE `code` IN ('FUNERAL', 'BEREAVEMENT');
END$$

DELIMITER ;

CALL `sp_leave_same_day_migration`();

DROP PROCEDURE IF EXISTS `sp_leave_same_day_migration`;

-- ------------------------------------------------------------
-- Kết quả
-- ------------------------------------------------------------
SELECT id, code, name, notice_hours, notice_hours_part_time, same_day_allowed
FROM `leave_types`
ORDER BY id;
