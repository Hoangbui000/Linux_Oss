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

# Đảm bảo có chứng chỉ SSL trước khi nạp VirtualHost port 443
SSL_CERT="/etc/ssl/certs/lamp_selfsigned.crt"
SSL_KEY="/etc/ssl/private/lamp_selfsigned.key"
if [[ ! -f "${SSL_KEY}" || ! -f "${SSL_CERT}" ]]; then
    echo "[INFO] Khởi tạo SSL Certificate ban đầu cho VirtualHost..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${SSL_KEY}" \
        -out "${SSL_CERT}" \
        -subj "/C=VN/ST=Hanoi/L=Hanoi/O=Linux_Oss/OU=LAMP_Project/CN=lamp.local"
    chmod 640 "${SSL_KEY}"
    chmod 644 "${SSL_CERT}"
fi

# Nạp cấu hình bảo mật Security Headers nếu có
SECURITY_CONF="$(dirname "$0")/../configs/apache/security_headers.conf"
if [[ -f "${SECURITY_CONF}" ]]; then
    echo "[INFO] Cấu hình Security Headers cho Apache..."
    cp "${SECURITY_CONF}" /etc/apache2/conf-available/security_headers.conf
    a2enconf security_headers
fi

# Nạp cấu hình PHP tối ưu (custom_php.ini)
PHP_CUSTOM_CONF="$(dirname "$0")/../configs/php/custom_php.ini"
if [[ -f "${PHP_CUSTOM_CONF}" ]] && command -v php &>/dev/null; then
    PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
    echo "[INFO] Áp dụng cấu hình tối ưu custom_php.ini cho PHP ${PHP_VER}..."
    mkdir -p "/etc/php/${PHP_VER}/apache2/conf.d" "/etc/php/${PHP_VER}/cli/conf.d"
    cp "${PHP_CUSTOM_CONF}" "/etc/php/${PHP_VER}/apache2/conf.d/99-custom.ini"
    cp "${PHP_CUSTOM_CONF}" "/etc/php/${PHP_VER}/cli/conf.d/99-custom.ini"
fi

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
