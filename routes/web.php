<?php

declare(strict_types=1);

use App\Controllers\HealthController;
use App\Controllers\PageController;

$router->add('GET', '/', [PageController::class, 'home']);
$router->add('GET', '/health', [HealthController::class, 'index']);
