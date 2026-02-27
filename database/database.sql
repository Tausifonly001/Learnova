CREATE DATABASE IF NOT EXISTS learnova CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE learnova;

CREATE TABLE IF NOT EXISTS users (
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS profiles (
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS creator_verification (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  id_document_url VARCHAR(255) NULL,
  portfolio_url VARCHAR(255) NULL,
  status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  reviewed_by BIGINT UNSIGNED NULL,
  reviewed_at DATETIME NULL,
  notes TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_creator_verification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_creator_verification_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_creator_verification_status (status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(90) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tags (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(90) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  creator_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  slug VARCHAR(190) NOT NULL UNIQUE,
  short_description VARCHAR(255) NULL,
  description MEDIUMTEXT NULL,
  level ENUM('beginner','intermediate','advanced') DEFAULT 'beginner',
  language VARCHAR(40) DEFAULT 'English',
  thumbnail_url VARCHAR(255) NULL,
  status ENUM('draft','pending_approval','approved','rejected') NOT NULL DEFAULT 'draft',
  is_subscription_enabled TINYINT(1) NOT NULL DEFAULT 0,
  published_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_courses_creator FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_courses_category FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_courses_status_category (status, category_id),
  FULLTEXT INDEX ftx_courses_search (title, short_description, description)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS course_tags (
  course_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (course_id, tag_id),
  CONSTRAINT fk_course_tags_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  CONSTRAINT fk_course_tags_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS course_sections (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  sort_order INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_course_sections_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_course_sections_course_order (course_id, sort_order)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS lessons (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL,
  section_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  content_type ENUM('video','article','resource') NOT NULL DEFAULT 'video',
  video_url VARCHAR(255) NULL,
  content LONGTEXT NULL,
  duration_seconds INT NOT NULL DEFAULT 0,
  is_preview TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_lessons_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  CONSTRAINT fk_lessons_section FOREIGN KEY (section_id) REFERENCES course_sections(id) ON DELETE CASCADE,
  INDEX idx_lessons_course_section_order (course_id, section_id, sort_order)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pricing (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL,
  price_type ENUM('one_time','subscription') NOT NULL DEFAULT 'one_time',
  amount DECIMAL(10,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pricing_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_pricing_course_type_active (course_id, price_type, is_active)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  order_number VARCHAR(30) NOT NULL UNIQUE,
  subtotal DECIMAL(10,2) NOT NULL,
  discount_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  tax_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  grand_total DECIMAL(10,2) NOT NULL,
  status ENUM('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_orders_user_status (user_id, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  provider VARCHAR(50) NOT NULL,
  provider_payment_id VARCHAR(120) NULL,
  provider_order_id VARCHAR(120) NULL,
  amount DECIMAL(10,2) NOT NULL,
  creator_earning DECIMAL(10,2) NOT NULL DEFAULT 0,
  platform_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  status ENUM('initiated','captured','failed','refunded') NOT NULL DEFAULT 'initiated',
  webhook_payload JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  INDEX idx_payments_status_created (status, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subscriptions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  slug VARCHAR(140) NOT NULL UNIQUE,
  billing_cycle ENUM('monthly','yearly') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  features JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_subscriptions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  subscription_id BIGINT UNSIGNED NOT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  status ENUM('active','expired','cancelled') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_subscriptions_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_user_subscriptions_subscription FOREIGN KEY (subscription_id) REFERENCES subscriptions(id),
  INDEX idx_user_subscriptions_user_status (user_id, status, end_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS enrollments (
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS lesson_progress (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  enrollment_id BIGINT UNSIGNED NOT NULL,
  lesson_id BIGINT UNSIGNED NOT NULL,
  status ENUM('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
  completed_at DATETIME NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_enrollment_lesson (enrollment_id, lesson_id),
  CONSTRAINT fk_lesson_progress_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE,
  CONSTRAINT fk_lesson_progress_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  review TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_review_user_course (user_id, course_id),
  CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  INDEX idx_reviews_course_rating (course_id, rating)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS wishlists (
  user_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, course_id),
  CONSTRAINT fk_wishlists_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_wishlists_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS coupons (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  creator_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(30) NOT NULL UNIQUE,
  discount_type ENUM('fixed','percent') NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL,
  max_uses INT NULL,
  used_count INT NOT NULL DEFAULT 0,
  starts_at DATETIME NULL,
  expires_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_coupons_creator FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_coupons_code_active (code, is_active)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS coupon_usage (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  coupon_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  order_id BIGINT UNSIGNED NOT NULL,
  discount_amount DECIMAL(10,2) NOT NULL,
  used_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_coupon_usage_coupon FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE,
  CONSTRAINT fk_coupon_usage_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_coupon_usage_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  UNIQUE KEY uq_coupon_usage_order (coupon_id, order_id),
  INDEX idx_coupon_usage_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payouts (
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
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS reports (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reporter_user_id BIGINT UNSIGNED NOT NULL,
  target_type ENUM('course','lesson','review','user') NOT NULL,
  target_id BIGINT UNSIGNED NOT NULL,
  reason VARCHAR(255) NOT NULL,
  status ENUM('open','in_review','resolved','dismissed') NOT NULL DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reviewed_by BIGINT UNSIGNED NULL,
  reviewed_at DATETIME NULL,
  CONSTRAINT fk_reports_reporter FOREIGN KEY (reporter_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reports_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_reports_status_created (status, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
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
) ENGINE=InnoDB;
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
