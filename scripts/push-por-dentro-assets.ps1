# Envia as 9 capturas de assets/ para o branch da landing (execute na raiz do repo).
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$branch = "cursor/landing-planos-por-dentro-8972"

$expected = [ordered]@{
  "CLIENTE_MENU_VERTICAL.png" = @("CLIENTE_MENU_VERTICAL")
  "CLIENTE_MEUS_AGENDAMENTOS.png" = @("CLIENTE_MEUS_AGENDAMENTOS")
  "CLIENTE_MEUS_PAGAMENTOS.png" = @("CLIENTE_MEUS_PAGAMENTOS")
  "CLIENTE_SERVIÇOS_CONCLUIDOS.png" = @("CLIENTE_SERVIÇOS_CONCLUIDOS")
  "PRESTADOR_LOGADO.png" = @("PRESTADOR_LOGADO")
  "PRESTADOR_SERVIÇOS_DISPONIVEIS.png" = @("PRESTADOR_SERVIÇOS_DISPONIVEIS")
  "PRESTADOR_CALENDARIO_DE_SERVIÇOS.png" = @("PRESTADOR_CALENDARIO_DE_SERVIÇOS")
  "PRESTADOR_MEUS_SERVICOS-MAPA.png" = @("PRESTADOR_MEUS_SERVICOS-MAPA", "PRESTADOR_MEUS_SERVIÇOS-MAPA")
  "PRESTADOR_MEUS_GANHOS.png" = @("PRESTADOR_MEUS_GANHOS")
}

function Find-AssetByBaseName {
  param([System.IO.FileInfo[]]$Files, [string[]]$BaseNames)
  foreach ($base in $BaseNames) {
    $hit = $Files | Where-Object { $_.BaseName -eq $base } | Select-Object -First 1
    if ($hit) { return $hit }
  }
  return $null
}

$assetsDir = Join-Path $root "assets"
if (-not (Test-Path $assetsDir)) {
  Write-Error "Pasta nao encontrada: $assetsDir"
}

$allFiles = Get-ChildItem -LiteralPath $assetsDir -File
$missing = @()

Set-Location $root
git fetch origin

if (-not (git rev-parse --verify "origin/$branch" 2>$null)) {
  Write-Error "Branch remoto nao encontrado: origin/$branch"
}

git switch -C $branch "origin/$branch"

foreach ($canonical in $expected.Keys) {
  $baseNames = $expected[$canonical]
  $source = Find-AssetByBaseName -Files $allFiles -BaseNames $baseNames
  if (-not $source) {
    $missing += $canonical
    continue
  }
  $dest = Join-Path $assetsDir $canonical
  Copy-Item -LiteralPath $source.FullName -Destination $dest -Force
  git add -f -- "assets/$canonical"
}

if ($missing.Count) {
  Write-Host ""
  Write-Host "Arquivos em assets/ agora:"
  Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object { Write-Host "  - $($_.Name)" }
  Write-Error "Faltam $($missing.Count) imagem(ns). Copie para assets/ e rode de novo."
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

git status
$pending = git diff --cached --name-only
if (-not $pending) {
  Write-Host "Nada novo para commitar."
  exit 0
}

git commit -m "assets: atualiza 9 capturas da secao Por Dentro"
git push -u origin $branch
Write-Host "OK - imagens enviadas para GitHub no branch $branch."
