-- =====================================================
-- SQL Migration cho Đạt 2 - Store Manager
-- Bước 3 - Employee List với Search/Filter/Sort/Pagination
-- =====================================================

-- =====================================================
-- 0. KIỂM TRA VÀ BỔ SUNG INDEX CHO PERFORMANCE
-- =====================================================

-- Index cho employee_profiles - tối ưu query theo branch
-- Chạy từng dòng nếu chưa có index
-- ALTER TABLE employee_profiles ADD INDEX idx_home_branch (home_branch_id);

-- Index cho users - tối ưu query theo status và role
-- ALTER TABLE users ADD INDEX idx_status (status);
-- ALTER TABLE users ADD INDEX idx_role_id (role_id);

-- =====================================================
-- 1. THAY ĐỔI BẢNG users - Thêm EMERGENCY_LOCKED
-- =====================================================

-- Bước 1a: Kiểm tra cấu trúc hiện tại của bảng users
-- DESCRIBE users;

-- Bước 1b: Nếu cột status là ENUM('ACTIVE'), cần ALTER:
-- ALTER TABLE users MODIFY COLUMN status ENUM('ACTIVE', 'EMERGENCY_LOCKED', 'INACTIVE') DEFAULT 'ACTIVE';

-- Bước 1c: Nếu cột status là VARCHAR, kiểm tra xem có giá trị 'EMERGENCY_LOCKED' chưa
-- SELECT DISTINCT status FROM users;

-- Bước 1d: Nếu chưa có, không cần thay đổi vì VARCHAR cho phép thêm giá trị mới

-- =====================================================
-- 2. TẠO BẢNG audit_logs
-- =====================================================
-- Bảng này ghi log tất cả các thao tác Lock/Unlock

CREATE TABLE IF NOT EXISTS audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action VARCHAR(50) NOT NULL COMMENT 'EMERGENCY_LOCK, EMERGENCY_UNLOCK',
    actor_id INT NOT NULL COMMENT 'Người thực hiện hành động (FK → users.id)',
    target_user_id INT NOT NULL COMMENT 'User bị ảnh hưởng (FK → users.id)',
    description TEXT COMMENT 'Mô tả thêm (lý do lock/unlock)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_actor (actor_id),
    INDEX idx_target (target_user_id),
    INDEX idx_created (created_at),
    INDEX idx_action (action),
    
    CONSTRAINT fk_audit_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_audit_target FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. TẠO BẢNG employee_locks
-- =====================================================
-- Bảng này lưu trữ lịch sử Lock/Unlock chi tiết
-- Cần thiết để:
-- - Biết ai lock/unlock vào lúc nào
-- - Lưu lý do lock
-- - Theo dõi nhiều lần lock/unlock cho 1 user

