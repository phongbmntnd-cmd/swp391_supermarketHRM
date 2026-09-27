-- =============================================
-- CHẠY FILE NÀY TRONG MYSQL ĐỂ TẠO BẢNG
-- =============================================

CREATE TABLE IF NOT EXISTS audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(50) NOT NULL COMMENT 'Hành động: EMERGENCY_LOCK, EMERGENCY_UNLOCK',
    actor_id INT NOT NULL COMMENT 'Người thực hiện',
    target_user_id INT NOT NULL COMMENT 'User bị ảnh hưởng',
    description VARCHAR(500) COMMENT 'Mô tả thêm (lý do)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_actor (actor_id),
    INDEX idx_target (target_user_id),
    INDEX idx_action (action),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS employee_locks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT 'User bị khóa',
    locked_by INT NOT NULL COMMENT 'Store Manager thực hiện khóa',
    unlocked_by INT COMMENT 'Store Manager thực hiện mở khóa',
    reason VARCHAR(500) COMMENT 'Lý do khóa',
    locked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unlocked_at TIMESTAMP COMMENT 'Thời gian mở khóa',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'TRUE = đang bị khóa, FALSE = đã mở khóa',
    INDEX idx_user (user_id),
    INDEX idx_locked_by (locked_by),
    INDEX idx_unlocked_by (unlocked_by),
    INDEX idx_is_active (is_active),
    INDEX idx_locked_at (locked_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
