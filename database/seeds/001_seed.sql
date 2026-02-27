USE learnova;

INSERT INTO users (name, email, password_hash, role, status, email_verified_at)
VALUES
('Learnova Admin', 'admin@learnova.test', '$2y$10$9Mnz/vpb8h3fGgVJtJm9M.SFjPBNNh4hY4DY63V5DqNnWzQ3AXevi', 'admin', 'active', NOW()),
('Ava Creator', 'creator@learnova.test', '$2y$10$9Mnz/vpb8h3fGgVJtJm9M.SFjPBNNh4hY4DY63V5DqNnWzQ3AXevi', 'creator', 'active', NOW()),
('Sam Student', 'student@learnova.test', '$2y$10$9Mnz/vpb8h3fGgVJtJm9M.SFjPBNNh4hY4DY63V5DqNnWzQ3AXevi', 'student', 'active', NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name), status = VALUES(status);

INSERT INTO profiles (user_id, bio)
SELECT id, 'Seed profile' FROM users
ON DUPLICATE KEY UPDATE bio = VALUES(bio);

INSERT INTO categories (name, slug)
VALUES
  ('Web Development', 'web-development'),
  ('UI/UX Design', 'ui-ux-design'),
  ('AI & Automation', 'ai-automation'),
  ('Digital Marketing', 'digital-marketing')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO tags (name, slug)
VALUES
  ('JavaScript', 'javascript'),
  ('PHP', 'php'),
  ('UI Animation', 'ui-animation'),
  ('Figma', 'figma'),
  ('Productivity', 'productivity')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO tags (name, slug)
VALUES
('Laravel', 'laravel'),
('Figma', 'figma'),
('Prompt Engineering', 'prompt-engineering'),
('JavaScript', 'javascript')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO courses (creator_id, category_id, title, slug, short_description, description, level, language, status, published_at)
SELECT 
  (SELECT id FROM users WHERE email = 'creator@learnova.test' LIMIT 1),
  (SELECT id FROM categories WHERE slug = 'web-development' LIMIT 1),
  'Build Premium Course Platforms with PHP MVC',
  'build-premium-course-platforms-php-mvc',
  'A practical path to architecting secure and scalable learning platforms.',
  'This demo course includes architecture, modular MVC, API-first patterns, and monetization strategies for education products.',
  'intermediate',
  'English',
  'approved',
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM courses WHERE slug = 'build-premium-course-platforms-php-mvc'
);

INSERT INTO course_tags (course_id, tag_id)
SELECT c.id, t.id
FROM courses c
JOIN tags t ON t.slug IN ('laravel', 'javascript')
WHERE c.slug = 'build-premium-course-platforms-php-mvc'
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

INSERT INTO course_sections (course_id, title, sort_order)
SELECT c.id, 'Welcome & Setup', 1
FROM courses c
WHERE c.slug = 'build-premium-course-platforms-php-mvc'
AND NOT EXISTS (
  SELECT 1 FROM course_sections cs WHERE cs.course_id = c.id AND cs.sort_order = 1
);

INSERT INTO lessons (course_id, section_id, title, content_type, duration_seconds, is_preview, sort_order)
SELECT c.id, cs.id, 'Architecture Overview', 'video', 420, 1, 1
FROM courses c
JOIN course_sections cs ON cs.course_id = c.id AND cs.sort_order = 1
WHERE c.slug = 'build-premium-course-platforms-php-mvc'
AND NOT EXISTS (
  SELECT 1 FROM lessons l WHERE l.section_id = cs.id AND l.sort_order = 1
);

INSERT INTO pricing (course_id, one_time_enabled, one_time_price, subscription_enabled, subscription_price, currency)
SELECT c.id, 1, 129.00, 1, 19.00, 'USD'
FROM courses c
WHERE c.slug = 'build-premium-course-platforms-php-mvc'
ON DUPLICATE KEY UPDATE 
  one_time_enabled = VALUES(one_time_enabled),
  one_time_price = VALUES(one_time_price),
  subscription_enabled = VALUES(subscription_enabled),
  subscription_price = VALUES(subscription_price),
  currency = VALUES(currency);
