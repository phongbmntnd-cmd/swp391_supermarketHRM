-- Bảng lưu các nhân viên được "mượn" cho từng đề xuất điều chuyển tạm thời.
-- Thiếu bảng này khiến ShiftScheduleDAO.canAssign() và isLockedForTransfer()
-- ném SQLException mỗi khi Store Manager xếp ca.
--
-- Chạy: mysql -u root -p swp391_supermarket < migration_temporary_transfer_employees.sql

CREATE TABLE IF NOT EXISTS `temporary_transfer_employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transfer_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'RESERVED',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_transfer_employee` (`transfer_id`,`employee_id`),
  KEY `idx_transfer_employee_user` (`employee_id`),
  CONSTRAINT `fk_transfer_employee_request` FOREIGN KEY (`transfer_id`) REFERENCES `temporary_transfers` (`id`),
  CONSTRAINT `fk_transfer_employee_user` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
