<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap/app.php';

use App\Core\Database;

$status = 'failed';
$message = 'Database connection failed.';

try {
    $pdo = Database::connection();
    $version = (string) $pdo->query('SELECT VERSION()')->fetchColumn();
    $database = (string) $pdo->query('SELECT DATABASE()')->fetchColumn();

    $status = 'ok';
    $message = 'Database connection successful.';
} catch (Throwable $exception) {
    $version = 'n/a';
    $database = 'n/a';
}
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Learnova DB Health Check</title>
  <style>
    body{font-family:Inter,system-ui,-apple-system,sans-serif;background:#0f172a;color:#e2e8f0;display:grid;place-items:center;min-height:100vh;margin:0;padding:24px}
    .card{width:min(560px,100%);background:rgba(15,23,42,.75);border:1px solid rgba(148,163,184,.25);border-radius:16px;padding:24px;box-shadow:0 20px 45px rgba(2,6,23,.35)}
    .badge{display:inline-block;padding:4px 10px;border-radius:999px;font-size:12px;font-weight:700;letter-spacing:.05em;text-transform:uppercase}
    .ok{background:#14532d;color:#bbf7d0}.failed{background:#7f1d1d;color:#fecaca}
    code{background:rgba(51,65,85,.55);padding:2px 6px;border-radius:6px}
  </style>
</head>
<body>
  <section class="card">
    <span class="badge <?= htmlspecialchars($status, ENT_QUOTES, 'UTF-8') ?>"><?= htmlspecialchars($status, ENT_QUOTES, 'UTF-8') ?></span>
    <h1>Learnova Phase 1: DB Connection Test</h1>
    <p><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p>
    <p><strong>Database:</strong> <code><?= htmlspecialchars($database, ENT_QUOTES, 'UTF-8') ?></code></p>
    <p><strong>MySQL Version:</strong> <code><?= htmlspecialchars($version, ENT_QUOTES, 'UTF-8') ?></code></p>
  </section>
</body>
</html>
