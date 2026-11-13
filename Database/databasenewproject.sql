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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_adjustment_history`
--

LOCK TABLES `attendance_adjustment_history` WRITE;
/*!40000 ALTER TABLE `attendance_adjustment_history` DISABLE KEYS */;
INSERT INTO `attendance_adjustment_history` VALUES (1,2,7,'2026-11-09 08:34:04','2026-11-09 08:36:17','2026-11-09 08:34:00','2026-11-09 12:00:00','thử','2026-11-09 18:07:28');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendances`
--

LOCK TABLES `attendances` WRITE;
/*!40000 ALTER TABLE `attendances` DISABLE KEYS */;
INSERT INTO `attendances` VALUES (1,13,80,'2026-11-30 07:05:35','2026-11-30 12:01:19','WEB','VALID'),(2,15,97,'2026-11-09 08:34:00','2026-11-09 12:00:00','WEB','ADJUSTED'),(3,14,132,'2026-11-17 07:21:24','2026-11-17 17:00:47','WEB','VALID');
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
  `entity_type` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=539 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'CREATE_ROLE','[actor=#1] Tạo vai trò mới: \'egg\' - đfdf','0:0:0:0:0:0:0:1','2026-10-24 15:44:25',1,NULL,NULL,NULL),(2,1,'DELETE_ROLE','[actor=#1] Admin \'admin_user\' xóa vai trò \'egg\' (id=6)','0:0:0:0:0:0:0:1','2026-10-24 15:44:37',1,NULL,NULL,NULL),(3,NULL,'EMERGENCY_LOCK','Emergency Lock bởi Store Manager',NULL,'2026-10-27 08:11:29',6,11,'USER',11),(4,NULL,'EMERGENCY_UNLOCK','Emergency Unlock bởi Store Manager',NULL,'2026-10-27 08:11:56',6,11,'USER',11),(5,NULL,'EMERGENCY_LOCK','Emergency Lock bởi Store Manager',NULL,'2026-10-27 08:15:50',6,11,'USER',11),(6,NULL,'EMERGENCY_UNLOCK','Emergency Unlock bởi Store Manager',NULL,'2026-10-29 07:45:04',6,11,'USER',11),(7,NULL,'EMERGENCY_LOCK','Emergency Lock bởi Store Manager: đ',NULL,'2026-11-07 14:30:59',7,14,'USER',14),(8,NULL,'EMERGENCY_LOCK','Emergency Lock bởi Store Manager: dd',NULL,'2026-11-07 14:31:17',7,17,'USER',17),(9,NULL,'EMERGENCY_UNLOCK','Emergency Unlock bởi Store Manager',NULL,'2026-11-07 14:31:31',7,14,'USER',14),(10,NULL,'EMERGENCY_UNLOCK','Emergency Unlock bởi Store Manager',NULL,'2026-11-07 14:31:46',7,17,'USER',17),(11,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:31:40',1,NULL,'USER',1),(12,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-09 14:32:43',1,NULL,'USER',1),(13,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:32:49',3,NULL,'USER',3),(14,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:37:25',3,NULL,'USER',3),(15,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:52:08',15,NULL,'USER',15),(16,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-09 17:54:53',15,NULL,'USER',15),(17,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:54:58',7,NULL,'USER',7),(18,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:57:18',7,NULL,'USER',7),(19,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-09 17:57:30',7,NULL,'USER',7),(20,13,'LOGIN','Tài khoản NV006 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:57:31',13,NULL,'USER',13),(21,13,'LOGOUT','Tài khoản NV006 | Đăng xuất | Thành công | Bởi Trần Văn Test6','0:0:0:0:0:0:0:1','2026-11-09 17:57:35',13,NULL,'USER',13),(22,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:57:39',3,NULL,'USER',3),(23,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 17:57:41',3,NULL,'USER',3),(24,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:57:44',1,NULL,'USER',1),(25,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-09 17:57:46',1,NULL,'USER',1),(26,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:57:51',1,NULL,'USER',1),(27,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-09 17:57:54',1,NULL,'USER',1),(28,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:57:59',2,NULL,'USER',2),(29,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 17:59:19',2,NULL,'USER',2),(30,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:00:27',7,NULL,'USER',7),(31,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:02:40',7,NULL,'USER',7),(32,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:14:32',7,NULL,'USER',7),(33,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:22:14',7,NULL,'USER',7),(34,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:25:55',7,NULL,'USER',7),(35,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:32:07',7,NULL,'USER',7),(36,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:37:17',7,NULL,'USER',7),(37,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:56:53',7,NULL,'USER',7),(38,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-09 18:57:51',7,NULL,'USER',7),(39,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:57:55',14,NULL,'USER',14),(40,14,'LOGOUT','Tài khoản NV007 | Đăng xuất | Thành công | Bởi Trần Văn Test7','0:0:0:0:0:0:0:1','2026-11-09 18:58:24',14,NULL,'USER',14),(41,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:58:26',7,NULL,'USER',7),(42,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-09 18:58:44',7,NULL,'USER',7),(43,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:58:48',15,NULL,'USER',15),(44,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-09 18:59:17',15,NULL,'USER',15),(45,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 18:59:22',7,NULL,'USER',7),(46,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 19:12:53',7,NULL,'USER',7),(47,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 19:29:11',7,NULL,'USER',7),(48,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 19:44:13',7,NULL,'USER',7),(49,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 20:04:30',7,NULL,'USER',7),(50,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 20:20:23',3,NULL,'USER',3),(51,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 20:23:21',3,NULL,'USER',3),(52,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 20:23:23',7,NULL,'USER',7),(53,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 21:15:15',3,NULL,'USER',3),(54,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 21:23:19',3,NULL,'USER',3),(55,3,'CREATE_USER','Tài khoản NV011 (Trần Văn Test12) | Tạo | Vai trò: Employee | Mật khẩu mặc định: 123456 | Bởi hrm_user','0:0:0:0:0:0:0:1','2026-11-09 21:23:59',3,18,'USER',18),(56,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 21:25:12',3,NULL,'USER',3),(57,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 21:25:15',7,NULL,'USER',7),(58,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-09 21:27:51',7,NULL,'USER',7),(59,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 21:27:54',3,NULL,'USER',3),(60,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 21:40:03',3,NULL,'USER',3),(61,3,'CREATE_USER','Tài khoản NV012 (Trần Văn Test13) | Tạo | Vai trò: Employee | Mật khẩu mặc định: 123456 | Bởi hrm_user','0:0:0:0:0:0:0:1','2026-11-09 21:40:43',3,19,'USER',19),(62,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:36:38',3,NULL,'USER',3),(63,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:43:14',3,NULL,'USER',3),(64,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:43:14',3,NULL,'USER',3),(65,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 00:44:50',3,NULL,'USER',3),(66,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:44:55',1,NULL,'USER',1),(67,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-10 00:45:38',1,NULL,'USER',1),(68,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:45:43',2,NULL,'USER',2),(69,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-10 00:46:17',2,NULL,'USER',2),(70,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:46:20',7,NULL,'USER',7),(71,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 00:46:26',7,NULL,'USER',7),(72,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:46:29',2,NULL,'USER',2),(73,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:58:15',2,NULL,'USER',2),(74,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-10 01:11:33',2,NULL,'USER',2),(75,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:11:40',3,NULL,'USER',3),(76,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 01:14:31',3,NULL,'USER',3),(77,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:14:34',7,NULL,'USER',7),(78,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 01:15:31',7,NULL,'USER',7),(79,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:27:13',3,NULL,'USER',3),(80,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:29:20',3,NULL,'USER',3),(81,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 01:37:00',3,NULL,'USER',3),(82,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:37:05',7,NULL,'USER',7),(83,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 01:37:54',7,NULL,'USER',7),(84,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:37:56',3,NULL,'USER',3),(85,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:41:20',3,NULL,'USER',3),(86,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 01:41:27',3,NULL,'USER',3),(87,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:41:29',7,NULL,'USER',7),(88,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:43:44',7,NULL,'USER',7),(89,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 01:52:30',7,NULL,'USER',7),(90,6,'LOGIN','Tài khoản sm2_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:52:35',6,NULL,'USER',6),(91,6,'LOGIN','Tài khoản sm2_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:53:44',6,NULL,'USER',6),(92,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 01:59:25',7,NULL,'USER',7),(93,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:06:33',7,NULL,'USER',7),(94,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:12:57',7,NULL,'USER',7),(95,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:17:03',7,NULL,'USER',7),(96,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 02:33:54',7,NULL,'USER',7),(97,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:33:58',3,NULL,'USER',3),(98,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 02:34:20',3,NULL,'USER',3),(99,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:34:27',1,NULL,'USER',1),(100,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-10 02:34:28',1,NULL,'USER',1),(101,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:34:33',1,NULL,'USER',1),(102,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-10 02:34:44',1,NULL,'USER',1),(103,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:34:47',2,NULL,'USER',2),(104,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-10 02:35:00',2,NULL,'USER',2),(105,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:35:05',3,NULL,'USER',3),(106,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 14:48:59',3,NULL,'USER',3),(107,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:33:51',3,NULL,'USER',3),(108,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:36:11',3,NULL,'USER',3),(109,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:43:07',3,NULL,'USER',3),(110,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 15:43:20',3,NULL,'USER',3),(111,12,'LOGIN','Tài khoản NV005 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:43:26',12,NULL,'USER',12),(112,12,'LOGIN','Tài khoản NV005 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 17:02:09',12,NULL,'USER',12),(113,12,'LOGIN','Tài khoản NV005 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 02:04:02',12,NULL,'USER',12),(114,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:02:36',1,NULL,'USER',1),(115,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-11 08:03:16',1,NULL,'USER',1),(116,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:03:19',2,NULL,'USER',2),(117,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-11 08:04:08',2,NULL,'USER',2),(118,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:04:11',3,NULL,'USER',3),(119,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-11 08:09:57',3,NULL,'USER',3),(120,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:10:07',3,NULL,'USER',3),(121,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-11 08:10:19',3,NULL,'USER',3),(122,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:10:23',7,NULL,'USER',7),(123,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-11 08:14:29',7,NULL,'USER',7),(124,12,'LOGIN','Tài khoản NV005 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:14:33',12,NULL,'USER',12),(125,12,'LOGOUT','Tài khoản NV005 | Đăng xuất | Thành công | Bởi Trần Văn Test5','0:0:0:0:0:0:0:1','2026-11-11 08:23:00',12,NULL,'USER',12),(126,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:23:02',7,NULL,'USER',7),(127,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-11 08:25:24',7,NULL,'USER',7),(128,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:25:39',3,NULL,'USER',3),(129,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-11 08:26:55',3,NULL,'USER',3),(130,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:26:58',2,NULL,'USER',2),(131,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-11 08:27:26',2,NULL,'USER',2),(132,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 08:27:30',1,NULL,'USER',1),(133,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 09:29:21',1,NULL,'USER',1),(134,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-12 09:29:50',1,NULL,'USER',1),(135,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 09:29:55',2,NULL,'USER',2),(136,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-12 09:31:45',2,NULL,'USER',2),(137,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 09:31:48',3,NULL,'USER',3),(138,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 10:25:58',2,NULL,'USER',2),(139,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-08 00:43:23',2,NULL,'USER',2),(140,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 00:43:25',3,NULL,'USER',3),(141,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-08 01:27:47',3,NULL,'USER',3),(142,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 01:27:51',7,NULL,'USER',7),(143,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-08 01:57:19',7,NULL,'USER',7),(144,12,'LOGIN','Tài khoản NV005 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 01:57:22',12,NULL,'USER',12),(145,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 03:34:34',14,NULL,'USER',14),(146,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 14:53:47',2,NULL,'USER',2),(147,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-08 15:07:31',2,NULL,'USER',2),(148,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 15:07:37',3,NULL,'USER',3),(149,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-08 16:01:25',3,NULL,'USER',3),(150,6,'LOGIN','Tài khoản sm2_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 16:01:27',6,NULL,'USER',6),(151,6,'LOGOUT','Tài khoản sm2_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS2','0:0:0:0:0:0:0:1','2026-11-08 16:51:20',6,NULL,'USER',6),(152,13,'LOGIN','Tài khoản NV006 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-08 16:51:22',13,NULL,'USER',13),(153,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 00:39:20',2,NULL,'USER',2),(154,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 01:00:49',2,NULL,'USER',2),(155,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:01:05',14,NULL,'USER',14),(156,14,'LOGOUT','Tài khoản NV007 | Đăng xuất | Thành công | Bởi Trần Văn Test7','0:0:0:0:0:0:0:1','2026-11-09 01:02:10',14,NULL,'USER',14),(157,6,'LOGIN','Tài khoản sm2_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:02:13',6,NULL,'USER',6),(158,6,'LOGOUT','Tài khoản sm2_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS2','0:0:0:0:0:0:0:1','2026-11-09 01:08:22',6,NULL,'USER',6),(159,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:08:27',2,NULL,'USER',2),(160,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:28:40',2,NULL,'USER',2),(161,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 01:44:50',2,NULL,'USER',2),(162,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:44:53',15,NULL,'USER',15),(163,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:46:02',15,NULL,'USER',15),(164,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-09 01:46:13',15,NULL,'USER',15),(165,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:46:16',2,NULL,'USER',2),(166,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 01:46:24',2,NULL,'USER',2),(167,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:46:26',15,NULL,'USER',15),(168,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 01:57:18',15,NULL,'USER',15),(169,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-09 01:57:52',15,NULL,'USER',15),(170,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 02:02:13',2,NULL,'USER',2),(171,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 02:05:21',2,NULL,'USER',2),(172,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 02:05:24',3,NULL,'USER',3),(173,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 02:05:36',3,NULL,'USER',3),(174,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 02:05:38',2,NULL,'USER',2),(175,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 02:17:12',2,NULL,'USER',2),(176,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 02:17:28',2,NULL,'USER',2),(177,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 02:17:30',3,NULL,'USER',3),(178,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 02:17:52',3,NULL,'USER',3),(179,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 02:17:55',2,NULL,'USER',2),(180,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 02:25:54',2,NULL,'USER',2),(181,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 02:40:55',2,NULL,'USER',2),(182,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 10:03:37',2,NULL,'USER',2),(183,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 11:16:27',2,NULL,'USER',2),(184,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 12:39:30',2,NULL,'USER',2),(185,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 12:39:35',2,NULL,'USER',2),(186,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 12:39:40',7,NULL,'USER',7),(187,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-09 12:39:47',7,NULL,'USER',7),(188,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 12:39:52',2,NULL,'USER',2),(189,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 12:40:04',2,NULL,'USER',2),(190,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 12:40:06',7,NULL,'USER',7),(191,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 12:40:28',2,NULL,'USER',2),(192,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 13:01:13',2,NULL,'USER',2),(193,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 13:58:01',2,NULL,'USER',2),(194,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 13:58:04',3,NULL,'USER',3),(195,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 14:00:50',3,NULL,'USER',3),(196,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:00:53',2,NULL,'USER',2),(197,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 14:07:19',2,NULL,'USER',2),(198,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:07:22',3,NULL,'USER',3),(199,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 14:09:55',3,NULL,'USER',3),(200,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:09:58',2,NULL,'USER',2),(201,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:15:42',2,NULL,'USER',2),(202,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:17:33',2,NULL,'USER',2),(203,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:18:23',2,NULL,'USER',2),(204,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:20:10',2,NULL,'USER',2),(205,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:20:54',2,NULL,'USER',2),(206,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:25:21',2,NULL,'USER',2),(207,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 14:28:03',2,NULL,'USER',2),(208,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:28:06',3,NULL,'USER',3),(209,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 14:34:55',3,NULL,'USER',3),(210,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:34:57',2,NULL,'USER',2),(211,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 14:38:15',2,NULL,'USER',2),(212,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:38:20',3,NULL,'USER',3),(213,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 14:38:41',3,NULL,'USER',3),(214,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:38:44',2,NULL,'USER',2),(215,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-16 14:39:40',2,NULL,'USER',2),(216,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-09 14:45:38',2,NULL,'USER',2),(217,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 14:45:40',3,NULL,'USER',3),(218,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 16:59:42',3,NULL,'USER',3),(219,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-28 17:02:23',3,NULL,'USER',3),(220,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-28 17:03:11',3,NULL,'USER',3),(221,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-28 17:03:15',2,NULL,'USER',2),(222,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-28 17:03:57',2,NULL,'USER',2),(223,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-28 17:04:00',7,NULL,'USER',7),(224,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-28 17:07:33',7,NULL,'USER',7),(225,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-28 17:07:38',3,NULL,'USER',3),(226,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 17:13:32',3,NULL,'USER',3),(227,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:13:34',7,NULL,'USER',7),(228,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-09 17:14:41',7,NULL,'USER',7),(229,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 17:14:43',3,NULL,'USER',3),(230,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-12-30 17:20:07',3,NULL,'USER',3),(231,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-25 17:28:49',3,NULL,'USER',3),(232,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-25 17:44:26',3,NULL,'USER',3),(233,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-25 17:44:29',2,NULL,'USER',2),(234,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-25 17:44:46',2,NULL,'USER',2),(235,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-25 17:44:48',3,NULL,'USER',3),(236,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-25 17:45:18',3,NULL,'USER',3),(237,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-25 17:45:20',2,NULL,'USER',2),(238,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 23:50:29',3,NULL,'USER',3),(239,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 23:52:59',3,NULL,'USER',3),(240,6,'LOGIN','Tài khoản sm2_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 23:53:07',6,NULL,'USER',6),(241,6,'LOGOUT','Tài khoản sm2_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS2','0:0:0:0:0:0:0:1','2026-11-09 23:54:01',6,NULL,'USER',6),(242,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 23:54:09',3,NULL,'USER',3),(243,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-09 23:59:48',3,NULL,'USER',3),(244,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-09 23:59:50',2,NULL,'USER',2),(245,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-10 00:00:23',2,NULL,'USER',2),(246,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:00:25',3,NULL,'USER',3),(247,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 00:09:03',3,NULL,'USER',3),(248,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:09:05',2,NULL,'USER',2),(249,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-10 00:09:23',2,NULL,'USER',2),(250,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:09:25',3,NULL,'USER',3),(251,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 00:10:01',3,NULL,'USER',3),(252,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:10:04',2,NULL,'USER',2),(253,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-10 00:10:20',2,NULL,'USER',2),(254,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:10:22',3,NULL,'USER',3),(255,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-25 00:10:41',3,NULL,'USER',3),(256,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 00:11:36',3,NULL,'USER',3),(257,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:11:38',3,NULL,'USER',3),(258,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:11:55',3,NULL,'USER',3),(259,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-20 00:31:13',3,NULL,'USER',3),(260,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-20 00:33:54',3,NULL,'USER',3),(261,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-20 00:33:57',2,NULL,'USER',2),(262,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-10 00:34:27',2,NULL,'USER',2),(263,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:34:30',3,NULL,'USER',3),(264,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-24 00:34:46',3,NULL,'USER',3),(265,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 00:35:46',3,NULL,'USER',3),(266,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:35:48',3,NULL,'USER',3),(267,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 00:42:48',3,NULL,'USER',3),(268,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:42:51',7,NULL,'USER',7),(269,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 00:42:57',7,NULL,'USER',7),(270,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:43:04',3,NULL,'USER',3),(271,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 00:43:45',3,NULL,'USER',3),(272,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:43:48',2,NULL,'USER',2),(273,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-10 00:47:55',2,NULL,'USER',2),(274,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 00:47:57',3,NULL,'USER',3),(275,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-20 00:51:17',3,NULL,'USER',3),(276,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-20 01:13:38',3,NULL,'USER',3),(277,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-20 02:08:47',7,NULL,'USER',7),(278,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 02:17:03',7,NULL,'USER',7),(279,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:17:05',7,NULL,'USER',7),(280,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 02:18:44',7,NULL,'USER',7),(281,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:18:46',3,NULL,'USER',3),(282,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 02:20:00',3,NULL,'USER',3),(283,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:20:03',7,NULL,'USER',7),(284,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 02:55:47',7,NULL,'USER',7),(285,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:55:49',3,NULL,'USER',3),(286,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 02:59:27',3,NULL,'USER',3),(287,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 02:59:29',7,NULL,'USER',7),(288,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 04:27:54',7,NULL,'USER',7),(289,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 04:42:31',7,NULL,'USER',7),(290,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 04:42:34',3,NULL,'USER',3),(291,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 04:42:51',3,NULL,'USER',3),(292,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 04:42:53',7,NULL,'USER',7),(293,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 05:07:45',7,NULL,'USER',7),(294,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 05:07:47',3,NULL,'USER',3),(295,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 05:08:20',3,NULL,'USER',3),(296,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 05:08:31',7,NULL,'USER',7),(297,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 05:31:00',7,NULL,'USER',7),(298,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 05:58:58',7,NULL,'USER',7),(299,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 05:58:59',1,NULL,'USER',1),(300,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-10 05:59:09',1,NULL,'USER',1),(301,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 05:59:20',3,NULL,'USER',3),(302,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 05:59:36',3,NULL,'USER',3),(303,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 06:01:24',7,NULL,'USER',7),(304,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 07:07:30',3,NULL,'USER',3),(305,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 07:47:52',3,NULL,'USER',3),(306,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 13:18:35',3,NULL,'USER',3),(307,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 13:56:08',3,NULL,'USER',3),(308,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 13:56:10',7,NULL,'USER',7),(309,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 13:57:04',7,NULL,'USER',7),(310,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 13:57:06',3,NULL,'USER',3),(311,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 14:18:26',3,NULL,'USER',3),(312,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 14:18:28',7,NULL,'USER',7),(313,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 14:18:42',7,NULL,'USER',7),(314,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 14:18:43',3,NULL,'USER',3),(315,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 14:22:10',3,NULL,'USER',3),(316,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 14:22:12',7,NULL,'USER',7),(317,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 14:22:30',7,NULL,'USER',7),(318,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 14:22:32',3,NULL,'USER',3),(319,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 14:41:11',3,NULL,'USER',3),(320,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 14:41:13',7,NULL,'USER',7),(321,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 14:43:47',7,NULL,'USER',7),(322,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 14:43:50',3,NULL,'USER',3),(323,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 14:54:30',3,NULL,'USER',3),(324,3,'CREATE_USER','Tài khoản NV013 (Trần Văn Test15) | Tạo | Vai trò: Employee | Mật khẩu mặc định: 123456 | Bởi hrm_user','0:0:0:0:0:0:0:1','2026-11-10 14:57:42',3,20,'USER',20),(325,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:02:41',3,NULL,'USER',3),(326,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 15:04:32',3,NULL,'USER',3),(327,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:04:34',7,NULL,'USER',7),(328,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 15:04:43',7,NULL,'USER',7),(329,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:04:45',3,NULL,'USER',3),(330,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 15:13:01',3,NULL,'USER',3),(331,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:13:03',7,NULL,'USER',7),(332,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 15:18:52',7,NULL,'USER',7),(333,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:18:54',3,NULL,'USER',3),(334,3,'CREATE_USER','Tài khoản NV014 (Trần Văn Test14) | Tạo | Vai trò: Employee | Mật khẩu mặc định: 123456 | Bởi hrm_user','0:0:0:0:0:0:0:1','2026-11-10 15:24:15',3,21,'USER',21),(335,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:49:09',3,NULL,'USER',3),(336,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:52:14',3,NULL,'USER',3),(337,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 15:56:58',3,NULL,'USER',3),(338,3,'CREATE_USER','Tài khoản NV015 (Trần Văn Test14) | Tạo | Vai trò: Employee | Mật khẩu mặc định: 123456 | Bởi hrm_user','0:0:0:0:0:0:0:1','2026-11-10 15:59:49',3,22,'USER',22),(339,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 16:11:06',3,NULL,'USER',3),(340,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 16:11:13',7,NULL,'USER',7),(341,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-10 16:16:56',7,NULL,'USER',7),(342,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 16:16:58',3,NULL,'USER',3),(343,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-10 16:32:30',3,NULL,'USER',3),(344,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-10 16:32:37',7,NULL,'USER',7),(345,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 03:20:15',7,NULL,'USER',7),(346,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 04:09:43',7,NULL,'USER',7),(347,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 04:33:44',7,NULL,'USER',7),(348,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 04:39:02',7,NULL,'USER',7),(349,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 04:40:56',7,NULL,'USER',7),(350,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-11 05:29:21',7,NULL,'USER',7),(351,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 05:29:23',3,NULL,'USER',3),(352,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-11 05:38:54',3,NULL,'USER',3),(353,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 05:38:56',7,NULL,'USER',7),(354,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-11 05:51:30',7,NULL,'USER',7),(355,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 05:51:32',3,NULL,'USER',3),(356,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-11 05:52:28',3,NULL,'USER',3),(357,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 05:52:30',7,NULL,'USER',7),(358,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-11 06:15:37',7,NULL,'USER',7),(359,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 06:15:39',3,NULL,'USER',3),(360,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-11 06:26:57',3,NULL,'USER',3),(361,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 06:27:02',14,NULL,'USER',14),(362,14,'LOGOUT','Tài khoản NV007 | Đăng xuất | Thành công | Bởi Trần Văn Test7','0:0:0:0:0:0:0:1','2026-11-11 06:27:17',14,NULL,'USER',14),(363,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 06:27:19',7,NULL,'USER',7),(364,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-11 06:28:43',7,NULL,'USER',7),(365,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 06:28:45',14,NULL,'USER',14),(366,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-16 00:20:29',14,NULL,'USER',14),(367,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 00:21:17',14,NULL,'USER',14),(368,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:00:44',14,NULL,'USER',14),(369,14,'LOGOUT','Tài khoản NV007 | Đăng xuất | Thành công | Bởi Trần Văn Test7','0:0:0:0:0:0:0:1','2026-11-17 10:01:17',14,NULL,'USER',14),(370,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:01:24',7,NULL,'USER',7),(371,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-17 10:14:27',7,NULL,'USER',7),(372,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:14:29',3,NULL,'USER',3),(373,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-17 10:15:18',3,NULL,'USER',3),(374,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:15:19',7,NULL,'USER',7),(375,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-17 10:15:26',7,NULL,'USER',7),(376,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:15:31',3,NULL,'USER',3),(377,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-17 10:29:29',3,NULL,'USER',3),(378,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:29:32',7,NULL,'USER',7),(379,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-17 10:50:57',7,NULL,'USER',7),(380,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:51:00',14,NULL,'USER',14),(381,14,'LOGOUT','Tài khoản NV007 | Đăng xuất | Thành công | Bởi Trần Văn Test7','0:0:0:0:0:0:0:1','2026-11-17 10:53:38',14,NULL,'USER',14),(382,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:53:41',3,NULL,'USER',3),(383,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-17 10:57:35',3,NULL,'USER',3),(384,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-17 10:57:38',7,NULL,'USER',7),(385,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-11 07:52:08',7,NULL,'USER',7),(386,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 07:52:10',14,NULL,'USER',14),(387,14,'LOGOUT','Tài khoản NV007 | Đăng xuất | Thành công | Bởi Trần Văn Test7','0:0:0:0:0:0:0:1','2026-11-11 07:52:44',14,NULL,'USER',14),(388,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-11 07:52:47',15,NULL,'USER',15),(389,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 08:09:29',15,NULL,'USER',15),(390,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-12 08:16:31',15,NULL,'USER',15),(391,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 08:16:32',7,NULL,'USER',7),(392,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 08:53:13',7,NULL,'USER',7),(393,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-12 08:59:50',7,NULL,'USER',7),(394,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 08:59:54',14,NULL,'USER',14),(395,14,'LOGOUT','Tài khoản NV007 | Đăng xuất | Thành công | Bởi Trần Văn Test7','0:0:0:0:0:0:0:1','2026-11-12 09:00:01',14,NULL,'USER',14),(396,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 09:00:04',7,NULL,'USER',7),(397,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-12 09:00:51',7,NULL,'USER',7),(398,14,'LOGIN','Tài khoản NV007 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 09:00:54',14,NULL,'USER',14),(399,14,'LOGOUT','Tài khoản NV007 | Đăng xuất | Thành công | Bởi Trần Văn Test7','0:0:0:0:0:0:0:1','2026-11-12 09:07:02',14,NULL,'USER',14),(400,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 09:07:04',15,NULL,'USER',15),(401,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-12 09:12:59',15,NULL,'USER',15),(402,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 09:13:03',7,NULL,'USER',7),(403,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 14:26:27',15,NULL,'USER',15),(404,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-12 15:04:18',15,NULL,'USER',15),(405,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 15:04:21',7,NULL,'USER',7),(406,7,'EMERGENCY_LOCK','Emergency Lock bởi Store Manager',NULL,'2026-11-12 15:04:40',7,21,'USER',21),(407,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-12 15:35:32',7,NULL,'USER',7),(408,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 15:35:33',3,NULL,'USER',3),(409,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-12 15:53:05',3,NULL,'USER',3),(410,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 15:53:07',2,NULL,'USER',2),(411,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-12 15:55:01',2,NULL,'USER',2),(412,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 15:55:05',1,NULL,'USER',1),(413,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 16:44:25',15,NULL,'USER',15),(414,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 17:02:28',15,NULL,'USER',15),(415,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:42:22',3,NULL,'USER',3),(416,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 03:47:10',3,NULL,'USER',3),(417,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:47:15',7,NULL,'USER',7),(418,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:17:33',15,NULL,'USER',15),(419,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-13 06:18:07',15,NULL,'USER',15),(420,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:18:09',7,NULL,'USER',7),(421,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-13 06:18:47',7,NULL,'USER',7),(422,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:18:49',3,NULL,'USER',3),(423,3,'CREATE_USER','Tài khoản NV016 (Trần Văn Test20) | Tạo | Vai trò: Employee | Mật khẩu mặc định: 123456 | Bởi hrm_user','0:0:0:0:0:0:0:1','2026-11-13 06:19:22',3,23,'USER',23),(424,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 06:19:30',3,NULL,'USER',3),(425,23,'LOGIN','Tài khoản NV016 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:19:38',23,NULL,'USER',23),(426,23,'LOGOUT','Tài khoản NV016 | Đăng xuất | Thành công | Bởi Trần Văn Test20','0:0:0:0:0:0:0:1','2026-11-13 06:19:59',23,NULL,'USER',23),(427,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:20:01',7,NULL,'USER',7),(428,7,'EMERGENCY_UNLOCK','Emergency Unlock bởi Store Manager',NULL,'2026-11-13 06:20:06',7,21,'USER',21),(429,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-13 06:24:37',7,NULL,'USER',7),(430,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:24:40',3,NULL,'USER',3),(431,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 06:24:48',3,NULL,'USER',3),(432,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:24:52',2,NULL,'USER',2),(433,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-13 06:26:44',2,NULL,'USER',2),(434,23,'LOGIN','Tài khoản NV016 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:26:46',23,NULL,'USER',23),(435,23,'LOGOUT','Tài khoản NV016 | Đăng xuất | Thành công | Bởi Trần Văn Test20','0:0:0:0:0:0:0:1','2026-11-13 06:27:51',23,NULL,'USER',23),(436,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:27:54',7,NULL,'USER',7),(437,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-13 06:28:12',7,NULL,'USER',7),(438,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:28:16',3,NULL,'USER',3),(439,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 06:30:18',3,NULL,'USER',3),(440,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:30:22',2,NULL,'USER',2),(441,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-13 06:30:23',2,NULL,'USER',2),(442,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 08:24:56',2,NULL,'USER',2),(443,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-13 08:26:08',2,NULL,'USER',2),(444,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 08:26:12',1,NULL,'USER',1),(445,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-13 08:28:44',1,NULL,'USER',1),(446,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 08:28:46',1,NULL,'USER',1),(447,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-13 08:28:49',1,NULL,'USER',1),(448,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 08:28:53',3,NULL,'USER',3),(449,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 08:48:01',3,NULL,'USER',3),(450,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 08:48:05',7,NULL,'USER',7),(451,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-13 09:04:19',7,NULL,'USER',7),(452,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 09:04:22',15,NULL,'USER',15),(453,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-13 09:15:35',15,NULL,'USER',15),(454,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 09:15:41',3,NULL,'USER',3),(455,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 09:18:04',3,NULL,'USER',3),(456,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 09:18:06',7,NULL,'USER',7),(457,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-13 09:23:59',7,NULL,'USER',7),(458,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 09:24:01',15,NULL,'USER',15),(459,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 10:25:46',7,NULL,'USER',7),(460,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-12 10:38:06',7,NULL,'USER',7),(461,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 10:38:08',3,NULL,'USER',3),(462,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-12 10:39:21',3,NULL,'USER',3),(463,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 10:39:24',7,NULL,'USER',7),(464,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-12 10:39:57',7,NULL,'USER',7),(465,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 10:40:02',3,NULL,'USER',3),(466,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-12 10:40:23',3,NULL,'USER',3),(467,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 10:40:25',7,NULL,'USER',7),(468,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 13:32:38',7,NULL,'USER',7),(469,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-12 13:33:16',7,NULL,'USER',7),(470,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 13:33:20',3,NULL,'USER',3),(471,3,'CREATE_USER','Tài khoản NV017 (Trần Văn Test21) | Tạo | Vai trò: Employee | Mật khẩu mặc định: 123456 | Bởi hrm_user','0:0:0:0:0:0:0:1','2026-11-12 13:36:36',3,24,'USER',24),(472,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-12 13:38:03',3,NULL,'USER',3),(473,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 13:38:06',7,NULL,'USER',7),(474,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 14:48:00',7,NULL,'USER',7),(475,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-12 14:48:58',7,NULL,'USER',7),(476,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 14:49:03',3,NULL,'USER',3),(477,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 16:03:34',2,NULL,'USER',2),(478,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-12 16:03:53',2,NULL,'USER',2),(479,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 16:03:57',3,NULL,'USER',3),(480,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-12 16:04:36',3,NULL,'USER',3),(481,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 16:04:40',2,NULL,'USER',2),(482,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-12 16:06:45',2,NULL,'USER',2),(483,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 16:06:48',3,NULL,'USER',3),(484,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-12 16:12:39',3,NULL,'USER',3),(485,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 16:12:43',2,NULL,'USER',2),(486,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-12 16:26:30',2,NULL,'USER',2),(487,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-12 16:26:34',3,NULL,'USER',3),(488,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 01:15:45',1,NULL,'USER',1),(489,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-13 01:31:12',1,NULL,'USER',1),(490,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 01:31:15',2,NULL,'USER',2),(491,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-13 01:36:54',2,NULL,'USER',2),(492,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 01:36:57',3,NULL,'USER',3),(493,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 01:43:53',3,NULL,'USER',3),(494,6,'LOGIN','Tài khoản sm2_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 01:43:59',6,NULL,'USER',6),(495,6,'LOGOUT','Tài khoản sm2_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS2','0:0:0:0:0:0:0:1','2026-11-13 01:44:03',6,NULL,'USER',6),(496,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 01:44:05',3,NULL,'USER',3),(497,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 01:55:40',3,NULL,'USER',3),(498,6,'LOGIN','Tài khoản sm2_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 01:55:42',6,NULL,'USER',6),(499,6,'LOGOUT','Tài khoản sm2_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS2','0:0:0:0:0:0:0:1','2026-11-13 02:18:25',6,NULL,'USER',6),(500,15,'LOGIN','Tài khoản NV008 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 02:18:27',15,NULL,'USER',15),(501,15,'LOGOUT','Tài khoản NV008 | Đăng xuất | Thành công | Bởi Trần Văn Test8','0:0:0:0:0:0:0:1','2026-11-13 02:39:04',15,NULL,'USER',15),(502,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 02:39:09',1,NULL,'USER',1),(503,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-13 02:41:12',1,NULL,'USER',1),(504,23,'LOGIN','Tài khoản NV016 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 02:41:13',23,NULL,'USER',23),(505,23,'LOGOUT','Tài khoản NV016 | Đăng xuất | Thành công | Bởi Trần Văn Test20','0:0:0:0:0:0:0:1','2026-11-13 02:41:15',23,NULL,'USER',23),(506,23,'LOGIN','Tài khoản NV016 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 02:41:19',23,NULL,'USER',23),(507,23,'LOGOUT','Tài khoản NV016 | Đăng xuất | Thành công | Bởi Trần Văn Test20','0:0:0:0:0:0:0:1','2026-11-13 02:42:39',23,NULL,'USER',23),(508,1,'LOGIN_FAILED','Tài khoản admin_user | Đăng nhập thất bại | Thất bại - sai tên đăng nhập hoặc mật khẩu | Tài khoản tồn tại: Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-13 02:42:41',1,NULL,NULL,NULL),(509,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 02:42:48',1,NULL,'USER',1),(510,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:09:26',1,NULL,'USER',1),(511,1,'LOGOUT','Tài khoản admin_user | Đăng xuất | Thành công | Bởi Quản Trị Viên Hệ Thống','0:0:0:0:0:0:0:1','2026-11-13 03:12:26',1,NULL,'USER',1),(512,23,'LOGIN','Tài khoản NV016 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:12:28',23,NULL,'USER',23),(513,23,'LOGOUT','Tài khoản NV016 | Đăng xuất | Thành công | Bởi Trần Văn Test20','0:0:0:0:0:0:0:1','2026-11-13 03:13:13',23,NULL,'USER',23),(514,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:13:16',1,NULL,'USER',1),(515,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:18:27',2,NULL,'USER',2),(516,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:18:27',2,NULL,'USER',2),(517,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-13 03:18:42',2,NULL,'USER',2),(518,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:18:45',3,NULL,'USER',3),(519,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 03:18:55',3,NULL,'USER',3),(520,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:19:00',7,NULL,'USER',7),(521,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-13 03:22:23',7,NULL,'USER',7),(522,13,'LOGIN','Tài khoản NV006 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:22:27',13,NULL,'USER',13),(523,13,'LOGOUT','Tài khoản NV006 | Đăng xuất | Thành công | Bởi Trần Văn Test6','0:0:0:0:0:0:0:1','2026-11-13 03:22:52',13,NULL,'USER',13),(524,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:22:54',7,NULL,'USER',7),(525,7,'LOGOUT','Tài khoản sm3_user | Đăng xuất | Thành công | Bởi Quản Lý Cửa Hàng CS3','0:0:0:0:0:0:0:1','2026-11-13 03:24:32',7,NULL,'USER',7),(526,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:24:35',3,NULL,'USER',3),(527,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 03:25:14',3,NULL,'USER',3),(528,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 03:25:19',2,NULL,'USER',2),(529,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 04:07:00',1,NULL,'USER',1),(530,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 04:57:10',2,NULL,'USER',2),(531,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-13 04:58:59',2,NULL,'USER',2),(532,1,'LOGIN','Tài khoản admin_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 05:00:06',1,NULL,'USER',1),(533,2,'LOGIN','Tài khoản director_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 05:41:25',2,NULL,'USER',2),(534,2,'LOGOUT','Tài khoản director_user | Đăng xuất | Thành công | Bởi Giám Đốc Chuỗi','0:0:0:0:0:0:0:1','2026-11-13 05:42:10',2,NULL,'USER',2),(535,3,'LOGIN','Tài khoản hrm_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 05:42:12',3,NULL,'USER',3),(536,3,'LOGOUT','Tài khoản hrm_user | Đăng xuất | Thành công | Bởi Quản Lý Nhân Sự','0:0:0:0:0:0:0:1','2026-11-13 06:31:18',3,NULL,'USER',3),(537,7,'LOGIN','Tài khoản sm3_user | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 06:31:22',7,NULL,'USER',7),(538,13,'LOGIN','Tài khoản NV006 | Đăng nhập | Thành công','0:0:0:0:0:0:0:1','2026-11-13 07:22:25',13,NULL,'USER',13);
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_manager_assignments`
--

DROP TABLE IF EXISTS `branch_manager_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branch_manager_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_id` int NOT NULL,
  `manager_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `assigned_by` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `extend_reason` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branch_id` (`branch_id`),
  KEY `manager_id` (`manager_id`),
  KEY `assigned_by` (`assigned_by`),
  CONSTRAINT `branch_manager_assignments_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `branch_manager_assignments_ibfk_2` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`),
  CONSTRAINT `branch_manager_assignments_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_manager_assignments`
--

LOCK TABLES `branch_manager_assignments` WRITE;
/*!40000 ALTER TABLE `branch_manager_assignments` DISABLE KEYS */;
INSERT INTO `branch_manager_assignments` VALUES (1,4,7,'2026-11-06','2026-12-09',3,'2026-11-03 23:57:04','test'),(2,6,7,'2026-11-15','2026-11-29',3,'2026-11-09 21:34:19',NULL),(3,7,6,'2026-11-10','2026-12-12',3,'2026-11-09 21:38:37','DFDF'),(4,5,6,'2026-11-15','2026-12-26',3,'2026-11-10 06:51:35',NULL),(5,8,7,'2026-11-22','2026-11-29',3,'2026-11-10 07:02:27',NULL),(6,9,7,'2026-11-15','2026-11-30',3,'2026-11-10 07:42:38',NULL),(7,10,7,'2026-11-20','2026-11-30',3,'2026-11-20 07:51:56',NULL),(8,11,4,'2026-11-15','2026-11-25',3,'2026-11-12 23:09:35',NULL);
/*!40000 ALTER TABLE `branch_manager_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_requests`
--

DROP TABLE IF EXISTS `branch_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branch_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_name` varchar(150) NOT NULL,
  `branch_address` varchar(255) NOT NULL,
  `expected_opening_date` date NOT NULL,
  `reason` text NOT NULL,
  `requested_by` int NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'PENDING_HR',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `branch_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_branch_request_branch` (`branch_id`),
  CONSTRAINT `fk_branch_request_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_requests`
--

LOCK TABLES `branch_requests` WRITE;
/*!40000 ALTER TABLE `branch_requests` DISABLE KEYS */;
INSERT INTO `branch_requests` VALUES (1,'Siêu thị Cơ sở 4','123 Xuân Phương ,Hà Nội','2026-11-06','test',2,'COMPLETED','2026-11-03 22:48:04',4),(2,'Siêu thị Cơ sở 5','123 Văn Phong ,Hà Nội','2026-11-20','test',2,'IN_PROGRESS','2026-11-09 09:05:09',5),(3,'Siêu thị Cơ sở 6','123 Thanh Phong ,Hà Nội','2026-11-10','test',2,'COMPLETED','2026-11-09 20:34:00',6),(4,'Siêu thị Cơ sở 7','124 Văn Phong ,Hà Nội','2026-11-11','test',2,'IN_PROGRESS','2026-11-09 21:06:33',7),(5,'Siêu thị Cơ sở ́','126 Văn Phong ,Hà Nội','2026-11-20','test',2,'IN_PROGRESS','2026-11-10 07:00:17',8),(6,'Siêu thị Cơ sở 8','128 Văn Phong ,Hà Nội','2026-11-20','test',2,'IN_PROGRESS','2026-11-10 07:09:18',9),(7,'Siêu thị Cơ sở 9','129 Văn Phong ,Hà Nội','2026-11-20','test',2,'IN_PROGRESS','2026-11-10 07:10:17',10),(8,'Siêu thị Cơ sở 10','130 Văn Phong ,Hà Nội','2026-11-20','test',2,'IN_PROGRESS','2026-11-10 07:34:25',11);
/*!40000 ALTER TABLE `branch_requests` ENABLE KEYS */;
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
  `status` enum('ACTIVE','INACTIVE','CLOSED','PREPARING') COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `store_manager_id` int DEFAULT NULL COMMENT 'Chỉ định Store Manager phụ trách',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `store_manager_id` (`store_manager_id`),
  CONSTRAINT `branches_ibfk_1` FOREIGN KEY (`store_manager_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
INSERT INTO `branches` VALUES (1,'BR001','Siêu thị Cơ sở 1 - Cầu Giấy','123 Cầu Giấy, Hà Nội','ACTIVE',4,'2026-09-22 16:50:49'),(2,'BR002','Siêu thị Cơ sở 2 - Đống Đa','456 Tây Sơn, Hà Nội','ACTIVE',6,'2026-09-22 16:50:49'),(3,'BR003','Siêu thị Cơ sở 3 - Hà Đông','789 Quang Trung, Hà Nội','ACTIVE',7,'2026-09-22 16:50:49'),(4,'BR004','Siêu thị Cơ sở 4','123 Xuân Phương ,Hà Nội','ACTIVE',7,'2026-11-03 16:29:43'),(5,'BR005','Siêu thị Cơ sở 5','123 Văn Phong ,Hà Nội','PREPARING',6,'2026-11-09 02:05:32'),(6,'BR006','Siêu thị Cơ sở 6','123 Thanh Phong ,Hà Nội','ACTIVE',7,'2026-11-09 13:58:50'),(7,'BR007','Siêu thị Cơ sở 7','124 Văn Phong ,Hà Nội','PREPARING',6,'2026-11-09 14:09:01'),(8,'BR008','Siêu thị Cơ sở ́','126 Văn Phong ,Hà Nội','PREPARING',7,'2026-11-10 00:00:32'),(9,'BR009','Siêu thị Cơ sở 8','128 Văn Phong ,Hà Nội','PREPARING',7,'2026-11-10 00:09:29'),(10,'BR010','Siêu thị Cơ sở 9','129 Văn Phong ,Hà Nội','PREPARING',7,'2026-11-20 00:31:18'),(11,'BR011','Siêu thị Cơ sở 10','130 Văn Phong ,Hà Nội','PREPARING',4,'2026-11-24 00:34:58');
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `candidates`
--

LOCK TABLES `candidates` WRITE;
/*!40000 ALTER TABLE `candidates` DISABLE KEYS */;
INSERT INTO `candidates` VALUES (1,'Trần Văn Test1','test1@gmail.com','0900000001','090000000001','2026-10-19 10:10:29'),(2,'Trần Văn Test2','test2@gmail.com','0900000002','090000000002','2026-10-19 10:10:54'),(3,'Trần Văn Test3','test3@gmail.com','0900000003','090000000003','2026-10-19 10:11:23'),(4,'Trần Văn Test4','test4@gmail.com','0900000004','090000000004','2026-10-19 10:11:59'),(5,'Trần Văn Test5','test5@gmail.com','0900000005','090000000005','2026-10-19 10:12:18'),(6,'Trần Văn Test6','test6@gmail.com','0900000006','090000000006','2026-10-19 10:12:38'),(7,'Trần Văn Test7','test7@gmail.com','0900000007','090000000007','2026-10-19 10:13:04'),(8,'Trần Văn Test8','test8@gmail.com','0900000008','090000000008','2026-10-19 10:13:21'),(9,'Trần Văn Test9','test9@gmail.com','0900000009','090000000009','2026-10-19 10:13:45'),(10,'Trần Văn Test10','test10@gmail.com','0900000012','090000000010','2026-10-25 07:47:12'),(11,'Trần Văn Test1',NULL,'0900000011','090000000011','2026-11-07 13:57:32'),(12,'Trần Văn Test1','test1@gmail.com','0900000001','090000000001','2026-11-10 02:55:23'),(13,'Trần Văn Phong',NULL,'0900000001','090000000010','2026-11-10 03:27:48'),(14,'Trần Văn Phong',NULL,'0900000020','090000000011','2026-11-10 04:28:44'),(15,'Trần Văn Test15',NULL,'0900000015','090000000015','2026-11-10 13:56:58'),(16,'Trần Văn Test16',NULL,'0900000016','090000000016','2026-11-10 14:43:45');
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
INSERT INTO `contracts` VALUES (1,8,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(2,9,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(3,10,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(4,11,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(5,12,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(6,13,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(7,14,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(8,15,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(9,16,'Hợp đồng CHÍNH THỨC','2026-10-19',NULL,'ACTIVE'),(10,17,'Hợp đồng THỜI VỤ','2026-11-07','2026-11-15','ACTIVE'),(11,18,'Hợp đồng CHÍNH THỨC','2026-11-10',NULL,'ACTIVE'),(12,19,'Hợp đồng CHÍNH THỨC','2026-11-10',NULL,'ACTIVE'),(13,20,'Hợp đồng THỜI VỤ','2026-11-10','2026-11-15','ACTIVE'),(14,21,'Hợp đồng CHÍNH THỨC','2026-11-10',NULL,'ACTIVE'),(15,22,'Hợp đồng THỜI VỤ','2026-11-10','2026-11-10','ACTIVE'),(16,23,'Hợp đồng CHÍNH THỨC','2026-11-13',NULL,'ACTIVE'),(17,24,'Hợp đồng CHÍNH THỨC','2026-11-12',NULL,'ACTIVE');
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
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_availabilities`
--

LOCK TABLES `employee_availabilities` WRITE;
/*!40000 ALTER TABLE `employee_availabilities` DISABLE KEYS */;
INSERT INTO `employee_availabilities` VALUES (2,16,'TUESDAY',1,'2026-10-26'),(3,16,'WEDNESDAY',1,'2026-10-26'),(4,16,'THURSDAY',1,'2026-10-26'),(5,16,'FRIDAY',1,'2026-10-26'),(6,16,'SATURDAY',1,'2026-10-26'),(7,16,'SUNDAY',1,'2026-10-26'),(8,15,'MONDAY',1,'2026-10-26'),(9,15,'TUESDAY',1,'2026-10-26'),(10,15,'WEDNESDAY',1,'2026-10-26'),(11,15,'THURSDAY',1,'2026-10-26'),(12,15,'FRIDAY',1,'2026-10-26'),(13,15,'SATURDAY',1,'2026-10-26'),(14,15,'SUNDAY',1,'2026-10-26'),(15,15,'MONDAY',2,'2026-10-26'),(16,15,'TUESDAY',2,'2026-10-26'),(17,15,'WEDNESDAY',2,'2026-10-26'),(18,15,'THURSDAY',2,'2026-10-26'),(19,15,'FRIDAY',2,'2026-10-26'),(20,15,'SATURDAY',2,'2026-10-26'),(21,15,'SUNDAY',2,'2026-10-26'),(22,13,'MONDAY',1,'2026-10-26'),(23,13,'TUESDAY',1,'2026-10-26'),(24,13,'WEDNESDAY',1,'2026-10-26'),(25,13,'THURSDAY',1,'2026-10-26'),(26,13,'FRIDAY',1,'2026-10-26'),(27,13,'SATURDAY',1,'2026-10-26'),(28,13,'SUNDAY',1,'2026-10-26'),(29,12,'MONDAY',1,'2026-10-26'),(30,12,'TUESDAY',1,'2026-10-26'),(31,12,'WEDNESDAY',1,'2026-10-26'),(32,12,'THURSDAY',1,'2026-10-26'),(33,12,'FRIDAY',1,'2026-10-26'),(34,12,'SATURDAY',1,'2026-10-26'),(35,12,'SUNDAY',1,'2026-10-26'),(36,13,'MONDAY',1,'2026-11-30'),(37,13,'TUESDAY',1,'2026-11-30'),(38,13,'WEDNESDAY',1,'2026-11-30'),(39,13,'THURSDAY',1,'2026-11-30'),(40,13,'FRIDAY',1,'2026-11-30'),(41,13,'SATURDAY',1,'2026-11-30'),(42,13,'SUNDAY',1,'2026-11-30'),(43,16,'MONDAY',1,'2026-11-30'),(44,16,'TUESDAY',1,'2026-11-30'),(45,16,'WEDNESDAY',1,'2026-11-30'),(46,16,'THURSDAY',1,'2026-11-30'),(47,16,'FRIDAY',1,'2026-11-30'),(48,16,'SATURDAY',1,'2026-11-30'),(49,16,'SUNDAY',1,'2026-11-30'),(50,15,'MONDAY',1,'2026-11-30'),(51,15,'TUESDAY',1,'2026-11-30'),(52,15,'WEDNESDAY',1,'2026-11-30'),(53,15,'THURSDAY',1,'2026-11-30'),(54,15,'FRIDAY',1,'2026-11-30'),(55,15,'SATURDAY',1,'2026-11-30'),(56,15,'SUNDAY',1,'2026-11-30'),(57,12,'MONDAY',1,'2026-11-30'),(58,12,'TUESDAY',1,'2026-11-30'),(59,12,'WEDNESDAY',1,'2026-11-30'),(60,12,'THURSDAY',1,'2026-11-30'),(61,12,'FRIDAY',1,'2026-11-30'),(62,15,'MONDAY',1,'2026-11-09'),(63,15,'TUESDAY',1,'2026-11-09'),(64,15,'WEDNESDAY',1,'2026-11-09'),(65,15,'THURSDAY',1,'2026-11-09'),(66,15,'FRIDAY',1,'2026-11-09'),(67,15,'SATURDAY',1,'2026-11-09'),(68,16,'MONDAY',1,'2026-11-09'),(69,16,'TUESDAY',1,'2026-11-09'),(70,16,'WEDNESDAY',1,'2026-11-09'),(71,16,'THURSDAY',1,'2026-11-09'),(72,16,'FRIDAY',1,'2026-11-09'),(73,16,'SATURDAY',1,'2026-11-09'),(79,15,'WEDNESDAY',1,'2026-11-16'),(80,15,'THURSDAY',1,'2026-11-16'),(81,15,'FRIDAY',1,'2026-11-16'),(82,15,'SATURDAY',1,'2026-11-16'),(83,15,'SUNDAY',1,'2026-11-16');
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_locks`
--

LOCK TABLES `employee_locks` WRITE;
/*!40000 ALTER TABLE `employee_locks` DISABLE KEYS */;
INSERT INTO `employee_locks` VALUES (1,11,6,6,NULL,'2026-10-27 08:11:29','2026-10-27 08:11:56',0),(2,11,6,6,NULL,'2026-10-27 08:15:50','2026-10-29 07:45:04',0),(3,14,7,7,'đ','2026-11-07 14:30:59','2026-11-07 14:31:31',0),(4,17,7,7,'dd','2026-11-07 14:31:17','2026-11-07 14:31:46',0),(5,21,7,7,NULL,'2026-11-12 15:04:40','2026-11-13 06:20:06',0);
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
INSERT INTO `employee_profiles` VALUES (1,'Quản Trị Viên Hệ Thống','0901111111','001090000001',1,3,3,'FULL_TIME',NULL,10.00),(2,'Giám Đốc Chuỗi','0902222222','001090000002',1,1,1,'FULL_TIME',NULL,10.00),(3,'Quản Lý Nhân Sự','0903333333','001090000003',1,2,2,'FULL_TIME',NULL,10.00),(4,'Quản Lý Cửa Hàng CS1','0904444444','001090000004',1,4,4,'FULL_TIME',NULL,10.00),(5,'Nhân Viên Bán Hàng CS1','0905555555','001090000005',1,6,5,'FULL_TIME',NULL,10.00),(6,'Quản Lý Cửa Hàng CS2','0906666666','001090000006',2,4,4,'FULL_TIME',NULL,10.00),(7,'Quản Lý Cửa Hàng CS3','0907777777','001090000007',3,4,4,'FULL_TIME',NULL,10.00),(8,'Trần Văn Test1','0900000001','090000000001',1,7,5,'FULL_TIME','FT_ROTATING',10.00),(9,'Trần Văn Test2','0900000002','090000000002',1,7,5,'PART_TIME','PT_FLEXIBLE',10.00),(10,'Trần Văn Test3','0900000003','090000000003',1,7,5,'PART_TIME','PT_FIXED_MORNING',10.00),(11,'Trần Văn Test4','0900000004','090000000004',2,7,5,'FULL_TIME','FT_ROTATING',10.00),(12,'Trần Văn Test5','0900000005','090000000005',2,7,5,'PART_TIME','PT_FLEXIBLE',10.00),(13,'Trần Văn Test6','0900000006','090000000006',2,7,5,'PART_TIME','PT_FIXED_MORNING',10.00),(14,'Trần Văn Test7','0900000007','090000000007',3,7,5,'FULL_TIME','FT_ROTATING',10.00),(15,'Trần Văn Test8','0900000008','090000000008',3,7,5,'PART_TIME','PT_FLEXIBLE',10.00),(16,'Trần Văn Test9','0900000009','090000000009',3,7,5,'PART_TIME','PT_FIXED_MORNING',10.00),(17,'Trần Văn Test1','0900000011','090000000011',4,9,4,'FULL_TIME','FT_ROTATING',10.00),(18,'Trần Văn Test12','0900000012','090000000012',4,6,5,'PART_TIME','PT_FLEXIBLE',10.00),(19,'Trần Văn Test13','0900000013','090000000013',4,6,5,'PART_TIME','PT_FLEXIBLE',10.00),(20,'Trần Văn Test15','0900000015','090000000015',3,7,5,'FULL_TIME','FT_ROTATING',10.00),(21,'Trần Văn Test14','0900000014','090000000010',3,7,5,'FULL_TIME','FT_ROTATING',10.00),(22,'Trần Văn Test14','0900000017','090000000017',4,6,5,'PART_TIME','PT_FLEXIBLE',10.00),(23,'Trần Văn Test20','0900000020','090000000020',3,7,5,'FULL_TIME','FT_ROTATING',10.00),(24,'Trần Văn Test21','0900000021','090000000021',3,6,5,'FULL_TIME','FT_ROTATING',10.00);
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
INSERT INTO `employee_salary_configs` VALUES (14,9000000.00,0.00,0.00,3,'2026-11-17 10:18:20');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_proposals`
--

LOCK TABLES `recruitment_proposals` WRITE;
/*!40000 ALTER TABLE `recruitment_proposals` DISABLE KEYS */;
INSERT INTO `recruitment_proposals` VALUES (1,1,1,7,'FULL_TIME',5,NULL,'2026-10-20','test','APPROVED',4,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV001 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:10:29','2026-10-19 10:14:10','FT_ROTATING'),(2,2,1,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',4,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV002 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:10:54','2026-10-19 10:14:15','PT_FLEXIBLE'),(3,3,1,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',4,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV003 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:11:23','2026-10-19 10:14:19','PT_FIXED_MORNING'),(4,4,2,7,'FULL_TIME',5,NULL,'2026-10-20','test','APPROVED',6,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV004 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:11:59','2026-10-19 10:14:24','FT_ROTATING'),(5,5,2,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',6,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV005 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:12:18','2026-10-19 10:14:28','PT_FLEXIBLE'),(6,6,2,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',6,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV006 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:12:38','2026-10-19 10:14:31','PT_FIXED_MORNING'),(7,7,3,7,'FULL_TIME',5,NULL,'2026-10-20','test','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV007 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:13:04','2026-10-19 10:14:34','FT_ROTATING'),(8,8,3,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV008 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:13:21','2026-10-19 10:14:38','PT_FLEXIBLE'),(9,9,3,7,'PART_TIME',5,NULL,'2026-10-20','test','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV009 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-10-19 10:13:45','2026-10-19 10:14:41','PT_FIXED_MORNING'),(10,10,3,7,'FULL_TIME',5,NULL,'2026-11-20','test ok','REJECTED',7,3,'test','2026-10-25 07:47:12','2026-11-10 05:08:17','FT_ROTATING'),(11,11,4,9,'FULL_TIME',4,'2026-11-15','2026-11-08','test','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV010 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-11-07 13:57:32','2026-11-07 14:08:46','FT_ROTATING'),(12,12,3,7,'FULL_TIME',5,NULL,'2026-11-25','Bổ sung nhân sự cho ca bán hàng','REJECTED',7,3,'test','2026-11-10 02:55:23','2026-11-10 05:08:07','FT_ROTATING'),(13,13,3,7,'FULL_TIME',5,'2026-11-10','2026-11-11','fgffg','REJECTED',7,3,'test','2026-11-10 03:27:48','2026-11-10 05:07:59','FT_ROTATING'),(14,14,3,7,'FULL_TIME',5,'2026-11-12','2026-11-11','sddfef','PENDING',7,3,NULL,'2026-11-10 04:28:44','2026-11-10 14:22:29','FT_ROTATING'),(15,15,3,7,'FULL_TIME',5,'2026-11-15','2026-11-12','test','APPROVED',7,3,'Đã phê duyệt. Tài khoản cấp mới - Username: NV013 | Mật khẩu mặc định: 123456 (Yêu cầu đổi khi đăng nhập lần đầu)','2026-11-10 13:56:58','2026-11-10 14:57:42','FT_ROTATING'),(16,16,3,7,'FULL_TIME',5,'2026-11-30','2026-11-15','test','PENDING',7,NULL,NULL,'2026-11-10 14:43:45','2026-11-10 14:43:45','FT_ROTATING');
/*!40000 ALTER TABLE `recruitment_proposals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recruitment_requests`
--

DROP TABLE IF EXISTS `recruitment_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recruitment_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branch_id` int NOT NULL,
  `requested_by` int NOT NULL,
  `position_id` int NOT NULL,
  `quantity` int NOT NULL,
  `employment_type` enum('FULL_TIME','PART_TIME') NOT NULL,
  `shift_type` varchar(50) NOT NULL,
  `target_date` date NOT NULL,
  `reason` text NOT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  `reviewed_by` int DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `hr_note` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_rr_requester` (`requested_by`),
  KEY `fk_rr_position` (`position_id`),
  KEY `fk_rr_reviewer` (`reviewed_by`),
  KEY `idx_rr_branch_status` (`branch_id`,`status`),
  KEY `idx_rr_created_at` (`created_at`),
  CONSTRAINT `fk_rr_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_rr_position` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`),
  CONSTRAINT `fk_rr_requester` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rr_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_rr_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recruitment_requests`
--

LOCK TABLES `recruitment_requests` WRITE;
/*!40000 ALTER TABLE `recruitment_requests` DISABLE KEYS */;
INSERT INTO `recruitment_requests` VALUES (1,4,7,6,3,'PART_TIME','PT_FLEXIBLE','2026-11-20','test','APPROVED',3,'2026-11-10 22:28:22',NULL,'2026-11-10 02:44:50','2026-11-10 22:28:22'),(2,3,7,10,2,'FULL_TIME','FT_FIXED_MORNING','2026-11-12','ddfdfdf','REJECTED',3,'2026-11-10 20:26:39','test','2026-11-10 08:37:31','2026-11-10 20:26:39'),(3,3,7,7,2,'FULL_TIME','FT_ROTATING','2026-11-15','thiếu','APPROVED',3,'2026-11-10 20:23:36',NULL,'2026-11-10 09:18:15','2026-11-10 20:23:36'),(4,3,7,7,1,'FULL_TIME','FT_FIXED_MORNING','2026-11-10','fgfg','REJECTED',3,'2026-11-10 11:42:45','cc','2026-11-10 09:36:20','2026-11-10 11:42:45'),(5,3,7,6,2,'FULL_TIME','FT_ROTATING','2026-11-14','tesst','APPROVED',3,'2026-11-12 20:34:37',NULL,'2026-11-12 20:33:13','2026-11-12 20:34:37');
/*!40000 ALTER TABLE `recruitment_requests` ENABLE KEYS */;
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
  `target_user_id` int DEFAULT NULL,
  `shift_schedule_id` int DEFAULT NULL,
  `target_shift_schedule_id` int DEFAULT NULL,
  `status` enum('WAITING_COLLEAGUE','PENDING','APPROVED','REJECTED','DECLINED','CANCELLED') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'WAITING_COLLEAGUE',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `response` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `colleague_responded_at` datetime DEFAULT NULL,
  `colleague_response` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_type` enum('SWAP','OPEN','EXTRA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SWAP',
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shift_requirements`
--

LOCK TABLES `shift_requirements` WRITE;
/*!40000 ALTER TABLE `shift_requirements` DISABLE KEYS */;
INSERT INTO `shift_requirements` VALUES (1,2,7,1,1,'2026-10-26'),(2,2,7,1,1,'2026-11-30'),(3,4,7,1,3,'2026-11-09'),(4,3,7,1,1,'2026-11-09'),(5,3,7,4,2,'2026-11-17'),(6,3,7,4,2,'2026-11-16'),(7,3,7,4,2,'2026-11-19');
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
) ENGINE=InnoDB AUTO_INCREMENT=176 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shift_schedules`
--

LOCK TABLES `shift_schedules` WRITE;
/*!40000 ALTER TABLE `shift_schedules` DISABLE KEYS */;
INSERT INTO `shift_schedules` VALUES (13,2,13,1,'2026-10-26',7,'DRAFT',NULL),(14,3,12,1,'2026-10-26',7,'DRAFT',2),(25,2,12,1,'2026-10-27',7,'DRAFT',NULL),(26,2,12,1,'2026-10-28',7,'DRAFT',NULL),(27,2,12,1,'2026-10-29',7,'DRAFT',NULL),(28,2,12,1,'2026-10-30',7,'DRAFT',NULL),(29,2,12,1,'2026-11-01',7,'DRAFT',NULL),(37,3,15,1,'2026-10-26',7,'DRAFT',NULL),(38,3,15,1,'2026-10-27',7,'DRAFT',NULL),(39,3,15,1,'2026-10-28',7,'DRAFT',NULL),(40,3,15,1,'2026-10-29',7,'DRAFT',NULL),(41,3,15,1,'2026-10-30',7,'DRAFT',NULL),(42,3,15,1,'2026-10-31',7,'DRAFT',NULL),(43,3,15,1,'2026-11-01',7,'DRAFT',NULL),(52,3,16,1,'2026-10-26',7,'DRAFT',NULL),(53,3,16,1,'2026-10-27',7,'DRAFT',NULL),(54,3,16,1,'2026-10-28',7,'DRAFT',NULL),(58,3,16,1,'2026-10-29',7,'DRAFT',NULL),(59,3,16,1,'2026-10-30',7,'DRAFT',NULL),(60,3,16,1,'2026-10-31',7,'DRAFT',NULL),(61,3,16,1,'2026-11-01',7,'DRAFT',NULL),(70,3,14,4,'2026-11-03',7,'DRAFT',NULL),(79,2,12,1,'2026-11-30',7,'DRAFT',NULL),(80,3,13,1,'2026-11-30',7,'DRAFT',7),(81,3,16,1,'2026-11-30',7,'DRAFT',NULL),(82,3,15,1,'2026-11-30',7,'DRAFT',NULL),(83,3,16,1,'2026-12-01',7,'DRAFT',NULL),(84,3,16,1,'2026-12-02',7,'DRAFT',NULL),(85,3,15,1,'2026-12-01',7,'DRAFT',NULL),(86,3,15,1,'2026-12-02',7,'DRAFT',NULL),(87,3,16,1,'2026-12-03',7,'DRAFT',NULL),(88,3,15,1,'2026-12-03',7,'DRAFT',NULL),(89,3,16,1,'2026-12-04',7,'DRAFT',NULL),(90,3,15,1,'2026-12-04',7,'DRAFT',NULL),(91,3,16,1,'2026-12-05',7,'DRAFT',NULL),(92,3,15,1,'2026-12-05',7,'DRAFT',NULL),(93,3,16,1,'2026-12-06',7,'DRAFT',NULL),(94,3,15,1,'2026-12-06',7,'DRAFT',NULL),(96,3,16,1,'2026-11-09',7,'DRAFT',NULL),(97,4,15,1,'2026-11-09',7,'DRAFT',8),(132,4,14,4,'2026-11-17',7,'DRAFT',12),(139,3,20,4,'2026-11-16',7,'DRAFT',NULL),(159,3,14,4,'2026-11-23',7,'DRAFT',NULL),(160,3,14,4,'2026-11-24',7,'DRAFT',NULL),(161,3,14,4,'2026-11-25',7,'DRAFT',NULL),(162,3,14,4,'2026-11-26',7,'DRAFT',NULL),(163,3,14,4,'2026-11-27',7,'DRAFT',NULL),(164,3,14,4,'2026-11-28',7,'DRAFT',NULL),(165,3,14,4,'2026-11-29',7,'DRAFT',NULL),(166,3,20,4,'2026-11-17',7,'DRAFT',NULL),(167,3,21,4,'2026-11-17',7,'DRAFT',NULL),(168,3,23,4,'2026-11-17',7,'DRAFT',NULL),(170,3,20,4,'2026-11-18',7,'DRAFT',NULL),(173,3,21,4,'2026-11-18',7,'DRAFT',NULL),(174,3,23,4,'2026-11-18',7,'DRAFT',NULL),(175,4,14,4,'2026-11-18',7,'DRAFT',15);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplementary_shift_opportunities`
--

LOCK TABLES `supplementary_shift_opportunities` WRITE;
/*!40000 ALTER TABLE `supplementary_shift_opportunities` DISABLE KEYS */;
INSERT INTO `supplementary_shift_opportunities` VALUES (1,3,7,1,'2026-10-27','2026-10-23 21:35:00',7,'CLOSED','2026-10-22 14:36:17'),(2,3,7,1,'2026-10-26','2026-10-23 21:40:00',7,'CLOSED','2026-10-22 14:40:31'),(3,3,7,4,'2026-11-16','2026-11-12 01:57:00',7,'CLOSED','2026-11-09 18:57:36');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temporary_transfer_employees`
--

LOCK TABLES `temporary_transfer_employees` WRITE;
/*!40000 ALTER TABLE `temporary_transfer_employees` DISABLE KEYS */;
INSERT INTO `temporary_transfer_employees` VALUES (1,2,12,'APPROVED','2026-10-19 10:47:31'),(2,7,13,'APPROVED','2026-11-24 10:01:32'),(3,8,15,'APPROVED','2026-11-04 14:50:50'),(4,11,14,'RELEASED','2026-11-11 05:20:01'),(5,12,14,'APPROVED','2026-11-11 05:51:28'),(6,13,20,'RELEASED','2026-11-11 06:15:34'),(7,15,14,'APPROVED','2026-11-12 10:37:47');
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temporary_transfers`
--

LOCK TABLES `temporary_transfers` WRITE;
/*!40000 ALTER TABLE `temporary_transfers` DISABLE KEYS */;
INSERT INTO `temporary_transfers` VALUES (1,7,3,2,7,1,'2026-10-26',3,NULL,'test','đang thiếu nhân viên','REJECTED_MANAGER','2026-10-19 10:22:29','2026-10-19 10:25:24',1,NULL,NULL,NULL),(2,7,3,2,7,1,'2026-10-26',3,NULL,'test',NULL,'APPROVED','2026-10-19 10:26:06','2026-10-19 10:51:26',2,'2026-10-19 17:47:31',3,'2026-10-19 17:51:26'),(3,7,3,2,7,1,'2026-10-28',3,NULL,'ygi',NULL,'PENDING_MANAGER','2026-10-22 15:40:45','2026-10-22 15:40:45',1,NULL,NULL,NULL),(4,7,3,1,7,1,'2026-10-28',3,NULL,'yy',NULL,'PENDING_MANAGER','2026-10-22 15:54:12','2026-10-22 15:54:12',1,NULL,NULL,NULL),(5,7,3,2,7,2,'2026-11-01',4,NULL,'test',NULL,'PENDING_MANAGER','2026-10-25 14:38:42','2026-10-25 14:38:42',1,NULL,NULL,NULL),(6,7,3,2,7,4,'2026-11-01',4,NULL,'test2',NULL,'PENDING_MANAGER','2026-10-25 15:37:55','2026-10-25 15:37:55',1,NULL,NULL,NULL),(7,7,3,2,7,1,'2026-11-30',3,NULL,'test',NULL,'APPROVED','2026-11-24 09:58:29','2026-11-24 10:02:22',1,'2026-11-24 17:01:32',3,'2026-11-24 17:02:22'),(8,7,4,3,7,1,'2026-11-09',3,NULL,'test',NULL,'APPROVED','2026-11-07 14:41:09','2026-11-04 14:52:43',3,'2026-11-04 21:50:50',3,'2026-11-04 21:52:43'),(9,7,3,1,7,1,'2026-11-16',3,NULL,'thiếu',NULL,'PENDING_MANAGER','2026-11-11 03:35:12','2026-11-11 03:35:12',2,NULL,NULL,NULL),(10,7,4,3,7,4,'2026-11-17',3,NULL,'test','test','REJECTED_MANAGER','2026-11-11 04:10:29','2026-11-11 04:19:33',3,NULL,NULL,NULL),(11,7,4,3,7,4,'2026-11-17',3,NULL,'test2','check 2 cơ sở','REJECTED_HR','2026-11-11 04:25:51','2026-11-11 05:38:44',3,'2026-11-11 12:20:01',3,'2026-11-11 12:38:44'),(12,7,4,3,7,4,'2026-11-17',3,NULL,'test',NULL,'APPROVED','2026-11-11 05:44:18','2026-11-11 05:52:22',1,'2026-11-11 12:51:28',3,'2026-11-11 12:52:22'),(13,7,4,3,7,4,'2026-11-16',3,NULL,'dfdfd','kjok','REJECTED_HR','2026-11-11 06:00:01','2026-11-12 10:40:16',1,'2026-11-11 13:15:34',3,'2026-11-12 17:40:16'),(14,7,3,4,7,4,'2026-12-08',3,NULL,'dfdfd',NULL,'PENDING_MANAGER','2026-11-12 15:09:44','2026-11-12 15:09:44',1,NULL,NULL,NULL),(15,7,4,3,7,4,'2026-11-18',3,NULL,'testt',NULL,'APPROVED','2026-11-12 10:31:51','2026-11-12 10:40:21',1,'2026-11-12 17:37:47',3,'2026-11-12 17:40:21');
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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin_user','123456789','admin@supermarket.com',1,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-11-13 03:10:08',0),(2,'director_user','123456','director@supermarket.com',2,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(3,'hrm_user','123456','hrm@supermarket.com',3,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(4,'sm_user','123456','sm1@supermarket.com',4,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(5,'emp_user','123456','emp1@supermarket.com',5,'ACTIVE',NULL,'2026-09-22 16:50:49','2026-10-19 05:52:37',0),(6,'sm2_user','123456','sm2@supermarket.com',4,'ACTIVE',NULL,'2026-10-07 08:41:12','2026-10-19 05:52:37',0),(7,'sm3_user','123456','sm3@supermarket.com',4,'ACTIVE',NULL,'2026-10-07 08:41:12','2026-10-19 05:52:37',0),(8,'NV001','123456','test1@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:10','2026-10-19 10:15:33',0),(9,'NV002','123456','test2@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:15','2026-10-19 10:16:19',0),(10,'NV003','123456','test3@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:19','2026-10-19 10:16:34',0),(11,'NV004','123456','test4@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:24','2026-10-29 07:45:04',0),(12,'NV005','123456','test5@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:28','2026-10-19 10:17:00',0),(13,'NV006','123456','test6@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:31','2026-10-19 10:17:14',0),(14,'NV007','123456','test7@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:34','2026-11-07 14:31:31',0),(15,'NV008','123456','test8@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:38','2026-10-19 10:17:40',0),(16,'NV009','123456','test9@gmail.com',5,'ACTIVE',NULL,'2026-10-19 10:14:41','2026-10-19 10:18:02',0),(17,'NV010','123456',NULL,5,'ACTIVE','2026-11-15 00:00:00','2026-11-07 14:08:46','2026-11-07 14:31:46',1),(18,'NV011','123456',NULL,5,'ACTIVE',NULL,'2026-11-09 21:23:59','2026-11-09 21:23:59',1),(19,'NV012','123456',NULL,5,'ACTIVE',NULL,'2026-11-09 21:40:43','2026-11-09 21:40:43',1),(20,'NV013','123456',NULL,5,'ACTIVE','2026-11-15 00:00:00','2026-11-10 14:57:42','2026-11-10 14:57:42',1),(21,'NV014','123456',NULL,5,'ACTIVE',NULL,'2026-11-10 15:24:15','2026-11-13 06:20:06',1),(22,'NV015','123456',NULL,5,'ACTIVE','2026-11-10 00:00:00','2026-11-10 15:59:49','2026-11-10 15:59:49',1),(23,'NV016','123456',NULL,5,'ACTIVE',NULL,'2026-11-13 06:19:22','2026-11-13 06:19:50',0),(24,'NV017','123456',NULL,5,'ACTIVE',NULL,'2026-11-12 13:36:36','2026-11-12 13:36:36',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `violations`
--

LOCK TABLES `violations` WRITE;
/*!40000 ALTER TABLE `violations` DISABLE KEYS */;
INSERT INTO `violations` VALUES (1,13,2,'vi phạm','nhìn hơi ngu',NULL,0.00,'2026-10-31 20:46:21','WORK_PERFORMANCE','2026-10-30',6,'APPROVED','lần sau bớt ngu nhé.','chấm dứt hợp đồng',3,'2026-10-31 20:47:29'),(2,12,2,'ddfd','dfdf',NULL,0.00,'2026-10-31 20:54:19','OPERATIONAL','2026-10-24',6,'PENDING_REVIEW',NULL,NULL,NULL,NULL),(3,14,3,'sdsdsd','sdssd',NULL,0.00,'2026-10-31 20:55:04','WORK_PERFORMANCE','2026-10-29',7,'PENDING_REVIEW',NULL,NULL,NULL,NULL),(4,15,4,'bvbv','vbvb',NULL,0.00,'2026-11-10 01:27:20','ATTENDANCE','2026-11-09',7,'PENDING_REVIEW',NULL,NULL,NULL,NULL);
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

-- Dump completed on 2026-11-13 14:36:37
