<?php

declare(strict_types=1);

namespace App\Core;

class Validator
{
    public static function required(array $payload, array $fields): array
    {
        $errors = [];
        foreach ($fields as $field) {
            if (!isset($payload[$field]) || trim((string) $payload[$field]) === '') {
                $errors[$field] = ucfirst($field) . ' is required';
            }
        }
        return $errors;
    }

    public static function email(string $email): ?string
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) ? null : 'Invalid email format';
    }
}
