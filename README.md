# 🎓 Learnova (Core PHP MVC)

Production-oriented starter for a secure, mobile-first, SPA-like course marketplace.

## Implemented in this delivery
- **Phase 1** architecture + normalized schema + seeds.
- **Phase 2** foundational auth/security (student/creator registration, admin-seeded login restriction, CSRF, input validation, session regeneration, role guards helpers, login rate limiting via audit log scan).
- **Phase 3** SPA-like shell baseline (single entry router, AJAX APIs, History API hooks, loader, toasts, GSAP/AOS integration, mobile-first UI).

---

## Folder Structure

```txt
Learnova/
├─ app/
│  ├─ Config/
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
│  └─ seeds/001_seed.sql
├─ public/
│  ├─ assets/js/app.js
│  └─ index.php
├─ routes/
│  ├─ api.php
│  └─ web.php
├─ storage/
├─ .env.example
└─ README.md
```

---

## XAMPP Setup (htdocs/Learnova)
1. Copy project to `xampp/htdocs/Learnova`.
2. Create `.env` from `.env.example` and adjust DB values.
3. Start **Apache** and **MySQL** in XAMPP.
4. Run SQL files in order:
   1) `database/migrations/001_init.sql`
   2) `database/seeds/001_seed.sql`
5. Open: `http://localhost/Learnova/public`

### Seeded admin
- Email: `admin@learnova.test`
- Password hash is seeded in SQL; replace with your own generated hash before production.

---

## API JSON Contract
All API endpoints return:

```json
{
  "success": true,
  "message": "",
  "data": {},
  "errors": {}
}
```

---

## Regression Testing Checklist

### Phase 1
- [ ] All schema tables created with foreign keys and indexes.
- [ ] Seed admin and categories inserted.
- [ ] DB connection via PDO singleton works.

### Phase 2
- [ ] Student registration succeeds.
- [ ] Creator registration succeeds.
- [ ] Admin account cannot login via non-admin portal payload.
- [ ] CSRF invalid token returns 419 JSON response.
- [ ] Repeated failed logins trigger 429 rate-limit response.
- [ ] Session ID regenerates on successful login.

### Phase 3
- [ ] Home renders without full refresh.
- [ ] Course list loads via AJAX.
- [ ] Loader/toast work for API feedback.
- [ ] AOS animation initialized.
- [ ] GSAP transition triggers on SPA navigation links.

---

## Backward compatibility note
Subsequent phases should extend current routes/controllers/models **without changing** response contract or authentication/session primitives.
