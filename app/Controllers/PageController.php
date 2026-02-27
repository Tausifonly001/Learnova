<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Security;
use App\Core\View;

class PageController
{
    public function home(): void
    {
        View::render('pages/home', ['csrf' => Security::csrfToken(), 'title' => 'Learnova']);
    }
}
