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

  function renderTrialBanner() {
    const trial = cfg.trialAssinatura || {};
    const aceites = Number(trial.trial_aceites != null ? trial.trial_aceites : 2);
    const dias = Number(trial.trial_dias != null ? trial.trial_dias : 7);
    const taxaDefault =
      cfg.taxaPorCodigo && cfg.taxaPorCodigo.trial != null ? cfg.taxaPorCodigo.trial : 20;
    const taxa = Number(trial.taxa_job != null ? trial.taxa_job : taxaDefault);

    document.querySelectorAll('[data-trial-aceites]').forEach((el) => {
      el.textContent = String(aceites);
    });
    document.querySelectorAll('[data-trial-dias]').forEach((el) => {
      el.textContent = String(dias);
    });
    const taxaEl = document.getElementById('planos-trial-taxa');
    if (taxaEl) taxaEl.textContent = `Taxa atual por job: ${taxa}%`;

    const trialRoot = document.getElementById('planos-trial');
    if (trialRoot) bindPlanLinks(trialRoot);
  }

  /* —— Planos de assinatura (prestadores) —— */
  const TAXA_POR_CODIGO = Object.assign(
    { trial: 20, essencial: 16, profissional: 12, premium: 5 },
    cfg.taxaPorCodigo || {}
  );

  const PLAN_META = {
    essencial: {
      tagline: 'Menos que um Sanduíche',
      taxa_job: TAXA_POR_CODIGO.essencial,
      features: [
        'Aceites ilimitados de serviços',
        `Taxa de ${TAXA_POR_CODIGO.essencial}% por job`,
        'Agenda, chat e painel de ganhos',
        'Checkout Asaas em breve',
      ],
    },
    profissional: {
      tagline: 'Custa menos que uma mini pizza por mês',
      taxa_job: TAXA_POR_CODIGO.profissional,
      features: [
        'Aceites ilimitados de serviços',
        `Taxa reduzida de ${TAXA_POR_CODIGO.profissional}% por job`,
        'Melhor margem por serviço concluído',
        'Agenda, chat e painel de ganhos',
      ],
    },
    premium: {
      tagline: 'Você vai pagar menos do que uma pizza!',
      taxa_job: TAXA_POR_CODIGO.premium,
      features: [
        'Aceites ilimitados de serviços',
        `Taxa de ${TAXA_POR_CODIGO.premium}% por job`,
        'Máxima margem para o prestador',
        'Agenda, chat e painel de ganhos',
      ],
    },
  };

  function formatBRL(value) {
    return Number(value || 0).toLocaleString('pt-BR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    });
  }

  function planMetaKey(codigo) {
    const code = String(codigo || '');
    return Object.keys(PLAN_META).find((k) => code.includes(k)) || null;
  }

  function normalizePlan(raw) {
    const codigo = String(raw.codigo || raw.nome || '')
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/\s+/g, '_');
    const key = planMetaKey(codigo);
    const meta = (key && PLAN_META[key]) || {};
    const taxaFromCodigo = key && TAXA_POR_CODIGO[key] != null ? Number(TAXA_POR_CODIGO[key]) : null;
    const taxa =
      raw.taxa_job != null
        ? Number(raw.taxa_job)
        : meta.taxa_job != null
          ? Number(meta.taxa_job)
          : taxaFromCodigo;
    return {
      codigo,
      nome: raw.nome || 'Plano',
      tagline: raw.tagline || meta.tagline || '',
      descricao: raw.descricao || '',
      preco_anual: raw.preco_anual == null ? null : Number(raw.preco_anual),
      taxa_job: taxa,
      limite_aceites:
        raw.limite_aceites == null || raw.limite_aceites === ''
          ? null
          : Number(raw.limite_aceites),
      ordem: Number(raw.ordem || 0),
      status: raw.status,
      features: meta.features || [],
    };
  }

  function planFeatures(plan) {
    if (plan.features && plan.features.length) return plan.features;
    const taxa =
      plan.taxa_job == null ? 'taxa conforme o plano' : `Taxa de ${plan.taxa_job}% por job`;
    return [
      plan.limite_aceites == null || plan.limite_aceites <= 0
        ? 'Aceites ilimitados de serviços'
        : `Até ${plan.limite_aceites} aceites`,
      taxa,
      'Agenda, chat e painel de ganhos',
    ];
  }

  function isFeaturedPlan(plan) {
    return plan.codigo.includes('profissional');
  }

  function planPriceHtml(plan) {
    const anual = plan.preco_anual;
    if (anual == null || Number.isNaN(anual) || anual < 0) {
      return `
        <div class="plan-price">
          <span class="plan-price-main">Sob consulta</span>
        </div>`;
    }
    if (anual === 0) {
      return `
        <div class="plan-price">
          <span class="plan-price-main">Grátis</span>
          <span class="plan-price-sub">sem mensalidade</span>
        </div>`;
    }
    const mensal = anual / 12;
    const taxaLabel =
      plan.taxa_job == null
        ? ''
        : `<span class="plan-price-taxa">Taxa ${plan.taxa_job}% por job</span>`;
    return `
      <div class="plan-price">
        <span class="plan-price-main">R$ ${formatBRL(anual)}</span>
        <span class="plan-price-period">/ano</span>
        <span class="plan-price-sub">≈ R$ ${formatBRL(mensal)}/mês</span>
        ${taxaLabel}
      </div>`;
  }

  function bindPlanLinks(root) {
    root.querySelectorAll('[data-app-link]').forEach((el) => {
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
  }

  function renderPlans(plans) {
    const grid = document.getElementById('planos-grid');
    if (!grid) return;

    const sorted = [...plans]
      .map(normalizePlan)
      .filter((p) => p.status == null || Number(p.status) === 1)
      .sort((a, b) => a.ordem - b.ordem);

    if (!sorted.length) {
      grid.innerHTML =
        '<p class="text-center text-sm text-gray-500 col-span-full">Planos em breve. Cadastre-se no app para ser avisado.</p>';
      return;
    }

    grid.innerHTML = sorted
      .map((plan) => {
        const featured = isFeaturedPlan(plan);
        const features = planFeatures(plan);
        const params = JSON.stringify({ auth: 'register', plan: plan.codigo });
        const tagline = plan.tagline
          ? `<p class="plan-tagline mt-3 text-sm font-semibold ${
              featured ? 'text-gold-light' : 'text-primary'
            }">${plan.tagline}</p>`
          : '';
        return `
          <article class="plan-card glass gradient-border rounded-3xl p-6 sm:p-8 flex flex-col ${
            featured ? 'plan-card--featured' : ''
          }" data-plan-codigo="${plan.codigo}">
            ${featured ? '<span class="plan-badge">Mais popular</span>' : ''}
            <p class="text-xs font-bold uppercase tracking-widest ${
              featured ? 'text-gold-light' : 'text-primary'
            }">Assinatura anual</p>
            <h3 class="text-xl font-bold text-white mt-1">${plan.nome}</h3>
            ${tagline}
            <p class="mt-2 text-sm text-gray-400 leading-relaxed">${plan.descricao || ''}</p>
            ${planPriceHtml(plan)}
            <ul class="mt-6 space-y-2.5 text-sm text-gray-300 flex-1">
              ${features
                .map(
                  (f) =>
                    `<li class="flex gap-2"><span class="${
                      featured ? 'text-gold-light' : 'text-primary'
                    } shrink-0">✓</span><span>${f}</span></li>`
                )
                .join('')}
            </ul>
            <a data-app-link data-app-path="/" data-app-params='${params}'
              class="mt-8 inline-flex items-center justify-center w-full font-semibold px-5 py-3 rounded-xl text-sm ${
                featured ? 'btn-primary text-white' : 'btn-outline-gold text-gold-light'
              }">Assinar anualmente</a>
          </article>`;
      })
      .join('');

    bindPlanLinks(grid);
  }

  async function fetchPlanosFromSupabase(url, key) {
    const baseSelect =
      'id,nome,codigo,descricao,preco_anual,limite_aceites,status,ordem,taxa_job';
    const headers = {
      apikey: key,
      Authorization: `Bearer ${key}`,
      Accept: 'application/json',
    };
    const query = `select=${baseSelect}&status=eq.1&order=ordem.asc`;
    let res = await fetch(`${url}/rest/v1/planos_assinatura?${query}`, { headers });
    if (res.status === 400) {
      const fallbackSelect =
        'id,nome,codigo,descricao,preco_anual,limite_aceites,status,ordem';
      res = await fetch(`${url}/rest/v1/planos_assinatura?select=${fallbackSelect}&status=eq.1&order=ordem.asc`, {
        headers,
      });
    }
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const rows = await res.json();
    return Array.isArray(rows) ? rows : [];
  }

  async function loadPlanosAssinatura() {
    const fallback = Array.isArray(cfg.planosAssinaturaFallback)
      ? cfg.planosAssinaturaFallback
      : [];
    const url = (cfg.supabaseUrl || '').replace(/\/$/, '');
    const key = cfg.supabaseAnonKey;

    if (!url || !key) {
      renderPlans(fallback);
      return;
    }

    try {
      let rows = await fetchPlanosFromSupabase(url, key);
      if (!rows.length) {
        const headers = {
          apikey: key,
          Authorization: `Bearer ${key}`,
          Accept: 'application/json',
        };
        const res = await fetch(
          `${url}/rest/v1/planos_assinatura?select=id,nome,codigo,descricao,preco_anual,limite_aceites,status,ordem&order=ordem.asc`,
          { headers }
        );
        if (res.ok) {
          const all = await res.json();
          if (Array.isArray(all)) rows = all.filter((r) => r.status == null || Number(r.status) === 1);
        }
      }
      renderPlans(rows.length ? rows : fallback);
    } catch {
      renderPlans(fallback);
    }
  }

  function renderPorDentroGaleria() {
    const grid = document.getElementById('por-dentro-grid');
    const items = Array.isArray(cfg.porDentroGaleria) ? cfg.porDentroGaleria : [];
    if (!grid || !items.length) return;

    grid.innerHTML = items
      .map((item) => {
        const isCliente = item.perfil === 'cliente';
        const labelClass = isCliente ? 'text-primary' : 'text-gold-light';
        const label = isCliente ? 'Cliente' : 'Prestador';
        const assetV = cfg.assetsVersion ? `?v=${encodeURIComponent(String(cfg.assetsVersion))}` : '';
        const src = `assets/${encodeURI(item.arquivo || '')}${assetV}`;
        const alt = `AgendaService — ${label.toLowerCase()}: ${item.titulo || ''}`;
        return `
          <article class="screenshot-card flex flex-col items-center text-center max-w-[350px] w-full mx-auto">
            <div class="mb-4">
              <span class="text-[10px] font-bold uppercase tracking-widest ${labelClass}">${label}</span>
              <h3 class="text-lg font-bold text-white mt-1">${item.titulo || ''}</h3>
            </div>
            <div class="phone-frame w-[300px] sm:w-[330px] lg:w-[350px] rounded-[2.85rem] p-3.5">
              <div class="phone-notch w-28 h-5 mx-auto rounded-b-xl mb-2"></div>
              <div class="mock-screen rounded-[2rem] overflow-hidden aspect-[9/18]">
                <img
                  src="${src}"
                  alt="${alt}"
                  class="w-full h-full object-cover object-top"
                  loading="lazy"
                  width="390"
                  height="844"
                />
              </div>
            </div>
            <p class="mt-4 text-sm text-gray-400">${item.descricao || ''}</p>
          </article>`;
      })
      .join('');

    const remainder = items.length % 3;
    if (remainder === 2) {
      grid.innerHTML += '<div class="hidden xl:block" aria-hidden="true"></div>';
    } else if (remainder === 1) {
      grid.innerHTML +=
        '<div class="hidden xl:block" aria-hidden="true"></div><div class="hidden xl:block" aria-hidden="true"></div>';
    }
  }

  loadPlanosAssinatura();
  renderTrialBanner();
  renderPorDentroGaleria();
})();
