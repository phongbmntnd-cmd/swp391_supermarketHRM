-- =====================================================================
--  DATABASE TONG HOP - swp391_supermarket (SUPERMARKET HRM)
--
--  File nay la ban tong hop cua TOAN BO thu muc Database/
--  (1 file schema goc + 9 file migration + 2 file seed),
--  duoc trich xuat lai tu database dang chay nen DA CHUA TOAN BO
--  migration (khong can chay them script nao).
--
--  SCHEMA : 36 bang + 1 view (v_employee_locks)
--            Da bao gom cac migration:
--              - audit_logs.entity_type / entity_id
--              - shift_change_requests.request_type = SWAP/OPEN/EXTRA
--                va shift_schedule_id cho phep NULL
--              - leave_types.notice_hours / notice_hours_part_time /
--                same_day_allowed
--              - leave_request_shifts (chi tiet ca cua don nghi)
--              - open_shifts.leave_request_id
--              - supplementary_shift_opportunities /
--                supplementary_shift_applications
--              - temporary_transfer_employees
--
--  DU LIEU : da loai bo toan bo du lieu TEST
--              (tai khoan test_nv_a / test_nv_b va cac ban ghi lien quan)
--
--  CACH DUNG:
--    mysql -u root -p -e "CREATE DATABASE swp391_supermarket
--      CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
--    mysql -u root -p --default-character-set=utf8mb4 \
--      swp391_supermarket < swp391_supermarket_full.sql
--
--  Tai khoan mac dinh (mat khau: 123456):
--    admin_user (Admin) | director_user (Director) | hrm_user (HR)
--    sm_user, sm2_user, sm3_user (Store Manager)
--    emp_user, pt_user1, pt_user2 (Employee)
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- ======================= PHAN 1: SCHEMA =======================

