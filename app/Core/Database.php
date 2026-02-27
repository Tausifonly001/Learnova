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
            $db = config('database');
            $dsn = sprintf(
                '%s:host=%s;port=%s;dbname=%s;charset=%s',
                $db['driver'] ?? 'mysql',
                $db['host'] ?? '127.0.0.1',
                $db['port'] ?? '3306',
                $db['database'] ?? 'learnova',
                $db['charset'] ?? 'utf8mb4'
            );

            try {
                self::$instance = new PDO(
                    $dsn,
                    (string) ($db['username'] ?? 'root'),
                    (string) ($db['password'] ?? ''),
                    [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::ATTR_EMULATE_PREPARES => false,
                    ]
                );
            } catch (PDOException $exception) {
                throw new \RuntimeException('Database connection failed. Check .env settings.', 0, $exception);
            }
        }

        return self::$instance;
    }
}
