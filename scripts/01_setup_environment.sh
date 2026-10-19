#!/usr/bin/env bash
# ====================================================================
# Script Khởi Tạo Môi Trường Hệ Thống & Bảo Mật Cơ Bản (Giai đoạn P1)
# Tác giả: Thành viên A (Nhóm trưởng / Hạ Tầng & Điều Phối)
# ====================================================================

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Vui lòng chạy script này với quyền root: sudo bash $0"
   exit 1
fi

echo "=========================================================="
echo "  [THÀNH VIÊN A] BẮT ĐẦU CẤU HÌNH HẠ TẦNG UBUNTU SERVER"
echo "=========================================================="

# 1. Cập nhật hệ thống
echo "[INFO] Đang cập nhật danh sách gói và nâng cấp hệ điều hành..."
apt update -y && apt upgrade -y

# 2. Cài đặt các công cụ quản trị thiết yếu
echo "[INFO] Đang cài đặt các tiện ích quản trị hệ thống..."
apt install -y curl wget git vim htop net-tools ufw fail2ban unzip software-properties-common ca-certificates

# 3. Cấu hình múi giờ chuẩn Việt Nam (GMT+7)
echo "[INFO] Cấu hình múi giờ hệ thống sang Asia/Ho_Chi_Minh..."
timedatectl set-timezone Asia/Ho_Chi_Minh

# 4. Kiểm tra cấu hình mạng IP
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "[SUCCESS] Địa chỉ IP hiện tại của máy chủ: ${SERVER_IP}"
echo "[NOTE] Hãy dùng IP này để cấu hình file hosts trên máy thật: ${SERVER_IP} lamp.local"

# 5. Hướng dẫn thiết lập SSH Key
echo ""
echo "=========================================================="
echo "  HƯỚNG DẪN THÀNH VIÊN KẾT NỐI SSH TỪ XA:"
echo "  Từ máy máy tính cá nhân của các thành viên, chạy lệnh:"
echo "    ssh-copy-id username@${SERVER_IP}"
echo "    ssh username@${SERVER_IP}"
echo "=========================================================="
