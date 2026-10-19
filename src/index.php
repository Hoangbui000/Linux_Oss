<?php
/**
 * Trang Kiểm Tra Trạng Thái Hoạt Động Của LAMP Stack Web Server
 * Dự án: Linux_Oss
 */

header('Content-Type: text/html; charset=utf-8');

$dbHost = '127.0.0.1';
$dbUser = 'lamp_user';
$dbPass = 'StrongPassword123';
$dbName = 'lamp_db';

$dbStatus = false;
$dbMessage = '';

try {
    if (extension_loaded('pdo_mysql')) {
        $pdo = new PDO("mysql:host={$dbHost};dbname={$dbName};charset=utf8mb4", $dbUser, $dbPass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_TIMEOUT => 3,
        ]);
        $dbStatus = true;
        $dbMessage = 'Kết nối MySQL Server thành công qua PDO!';
    } else {
        $dbMessage = 'Module pdo_mysql chưa được cài đặt!';
    }
} catch (Exception $e) {
    $dbMessage = 'Chưa kết nối được Database (hoặc chưa khởi tạo user/db): ' . htmlspecialchars($e->getMessage());
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LAMP Stack Status | Linux_Oss</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0f172a; color: #f8fafc; margin: 0; padding: 40px 20px; }
        .container { max-width: 800px; margin: 0 auto; background: #1e293b; border-radius: 12px; padding: 32px; box-shadow: 0 10px 25px rgba(0,0,0,0.4); border: 1px solid #334155; }
        h1 { color: #38bdf8; margin-top: 0; }
        .badge { display: inline-block; padding: 6px 14px; border-radius: 9999px; font-weight: bold; font-size: 14px; margin-bottom: 20px; }
        .success { background: #059669; color: #ecfdf5; }
        .warning { background: #d97706; color: #fffbeb; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 24px; }
        .card { background: #0f172a; padding: 16px; border-radius: 8px; border: 1px solid #334155; }
        .card h3 { margin-top: 0; color: #94a3b8; font-size: 14px; text-transform: uppercase; }
        .card p { margin: 8px 0 0; font-size: 18px; font-weight: 600; color: #f1f5f9; }
        .footer { margin-top: 32px; font-size: 13px; color: #64748b; text-align: center; border-top: 1px solid #334155; padding-top: 16px; }
    </style>
</head>
<body>
<div class="container">
    <h1>🚀 LAMP Stack Web Server - Sẵn Sàng</h1>
    <div class="badge <?= $dbStatus ? 'success' : 'warning' ?>">
        <?= $dbStatus ? 'Hệ thống LAMP hoạt động hoàn hảo 100%' : 'Apache & PHP hoạt động (Database cần cấu hình user)' ?>
    </div>

    <div class="grid">
        <div class="card">
            <h3>Hệ Điều Hành (OS)</h3>
            <p><?= php_uname('s') . ' ' . php_uname('r') ?></p>
        </div>
        <div class="card">
            <h3>Web Server (Apache)</h3>
            <p><?= isset($_SERVER['SERVER_SOFTWARE']) ? htmlspecialchars($_SERVER['SERVER_SOFTWARE']) : 'Apache' ?></p>
        </div>
        <div class="card">
            <h3>Phiên Bản PHP</h3>
            <p>PHP <?= PHP_VERSION ?></p>
        </div>
        <div class="card">
            <h3>Cơ Sở Dữ Liệu MySQL</h3>
            <p><?= $dbStatus ? 'Đã kết nối' : 'Chưa kết nối' ?></p>
        </div>
    </div>

    <div style="margin-top: 24px; padding: 16px; background: #0f172a; border-radius: 8px; border-left: 4px solid <?= $dbStatus ? '#10b981' : '#f59e0b' ?>;">
        <strong>Chi tiết kiểm tra Database:</strong> <?= $dbMessage ?>
    </div>

    <div style="margin-top: 24px; text-align: center;">
        <a href="crud_demo.php" style="display: inline-block; background: #0284c7; color: #ffffff; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600; font-size: 15px; box-shadow: 0 4px 12px rgba(2,132,199,0.3);">
            👉 Truy Cập Ứng Dụng Mẫu (CRUD Member Demo)
        </a>
    </div>

    <div class="footer">
        Đồ án: Deployment and Configuration of a LAMP Stack Web Server on Ubuntu | Linux_Oss Project
    </div>
</div>
</body>
</html>