-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: swp391_supermarket
-- ------------------------------------------------------
-- Server version	8.0.46
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attendances`
--

DROP TABLE IF EXISTS `attendances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendances` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `shift_schedule_id` int NOT NULL,
  `check_in` datetime DEFAULT NULL,
  `check_out` datetime DEFAULT NULL,
  `method` enum('WIFI','DYNAMIC_QR') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('VALID','INVALID','ADJUSTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'VALID',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `shift_schedule_id` (`shift_schedule_id`),
  CONSTRAINT `attendances_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `attendances_ibfk_2` FOREIGN KEY (`shift_schedule_id`) REFERENCES `shift_schedules` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `actor_id` int DEFAULT NULL,
  `target_user_id` int DEFAULT NULL,
  `entity_type` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Mã chi nhánh',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('ACTIVE','INACTIVE','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `store_manager_id` int DEFAULT NULL COMMENT 'Chỉ định Store Manager phụ trách',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `store_manager_id` (`store_manager_id`),
  CONSTRAINT `branches_ibfk_1` FOREIGN KEY (`store_manager_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `candidates`
--

DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identity_card` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `certificates`
--

DROP TABLE IF EXISTS `certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Ví dụ: Chứng chỉ ATVSTP',
  `issued_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `certificates_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contracts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `contract_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('ACTIVE','EXPIRED','TERMINATED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `contracts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_availabilities`
--

DROP TABLE IF EXISTS `employee_availabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_availabilities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `day_of_week` enum('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `shift_id` int NOT NULL,
  `week_start_date` date NOT NULL DEFAULT '2026-10-19',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `shift_id` (`shift_id`),
  CONSTRAINT `employee_availabilities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `employee_availabilities_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_locks`
--

DROP TABLE IF EXISTS `employee_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_locks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `locked_by` int NOT NULL,
  `unlocked_by` int DEFAULT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `locked_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `unlocked_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_locked_by` (`locked_by`),
  KEY `idx_locked_at` (`locked_at`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_user_active` (`user_id`,`is_active`),
  KEY `fk_unlock_by` (`unlocked_by`),
  CONSTRAINT `fk_lock_by` FOREIGN KEY (`locked_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lock_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_unlock_by` FOREIGN KEY (`unlocked_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_profiles`
--

DROP TABLE IF EXISTS `employee_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_profiles` (
  `user_id` int NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `identity_card` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `home_branch_id` int NOT NULL COMMENT 'Cơ sở quản lý chính (Local Scope)',
  `position_id` int DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `employee_type` enum('FULL_TIME','PART_TIME','CASUAL') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `shift_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `standard_hours_per_day` decimal(5,2) NOT NULL DEFAULT '10.00',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `identity_card` (`identity_card`),
  KEY `home_branch_id` (`home_branch_id`),
  KEY `position_id` (`position_id`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `employee_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `employee_profiles_ibfk_2` FOREIGN KEY (`home_branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `employee_profiles_ibfk_3` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`),
  CONSTRAINT `employee_profiles_ibfk_4` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_transfers`
--

DROP TABLE IF EXISTS `employee_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_transfers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `from_branch_id` int NOT NULL,
  `to_branch_id` int NOT NULL,
  `transfer_type` enum('PERMANENT','TEMPORARY') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Cố định hoặc Mượn tạm thời',
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `from_branch_id` (`from_branch_id`),
  KEY `to_branch_id` (`to_branch_id`),
  CONSTRAINT `employee_transfers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `employee_transfers_ibfk_2` FOREIGN KEY (`from_branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `employee_transfers_ibfk_3` FOREIGN KEY (`to_branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `leave_balances`
--

DROP TABLE IF EXISTS `leave_balances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_balances` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `leave_type_id` int NOT NULL,
  `year` int NOT NULL,
  `total_days` int DEFAULT '0',
  `total_hours` decimal(8,2) DEFAULT NULL,
  `used_days` int DEFAULT '0',
  `used_hours` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_type_year` (`user_id`,`leave_type_id`,`year`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `leave_request_shifts`
--

DROP TABLE IF EXISTS `leave_request_shifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_request_shifts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `leave_request_id` int NOT NULL,
  `work_date` date NOT NULL,
  `shift_id` int NOT NULL,
  `shift_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hours` decimal(5,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `idx_lrs_request` (`leave_request_id`),
  KEY `idx_lrs_user_date` (`work_date`,`shift_id`),
  KEY `leave_request_shifts_ibfk_2` (`shift_id`),
  CONSTRAINT `leave_request_shifts_ibfk_1` FOREIGN KEY (`leave_request_id`) REFERENCES `leave_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `leave_request_shifts_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=321 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `leave_type_id` int NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `total_days` int NOT NULL DEFAULT '0',
  `total_hours` decimal(8,2) DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `manager_response` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reviewed_by` int DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `leave_type_id` (`leave_type_id`),
  KEY `leave_requests_ibfk_3` (`reviewed_by`),
  CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `leave_requests_ibfk_2` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`id`),
  CONSTRAINT `leave_requests_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=421 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `leave_types`
--

DROP TABLE IF EXISTS `leave_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `default_days` int DEFAULT '0',
  `paid_leave` tinyint(1) DEFAULT '1',
  `notice_hours` int NOT NULL DEFAULT '48',
  `notice_hours_part_time` int NOT NULL DEFAULT '48',
  `same_day_allowed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `open_shift_applications`
--

DROP TABLE IF EXISTS `open_shift_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `open_shift_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `open_shift_id` int NOT NULL,
  `user_id` int NOT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `reject_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `applied_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `open_shift_id` (`open_shift_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `open_shift_applications_ibfk_1` FOREIGN KEY (`open_shift_id`) REFERENCES `open_shifts` (`id`),
  CONSTRAINT `open_shift_applications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `open_shifts`
--

DROP TABLE IF EXISTS `open_shifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `open_shifts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_id` int NOT NULL,
  `shift_id` int NOT NULL,
  `position_id` int NOT NULL,
  `work_date` date NOT NULL,
  `status` enum('OPEN','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'OPEN',
  `leave_request_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `shift_id` (`shift_id`),
  KEY `leave_request_id` (`leave_request_id`),
  CONSTRAINT `open_shifts_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `open_shifts_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payroll_periods`
--

DROP TABLE IF EXISTS `payroll_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_periods` (
  `id` int NOT NULL AUTO_INCREMENT,
  `month` int NOT NULL,
  `year` int NOT NULL,
  `status` enum('DRAFT','FINALIZED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
  `finalized_by` int DEFAULT NULL,
  `finalized_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `finalized_by` (`finalized_by`),
  CONSTRAINT `payroll_periods_ibfk_1` FOREIGN KEY (`finalized_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payslips`
--

DROP TABLE IF EXISTS `payslips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payslips` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payroll_period_id` int NOT NULL,
  `user_id` int NOT NULL,
  `total_hours` decimal(6,2) NOT NULL,
  `base_salary` decimal(12,2) NOT NULL,
  `bonus` decimal(12,2) DEFAULT '0.00',
  `deductions` decimal(12,2) DEFAULT '0.00',
  `net_salary` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `payroll_period_id` (`payroll_period_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `payslips_ibfk_1` FOREIGN KEY (`payroll_period_id`) REFERENCES `payroll_periods` (`id`),
  CONSTRAINT `payslips_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Ví dụ: account:create, shift:approve',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `positions`
--

DROP TABLE IF EXISTS `positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `positions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `positions_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recruitment_proposals`
--

DROP TABLE IF EXISTS `recruitment_proposals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_proposals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidate_id` int DEFAULT NULL,
  `branch_id` int NOT NULL,
  `position_id` int NOT NULL,
  `employment_type` enum('FULL_TIME','PART_TIME') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` int DEFAULT NULL,
  `expiration_date` date DEFAULT NULL,
  `target_date` date DEFAULT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_by` int NOT NULL,
  `approved_by` int DEFAULT NULL,
  `hr_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `shift_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `position_id` (`position_id`),
  KEY `created_by` (`created_by`),
  KEY `approved_by` (`approved_by`),
  KEY `fk_recruitment_candidate` (`candidate_id`),
  CONSTRAINT `fk_proposals_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`),
  CONSTRAINT `fk_recruitment_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `recruitment_proposals_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `recruitment_proposals_ibfk_2` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`),
  CONSTRAINT `recruitment_proposals_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `recruitment_proposals_ibfk_4` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ADMIN, DIRECTOR, HR_MANAGER, STORE_MANAGER, EMPLOYEE',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `salary_rules`
--

DROP TABLE IF EXISTS `salary_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_rules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hourly_rate` decimal(12,2) NOT NULL,
  `overtime_rate` decimal(12,2) DEFAULT '1.50',
  `fine_per_violation` decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shift_change_requests`
--

DROP TABLE IF EXISTS `shift_change_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shift_change_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `requester_id` int NOT NULL,
  `target_user_id` int DEFAULT NULL,
  `shift_schedule_id` int DEFAULT NULL,
  `status` enum('WAITING_COLLEAGUE','PENDING','APPROVED','REJECTED','DECLINED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'WAITING_COLLEAGUE',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `response` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `colleague_response` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `colleague_responded_at` datetime DEFAULT NULL,
  `request_type` enum('SWAP','OPEN','EXTRA') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SWAP',
  `target_shift_schedule_id` int DEFAULT NULL,
  `open_shift_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `requester_id` (`requester_id`),
  KEY `target_user_id` (`target_user_id`),
  KEY `shift_schedule_id` (`shift_schedule_id`),
  KEY `target_shift_schedule_id` (`target_shift_schedule_id`),
  KEY `open_shift_id` (`open_shift_id`),
  CONSTRAINT `shift_change_requests_ibfk_1` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`),
  CONSTRAINT `shift_change_requests_ibfk_2` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `shift_change_requests_ibfk_3` FOREIGN KEY (`shift_schedule_id`) REFERENCES `shift_schedules` (`id`),
  CONSTRAINT `shift_change_requests_ibfk_4` FOREIGN KEY (`target_shift_schedule_id`) REFERENCES `shift_schedules` (`id`),
  CONSTRAINT `shift_change_requests_ibfk_5` FOREIGN KEY (`open_shift_id`) REFERENCES `open_shifts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shift_logs`
--

DROP TABLE IF EXISTS `shift_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shift_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_id` int NOT NULL,
  `store_manager_id` int NOT NULL,
  `log_date` date NOT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `store_manager_id` (`store_manager_id`),
  CONSTRAINT `shift_logs_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `shift_logs_ibfk_2` FOREIGN KEY (`store_manager_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shift_requirements`
--

DROP TABLE IF EXISTS `shift_requirements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shift_requirements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_id` int NOT NULL,
  `position_id` int NOT NULL,
  `shift_id` int NOT NULL,
  `required_count` int NOT NULL DEFAULT '2',
  `work_date` date DEFAULT NULL COMMENT 'Áp dụng cho ngày cụ thể nếu cần linh động lễ tết',
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `position_id` (`position_id`),
  KEY `shift_id` (`shift_id`),
  CONSTRAINT `shift_requirements_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `shift_requirements_ibfk_2` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`),
  CONSTRAINT `shift_requirements_ibfk_3` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shift_schedules`
--

DROP TABLE IF EXISTS `shift_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shift_schedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_id` int NOT NULL,
  `user_id` int NOT NULL,
  `shift_id` int NOT NULL,
  `work_date` date NOT NULL,
  `position_id` int DEFAULT NULL,
  `status` enum('DRAFT','PUBLISHED','ON_LEAVE','CANCELLED') COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
  `temporary_transfer_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `user_id` (`user_id`),
  KEY `shift_id` (`shift_id`),
  KEY `position_id` (`position_id`),
  KEY `fk_schedule_temporary_transfer` (`temporary_transfer_id`),
  CONSTRAINT `fk_schedule_temporary_transfer` FOREIGN KEY (`temporary_transfer_id`) REFERENCES `temporary_transfers` (`id`),
  CONSTRAINT `shift_schedules_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `shift_schedules_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `shift_schedules_ibfk_3` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`),
  CONSTRAINT `shift_schedules_ibfk_4` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=264 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shifts`
--

DROP TABLE IF EXISTS `shifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shifts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Ca Sáng, Ca Chiều, Ca Tối',
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `supplementary_shift_applications`
--

DROP TABLE IF EXISTS `supplementary_shift_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplementary_shift_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `opportunity_id` int NOT NULL,
  `user_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_supplementary_application` (`opportunity_id`,`user_id`),
  KEY `fk_supplementary_application_user` (`user_id`),
  CONSTRAINT `fk_supplementary_application_opportunity` FOREIGN KEY (`opportunity_id`) REFERENCES `supplementary_shift_opportunities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_supplementary_application_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `supplementary_shift_opportunities`
--

DROP TABLE IF EXISTS `supplementary_shift_opportunities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplementary_shift_opportunities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_id` int NOT NULL,
  `position_id` int NOT NULL,
  `shift_id` int NOT NULL,
  `work_date` date NOT NULL,
  `registration_deadline` datetime NOT NULL,
  `opened_by` int NOT NULL,
  `status` enum('OPEN','CLOSED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OPEN',
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temporary_transfer_employees`
--

DROP TABLE IF EXISTS `temporary_transfer_employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temporary_transfer_employees` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temporary_transfers`
--

DROP TABLE IF EXISTS `temporary_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temporary_transfers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `requester_id` int NOT NULL,
  `destination_store_id` int NOT NULL,
  `source_store_id` int NOT NULL,
  `position_id` int NOT NULL,
  `shift_id` int NOT NULL,
  `work_date` date NOT NULL,
  `required_count` int NOT NULL,
  `employee_id` int DEFAULT NULL,
  `reason` text NOT NULL,
  `reject_reason` text,
  `status` varchar(50) DEFAULT 'PENDING_MANAGER',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `requested_count` int DEFAULT NULL,
  `manager_approved_at` datetime DEFAULT NULL,
  `hr_approved_by` int DEFAULT NULL,
  `hr_approved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `requester_id` (`requester_id`),
  KEY `destination_store_id` (`destination_store_id`),
  KEY `source_store_id` (`source_store_id`),
  KEY `position_id` (`position_id`),
  KEY `shift_id` (`shift_id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `temporary_transfers_ibfk_1` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`),
  CONSTRAINT `temporary_transfers_ibfk_2` FOREIGN KEY (`destination_store_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `temporary_transfers_ibfk_3` FOREIGN KEY (`source_store_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `temporary_transfers_ibfk_4` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`),
  CONSTRAINT `temporary_transfers_ibfk_5` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`),
  CONSTRAINT `temporary_transfers_ibfk_6` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role_id` int NOT NULL,
  `status` enum('ACTIVE','INACTIVE','EMERGENCY_LOCKED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `expiration_date` datetime DEFAULT NULL COMMENT 'Hạn tài khoản nhân sự thời vụ',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_first_login` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `v_employee_locks`
--

DROP TABLE IF EXISTS `v_employee_locks`;
/*!50001 DROP VIEW IF EXISTS `v_employee_locks`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_employee_locks` AS SELECT 
 1 AS `id`,
 1 AS `user_id`,
 1 AS `employee_name`,
 1 AS `locked_by`,
 1 AS `locked_by_name`,
 1 AS `unlocked_by`,
 1 AS `unlocked_by_name`,
 1 AS `reason`,
 1 AS `locked_at`,
 1 AS `unlocked_at`,
 1 AS `is_active`,
 1 AS `branch_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `violations`
--

DROP TABLE IF EXISTS `violations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `violations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `branch_id` int NOT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `evidence_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deduction_amount` decimal(12,2) DEFAULT '0.00',
  `recorded_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `category` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OTHER',
  `violation_date` date DEFAULT NULL,
  `reported_by` int DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LEGACY',
  `review_note` text COLLATE utf8mb4_unicode_ci,
  `disciplinary_action` text COLLATE utf8mb4_unicode_ci,
  `reviewed_by` int DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `violations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `violations_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'swp391_supermarket'
--

--
-- Dumping routines for database 'swp391_supermarket'
--
/*!50003 DROP PROCEDURE IF EXISTS `add_column_if_not_exists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_column_if_not_exists`(
    IN p_table  VARCHAR(64),
    IN p_column VARCHAR(64),
    IN p_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = p_table
          AND COLUMN_NAME  = p_column
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `',
                          p_column, '` ', p_definition);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_employee_locks`
--

/*!50001 DROP VIEW IF EXISTS `v_employee_locks`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_employee_locks` AS select `el`.`id` AS `id`,`el`.`user_id` AS `user_id`,`target_ep`.`full_name` AS `employee_name`,`el`.`locked_by` AS `locked_by`,`locked_ep`.`full_name` AS `locked_by_name`,`el`.`unlocked_by` AS `unlocked_by`,`unlocked_ep`.`full_name` AS `unlocked_by_name`,`el`.`reason` AS `reason`,`el`.`locked_at` AS `locked_at`,`el`.`unlocked_at` AS `unlocked_at`,`el`.`is_active` AS `is_active`,`target_ep`.`home_branch_id` AS `branch_id` from (((`employee_locks` `el` join `employee_profiles` `target_ep` on((`el`.`user_id` = `target_ep`.`user_id`))) join `employee_profiles` `locked_ep` on((`el`.`locked_by` = `locked_ep`.`user_id`))) left join `employee_profiles` `unlocked_ep` on((`el`.`unlocked_by` = `unlocked_ep`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


-- ======================= PHAN 2: DU LIEU =======================

-- ---------- 10_roles.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `roles`

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` (`id`, `name`, `description`) VALUES (1,'System Admin','Quản trị hệ thống toàn chuỗi'),(2,'Director','Giám đốc chuỗi siêu thị'),(3,'HR Manager','Quản lý nhân sự toàn chuỗi'),(4,'Store Manager','Quản lý chi nhánh cửa hàng'),(5,'Employee','Nhân viên vận hành siêu thị');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 11_departments.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `departments`

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` (`id`, `name`) VALUES (1,'Ban Giám Đốc'),(5,'Bộ Phận Thu Ngân & Bán Hàng'),(4,'Bộ Phận Văn Hành Cửa Hàng'),(3,'Phòng Công Nghệ Thông Tin'),(2,'Phòng Hành Chính - Nhân Sự');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 12_positions.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `positions`

LOCK TABLES `positions` WRITE;
/*!40000 ALTER TABLE `positions` DISABLE KEYS */;
INSERT INTO `positions` (`id`, `title`, `department_id`) VALUES (1,'Giám Đốc Chuỗi',1),(2,'Quản Lý Nhân Sự',2),(3,'Quản Trị Hệ Thống',3),(4,'Quản Lý Chi Nhánh',4),(6,'Nhân Viên Thu Ngân',5),(7,'Nhân Viên Bán Hàng & Trưng Bày',5),(8,'Nhân Viên Kho Chi Nhánh',4),(9,'Nhân Viên Bảo Vệ',4),(10,'Nhân Viên Vệ Sinh & Tạp Vụ',4),(11,'Nhân viên pha chế',4);
/*!40000 ALTER TABLE `positions` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 13_branches.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `branches`

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` (`id`, `code`, `name`, `address`, `status`, `store_manager_id`, `created_at`) VALUES (1,'BR001','Siêu thị Cơ sở 1 - Cầu Giấy','123 Cầu Giấy, Hà Nội','ACTIVE',4,'2026-09-22 16:50:49'),(2,'BR002','Siêu thị Cơ sở 2 - Đống Đa','456 Tây Sơn, Hà Nội','ACTIVE',6,'2026-09-22 16:50:49'),(3,'BR003','Siêu thị Cơ sở 3 - Hà Đông','789 Quang Trung, Hà Nội','ACTIVE',7,'2026-09-22 16:50:49');
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 14_shifts.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `shifts`

LOCK TABLES `shifts` WRITE;
/*!40000 ALTER TABLE `shifts` DISABLE KEYS */;
INSERT INTO `shifts` (`id`, `name`, `start_time`, `end_time`) VALUES (1,'Ca Sáng','07:00:00','12:00:00'),(2,'Ca Chiều','12:00:00','17:00:00'),(3,'Ca Tối','17:00:00','22:00:00'),(4,'Ca Full-time Sáng - Chiều','07:00:00','17:00:00'),(5,'Ca Full-time Chiều - Tối','12:00:00','22:00:00');
/*!40000 ALTER TABLE `shifts` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 15_leave_types.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `leave_types`

LOCK TABLES `leave_types` WRITE;
/*!40000 ALTER TABLE `leave_types` DISABLE KEYS */;
INSERT INTO `leave_types` (`id`, `code`, `name`, `description`, `default_days`, `paid_leave`, `notice_hours`, `notice_hours_part_time`, `same_day_allowed`) VALUES (1,'ANNUAL','Nghỉ phép năm','Nghỉ phép thường niên',12,1,48,48,0),(2,'SICK','Nghỉ ốm','Nghỉ do lý do sức khỏe',30,1,4,4,1),(3,'UNPAID','Nghỉ không lương','Nghỉ việc riêng không hưởng lương',0,0,24,48,0),(4,'FUNERAL','Nghỉ tang','Nghỉ viếng tang người thân',3,1,0,0,1);
/*!40000 ALTER TABLE `leave_types` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 20_users.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `users`
-- WHERE:  username NOT IN ('test_nv_a','test_nv_b')

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`id`, `username`, `password_hash`, `email`, `role_id`, `status`, `expiration_date`, `created_at`, `updated_at`, `is_first_login`) VALUES (1,'admin_user','123456','admin@supermarket.com',1,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-09-22 16:50:49',0),(2,'director_user','123456','director@supermarket.com',2,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-09-22 16:50:49',0),(3,'hrm_user','123456','hrm@supermarket.com',3,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-09-22 16:50:49',0),(4,'sm_user','123456','sm1@supermarket.com',4,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-09-22 16:50:49',0),(5,'emp_user','123456','emp1@supermarket.com',5,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-13 07:53:55',0),(6,'sm2_user','123456','sm2@supermarket.com',4,'ACTIVE',NULL,'2026-10-07 08:41:12','2026-10-07 08:41:12',0),(7,'sm3_user','123456','sm3@supermarket.com',4,'ACTIVE',NULL,'2026-10-07 08:41:12','2026-10-07 08:41:12',0),(44,'pt_user1','123456','pt1@supermarket.vn',5,'ACTIVE',NULL,'2026-10-24 15:27:12','2026-10-24 15:45:47',0),(45,'pt_user2','123456','pt2@supermarket.vn',5,'ACTIVE',NULL,'2026-10-24 15:27:12','2026-10-24 15:45:47',0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 21_profiles.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `employee_profiles`
-- WHERE:  user_id NOT IN (46,47)

LOCK TABLES `employee_profiles` WRITE;
/*!40000 ALTER TABLE `employee_profiles` DISABLE KEYS */;
INSERT INTO `employee_profiles` (`user_id`, `full_name`, `phone`, `identity_card`, `home_branch_id`, `position_id`, `department_id`, `employee_type`, `shift_type`, `standard_hours_per_day`) VALUES (1,'Quản Trị Viên Hệ Thống','0901111111','001090000001',1,3,3,'FULL_TIME',NULL,10.00),(2,'Giám Đốc Chuỗi','0902222222','001090000002',1,1,1,'FULL_TIME',NULL,10.00),(3,'Quản Lý Nhân Sự','0903333333','001090000003',1,2,2,'FULL_TIME',NULL,10.00),(4,'Quản Lý Cửa Hàng CS1','0904444444','001090000004',1,4,4,'FULL_TIME',NULL,10.00),(5,'Nhân Viên Bán Hàng CS1','0905555555','001090000005',1,6,5,'FULL_TIME',NULL,10.00),(6,'Quản Lý Cửa Hàng CS2','0906666666','001090000006',2,4,4,'FULL_TIME',NULL,10.00),(7,'Quản Lý Cửa Hàng CS3','0907777777','001090000007',3,4,4,'FULL_TIME',NULL,10.00),(44,'Nguyễn Minh Anh (Part-time)','0901110001','PT0000001',1,7,5,'PART_TIME','PT_FIXED_EVENING',5.00),(45,'Trần Thị Bình (Part-time)','0901110002','PT0000002',1,7,5,'PART_TIME','PT_FIXED_MORNING',5.00);
/*!40000 ALTER TABLE `employee_profiles` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 22_contracts.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `contracts`

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
/*!40000 ALTER TABLE `contracts` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 23_balances.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `leave_balances`
-- WHERE:  user_id NOT IN (46,47)

LOCK TABLES `leave_balances` WRITE;
/*!40000 ALTER TABLE `leave_balances` DISABLE KEYS */;
INSERT INTO `leave_balances` (`id`, `user_id`, `leave_type_id`, `year`, `total_days`, `total_hours`, `used_days`, `used_hours`) VALUES (1,5,1,2026,12,120.00,0,0.00),(2,5,2,2026,30,300.00,0,0.00),(4,5,4,2026,3,30.00,0,0.00),(9,5,3,2026,0,0.00,0,0.00),(22,44,1,2026,12,60.00,0,0.00),(23,44,4,2026,3,15.00,0,0.00),(24,44,2,2026,30,150.00,0,0.00),(25,45,1,2026,12,60.00,0,0.00),(26,45,4,2026,3,15.00,0,0.00),(27,45,2,2026,30,150.00,0,0.00);
/*!40000 ALTER TABLE `leave_balances` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 24_avail.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `employee_availabilities`
-- WHERE:  user_id NOT IN (46,47)

LOCK TABLES `employee_availabilities` WRITE;
/*!40000 ALTER TABLE `employee_availabilities` DISABLE KEYS */;
INSERT INTO `employee_availabilities` (`id`, `user_id`, `day_of_week`, `shift_id`, `week_start_date`) VALUES (15,45,'MONDAY',1,'2026-11-02'),(16,45,'TUESDAY',1,'2026-11-02'),(17,45,'WEDNESDAY',1,'2026-11-02'),(18,45,'THURSDAY',1,'2026-11-02'),(19,45,'FRIDAY',1,'2026-11-02'),(20,45,'SATURDAY',1,'2026-11-02'),(21,45,'SUNDAY',1,'2026-11-02');
/*!40000 ALTER TABLE `employee_availabilities` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 25_schedules.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `shift_schedules`
-- WHERE:  user_id NOT IN (46,47)

LOCK TABLES `shift_schedules` WRITE;
/*!40000 ALTER TABLE `shift_schedules` DISABLE KEYS */;
INSERT INTO `shift_schedules` (`id`, `branch_id`, `user_id`, `shift_id`, `work_date`, `position_id`, `status`, `temporary_transfer_id`) VALUES (35,1,5,4,'2026-10-19',7,'DRAFT',NULL),(36,1,5,4,'2026-10-20',7,'DRAFT',NULL),(37,1,5,4,'2026-10-21',7,'DRAFT',NULL),(38,1,5,4,'2026-10-22',7,'DRAFT',NULL),(39,1,5,4,'2026-10-23',7,'DRAFT',NULL),(42,1,44,3,'2026-10-19',7,'DRAFT',NULL),(43,1,44,3,'2026-10-21',7,'DRAFT',NULL),(44,1,44,3,'2026-10-23',7,'DRAFT',NULL),(45,1,44,3,'2026-10-25',7,'DRAFT',NULL),(49,1,45,1,'2026-10-20',7,'DRAFT',NULL),(50,1,45,1,'2026-10-22',7,'DRAFT',NULL),(51,1,45,1,'2026-10-24',7,'DRAFT',NULL),(71,1,5,4,'2026-10-26',7,'PUBLISHED',NULL),(72,1,5,4,'2026-10-27',7,'PUBLISHED',NULL),(73,1,5,4,'2026-10-28',7,'PUBLISHED',NULL),(74,1,5,4,'2026-10-29',7,'PUBLISHED',NULL),(75,1,5,4,'2026-10-30',7,'PUBLISHED',NULL),(78,1,44,3,'2026-10-26',7,'PUBLISHED',NULL),(79,1,45,3,'2026-10-30',7,'PUBLISHED',NULL),(80,1,45,3,'2026-11-01',7,'PUBLISHED',NULL),(81,1,45,1,'2026-10-27',7,'PUBLISHED',NULL),(82,1,44,3,'2026-10-29',7,'PUBLISHED',NULL),(83,1,44,1,'2026-10-31',7,'PUBLISHED',NULL),(84,1,44,3,'2026-10-28',7,'PUBLISHED',NULL),(104,1,44,3,'2026-11-04',7,'PUBLISHED',NULL),(117,1,5,4,'2026-11-09',7,'PUBLISHED',NULL),(119,1,5,4,'2026-11-10',7,'PUBLISHED',NULL),(120,1,5,4,'2026-11-03',7,'PUBLISHED',NULL),(121,1,5,4,'2026-11-11',7,'PUBLISHED',NULL),(122,1,5,4,'2026-11-04',7,'PUBLISHED',NULL),(123,1,5,4,'2026-11-12',7,'PUBLISHED',NULL),(124,1,5,4,'2026-11-05',7,'PUBLISHED',NULL),(125,1,5,4,'2026-11-13',7,'PUBLISHED',NULL),(126,1,5,4,'2026-11-06',7,'PUBLISHED',NULL),(132,1,44,1,'2026-11-09',7,'PUBLISHED',NULL),(133,1,44,3,'2026-11-02',7,'PUBLISHED',NULL),(134,1,44,3,'2026-11-11',7,'PUBLISHED',NULL),(136,1,44,3,'2026-11-13',7,'PUBLISHED',NULL),(137,1,44,3,'2026-11-06',7,'PUBLISHED',NULL),(138,1,44,3,'2026-10-30',7,'PUBLISHED',NULL),(139,1,44,3,'2026-11-15',7,'PUBLISHED',NULL),(140,1,44,3,'2026-11-08',7,'PUBLISHED',NULL),(147,1,44,1,'2026-11-10',7,'PUBLISHED',NULL),(148,1,45,1,'2026-11-03',7,'PUBLISHED',NULL),(149,1,45,1,'2026-11-12',7,'PUBLISHED',NULL),(150,1,45,1,'2026-11-05',7,'PUBLISHED',NULL),(151,1,45,1,'2026-10-29',7,'PUBLISHED',NULL),(152,1,45,1,'2026-11-14',7,'PUBLISHED',NULL),(153,1,45,1,'2026-11-07',7,'PUBLISHED',NULL),(208,1,5,4,'2026-11-02',6,'PUBLISHED',NULL),(216,1,5,5,'2026-11-16',6,'DRAFT',NULL),(255,1,44,1,'2026-11-04',7,'PUBLISHED',NULL),(260,1,44,1,'2026-11-16',7,'ON_LEAVE',NULL),(261,1,45,3,'2026-11-17',7,'PUBLISHED',NULL),(263,1,45,1,'2026-11-18',7,'PUBLISHED',NULL);
/*!40000 ALTER TABLE `shift_schedules` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 26_requirements.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `shift_requirements`

LOCK TABLES `shift_requirements` WRITE;
/*!40000 ALTER TABLE `shift_requirements` DISABLE KEYS */;
INSERT INTO `shift_requirements` (`id`, `branch_id`, `position_id`, `shift_id`, `required_count`, `work_date`) VALUES (35,1,7,3,2,'2026-10-19'),(36,1,7,3,2,'2026-10-21'),(37,1,7,3,2,'2026-10-23'),(38,1,7,3,2,'2026-10-25'),(42,1,7,1,2,'2026-10-20'),(43,1,7,1,2,'2026-10-22'),(44,1,7,1,2,'2026-10-24'),(45,1,7,4,3,'2026-10-19'),(46,1,7,4,3,'2026-10-20'),(47,1,7,4,3,'2026-10-21'),(48,1,7,4,3,'2026-10-22'),(49,1,7,4,3,'2026-10-23'),(52,1,7,3,2,'2026-10-28'),(53,1,7,3,2,'2026-10-29'),(54,1,7,3,2,'2026-10-26'),(55,1,7,3,2,'2026-10-30'),(56,1,7,3,2,'2026-11-01'),(57,1,7,1,2,'2026-10-27'),(58,1,7,1,2,'2026-10-29'),(59,1,7,1,2,'2026-10-31'),(60,1,7,4,3,'2026-10-26'),(61,1,7,4,3,'2026-10-27'),(62,1,7,4,3,'2026-10-28'),(63,1,7,4,3,'2026-10-29'),(64,1,7,4,3,'2026-10-30'),(65,1,7,3,2,'2026-11-09'),(66,1,7,3,2,'2026-11-02'),(67,1,7,3,2,'2026-11-11'),(68,1,7,3,2,'2026-11-04'),(69,1,7,3,2,'2026-11-13'),(70,1,7,3,2,'2026-11-06'),(71,1,7,3,2,'2026-11-15'),(72,1,7,3,2,'2026-11-08'),(80,1,7,1,2,'2026-11-10'),(81,1,7,1,2,'2026-11-03'),(82,1,7,1,2,'2026-11-12'),(83,1,7,1,2,'2026-11-05'),(84,1,7,1,2,'2026-11-14'),(85,1,7,1,2,'2026-11-07'),(87,1,7,4,3,'2026-11-09'),(88,1,7,4,3,'2026-11-02'),(89,1,7,4,3,'2026-11-10'),(90,1,7,4,3,'2026-11-03'),(91,1,7,4,3,'2026-11-11'),(92,1,7,4,3,'2026-11-04'),(93,1,7,4,3,'2026-11-12'),(94,1,7,4,3,'2026-11-05'),(95,1,7,4,3,'2026-11-13'),(96,1,7,4,3,'2026-11-06'),(102,1,7,5,4,'2026-11-02'),(103,1,6,4,4,'2026-11-02');
/*!40000 ALTER TABLE `shift_requirements` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 30_leave_requests.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `leave_requests`
-- WHERE:  user_id NOT IN (46,47)

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` (`id`, `user_id`, `leave_type_id`, `reason`, `start_date`, `end_date`, `total_days`, `total_hours`, `status`, `manager_response`, `reviewed_by`, `reviewed_at`, `created_at`) VALUES (417,44,1,'E2E test xin nghi 2 ca','2026-11-04','2026-11-04',1,10.00,'PENDING',NULL,NULL,NULL,'2026-11-01 16:37:27'),(418,44,1,'test nghi','2026-11-16','2026-11-16',1,NULL,'APPROVED',NULL,1,'2026-11-01 16:46:47','2026-11-01 16:46:47'),(419,5,1,'don thu hoi test','2026-11-03','2026-11-03',1,10.00,'CANCELLED','Thu hồi: NV bao huy',4,'2026-11-01 16:47:07','2026-11-01 16:47:05'),(420,5,2,'don pending','2026-11-02','2026-11-02',1,10.00,'PENDING',NULL,NULL,NULL,'2026-11-01 16:47:07');
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 31_leave_shifts.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `leave_request_shifts`

LOCK TABLES `leave_request_shifts` WRITE;
/*!40000 ALTER TABLE `leave_request_shifts` DISABLE KEYS */;
INSERT INTO `leave_request_shifts` (`id`, `leave_request_id`, `work_date`, `shift_id`, `shift_name`, `hours`) VALUES (317,417,'2026-11-04',1,'Ca Sáng',5.00),(318,417,'2026-11-04',3,'Ca Tối',5.00),(319,419,'2026-11-03',4,'Ca Full-time Sáng - Chiều',10.00),(320,420,'2026-11-02',4,'Ca Full-time Sáng - Chiều',10.00);
/*!40000 ALTER TABLE `leave_request_shifts` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 32_open_shifts.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `open_shifts`

LOCK TABLES `open_shifts` WRITE;
/*!40000 ALTER TABLE `open_shifts` DISABLE KEYS */;
INSERT INTO `open_shifts` (`id`, `branch_id`, `shift_id`, `position_id`, `work_date`, `status`, `leave_request_id`) VALUES (16,1,1,7,'2026-10-30','CLOSED',NULL),(17,1,1,7,'2026-11-01','CLOSED',NULL),(18,1,3,7,'2026-10-29','CLOSED',NULL),(19,1,1,7,'2026-10-29','CLOSED',NULL),(27,1,1,7,'2026-11-02','OPEN',NULL),(35,1,2,7,'2026-11-02','OPEN',NULL),(46,1,4,6,'2026-11-02','CLOSED',386),(93,1,4,7,'2026-11-03','CLOSED',405),(100,1,4,7,'2026-11-03','CLOSED',411),(101,1,1,7,'2026-11-04','CLOSED',NULL),(105,1,4,7,'2026-11-03','CLOSED',415),(106,1,1,7,'2026-11-16','CLOSED',418),(107,1,1,7,'2026-11-18','OPEN',NULL),(108,1,1,7,'2026-11-16','OPEN',NULL),(109,1,4,7,'2026-11-03','CLOSED',419);
/*!40000 ALTER TABLE `open_shifts` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 33_shift_change.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `shift_change_requests`
-- WHERE:  requester_id NOT IN (46,47) AND (target_user_id IS NULL OR target_user_id NOT IN (46,47))

LOCK TABLES `shift_change_requests` WRITE;
/*!40000 ALTER TABLE `shift_change_requests` DISABLE KEYS */;
INSERT INTO `shift_change_requests` (`id`, `requester_id`, `target_user_id`, `shift_schedule_id`, `status`, `reason`, `response`, `colleague_response`, `colleague_responded_at`, `request_type`, `target_shift_schedule_id`, `open_shift_id`) VALUES (129,44,NULL,138,'CANCELLED','Xin chuyển sang ca trống',NULL,NULL,NULL,'OPEN',NULL,16),(130,44,45,80,'APPROVED','Sẽ được duyệt','Đồng ý đổi ca','OK','2026-10-28 16:15:45','SWAP',133,NULL),(149,44,45,133,'APPROVED','E2E: doi ca cho nhau','E2E: duyet doi ca','E2E: B dong y doi ca','2026-10-31 11:39:16','SWAP',148,NULL),(170,44,45,148,'APPROVED','E2E: doi ca cho nhau','E2E: duyet doi ca','E2E: B dong y doi ca','2026-11-01 20:20:03','SWAP',133,NULL),(171,44,45,133,'APPROVED','E2E: doi ca cho nhau','E2E: duyet doi ca','E2E: B dong y doi ca','2026-11-01 20:20:14','SWAP',148,NULL),(173,44,45,104,'APPROVED','cho bố đổi','oki','ok con zai','2026-11-01 23:23:38','SWAP',133,NULL),(177,44,45,133,'APPROVED','E2E: doi ca cho nhau','E2E: duyet doi ca','E2E: B dong y doi ca','2026-11-01 23:37:02','SWAP',104,NULL),(178,45,NULL,NULL,'APPROVED','Toi muon lam them ca','OK duyet',NULL,NULL,'EXTRA',NULL,106),(179,45,NULL,NULL,'PENDING','don A',NULL,NULL,NULL,'EXTRA',NULL,108),(180,44,45,148,'APPROVED','E2E: doi ca cho nhau','E2E: duyet doi ca','E2E: B dong y doi ca','2026-11-01 23:47:10','SWAP',133,NULL);
/*!40000 ALTER TABLE `shift_change_requests` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 34_supp_opp.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `supplementary_shift_opportunities`

LOCK TABLES `supplementary_shift_opportunities` WRITE;
/*!40000 ALTER TABLE `supplementary_shift_opportunities` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplementary_shift_opportunities` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 35_supp_app.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `supplementary_shift_applications`
-- WHERE:  user_id NOT IN (46,47)

LOCK TABLES `supplementary_shift_applications` WRITE;
/*!40000 ALTER TABLE `supplementary_shift_applications` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplementary_shift_applications` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 40_attendances.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `attendances`
-- WHERE:  user_id NOT IN (46,47)

LOCK TABLES `attendances` WRITE;
/*!40000 ALTER TABLE `attendances` DISABLE KEYS */;
INSERT INTO `attendances` (`id`, `user_id`, `shift_schedule_id`, `check_in`, `check_out`, `method`, `status`) VALUES (1,5,35,'2026-10-19 07:05:00','2026-10-19 17:10:00','WIFI','VALID'),(2,5,36,'2026-10-20 07:05:00','2026-10-20 17:00:00','WIFI','VALID'),(3,5,37,'2026-10-21 07:05:00','2026-10-21 17:00:00','DYNAMIC_QR','VALID'),(4,5,38,'2026-10-22 07:05:00','2026-10-22 17:00:00','WIFI','ADJUSTED'),(5,5,39,'2026-10-23 07:05:00','2026-10-23 17:00:00','WIFI','VALID'),(6,44,42,'2026-10-19 17:05:00','2026-10-19 22:10:00','WIFI','VALID'),(7,44,43,'2026-10-21 17:05:00','2026-10-21 22:00:00','WIFI','VALID'),(8,44,44,'2026-10-23 17:05:00','2026-10-23 22:00:00','DYNAMIC_QR','VALID'),(9,44,45,'2026-10-25 17:05:00','2026-10-25 22:00:00','WIFI','VALID'),(10,45,49,'2026-10-20 07:05:00','2026-10-20 12:00:00','DYNAMIC_QR','VALID'),(11,45,50,'2026-10-22 07:05:00','2026-10-22 12:00:00','WIFI','VALID'),(12,45,51,'2026-10-24 07:25:00','2026-10-24 12:00:00','WIFI','VALID'),(13,5,71,'2026-10-26 07:25:00','2026-10-26 17:00:00','WIFI','VALID'),(14,5,72,'2026-10-27 07:05:00','2026-10-27 17:00:00','WIFI','VALID'),(15,5,73,'2026-10-28 07:05:00','2026-10-28 17:00:00','DYNAMIC_QR','VALID'),(16,44,78,'2026-10-26 17:05:00','2026-10-26 22:00:00','WIFI','VALID'),(17,45,81,'2026-10-27 07:05:00','2026-10-27 12:00:00','DYNAMIC_QR','VALID'),(18,44,84,'2026-10-28 17:05:00','2026-10-28 22:00:00','DYNAMIC_QR','VALID');
/*!40000 ALTER TABLE `attendances` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 41_locks.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `employee_locks`
-- WHERE:  user_id NOT IN (46,47) AND locked_by NOT IN (46,47)

LOCK TABLES `employee_locks` WRITE;
/*!40000 ALTER TABLE `employee_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_locks` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 42_proposals.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `recruitment_proposals`
-- WHERE:  created_by NOT IN (46,47)

LOCK TABLES `recruitment_proposals` WRITE;
/*!40000 ALTER TABLE `recruitment_proposals` DISABLE KEYS */;
INSERT INTO `recruitment_proposals` (`id`, `candidate_id`, `branch_id`, `position_id`, `employment_type`, `department_id`, `expiration_date`, `target_date`, `reason`, `status`, `created_by`, `approved_by`, `hr_note`, `created_at`, `updated_at`, `shift_type`) VALUES (1,1,2,7,'FULL_TIME',5,NULL,'2026-10-14','ứdsd','PENDING',6,NULL,NULL,'2026-10-13 14:44:35','2026-10-13 14:44:35',NULL),(2,2,3,8,'PART_TIME',4,'2026-10-21','2026-10-14','fjh','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV002 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-13 14:52:00','2026-10-13 15:52:59',NULL),(3,3,3,9,'PART_TIME',4,NULL,'2026-10-14','fthg','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV001 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-13 14:52:20','2026-10-13 14:59:16',NULL),(4,4,3,7,'FULL_TIME',5,NULL,'2026-10-22','thiếu','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV003 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-21 05:16:16','2026-10-21 05:17:09',NULL),(5,5,1,7,'FULL_TIME',5,NULL,'2026-10-22','thiếu','APPROVED',4,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV004 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-21 05:23:38','2026-10-21 05:23:51',NULL),(6,6,3,7,'FULL_TIME',5,NULL,'2026-10-17','fsfd','PENDING',7,NULL,NULL,'2026-10-16 04:39:25','2026-10-16 04:39:25','FT_FIXED_EVENING'),(7,7,3,7,'PART_TIME',5,NULL,'2026-10-17','thử','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV005 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-16 06:59:59','2026-10-16 07:00:17','PT_FIXED_MORNING'),(8,8,3,9,'PART_TIME',4,NULL,'2026-10-21','thử','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV006 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-16 07:33:46','2026-10-16 07:34:57','PT_FLEXIBLE'),(9,9,3,9,'FULL_TIME',4,NULL,'2026-10-21','thử','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV007 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-16 07:34:17','2026-10-16 07:35:02','FT_FIXED_MORNING'),(10,10,3,9,'FULL_TIME',4,NULL,'2026-10-21','thử','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV008 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-16 07:34:40','2026-10-16 07:35:10','FT_ROTATING');
/*!40000 ALTER TABLE `recruitment_proposals` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 43_transfers.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `temporary_transfers`

LOCK TABLES `temporary_transfers` WRITE;
/*!40000 ALTER TABLE `temporary_transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `temporary_transfers` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 44_transfer_emp.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `temporary_transfer_employees`
-- WHERE:  employee_id NOT IN (46,47)

LOCK TABLES `temporary_transfer_employees` WRITE;
/*!40000 ALTER TABLE `temporary_transfer_employees` DISABLE KEYS */;
/*!40000 ALTER TABLE `temporary_transfer_employees` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 45_violations.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `violations`
-- WHERE:  user_id NOT IN (46,47)

LOCK TABLES `violations` WRITE;
/*!40000 ALTER TABLE `violations` DISABLE KEYS */;
/*!40000 ALTER TABLE `violations` ENABLE KEYS */;
UNLOCK TABLES;



-- ---------- 46_audit.sql ----------
-- ------------------------------------------------------

-- Dumping data for table `audit_logs`
-- WHERE:  (actor_id IS NULL OR actor_id NOT IN (46,47)) AND (target_user_id IS NULL OR target_user_id NOT IN (46,47)) AND (entity_id IS NULL OR entity_id NOT IN (46,47))

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `description`, `ip_address`, `created_at`, `actor_id`, `target_user_id`, `entity_type`, `entity_id`) VALUES (3,1,'LOGIN','[actor=#1] Đăng nhập thành công. Tài khoản: \'admin_user\'','0:0:0:0:0:0:0:1','2026-11-02 13:29:15',1,NULL,NULL,NULL),(4,NULL,'LOGIN_FAILED','Tài khoản admin / Đăng nhập / Thất bại - sai tên đăng nhập hoặc mật khẩu','0:0:0:0:0:0:0:1','2026-11-02 14:03:11',NULL,NULL,NULL,NULL),(5,1,'LOGIN','Tài khoản admin_user / Đăng nhập / Thành công','0:0:0:0:0:0:0:1','2026-11-02 14:42:12',1,NULL,'USER',1),(6,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-02 14:48:08',1,NULL,'USER',1),(7,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-02 14:49:58',1,NULL,'USER',1),(8,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-02 14:50:29',1,NULL,'USER',1),(9,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-02 14:51:32',1,NULL,'USER',1),(12,1,'LOGIN','[actor=#1] Đăng nhập thành công. Tài khoản: \'admin_user\'','0:0:0:0:0:0:0:1','2026-11-02 15:25:27',1,NULL,NULL,NULL),(13,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-02 18:16:33',1,NULL,'USER',1),(14,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-03 02:59:46',1,NULL,'USER',1),(15,NULL,'LOGIN_FAILED','Tài khoản store_manager | Đăng nhập thất bại | Thất bại - sai tên đăng nhập hoặc mật khẩu','0:0:0:0:0:0:0:1','2026-11-03 03:00:08',NULL,NULL,NULL,NULL),(16,NULL,'LOGIN_FAILED','Tài khoản store_user | Đăng nhập thất bại | Thất bại - sai tên đăng nhập hoặc mật khẩu','0:0:0:0:0:0:0:1','2026-11-03 03:00:08',NULL,NULL,NULL,NULL),(17,NULL,'LOGIN_FAILED','Tài khoản nhanvien | Đăng nhập thất bại | Thất bại - sai tên đăng nhập hoặc mật khẩu','0:0:0:0:0:0:0:1','2026-11-03 03:00:09',NULL,NULL,NULL,NULL),(18,NULL,'LOGIN_FAILED','Tài khoản employee_user | Đăng nhập thất bại | Thất bại - sai tên đăng nhập hoặc mật khẩu','0:0:0:0:0:0:0:1','2026-11-03 03:00:09',NULL,NULL,NULL,NULL),(19,4,'LOGIN','Tài khoản sm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-03 03:00:51',4,NULL,'USER',4),(20,5,'LOGIN','Tài khoản emp_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-03 03:01:27',5,NULL,'USER',5),(21,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-03 03:01:29',3,NULL,'USER',3),(22,5,'LOGIN','Tài khoản emp_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-03 03:07:55',5,NULL,'USER',5),(23,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-03 03:07:55',3,NULL,'USER',3),(24,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-04 08:05:29',1,NULL,'USER',1),(25,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-04 13:46:37',1,NULL,'USER',1),(26,5,'LOGIN','Tài khoản emp_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-05 03:56:54',5,NULL,'USER',5),(27,5,'LOGIN','Tài khoản emp_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-07 07:45:55',5,NULL,'USER',5),(28,5,'LOGOUT','Tài khoản emp_user | Đăng xuất | Thành công | Bởi Nhân Viên Bán Hàng CS1','0:0:0:0:0:0:0:1','2026-11-07 08:01:42',5,NULL,'USER',5),(29,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-07 08:01:52',1,NULL,'USER',1),(30,5,'LOGIN','Tài khoản emp_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-07 13:37:42',5,NULL,'USER',5),(31,5,'LOGOUT','Tài khoản emp_user | Đăng xuất | Thành công | Bởi Nhân Viên Bán Hàng CS1','0:0:0:0:0:0:0:1','2026-11-07 13:49:13',5,NULL,'USER',5),(32,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-07 13:49:22',1,NULL,'USER',1),(33,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 14:01:10',2,NULL,'USER',2),(34,44,'LOGIN','Tài khoản pt_user1 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 07:15:42',44,NULL,'USER',44),(35,44,'LOGOUT','Tài khoản pt_user1 | Đăng xuất | Thành công | Bởi Nguyễn Minh Anh (Part-time)','0:0:0:0:0:0:0:1','2026-11-11 07:38:04',44,NULL,'USER',44),(36,44,'LOGIN','Tài khoản pt_user1 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:00:19',44,NULL,'USER',44),(37,44,'LOGOUT','Tài khoản pt_user1 | Đăng xuất | Thành công | Bởi Nguyễn Minh Anh (Part-time)','0:0:0:0:0:0:0:1','2026-11-11 09:10:52',44,NULL,'USER',44),(38,1,'LOGIN_FAILED','Tài khoản admin_user | Đăng nhập thất bại | Thất bại - sai tên đăng nhập hoặc mật khẩu | Tài khoản tồn tại: Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-11 09:11:01',1,NULL,NULL,NULL),(39,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 09:11:10',1,NULL,'USER',1),(40,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-11 10:12:06',1,NULL,'USER',1),(41,4,'LOGIN','Tài khoản sm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 10:12:16',4,NULL,'USER',4);
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;




-- ======================= PHAN 3: KET THUC =======================

SET FOREIGN_KEY_CHECKS = 1;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- Kiem tra nhanh sau khi import
SELECT 'So bang' AS muc, COUNT(*) AS so_luong
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE';

SELECT id, username, role_id, status FROM users ORDER BY id;
