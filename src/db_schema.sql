-- ====================================================================
-- Script Khởi Tạo Cơ Sở Dữ Liệu & Bảng Mẫu Cho Đồ Án LAMP Stack
-- Tác giả: Nhóm Dự án Linux_Oss (Nhiệm vụ Thành viên C)
-- Cách import: mysql -u root -p < src/db_schema.sql
-- ====================================================================

-- 1. Tạo Database nếu chưa tồn tại
CREATE DATABASE IF NOT EXISTS `lamp_db`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- 2. Khởi tạo User và Phân quyền chuyên biệt (Không dùng quyền root cho Web)
CREATE USER IF NOT EXISTS 'lamp_user'@'localhost' IDENTIFIED BY 'StrongPassword123';
CREATE USER IF NOT EXISTS 'lamp_user'@'127.0.0.1' IDENTIFIED BY 'StrongPassword123';

GRANT ALL PRIVILEGES ON `lamp_db`.* TO 'lamp_user'@'localhost';
GRANT ALL PRIVILEGES ON `lamp_db`.* TO 'lamp_user'@'127.0.0.1';
FLUSH PRIVILEGES;

-- 3. Sử dụng Database
USE `lamp_db`;

-- 4. Tạo bảng Quản Lý Sinh Viên / Thành Viên Dự Án (students)
CREATE TABLE IF NOT EXISTS `students` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_code` VARCHAR(20) NOT NULL UNIQUE COMMENT 'Mã sinh viên',
    `full_name` VARCHAR(100) NOT NULL COMMENT 'Họ và tên',
    `email` VARCHAR(100) NOT NULL COMMENT 'Email liên hệ',
    `class_name` VARCHAR(50) NOT NULL COMMENT 'Lớp sinh hoạt',
    `project_role` VARCHAR(100) NOT NULL COMMENT 'Vai trò trong đồ án',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian khởi tạo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Nạp dữ liệu mẫu ban đầu
INSERT INTO `students` (`student_code`, `full_name`, `email`, `class_name`, `project_role`) VALUES
('B21DCCN001', 'Nguyễn Văn A (Leader)', 'leader.a@example.com', 'D21CQCN01-B', 'Nhóm trưởng / Hạ Tầng & Điều Phối (35%)'),
('B21DCCN002', 'Trần Thị B', 'member.b@example.com', 'D21CQCN01-B', 'Chuyên trách Web Server & PHP (35%)'),
('B21DCCN003', 'Lê Văn C', 'member.c@example.com', 'D21CQCN01-B', 'Chuyên trách Database & Security / Tự động hóa (30%)')
ON DUPLICATE KEY UPDATE `full_name`=VALUES(`full_name`);
