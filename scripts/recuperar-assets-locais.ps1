# Recupera PNGs apagados do disco (git remove arquivos rastreados ao trocar de branch).
# Restaura da main (nomes antigos) e renomeia para SERVICOS (sem cedilha). Execute na raiz do repo.
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

function ConvertTo-PorDentroFileName {
  param([string]$FileName)
  $base = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
  $formD = $base.Normalize([Text.NormalizationForm]::FormD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($ch in $formD.ToCharArray()) {
    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne 'NonSpacingMark') {
      $null = $sb.Append($ch)
    }
  }
  $ascii = $sb.ToString() -replace 'Ç', 'C' -replace 'Ã', 'A'
  $ascii = [regex]::Replace($ascii, 'SERVI[^C_]*C?OS', 'SERVICOS', 'IgnoreCase')
  return ($ascii + '.png')
}

Write-Host "Restaurando capturas da branch main e renomeando para SERVICOS..."
$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
git fetch origin
$ErrorActionPreference = $prev

$fromMain = @(git ls-tree -r --name-only origin/main -- assets/ | Where-Object {
    $_ -match '\.(png|PNG)$' -and $_ -notmatch 'screenshot-'
  })
if (-not $fromMain.Count) {
  Write-Error "Nenhum PNG encontrado em origin/main em assets/"
}

git checkout origin/main -- $fromMain

$assetsDir = Join-Path $root "assets"
Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object {
  if ($_.Extension -notmatch '^\.(png|PNG)$') { return }
  $targetName = ConvertTo-PorDentroFileName $_.Name
  if ($_.Name -ceq $targetName) { return }
  $dest = Join-Path $assetsDir $targetName
  if (Test-Path -LiteralPath $dest) {
    Remove-Item -LiteralPath $dest -Force
  }
  Move-Item -LiteralPath $_.FullName -Destination $dest -Force
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
