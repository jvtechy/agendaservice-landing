# Envia as 9 capturas de assets/ para o branch da landing (execute na raiz do repo).
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$branch = "cursor/landing-planos-por-dentro-8972"

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

# Evita erro "local changes would be overwritten by merge" (PNG antigos .PNG vs branch novo)
$stashName = "agendaservice-landing-assets-$(Get-Date -Format 'yyyyMMddHHmmss')"
git stash push -u -m $stashName -- assets 2>$null

git checkout $branch 2>$null
if ($LASTEXITCODE -ne 0) {
  git checkout -b $branch "origin/$branch"
}
git reset --hard "origin/$branch"

# Restaura só os PNG da pasta assets do stash (se existir)
$stashList = git stash list | Select-String $stashName
if ($stashList) {
  git checkout "stash@{0}" -- assets 2>$null
  git stash drop "stash@{0}" 2>$null
}

# Garante que os 9 arquivos locais (já validados) entram no commit
foreach ($name in $expected) {
  git add -f (Join-Path "assets" $name)
}

# Remove legado se ainda estiver rastreado
$legacy = @(
  "assets/CLIENTE_MEUS_AGENDAMENTOS.PNG",
  "assets/CLIENTE_SERVIÇOS_CONCLUIDOS.PNG",
  "assets/PRESTADOR_CALENDARIO_DE_SERVIÇOS.PNG",
  "assets/PRESTADOR_MEUS_SERVICOS-MAPA.PNG",
  "assets/PRESTADOR_SERVIÇOS_DISPONIVEIS.PNG",
  "assets/PRESTADOR_MEUS_GANHOS.PNG",
  "assets/screenshot-cliente.png",
  "assets/screenshot-prestador.png"
)
foreach ($path in $legacy) {
  git rm -f --ignore-unmatch $path 2>$null | Out-Null
}

git status
$pending = git diff --cached --name-only
if (-not $pending) {
  Write-Host "Nada novo para commitar (imagens já estão no GitHub?)."
  exit 0
}

git commit -m "assets: atualiza 9 capturas da seção Por Dentro"
git push -u origin $branch
Write-Host "OK — imagens enviadas para GitHub."
