#!/usr/bin/env bash
# ====================================================================
# Script Cấu Hình SSL/TLS, Tường Lửa UFW & Fail2ban (Giai đoạn P3)
# Tác giả: Thành viên C (Chuyên trách Database, Bảo mật & Tự động hóa)
# ====================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Vui lòng chạy script này với quyền root: sudo bash $0"
   exit 1
fi

echo "=========================================================="
echo "  [THÀNH VIÊN C] CẤU HÌNH SSL, TƯỜNG LỬA UFW & FAIL2BAN"
echo "=========================================================="

# 1. Cài đặt fail2ban nếu chưa có
if ! command -v fail2ban-server &>/dev/null; then
    echo "[INFO] Đang cài đặt dịch vụ Fail2ban..."
    apt install -y fail2ban
fi

# 2. Tạo chứng chỉ SSL Self-Signed cho Domain lamp.local
SSL_CERT="/etc/ssl/certs/lamp_selfsigned.crt"
SSL_KEY="/etc/ssl/private/lamp_selfsigned.key"

if [[ ! -f "${SSL_KEY}" || ! -f "${SSL_CERT}" ]]; then
    echo "[INFO] Đang khởi tạo SSL/TLS Certificate (OpenSSL 2048-bit)..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "${SSL_KEY}" \
        -out "${SSL_CERT}" \
        -subj "/C=VN/ST=Hanoi/L=Hanoi/O=Linux_Oss/OU=LAMP_Project/CN=lamp.local"
fi

chown root:ssl-cert "${SSL_KEY}" 2>/dev/null || true
chmod 640 "${SSL_KEY}"
chmod 644 "${SSL_CERT}"
echo "[SUCCESS] Chứng chỉ SSL đã sẵn sàng tại:"
echo "  - Certificate: ${SSL_CERT}"
echo "  - Private Key: ${SSL_KEY}"

# 3. Cấu hình Tường lửa UFW (Bảo vệ cổng)
echo "[INFO] Thiết lập quy tắc tường lửa UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH Remote Access'
ufw allow 80/tcp comment 'Apache HTTP'
ufw allow 443/tcp comment 'Apache HTTPS'

# Bật UFW ở chế độ non-interactive
echo "y" | ufw enable
ufw status verbose

# 4. Cấu hình Fail2ban chống Brute-Force
mkdir -p /etc/fail2ban
JAIL_SRC="$(dirname "$0")/../configs/security/jail.local"
if [[ -f "${JAIL_SRC}" ]]; then
    echo "[INFO] Áp dụng cấu hình Fail2ban từ jail.local..."
    cp "${JAIL_SRC}" /etc/fail2ban/jail.local
    systemctl restart fail2ban
    systemctl enable fail2ban
    fail2ban-client status || true
fi

# 5. Kích hoạt module SSL và Restart Apache để lắng nghe Port 443
a2enmod ssl headers rewrite
a2ensite lamp.local.conf
systemctl restart apache2

echo "=========================================================="
echo "[SUCCESS] Hoàn tất thiết lập Bảo Mật Hệ Thống & SSL!"
echo "Truy cập HTTPS an toàn tại: https://lamp.local/"
echo "=========================================================="
