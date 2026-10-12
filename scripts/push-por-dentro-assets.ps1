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
  Write-Error "Pasta não encontrada: $assetsDir"
}

$allFiles = Get-ChildItem -LiteralPath $assetsDir -File
$missing = @()

Set-Location $root
git fetch origin

if (-not (git rev-parse --verify "origin/$branch" 2>$null)) {
  Write-Error "Branch remoto não encontrado: origin/$branch (rode: git fetch origin)"
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
  git add -f $dest
}

if ($missing.Count) {
  Write-Host "`nArquivos atuais em assets/:"
  $allFiles | ForEach-Object { Write-Host "  - $($_.Name)" }
  Write-Error "Faltando (base do nome): $($missing -join ', ')"
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
  Write-Host "Nada novo para commitar (imagens já estão no GitHub?)."
  exit 0
}

git commit -m "assets: atualiza 9 capturas da seção Por Dentro"
git push -u origin $branch
Write-Host "OK — imagens enviadas para GitHub no branch $branch."
