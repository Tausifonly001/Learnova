<?php

declare(strict_types=1);

namespace App\Config;

final class Config
{
    private static bool $loaded = false;

    /** @var array<string, string> */
    private static array $values = [];

    public static function load(?string $path = null): void
    {
        if (self::$loaded) {
            return;
        }

        $envPath = $path ?? dirname(__DIR__, 2) . '/.env';
        if (!is_file($envPath)) {
            self::$loaded = true;
            return;
        }

        $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
        foreach ($lines as $line) {
            $trimmed = trim($line);
            if ($trimmed === '' || str_starts_with($trimmed, '#') || !str_contains($trimmed, '=')) {
                continue;
            }

            [$key, $value] = array_map('trim', explode('=', $trimmed, 2));
            $normalized = trim($value, "\"'");

            self::$values[$key] = $normalized;
            $_ENV[$key] = $normalized;
            putenv(sprintf('%s=%s', $key, $normalized));
        }

        self::$loaded = true;
    }

    public static function get(string $key, ?string $default = null): ?string
    {
        self::load();

        return self::$values[$key] ?? $_ENV[$key] ?? (getenv($key) ?: null) ?? $default;
    }
}
