<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Database;
use App\Core\View;
use Throwable;

class PageController
{
    public function home(): void
    {
        $dbStatus = [
            'connected' => false,
            'database' => config('database.database', env('DB_NAME', 'learnova')),
            'message' => 'Database connection test not executed.',
        ];

        try {
            $pdo = Database::connection();
            $stmt = $pdo->query('SELECT NOW() AS server_time');
            $serverTime = $stmt->fetch()['server_time'] ?? null;
            $dbStatus = [
                'connected' => true,
                'database' => config('database.database', env('DB_NAME', 'learnova')),
                'message' => 'Database connection successful.',
                'server_time' => $serverTime,
            ];
        } catch (Throwable $exception) {
            $dbStatus['message'] = 'Database connection failed. Verify .env credentials and imported schema.';
        }

        View::render('pages/home', ['title' => 'Learnova Phase 1', 'dbStatus' => $dbStatus]);
    }
}
