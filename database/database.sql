CREATE DATABASE IF NOT EXISTS learnova CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE learnova;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS audit_logs;
DROP VIEW IF EXISTS reports_flags;
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS payouts;
DROP TABLE IF EXISTS coupon_usage;
DROP TABLE IF EXISTS coupons;
DROP TABLE IF EXISTS wishlists;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS lesson_progress;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS user_subscriptions;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS pricing;
DROP TABLE IF EXISTS lessons;
DROP TABLE IF EXISTS course_sections;
DROP TABLE IF EXISTS course_tags;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS creator_verification;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('student','creator','admin') NOT NULL,
  status ENUM('active','suspended','banned') NOT NULL DEFAULT 'active',
  email_verified_at DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_role_status (role, status)
);

CREATE TABLE profiles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  avatar_url VARCHAR(255) NULL,
  bio TEXT NULL,
  phone VARCHAR(30) NULL,
  country VARCHAR(80) NULL,
  timezone VARCHAR(80) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE creator_verification (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  id_document_path VARCHAR(255) NULL,
  portfolio_url VARCHAR(255) NULL,
  status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  reviewed_by BIGINT UNSIGNED NULL,
  reviewed_at DATETIME NULL,
  rejection_reason VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_creator_verification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_creator_verification_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_creator_verification_status (status)
);

CREATE TABLE categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(90) NOT NULL UNIQUE,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tags (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(90) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  creator_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  slug VARCHAR(190) NOT NULL UNIQUE,
  short_description VARCHAR(255) NULL,
  description MEDIUMTEXT NULL,
  level ENUM('beginner','intermediate','advanced') DEFAULT 'beginner',
  language VARCHAR(40) DEFAULT 'English',
  thumbnail_path VARCHAR(255) NULL,
  status ENUM('draft','pending','approved','rejected') NOT NULL DEFAULT 'draft',
  rejection_reason VARCHAR(255) NULL,
  published_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_courses_creator FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_courses_category FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_courses_status_category (status, category_id),
  FULLTEXT INDEX ftx_courses_search (title, short_description, description)
);

CREATE TABLE course_tags (
  course_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (course_id, tag_id),
  CONSTRAINT fk_course_tags_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  CONSTRAINT fk_course_tags_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

CREATE TABLE course_sections (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  sort_order INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_course_sections_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_course_sections_course_order (course_id, sort_order)
);

CREATE TABLE lessons (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL,
  section_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  content_type ENUM('video','article','resource') NOT NULL DEFAULT 'video',
  video_url VARCHAR(255) NULL,
  content LONGTEXT NULL,
  duration_seconds INT UNSIGNED NOT NULL DEFAULT 0,
  is_preview TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_lessons_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  CONSTRAINT fk_lessons_section FOREIGN KEY (section_id) REFERENCES course_sections(id) ON DELETE CASCADE,
  INDEX idx_lessons_course_section_order (course_id, section_id, sort_order)
);

CREATE TABLE pricing (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL UNIQUE,
  one_time_enabled TINYINT(1) NOT NULL DEFAULT 1,
  one_time_price DECIMAL(10,2) NULL,
  subscription_enabled TINYINT(1) NOT NULL DEFAULT 0,
  subscription_price DECIMAL(10,2) NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pricing_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_pricing_subscription_enabled (subscription_enabled)
);

CREATE TABLE orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  order_number VARCHAR(30) NOT NULL UNIQUE,
  subtotal DECIMAL(10,2) NOT NULL,
  discount_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  tax_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  grand_total DECIMAL(10,2) NOT NULL,
  status ENUM('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_orders_user_status (user_id, status)
);

CREATE TABLE order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  pricing_id BIGINT UNSIGNED NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  creator_earning DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_order_items_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT fk_order_items_pricing FOREIGN KEY (pricing_id) REFERENCES pricing(id),
  INDEX idx_order_items_order_course (order_id, course_id)
);