CREATE TABLE IF NOT EXISTS employee_locks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL COMMENT 'User bị lock (FK → users.id)',
    locked_by INT NOT NULL COMMENT 'Store Manager thực hiện lock (FK → users.id)',
    unlocked_by INT NULL COMMENT 'Store Manager thực hiện unlock (FK → users.id, null nếu chưa unlock)',
    reason TEXT COMMENT 'Lý do lock',
    locked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unlocked_at TIMESTAMP NULL COMMENT 'Thời điểm unlock (null = đang bị lock)',
    is_active BOOLEAN DEFAULT TRUE COMMENT 'true = đang lock, false = đã unlock',
    
    INDEX idx_user (user_id),
    INDEX idx_locked_by (locked_by),
    INDEX idx_locked_at (locked_at),
    INDEX idx_is_active (is_active),
    INDEX idx_user_active (user_id, is_active),
    
    CONSTRAINT fk_lock_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_lock_by FOREIGN KEY (locked_by) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_unlock_by FOREIGN KEY (unlocked_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 4. TẠO STORED PROCEDURE ĐỂ THỰC HIỆN LOCK/UNLOCK AN TOÀN
-- =====================================================

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS sp_emergency_lock(
    IN p_user_id INT,
    IN p_locked_by INT,
    IN p_reason TEXT
)
BEGIN
    DECLARE v_current_status VARCHAR(50);
    DECLARE v_user_branch INT;
    DECLARE v_locked_by_branch INT;
    DECLARE v_error_msg VARCHAR(255);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get current status
    SELECT status INTO v_current_status FROM users WHERE id = p_user_id FOR UPDATE;
    
    -- Check if user exists
    IF v_current_status IS NULL THEN
        SET v_error_msg = 'Không tìm thấy nhân viên';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;
    
    -- Check if already locked
    IF v_current_status = 'EMERGENCY_LOCKED' THEN
        SET v_error_msg = 'Nhân viên đã bị khóa trước đó';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;
    
    -- Check self-lock
    IF p_user_id = p_locked_by THEN
        SET v_error_msg = 'Không thể tự khóa tài khoản của mình';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;
    
    -- Get branch of target user
    SELECT home_branch_id INTO v_user_branch FROM employee_profiles WHERE user_id = p_user_id;
    
    -- Get branch of Store Manager
    SELECT home_branch_id INTO v_locked_by_branch FROM employee_profiles WHERE user_id = p_locked_by;
    
    -- Check Local Scope
    IF v_user_branch != v_locked_by_branch THEN
        SET v_error_msg = 'Bạn không có quyền khóa nhân viên không thuộc cơ sở bạn quản lý';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;
    
    -- Update user status
    UPDATE users SET status = 'EMERGENCY_LOCKED' WHERE id = p_user_id;
    
    -- Insert audit log
    INSERT INTO audit_logs (action, actor_id, target_user_id, description)
    VALUES ('EMERGENCY_LOCK', p_locked_by, p_user_id, 
            CONCAT('Emergency Lock: ', COALESCE(p_reason, 'Không có lý do')));
    
    -- Insert lock record
    INSERT INTO employee_locks (user_id, locked_by, reason, is_active)
    VALUES (p_user_id, p_locked_by, p_reason, TRUE);
    
    -- Commit
    COMMIT;
    
END //

CREATE PROCEDURE IF NOT EXISTS sp_emergency_unlock(
    IN p_user_id INT,
    IN p_unlocked_by INT
)
BEGIN
    DECLARE v_current_status VARCHAR(50);
    DECLARE v_user_branch INT;
    DECLARE v_unlocked_by_branch INT;
    DECLARE v_error_msg VARCHAR(255);
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get current status
    SELECT status INTO v_current_status FROM users WHERE id = p_user_id FOR UPDATE;
    
    -- Check if user exists
    IF v_current_status IS NULL THEN
        SET v_error_msg = 'Không tìm thấy nhân viên';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;
    
    -- Check if not locked
    IF v_current_status != 'EMERGENCY_LOCKED' THEN
        SET v_error_msg = 'Nhân viên không bị khóa';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;
    
    -- Get branch of target user
    SELECT home_branch_id INTO v_user_branch FROM employee_profiles WHERE user_id = p_user_id;
    
    -- Get branch of Store Manager
    SELECT home_branch_id INTO v_unlocked_by_branch FROM employee_profiles WHERE user_id = p_unlocked_by;
    
    -- Check Local Scope
    IF v_user_branch != v_unlocked_by_branch THEN
        SET v_error_msg = 'Bạn không có quyền mở khóa nhân viên không thuộc cơ sở bạn quản lý';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;
    
    -- Update user status
    UPDATE users SET status = 'ACTIVE' WHERE id = p_user_id;
    
    -- Insert audit log
    INSERT INTO audit_logs (action, actor_id, target_user_id, description)
    VALUES ('EMERGENCY_UNLOCK', p_unlocked_by, p_user_id, 'Emergency Unlock');
    
    -- Update lock record
    UPDATE employee_locks 
    SET is_active = FALSE, unlocked_by = p_unlocked_by, unlocked_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id AND is_active = TRUE;
    
    -- Commit
    COMMIT;
    
END //

DELIMITER ;

-- =====================================================
-- 5. TẠO VIEW ĐỂ XEM LỊCH SỬ LOCK/UNLOCK
-- =====================================================

CREATE OR REPLACE VIEW v_employee_locks AS
SELECT 
    el.id,
    el.user_id,
    target_ep.full_name AS employee_name,
    el.locked_by,
    locked_ep.full_name AS locked_by_name,
    el.unlocked_by,
    unlocked_ep.full_name AS unlocked_by_name,
    el.reason,
    el.locked_at,
    el.unlocked_at,
    el.is_active,
    target_ep.home_branch_id AS branch_id
FROM employee_locks el
JOIN employee_profiles target_ep ON el.user_id = target_ep.user_id
JOIN employee_profiles locked_ep ON el.locked_by = locked_ep.user_id
LEFT JOIN employee_profiles unlocked_ep ON el.unlocked_by = unlocked_ep.user_id;

-- =====================================================
-- 6. DỮ LIỆU MẪU ĐỂ TEST (tùy chọn)
-- =====================================================

-- Xem audit logs:
-- SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT 10;

-- Xem lịch sử lock:
-- SELECT * FROM v_employee_locks ORDER BY locked_at DESC LIMIT 10;
