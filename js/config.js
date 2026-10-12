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
  /** Taxa por job (%) quando a coluna taxa_job não vier do Supabase. */
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
      titulo: 'Meus agendamentos',
      arquivo: 'CLIENTE_MEUS_AGENDAMENTOS.PNG',
      descricao: 'Acompanhe pedidos em andamento e escolha o prestador ideal para cada serviço.',
    },
    {
      perfil: 'cliente',
      titulo: 'Serviços concluídos',
      arquivo: 'CLIENTE_SERVIÇOS_CONCLUIDOS.PNG',
      descricao: 'Histórico de serviços finalizados, avaliações e liberação de pagamento.',
    },
    {
      perfil: 'cliente',
      titulo: 'Cliente logado',
      arquivo: 'screenshot-cliente.png',
      descricao: 'Acesso ao painel do cliente após login — visão geral dos serviços.',
    },
    {
      perfil: 'prestador',
      titulo: 'Serviços disponíveis',
      arquivo: 'PRESTADOR_SERVIÇOS_DISPONIVEIS.PNG',
      descricao: 'Oportunidades na região para o prestador aceitar após a escolha do cliente.',
    },
    {
      perfil: 'prestador',
      titulo: 'Calendário de serviços',
      arquivo: 'PRESTADOR_CALENDARIO_DE_SERVIÇOS.PNG',
      descricao: 'Agenda do dia e da semana com serviços confirmados.',
    },
    {
      perfil: 'prestador',
      titulo: 'Meus serviços — mapa',
      arquivo: 'PRESTADOR_MEUS_SERVICOS-MAPA.PNG',
      descricao: 'Mapa com localização dos atendimentos para planejar o deslocamento.',
    },
    {
      perfil: 'prestador',
      titulo: 'Meus ganhos',
      arquivo: 'PRESTADOR_MEUS_GANHOS.png',
      descricao: 'Resumo de valores a receber e histórico de pagamentos.',
    },
    {
      perfil: 'prestador',
      titulo: 'Painel do prestador',
      arquivo: 'screenshot-prestador.png',
      descricao: 'Visão do painel do profissional parceiro na plataforma.',
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
