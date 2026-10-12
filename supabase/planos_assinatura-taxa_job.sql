-- Execute no SQL Editor do Supabase (projeto agendaservice).
-- Garante coluna taxa_job e valores oficiais na landing / app.

ALTER TABLE public.planos_assinatura
  ADD COLUMN IF NOT EXISTS taxa_job numeric(5, 2);

COMMENT ON COLUMN public.planos_assinatura.taxa_job IS 'Taxa percentual por job (ex.: 16 = 16%)';

-- Ajuste os UPDATEs se os codigos no seu banco forem diferentes.
UPDATE public.planos_assinatura SET taxa_job = 16 WHERE lower(codigo) LIKE '%essencial%';
UPDATE public.planos_assinatura SET taxa_job = 12 WHERE lower(codigo) LIKE '%profissional%';
UPDATE public.planos_assinatura SET taxa_job = 5 WHERE lower(codigo) LIKE '%premium%';
UPDATE public.planos_assinatura SET taxa_job = 20 WHERE lower(codigo) LIKE '%trial%';

-- Depois de popular a tabela, na landing defina prioridadeTaxaSupabase: true em js/config.js