CREATE TABLE payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  provider VARCHAR(50) NOT NULL,
  provider_payment_id VARCHAR(120) NULL,
  provider_order_id VARCHAR(120) NULL,
  amount DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  creator_earning DECIMAL(10,2) NOT NULL DEFAULT 0,
  status ENUM('initiated','captured','failed','refunded') NOT NULL DEFAULT 'initiated',
  webhook_payload JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  INDEX idx_payments_status_created (status, created_at)
);

CREATE TABLE subscriptions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) NOT NULL UNIQUE,
  billing_cycle ENUM('monthly','annual') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  features JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE user_subscriptions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  subscription_id BIGINT UNSIGNED NOT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  status ENUM('active','expired','cancelled') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_subscriptions_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_user_subscriptions_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
  INDEX idx_user_subscriptions_user_status (user_id, status, end_date)
);

CREATE TABLE enrollments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  order_item_id BIGINT UNSIGNED NULL,
  enrolled_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  progress_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_user_course (user_id, course_id),
  CONSTRAINT fk_enrollments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_enrollments_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  CONSTRAINT fk_enrollments_order_item FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE SET NULL,
  INDEX idx_enrollments_course (course_id)
);

CREATE TABLE lesson_progress (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  enrollment_id BIGINT UNSIGNED NOT NULL,
  lesson_id BIGINT UNSIGNED NOT NULL,
  status ENUM('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
  completed_at DATETIME NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_enrollment_lesson (enrollment_id, lesson_id),
  CONSTRAINT fk_lesson_progress_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE,
  CONSTRAINT fk_lesson_progress_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);

CREATE TABLE reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  review TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_review_user_course (user_id, course_id),
  CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_reviews_course_rating (course_id, rating)
);

CREATE TABLE wishlists (
  user_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, course_id),
  CONSTRAINT fk_wishlists_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_wishlists_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

CREATE TABLE coupons (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  creator_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NULL,
  code VARCHAR(30) NOT NULL UNIQUE,
  discount_type ENUM('fixed','percent') NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL,
  max_uses INT NULL,
  starts_at DATETIME NULL,
  expires_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_coupons_creator FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_coupons_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
  INDEX idx_coupons_code_active (code, is_active)
);

CREATE TABLE coupon_usage (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  coupon_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  order_id BIGINT UNSIGNED NOT NULL,
  discount_amount DECIMAL(10,2) NOT NULL,
  used_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_coupon_usage_coupon FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE,
  CONSTRAINT fk_coupon_usage_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_coupon_usage_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  UNIQUE KEY uq_coupon_usage_coupon_order (coupon_id, order_id),
  INDEX idx_coupon_usage_user (user_id, used_at)
);

CREATE TABLE payouts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  creator_id BIGINT UNSIGNED NOT NULL,
  request_amount DECIMAL(10,2) NOT NULL,
  approved_amount DECIMAL(10,2) NULL,
  status ENUM('requested','approved','rejected','paid') NOT NULL DEFAULT 'requested',
  requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  processed_at DATETIME NULL,
  processed_by BIGINT UNSIGNED NULL,
  notes VARCHAR(255) NULL,
  CONSTRAINT fk_payouts_creator FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_payouts_admin FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_payouts_creator_status (creator_id, status)
);

CREATE TABLE reports (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reporter_user_id BIGINT UNSIGNED NOT NULL,
  target_type ENUM('course','lesson','review','user') NOT NULL,
  target_id BIGINT UNSIGNED NOT NULL,
  reason VARCHAR(255) NOT NULL,
  details TEXT NULL,
  status ENUM('open','in_review','resolved','dismissed') NOT NULL DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reviewed_by BIGINT UNSIGNED NULL,
  reviewed_at DATETIME NULL,
  CONSTRAINT fk_reports_reporter FOREIGN KEY (reporter_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reports_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_reports_status_created (status, created_at)
);

CREATE OR REPLACE VIEW reports_flags AS
SELECT * FROM reports;

CREATE TABLE audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  actor_user_id BIGINT UNSIGNED NULL,
  action VARCHAR(120) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id BIGINT UNSIGNED NULL,
  metadata JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_logs_actor FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_audit_logs_action_created (action, created_at),
  INDEX idx_audit_logs_entity (entity_type, entity_id)
);
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
