#!/usr/bin/env bash
# ====================================================================
# Script Sao Lưu Tự Động Toàn Diện Cho LAMP Stack Web Server
# Tác giả: Thành viên C (Chuyên trách Database, Bảo mật & Tự động hóa)
# ====================================================================

set -euo pipefail

# Khai báo thông số
BACKUP_DIR="/var/backups/lamp_backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
WEB_ROOT="/var/www/lamp.local/public_html"
DB_NAME="lamp_db"
DB_USER="lamp_user"
DB_PASS="StrongPassword123"

# Tạo thư mục chứa backup nếu chưa có
mkdir -p "${BACKUP_DIR}"

echo "[INFO] [$(date)] Bắt đầu tiến trình sao lưu LAMP Server..."

# 1. Sao lưu Cơ sở dữ liệu MySQL
echo "[INFO] Đang sao lưu Database '${DB_NAME}'..."
mysqldump --no-tablespaces -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" | gzip > "${BACKUP_DIR}/db_${DB_NAME}_${TIMESTAMP}.sql.gz"

# 2. Sao lưu Source Code Web
echo "[INFO] Đang nén mã nguồn web tại '${WEB_ROOT}'..."
tar -czf "${BACKUP_DIR}/web_source_${TIMESTAMP}.tar.gz" -C "${WEB_ROOT}" .

# 3. Dọn dẹp bản backup cũ quá 7 ngày
echo "[INFO] Xóa các bản sao lưu cũ hơn 7 ngày..."
find "${BACKUP_DIR}" -type f -name "*.gz" -mtime +7 -exec rm -f {} +

echo "[SUCCESS] Tiến trình sao lưu hoàn tất thành công tại: ${BACKUP_DIR}"
ls -lh "${BACKUP_DIR}"
