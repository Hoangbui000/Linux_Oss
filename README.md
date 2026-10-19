# Đề Tài: Deployment and Configuration of a LAMP Stack Web Server on Ubuntu
**Mã Dự Án**: `Linux_Oss`  
**Nhóm Thực Hiện**: 3 Thành viên:
- **Thành viên A (Nhóm trưởng)**: Hạ tầng ban đầu & Điều phối tổng thể (~35%)
- **Thành viên B**: Chuyên trách Web Server (Apache) & Môi trường PHP (~35%)
- **Thành viên C**: Chuyên trách Database (MySQL), Bảo mật (UFW, Fail2ban) & Tự động hóa (~30%)

---

## 📂 1. Cấu Trúc Toàn Diện Của Dự Án (Project Structure)

```text
Linux_Oss/
├── .gitignore                          # Bỏ qua logs, file sao lưu và private keys
├── README.md                           # Giới thiệu tổng quan và hướng dẫn nhanh dự án
│
├── docs/                               # Toàn bộ tài liệu học thuật và kịch bản
│   ├── lamp_stack_project_plan.md      # Kế hoạch chi tiết 6 giai đoạn, phân công & RACI matrix
│   ├── deployment_guide.md             # Hướng dẫn triển khai từng bước từ A đến Z
│   ├── troubleshooting_guide.md        # Cẩm nang xử lý 7 lỗi kinh điển & mẹo vấn đáp
│   └── demo_presentation_guide.md      # Kịch bản 10 phút thuyết trình & Live Demo đạt điểm tối đa
│
├── configs/                            # Các file cấu hình mẫu tối ưu hóa hệ thống
│   ├── apache/
│   │   ├── lamp.local.conf             # VirtualHost cho HTTP (80) & HTTPS (443)
│   │   └── security_headers.conf       # Cấu hình Header an ninh (X-Frame, X-XSS, MIME)
│   ├── mysql/
│   │   └── custom_mysqld.cnf           # Tối ưu UTF-8 mb4, buffer pool và giới hạn kết nối
│   ├── php/
│   │   └── custom_php.ini              # Tối ưu upload 64M, memory_limit 256M, OPcache
│   └── security/
│       └── jail.local                  # Cấu hình Fail2ban bảo vệ SSH và Apache
│
├── scripts/                            # Bộ công cụ tự động hóa theo phân công
│   ├── 00_healthcheck.sh               # [Chung] Kiểm tra toàn diện trạng thái hệ thống 1-click
│   ├── 01_setup_environment.sh         # [Thành viên A] Cập nhật Ubuntu, user sudo, timezone, SSH
│   ├── 02_install_core_lamp.sh         # [Thành viên B] Cài đặt Apache, PHP, VirtualHost
│   ├── 02_setup_database.sh            # [Thành viên C] Cài đặt MySQL, tối ưu my.cnf & nạp schema
│   ├── 03_setup_security_ssl.sh        # [Thành viên C] Tạo SSL OpenSSL, mở UFW, cài Fail2ban
│   ├── backup_lamp.sh                  # [Thành viên C] Tự động sao lưu CSDL MySQL và Source Code
│   ├── restore_lamp.sh                 # [Thành viên C] Kịch bản khôi phục sự cố (Disaster Recovery)
│   └── test_benchmark.sh               # [Thành viên C] Đo tải hệ thống với ApacheBench (ab)
│
└── src/                                # Mã nguồn ứng dụng web demo phục vụ kiểm thử
    ├── db_schema.sql                   # CSDL mẫu, cấp quyền user và bảng 'students'
    ├── index.php                       # Bảng điều khiển kiểm tra trạng thái hoạt động (Dashboard)
    └── crud_demo.php                   # Ứng dụng Quản lý Thành viên (Thêm/Xem/Xóa) kết nối PDO MySQL
```

---

## ⚡ 2. Hướng Dẫn Vận Hành Nhanh (Quick Start)

### Bước 1: Khởi tạo môi trường (Thành viên A)
```bash
chmod +x scripts/*.sh
sudo ./scripts/01_setup_environment.sh
```

### Bước 2: Cài đặt Web Server & Ứng dụng (Thành viên B)
```bash
sudo ./scripts/02_install_core_lamp.sh
sudo cp -r src/* /var/www/lamp.local/public_html/
sudo chown -R www-data:www-data /var/www/lamp.local/public_html
```

### Bước 3: Cấu hình CSDL & Bảo mật (Thành viên C)
```bash
# Cài đặt MySQL Server, tối ưu my.cnf và nạp schema
sudo ./scripts/02_setup_database.sh

# Bật SSL, Tường lửa UFW & Fail2ban
sudo ./scripts/03_setup_security_ssl.sh

# Chạy thử sao lưu
sudo ./scripts/backup_lamp.sh
```

### Bước 4: Kiểm tra trạng thái 1-Click (Cả nhóm / Nghiệm thu)
```bash
./scripts/00_healthcheck.sh
```

---

## 🌐 3. Trải Nghiệm Demo Trên Trình Duyệt

1. Thêm IP máy ảo vào file `hosts` của máy cá nhân:
   ```text
   <IP_UBUNTU_SERVER>    lamp.local www.lamp.local
   ```
2. Truy cập:
   - **Trang Chẩn Đoán Hệ Thống**: `https://lamp.local/index.php`
   - **Trang Ứng Dụng Mẫu (CRUD Member)**: `https://lamp.local/crud_demo.php`

---

## 📖 4. Tài Liệu Tham Khảo Trong Thư Mục `docs/`
- Xem phân công công việc & biểu đồ Gantt: [Kế hoạch chi tiết](docs/lamp_stack_project_plan.md)
- Xem hướng dẫn chi tiết từng câu lệnh: [Deployment Guide](docs/deployment_guide.md)
- Xem giải thích lỗi và trả lời vấn đáp: [Troubleshooting Guide](docs/troubleshooting_guide.md)
- Xem kịch bản thuyết trình bảo vệ đồ án: [Presentation & Demo Guide](docs/demo_presentation_guide.md)
- **Hướng dẫn từng bước chạy dự án trên máy bản thân**: [Hướng Dẫn Chạy](huong_dan_chay.md)
- **Kịch bản Demo trực tiếp & Kết quả mẫu chi tiết**: [Hướng Dẫn Demo](huong_dan_demo.md)
