<?php

declare(strict_types=1);

namespace App\Core;

class Session
{
    public static function start(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_name((string) env('SESSION_NAME', 'learnova_session'));

            $isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
                || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');

            session_set_cookie_params([
                'httponly' => true,
                'secure' => $isHttps,
                'samesite' => 'Lax',
                'path' => '/',
            ]);
            session_start();
        }

        if (!isset($_SESSION['initiated'])) {
            session_regenerate_id(true);
            $_SESSION['initiated'] = time();
        }
    }

    public static function regenerate(): void
    {
        session_regenerate_id(true);
    }
}
