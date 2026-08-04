(function () {
  'use strict';

  const cfg = window.AGENDASERVICE_CONFIG || { appUrl: 'http://localhost:3000' };

  function appLink(path, params) {
    const base = (cfg.appUrl || '').replace(/\/$/, '');
    const url = new URL(path || '/', base || window.location.origin);
    if (params) {
      Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));
    }
    return url.toString();
  }

  function normalizePhoneDigits(value) {
    return String(value || '').replace(/\D/g, '');
  }

  function formatWhatsAppMask(value) {
    const digits = normalizePhoneDigits(value).slice(0, 11);
    if (digits.length <= 2) return digits;
    if (digits.length <= 7) return `(${digits.slice(0, 2)}) ${digits.slice(2)}`;
    return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7)}`;
  }

  document.querySelectorAll('[data-app-link]').forEach((el) => {
    const path = el.getAttribute('data-app-path') || '/';
    const paramsRaw = el.getAttribute('data-app-params');
    let params = null;
    if (paramsRaw) {
      try {
        params = JSON.parse(paramsRaw);
      } catch {
        params = null;
      }
    }
    el.setAttribute('href', appLink(path, params));
    if (el.tagName === 'A') {
      el.setAttribute('target', '_blank');
      el.setAttribute('rel', 'noopener noreferrer');
    }
  });

  const menuBtn = document.getElementById('menu-btn');
  const closeBtn = document.getElementById('close-menu');
  const mobileNav = document.getElementById('mobile-nav');
  const mobileBackdrop = document.getElementById('mobile-backdrop');

  function closeMenu() {
    mobileNav?.classList.remove('nav-open');
    document.body.classList.remove('overflow-hidden');
  }

  menuBtn?.addEventListener('click', () => {
    mobileNav?.classList.add('nav-open');
    document.body.classList.add('overflow-hidden');
  });
  closeBtn?.addEventListener('click', closeMenu);
  mobileBackdrop?.addEventListener('click', closeMenu);
  mobileNav?.querySelectorAll('a').forEach((a) => a.addEventListener('click', closeMenu));

  const header = document.getElementById('site-header');
  window.addEventListener('scroll', () => {
    if (!header) return;
    header.classList.toggle('shadow-lg', window.scrollY > 12);
    header.classList.toggle('shadow-black/40', window.scrollY > 12);
  });

  const track = document.getElementById('testimonial-track');
  const prevBtn = document.getElementById('testimonial-prev');
  const nextBtn = document.getElementById('testimonial-next');
  const dotsWrap = document.getElementById('testimonial-dots');
  let carouselIndex = 0;

  function slidesPerView() {
    if (window.innerWidth >= 1024) return 3;
    if (window.innerWidth >= 768) return 2;
    return 1;
  }

  function maxIndex() {
    const slides = track?.children.length || 0;
    return Math.max(0, slides - slidesPerView());
  }

  function buildDots() {
    if (!dotsWrap) return;
    dotsWrap.innerHTML = '';
    for (let i = 0; i <= maxIndex(); i++) {
      const dot = document.createElement('button');
      dot.type = 'button';
      dot.className = 'w-2 h-2 rounded-full bg-white/20 transition-colors';
      dot.setAttribute('aria-label', `Depoimento ${i + 1}`);
      dot.addEventListener('click', () => {
        carouselIndex = i;
        updateCarousel();
      });
      dotsWrap.appendChild(dot);
    }
  }

  function updateCarousel() {
    if (!track) return;
    carouselIndex = Math.min(carouselIndex, maxIndex());
    const pct = (100 / slidesPerView()) * carouselIndex;
    track.style.transform = `translateX(-${pct}%)`;
    dotsWrap?.querySelectorAll('button').forEach((dot, i) => {
      dot.classList.toggle('bg-emerald-500', i === carouselIndex);
      dot.classList.toggle('bg-white/20', i !== carouselIndex);
    });
  }

  if (track && dotsWrap) {
    buildDots();
    prevBtn?.addEventListener('click', () => {
      carouselIndex = carouselIndex <= 0 ? maxIndex() : carouselIndex - 1;
      updateCarousel();
    });
    nextBtn?.addEventListener('click', () => {
      carouselIndex = carouselIndex >= maxIndex() ? 0 : carouselIndex + 1;
      updateCarousel();
    });
    window.addEventListener('resize', () => {
      carouselIndex = 0;
      buildDots();
      updateCarousel();
    });
    updateCarousel();
    setInterval(() => {
      carouselIndex = carouselIndex >= maxIndex() ? 0 : carouselIndex + 1;
      updateCarousel();
    }, 7000);
  }

  document.querySelectorAll('.faq-trigger').forEach((btn) => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const wasOpen = item?.classList.contains('open');
      document.querySelectorAll('.faq-item.open').forEach((el) => el.classList.remove('open'));
      if (!wasOpen) item?.classList.add('open');
    });
  });

  const form = document.getElementById('lead-form');
  const whatsappInput = document.getElementById('lead-whatsapp');
  const toast = document.getElementById('toast');

  whatsappInput?.addEventListener('input', (e) => {
    e.target.value = formatWhatsAppMask(e.target.value);
  });

  function showToast(message, isError) {
    if (!toast) return;
    toast.textContent = message;
    toast.classList.toggle('bg-red-600', !!isError);
    toast.classList.toggle('bg-emerald-600', !isError);
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 4500);
  }

  form?.addEventListener('submit', (e) => {
    e.preventDefault();
    let valid = true;

    form.querySelectorAll('[required]').forEach((field) => {
      field.classList.remove('error');
      if (!String(field.value || '').trim()) {
        field.classList.add('error');
        valid = false;
      }
    });

    const profileChecked = form.querySelectorAll('input[name="perfil"]:checked');
    if (profileChecked.length === 0) {
      showToast('Selecione se deseja contratar ou prestar serviços.', true);
      return;
    }

    if (!valid) {
      showToast('Preencha todos os campos obrigatórios.', true);
      return;
    }

    const nome = form.nome.value.trim();
    const email = form.email.value.trim();
    const whatsapp = normalizePhoneDigits(form.whatsapp.value);
    const perfis = Array.from(profileChecked).map((el) => el.value).join(' e ');

    const body =
      `Olá! Quero receber novidades do AgendaService.\n\n` +
      `Nome: ${nome}\nE-mail: ${email}\nWhatsApp: ${whatsapp}\nPerfil: ${perfis}`;

    const waNumber = normalizePhoneDigits(cfg.whatsappLeads || cfg.whatsappSuporte);

    if (waNumber.length >= 10) {
      const msg = encodeURIComponent(body);
      window.open(`https://wa.me/55${waNumber.replace(/^55/, '')}?text=${msg}`, '_blank');
      showToast('Redirecionando para WhatsApp… Obrigado pelo interesse!');
    } else if (cfg.emailContato) {
      window.location.href = `mailto:${cfg.emailContato}?subject=${encodeURIComponent('Lead AgendaService')}&body=${encodeURIComponent(body)}`;
      showToast('Abrindo seu e-mail… Obrigado pelo interesse!');
    } else {
      showToast('Cadastro recebido! Entraremos em contato em breve.');
    }

    form.reset();
  });

  const yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = String(new Date().getFullYear());
})();
