-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: swp391_supermarket
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attendance_adjustment_history`
--

DROP TABLE IF EXISTS `attendance_adjustment_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_adjustment_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `attendance_id` int NOT NULL,
  `adjusted_by` int NOT NULL,
  `previous_check_in` datetime DEFAULT NULL,
  `previous_check_out` datetime DEFAULT NULL,
  `adjusted_check_in` datetime DEFAULT NULL,
  `adjusted_check_out` datetime DEFAULT NULL,
  `adjustment_note` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `attendance_id` (`attendance_id`),
  KEY `adjusted_by` (`adjusted_by`),
  CONSTRAINT `attendance_adjustment_history_ibfk_1` FOREIGN KEY (`attendance_id`) REFERENCES `attendances` (`id`),
  CONSTRAINT `attendance_adjustment_history_ibfk_2` FOREIGN KEY (`adjusted_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_adjustment_history`
--

LOCK TABLES `attendance_adjustment_history` WRITE;
/*!40000 ALTER TABLE `attendance_adjustment_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance_adjustment_history` ENABLE KEYS */;
UNLOCK TABLES;

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
  `method` enum('WIFI','DYNAMIC_QR','WEB') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('VALID','INVALID','ADJUSTED','PENDING') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'VALID',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `shift_schedule_id` (`shift_schedule_id`),
  CONSTRAINT `attendances_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `attendances_ibfk_2` FOREIGN KEY (`shift_schedule_id`) REFERENCES `shift_schedules` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendances`
--

LOCK TABLES `attendances` WRITE;
/*!40000 ALTER TABLE `attendances` DISABLE KEYS */;
INSERT INTO `attendances` VALUES (1,13,80,'2026-11-30 07:05:35','2026-11-30 12:01:19','WEB','VALID');
/*!40000 ALTER TABLE `attendances` ENABLE KEYS */;
UNLOCK TABLES;

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
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'CREATE_ROLE','[actor=#1] Tạo vai trò mới: \'egg\' - đfdf','0:0:0:0:0:0:0:1','2026-10-24 15:44:25',1,NULL),(2,1,'DELETE_ROLE','[actor=#1] Admin \'admin_user\' xóa vai trò \'egg\' (id=6)','0:0:0:0:0:0:0:1','2026-10-24 15:44:37',1,NULL),(3,NULL,'EMERGENCY_LOCK','Emergency Lock bởi Store Manager',NULL,'2026-10-27 08:11:29',6,11),(4,NULL,'EMERGENCY_UNLOCK','Emergency Unlock bởi Store Manager',NULL,'2026-10-27 08:11:56',6,11),(5,NULL,'EMERGENCY_LOCK','Emergency Lock bởi Store Manager',NULL,'2026-10-27 08:15:50',6,11),(6,NULL,'EMERGENCY_UNLOCK','Emergency Unlock bởi Store Manager',NULL,'2026-10-29 07:45:04',6,11);
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'BR001','Siêu thị Cơ sở 1 - Cầu Giấy','123 Cầu Giấy, Hà Nội','ACTIVE',4,'2026-09-22 16:50:49'),(2,'BR002','Siêu thị Cơ sở 2 - Đống Đa','456 Tây Sơn, Hà Nội','ACTIVE',6,'2026-09-22 16:50:49'),(3,'BR003','Siêu thị Cơ sở 3 - Hà Đông','789 Quang Trung, Hà Nội','ACTIVE',7,'2026-09-22 16:50:49');
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidates`
--

LOCK TABLES `candidates` WRITE;
/*!40000 ALTER TABLE `candidates` DISABLE KEYS */;
INSERT INTO `candidates` VALUES (1,'Trần Văn Test1','test1@gmail.com','0900000001','090000000001','2026-10-19 10:10:29'),(2,'Trần Văn Test2','test2@gmail.com','0900000002','090000000002','2026-10-19 10:10:54'),(3,'Trần Văn Test3','test3@gmail.com','0900000003','090000000003','2026-10-19 10:11:23'),(4,'Trần Văn Test4','test4@gmail.com','0900000004','090000000004','2026-10-19 10:11:59'),(5,'Trần Văn Test5','test5@gmail.com','0900000005','090000000005','2026-10-19 10:12:18'),(6,'Trần Văn Test6','test6@gmail.com','0900000006','090000000006','2026-10-19 10:12:38'),(7,'Trần Văn Test7','test7@gmail.com','0900000007','090000000007','2026-10-19 10:13:04'),(8,'Trần Văn Test8','test8@gmail.com','0900000008','090000000008','2026-10-19 10:13:21'),(9,'Trần Văn Test9','test9@gmail.com','0900000009','090000000009','2026-10-19 10:13:45'),(10,'Trần Văn Test10','test10@gmail.com','0900000011','090000000010','2026-10-25 07:47:12');
/*!40000 ALTER TABLE `candidates` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `certificates`
--

LOCK TABLES `certificates` WRITE;
/*!40000 ALTER TABLE `certificates` DISABLE KEYS */;
/*!40000 ALTER TABLE `certificates` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
INSERT INTO `contracts` VALUES (1,8,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(2,9,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(3,10,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(4,11,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(5,12,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(6,13,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(7,14,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(8,15,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(9,16,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE');
/*!40000 ALTER TABLE `contracts` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'Ban Giám Đốc'),(5,'Bộ Phận Thu Ngân & Bán Hàng'),(4,'Bộ Phận Vận Hành Cửa Hàng'),(3,'Phòng Công Nghệ Thông Tin'),(2,'Phòng Hành Chính - Nhân Sự');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_availabilities`
--

