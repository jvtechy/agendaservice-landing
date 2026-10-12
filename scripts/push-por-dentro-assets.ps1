# Copia as 9 capturas de assets/ e envia para o branch da landing (execute na raiz do repo).
$ErrorActionPreference = "Stop"
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not (Test-Path (Join-Path $root ".git"))) { $root = Split-Path $PSScriptRoot -Parent }

$expected = @(
  "CLIENTE_MEUS_AGENDAMENTOS.PNG",
  "CLIENTE_MEUS_AGENDAMENTOS-2.PNG",
  "CLIENTE_MEUS_PAGAMENTOS.PNG",
  "CLIENTE_SERVIÇOS_CONCLUIDOS.PNG",
  "PRESTADOR_LOGADO.PNG",
  "PRESTADOR_SERVIÇOS_DISPONIVEIS.PNG",
  "PRESTADOR_CALENDARIO_DE_SERVIÇOS.PNG",
  "PRESTADOR_MEUS_SERVICOS-MAPA.PNG",
  "PRESTADOR_MEUS_GANHOS.png"
)

$assets = Join-Path $root "assets"
$missing = @()
foreach ($name in $expected) {
  if (-not (Test-Path (Join-Path $assets $name))) { $missing += $name }
}
if ($missing.Count) {
  Write-Error "Arquivos ausentes em assets/: $($missing -join ', ')"
}

Set-Location $root
git fetch origin
git checkout cursor/landing-planos-por-dentro-8972
if ($LASTEXITCODE -ne 0) { git checkout -b cursor/landing-planos-por-dentro-8972 }

foreach ($name in $expected) {
  git add -f (Join-Path "assets" $name)
}

git status
git commit -m "assets: atualiza 9 capturas da seção Por Dentro"
git push -u origin cursor/landing-planos-por-dentro-8972
Write-Host "OK — imagens enviadas para GitHub."
