# AgendaService — Landing Page

Landing page pública do **AgendaService**, produto da **JVTechy**. Projeto separado do Web App (`../agendaservice`).

## Estrutura

```
agendaservice-landing/
├── index.html          # Página principal
├── termos.html         # Termos de uso (rascunho)
├── privacidade.html    # Política de privacidade (rascunho)
├── assets/
│   ├── logo.svg        # Logo AgendaService (wordmark)
│   └── logo-icon.svg   # Ícone / favicon
├── css/styles.css
├── js/
│   ├── config.js       # URL do app + contatos
│   └── main.js         # Nav, carrossel, formulário, CTAs
└── vercel.json
```

## Desenvolvimento local

```bash
cd agendaservice-landing
npm run dev
```

Abre em **http://localhost:4321**

## Configuração antes do deploy

Edite `js/config.js`:

```js
window.AGENDASERVICE_CONFIG = {
  appUrl: 'https://app.agendaservice.com.br',  // URL do Web App
  whatsappSuporte: '5511999999999',
  emailContato: 'contato@jvtechy.com.br',
  whatsappLeads: '5511999999999',  // formulário de leads → WhatsApp
};
```

## Deploy (Vercel)

1. Crie um **novo projeto** na Vercel apontando para esta pasta (ou monorepo com root `agendaservice-landing`).
2. Domínio sugerido: `agendaservice.com.br` (landing).
3. App em subdomínio: `app.agendaservice.com.br` → projeto `agendaservice`.

## CTAs

Todos os botões com `data-app-link` redirecionam para `config.appUrl`. Parâmetros opcionais via `data-app-params` (ex.: cadastro prestador).

## Formulário de leads

- Com `whatsappLeads` ou `whatsappSuporte`: abre WhatsApp com mensagem formatada.
- Senão: `mailto:` para `emailContato`.
- Para integração avançada (Supabase/Formspree), substitua o handler em `js/main.js`.

## Logo

SVG em `assets/logo.svg` — verde `#10B981`, detalhe dourado `#FBBF24`, fundo escuro.

---

© JVTechy — [AgendaService](https://github.com/jvtechy/agendaservice)

> Linha de teste — atualização automática do README.
> Linha de teste 2 — commit e push na main.
