<?php

declare(strict_types=1);

use App\Core\Response;

function base_path(string $path = ''): string
{
    $base = dirname(__DIR__, 2);
    return $path ? $base . '/' . ltrim($path, '/') : $base;
}

function app_url(string $path = ''): string
{
    $url = rtrim((string) env('APP_URL', ''), '/');
    return $path ? $url . '/' . ltrim($path, '/') : $url;
}

function config(string $key, mixed $default = null): mixed
{
    static $cache = [];

    [$file, $nested] = array_pad(explode('.', $key, 2), 2, null);

    if (!isset($cache[$file])) {
        $path = base_path('app/Config/' . $file . '.php');
        $cache[$file] = is_file($path) ? require $path : [];
    }

    $value = $cache[$file];
    if ($nested !== null) {
        foreach (explode('.', $nested) as $segment) {
            if (!is_array($value) || !array_key_exists($segment, $value)) {
                return $default;
            }
            $value = $value[$segment];
        }
    }

    return $value ?? $default;
}

function requireAuth(): void
{
    if (empty($_SESSION['auth'])) {
        Response::json(false, 'Authentication required', [], ['auth' => 'Please login first'], 401);
    }
}

function requireRole(array $roles): void
{
    requireAuth();
    $role = $_SESSION['auth']['role'] ?? null;
    if (!$role || !in_array($role, $roles, true)) {
        Response::json(false, 'Forbidden', [], ['role' => 'Insufficient permissions'], 403);
    }
}
