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

Write-Host "Atualizando scripts/ do GitHub (sem git pull)..."
git checkout $remote -- scripts/
if ($LASTEXITCODE -ne 0) { Write-Error "git checkout scripts falhou." }

Write-Host "Alinhando branch com $remote..."
git reset --mixed $remote
if ($LASTEXITCODE -ne 0) { Write-Error "git reset --mixed falhou." }

$ErrorActionPreference = $prev
Write-Host ""
Write-Host "Desbloqueado. Agora rode: .\scripts\push-por-dentro-assets.ps1"
