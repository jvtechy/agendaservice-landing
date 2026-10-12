# Atualiza o branch local sem git pull (evita erro de PNG nao rastreado em assets/).
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$branch = "cursor/landing-planos-por-dentro-8972"

Set-Location $root
$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
git fetch origin
$ErrorActionPreference = $prev
if ($LASTEXITCODE -ne 0) { Write-Error "git fetch falhou." }

$current = git branch --show-current
if ($current -ne $branch) {
  git switch $branch 2>$null
  if ($LASTEXITCODE -ne 0) { git switch -c $branch "origin/$branch" }
}

Write-Host "Atualizando scripts/ do remoto..."
git checkout "origin/$branch" -- scripts/
if ($LASTEXITCODE -ne 0) { Write-Error "git checkout scripts falhou." }

Write-Host "Alinhando $branch com origin/$branch (nao apaga PNGs em assets/)..."
$ErrorActionPreference = "Continue"
git reset --mixed "origin/$branch"
$ErrorActionPreference = $prev
if ($LASTEXITCODE -ne 0) { Write-Error "git reset falhou." }

Write-Host "Pronto. Para publicar imagens: .\scripts\push-por-dentro-assets.ps1"
