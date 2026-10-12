# Recupera PNGs apagados do disco (git remove arquivos rastreados ao trocar de branch).
# Restaura da main e renomeia para SERVICOS (sem cedilha). Execute na raiz do repo.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host "Restaurando capturas da branch main e renomeando para SERVICOS..."
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

$assetsDir = Join-Path $root "assets"
$renames = @{
  "CLIENTE_MEUS_AGENDAMENTOS.PNG" = "CLIENTE_MEUS_AGENDAMENTOS.png"
  "CLIENTE_SERVIÇOS_CONCLUIDOS.PNG" = "CLIENTE_SERVICOS_CONCLUIDOS.png"
  "PRESTADOR_CALENDARIO_DE_SERVIÇOS.PNG" = "PRESTADOR_CALENDARIO_DE_SERVICOS.png"
  "PRESTADOR_MEUS_SERVICOS-MAPA.PNG" = "PRESTADOR_MEUS_SERVICOS-MAPA.png"
  "PRESTADOR_SERVIÇOS_DISPONIVEIS.PNG" = "PRESTADOR_SERVICOS_DISPONIVEIS.png"
}
foreach ($pair in $renames.GetEnumerator()) {
  $src = Join-Path $assetsDir $pair.Key
  $dest = Join-Path $assetsDir $pair.Value
  if (Test-Path -LiteralPath $src) {
    Move-Item -LiteralPath $src -Destination $dest -Force
  }
}

Write-Host ""
Write-Host "Arquivos em assets/:"
Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object { Write-Host "  - $($_.Name)" }

Write-Host ""
Write-Host "Mantenha (ou copie do backup) os 3 PNG novos se faltarem:"
Write-Host "  CLIENTE_MENU_VERTICAL.png"
Write-Host "  CLIENTE_MEUS_PAGAMENTOS.png"
Write-Host "  PRESTADOR_LOGADO.png"
Write-Host ""
Write-Host "Envie as 9 para o GitHub com: .\scripts\push-por-dentro-assets.ps1"
