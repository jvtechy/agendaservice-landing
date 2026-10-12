# Recupera PNGs apagados do disco (git remove arquivos rastreados ao trocar de branch).
# NAO restaura screenshot-*.png (legado). Execute na raiz do repo.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Restaurando capturas antigas da branch main (6 arquivos)..."
git fetch origin

$fromMain = @(
  "assets/CLIENTE_MEUS_AGENDAMENTOS.PNG",
  "assets/CLIENTE_SERVIÇOS_CONCLUIDOS.PNG",
  "assets/PRESTADOR_CALENDARIO_DE_SERVIÇOS.PNG",
  "assets/PRESTADOR_MEUS_GANHOS.png",
  "assets/PRESTADOR_MEUS_SERVICOS-MAPA.PNG",
  "assets/PRESTADOR_SERVIÇOS_DISPONIVEIS.PNG",
  "assets/logo.svg",
  "assets/logo-icon.svg"
)
git checkout origin/main -- $fromMain

Write-Host ""
Write-Host "Arquivos em assets/:"
Get-ChildItem -LiteralPath (Join-Path $root "assets") -File | ForEach-Object { Write-Host "  - $($_.Name)" }

Write-Host ""
Write-Host "Mantenha (ou copie de backup) os 3 PNG novos:"
Write-Host "  CLIENTE_MENU_VERTICAL.png"
Write-Host "  CLIENTE_MEUS_PAGAMENTOS.png"
Write-Host "  PRESTADOR_LOGADO.png"
Write-Host ""
Write-Host "Envie as 9 para o GitHub com: .\scripts\push-por-dentro-assets.ps1"
