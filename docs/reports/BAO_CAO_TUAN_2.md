# BÁO CÁO TIẾN ĐỘ ĐỒ ÁN - TUẦN 02

* **Đề tài**: Deployment and Configuration of a LAMP Stack Web Server on Ubuntu
* **Mã đồ án**: `Linux_Oss`
* **Kho mã nguồn GitHub**: [https://github.com/Hoangbui000/Linux_Oss](https://github.com/Hoangbui000/Linux_Oss)
* **Giai đoạn thực hiện**: Giai đoạn P3 & P4 (Bảo Mật Hệ Thống, SSL/TLS, VirtualHost HTTPS & Triển Khai Web App Full CRUD)
* **Thời gian báo cáo**: Tuần 2
* **Nhóm sinh viên thực hiện (3 thành viên)**:
  1. **Thành viên A (Nhóm trưởng / Leader)**: Phối hợp SSL/TLS, Cấu hình chuyển hướng HTTPS & Rà soát tích hợp (~35%)
  2. **Thành viên B**: Xây dựng Ứng dụng Web Demo Full CRUD (PDO MySQL) & Tối ưu hóa cấu hình PHP (~35%)
  3. **Thành viên C**: Thiết lập Tường lửa UFW, Cấu hình Fail2ban & Kiểm thử An ninh (~30%)

---

## I. MỤC TIÊU CỦA TUẦN 02
1. Thiết lập tường lửa mạng **UFW**, tuân thủ nguyên tắc "Deny by Default" (chặn toàn bộ cổng vào, chỉ mở duy nhất các cổng thiết yếu: 22 SSH, 80 HTTP, 443 HTTPS).
2. Cài đặt và cấu hình dịch vụ **Fail2ban** để tự động phát hiện và khóa IP (ban) tấn công dò quét mật khẩu SSH Brute-Force.
3. Tạo chứng chỉ **SSL/TLS (OpenSSL 2048-bit)**, kích hoạt VirtualHost HTTPS và bật tính năng tự động chuyển hướng **HTTP sang HTTPS (Redirect 301)**.
4. Áp dụng các **Security Headers** (X-Frame-Options chống Clickjacking, X-Content-Type-Options chống MIME-Sniffing) và tối ưu hóa runtime PHP qua [custom_php.ini](file:///home/buiduchoang/Desktop/Linux_Oss/configs/php/custom_php.ini).
5. Xây dựng và triển khai hoàn thiện ứng dụng web mẫu [crud_demo.php](file:///home/buiduchoang/Desktop/Linux_Oss/src/crud_demo.php) đáp ứng chuẩn **100% Full CRUD (Create - Read - Update - Delete)** có giao diện trực quan Dark Mode.

---

## II. CHI TIẾT CÔNG VIỆC ĐÃ HOÀN THÀNH THEO THÀNH VIÊN

### 1. Thành viên A (Nhóm trưởng / Hạ Tầng & Điều Phối - 35%)
* **Công việc đã thực hiện**:
  - Hỗ trợ khởi tạo và phân quyền chứng chỉ số SSL tự ký tại `/etc/ssl/certs/lamp_selfsigned.crt` và khóa bí mật `/etc/ssl/private/lamp_selfsigned.key` với quyền bảo mật nghiêm ngặt `chmod 640`.
  - Phối hợp cùng Thành viên B tinh chỉnh file [lamp.local.conf](file:///home/buiduchoang/Desktop/Linux_Oss/configs/apache/lamp.local.conf) để kích hoạt `mod_rewrite`, đảm bảo mọi request vào cổng 80 đều chuyển hướng sang `https://lamp.local`.
  - Kiểm thử chéo kết nối mạng trên máy tính cá nhân qua trình duyệt bằng giao thức HTTPS, xác minh chứng chỉ số hợp lệ.

### 2. Thành viên B (Chuyên trách Web Server & PHP - 35%)
* **Công việc đã thực hiện**:
  - Viết module [custom_php.ini](file:///home/buiduchoang/Desktop/Linux_Oss/configs/php/custom_php.ini) nạp vào `/etc/php/8.3/apache2/conf.d/99-custom.ini`: nâng giới hạn upload `64MB`, bộ nhớ `256MB`, ẩn header `expose_php = Off` và kích hoạt `opcache.enable = 1`.
  - Xây dựng trang chẩn đoán [index.php](file:///home/buiduchoang/Desktop/Linux_Oss/src/index.php) hiển thị trạng thái của 4 tầng Linux, Apache, MySQL, PHP.
  - Xây dựng ứng dụng quản lý sinh viên [crud_demo.php](file:///home/buiduchoang/Desktop/Linux_Oss/src/crud_demo.php) với đầy đủ 4 thao tác CRUD:
    * **Create (Thêm mới)**: Form nhập thông tin sinh viên, validate dữ liệu đầu vào.
    * **Read (Xem danh sách)**: Truy vấn danh sách và hiển thị dưới dạng bảng dữ liệu responsive.
    * **Update (Sửa thông tin)**: Cửa sổ Modal tương tác cho phép sửa thông tin sinh viên đã có và cập nhật vào MySQL.
    * **Delete (Xóa bản ghi)**: Nút xóa kèm hộp thoại xác nhận JavaScript `confirm()`.
  - Đảm bảo an ninh ứng dụng web: Sử dụng **PDO Prepared Statements** (`execute([$data])`) để miễn nhiễm với lỗ hổng SQL Injection; lọc toàn bộ đầu ra bằng hàm `htmlspecialchars()` để triệt tiêu lỗ hổng XSS (Cross-Site Scripting).

### 3. Thành viên C (Chuyên trách Database, An Ninh & Tự Động Hóa - 30%)
* **Công việc đã thực hiện**:
  - Viết kịch bản tự động hóa [03_setup_security_ssl.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/03_setup_security_ssl.sh).
  - Cấu hình tường lửa UFW:
    ```bash
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp comment 'SSH Remote Access'
    ufw allow 80/tcp comment 'Apache HTTP'
    ufw allow 443/tcp comment 'Apache HTTPS'
    ufw enable
    ```
  - Cài đặt và cấu hình Fail2ban qua file [jail.local](file:///home/buiduchoang/Desktop/Linux_Oss/configs/security/jail.local): Giám sát log `/var/log/auth.log`, tự động cấm IP vi phạm đăng nhập SSH sai quá 3 lần trong vòng 10 phút, thời gian ban là 2 giờ (`bantime = 2h`).
  - Kiểm thử trực tiếp tính năng thêm, sửa, xóa trên web và kiểm tra sự thay đổi dữ liệu trong bảng `students` của MySQL.

---

## III. MINH CHỨNG KỸ THUẬT & KẾT QUẢ NGHIỆM THU

### 1. Trạng thái Tường lửa UFW:
Lệnh: `sudo ufw status verbose`
```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                   # SSH Remote Access
80/tcp                     ALLOW IN    Anywhere                   # Apache HTTP
443/tcp                    ALLOW IN    Anywhere                   # Apache HTTPS
22/tcp (v6)                ALLOW IN    Anywhere (v6)              # SSH Remote Access
80/tcp (v6)                ALLOW IN    Anywhere (v6)              # Apache HTTP
443/tcp (v6)               ALLOW IN    Anywhere (v6)              # Apache HTTPS
```

### 2. Trạng thái dịch vụ phòng chống dò quét Fail2ban:
Lệnh: `sudo fail2ban-client status sshd`
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

### 3. Kiểm tra tự động chuyển hướng HTTP -> HTTPS (Code 301):
Lệnh: `curl -I -H "Host: lamp.local" http://127.0.0.1/`
```text
HTTP/1.1 301 Moved Permanently
Date: Tue, 20 Oct 2026 10:38:35 GMT
Server: Apache/2.4.58 (Ubuntu)
Location: https://lamp.local/
Content-Type: text/html; charset=iso-8859-1
```
*(Yêu cầu gửi vào cổng 80 lập tức được máy chủ chuyển hướng an toàn sang `https://lamp.local/` qua mã phản hồi 301).*

### 4. Kiểm tra Header An Ninh trên kết nối HTTPS:
Lệnh: `curl -k -I -H "Host: lamp.local" https://127.0.0.1/`
```text
HTTP/1.1 200 OK
Date: Tue, 20 Oct 2026 10:38:35 GMT
Server: Apache/2.4.58 (Ubuntu)
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
Content-Type: text/html; charset=utf-8
```

### 5. Kết quả kiểm tra hoạt động ứng dụng Web Demo (Full CRUD):
* Thao tác **Create**: Đã thêm thành công bản ghi sinh viên mới vào CSDL `lamp_db`.
* Thao tác **Read**: Hiển thị đầy đủ danh sách sinh viên cùng thời gian xử lý truy vấn PHP PDO chỉ ~1.2 - 1.8 ms.
* Thao tác **Update**: Đã bấm nút "Sửa", mở modal cập nhật vai trò/lớp và lưu thay đổi thành công vào MySQL.
* Thao tác **Delete**: Xóa bản ghi thành công và CSDL tự động đồng bộ tức thời.

---

## IV. KHÓ KHĂN GẶP PHẢI & GIẢI PHÁP KHẮC PHỤC TRONG TUẦN 02
1. **Khó khăn 1**: Khi truy cập HTTPS trên trình duyệt, xuất hiện cảnh báo "Your connection is not private / Not Secure".
   - *Nguyên nhân*: Do hệ thống sử dụng chứng chỉ tự ký (Self-signed Certificate) tạo bằng OpenSSL trong môi trường mạng nội bộ Lab, không do các tổ chức CA công cộng (như Let's Encrypt hay DigiCert) cấp.
   - *Giải pháp*: Nhóm giải thích rõ nguyên lý trong báo cáo học thuật: kênh truyền vẫn được mã hóa đối xứng AES 256-bit bảo mật tuyệt đối. Trên trình duyệt, chỉ cần chọn "Advanced" ➔ "Proceed to lamp.local" để truy cập.
2. **Khó khăn 2**: Nguy cơ bị khóa SSH từ xa khi kích hoạt tường lửa UFW.
   - *Nguyên nhân*: Nếu chạy `ufw enable` trước khi mở port 22 thì người quản trị sẽ bị ngắt kết nối SSH ngay lập tức.
   - *Giải pháp*: Trong script [03_setup_security_ssl.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/03_setup_security_ssl.sh), nhóm luôn tuân thủ nguyên tắc chạy `ufw allow 22/tcp` trước, sau đó mới kích hoạt `ufw enable`.

---

## V. ĐÁNH GIÁ TIẾN ĐỘ & KẾ HOẠCH TUẦN 03 (TUẦN TỔNG KẾT)

* **Đánh giá mức độ hoàn thành Tuần 2**: **100% mục tiêu đề ra**.
* **Kế hoạch công việc Tuần 03**:
  1. Viết kịch bản tự động sao lưu dữ liệu toàn diện [backup_lamp.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/backup_lamp.sh) (CSDL MySQL nén `gzip` + mã nguồn web nén `tar.gz`) và thiết lập chạy tự động hàng ngày bằng **Cron Job**.
  2. Xây dựng kịch bản cứu hộ thảm họa [restore_lamp.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/restore_lamp.sh) (Disaster Recovery) phục hồi hệ thống khi có sự cố mất mát dữ liệu.
  3. Đo lường hiệu năng chịu tải (Stress testing) bằng công cụ **ApacheBench (`ab`)** để thu thập số liệu Requests per second (RPS) và độ trễ phản hồi.
  4. Hoàn thiện Slide thuyết trình bảo vệ đồ án, cẩm nang xử lý lỗi và kịch bản Live Demo trực tiếp.
