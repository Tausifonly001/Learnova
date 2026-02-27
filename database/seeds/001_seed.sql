USE learnova;

INSERT INTO users (name, email, password_hash, role, status, email_verified_at)
VALUES ('Learnova Admin', 'admin@learnova.test', '$2y$10$9Mnz/vpb8h3fGgVJtJm9M.SFjPBNNh4hY4DY63V5DqNnWzQ3AXevi', 'admin', 'active', NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO profiles (user_id)
SELECT id FROM users WHERE email = 'admin@learnova.test'
ON DUPLICATE KEY UPDATE user_id = user_id;

INSERT INTO categories (name, slug)
VALUES
('Web Development', 'web-development'),
('UI/UX Design', 'ui-ux-design'),
('AI & Automation', 'ai-automation'),
('Digital Marketing', 'digital-marketing')
ON DUPLICATE KEY UPDATE name = VALUES(name);
