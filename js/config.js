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
    trial_aceites: 1,
    taxa_job: 15,
  },
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
      descricao: 'Aceites ilimitados com taxa padrão de 15% por job.',
      preco_anual: 178.68,
      taxa_job: 15,
      limite_aceites: null,
      ordem: 1,
      status: 1,
    },
    {
      codigo: 'profissional',
      nome: 'Profissional',
      tagline: 'Custa menos que uma mini pizza por mês',
      descricao: 'Taxa reduzida de 5% por job concluído.',
      preco_anual: 358.68,
      taxa_job: 5,
      limite_aceites: null,
      ordem: 2,
      status: 1,
    },
    {
      codigo: 'premium',
      nome: 'Premium',
      tagline: 'Você vai pagar menos do que uma pizza!',
      descricao: 'Zero taxa por job — máxima margem para o prestador.',
      preco_anual: 479.88,
      taxa_job: 0,
      limite_aceites: null,
      ordem: 3,
      status: 1,
    },
  ],
};
