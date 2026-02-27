<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\Database;
use PDO;

class Course
{
    public function list(array $filters): array
    {
        $sql = 'SELECT c.id, c.title, c.slug, c.thumbnail_url, c.level, c.status, cat.name AS category_name,
                       COALESCE(AVG(r.rating),0) AS avg_rating, p.amount, p.currency
                FROM courses c
                INNER JOIN categories cat ON cat.id = c.category_id
                LEFT JOIN reviews r ON r.course_id = c.id
                LEFT JOIN pricing p ON p.course_id = c.id AND p.price_type = "one_time"
                WHERE c.status = "approved"';

        $params = [];
        if (!empty($filters['search'])) {
            $sql .= ' AND (c.title LIKE :search OR c.short_description LIKE :search)';
            $params['search'] = '%' . $filters['search'] . '%';
        }
        if (!empty($filters['category_id'])) {
            $sql .= ' AND c.category_id = :category_id';
            $params['category_id'] = (int) $filters['category_id'];
        }

        $sql .= ' GROUP BY c.id';

        if (($filters['sort'] ?? '') === 'rating_desc') {
            $sql .= ' ORDER BY avg_rating DESC';
        } else {
            $sql .= ' ORDER BY c.created_at DESC';
        }

        $limit = max(1, (int) ($filters['limit'] ?? 10));
        $offset = max(0, (int) ($filters['offset'] ?? 0));
        $sql .= ' LIMIT :limit OFFSET :offset';

        $stmt = Database::connection()->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue(':' . $key, $value);
        }
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();
    }
}
