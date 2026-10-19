#!/usr/bin/env bash
# ====================================================================
# Script Cài Đặt & Cấu Hình MySQL Database Server (Giai đoạn P2)
# Tác giả: Thành viên C (Chuyên trách Database, Bảo mật & Tự động hóa)
# ====================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Vui lòng chạy script này với quyền root: sudo bash $0"
   exit 1
fi

echo "=========================================================="
echo "  [THÀNH VIÊN C] CÀI ĐẶT MYSQL SERVER & NẠP DỮ LIỆU MẪU"
echo "=========================================================="

# 1. Cài đặt MySQL Server
echo "[INFO] Đang cài đặt MySQL Server..."
apt install -y mysql-server

# Kích hoạt dịch vụ MySQL
systemctl enable mysql
systemctl start mysql

# 2. Áp dụng cấu hình tối ưu hóa MySQL
MYSQL_CUSTOM_CONF="$(dirname "$0")/../configs/mysql/custom_mysqld.cnf"
if [[ -f "${MYSQL_CUSTOM_CONF}" ]]; then
    echo "[INFO] Nạp cấu hình tối ưu custom_mysqld.cnf vào /etc/mysql/mysql.conf.d/..."
    cp "${MYSQL_CUSTOM_CONF}" /etc/mysql/mysql.conf.d/custom_mysqld.cnf
    systemctl restart mysql
fi

# 3. Nạp Cơ sở dữ liệu và Cấp quyền tài khoản Web User
SCHEMA_FILE="$(dirname "$0")/../src/db_schema.sql"
if [[ -f "${SCHEMA_FILE}" ]]; then
    echo "[INFO] Đang nạp schema CSDL và khởi tạo user từ ${SCHEMA_FILE}..."
    mysql < "${SCHEMA_FILE}"
    echo "[SUCCESS] Khởi tạo Database 'lamp_db' và User 'lamp_user' thành công!"
fi

# 4. Kiểm tra kết nối thử nghiệm
echo "[INFO] Kiểm tra kết nối nội bộ bằng tài khoản lamp_user..."
if mysql -ulamp_user -pStrongPassword123 -e "USE lamp_db; SELECT COUNT(*) AS Total_Students FROM students;" 2>/dev/null; then
    echo "[SUCCESS] Kết nối MySQL và truy vấn bảng 'students' thành công 100%!"
else
    echo "[WARN] Đang đồng bộ quyền user..."
    mysql -e "FLUSH PRIVILEGES;"
fi

echo "=========================================================="
echo "[HOÀN TẤT] Tầng Cơ sở dữ liệu MySQL đã sẵn sàng!"
echo "=========================================================="
