# Learnova — Phase 1 Foundation (Architecture + Database)

## Updated Folder Tree

```txt
Learnova/
├─ app/
│  ├─ Config/
│  │  └─ Config.php
│  ├─ Controllers/
│  ├─ Core/
│  │  ├─ Database.php
│  │  ├─ Response.php
│  │  ├─ Router.php
│  │  ├─ Security.php
│  │  ├─ Session.php
│  │  ├─ Validator.php
│  │  └─ View.php
│  ├─ Helpers/
│  │  └─ common.php
│  ├─ Models/
│  └─ Views/
├─ bootstrap/
│  ├─ app.php
│  └─ env.php
├─ database/
│  ├─ database.sql
│  ├─ migrations/
│  │  └─ 001_init.sql
│  └─ seeds/
│     └─ 001_seed.sql
├─ public/
│  ├─ assets/
│  ├─ db-test.php
│  └─ index.php
├─ routes/
│  ├─ api.php
│  └─ web.php
├─ storage/
└─ .env.example
```

## What Phase 1 Includes

- MVC-friendly folder structure for Core PHP app organization.
- `.env.example` environment template.
- Config loader (`App\Config\Config`) wired via `bootstrap/env.php`.
- PDO singleton (`App\Core\Database`) for centralized DB access.
- Fully normalized MySQL schema in `database/database.sql` plus split migration/seed files.
- Tables included:
  - users, profiles, creator_verification
  - categories, tags, course_tags
  - courses, course_sections, lessons, pricing
  - orders, order_items, payments
  - subscriptions, user_subscriptions
  - enrollments, lesson_progress
  - reviews, wishlists
  - coupons, coupon_usage
  - payouts
  - reports (with compatibility view: reports_flags)
  - audit_logs
- Seed data:
  - Admin user
  - Demo creator and student
  - Sample categories and tags
  - One approved demo course + section + lesson + pricing
- DB connection test page at `/public/db-test.php`.

## XAMPP Setup (htdocs/Learnova)

1. Put project under `xampp/htdocs/Learnova`.
2. Copy `.env.example` to `.env` and set DB credentials.
3. Start Apache + MySQL in XAMPP.
4. Import SQL:
   - Preferred: run `database/database.sql` once.
   - Alternative: run `database/migrations/001_init.sql`, then `database/seeds/001_seed.sql`.
5. Open:
   - App entry: `http://localhost/Learnova/public`
   - DB health check: `http://localhost/Learnova/public/db-test.php`

## Test Checklist

- [ ] `.env` loads expected values.
- [ ] `Database::connection()` returns active PDO instance.
- [ ] All tables are created with foreign keys and indexes.
- [ ] Seed users/categories/tags/demo course inserted.
- [ ] `db-test.php` reports connection `ok`.

## Regression Checklist (Phase 1 baseline)

- [ ] Running `database/database.sql` on a clean DB is idempotent.
- [ ] Seed script can run repeatedly without duplicate unique records.
- [ ] Existing bootstrap autoload still works.
- [ ] No PHP warnings/notices on `/public/db-test.php`.
