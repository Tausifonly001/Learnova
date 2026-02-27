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
