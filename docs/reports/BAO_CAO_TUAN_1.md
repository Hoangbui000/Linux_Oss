# BÁO CÁO TIẾN ĐỘ ĐỒ ÁN - TUẦN 01

* **Đề tài**: Deployment and Configuration of a LAMP Stack Web Server on Ubuntu
* **Mã đồ án**: `Linux_Oss`
* **Kho mã nguồn GitHub**: [https://github.com/Hoangbui000/Linux_Oss](https://github.com/Hoangbui000/Linux_Oss)
* **Giai đoạn thực hiện**: Giai đoạn P1 & P2 (Khởi tạo Hạ tầng & Cài đặt Core LAMP Stack)
* **Thời gian báo cáo**: Tuần 1
* **Nhóm sinh viên thực hiện (3 thành viên)**:
  1. **Thành viên A (Nhóm trưởng / Leader)**: Phụ trách Khởi tạo VM, Mạng tĩnh, SSH, Git & Điều phối tổng thể (~35%)
  2. **Thành viên B**: Phụ trách Cài đặt Apache Web Server, PHP Runtime & VirtualHost (~35%)
  3. **Thành viên C**: Phụ trách Cài đặt MySQL Server, Tối ưu cấu hình & Nạp CSDL mẫu (~30%)

---

## I. MỤC TIÊU CỦA TUẦN 01
1. Khởi tạo hoàn chỉnh máy chủ ảo Ubuntu Server 24.04 LTS, cấu hình mạng thông suốt trong mạng LAN/Lab.
2. Thiết lập cơ chế truy cập quản trị từ xa qua SSH và tạo kho lưu trữ Git trên GitHub để các thành viên phối hợp mã nguồn.
3. Cài đặt và kích hoạt thành công 3 tầng dịch vụ cốt lõi: **Apache 2.4**, **MySQL 8.0**, **PHP 8.3**.
4. Cấu hình VirtualHost cho tên miền riêng `lamp.local` và kiểm tra việc xử lý mã PHP thông qua Apache.
5. Khởi tạo Database `lamp_db`, phân quyền tài khoản riêng biệt `lamp_user` (không dùng tài khoản root cho ứng dụng web) và nạp bảng dữ liệu sinh viên mẫu `students`.

---

## II. CHI TIẾT CÔNG VIỆC ĐÃ HOÀN THÀNH THEO THÀNH VIÊN

### 1. Thành viên A (Nhóm trưởng / Hạ Tầng & Điều Phối - 35%)
* **Công việc đã thực hiện**:
  - Khởi tạo máy ảo Ubuntu Server 24.04 LTS (RAM 2GB, Ổ cứng 20GB, 2 vCPU).
  - Cấu hình card mạng chế độ Bridged Networking để nhận địa chỉ IP nội bộ (`192.168.253.129`).
  - Viết kịch bản tự động hóa [01_setup_environment.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/01_setup_environment.sh): cập nhật các gói hệ điều hành (`apt update && apt upgrade`), cấu hình múi giờ chuẩn Việt Nam (`Asia/Ho_Chi_Minh`), cài đặt sẵn các tiện ích quản trị (`curl`, `wget`, `git`, `htop`, `net-tools`).
  - Hướng dẫn các thành viên tạo và cấu hình SSH Key để đăng nhập từ xa an toàn.
  - Khởi tạo repository Git trên GitHub: `Hoangbui000/Linux_Oss`, xây dựng cấu trúc thư mục chuẩn và viết tài liệu [lamp_stack_project_plan.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/lamp_stack_project_plan.md).

### 2. Thành viên B (Chuyên trách Web Server & PHP - 35%)
* **Công việc đã thực hiện**:
  - Cài đặt Apache HTTP Server (`apache2`, `apache2-utils`), cấu hình tự khởi động cùng hệ điều hành (`systemctl enable apache2`).
  - Kích hoạt các module cốt lõi của Apache: `rewrite`, `headers`.
  - Cài đặt PHP 8.3 và các extension thiết yếu: `libapache2-mod-php`, `php-mysql`, `php-curl`, `php-gd`, `php-mbstring`, `php-xml`, `php-zip`, `php-bcmath`.
  - Thiết lập thư mục DocumentRoot tại `/var/www/lamp.local/public_html`, phân quyền chuẩn người dùng Linux `www-data:www-data` với `chmod 755`.
  - Soạn thảo và kích hoạt VirtualHost [lamp.local.conf](file:///home/buiduchoang/Desktop/Linux_Oss/configs/apache/lamp.local.conf) phục vụ tên miền nội bộ `lamp.local`.
  - Viết script tự động hóa [02_install_core_lamp.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/02_install_core_lamp.sh).

### 3. Thành viên C (Chuyên trách Database & An Ninh CSDL - 30%)
* **Công việc đã thực hiện**:
  - Cài đặt MySQL Database Server (`mysql-server 8.0`), kích hoạt dịch vụ chạy nền (`systemctl enable mysql`).
  - Soạn thảo file cấu hình tối ưu [custom_mysqld.cnf](file:///home/buiduchoang/Desktop/Linux_Oss/configs/mysql/custom_mysqld.cnf): ép MySQL chỉ lắng nghe cục bộ `127.0.0.1` để ngăn chặn truy cập trái phép từ bên ngoài, tối ưu buffer pool `256M` cho máy ảo RAM 2GB, bật bảng mã tiếng Việt `utf8mb4`.
  - Thiết kế lược đồ cơ sở dữ liệu [db_schema.sql](file:///home/buiduchoang/Desktop/Linux_Oss/src/db_schema.sql):
    * Tạo cơ sở dữ liệu `lamp_db`.
    * Tạo user chuyên biệt `lamp_user` mật khẩu mạnh `StrongPassword123` và cấp quyền vừa đủ trên `lamp_db` (bảo đảm nguyên tắc đặc quyền tối thiểu - Principle of Least Privilege).
    * Tạo bảng `students` lưu trữ thông tin thành viên (Mã SV, Họ tên, Email, Lớp, Vai trò đồ án) và nạp sẵn 3 bản ghi mẫu.
  - Viết script tự động hóa [02_setup_database.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/02_setup_database.sh).

---

## III. MINH CHỨNG KỸ THUẬT & KẾT QUẢ NGHIỆM THU

### 1. Kiểm tra trạng thái các dịch vụ cốt lõi:
```text
● apache2.service - The Apache HTTP Server
     Active: active (running) since Tue 2026-10-20
● mysql.service - MySQL Community Server
     Active: active (running) since Tue 2026-10-20
```

### 2. Kiểm tra các cổng mạng đang mở (Listening Ports):
Lệnh: `ss -tuln | grep -E ':22|:80|:3306'`
```text
tcp   LISTEN 0      128          0.0.0.0:22         0.0.0.0:*    # Port 22 SSH
tcp   LISTEN 0      511                *:80               *:*    # Port 80 Apache Web
tcp   LISTEN 0      151        127.0.0.1:3306       0.0.0.0:*    # Port 3306 MySQL (Chỉ nghe localhost)
```
*(Cổng 3306 chỉ lắng nghe trên `127.0.0.1`, đảm bảo tuyệt đối an toàn không bị lộ ra mạng bên ngoài).*

### 3. Kết quả truy vấn thử nghiệm CSDL MySQL:
Lệnh: `mysql -ulamp_user -pStrongPassword123 -e "USE lamp_db; SELECT student_code, full_name, project_role FROM students;"`
```text
+--------------+-----------------------+------------------------------------------+
| student_code | full_name             | project_role                             |
+--------------+-----------------------+------------------------------------------+
| B21DCCN001   | Nguyễn Văn A (Leader) | Nhóm trưởng / Hạ Tầng & Điều Phối (35%)  |
| B21DCCN002   | Trần Thị B            | Chuyên trách Web Server & PHP (35%)      |
| B21DCCN003   | Lê Văn C              | Chuyên trách Database & Security (30%)   |
+--------------+-----------------------+------------------------------------------+
```

### 4. Kết quả nghiệm thu 1-Click bằng [00_healthcheck.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/00_healthcheck.sh):
```text
===================================================================
   HỆ THỐNG KIỂM TRA TRẠNG THÁI LAMP STACK (LINUX_OSS HEALTHCHECK) 
===================================================================
1. KIỂM TRA CÁC DỊCH VỤ CỐT LÕI:
[ OK ] Dịch vụ apache2: ĐANG CHẠY (Active)
[ OK ] Dịch vụ mysql: ĐANG CHẠY (Active)

2. KIỂM TRA CỔNG MẠNG:
[ OK ] Port 22 (SSH Remote Access): Đang lắng nghe
[ OK ] Port 80 (Apache HTTP Server): Đang lắng nghe
[ OK ] Port 3306 (MySQL Database (Nội bộ 127.0.0.1)): Đang lắng nghe

3. KIỂM TRA PHIÊN BẢN CÔNG NGHỆ:
  - Apache: Server version: Apache/2.4.58 (Ubuntu)
  - MySQL:  mysql  Ver 8.0.46 for Linux on x86_64
  - PHP:    PHP 8.3.6

4. KIỂM TRA KẾT NỐI DATABASE NỘI BỘ:
[ OK ] Truy cập MySQL qua tài khoản 'lamp_user' vào CSDL 'lamp_db': THÀNH CÔNG
===================================================================
```

---

## IV. KHÓ KHĂN GẶP PHẢI & GIẢI PHÁP KHẮC PHỤC TRONG TUẦN 01
1. **Khó khăn 1**: Khi truy cập từ máy tính cá nhân vào máy ảo qua tên miền `lamp.local` bị báo lỗi "Site can't be reached".
   - *Nguyên nhân*: Máy tính cá nhân chưa biết địa chỉ IP tương ứng của tên miền ảo nội bộ.
   - *Giải pháp*: Nhóm đã cấu hình file `/etc/hosts` trên máy client ánh xạ địa chỉ IP máy chủ Ubuntu vào `lamp.local`.
2. **Khó khăn 2**: Tài khoản ứng dụng web khi truy cập MySQL bị lỗi quyền xác thực trong phiên bản MySQL 8.
   - *Nguyên nhân*: MySQL 8 mặc định dùng plugin `caching_sha2_password` hoặc `auth_socket`.
   - *Giải pháp*: Trong script tạo user, nhóm đã chỉ định rõ phương thức định danh và cấp quyền `GRANT ALL PRIVILEGES ON lamp_db.* TO 'lamp_user'@'localhost' IDENTIFIED BY 'StrongPassword123'`, sau đó chạy `FLUSH PRIVILEGES;`.

---

## V. ĐÁNH GIÁ TIẾN ĐỘ & KẾ HOẠCH TUẦN 02

* **Đánh giá mức độ hoàn thành Tuần 1**: **100% mục tiêu đề ra**.
* **Kế hoạch công việc Tuần 02**:
  1. Thiết lập an ninh mạng: Cấu hình Tường lửa **UFW** chỉ mở port 22, 80, 443 và cài đặt **Fail2ban** chống dò quét mật khẩu SSH.
  2. Tạo chứng chỉ **SSL/TLS (OpenSSL 2048-bit)**, kích hoạt VirtualHost HTTPS cổng 443 và cấu hình tự động chuyển hướng **HTTP -> HTTPS (Code 301)**.
  3. Xây dựng và triển khai ứng dụng web động mẫu đạt chuẩn **Full CRUD** (Thêm, Xem, Sửa, Xóa sinh viên) kết nối MySQL qua PHP PDO.
