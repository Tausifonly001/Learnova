const loader = document.getElementById('global-loader');
const toast = document.getElementById('toast');

const ui = {
  loading(show) { loader.classList.toggle('hidden', !show); loader.classList.toggle('flex', show); },
  notify(message, isError = false) {
    toast.textContent = message;
    toast.className = `fixed bottom-4 left-1/2 -translate-x-1/2 px-4 py-2 rounded text-white text-sm z-50 ${isError ? 'bg-red-600' : 'bg-slate-900'}`;
    toast.classList.remove('hidden');
    setTimeout(() => toast.classList.add('hidden'), 2500);
  }
};

async function api(url, options = {}) {
  ui.loading(true);
  try {
    const response = await fetch(url, options);
    return await response.json();
  } finally {
    ui.loading(false);
  }
}

function openModal(id) {
  const modal = document.getElementById(id);
  if (!modal) return;
  modal.classList.remove('hidden');
  modal.classList.add('flex');
}

document.addEventListener('click', (event) => {
  const btn = event.target.closest('[data-open-modal]');
  if (btn) openModal(btn.dataset.openModal);

  if (event.target.id?.endsWith('Modal')) {
    event.target.classList.add('hidden');
    event.target.classList.remove('flex');
  }
});

async function bindAuthForms() {
  const registerForm = document.getElementById('registerForm');
  if (registerForm) {
    registerForm.addEventListener('submit', async (event) => {
      event.preventDefault();
      const form = new FormData(registerForm);
      const data = await api(`${window.LEARNOVA.baseUrl}/api/auth/register`, { method: 'POST', body: form });
      ui.notify(data.message, !data.success);
    });
  }

  const loginForm = document.getElementById('loginForm');
  if (loginForm) {
    loginForm.addEventListener('submit', async (event) => {
      event.preventDefault();
      const form = new FormData(loginForm);
      const data = await api(`${window.LEARNOVA.baseUrl}/api/auth/login`, { method: 'POST', body: form });
      ui.notify(data.message, !data.success);
    });
  }
}

async function loadCourses() {
  const list = document.getElementById('course-list');
  if (!list) return;

  const search = document.getElementById('search')?.value || '';
  const sort = document.getElementById('sort')?.value || 'latest';
  const data = await api(`${window.LEARNOVA.baseUrl}/api/courses?search=${encodeURIComponent(search)}&sort=${sort}`);

  if (!data.success) {
    list.innerHTML = '<p class="text-red-600">Unable to load courses.</p>';
    return;
  }

  list.innerHTML = data.data.courses.map((course) => `
    <article class="bg-white rounded-xl border border-slate-200 p-4" data-aos="fade-up">
      <h3 class="font-semibold">${course.title}</h3>
      <p class="text-sm text-slate-600">${course.category_name} • ⭐ ${Number(course.avg_rating).toFixed(1)}</p>
      <p class="text-sm mt-2">${course.currency ?? 'USD'} ${course.amount ?? '0.00'}</p>
    </article>
  `).join('') || '<p>No courses found.</p>';

  AOS.refresh();
}

['search', 'sort'].forEach((id) => {
  document.addEventListener('input', (e) => { if (e.target.id === id) loadCourses(); });
  document.addEventListener('change', (e) => { if (e.target.id === id) loadCourses(); });
});

function setupSpaNavigation() {
  document.addEventListener('click', async (event) => {
    const link = event.target.closest('a[data-nav]');
    if (!link) return;
    event.preventDefault();

    const url = link.getAttribute('href');
    history.pushState({}, '', url);
    gsap.fromTo('#app-content', { opacity: 0.2, y: 8 }, { opacity: 1, y: 0, duration: 0.3 });
  });

  window.addEventListener('popstate', () => {
    gsap.fromTo('#app-content', { opacity: 0.2 }, { opacity: 1, duration: 0.2 });
  });
}

AOS.init({ once: true });
setupSpaNavigation();
bindAuthForms();
loadCourses();
