<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/bootstrap/app.php';

use App\Core\Router;

$router = new Router();
require base_path('routes/web.php');
require base_path('routes/api.php');

$_SERVER['LEARNOVA_ROUTES_LOADED'] = (string) $router->routeCount();

$requestUri = $_SERVER['REQUEST_URI'] ?? '/';
$path = parse_url($requestUri, PHP_URL_PATH) ?: '/';
$scriptDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
if ($scriptDir !== '' && $scriptDir !== '/' && str_starts_with($path, $scriptDir)) {
    $path = substr($path, strlen($scriptDir)) ?: '/';
}

$router->dispatch($_SERVER['REQUEST_METHOD'] ?? 'GET', $path);
