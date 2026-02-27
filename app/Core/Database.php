<?php

declare(strict_types=1);

namespace App\Core;

use PDO;
use PDOException;

class Database
{
    private static ?PDO $instance = null;

    public static function connection(): PDO
    {
        if (self::$instance === null) {
            $dsn = sprintf(
                'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
                env('DB_HOST', '127.0.0.1'),
                env('DB_PORT', '3306'),
                env('DB_NAME', 'learnova')
            );

            try {
                self::$instance = new PDO(
                    $dsn,
                    (string) env('DB_USER', 'root'),
                    (string) env('DB_PASS', ''),
                    [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::ATTR_EMULATE_PREPARES => false,
                    ]
                );
            } catch (PDOException $exception) {
                http_response_code(500);
                echo 'Database connection failed. Check .env settings.';
                exit;
            }
        }

        return self::$instance;
    }
}
