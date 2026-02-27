<?php

declare(strict_types=1);

if (!function_exists('env')) {
    function env(string $key, ?string $default = null): ?string
    {
        static $values = null;

        if ($values === null) {
            $values = [];
            $path = dirname(__DIR__) . '/.env';
            if (is_file($path)) {
                $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
                foreach ($lines as $line) {
                    if (str_starts_with(trim($line), '#') || !str_contains($line, '=')) {
                        continue;
                    }
                    [$envKey, $envValue] = array_map('trim', explode('=', $line, 2));
                    $values[$envKey] = trim($envValue, "\"'");
                }
            }
        }

        return $values[$key] ?? $_ENV[$key] ?? $default;
    }
}
