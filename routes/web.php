<?php

declare(strict_types=1);

use App\Controllers\PageController;

$router->add('GET', '/', [PageController::class, 'home']);
