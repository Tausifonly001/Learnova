<?php

declare(strict_types=1);

namespace App\Core;

class Response
{
    public static function json(bool $success, string $message = '', array $data = [], array $errors = [], int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'success' => $success,
            'message' => $message,
            'data' => $data,
            'errors' => $errors,
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}
