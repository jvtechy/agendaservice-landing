# Use quando git pull falhar com "untracked working tree files would be overwritten".
# Nao apaga PNGs em assets/. Nao usa merge.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$branch = "cursor/landing-planos-por-dentro-8972"
$remote = "origin/$branch"

Set-Location $root
$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
git fetch origin
if ($LASTEXITCODE -ne 0) { Write-Error "git fetch falhou." }

$assetsDir = Join-Path $root "assets"
$pngNames = @(
  "CLIENTE_MENU_VERTICAL.png", "CLIENTE_MEUS_AGENDAMENTOS.png", "CLIENTE_MEUS_PAGAMENTOS.png",
  "CLIENTE_SERVICOS_CONCLUIDOS.png", "PRESTADOR_LOGADO.png", "PRESTADOR_SERVICOS_DISPONIVEIS.png",
  "PRESTADOR_CALENDARIO_DE_SERVICOS.png", "PRESTADOR_MEUS_SERVICOS-MAPA.png", "PRESTADOR_MEUS_GANHOS.png"
)
foreach ($n in $pngNames) {
  $p = Join-Path $assetsDir $n
  if (Test-Path -LiteralPath $p) { git add -f -- "assets/$n" 2>$null | Out-Null }
}

Write-Host "Atualizando scripts/ do GitHub (sem git pull)..."
git checkout $remote -- scripts/
if ($LASTEXITCODE -ne 0) { Write-Error "git checkout scripts falhou." }

Write-Host "Alinhando branch com $remote..."
$rev = (git rev-parse $remote).Trim()
git branch -f $branch $rev 2>$null | Out-Null
git switch $branch 2>$null
git reset --mixed $rev
if ($LASTEXITCODE -ne 0) { Write-Error "git reset --mixed falhou." }

$ErrorActionPreference = $prev
Write-Host ""
Write-Host "Desbloqueado. Agora rode: .\scripts\push-por-dentro-assets.ps1"
