USE learnova;

INSERT INTO users (name, email, password_hash, role, status, email_verified_at)
VALUES
  ('Learnova Admin', 'admin@learnova.test', '$2y$10$9Mnz/vpb8h3fGgVJtJm9M.SFjPBNNh4hY4DY63V5DqNnWzQ3AXevi', 'admin', 'active', NOW()),
  ('Demo Creator', 'creator@learnova.test', '$2y$10$9Mnz/vpb8h3fGgVJtJm9M.SFjPBNNh4hY4DY63V5DqNnWzQ3AXevi', 'creator', 'active', NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO profiles (user_id, bio, country)
SELECT id, 'Platform administrator account.', 'Global' FROM users WHERE email = 'admin@learnova.test'
ON DUPLICATE KEY UPDATE bio = VALUES(bio);

INSERT INTO profiles (user_id, bio, country)
SELECT id, 'Creative coding educator focused on modern frontend systems.', 'India' FROM users WHERE email = 'creator@learnova.test'
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

INSERT INTO courses (
  creator_id,
  category_id,
  title,
  slug,
  short_description,
  description,
  level,
  language,
  status,
  is_subscription_enabled,
  published_at
)
SELECT
  creator.id,
  category.id,
  'Modern UI Motion Design with GSAP',
  'modern-ui-motion-design-gsap',
  'Build premium-feel interfaces using motion principles and performant animation architecture.',
  'A practical, project-based course that teaches animation systems, GSAP timelines, and conversion-focused UI motion.',
  'intermediate',
  'English',
  'approved',
  1,
  NOW()
FROM users creator
JOIN categories category ON category.slug = 'ui-ux-design'
WHERE creator.email = 'creator@learnova.test'
ON DUPLICATE KEY UPDATE short_description = VALUES(short_description), status = VALUES(status);

INSERT INTO course_tags (course_id, tag_id)
SELECT course.id, tag.id
FROM courses course
JOIN tags tag ON tag.slug IN ('javascript', 'ui-animation')
WHERE course.slug = 'modern-ui-motion-design-gsap'
ON DUPLICATE KEY UPDATE course_id = VALUES(course_id);

INSERT INTO pricing (course_id, price_type, amount, currency, is_active)
SELECT id, 'one_time', 79.00, 'USD', 1
FROM courses
WHERE slug = 'modern-ui-motion-design-gsap'
ON DUPLICATE KEY UPDATE amount = VALUES(amount), is_active = VALUES(is_active);
