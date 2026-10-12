# Envia as 9 capturas de assets/ para o branch da landing (execute na raiz do repo).
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent

$expected = @(
  "CLIENTE_MENU_VERTICAL.png",
  "CLIENTE_MEUS_AGENDAMENTOS.png",
  "CLIENTE_MEUS_PAGAMENTOS.png",
  "CLIENTE_SERVIÇOS_CONCLUIDOS.png",
  "PRESTADOR_LOGADO.png",
  "PRESTADOR_SERVIÇOS_DISPONIVEIS.png",
  "PRESTADOR_CALENDARIO_DE_SERVIÇOS.png",
  "PRESTADOR_MEUS_SERVICOS-MAPA.png",
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
git checkout cursor/landing-planos-por-dentro-8972 2>$null
if ($LASTEXITCODE -ne 0) { git checkout -b cursor/landing-planos-por-dentro-8972 }

# Remove capturas antigas (extensão .PNG / screenshots legados)
$legacy = @(
  "assets/CLIENTE_MEUS_AGENDAMENTOS.PNG",
  "assets/CLIENTE_SERVIÇOS_CONCLUIDOS.PNG",
  "assets/PRESTADOR_CALENDARIO_DE_SERVIÇOS.PNG",
  "assets/PRESTADOR_MEUS_SERVICOS-MAPA.PNG",
  "assets/PRESTADOR_SERVIÇOS_DISPONIVEIS.PNG",
  "assets/screenshot-cliente.png",
  "assets/screenshot-prestador.png"
)
foreach ($path in $legacy) {
  if (Test-Path (Join-Path $root $path)) { git rm -f $path 2>$null }
}

foreach ($name in $expected) {
  git add -f (Join-Path "assets" $name)
}

git status
git commit -m "assets: atualiza 9 capturas da seção Por Dentro"
git push -u origin cursor/landing-planos-por-dentro-8972
Write-Host "OK — imagens enviadas para GitHub."
