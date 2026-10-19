#!/usr/bin/env bash
# ====================================================================
# Healthcheck Script - Kiểm Tra Trạng Thái Toàn Diện LAMP Stack Server
# Tác giả: Nhóm Dự án Linux_Oss (Hỗ trợ Demo & Nghiệm thu đồ án)
# ====================================================================

set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}   HỆ THỐNG KIỂM TRA TRẠNG THÁI LAMP STACK (LINUX_OSS HEALTHCHECK) ${NC}"
echo -e "${BLUE}===================================================================${NC}"
echo -e "Thời gian kiểm tra: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "Hostname: $(hostname) | Kernel: $(uname -r)"
echo ""

check_service() {
    local service_name="$1"
    if systemctl is-active --quiet "${service_name}"; then
        echo -e "[ ${GREEN}OK${NC} ] Dịch vụ ${service_name}: ĐANG CHẠY (Active)"
    else
        echo -e "[ ${RED}FAILED${NC} ] Dịch vụ ${service_name}: KHÔNG HOẠT ĐỘNG (Inactive)"
    fi
}

check_port() {
    local port="$1"
    local desc="$2"
    if ss -tuln | grep -q -E ":${port}\b"; then
        echo -e "[ ${GREEN}OK${NC} ] Port ${port} (${desc}): Đang lắng nghe"
    else
        echo -e "[ ${RED}FAILED${NC} ] Port ${port} (${desc}): Chưa mở / không có dịch vụ lắng nghe"
    fi
}

echo -e "${YELLOW}1. KIỂM TRA CÁC DỊCH VỤ CỐT LÕI (SYSTEM SERVICES):${NC}"
check_service apache2
check_service mysql
check_service ufw
check_service fail2ban 2>/dev/null || echo -e "[ ${YELLOW}INFO${NC} ] Fail2ban chưa được kích hoạt"
echo ""

echo -e "${YELLOW}2. KIỂM TRA CÁC CỔNG MẠNG QUAN TRỌNG (LISTENING PORTS):${NC}"
check_port 22 "SSH Remote Access"
check_port 80 "Apache HTTP Server"
check_port 443 "Apache HTTPS/SSL Server"
check_port 3306 "MySQL Database (Nội bộ 127.0.0.1)"
echo ""

echo -e "${YELLOW}3. KIỂM TRA PHIÊN BẢN CÔNG NGHỆ:${NC}"
if command -v apache2 &>/dev/null; then
    echo -e "  - Apache: $(apache2 -v | head -n 1)"
fi
if command -v mysql &>/dev/null; then
    echo -e "  - MySQL:  $(mysql --version)"
fi
if command -v php &>/dev/null; then
    echo -e "  - PHP:    PHP $(php -r 'echo PHP_VERSION;') (Modules: $(php -m | tr '\n' ' ' | cut -c 1-60)...)"
fi
echo ""

echo -e "${YELLOW}4. KIỂM TRA KẾT NỐI DATABASE NỘI BỘ:${NC}"
DB_USER="lamp_user"
DB_PASS="StrongPassword123"
DB_NAME="lamp_db"

if command -v mysql &>/dev/null; then
    if mysql -u"${DB_USER}" -p"${DB_PASS}" -e "USE ${DB_NAME}; SELECT 'DB_OK' AS Status;" 2>/dev/null | grep -q "DB_OK"; then
        echo -e "[ ${GREEN}OK${NC} ] Truy cập MySQL qua tài khoản '${DB_USER}' vào CSDL '${DB_NAME}': THÀNH CÔNG"
    else
        echo -e "[ ${YELLOW}WARN${NC} ] Chưa thể kết nối MySQL với tài khoản '${DB_USER}' (hoặc chưa import schema)"
    fi
fi
echo ""

echo -e "${YELLOW}5. TÀI NGUYÊN HỆ THỐNG (RESOURCE USAGE):${NC}"
echo -e "  - RAM:  $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo -e "  - Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
echo ""

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}                    KIỂM TRA HOÀN TẤT                             ${NC}"
echo -e "${BLUE}===================================================================${NC}"
