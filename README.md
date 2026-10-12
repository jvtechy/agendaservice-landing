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

## Planos de assinatura

A seção `#planos` espelha a tela **Minha Assinatura** do Web App (Dev):

| Plano | Anual | ≈/mês | Taxa/job |
|-------|-------|-------|----------|
| **Trial** (status inicial) | — | — | 20% |
| Essencial | R$ 178,68 | R$ 14,89 | 16% |
| Profissional | R$ 358,68 | R$ 29,89 | 12% |
| Premium | R$ 479,88 | R$ 39,99 | 5% |

O **Trial** aparece como faixa de status (como em Minha Assinatura no app), não como card de compra.
Carrega `planos_assinatura` no Supabase (preço, nome, ordem). **Taxas exibidas:** `taxaPorCodigo` em `js/config.js` (20/16/12/5) enquanto `prioridadeTaxaSupabase` for `false`. Para usar só o banco, crie a coluna `taxa_job` (`supabase/planos_assinatura-taxa_job.sql`) e defina `prioridadeTaxaSupabase: true`.

A seção **Por Dentro** (`porDentroGaleria` em `js/config.js`) renderiza 3×3 telas (9 PNGs em `assets/`, nomes com `SERVICOS` sem cedilha): 4 de cliente, depois 5 de prestador.

**Windows:** não use `git pull` se você já tem PNGs em `assets/` — o Git aborta com “untracked files would be overwritten”.

**Nao use `git pull`.** Se der erro de *untracked files would be overwritten*, copie **tudo** no PowerShell (pasta do projeto):

```powershell
git fetch origin
git show origin/cursor/landing-planos-por-dentro-8972:PUBLICAR-POR-DENTRO.ps1 | Out-File -FilePath PUBLICAR-POR-DENTRO.ps1 -Encoding utf8
powershell -ExecutionPolicy Bypass -File .\PUBLICAR-POR-DENTRO.ps1
```

Alternativa: duplo clique em `publicar-por-dentro.cmd` (apos `git fetch` uma vez).
CTAs: Web App com `?auth=register&plan=<codigo>`.

## Logo

SVG em `assets/logo.svg` — verde `#10B981`, detalhe dourado `#FBBF24`, fundo escuro.

---

© JVTechy — [AgendaService](https://github.com/jvtechy/agendaservice)

> Linha de teste — atualização automática do README.
> Linha de teste 2 — commit e push na main.
