<div id="registerModal" class="hidden fixed inset-0 bg-black/40 z-50 items-center justify-center p-4">
  <form id="registerForm" class="bg-white rounded-xl p-4 w-full max-w-md space-y-3">
    <h3 class="font-semibold">Create account</h3>
    <input name="name" class="w-full border rounded p-2" placeholder="Full name" required>
    <input name="email" type="email" class="w-full border rounded p-2" placeholder="Email" required>
    <input name="password" type="password" class="w-full border rounded p-2" placeholder="Password" required>
    <select name="role" class="w-full border rounded p-2"><option value="student">Student</option><option value="creator">Creator</option></select>
    <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrf ?? ''); ?>">
    <button class="w-full bg-indigo-600 text-white rounded p-2">Register</button>
  </form>
</div>

<div id="loginModal" class="hidden fixed inset-0 bg-black/40 z-50 items-center justify-center p-4">
  <form id="loginForm" class="bg-white rounded-xl p-4 w-full max-w-md space-y-3">
    <h3 class="font-semibold">Login</h3>
    <input name="email" type="email" class="w-full border rounded p-2" placeholder="Email" required>
    <input name="password" type="password" class="w-full border rounded p-2" placeholder="Password" required>
    <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($csrf ?? ''); ?>">
    <button class="w-full bg-slate-900 text-white rounded p-2">Login</button>
  </form>
</div>
