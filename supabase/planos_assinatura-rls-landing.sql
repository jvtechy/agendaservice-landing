-- Execute no SQL Editor do Supabase (projeto agendaservice).
-- Permite que a landing page (chave anon) leia planos_assinatura.
-- Sem esta política, a API devolve [] e a página usa só o fallback de js/config.js.

ALTER TABLE public.planos_assinatura ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS planos_assinatura_public_read_landing ON public.planos_assinatura;

CREATE POLICY planos_assinatura_public_read_landing
  ON public.planos_assinatura
  FOR SELECT
  TO anon, authenticated
  USING (true);

GRANT SELECT ON TABLE public.planos_assinatura TO anon;
GRANT SELECT ON TABLE public.planos_assinatura TO authenticated;
