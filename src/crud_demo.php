<?php
/**
 * Ứng Dụng Web Mẫu: Quản Lý Thành Viên / Sinh Viên Dự Án
 * Chứng minh tương tác toàn diện giữa Apache, PHP và MySQL qua PDO
 * Dự án: Linux_Oss (Nhiệm vụ Thành viên B & C)
 */

declare(strict_types=1);

$dbHost = '127.0.0.1';
$dbUser = 'lamp_user';
$dbPass = 'StrongPassword123';
$dbName = 'lamp_db';

$startTime = microtime(true);
$message = '';
$messageType = '';
$students = [];

try {
    $pdo = new PDO("mysql:host={$dbHost};dbname={$dbName};charset=utf8mb4", $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_TIMEOUT            => 3,
    ]);

    // Xử lý Thêm mới thành viên
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'add') {
        $studentCode = trim($_POST['student_code'] ?? '');
        $fullName = trim($_POST['full_name'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $className = trim($_POST['class_name'] ?? '');
        $projectRole = trim($_POST['project_role'] ?? '');

        if ($studentCode !== '' && $fullName !== '' && $email !== '') {
            $stmt = $pdo->prepare("INSERT INTO students (student_code, full_name, email, class_name, project_role) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([$studentCode, $fullName, $email, $className, $projectRole]);
            $message = "Thêm thành viên '{$fullName}' thành công vào MySQL!";
            $messageType = 'success';
        } else {
            $message = 'Vui lòng nhập đầy đủ các trường bắt buộc!';
            $messageType = 'warning';
        }
    }

    // Xử lý Xóa thành viên
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'delete') {
        $id = (int)($_POST['id'] ?? 0);
        if ($id > 0) {
            $stmt = $pdo->prepare("DELETE FROM students WHERE id = ?");
            $stmt->execute([$id]);
            $message = "Đã xóa bản ghi ID #{$id} khỏi CSDL!";
            $messageType = 'info';
        }
    }

    // Lấy danh sách thành viên
    $stmt = $pdo->query("SELECT * FROM students ORDER BY id ASC");
    $students = $stmt->fetchAll();

} catch (PDOException $e) {
    $message = "Lỗi kết nối MySQL: " . htmlspecialchars($e->getMessage());
    $messageType = 'error';
}

$executionTime = number_format((microtime(true) - $startTime) * 1000, 2);
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Demo Quản Lý Thành Viên - LAMP Stack | Linux_Oss</title>
    <style>
        :root {
            --bg-color: #0f172a;
            --card-bg: #1e293b;
            --border-color: #334155;
            --primary: #38bdf8;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            margin: 0;
            padding: 30px 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 20px;
            margin-bottom: 24px;
        }
        h1 { margin: 0; font-size: 24px; color: var(--primary); }
        .nav-links a {
            color: var(--text-muted);
            text-decoration: none;
            margin-left: 16px;
            padding: 8px 14px;
            border-radius: 6px;
            background: #0f172a;
            border: 1px solid var(--border-color);
            transition: all 0.2s;
        }
        .nav-links a:hover { color: var(--primary); border-color: var(--primary); }
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .alert-success { background: #064e3b; color: #a7f3d0; border: 1px solid #059669; }
        .alert-warning { background: #78350f; color: #fde68a; border: 1px solid #d97706; }
        .alert-error { background: #7f1d1d; color: #fecaca; border: 1px solid #dc2626; }
        .alert-info { background: #1e3a5f; color: #bae6fd; border: 1px solid #0284c7; }
        .grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }
        @media (max-width: 768px) {
            .grid { grid-template-columns: 1fr; }
        }
        .card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 24px;
        }
        .card h2 { margin-top: 0; font-size: 18px; color: #f1f5f9; border-bottom: 1px solid var(--border-color); padding-bottom: 12px; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 12px;
        }
        th, td {
            text-align: left;
            padding: 10px 12px;
            border-bottom: 1px solid var(--border-color);
            font-size: 14px;
        }
        th { color: var(--text-muted); font-weight: 600; }
        tr:hover { background-color: rgba(255, 255, 255, 0.02); }
        .form-group {
            margin-bottom: 16px;
        }
        label {
            display: block;
            margin-bottom: 6px;
            font-size: 13px;
            color: var(--text-muted);
        }
        input, select {
            width: 100%;
            padding: 10px 12px;
            border-radius: 6px;
            border: 1px solid var(--border-color);
            background: #0f172a;
            color: var(--text-main);
            box-sizing: border-box;
            font-size: 14px;
        }
        input:focus { outline: none; border-color: var(--primary); }
        button {
            cursor: pointer;
            border-radius: 6px;
            font-weight: 600;
            transition: all 0.2s;
            border: none;
        }
        .btn-primary {
            width: 100%;
            padding: 12px;
            background: #0284c7;
            color: white;
            font-size: 14px;
        }
        .btn-primary:hover { background: #0369a1; }
        .btn-danger {
            background: transparent;
            color: var(--danger);
            padding: 4px 8px;
            font-size: 12px;
            border: 1px solid #7f1d1d;
        }
        .btn-danger:hover { background: #7f1d1d; color: white; }
        .metrics {
            margin-top: 24px;
            background: #090d16;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 13px;
            color: var(--text-muted);
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
        }
    </style>
</head>
<body>
<div class="container">
    <header>
        <div>
            <h1>📊 Demo Quản Lý Dự Án LAMP Stack</h1>
            <small style="color: var(--text-muted);">Mã nguồn PHP tương tác trực tiếp Cơ sở dữ liệu MySQL qua PDO</small>
        </div>
        <div class="nav-links">
            <a href="index.php">🔍 System Health</a>
            <a href="https://lamp.local/" target="_blank">🌐 lamp.local</a>
        </div>
    </header>

    <?php if ($message !== ''): ?>
        <div class="alert alert-<?= $messageType ?>">
            <?= htmlspecialchars($message) ?>
        </div>
    <?php endif; ?>

    <div class="grid">
        <!-- Danh sách thành viên -->
        <div class="card">
            <h2>Danh Sách Bản Ghi Trong MySQL (Table `students`)</h2>
            <?php if (empty($students)): ?>
                <p style="color: var(--text-muted); font-size: 14px;">Chưa có bản ghi nào hoặc chưa nạp file `src/db_schema.sql`.</p>
            <?php else: ?>
                <div style="overflow-x: auto;">
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Mã SV</th>
                                <th>Họ & Tên</th>
                                <th>Lớp</th>
                                <th>Vai trò Đồ án</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($students as $s): ?>
                                <tr>
                                    <td><?= (int)$s['id'] ?></td>
                                    <td><strong><?= htmlspecialchars($s['student_code']) ?></strong></td>
                                    <td><?= htmlspecialchars($s['full_name']) ?></td>
                                    <td><?= htmlspecialchars($s['class_name']) ?></td>
                                    <td><span style="color: var(--primary);"><?= htmlspecialchars($s['project_role']) ?></span></td>
                                    <td>
                                        <form method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn xóa bản ghi này?');" style="margin: 0;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<?= (int)$s['id'] ?>">
                                            <button type="submit" class="btn-danger">Xóa</button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            <?php endif; ?>
        </div>

        <!-- Form thêm mới -->
        <div class="card">
            <h2>➕ Thêm Thành Viên Mới</h2>
            <form method="POST">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label>Mã Sinh Viên / Mã Số (*)</label>
                    <input type="text" name="student_code" placeholder="VD: B21DCCN123" required>
                </div>
                <div class="form-group">
                    <label>Họ và Tên (*)</label>
                    <input type="text" name="full_name" placeholder="VD: Trần Văn Demo" required>
                </div>
                <div class="form-group">
                    <label>Email Liên Hệ (*)</label>
                    <input type="email" name="email" placeholder="VD: demo@example.com" required>
                </div>
                <div class="form-group">
                    <label>Lớp Sinh Hoạt</label>
                    <input type="text" name="class_name" placeholder="VD: D21CQCN01-B" value="D21CQCN01-B">
                </div>
                <div class="form-group">
                    <label>Vai Trò Trong Đồ Án</label>
                    <input type="text" name="project_role" placeholder="VD: Tester / SysAdmin">
                </div>
                <button type="submit" class="btn-primary">Ghi Dữ Liệu Vào MySQL</button>
            </form>
        </div>
    </div>

    <div class="metrics">
        <span>⏱ Thời gian thực thi truy vấn: <strong><?= $executionTime ?> ms</strong></span>
        <span>🐘 PHP Version: <strong><?= PHP_VERSION ?></strong></span>
        <span>🗄️ Database: <strong>MySQL (lamp_db)</strong></span>
        <span>🚀 Web Server: <strong><?= htmlspecialchars($_SERVER['SERVER_SOFTWARE'] ?? 'Apache') ?></strong></span>
    </div>
</div>
</body>
</html>