LOCK TABLES `employee_availabilities` WRITE;
/*!40000 ALTER TABLE `employee_availabilities` DISABLE KEYS */;
INSERT INTO `employee_availabilities` VALUES (2,16,'TUESDAY',1,'2026-10-26'),(3,16,'WEDNESDAY',1,'2026-10-26'),(4,16,'THURSDAY',1,'2026-10-26'),(5,16,'FRIDAY',1,'2026-10-26'),(6,16,'SATURDAY',1,'2026-10-26'),(7,16,'SUNDAY',1,'2026-10-26'),(8,15,'MONDAY',1,'2026-10-26'),(9,15,'TUESDAY',1,'2026-10-26'),(10,15,'WEDNESDAY',1,'2026-10-26'),(11,15,'THURSDAY',1,'2026-10-26'),(12,15,'FRIDAY',1,'2026-10-26'),(13,15,'SATURDAY',1,'2026-10-26'),(14,15,'SUNDAY',1,'2026-10-26'),(15,15,'MONDAY',2,'2026-10-26'),(16,15,'TUESDAY',2,'2026-10-26'),(17,15,'WEDNESDAY',2,'2026-10-26'),(18,15,'THURSDAY',2,'2026-10-26'),(19,15,'FRIDAY',2,'2026-10-26'),(20,15,'SATURDAY',2,'2026-10-26'),(21,15,'SUNDAY',2,'2026-10-26'),(22,13,'MONDAY',1,'2026-10-26'),(23,13,'TUESDAY',1,'2026-10-26'),(24,13,'WEDNESDAY',1,'2026-10-26'),(25,13,'THURSDAY',1,'2026-10-26'),(26,13,'FRIDAY',1,'2026-10-26'),(27,13,'SATURDAY',1,'2026-10-26'),(28,13,'SUNDAY',1,'2026-10-26'),(29,12,'MONDAY',1,'2026-10-26'),(30,12,'TUESDAY',1,'2026-10-26'),(31,12,'WEDNESDAY',1,'2026-10-26'),(32,12,'THURSDAY',1,'2026-10-26'),(33,12,'FRIDAY',1,'2026-10-26'),(34,12,'SATURDAY',1,'2026-10-26'),(35,12,'SUNDAY',1,'2026-10-26'),(36,13,'MONDAY',1,'2026-11-30'),(37,13,'TUESDAY',1,'2026-11-30'),(38,13,'WEDNESDAY',1,'2026-11-30'),(39,13,'THURSDAY',1,'2026-11-30'),(40,13,'FRIDAY',1,'2026-11-30'),(41,13,'SATURDAY',1,'2026-11-30'),(42,13,'SUNDAY',1,'2026-11-30'),(43,16,'MONDAY',1,'2026-11-30'),(44,16,'TUESDAY',1,'2026-11-30'),(45,16,'WEDNESDAY',1,'2026-11-30'),(46,16,'THURSDAY',1,'2026-11-30'),(47,16,'FRIDAY',1,'2026-11-30'),(48,16,'SATURDAY',1,'2026-11-30'),(49,16,'SUNDAY',1,'2026-11-30'),(50,15,'MONDAY',1,'2026-11-30'),(51,15,'TUESDAY',1,'2026-11-30'),(52,15,'WEDNESDAY',1,'2026-11-30'),(53,15,'THURSDAY',1,'2026-11-30'),(54,15,'FRIDAY',1,'2026-11-30'),(55,15,'SATURDAY',1,'2026-11-30'),(56,15,'SUNDAY',1,'2026-11-30'),(57,12,'MONDAY',1,'2026-11-30'),(58,12,'TUESDAY',1,'2026-11-30'),(59,12,'WEDNESDAY',1,'2026-11-30'),(60,12,'THURSDAY',1,'2026-11-30'),(61,12,'FRIDAY',1,'2026-11-30');
/*!40000 ALTER TABLE `employee_availabilities` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_locks`
--

LOCK TABLES `employee_locks` WRITE;
/*!40000 ALTER TABLE `employee_locks` DISABLE KEYS */;
INSERT INTO `employee_locks` VALUES (1,11,6,6,NULL,'2026-10-27 08:11:29','2026-10-27 08:11:56',0),(2,11,6,6,NULL,'2026-10-27 08:15:50','2026-10-29 07:45:04',0);
/*!40000 ALTER TABLE `employee_locks` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `employee_profiles`
--

LOCK TABLES `employee_profiles` WRITE;
/*!40000 ALTER TABLE `employee_profiles` DISABLE KEYS */;
INSERT INTO `employee_profiles` VALUES (1,'Quản Trị Viên Hệ Thống','0901111111','001090000001',1,3,3,'FULL_TIME',NULL,10.00),(2,'Giám Đốc Chuỗi','0902222222','001090000002',1,1,1,'FULL_TIME',NULL,10.00),(3,'Quản Lý Nhân Sự','0903333333','001090000003',1,2,2,'FULL_TIME',NULL,10.00),(4,'Quản Lý Cửa Hàng CS1','0904444444','001090000004',1,4,4,'FULL_TIME',NULL,10.00),(5,'Nhân Viên Bán Hàng CS1','0905555555','001090000005',1,6,5,'FULL_TIME',NULL,10.00),(6,'Quản Lý Cửa Hàng CS2','0906666666','001090000006',2,4,4,'FULL_TIME',NULL,10.00),(7,'Quản Lý Cửa Hàng CS3','0907777777','001090000007',3,4,4,'FULL_TIME',NULL,10.00),(8,'Trần Văn Test1','0900000001','090000000001',1,7,5,'FULL_TIME','FT_ROTATING',10.00),(9,'Trần Văn Test2','0900000002','090000000002',1,7,5,'PART_TIME','PT_FLEXIBLE',10.00),(10,'Trần Văn Test3','0900000003','090000000003',1,7,5,'PART_TIME','PT_FIXED_MORNING',10.00),(11,'Trần Văn Test4','0900000004','090000000004',2,7,5,'FULL_TIME','FT_ROTATING',10.00),(12,'Trần Văn Test5','0900000005','090000000005',2,7,5,'PART_TIME','PT_FLEXIBLE',10.00),(13,'Trần Văn Test6','0900000006','090000000006',2,7,5,'PART_TIME','PT_FIXED_MORNING',10.00),(14,'Trần Văn Test7','0900000007','090000000007',3,7,5,'FULL_TIME','FT_ROTATING',10.00),(15,'Trần Văn Test8','0900000008','090000000008',3,7,5,'PART_TIME','PT_FLEXIBLE',10.00),(16,'Trần Văn Test9','0900000009','090000000009',3,7,5,'PART_TIME','PT_FIXED_MORNING',10.00);
/*!40000 ALTER TABLE `employee_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_salary_configs`
--

DROP TABLE IF EXISTS `employee_salary_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_salary_configs` (
  `user_id` int NOT NULL,
  `monthly_salary` decimal(12,2) DEFAULT NULL,
  `hourly_rate` decimal(12,2) NOT NULL,
  `monthly_allowance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `updated_by` int NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  KEY `updated_by` (`updated_by`),
  CONSTRAINT `employee_salary_configs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `employee_salary_configs_ibfk_2` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_salary_configs`
--

LOCK TABLES `employee_salary_configs` WRITE;
/*!40000 ALTER TABLE `employee_salary_configs` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_salary_configs` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `employee_transfers`
--

LOCK TABLES `employee_transfers` WRITE;
/*!40000 ALTER TABLE `employee_transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `employee_transfers` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_balances`
--

LOCK TABLES `leave_balances` WRITE;
/*!40000 ALTER TABLE `leave_balances` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_balances` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_request_shifts`
--

LOCK TABLES `leave_request_shifts` WRITE;
/*!40000 ALTER TABLE `leave_request_shifts` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_request_shifts` ENABLE KEYS */;
UNLOCK TABLES;

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
  `manager_response` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `leave_types`
