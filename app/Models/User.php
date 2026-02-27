<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\Database;

class User
{
    public function findByEmail(string $email): array|false
    {
        $stmt = Database::connection()->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
        $stmt->execute(['email' => $email]);

        return $stmt->fetch();
    }

    public function create(array $data): int
    {
        $stmt = Database::connection()->prepare(
            'INSERT INTO users (name, email, password_hash, role, status) VALUES (:name, :email, :password_hash, :role, :status)'
        );
        $stmt->execute([
            'name' => $data['name'],
            'email' => $data['email'],
            'password_hash' => $data['password_hash'],
            'role' => $data['role'],
            'status' => 'active',
        ]);

        return (int) Database::connection()->lastInsertId();
    }

    public function createProfile(int $userId): void
    {
        $stmt = Database::connection()->prepare('INSERT INTO profiles (user_id) VALUES (:user_id)');
        $stmt->execute(['user_id' => $userId]);
    }

    public function recordLoginAttempt(string $email, string $ip, bool $success): void
    {
        $stmt = Database::connection()->prepare(
            'INSERT INTO audit_logs (actor_user_id, action, entity_type, metadata, ip_address) VALUES (NULL, :action, :entity_type, :metadata, :ip_address)'
        );
        $stmt->execute([
            'action' => $success ? 'auth.login.success' : 'auth.login.failed',
            'entity_type' => 'auth',
            'metadata' => json_encode(['email' => strtolower(trim($email))], JSON_UNESCAPED_UNICODE),
            'ip_address' => $ip,
        ]);
    }

    public function tooManyAttempts(string $email, string $ip): bool
    {
        $minutes = (int) env('LOGIN_LOCK_MINUTES', '15');
        $maxAttempts = (int) env('LOGIN_MAX_ATTEMPTS', '5');
        $cutoff = (new \DateTimeImmutable(sprintf('-%d minutes', max(1, $minutes))))->format('Y-m-d H:i:s');

        $stmt = Database::connection()->prepare(
            'SELECT COUNT(*) FROM audit_logs
             WHERE action = :action
             AND created_at >= :cutoff
             AND (metadata LIKE :email OR ip_address = :ip)'
        );
        $stmt->execute([
            'action' => 'auth.login.failed',
            'cutoff' => $cutoff,
            'email' => '%"email":"' . strtolower(trim($email)) . '"%',
            'ip' => $ip,
        ]);

        return (int) $stmt->fetchColumn() >= $maxAttempts;
    }
}
