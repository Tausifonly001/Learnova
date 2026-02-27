<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Database;
use App\Core\Response;

class HealthController
{
    public function index(): void
    {
        $checks = [
            'env_loaded' => $this->isEnvLoaded(),
            'session_started' => $this->isSessionStarted(),
            'routes_loaded' => $this->isRoutesLoaded(),
            'db_connected' => $this->isDatabaseConnected(),
        ];

        $success = !in_array(false, $checks, true);
        $status = $success ? 200 : 503;

        Response::json(
            $success,
            $success ? 'Health check passed' : 'Health check failed',
            [
                'checks' => $checks,
                'timestamp' => date(DATE_ATOM),
            ],
            $success ? [] : ['health' => 'One or more checks failed'],
            $status
        );
    }

    private function isEnvLoaded(): bool
    {
        $appName = env('APP_NAME');

        return is_string($appName) && $appName !== '';
    }

    private function isSessionStarted(): bool
    {
        return session_status() === PHP_SESSION_ACTIVE && isset($_SESSION['initiated']);
    }

    private function isRoutesLoaded(): bool
    {
        return (int) ($_SERVER['LEARNOVA_ROUTES_LOADED'] ?? 0) > 0;
    }

    private function isDatabaseConnected(): bool
    {
        try {
            $pdo = Database::connection();
            $value = $pdo->query('SELECT 1')->fetchColumn();

            return (int) $value === 1;
        } catch (\Throwable) {
            return false;
        }
    }
}
