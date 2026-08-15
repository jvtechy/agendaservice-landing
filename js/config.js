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
   * Fallback espelhando planos_assinatura do app (Dev).
   * Quando a tabela tiver linhas ativas, a landing usa os dados do Supabase.
   * preco_anual em reais; limite_aceites null = ilimitado.
   */
  planosAssinaturaFallback: [
    {
      codigo: 'basico',
      nome: 'Básico',
      descricao: 'Ideal para começar a atender pela plataforma com baixo compromisso.',
      preco_anual: 0,
      limite_aceites: 8,
      ordem: 1,
      status: 1,
    },
    {
      codigo: 'profissional',
      nome: 'Profissional',
      descricao: 'Para quem quer mais volume, destaque e taxa reduzida.',
      preco_anual: 598.8,
      limite_aceites: 40,
      ordem: 2,
      status: 1,
    },
    {
      codigo: 'parceiro',
      nome: 'Parceiro',
      descricao: 'Máxima prioridade, aceites ilimitados e as melhores condições.',
      preco_anual: 1198.8,
      limite_aceites: null,
      ordem: 3,
      status: 1,
    },
  ],
};