--

LOCK TABLES `leave_types` WRITE;
/*!40000 ALTER TABLE `leave_types` DISABLE KEYS */;
INSERT INTO `leave_types` VALUES (1,'ANNUAL','Nghỉ phép năm','Nghỉ phép thường niên',12,1,48,48,0),(2,'SICK','Nghỉ ốm','Nghỉ do lý do sức khỏe',30,1,4,4,1),(3,'UNPAID','Nghỉ không lương','Nghỉ việc riêng không hưởng lương',0,0,24,48,0),(4,'FUNERAL','Nghỉ tang','Nghỉ viếng tang người thân',3,1,0,0,1);
/*!40000 ALTER TABLE `leave_types` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `open_shift_applications`
--

LOCK TABLES `open_shift_applications` WRITE;
/*!40000 ALTER TABLE `open_shift_applications` DISABLE KEYS */;
/*!40000 ALTER TABLE `open_shift_applications` ENABLE KEYS */;
UNLOCK TABLES;

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
  KEY `fk_open_shifts_leave_request` (`leave_request_id`),
  CONSTRAINT `fk_open_shifts_leave_request` FOREIGN KEY (`leave_request_id`) REFERENCES `leave_requests` (`id`),
  CONSTRAINT `open_shifts_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `open_shifts_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `open_shifts`
