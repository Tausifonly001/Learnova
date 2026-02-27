<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= isset($title) ? htmlspecialchars($title) : 'Learnova'; ?></title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
</head>
<?php $baseUrl = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/'); ?>
<body class="bg-slate-50 text-slate-900">
  <header class="sticky top-0 z-40 bg-white border-b border-slate-200">
    <nav class="mx-auto max-w-6xl p-4 flex items-center justify-between">
      <a href="<?= ($baseUrl ?: '') . '/'; ?>" data-nav class="font-bold text-xl">🎓 Learnova</a>
      <div class="flex items-center gap-2">
        <button data-open-modal="loginModal" class="px-4 py-2 rounded bg-slate-900 text-white text-sm">Login</button>
        <button data-open-modal="registerModal" class="px-4 py-2 rounded bg-indigo-600 text-white text-sm">Join</button>
      </div>
    </nav>
  </header>

  <main id="app-content" class="mx-auto max-w-6xl p-4">
    <?= $content; ?>
  </main>

  <div id="global-loader" class="hidden fixed inset-0 bg-black/30 items-center justify-center z-50">
    <div class="animate-spin h-10 w-10 border-4 border-white border-t-transparent rounded-full"></div>
  </div>
  <div id="toast" class="hidden fixed bottom-4 left-1/2 -translate-x-1/2 px-4 py-2 rounded bg-slate-900 text-white text-sm z-50"></div>

  <?php include base_path('app/Views/partials/auth_modals.php'); ?>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
  <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
  <script>
    window.LEARNOVA = {
      csrf: '<?= htmlspecialchars($csrf ?? ($_SESSION['csrf'] ?? '')); ?>',
      baseUrl: '<?= $baseUrl; ?>'
    };
  </script>
  <script src="<?= ($baseUrl ?: '') . '/assets/js/app.js'; ?>"></script>
</body>
</html>
