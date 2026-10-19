#!/usr/bin/env bash
# ====================================================================
# Script Đo Lường Tải (Benchmark / Stress Test) Với ApacheBench (ab)
# Tác giả: Thành viên C (Chuyên trách Database, Bảo mật & Tự động hóa)
# ====================================================================

TARGET_URL="${1:-http://127.0.0.1/}"
CONCURRENCY=50
TOTAL_REQUESTS=1000

echo "=========================================================="
echo "  BẮT ĐẦU ĐO HIỆU NĂNG LAMP STACK VỚI APACHEBENCH"
echo "  Mục tiêu: ${TARGET_URL}"
echo "  Số kết nối đồng thời: ${CONCURRENCY}"
echo "  Tổng số request: ${TOTAL_REQUESTS}"
echo "=========================================================="

# Kiểm tra công cụ ab
if ! command -v ab &> /dev/null; then
    echo "[ERROR] ApacheBench chưa được cài đặt! Hãy chạy: sudo apt install apache2-utils -y"
    exit 1
fi

# Chạy test
ab -k -n "${TOTAL_REQUESTS}" -c "${CONCURRENCY}" "${TARGET_URL}"

echo "=========================================================="
echo "  ĐO LƯỜNG HOÀN TẤT. Ghi nhận thông số 'Requests per second'"
echo "  và 'Time per request' vào Báo cáo đồ án!"
echo "=========================================================="