--

LOCK TABLES `open_shifts` WRITE;
/*!40000 ALTER TABLE `open_shifts` DISABLE KEYS */;
/*!40000 ALTER TABLE `open_shifts` ENABLE KEYS */;
UNLOCK TABLES;

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
  UNIQUE KEY `uq_payroll_period_month_year` (`month`,`year`),
  KEY `finalized_by` (`finalized_by`),
  CONSTRAINT `payroll_periods_ibfk_1` FOREIGN KEY (`finalized_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_periods`
--

LOCK TABLES `payroll_periods` WRITE;
/*!40000 ALTER TABLE `payroll_periods` DISABLE KEYS */;
/*!40000 ALTER TABLE `payroll_periods` ENABLE KEYS */;
UNLOCK TABLES;

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
  `regular_hours` decimal(8,2) NOT NULL DEFAULT '0.00',
  `paid_leave_hours` decimal(8,2) NOT NULL DEFAULT '0.00',
  `overtime_hours` decimal(8,2) NOT NULL DEFAULT '0.00',
  `base_salary` decimal(12,2) NOT NULL,
  `bonus` decimal(12,2) DEFAULT '0.00',
  `allowances` decimal(12,2) NOT NULL DEFAULT '0.00',
  `deductions` decimal(12,2) DEFAULT '0.00',
  `net_salary` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payslip_period_employee` (`payroll_period_id`,`user_id`),
  KEY `payroll_period_id` (`payroll_period_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `payslips_ibfk_1` FOREIGN KEY (`payroll_period_id`) REFERENCES `payroll_periods` (`id`),
  CONSTRAINT `payslips_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payslips`
--

LOCK TABLES `payslips` WRITE;
/*!40000 ALTER TABLE `payslips` DISABLE KEYS */;
/*!40000 ALTER TABLE `payslips` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `positions`
--

LOCK TABLES `positions` WRITE;
/*!40000 ALTER TABLE `positions` DISABLE KEYS */;
INSERT INTO `positions` VALUES (1,'Giám Đốc Chuỗi',1),(2,'Quản Lý Nhân Sự',2),(3,'Quản Trị Hệ Thống',3),(4,'Quản Lý Chi Nhánh',4),(6,'Nhân Viên Thu Ngân',5),(7,'Nhân Viên Bán Hàng & Trưng Bày',5),(8,'Nhân Viên Kho Chi Nhánh',4),(9,'Nhân Viên Bảo Vệ',4),(10,'Nhân Viên Vệ Sinh & Tạp Vụ',4);
/*!40000 ALTER TABLE `positions` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `recruitment_proposals`
--

LOCK TABLES `recruitment_proposals` WRITE;
/*!40000 ALTER TABLE `recruitment_proposals` DISABLE KEYS */;
INSERT INTO `recruitment_proposals` VALUES (1,1,1,7,'FULL_TIME',5,NULL,'2026-10-20','test','APPROVED',4,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV001 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:10:29','2026-10-19 10:14:10','FT_ROTATING'),(2,2,1,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',4,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV002 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:10:54','2026-10-19 10:14:15','PT_FLEXIBLE'),(3,3,1,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',4,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV003 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:11:23','2026-10-19 10:14:19','PT_FIXED_MORNING'),(4,4,2,7,'FULL_TIME',5,NULL,'2026-10-20','test','APPROVED',6,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV004 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:11:59','2026-10-19 10:14:24','FT_ROTATING'),(5,5,2,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',6,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV005 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:12:18','2026-10-19 10:14:28','PT_FLEXIBLE'),(6,6,2,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',6,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV006 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:12:38','2026-10-19 10:14:31','PT_FIXED_MORNING'),(7,7,3,7,'FULL_TIME',5,NULL,'2026-10-20','test','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV007 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:13:04','2026-10-19 10:14:34','FT_ROTATING'),(8,8,3,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV008 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:13:21','2026-10-19 10:14:38','PT_FLEXIBLE'),(9,9,3,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV009 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:13:45','2026-10-19 10:14:41','PT_FIXED_MORNING'),(10,10,3,7,'FULL_TIME',5,NULL,'2026-10-27','êrr','PENDING',7,3,NULL,'2026-10-25 07:47:12','2026-10-25 09:11:45','FT_ROTATING');
/*!40000 ALTER TABLE `recruitment_proposals` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'System Admin','Quản trị hệ thống toàn chuỗi'),(2,'Director','Giám đốc chuỗi siêu thị'),(3,'HR Manager','Quản lý nhân sự toàn chuỗi'),(4,'Store Manager','Quản lý chi nhánh cửa hàng'),(5,'Employee','Nhân viên vận hành siêu thị');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `salary_rules`
--

LOCK TABLES `salary_rules` WRITE;
/*!40000 ALTER TABLE `salary_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `salary_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shift_change_requests`
--

DROP TABLE IF EXISTS `shift_change_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shift_change_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `requester_id` int NOT NULL,
  `target_user_id` int NOT NULL,
  `shift_schedule_id` int NOT NULL,
  `target_shift_schedule_id` int DEFAULT NULL,
  `status` enum('WAITING_COLLEAGUE','PENDING','APPROVED','REJECTED','DECLINED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'WAITING_COLLEAGUE',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `response` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `colleague_responded_at` datetime DEFAULT NULL,
  `colleague_response` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_type` enum('SWAP','OPEN') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SWAP',
  `open_shift_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `requester_id` (`requester_id`),
  KEY `target_user_id` (`target_user_id`),
  KEY `shift_schedule_id` (`shift_schedule_id`),
  KEY `idx_shift_change_target_schedule` (`target_shift_schedule_id`),
  KEY `shift_change_requests_ibfk_5` (`open_shift_id`),
  CONSTRAINT `fk_shift_change_target_schedule` FOREIGN KEY (`target_shift_schedule_id`) REFERENCES `shift_schedules` (`id`),
  CONSTRAINT `shift_change_requests_ibfk_1` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`),
  CONSTRAINT `shift_change_requests_ibfk_2` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `shift_change_requests_ibfk_3` FOREIGN KEY (`shift_schedule_id`) REFERENCES `shift_schedules` (`id`),
  CONSTRAINT `shift_change_requests_ibfk_5` FOREIGN KEY (`open_shift_id`) REFERENCES `open_shifts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shift_change_requests`
--

LOCK TABLES `shift_change_requests` WRITE;
/*!40000 ALTER TABLE `shift_change_requests` DISABLE KEYS */;
INSERT INTO `shift_change_requests` VALUES (1,15,16,42,61,'DECLINED','muốn đi chơi',NULL,'2026-10-29 23:25:41','tạm oki','SWAP',NULL),(2,15,16,42,61,'PENDING','hhh',NULL,'2026-10-29 23:26:52','tạm oki','SWAP',NULL);
/*!40000 ALTER TABLE `shift_change_requests` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `shift_logs`
--

LOCK TABLES `shift_logs` WRITE;
/*!40000 ALTER TABLE `shift_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `shift_logs` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shift_requirements`
--

LOCK TABLES `shift_requirements` WRITE;
/*!40000 ALTER TABLE `shift_requirements` DISABLE KEYS */;
INSERT INTO `shift_requirements` VALUES (1,2,7,1,1,'2026-10-26'),(2,2,7,1,1,'2026-11-30');
/*!40000 ALTER TABLE `shift_requirements` ENABLE KEYS */;
UNLOCK TABLES;

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
  `status` enum('DRAFT','PUBLISHED','ON_LEAVE') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
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
) ENGINE=InnoDB AUTO_INCREMENT=95 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shift_schedules`
--

LOCK TABLES `shift_schedules` WRITE;
/*!40000 ALTER TABLE `shift_schedules` DISABLE KEYS */;
INSERT INTO `shift_schedules` VALUES (13,2,13,1,'2026-10-26',7,'DRAFT',NULL),(14,3,12,1,'2026-10-26',7,'PUBLISHED',2),(25,2,12,1,'2026-10-27',7,'DRAFT',NULL),(26,2,12,1,'2026-10-28',7,'DRAFT',NULL),(27,2,12,1,'2026-10-29',7,'DRAFT',NULL),(28,2,12,1,'2026-10-30',7,'DRAFT',NULL),(29,2,12,1,'2026-11-01',7,'DRAFT',NULL),(37,3,15,1,'2026-10-26',7,'PUBLISHED',NULL),(38,3,15,1,'2026-10-27',7,'PUBLISHED',NULL),(39,3,15,1,'2026-10-28',7,'PUBLISHED',NULL),(40,3,15,1,'2026-10-29',7,'PUBLISHED',NULL),(41,3,15,1,'2026-10-30',7,'PUBLISHED',NULL),(42,3,15,1,'2026-10-31',7,'PUBLISHED',NULL),(43,3,15,1,'2026-11-01',7,'PUBLISHED',NULL),(52,3,16,1,'2026-10-26',7,'PUBLISHED',NULL),(53,3,16,1,'2026-10-27',7,'PUBLISHED',NULL),(54,3,16,1,'2026-10-28',7,'PUBLISHED',NULL),(58,3,16,1,'2026-10-29',7,'PUBLISHED',NULL),(59,3,16,1,'2026-10-30',7,'PUBLISHED',NULL),(60,3,16,1,'2026-10-31',7,'PUBLISHED',NULL),(61,3,16,1,'2026-11-01',7,'PUBLISHED',NULL),(70,3,14,4,'2026-11-03',7,'DRAFT',NULL),(79,2,12,1,'2026-11-30',7,'DRAFT',NULL),(80,3,13,1,'2026-11-30',7,'PUBLISHED',7),(81,3,16,1,'2026-11-30',7,'PUBLISHED',NULL),(82,3,15,1,'2026-11-30',7,'PUBLISHED',NULL),(83,3,16,1,'2026-12-01',7,'PUBLISHED',NULL),(84,3,16,1,'2026-12-02',7,'PUBLISHED',NULL),(85,3,15,1,'2026-12-01',7,'PUBLISHED',NULL),(86,3,15,1,'2026-12-02',7,'PUBLISHED',NULL),(87,3,16,1,'2026-12-03',7,'PUBLISHED',NULL),(88,3,15,1,'2026-12-03',7,'PUBLISHED',NULL),(89,3,16,1,'2026-12-04',7,'PUBLISHED',NULL),(90,3,15,1,'2026-12-04',7,'PUBLISHED',NULL),(91,3,16,1,'2026-12-05',7,'PUBLISHED',NULL),(92,3,15,1,'2026-12-05',7,'PUBLISHED',NULL),(93,3,16,1,'2026-12-06',7,'PUBLISHED',NULL),(94,3,15,1,'2026-12-06',7,'PUBLISHED',NULL);
/*!40000 ALTER TABLE `shift_schedules` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `shifts`
--

LOCK TABLES `shifts` WRITE;
/*!40000 ALTER TABLE `shifts` DISABLE KEYS */;
INSERT INTO `shifts` VALUES (1,'Ca Sáng','07:00:00','12:00:00'),(2,'Ca Chiều','12:00:00','17:00:00'),(3,'Ca Tối','17:00:00','22:00:00'),(4,'Ca Full-time Sáng - Chiều','07:00:00','17:00:00'),(5,'Ca Full-time Chiều - Tối','12:00:00','22:00:00');
/*!40000 ALTER TABLE `shifts` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `supplementary_shift_applications`
--

LOCK TABLES `supplementary_shift_applications` WRITE;
/*!40000 ALTER TABLE `supplementary_shift_applications` DISABLE KEYS */;
INSERT INTO `supplementary_shift_applications` VALUES (1,2,15,'2026-10-22 14:40:53'),(2,2,16,'2026-10-22 16:23:26');
/*!40000 ALTER TABLE `supplementary_shift_applications` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplementary_shift_opportunities`
--

