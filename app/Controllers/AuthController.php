<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Response;
use App\Core\Security;
use App\Core\Session;
use App\Core\Validator;
use App\Models\User;

class AuthController
{
    public function register(): void
    {
        $payload = $_POST;
        if (!Security::verifyCsrf($payload['csrf_token'] ?? null)) {
            Response::json(false, 'Invalid CSRF token', [], ['csrf' => 'Token mismatch'], 419);
        }

        $errors = Validator::required($payload, ['name', 'email', 'password', 'role']);
        if (!in_array(($payload['role'] ?? ''), ['student', 'creator'], true)) {
            $errors['role'] = 'Only student and creator registrations are allowed';
        }
        if ($emailError = Validator::email($payload['email'] ?? '')) {
            $errors['email'] = $emailError;
        }
        if (!empty($errors)) {
            Response::json(false, 'Validation failed', [], $errors, 422);
        }

        $userModel = new User();
        if ($userModel->findByEmail($payload['email'])) {
            Response::json(false, 'Email already exists', [], ['email' => 'Use another email'], 409);
        }

        $userId = $userModel->create([
            'name' => Security::clean($payload['name']),
            'email' => strtolower(trim($payload['email'])),
            'password_hash' => password_hash($payload['password'], PASSWORD_DEFAULT),
            'role' => $payload['role'],
        ]);
        $userModel->createProfile($userId);

        Response::json(true, 'Registration successful');
    }

    public function login(): void
    {
        $payload = $_POST;
        if (!Security::verifyCsrf($payload['csrf_token'] ?? null)) {
            Response::json(false, 'Invalid CSRF token', [], ['csrf' => 'Token mismatch'], 419);
        }

        $errors = Validator::required($payload, ['email', 'password']);
        if (!empty($errors)) {
            Response::json(false, 'Validation failed', [], $errors, 422);
        }

        $userModel = new User();
        $ip = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
        if ($userModel->tooManyAttempts($payload['email'], $ip)) {
            Response::json(false, 'Too many attempts', [], ['auth' => 'Try again later'], 429);
        }

        $user = $userModel->findByEmail(strtolower(trim($payload['email'])));
        if (!$user || !password_verify($payload['password'], $user['password_hash'])) {
            $userModel->recordLoginAttempt($payload['email'], $ip, false);
            Response::json(false, 'Invalid credentials', [], ['auth' => 'Invalid email/password'], 401);
        }

        if ($user['role'] === 'admin' && ($payload['portal'] ?? 'user') !== 'admin') {
            Response::json(false, 'Admin must use admin login', [], ['role' => 'Wrong login portal'], 403);
        }

        Session::regenerate();
        $_SESSION['auth'] = [
            'id' => (int) $user['id'],
            'name' => $user['name'],
            'role' => $user['role'],
        ];
        $userModel->recordLoginAttempt($payload['email'], $ip, true);

        Response::json(true, 'Login successful', ['user' => $_SESSION['auth']]);
    }

    public function logout(): void
    {
        $csrf = $_POST['csrf_token'] ?? $_SERVER['HTTP_X_CSRF_TOKEN'] ?? null;
        if (!Security::verifyCsrf(is_string($csrf) ? $csrf : null)) {
            Response::json(false, 'Invalid CSRF token', [], ['csrf' => 'Token mismatch'], 419);
        }

        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $params['path'] ?? '/', $params['domain'] ?? '', (bool) ($params['secure'] ?? false), (bool) ($params['httponly'] ?? true));
        }
        session_destroy();

        Response::json(true, 'Logged out');
    }
}
