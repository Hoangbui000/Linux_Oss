# Cẩm Nang Gỡ Lỗi & Tuyệt Chiêu Trả Lời Vấn Đáp (Troubleshooting & Defense Guide)

> **Dành cho**: Cả 3 thành viên khi thực hành, cài đặt và bảo vệ đề tài trước Giảng viên.

---

## 🎯 7 Tình Huống Lỗi Kinh Điển & Cách Khắc Phục Chuẩn Chuyên Gia

### 1. Lỗi: Trình duyệt tải về file `.php` thay vì thực thi giao diện (Download instead of executing)
* **Nguyên nhân**: Apache chưa được kích hoạt module PHP hoặc thiếu gói `libapache2-mod-php`.
* **Cách kiểm tra**:
  ```bash
  dpkg -l | grep libapache2-mod-php
  ls /etc/apache2/mods-enabled/php*
  ```
* **Cách khắc phục**:
  ```bash
  sudo apt install libapache2-mod-php -y
  sudo a2enmod php8.x  # hoặc phiên bản tương ứng
  sudo systemctl restart apache2
  ```

---

### 2. Lỗi: `403 Forbidden` khi truy cập trang web qua tên miền `lamp.local`
* **Nguyên nhân**: Phân quyền thư mục web bị sai (Apache chạy bằng user `www-data` nhưng thư mục lại thuộc `root` hoặc quyền quá chặt `chmod 700`), hoặc trong file VirtualHost thiếu directive `Require all granted`.
* **Cách khắc phục**:
  ```bash
  sudo chown -R www-data:www-data /var/www/lamp.local/public_html
  sudo find /var/www/lamp.local/public_html -type d -exec chmod 755 {} \;
  sudo find /var/www/lamp.local/public_html -type f -exec chmod 644 {} \;
  ```
  Kiểm tra file cấu hình VirtualHost:
  ```apache
  <Directory /var/www/lamp.local/public_html>
      Options -Indexes +FollowSymLinks
      AllowOverride All
      Require all granted
  </Directory>
  ```

---

### 3. Lỗi: `SQLSTATE[HY000] [1045] Access denied for user 'lamp_user'@'localhost'`
* **Nguyên nhân**:
  1. Chưa tạo user `lamp_user` hoặc mật khẩu khai báo trong PHP không khớp với mật khẩu trong MySQL.
  2. MySQL 8.0 sử dụng cơ chế xác thực `auth_socket` thay vì `caching_sha2_password` / `mysql_native_password`.
* **Cách khắc phục**:
  Đăng nhập MySQL bằng quyền root:
  ```bash
  sudo mysql
  ```
  Chạy lệnh cấp quyền:
  ```sql
  ALTER USER 'lamp_user'@'localhost' IDENTIFIED WITH mysql_native_password BY 'StrongPassword123';
  GRANT ALL PRIVILEGES ON lamp_db.* TO 'lamp_user'@'localhost';
  FLUSH PRIVILEGES;
  EXIT;
  ```

---

### 4. Lỗi: Trình duyệt báo `Not Secure` (SSL Certificate Warning) màu đỏ
* **Câu hỏi của Thầy/Cô**: *"Tại sao đã cấu hình SSL mà vào web trình duyệt vẫn báo Not Secure?"*
* **Câu trả lời chuẩn**:
  > *"Thưa thầy/cô, hệ thống sử dụng **Self-Signed Certificate (Chứng chỉ tự ký)** do nhóm tự sinh bằng công cụ `openssl` trong môi trường mạng nội bộ LAN/Lab. Trình duyệt cảnh báo vì Certificate này không do các tổ chức CA (Certificate Authority) công cộng uy tín (như DigiCert, Let's Encrypt) cấp. Tuy nhiên, toàn bộ dữ liệu truyền tải giữa Client và Web Server vẫn được mã hóa đối xứng AES 256-bit qua kênh HTTPS hoàn toàn an toàn."*

---

### 5. Lỗi: Không khởi động được Apache do lỗi đụng port 80 (`Address already in use`)
* **Nguyên nhân**: Có một tiến trình web server khác (như Nginx hoặc một phiên bản Apache cũ bị kẹt) đang chiếm dụng port 80.
* **Cách kiểm tra tiến trình đang chiếm port**:
  ```bash
  sudo ss -tulpn | grep ':80 '
  # hoặc
  sudo lsof -i :80
  ```
* **Cách khắc phục**:
  ```bash
  sudo systemctl stop nginx  # nếu có nginx
  sudo fuser -k 80/tcp       # ép kill tiến trình đang chiếm port 80
  sudo systemctl restart apache2
  ```

---

### 6. Lỗi: Tường lửa UFW bật lên làm mất kết nối SSH
* **Nguyên nhân**: Bật UFW (`ufw enable`) trước khi mở port 22 (`ufw allow 22`).
* **Cách phòng tránh & cứu hộ**:
  - Luôn mở port 22 trước:
    ```bash
    sudo ufw allow 22/tcp
    sudo ufw enable
    ```
  - Nếu lỡ bị khóa từ xa: Vào màn hình console trực tiếp của VMware / VirtualBox và gõ:
    ```bash
    sudo ufw allow 22/tcp && sudo ufw reload
    ```

---

### 7. Lỗi: Cron Job Backup không chạy tự động
* **Nguyên nhân**: Trong môi trường cron, biến môi trường `$PATH` bị hạn chế, dẫn đến cron không tìm thấy lệnh `mysqldump` hoặc không có quyền ghi vào thư mục `/var/backups`.
* **Cách kiểm tra log cron**:
  ```bash
  grep CRON /var/log/syslog
  ```
* **Cách khắc phục**:
  Trong script `backup_lamp.sh`, luôn sử dụng đường dẫn tuyệt đối hoặc khai báo đầu file:
  ```bash
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  ```

---

## 🛠️ Bộ 5 Lệnh Terminal Cần Nhớ Khi Vấn Đáp

1. **Kiểm tra trạng thái dịch vụ**:
   ```bash
   sudo systemctl status apache2 mysql ufw fail2ban
   ```
2. **Xem cú pháp Virtual Host**:
   ```bash
   sudo apache2ctl -S
   ```
3. **Theo dõi Log thời gian thực khi test web**:
   ```bash
   sudo tail -f /var/log/apache2/lamp_local_error.log
   ```
4. **Kiểm tra danh sách IP bị Fail2ban khóa**:
   ```bash
   sudo fail2ban-client status sshd
   ```
5. **Kiểm tra cổng đang lắng nghe**:
   ```bash
   sudo ss -tuln
   ```
