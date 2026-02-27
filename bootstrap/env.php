<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/app/Config/Config.php';

use App\Config\Config;

Config::load();

if (!function_exists('env')) {
    function env(string $key, ?string $default = null): ?string
    {
        return Config::get($key, $default);
    }
}
