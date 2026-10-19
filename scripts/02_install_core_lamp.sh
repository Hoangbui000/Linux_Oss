#!/usr/bin/env bash
# ====================================================================
# Script Cài Đặt & Cấu Hình Core LAMP Stack (Giai đoạn P2 & P3)
# Tác giả: Thành viên B (Chuyên trách Web Server & PHP)
# ====================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Vui lòng chạy script này với quyền root: sudo bash $0"
   exit 1
fi

echo "=========================================================="
echo "  [THÀNH VIÊN B] CÀI ĐẶT APACHE, PHP & CẤU HÌNH VIRTUAL HOST"
echo "=========================================================="

# 1. Cài đặt Apache2
echo "[INFO] Đang cài đặt Apache Web Server..."
apt install -y apache2 apache2-utils

# 2. Cài đặt PHP cùng các modules cần thiết
echo "[INFO] Đang cài đặt PHP và các phần mở rộng quan trọng..."
apt install -y php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-zip php-bcmath

# 3. Kích hoạt các module cốt lõi của Apache
echo "[INFO] Kích hoạt modules: rewrite, ssl, headers..."
a2enmod rewrite ssl headers

# 4. Tạo thư mục chứa mã nguồn ứng dụng web
WEB_ROOT="/var/www/lamp.local/public_html"
echo "[INFO] Khởi tạo thư mục Web Root tại: ${WEB_ROOT}"
mkdir -p "${WEB_ROOT}"

# Phân quyền chuẩn Linux Web Server
chown -R www-data:www-data /var/www/lamp.local
chmod -R 755 /var/www/lamp.local

# 5. Kích hoạt Virtual Host lamp.local
CONFIG_SRC="$(dirname "$0")/../configs/apache/lamp.local.conf"
if [[ -f "${CONFIG_SRC}" ]]; then
    echo "[INFO] Sao chép file cấu hình Virtual Host vào Apache..."
    cp "${CONFIG_SRC}" /etc/apache2/sites-available/lamp.local.conf
    a2ensite lamp.local.conf
    a2dissite 000-default.conf || true
fi

# 6. Khởi động lại Apache
echo "[INFO] Kiểm tra cú pháp và nạp lại cấu hình Apache..."
apache2ctl configtest
systemctl restart apache2

echo "=========================================================="
echo "[SUCCESS] Hoàn tất cài đặt Core Apache & PHP!"
echo "Virtual Host đã sẵn sàng tại: http://lamp.local/"
echo "=========================================================="
