<?php

declare(strict_types=1);

return [
    'name' => env('APP_NAME', 'Learnova'),
    'env' => env('APP_ENV', 'development'),
    'debug' => filter_var(env('APP_DEBUG', 'false'), FILTER_VALIDATE_BOOL),
    'url' => env('APP_URL', 'http://localhost/Learnova/public'),
    'session' => [
        'name' => env('SESSION_NAME', 'learnova_session'),
        'secure' => filter_var(env('SESSION_SECURE', 'false'), FILTER_VALIDATE_BOOL),
        'same_site' => env('SESSION_SAMESITE', 'Lax'),
    ],
];
