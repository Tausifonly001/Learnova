<?php

declare(strict_types=1);

require_once __DIR__ . '/env.php';
require_once dirname(__DIR__) . '/app/Helpers/common.php';

spl_autoload_register(static function ($class): void {
    $prefix = 'App\\';
    $baseDir = dirname(__DIR__) . '/app/';
    if (str_starts_with($class, $prefix)) {
        $relativeClass = substr($class, strlen($prefix));
        $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';
        if (is_file($file)) {
            require_once $file;
        }
    }
});

use App\Core\Session;

Session::start();
