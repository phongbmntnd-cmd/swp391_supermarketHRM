-- ============================================================
--  MIGRATION: Mở rộng bảng audit_logs
--  Thêm cột entity_type / entity_id để định danh đối tượng bị tác động
--  (tài khoản, phòng ban, vị trí, vai trò...) thay vì chỉ dựa vào
--  target_user_id (chỉ dùng được cho tài khoản).
-- ============================================================

-- 1) Thêm cột entity_type (loại đối tượng)
SET @col_exists := (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'audit_logs'
      AND column_name = 'entity_type'
);
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE audit_logs ADD COLUMN entity_type VARCHAR(30) DEFAULT NULL AFTER target_user_id',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2) Thêm cột entity_id (id đối tượng trong bảng tương ứng)
SET @col_exists := (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'audit_logs'
      AND column_name = 'entity_id'
);
SET @sql := IF(@col_exists = 0,
    'ALTER TABLE audit_logs ADD COLUMN entity_id INT DEFAULT NULL AFTER entity_type',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 3) Index hỗ trợ lọc theo loại/id đối tượng
SET @idx_exists := (
    SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'audit_logs'
      AND index_name = 'idx_entity'
);
SET @sql := IF(@idx_exists = 0,
    'CREATE INDEX idx_entity ON audit_logs (entity_type, entity_id)',
    'DO 0');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 4) Backfill dữ liệu cũ: các log có target_user_id thuộc loại USER
UPDATE audit_logs
SET entity_type = 'USER', entity_id = target_user_id
WHERE entity_type IS NULL AND target_user_id IS NOT NULL;

-- 5) Backfill: các log đăng nhập / đăng xuất gắn với chính actor
UPDATE audit_logs
SET entity_type = 'USER', entity_id = actor_id
WHERE entity_type IS NULL
  AND actor_id IS NOT NULL
  AND action IN ('LOGIN', 'LOGOUT');

SELECT 'MIGRATION audit_logs: DONE' AS result;
