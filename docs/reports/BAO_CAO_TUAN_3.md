# BÁO CÁO TIẾN ĐỘ ĐỒ ÁN - TUẦN 03 (BÁO CÁO TỔNG KẾT & NGHIỆM THU)

* **Đề tài**: Deployment and Configuration of a LAMP Stack Web Server on Ubuntu
* **Mã đồ án**: `Linux_Oss`
* **Kho mã nguồn GitHub**: [https://github.com/Hoangbui000/Linux_Oss](https://github.com/Hoangbui000/Linux_Oss)
* **Giai đoạn thực hiện**: Giai đoạn P5 & P6 (Đo Kiểm Hiệu Năng, Sao Lưu & Phục Hồi Thảm Họa, Hoàn Thiện Hồ Sơ Đồ Án)
* **Thời gian báo cáo**: Tuần 3 (Tuần kết thúc)
* **Nhóm sinh viên thực hiện (3 thành viên)**:
  1. **Thành viên A (Nhóm trưởng / Leader)**: Chủ trì Nghiệm thu hệ thống 1-Click, Diễn tập Disaster Recovery & Điều phối Thuyết trình (~35%)
  2. **Thành viên B**: Hoàn thiện thuyết minh kỹ thuật Web/PHP, phối hợp diễn tập khôi phục mã nguồn (~35%)
  3. **Thành viên C**: Viết Script Backup/Restore, Cron Job, Đo tải ApacheBench (`ab`) & Thiết kế Slide (~30%)

---

## I. MỤC TIÊU CỦA TUẦN 03
1. Xây dựng giải pháp sao lưu dự phòng tự động toàn diện: Tự động kết xuất CSDL MySQL bằng `mysqldump` nén định dạng `.sql.gz` và đóng gói mã nguồn web `.tar.gz`.
2. Thiết lập tiến trình định kỳ tự động chạy sao lưu qua **Cron Job** và cơ chế tự động xoá file backup cũ quá 7 ngày để tiết kiệm dung lượng ổ cứng.
3. Xây dựng và thử nghiệm thành công kịch bản **Cứu hộ thảm họa (Disaster Recovery)**: Giả lập tình huống hệ thống bị xóa sạch cơ sở dữ liệu và mã nguồn, sau đó phục hồi nguyên vẹn 100% trong vòng dưới 10 giây.
4. Đo lường hiệu năng chịu tải (Stress testing/Benchmark) bằng công cụ **ApacheBench (`ab`)** với tải trọng 1000 requests và 50 kết nối đồng thời.
5. Nghiệm thu toàn diện hệ thống bằng script 1-Click [00_healthcheck.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/00_healthcheck.sh).
6. Hoàn thiện toàn bộ hồ sơ kỹ thuật, cẩm nang gỡ lỗi, kịch bản 10 phút thuyết trình bảo vệ trước Hội đồng Giảng viên.

---

## II. CHI TIẾT CÔNG VIỆC ĐÃ HOÀN THÀNH THEO THÀNH VIÊN

### 1. Thành viên A (Nhóm trưởng / Hạ Tầng & Điều Phối - 35%)
* **Công việc đã thực hiện**:
  - Chủ trì diễn tập kịch bản phục hồi sự cố: Cố tình xóa trắng dữ liệu trong CSDL, sau đó chạy script [restore_lamp.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/restore_lamp.sh) và xác nhận website phục hồi hoàn hảo.
  - Viết và hoàn thiện kịch bản thuyết trình bảo vệ đồ án 10 phút trong [demo_presentation_guide.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/demo_presentation_guide.md), phân chia rõ lời thoại và thao tác Terminal cho cả 3 thành viên.
  - Tổng hợp toàn bộ hồ sơ báo cáo, sơ đồ kiến trúc hệ thống và biểu đồ tiến độ Gantt Chart vào tài liệu tổng kết.

### 2. Thành viên B (Chuyên trách Web Server & PHP - 35%)
* **Công việc đã thực hiện**:
  - Phối hợp cùng Thành viên C kiểm tra tính toàn vẹn của mã nguồn web sau khi giải nén phục hồi (`chmod 755` và `chown www-data:www-data`), đảm bảo không bị lỗi phân quyền `403 Forbidden`.
  - Biên soạn tài liệu hướng dẫn khắc phục 7 lỗi kinh điển trong [troubleshooting_guide.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/troubleshooting_guide.md) (lỗi tải file `.php`, lỗi xung đột port 80, lỗi xác thực MySQL...).
  - Kiểm tra độ ổn định của ứng dụng web động dưới áp lực truy cập đồng thời cao từ bài test của Thành viên C.

### 3. Thành viên C (Chuyên trách Database, An Ninh & Tự Động Hóa - 30%)
* **Công việc đã thực hiện**:
  - Viết script tự động sao lưu [backup_lamp.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/backup_lamp.sh):
    * Sử dụng cờ `--no-tablespaces` tránh lỗi quyền `PROCESS` của MySQL 8.
    * Đặt lịch chạy tự động vào lúc 02:00 sáng mỗi ngày qua crontab:
      `0 2 * * * /home/buiduchoang/Desktop/Linux_Oss/scripts/backup_lamp.sh >> /var/log/lamp_backup.log 2>&1`
    * Tự động dọn dẹp các bản sao lưu cũ quá 7 ngày: `find "${BACKUP_DIR}" -type f -name "*.gz" -mtime +7 -exec rm -f {} +`.
  - Viết script khôi phục sự cố [restore_lamp.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/restore_lamp.sh): Tự động tìm bản backup mới nhất, tự động dựng lại CSDL nếu bị drop (`CREATE DATABASE IF NOT EXISTS`), xả nén mã nguồn và tải lại dịch vụ Apache.
  - Viết script đo kiểm tải [test_benchmark.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/test_benchmark.sh) sử dụng `ab` (ApacheBench) với 1000 requests và 50 concurrency.
  - Thiết kế bộ Slide thuyết trình đồ án trực quan trên nền tảng Canva/PowerPoint.

---

## III. MINH CHỨNG KỸ THUẬT & KẾT QUẢ NGHIỆM THU

### 1. Kết quả chạy kịch bản sao lưu tự động [backup_lamp.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/backup_lamp.sh):
```text
[INFO] Bắt đầu tiến trình sao lưu LAMP Server...
[INFO] Đang sao lưu Database 'lamp_db'...
[INFO] Đang nén mã nguồn web tại '/var/www/lamp.local/public_html'...
[INFO] Xóa các bản sao lưu cũ hơn 7 ngày...
[SUCCESS] Tiến trình sao lưu hoàn tất thành công tại: /var/backups/lamp_backups
total 24K
-rw-r--r-- 1 root root 1.8K Oct 20 02:00 db_lamp_db_20261020_020001.sql.gz
-rw-r--r-- 1 root root  18K Oct 20 02:00 web_source_20261020_020001.tar.gz
```

### 2. Kết quả diễn tập Cứu hộ thảm họa [restore_lamp.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/restore_lamp.sh):
* **Giả lập sự cố**: Xóa toàn bộ database (`DROP DATABASE lamp_db;`).
* **Tiến hành khôi phục**:
  ```bash
  sudo ./scripts/restore_lamp.sh
  ```
* **Kết quả Terminal**:
  ```text
  ==========================================================
    [DISASTER RECOVERY] TIẾN TRÌNH KHÔI PHỤC HỆ THỐNG LAMP
  ==========================================================
  [INFO] Bản backup Database mới nhất: /var/backups/lamp_backups/db_lamp_db_20261020_020001.sql.gz
  [INFO] Bản backup Mã nguồn mới nhất: /var/backups/lamp_backups/web_source_20261020_020001.tar.gz
  [INFO] Đảm bảo Database 'lamp_db' sẵn sàng...
  [INFO] Đang giải nén và nạp lại dữ liệu vào Database 'lamp_db'...
  [SUCCESS] Khôi phục cơ sở dữ liệu MySQL thành công!
  [INFO] Đang giải nén mã nguồn vào '/var/www/lamp.local/public_html'...
  [SUCCESS] Khôi phục mã nguồn và phân quyền web thành công!
  ==========================================================
  [HOÀN TẤT] Hệ thống LAMP Stack đã được khôi phục 100%!
  ==========================================================
  ```
* **Kiểm tra trình duyệt**: Truy cập lại `https://lamp.local/crud_demo.php`, toàn bộ dữ liệu sinh viên hiển thị nguyên vẹn!

### 3. Kết quả đo kiểm chịu tải với ApacheBench (`ab`):
Lệnh: `./scripts/test_benchmark.sh https://lamp.local/`
```text
Server Software:        Apache/2.4.58
Server Hostname:        lamp.local
Server Port:            443
SSL/TLS Protocol:       TLSv1.3,TLS_AES_256_GCM_SHA384,2048,256

Concurrency Level:      50
Time taken for tests:   0.852 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      3150000 bytes
HTML transferred:       2897000 bytes
Requests per second:    1173.71 [#/sec] (mean)
Time per request:       42.600 [ms] (mean)
Time per request:       0.852 [ms] (mean, across all concurrent requests)
```
* **Nhận xét thông số kỹ thuật**:
  - Tốc độ xử lý đạt **1,173.71 requests/giây**, đáp ứng cực tốt lưu lượng truy cập cao.
  - Tỷ lệ lỗi: **Failed requests = 0 (0%)**, máy chủ giữ vững tính ổn định dưới tải 50 kết nối đồng thời.
  - Thời gian phản hồi trung bình: **0.85 ms** cho mỗi request song song.

### 4. Kết quả nghiệm thu toàn diện 1-Click [00_healthcheck.sh](file:///home/buiduchoang/Desktop/Linux_Oss/scripts/00_healthcheck.sh):
```text
===================================================================
   HỆ THỐNG KIỂM TRA TRẠNG THÁI LAMP STACK (LINUX_OSS HEALTHCHECK) 
===================================================================
Thời gian kiểm tra: 2026-10-20 10:38:35
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
  - MySQL:  mysql  Ver 8.0.46-0ubuntu0.24.04.4 for Linux on x86_64
  - PHP:    PHP 8.3.6 (Modules: bcmath, curl, gd, mbstring, mysqli, pdo_mysql...)

4. KIỂM TRA KẾT NỐI DATABASE NỘI BỘ:
[ OK ] Truy cập MySQL qua tài khoản 'lamp_user' vào CSDL 'lamp_db': THÀNH CÔNG

5. KIỂM TRA BẢO MẬT SSL & VIRTUALHOST:
[ OK ] Chứng chỉ SSL (/etc/ssl/certs/lamp_selfsigned.crt): Tồn tại (Hạn dùng: Oct 18 2027)
[ OK ] Tự động chuyển hướng HTTP sang HTTPS (Code: 301): ĐẠT

6. TÀI NGUYÊN HỆ THỐNG (RESOURCE USAGE):
  - RAM:  4.7Gi/6.7Gi
  - Disk: 18G/31G (61% used)

===================================================================
                    KIỂM TRA HOÀN TẤT                             
===================================================================
```

---

## IV. TỔNG KẾT ĐỀ TÀI & ĐÁNH GIÁ KẾT QUẢ ĐỒ ÁN

### 1. Mức độ hoàn thành đề tài:
* Toàn bộ 6 giai đoạn kỹ thuật (P1 ➔ P6) đã hoàn tất **100%**.
* Mã nguồn đầy đủ, không có lỗi tiềm ẩn, đã được đưa lên kho GitHub công khai: [https://github.com/Hoangbui000/Linux_Oss](https://github.com/Hoangbui000/Linux_Oss).

### 2. Bộ tài liệu hoàn chỉnh sẵn sàng phục vụ Hội đồng Giảng viên:
1. [TONG_QUAN_TIEN_DO.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/reports/TONG_QUAN_TIEN_DO.md): Báo cáo tổng thể tiến độ toàn dự án.
2. [BAO_CAO_TUAN_1.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/reports/BAO_CAO_TUAN_1.md): Báo cáo chi tiết Tuần 1 (Hạ tầng, Apache, MySQL, PHP).
3. [BAO_CAO_TUAN_2.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/reports/BAO_CAO_TUAN_2.md): Báo cáo chi tiết Tuần 2 (Bảo mật UFW, Fail2ban, SSL/TLS, Web App Full CRUD).
4. [BAO_CAO_TUAN_3.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/reports/BAO_CAO_TUAN_3.md): Báo cáo chi tiết Tuần 3 (Backup/Restore, Stress Test `ab`, Nghiệm thu).
5. [demo_presentation_guide.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/demo_presentation_guide.md): Kịch bản Live Demo 10 phút phân vai chuẩn.
6. [troubleshooting_guide.md](file:///home/buiduchoang/Desktop/Linux_Oss/docs/troubleshooting_guide.md): Cẩm nang 7 lỗi kinh điển & 5 lệnh vấn đáp ăn điểm tuyệt đối.
