-- ============================================================
-- MIGRATION: bảng supplementary_shift_opportunities +
--            bảng supplementary_shift_applications
--
-- MỤC ĐÍCH
--   Tính năng "Xếp lịch & Phân ca" của Store Manager gọi
--   SupplementaryShiftDAO.getApplicants() và
--   SupplementaryShiftDAO.isSupplementaryOpened().
--   Hai hàm này truy vấn bảng `supplementary_shift_opportunities`
--   và `supplementary_shift_applications`.
--
--   Nếu 2 bảng này chưa tồn tại trong database thì trang
--   /store-manager/schedule trả về lỗi 500 (SQLException:
--   Table 'swp391_supermarket.supplementary_shift_opportunities'
--   doesn't exist) và KHÔNG hiển thị được bảng xếp lịch.
--
--   - supplementary_shift_opportunities: ca thiếu nhân sự mà
--     Store Manager mở đăng ký bổ sung cho Part-time/Casual.
--   - supplementary_shift_applications: các đơn nhân viên
--     part-time đăng ký vào ca bổ sung đó.
--
-- SCRIPT IDEMPOTENT - chạy lại nhiều lần vẫn an toàn.
-- Nếu database đã được tạo từ file Database/databasenewproject.sql
-- (bản dump mới nhất) thì 2 bảng này đã có sẵn, script sẽ
-- báo "đã tồn tại" và không làm gì thêm.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Bảng ca bổ sung (phải tạo TRƯỚC vì bảng 2 có FK trỏ tới)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `supplementary_shift_opportunities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_id` int NOT NULL,
  `position_id` int NOT NULL,
  `shift_id` int NOT NULL,
  `work_date` date NOT NULL,
  `registration_deadline` datetime NOT NULL,
  `opened_by` int NOT NULL,
  `status` enum('OPEN','CLOSED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OPEN',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_supplementary_opportunity` (`branch_id`,`position_id`,`shift_id`,`work_date`),
  KEY `idx_supplementary_deadline` (`status`,`registration_deadline`),
  KEY `fk_supplementary_position` (`position_id`),
  KEY `fk_supplementary_shift` (`shift_id`),
  KEY `fk_supplementary_opened_by` (`opened_by`),
  CONSTRAINT `fk_supplementary_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_supplementary_opened_by` FOREIGN KEY (`opened_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_supplementary_position` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`),
  CONSTRAINT `fk_supplementary_shift` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. Bảng đơn đăng ký ca bổ sung
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `supplementary_shift_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `opportunity_id` int NOT NULL,
  `user_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_supplementary_application` (`opportunity_id`,`user_id`),
  KEY `fk_supplementary_application_user` (`user_id`),
  CONSTRAINT `fk_supplementary_application_opportunity` FOREIGN KEY (`opportunity_id`) REFERENCES `supplementary_shift_opportunities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_supplementary_application_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 3. Kết quả
-- ------------------------------------------------------------
SELECT id, branch_id, position_id, shift_id, work_date, status
FROM `supplementary_shift_opportunities`
ORDER BY id;

SELECT id, opportunity_id, user_id, created_at
FROM `supplementary_shift_applications`
ORDER BY id;
