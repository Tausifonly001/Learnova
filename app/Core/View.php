<?php

declare(strict_types=1);

namespace App\Core;

class View
{
    public static function render(string $view, array $data = [], string $layout = 'layouts/app'): void
    {
        extract($data, EXTR_SKIP);
        $viewPath = base_path('app/Views/' . $view . '.php');
        $layoutPath = base_path('app/Views/' . $layout . '.php');

        ob_start();
        include $viewPath;
        $content = ob_get_clean();

        include $layoutPath;
    }

    public static function partial(string $view, array $data = []): void
    {
        extract($data, EXTR_SKIP);
        include base_path('app/Views/' . $view . '.php');
    }
}
