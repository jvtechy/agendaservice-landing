/**
 * Configure antes do deploy (Vercel: variáveis ou edite este arquivo).
 * appUrl: URL do Web App AgendaService (projeto agendaservice).
 * supabase*: mesma base do app — planos_assinatura / assinaturas_prestador.
 */
window.AGENDASERVICE_CONFIG = {
  appUrl: 'https://agendaservice.vercel.app',
  whatsappSuporte: '5531998163074',
  emailContato: 'contato@jvtechy.com.br',
  whatsappLeads: '',
  supabaseUrl: 'https://pygzpjudjsbsdtrhwayl.supabase.co',
  supabaseAnonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5Z3pwanVkanNic2R0cmh3YXlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5NTI4NzQsImV4cCI6MjA4NTUyODg3NH0.69ncwkiLIF7DmY69pKgKh9nDcKwVIlJ_N0PoaAgbaqk',
  /**
   * Trial = status inicial do prestador no app (Minha Assinatura), não um plano anual.
   * Aparece como faixa acima dos 3 planos pagos.
   */
  trialAssinatura: {
    nome: 'Trial',
    statusLabel: 'Trial',
    descricao: 'Comece sem pagar assinatura e teste a plataforma antes de escolher um plano anual.',
    trial_dias: 7,
    trial_aceites: 2,
    taxa_job: 20,
  },
  /** Incremente ao trocar PNGs em assets/ (cache do navegador e CDN). */
  assetsVersion: '20260330-plans2',
  /**
   * false (padrão): taxas exibidas vêm de taxaPorCodigo (20/16/12/5).
   * true: usa taxa_job da tabela planos_assinatura quando a coluna existir.
   */
  prioridadeTaxaSupabase: false,
  /** Taxa por job (%) — fonte oficial na landing quando prioridadeTaxaSupabase é false. */
  taxaPorCodigo: {
    trial: 20,
    essencial: 16,
    profissional: 12,
    premium: 5,
  },
  /**
   * Galeria "Por Dentro" — 3 linhas × 3 imagens (clientes, depois prestadores).
   * Atualize `arquivo` em assets/ quando trocar as capturas de tela.
   */
  porDentroGaleria: [
    {
      perfil: 'cliente',
      titulo: 'Menu do cliente',
      arquivo: 'CLIENTE_MENU_VERTICAL.png',
      descricao: 'Navegação rápida no painel do cliente após o login.',
    },
    {
      perfil: 'cliente',
      titulo: 'Meus agendamentos',
      arquivo: 'CLIENTE_MEUS_AGENDAMENTOS.png',
      descricao: 'Lista de pedidos em andamento — compare prestadores e escolha quem vai atender.',
    },
    {
      perfil: 'cliente',
      titulo: 'Meus pagamentos',
      arquivo: 'CLIENTE_MEUS_PAGAMENTOS.png',
      descricao: 'Pagamentos via PIX com transparência em cada etapa do serviço.',
    },
    {
      perfil: 'cliente',
      titulo: 'Serviços concluídos',
      arquivo: 'CLIENTE_SERVICOS_CONCLUIDOS.png',
      descricao: 'Histórico de serviços finalizados, avaliações e liberação de pagamento.',
    },
    {
      perfil: 'prestador',
      titulo: 'Prestador logado',
      arquivo: 'PRESTADOR_LOGADO.png',
      descricao: 'Painel do profissional após login — visão geral da operação.',
    },
    {
      perfil: 'prestador',
      titulo: 'Serviços disponíveis',
      arquivo: 'PRESTADOR_SERVICOS_DISPONIVEIS.png',
      descricao: 'Oportunidades na região após o cliente escolher o prestador.',
    },
    {
      perfil: 'prestador',
      titulo: 'Calendário de serviços',
      arquivo: 'PRESTADOR_CALENDARIO_DE_SERVICOS.png',
      descricao: 'Agenda do dia e da semana com serviços confirmados.',
    },
    {
      perfil: 'prestador',
      titulo: 'Meus serviços — mapa',
      arquivo: 'PRESTADOR_MEUS_SERVICOS-MAPA.png',
      descricao: 'Mapa com localização dos atendimentos para planejar o deslocamento.',
    },
    {
      perfil: 'prestador',
      titulo: 'Meus ganhos',
      arquivo: 'PRESTADOR_MEUS_GANHOS.png',
      descricao: 'Resumo de valores a receber e histórico de pagamentos.',
    },
  ],
  /**
   * Fallback alinhado à tela "Minha Assinatura" do app (versão Dev).
   * preco_anual em reais; taxa_job em %; limite_aceites null = ilimitado.
   * Quando planos_assinatura tiver linhas ativas, a landing usa o Supabase.
   */
  planosAssinaturaFallback: [
    {
      codigo: 'essencial',
      nome: 'Essencial',
      tagline: 'Menos que um Sanduíche',
      descricao: 'Aceites ilimitados com taxa de 16% por job.',
      preco_anual: 178.68,
      taxa_job: 16,
      limite_aceites: null,
      ordem: 1,
      status: 1,
    },
    {
      codigo: 'profissional',
      nome: 'Profissional',
      tagline: 'Custa menos que uma mini pizza por mês',
      descricao: 'Taxa reduzida de 12% por job concluído.',
      preco_anual: 358.68,
      taxa_job: 12,
      limite_aceites: null,
      ordem: 2,
      status: 1,
    },
    {
      codigo: 'premium',
      nome: 'Premium',
      tagline: 'Você vai pagar menos do que uma pizza!',
      descricao: 'Taxa de 5% por job — melhor margem entre os planos pagos.',
      preco_anual: 479.88,
      taxa_job: 5,
      limite_aceites: null,
      ordem: 3,
      status: 1,
    },
  ],
};
