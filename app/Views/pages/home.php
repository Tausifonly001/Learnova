<section class="max-w-xl mx-auto mt-10 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
  <h1 class="text-2xl font-semibold text-slate-900">Learnova — Phase 1 Foundation</h1>
  <p class="mt-2 text-sm text-slate-600">Core MVC architecture + normalized database setup check.</p>

  <div class="mt-6 rounded-xl border p-4 <?= !empty($dbStatus['connected']) ? 'border-emerald-200 bg-emerald-50' : 'border-rose-200 bg-rose-50'; ?>">
    <p class="text-sm font-medium <?= !empty($dbStatus['connected']) ? 'text-emerald-700' : 'text-rose-700'; ?>">
      <?= htmlspecialchars($dbStatus['message'] ?? 'Unknown status', ENT_QUOTES, 'UTF-8'); ?>
    </p>
    <ul class="mt-2 space-y-1 text-xs text-slate-700">
      <li><strong>Database:</strong> <?= htmlspecialchars((string) ($dbStatus['database'] ?? ''), ENT_QUOTES, 'UTF-8'); ?></li>
      <?php if (!empty($dbStatus['server_time'])): ?>
        <li><strong>Server Time:</strong> <?= htmlspecialchars((string) $dbStatus['server_time'], ENT_QUOTES, 'UTF-8'); ?></li>
      <?php endif; ?>
    </ul>
  </div>

  <p class="mt-5 text-xs text-slate-500">Next phases will layer authentication, SPA routing, and premium UI animations on top of this foundation.</p>
</section>
