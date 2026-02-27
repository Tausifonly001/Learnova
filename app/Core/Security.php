<?php

declare(strict_types=1);

namespace App\Core;

class Security
{
    public static function csrfToken(): string
    {
        $ttl = (int) env('CSRF_TOKEN_TTL', '3600');
        $needsNewToken = !isset($_SESSION['csrf']) || (time() - ($_SESSION['csrf_issued_at'] ?? 0) > $ttl);

        if ($needsNewToken) {
            $_SESSION['csrf'] = bin2hex(random_bytes(32));
            $_SESSION['csrf_issued_at'] = time();
        }

        return $_SESSION['csrf'];
    }

    public static function verifyCsrf(?string $token): bool
    {
        return hash_equals($_SESSION['csrf'] ?? '', (string) $token);
    }

    public static function clean(string $value): string
    {
        return htmlspecialchars(trim($value), ENT_QUOTES, 'UTF-8');
    }
}
