# Envia as 9 capturas de assets/ para o branch da landing (execute na raiz do repo).
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$branch = "cursor/landing-planos-por-dentro-8972"

# Nome canônico (como na landing) -> padrões aceitos no disco (Windows ignora maiúsculas)
$expected = [ordered]@{
  "CLIENTE_MENU_VERTICAL.png" = @("CLIENTE_MENU_VERTICAL.png", "CLIENTE_MENU_VERTICAL.PNG")
  "CLIENTE_MEUS_AGENDAMENTOS.png" = @("CLIENTE_MEUS_AGENDAMENTOS.png", "CLIENTE_MEUS_AGENDAMENTOS.PNG")
  "CLIENTE_MEUS_PAGAMENTOS.png" = @("CLIENTE_MEUS_PAGAMENTOS.png", "CLIENTE_MEUS_PAGAMENTOS.PNG")
  "CLIENTE_SERVIÇOS_CONCLUIDOS.png" = @("CLIENTE_SERVIÇOS_CONCLUIDOS.png", "CLIENTE_SERVIÇOS_CONCLUIDOS.PNG")
  "PRESTADOR_LOGADO.png" = @("PRESTADOR_LOGADO.png", "PRESTADOR_LOGADO.PNG")
  "PRESTADOR_SERVIÇOS_DISPONIVEIS.png" = @("PRESTADOR_SERVIÇOS_DISPONIVEIS.png", "PRESTADOR_SERVIÇOS_DISPONIVEIS.PNG")
  "PRESTADOR_CALENDARIO_DE_SERVIÇOS.png" = @("PRESTADOR_CALENDARIO_DE_SERVIÇOS.png", "PRESTADOR_CALENDARIO_DE_SERVIÇOS.PNG")
  "PRESTADOR_MEUS_SERVICOS-MAPA.png" = @(
    "PRESTADOR_MEUS_SERVICOS-MAPA.png",
    "PRESTADOR_MEUS_SERVICOS-MAPA.PNG",
    "PRESTADOR_MEUS_SERVIÇOS-MAPA.png",
    "PRESTADOR_MEUS_SERVIÇOS-MAPA.PNG"
  )
  "PRESTADOR_MEUS_GANHOS.png" = @("PRESTADOR_MEUS_GANHOS.png", "PRESTADOR_MEUS_GANHOS.PNG")
}

function Resolve-AssetPath {
  param([string]$AssetsDir, [string[]]$Patterns)
  foreach ($pattern in $Patterns) {
    $full = Join-Path $AssetsDir $pattern
    if (Test-Path -LiteralPath $full) { return $full }
  }
  $files = Get-ChildItem -LiteralPath $AssetsDir -File -ErrorAction SilentlyContinue
  foreach ($pattern in $Patterns) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($pattern)
    $hit = $files | Where-Object { $_.BaseName -eq $base } | Select-Object -First 1
    if ($hit) { return $hit.FullName }
  }
  return $null
}

$assetsDir = Join-Path $root "assets"
if (-not (Test-Path $assetsDir)) {
  Write-Error "Pasta não encontrada: $assetsDir"
}

$resolved = @{}
$missing = @()
foreach ($canonical in $expected.Keys) {
  $path = Resolve-AssetPath -AssetsDir $assetsDir -Patterns $expected[$canonical]
  if (-not $path) {
    $missing += $canonical
  } else {
    $resolved[$canonical] = $path
  }
}

if ($missing.Count) {
  Write-Host "Arquivos em assets/ (para conferência):"
  Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object { Write-Host "  - $($_.Name)" }
  Write-Error "Faltando (nome canônico): $($missing -join ', ')"
}

Set-Location $root
git fetch origin

if (-not (git rev-parse --verify "origin/$branch" 2>$null)) {
  Write-Error "Branch remoto não encontrado: origin/$branch"
}

git switch -C $branch "origin/$branch"

$staging = Join-Path $env:TEMP "agendaservice-por-dentro-staging"
if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Path $staging | Out-Null

foreach ($canonical in $resolved.Keys) {
  $src = $resolved[$canonical]
  $dest = Join-Path $staging $canonical
  Copy-Item -LiteralPath $src -Destination $dest -Force
  git add -f $dest
  git mv -f $dest (Join-Path "assets" $canonical)
}

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

Remove-Item -Recurse -Force $staging -ErrorAction SilentlyContinue

git status
$pending = git diff --cached --name-only
if (-not $pending) {
  Write-Host "Nada novo para commitar (imagens já estão no GitHub?)."
  exit 0
}

git commit -m "assets: atualiza 9 capturas da seção Por Dentro"
git push -u origin $branch
Write-Host "OK — imagens enviadas para GitHub no branch $branch."
