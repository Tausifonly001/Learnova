<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Response;
use App\Models\Course;

class CourseController
{
    public function index(): void
    {
        $filters = [
            'search' => trim((string) ($_GET['search'] ?? '')),
            'category_id' => $_GET['category_id'] ?? null,
            'sort' => $_GET['sort'] ?? null,
            'limit' => $_GET['limit'] ?? 10,
            'offset' => $_GET['offset'] ?? 0,
        ];

        $courses = (new Course())->list($filters);
        Response::json(true, 'Courses fetched', ['courses' => $courses]);
    }
}
