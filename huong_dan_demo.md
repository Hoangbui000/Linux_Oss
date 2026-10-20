# Hướng Dẫn Chi Tiết Cách Demo Đồ Án LAMP Stack & Kết Quả Mẫu (Full Demo Guide)

> **Đề tài**: Deployment and Configuration of a LAMP Stack Web Server on Ubuntu  
> **Mã đồ án**: `Linux_Oss`  
> **Dành cho**: Cả 3 thành viên khi thực hành thử và khi bước vào buổi bảo vệ trực tiếp trước Giảng viên.

---

## 📋 MỤC LỤC
1. [Khung Kịch Bản Demo 10 Phút & Phân Vai](#1-khung-kịch-bản-demo-10-phút--phân-vai)
2. [Chuẩn Bị Trước Giờ G (Checklist 5 Phút)](#2-chuẩn-bị-trước-giờ-g-checklist-5-phút)
3. [Chi Tiết Từng Bước Demo & Kết Quả Mẫu Hiển Thị](#3-chi-tiết-từng-bước-demo--kết-quả-mẫu-hiển-thị)
   - [Bước 1: Giới thiệu kiến trúc & Healthcheck 1-Click (Leader A)](#bước-1-giới-thiệu-kiến-trúc--healthcheck-1-click-thành-viên-a)
   - [Bước 2: Demo Web Server & VirtualHost Apache (Thành viên B)](#bước-2-demo-web-server--virtualhost-apache-thành-viên-b)
   - [Bước 3: Demo Ứng Dụng Động Tương Tác CSDL MySQL (Thành viên B & C)](#bước-3-demo-ứng-dụng-động-tương-tác-csdl-mysql-thành-viên-b--c)
   - [Bước 4: Demo An Ninh Tường Lửa UFW & Fail2ban (Thành viên C)](#bước-4-demo-an-ninh-tường-lửa-ufw--fail2ban-thành-viên-c)
   - [Bước 5: Demo Kịch Bản Khôi Phục Thảm Họa - Cú Chốt Điểm 10 (Thành viên C & Leader)](#bước-5-demo-kịch-bản-khôi-phục-thảm-họa---cú-chốt-điểm-10-thành-viên-c--leader)
   - [Bước 6: Đo Tải Hiệu Năng Với ApacheBench (Thành viên C)](#bước-6-đo-tải-hiệu-năng-với-apachebench-thành-viên-c)
4. [Bộ 5 Câu Hỏi Vấn Đáp Thường Gặp Của Giảng Viên & Cách Trả Lời](#4-bộ-5-câu-hỏi-vấn-đáp-thường-gặp-của-giảng-viên--cách-trả-lời)

---

## 1. Khung Kịch Bản Demo 10 Phút & Phân Vai

| Thời gian | Người phụ trách | Nội dung trình bày | Thao tác chính |
| :---: | :---: | :--- | :--- |
| **00:00 - 02:00** | **Thành viên A** *(Leader)* | Mở đầu, giới thiệu kiến trúc & Nghiệm thu hệ thống | Chạy script `./scripts/00_healthcheck.sh` |
| **02:00 - 04:30** | **Thành viên B** | Demo Web Server, VirtualHost & Dashboard | Mở `https://lamp.local/index.php` & xem file cấu hình conf |
| **04:30 - 06:30** | **Thành viên B + C** | Demo Ứng dụng CRUD tương tác CSDL MySQL | Thao tác trên `https://lamp.local/crud_demo.php` & Terminal SQL |
| **06:30 - 08:00** | **Thành viên C** | Demo An ninh UFW, Fail2ban & Chứng chỉ SSL | Kiểm tra `ufw status`, `fail2ban-client` & Ổ khóa HTTPS |
| **08:00 - 10:00** | **Cả 3 thành viên** | Cứu hộ thảm họa (Disaster Recovery) & Đo tải Stress test | Xóa thử dữ liệu -> chạy `restore_lamp.sh` & chạy `test_benchmark.sh` |

---

## 2. Chuẩn Bị Trước Giờ G (Checklist 5 Phút)

Trước khi thầy cô gọi tên vào chấm đồ án:
1. **Kiểm tra IP máy Ubuntu Server**:
   ```bash
   hostname -I | awk '{print $1}'
   # Kết quả mẫu: 192.168.253.129
   ```
2. **Đảm bảo máy tính cá nhân đã trỏ file `hosts` về IP trên**:
   - `192.168.253.129  lamp.local www.lamp.local`
3. **Mở sẵn 2 cửa sổ**:
   - Cửa sổ 1: Terminal (đang ở thư mục `/home/buiduchoang/Desktop/Linux_Oss`).
   - Cửa sổ 2: Trình duyệt Web (Chrome hoặc Firefox), mở sẵn tab `https://lamp.local/index.php`.

---

## 3. Chi Tiết Từng Bước Demo & Kết Quả Mẫu Hiển Thị

### BƯỚC 1: Giới Thiệu Kiến Trúc & Healthcheck 1-Click (Thành viên A)

* **Lời thoại**:
  > *"Em chào thầy/cô! Nhóm em gồm 3 thành viên thực hiện đề tài 'Triển khai và Cấu hình Máy chủ Web LAMP Stack trên Ubuntu 24.04'. Hệ thống được tách làm 4 tầng độc lập: Hạ tầng mạng & OS, Web Server Apache, CSDL MySQL và Tầng An toàn bảo mật. Trước tiên, em xin phép chạy script Healthcheck để kiểm tra toàn bộ dịch vụ cốt lõi của máy chủ."*

* **Thao tác lệnh Terminal**:
  ```bash
  cd /home/buiduchoang/Desktop/Linux_Oss
  ./scripts/00_healthcheck.sh
  ```

* **KẾT QUẢ TERMINAL MẪU HIỂN THỊ**:
  ```text
  ===================================================================
     HỆ THỐNG KIỂM TRA TRẠNG THÁI LAMP STACK (LINUX_OSS HEALTHCHECK) 
  ===================================================================
  Thời gian kiểm tra: 2026-10-19 09:15:30
  Hostname: VKU | Kernel: 7.0.0-38-generic

  1. KIỂM TRA CÁC DỊCH VỤ CỐT LÕI (SYSTEM SERVICES):
  [ OK ] Dịch vụ apache2: ĐANG CHẠY (Active)
  [ OK ] Dịch vụ mysql: ĐANG CHẠY (Active)
  [ OK ] Dịch vụ ufw: ĐANG CHẠY (Active)
  [ OK ] Dịch vụ fail2ban: ĐANG CHẠY (Active)

  2. KIỂM TRA CÁC CỔNG MẠNG QUAN TRỌNG (LISTENING PORTS):
  [ OK ] Port 22 (SSH Remote Access): Đang lắng nghe
  [ OK ] Port 80 (Apache HTTP Server): Đang lắng nghe
  [ OK ] Port 443 (Apache HTTPS/SSL Server): Đang lắng nghe
  [ OK ] Port 3306 (MySQL Database (Nội bộ 127.0.0.1)): Đang lắng nghe

  3. KIỂM TRA PHIÊN BẢN CÔNG NGHỆ:
    - Apache: Server version: Apache/2.4.58 (Ubuntu)
    - MySQL:  mysql  Ver 8.0.39-0ubuntu0.24.04.2 for Linux on x86_64 ((Ubuntu))
    - PHP:    PHP 8.3.6 (Modules: Core date libxml openssl pcre zlib filter hash json mysqli...)

  4. KIỂM TRA KẾT NỐI DATABASE NỘI BỘ:
  [ OK ] Truy cập MySQL qua tài khoản 'lamp_user' vào CSDL 'lamp_db': THÀNH CÔNG

  5. TÀI NGUYÊN HỆ THỐNG (RESOURCE USAGE):
    - RAM:  720Mi/1.9Gi
    - Disk: 7.8G/20G (41% used)

  ===================================================================
                      KIỂM TRA HOÀN TẤT                             
  ===================================================================
  ```

---

### BƯỚC 2: Demo Web Server & VirtualHost Apache (Thành viên B)

* **Lời thoại**:
  > *"Em là Thành viên B, phụ trách tầng Web Server Apache và môi trường PHP. Em đã cấu hình VirtualHost riêng biệt cho tên miền `lamp.local`, hỗ trợ cả cổng 80 (HTTP) và cổng 443 (HTTPS) với DocumentRoot độc lập tại `/var/www/lamp.local/public_html`."*

* **Thao tác 1: Cho thầy cô xem cấu hình VirtualHost**:
  ```bash
  cat /etc/apache2/sites-available/lamp.local.conf | head -n 27
  ```
* **KẾT QUẢ TERMINAL MẪU**:
  ```apache
  <VirtualHost *:80>
      ServerAdmin webmaster@lamp.local
      ServerName lamp.local
      ServerAlias www.lamp.local

      DocumentRoot /var/www/lamp.local/public_html

      <Directory /var/www/lamp.local/public_html>
          Options -Indexes +FollowSymLinks
          AllowOverride All
          Require all granted
      </Directory>

      ErrorLog ${APACHE_LOG_DIR}/lamp_local_error.log
      CustomLog ${APACHE_LOG_DIR}/lamp_local_access.log combined
  </VirtualHost>
  ```

* **Thao tác 2: Mở trình duyệt Web**:
  Truy cập: `https://lamp.local/index.php`
* **KẾT QUẢ TRÊN MÀN HÌNH TRÌNH DUYỆT**:
  - Giao diện Dashboard màu xanh đen (Dark Mode) hiện lên.
  - Huy hiệu xanh lá cây: **"Hệ thống LAMP hoạt động hoàn hảo 100%"**.
  - Các khối Card thông tin:
    * **Hệ Điều Hành (OS)**: Linux 7.0.0-38-generic
    * **Web Server**: Apache/2.4.58 (Ubuntu)
    * **Phiên bản PHP**: PHP 8.3.6
    * **Cơ sở dữ liệu MySQL**: Đã kết nối thành công qua PDO!

---

### BƯỚC 3: Demo Ứng Dụng Động Tương Tác CSDL MySQL (Thành viên B & C)

* **Lời thoại**:
  > *"Để chứng minh LAMP Stack xử lý mượt mà ứng dụng động thực tế chứ không chỉ phục vụ trang web tĩnh, nhóm em đã xây dựng module Quản lý Sinh viên kết nối MySQL qua PHP PDO, chuẩn 100% mô hình CRUD: Thêm (Create) - Xem (Read) - Sửa (Update) - Xóa (Delete) và đo lường thời gian phản hồi câu truy vấn trực tiếp."*

* **Thao tác trên Trình duyệt (`https://lamp.local/crud_demo.php`)**:
  1. Thầy cô sẽ thấy bảng dữ liệu mẫu sẵn có 3 thành viên:
     - `B21DCCN001` - Nguyễn Văn A - Nhóm trưởng / Hạ Tầng & Điều Phối (35%)
     - `B21DCCN002` - Trần Thị B - Chuyên trách Web Server & PHP (35%)
     - `B21DCCN003` - Lê Văn C - Chuyên trách Database & Security (30%)
  2. **Thực hiện Thêm mới một sinh viên (Create)**:
     - Nhập Mã SV: `B21DCCN999`
     - Họ tên: `Giảng Viên Chấm Điểm`
     - Email: `thaygiao@vku.udn.vn`
     - Bấm nút **"Ghi Dữ Liệu Vào MySQL"**.
  3. **Kết quả Thêm mới**:
     - Bảng thông báo màu xanh hiện lên: *"Thêm thành viên 'Giảng Viên Chấm Điểm' thành công vào MySQL!"*.
     - Dòng mới lập tức xuất hiện trong bảng.
  4. **Thực hiện Chỉnh sửa thông tin (Update)**:
     - Bấm nút **"Sửa"** màu xanh dương ở dòng `B21DCCN999`.
     - Cửa sổ Modal hiện lên, đổi Vai trò thành: `Giám Khảo Đánh Giá (Điểm 10)`.
     - Bấm **"Lưu Cập Nhật"** -> Dữ liệu cập nhật ngay lập tức vào MySQL!
  5. **Thực hiện Xóa (Delete)**:
     - Bấm nút **"Xóa"** màu đỏ ở dòng cần xoá -> Xác nhận -> Bản ghi bị xoá khỏi CSDL.
     - Thanh thời gian thực thi (Metrics) ở cuối trang: `Thời gian thực thi truy vấn: 1.45 ms`.

* **Thao tác kiểm chứng trực tiếp trong Terminal MySQL (Thành viên C gõ)**:
  ```bash
  mysql -ulamp_user -pStrongPassword123 -e "USE lamp_db; SELECT student_code, full_name, email FROM students WHERE student_code='B21DCCN999';"
  ```
* **KẾT QUẢ TERMINAL MẪU**:
  ```text
  +--------------+-----------------------+---------------------+
  | student_code | full_name             | email               |
  +--------------+-----------------------+---------------------+
  | B21DCCN999   | Giảng Viên Chấm Điểm | thaygiao@vku.udn.vn |
  +--------------+-----------------------+---------------------+
  ```

---

### BƯỚC 4: Demo An Ninh Tường Lửa UFW & Fail2ban (Thành viên C)

* **Lời thoại**:
  > *"Em là Thành viên C, phụ trách CSDL và Bảo mật. Máy chủ được thiết lập an toàn theo nguyên tắc 'Default Deny' - chặn toàn bộ các cổng không sử dụng, chỉ mở duy nhất cổng 22 (SSH), 80 (HTTP) và 443 (HTTPS). Đồng thời dịch vụ Fail2ban liên tục giám sát log để tự động khóa IP nếu dò mật khẩu SSH sai quá 3 lần."*

* **Thao tác 1: Kiểm tra trạng thái Tường lửa UFW**:
  ```bash
  sudo ufw status verbose
  ```
* **KẾT QUẢ TERMINAL MẪU**:
  ```text
  Status: active
  Logging: on (low)
  Default: deny (incoming), allow (outgoing), disabled (routed)
  New profiles: skip

  To                         Action      From
  --                         ------      ----
  22/tcp (SSH Remote Access) ALLOW IN    Anywhere                  
  80/tcp (Apache HTTP)       ALLOW IN    Anywhere                  
  443/tcp (Apache HTTPS)     ALLOW IN    Anywhere                  
  22/tcp (v6)                ALLOW IN    Anywhere (v6)             
  80/tcp (v6)                ALLOW IN    Anywhere (v6)             
  443/tcp (v6)               ALLOW IN    Anywhere (v6)
  ```

* **Thao tác 2: Kiểm tra Fail2ban**:
  ```bash
  sudo fail2ban-client status sshd
  ```
* **KẾT QUẢ TERMINAL MẪU**:
  ```text
  Status for the jail: sshd
  |- Filter
  |  |- Currently failed: 0
  |  |- Total failed:     0
  |  `- File list:        /var/log/auth.log
  `- Actions
     |- Currently banned: 0
     |- Total banned:     0
     `- Banned IP list:
  ```

* **Thao tác 3: Chỉ cho thầy cô xem Ổ khóa SSL trên Trình duyệt**:
  - Bấm vào biểu tượng ổ khóa cạnh thanh địa chỉ `https://lamp.local/`.
  - Chọn **Certificate is valid** -> Xem thông số:
    * Issued to: `lamp.local`
    * Organization: `Linux_Oss`
    * Signature Algorithm: `SHA-256 with RSA Encryption (2048-bit)`

---

### BƯỚC 5: Demo Kịch Bản Khôi Phục Thảm Họa - Cú Chốt Điểm 10 (Thành viên C & Leader)

* **Lời thoại**:
  > *"Một máy chủ chuẩn Production không chỉ cần chạy được mà phải có năng lực tự phục hồi khi gặp thảm họa (Disaster Recovery). Nhóm đã thiết lập cơ chế sao lưu tự động và viết kịch bản phục hồi 1-Click."*

* **Thao tác 5.1: Thực hiện Sao lưu thủ công**:
  ```bash
  sudo ./scripts/backup_lamp.sh
  ```
* **KẾT QUẢ TERMINAL MẪU**:
  ```text
  [INFO] [Mon Oct 19 09:22:15 +07 2026] Bắt đầu tiến trình sao lưu LAMP Server...
  [INFO] Đang sao lưu Database 'lamp_db'...
  [INFO] Đang nén mã nguồn web tại '/var/www/lamp.local/public_html'...
  [INFO] Xóa các bản sao lưu cũ hơn 7 ngày...
  [SUCCESS] Tiến trình sao lưu hoàn tất thành công tại: /var/backups/lamp_backups
  -rw-r--r-- 1 root root 1.8K Oct 19 09:22 db_lamp_db_20261019_092215.sql.gz
  -rw-r--r-- 1 root root 4.2K Oct 19 09:22 web_source_20261019_092215.tar.gz
  ```

* **Thao tác 5.2: Táo bạo xóa thử file trang web trước mặt giảng viên**:
  ```bash
  sudo rm -f /var/www/lamp.local/public_html/crud_demo.php
  ```
  - *Mở lại trình duyệt F5 `https://lamp.local/crud_demo.php`*: **Màn hình lập tức báo `404 Not Found`!**

* **Thao tác 5.3: Chạy script Khôi phục Thảm Họa 1-Click**:
  ```bash
  sudo ./scripts/restore_lamp.sh
  ```
* **KẾT QUẢ TERMINAL MẪU**:
  ```text
  ==========================================================
    [DISASTER RECOVERY] TIẾN TRÌNH KHÔI PHỤC HỆ THỐNG LAMP
  ==========================================================
  [INFO] Bản backup Database mới nhất: /var/backups/lamp_backups/db_lamp_db_20261019_092215.sql.gz
  [INFO] Bản backup Mã nguồn mới nhất: /var/backups/lamp_backups/web_source_20261019_092215.tar.gz

  [INFO] Đang giải nén và nạp lại Database 'lamp_db'...
  [SUCCESS] Khôi phục cơ sở dữ liệu MySQL thành công!
  [INFO] Đang giải nén mã nguồn vào '/var/www/lamp.local/public_html'...
  [SUCCESS] Khôi phục mã nguồn và phân quyền web thành công!
  ==========================================================
  [HOÀN TẤT] Hệ thống LAMP Stack đã được khôi phục 100%!
  ==========================================================
  ```
  - *F5 lại trình duyệt `https://lamp.local/crud_demo.php`*: **Trang web và toàn bộ danh sách sinh viên lập tức xuất hiện trở lại nguyên vẹn!**

---

### BƯỚC 6: Đo Tải Hiệu Năng Với ApacheBench (Thành viên C)

* **Lời thoại**:
  > *"Cuối cùng, nhóm tiến hành kiểm thử sức chịu tải của máy chủ bằng công cụ ApacheBench với 1.000 requests và 50 kết nối đồng thời."*

* **Thao tác Terminal**:
  ```bash
  ./scripts/test_benchmark.sh https://lamp.local/
  ```

* **KẾT QUẢ TERMINAL MẪU**:
  ```text
  ==========================================================
    BẮT ĐẦU ĐO HIỆU NĂNG LAMP STACK VỚI APACHEBENCH
    Mục tiêu: https://lamp.local/
    Số kết nối đồng thời: 50
    Tổng số request: 1000
  ==========================================================
  Benchmarking lamp.local (be patient)
  Completed 100 requests
  Completed 200 requests
  Completed 300 requests
  Completed 400 requests
  Completed 500 requests
  Completed 600 requests
  Completed 700 requests
  Completed 800 requests
  Completed 900 requests
  Completed 1000 requests
  Finished 1000 requests

  Server Software:        Apache/2.4.58
  Server Hostname:        lamp.local
  Server Port:            443
  SSL/TLS Protocol:       TLSv1.3,TLS_AES_256_GCM_SHA384,2048,256

  Document Path:          /
  Document Length:        3689 bytes

  Concurrency Level:      50
  Time taken for tests:   0.842 seconds
  Complete requests:      1000
  Failed requests:        0
  Total transferred:      3985000 bytes
  HTML transferred:       3689000 bytes
  Requests per second:    1187.65 [#/sec] (mean)
  Time per request:       42.100 [ms] (mean)
  Time per request:       0.842 [ms] (mean, across all concurrent requests)
  Transfer rate:          4621.50 [Kbytes/sec] received

  Connection Times (ms)
                min  mean[+/-sd] median   max
  Connect:        5   18   6.2     16      38
  Processing:    10   22   7.1     21      45
  Waiting:        8   19   6.5     18      40
  Total:         18   40  10.1     38      72

  ==========================================================
    ĐO LƯỜNG HOÀN TẤT. Failed requests = 0 | RPS = 1187.65
  ==========================================================
  ```
  *(Chỉ vào dòng `Failed requests: 0` và `Requests per second: ~1187` để khẳng định máy chủ xử lý cực kỳ ổn định).*

---

## 4. Bộ 5 Câu Hỏi Vấn Đáp Thường Gặp Của Giảng Viên & Cách Trả Lời

#### Câu 1 (Hỏi Thành viên B): *"Tại sao trong Virtual Host lại cần directive `Require all granted`?"*
* **Trả lời**: *"Thưa thầy/cô, từ phiên bản Apache 2.4, cơ chế kiểm soát truy cập chuyển sang dùng module `mod_authz_core`. Directive `Require all granted` cho phép mọi client được phép truy cập vào thư mục `DocumentRoot`. Nếu thiếu chỉ thị này, Apache sẽ chặn toàn bộ request và trả về mã lỗi `403 Forbidden`."*

#### Câu 2 (Hỏi Thành viên C): *"Tại sao không dùng tài khoản `root` của MySQL để kết nối trong file PHP?"*
* **Trả lời**: *"Thưa thầy/cô, đây là nguyên tắc đặc quyền tối thiểu (Principle of Least Privilege) trong bảo mật. Nếu dùng quyền root, trong trường hợp ứng dụng web bị lỗ hổng SQL Injection, kẻ tấn công có thể chiếm toàn quyền kiểm soát cơ sở dữ liệu và hệ điều hành. Nhóm tạo tài khoản riêng `lamp_user` chỉ có quyền trên database `lamp_db` để khoanh vùng thiệt hại."*

#### Câu 3 (Hỏi Thành viên A): *"Tại sao trình duyệt lại hiện cảnh báo 'Your connection is not private' dù đã cài SSL?"*
* **Trả lời**: *"Thưa thầy/cô, do hệ thống chạy trên môi trường Lab/Mạng nội bộ nên nhóm sử dụng chứng chỉ tự ký (Self-Signed Certificate) sinh bằng OpenSSL. Trình duyệt cảnh báo vì chứng chỉ không được ký bởi một CA công cộng (như DigiCert hay Let's Encrypt). Nhưng về mặt kỹ thuật mã hóa, toàn bộ kênh truyền HTTPS vẫn được mã hóa đối xứng chuẩn TLS 1.3 và AES 256-bit an toàn tuyệt đối."*

#### Câu 4 (Hỏi Thành viên C): *"Lệnh `mysql_secure_installation` thực hiện những việc gì bên dưới hệ thống?"*
* **Trả lời**: *"Dạ lệnh này thực hiện 4 tác vụ bảo mật cốt lõi: (1) Thiết lập chính sách độ phức tạp mật khẩu; (2) Xóa các tài khoản anonymous (vô danh); (3) Tắt quyền đăng nhập từ xa của user `root`; và (4) Xóa bỏ cơ sở dữ liệu `test` mặc định."*

#### Câu 5 (Hỏi Leader A): *"Nhóm đã phân chia công việc như thế nào trong suốt dự án?"*
* **Trả lời**: *"Dạ nhóm em phân chia theo năng lực và mô hình 3 lớp rõ ràng: Em là nhóm trưởng phụ trách hạ tầng khởi tạo ban đầu, kết nối mạng và điều phối tổng thể (~35%); bạn B chuyên trách máy chủ web Apache, PHP và ứng dụng web (~35%); bạn C chuyên trách cơ sở dữ liệu MySQL, tường lửa UFW, Fail2ban và tự động hóa sao lưu (~30%). Cả 3 thành viên đều có mã nguồn và script terminal thực tế trong bài báo cáo."*
