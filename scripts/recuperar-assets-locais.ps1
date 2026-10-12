# Recupera PNGs apagados do disco ao trocar de branch (git remove arquivos rastreados).
# Execute na raiz do repo. NAO usa reset --hard depois.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Restaurando assets/ a partir da branch main (copias antigas do Git)..."
git fetch origin
git checkout origin/main -- assets/

Write-Host ""
Write-Host "Arquivos restaurados em assets/:"
Get-ChildItem -LiteralPath (Join-Path $root "assets") -File | ForEach-Object { Write-Host "  - $($_.Name)" }

Write-Host ""
Write-Host "Se faltarem CLIENTE_MENU_VERTICAL, CLIENTE_MEUS_PAGAMENTOS ou PRESTADOR_LOGADO,"
Write-Host "copie de novo do backup/Explorer (git nao tinha esses 3 na main)."
Write-Host ""
Write-Host "Depois envie tudo com: .\scripts\push-por-dentro-assets.ps1"