LOCK TABLES `supplementary_shift_opportunities` WRITE;
/*!40000 ALTER TABLE `supplementary_shift_opportunities` DISABLE KEYS */;
INSERT INTO `supplementary_shift_opportunities` VALUES (1,3,7,1,'2026-10-27','2026-10-23 21:35:00',7,'CLOSED','2026-10-22 14:36:17'),(2,3,7,1,'2026-10-26','2026-10-23 21:40:00',7,'CLOSED','2026-10-22 14:40:31');
/*!40000 ALTER TABLE `supplementary_shift_opportunities` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temporary_transfer_employees`
--

LOCK TABLES `temporary_transfer_employees` WRITE;
/*!40000 ALTER TABLE `temporary_transfer_employees` DISABLE KEYS */;
INSERT INTO `temporary_transfer_employees` VALUES (1,2,12,'APPROVED','2026-10-19 10:47:31'),(2,7,13,'APPROVED','2026-11-24 10:01:32');
/*!40000 ALTER TABLE `temporary_transfer_employees` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temporary_transfers`
--

LOCK TABLES `temporary_transfers` WRITE;
/*!40000 ALTER TABLE `temporary_transfers` DISABLE KEYS */;
INSERT INTO `temporary_transfers` VALUES (1,7,3,2,7,1,'2026-10-26',3,NULL,'test','đang thiếu nhân viên','REJECTED_MANAGER','2026-10-19 10:22:29','2026-10-19 10:25:24',1,NULL,NULL,NULL),(2,7,3,2,7,1,'2026-10-26',3,NULL,'test',NULL,'APPROVED','2026-10-19 10:26:06','2026-10-19 10:51:26',2,'2026-10-19 17:47:31',3,'2026-10-19 17:51:26'),(3,7,3,2,7,1,'2026-10-28',3,NULL,'ygi',NULL,'PENDING_MANAGER','2026-10-22 15:40:45','2026-10-22 15:40:45',1,NULL,NULL,NULL),(4,7,3,1,7,1,'2026-10-28',3,NULL,'yy',NULL,'PENDING_MANAGER','2026-10-22 15:54:12','2026-10-22 15:54:12',1,NULL,NULL,NULL),(5,7,3,2,7,2,'2026-11-01',4,NULL,'test',NULL,'PENDING_MANAGER','2026-10-25 14:38:42','2026-10-25 14:38:42',1,NULL,NULL,NULL),(6,7,3,2,7,4,'2026-11-01',4,NULL,'test2',NULL,'PENDING_MANAGER','2026-10-25 15:37:55','2026-10-25 15:37:55',1,NULL,NULL,NULL),(7,7,3,2,7,1,'2026-11-30',3,NULL,'test',NULL,'APPROVED','2026-11-24 09:58:29','2026-11-24 10:02:22',1,'2026-11-24 17:01:32',3,'2026-11-24 17:02:22');
/*!40000 ALTER TABLE `temporary_transfers` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin_user','123456','admin@supermarket.com',1,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(2,'director_user','123456','director@supermarket.com',2,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(3,'hrm_user','123456','hrm@supermarket.com',3,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(4,'sm_user','123456','sm1@supermarket.com',4,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(5,'emp_user','123456','emp1@supermarket.com',5,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(6,'sm2_user','123456','sm2@supermarket.com',4,'ACTIVE',NULL,'2026-10-07 08:41:12','2026-10-19 05:52:37',0),(7,'sm3_user','123456','sm3@supermarket.com',4,'ACTIVE',NULL,'2026-10-07 08:41:12','2026-10-19 05:52:37',0),(8,'NV001','123456','test1@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:10','2026-10-19 10:15:33',0),(9,'NV002','123456','test2@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:15','2026-10-19 10:16:19',0),(10,'NV003','123456','test3@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:19','2026-10-19 10:16:34',0),(11,'NV004','123456','test4@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:24','2026-10-29 07:45:04',0),(12,'NV005','123456','test5@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:28','2026-10-19 10:17:00',0),(13,'NV006','123456','test6@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:31','2026-10-19 10:17:14',0),(14,'NV007','123456','test7@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:34','2026-10-19 10:17:27',0),(15,'NV008','123456','test8@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:38','2026-10-19 10:17:40',0),(16,'NV009','123456','test9@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:41','2026-10-19 10:18:02',0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

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
  KEY `idx_violations_status_recorded` (`status`,`recorded_at`),
  KEY `idx_violations_reported_by` (`reported_by`),
  KEY `idx_violations_reviewed_by` (`reviewed_by`),
  CONSTRAINT `violations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `violations_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `violations_reported_by_fk` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `violations_reviewed_by_fk` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `violations`
--

LOCK TABLES `violations` WRITE;
/*!40000 ALTER TABLE `violations` DISABLE KEYS */;
INSERT INTO `violations` VALUES (1,13,2,'vi phạm','nhìn hơi ngu',NULL,0.00,'2026-10-31 20:46:21','WORK_PERFORMANCE','2026-10-30',6,'APPROVED','lần sau bớt ngu nhé.','chấm dứt hợp đồng',3,'2026-10-31 20:47:29'),(2,12,2,'ddfd','dfdf',NULL,0.00,'2026-10-31 20:54:19','OPERATIONAL','2026-10-24',6,'PENDING_REVIEW',NULL,NULL,NULL,NULL),(3,14,3,'sdsdsd','sdssd',NULL,0.00,'2026-10-31 20:55:04','WORK_PERFORMANCE','2026-10-29',7,'PENDING_REVIEW',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `violations` ENABLE KEYS */;
UNLOCK TABLES;

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
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-01 21:21:02
