# Learnova — Phase 1 (MVC Architecture + Database Foundation)

This delivery provides the production-ready **foundation** for Learnova using Core PHP MVC + MySQL.

## What is included in Phase 1
- Finalized MVC folder structure for `htdocs/Learnova`.
- Environment loader with `.env.example`.
- Centralized config files (`app/Config/app.php`, `app/Config/database.php`).
- PDO singleton database connection.
- Normalized SQL schema with foreign keys and indexes for:
  - users/profiles/creator verification
  - categories/tags/course mapping
  - courses/sections/lessons/pricing
  - enrollments/progress
  - orders/order_items/payments (with `platform_fee` + `creator_earning`)
  - subscriptions/user_subscriptions
  - reviews/wishlist
  - coupons/coupon_usage
  - payouts
  - reports
  - audit logs
- Seed data:
  - Admin account
  - Demo creator account
  - Sample categories
  - Sample tags
  - 1 approved demo course + pricing + mapped tags
- DB connection test page at `/public` root.

## Folder Structure

```txt
Learnova/
├─ app/
│  ├─ Config/
│  │  ├─ app.php
│  │  └─ database.php
│  ├─ Controllers/
│  │  ├─ AuthController.php
│  │  ├─ CourseController.php
│  │  └─ PageController.php
│  ├─ Core/
│  │  ├─ Database.php
│  │  ├─ Response.php
│  │  ├─ Router.php
│  │  ├─ Security.php
│  │  ├─ Session.php
│  │  ├─ Validator.php
│  │  └─ View.php
│  ├─ Helpers/common.php
│  ├─ Models/
│  │  ├─ Course.php
│  │  └─ User.php
│  └─ Views/
│     ├─ layouts/app.php
│     ├─ pages/home.php
│     └─ partials/auth_modals.php
├─ bootstrap/
│  ├─ app.php
│  └─ env.php
├─ database/
│  ├─ migrations/001_init.sql
│  ├─ seeds/001_seed.sql
│  └─ database.sql
├─ public/
│  ├─ .htaccess
│  ├─ assets/js/app.js
│  └─ index.php
├─ routes/
│  ├─ api.php
│  └─ web.php
├─ storage/uploads/.gitkeep
├─ .env.example
└─ README.md
```

## XAMPP Setup (htdocs/Learnova)
1. Copy this project into: `xampp/htdocs/Learnova`.
2. Create `.env` from `.env.example`.
3. Update DB credentials in `.env`.
4. Start Apache + MySQL in XAMPP.
5. Import database in one of two ways:
   - Single file: `database/database.sql`
   - Two-step: `database/migrations/001_init.sql` then `database/seeds/001_seed.sql`
6. Open `http://localhost/Learnova/public`.

If successful, the page shows **Database connection successful** and server timestamp.

## Seeded Accounts
- Admin: `admin@learnova.test`
- Demo Creator: `creator@learnova.test`
- Both use the seeded bcrypt hash from SQL (replace before production).

## Test Checklist (Phase 1)
- [ ] Schema imports without FK/index errors.
- [ ] `users`, `courses`, `orders`, `payments`, `payouts`, `audit_logs` tables are created.
- [ ] `coupon_usage` exists and references coupons/users/orders.
- [ ] Seed inserts admin, demo creator, categories, tags, and demo course.
- [ ] `/public` root shows DB success status.

## Regression Checklist
- [ ] Existing routes still resolve through `public/index.php`.
- [ ] API response contract remains `{ success, message, data, errors }`.
- [ ] PDO prepared statements remain enabled (`ATTR_EMULATE_PREPARES=false`).
