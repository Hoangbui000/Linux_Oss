#!/usr/bin/env bash
# ====================================================================
# Script Phục Hồi Dữ Liệu Sau Sự Cố (Disaster Recovery & Restore)
# Tác giả: Thành viên C (Chuyên trách Database, Bảo mật & Tự động hóa)
# ====================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Vui lòng chạy script này với quyền root: sudo bash $0"
   exit 1
fi

BACKUP_DIR="/var/backups/lamp_backups"
WEB_ROOT="/var/www/lamp.local/public_html"
DB_NAME="lamp_db"
DB_USER="lamp_user"
DB_PASS="StrongPassword123"

echo "=========================================================="
echo "  [DISASTER RECOVERY] TIẾN TRÌNH KHÔI PHỤC HỆ THỐNG LAMP"
echo "=========================================================="

# 1. Tìm bản sao lưu mới nhất
LATEST_DB_BACKUP=$(ls -t "${BACKUP_DIR}"/db_"${DB_NAME}"_*.sql.gz 2>/dev/null | head -n 1 || true)
LATEST_WEB_BACKUP=$(ls -t "${BACKUP_DIR}"/web_source_*.tar.gz 2>/dev/null | head -n 1 || true)

if [[ -z "${LATEST_DB_BACKUP}" || -z "${LATEST_WEB_BACKUP}" ]]; then
    echo "[ERROR] Không tìm thấy file backup hợp lệ trong ${BACKUP_DIR}!"
    echo "Hãy chắc chắn rằng bạn đã chạy script 'backup_lamp.sh' ít nhất một lần."
    exit 1
fi

echo "[INFO] Bản backup Database mới nhất: ${LATEST_DB_BACKUP}"
echo "[INFO] Bản backup Mã nguồn mới nhất: ${LATEST_WEB_BACKUP}"
echo ""

# 2. Khôi phục Cơ sở dữ liệu MySQL
echo "[INFO] Đảm bảo Database '${DB_NAME}' sẵn sàng..."
mysql -u"${DB_USER}" -p"${DB_PASS}" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true
echo "[INFO] Đang giải nén và nạp lại dữ liệu vào Database '${DB_NAME}'..."
gunzip -c "${LATEST_DB_BACKUP}" | mysql -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}"
echo "[SUCCESS] Khôi phục cơ sở dữ liệu MySQL thành công!"

# 3. Khôi phục Source Code Web
echo "[INFO] Đang giải nén mã nguồn vào '${WEB_ROOT}'..."
mkdir -p "${WEB_ROOT}"
tar -xzf "${LATEST_WEB_BACKUP}" -C "${WEB_ROOT}"

# Thiết lập lại phân quyền hệ thống chuẩn
chown -R www-data:www-data /var/www/lamp.local
find "${WEB_ROOT}" -type d -exec chmod 755 {} \;
find "${WEB_ROOT}" -type f -exec chmod 644 {} \;
echo "[SUCCESS] Khôi phục mã nguồn và phân quyền web thành công!"

# 4. Tải lại Web Server
systemctl reload apache2
echo "=========================================================="
echo "[HOÀN TẤT] Hệ thống LAMP Stack đã được khôi phục 100%!"
echo "Truy cập kiểm tra tại: http://lamp.local/ hoặc https://lamp.local/"
echo "=========================================================="
