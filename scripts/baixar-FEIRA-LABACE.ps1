# Baixa a pasta FEIRA-LABACE do GitHub (branch main) para o disco local.
# Uso (PowerShell):
#   .\scripts\baixar-FEIRA-LABACE.ps1
#   .\scripts\baixar-FEIRA-LABACE.ps1 -Destino "D:\Backup\FEIRA-LABACE"
param(
  [string]$Destino = "C:\FEIRA-LABACE",
  [string]$Repositorio = "jvtechy/agendaservice-landing",
  [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
  Write-Host ">> $Message" -ForegroundColor Cyan
}

$zipUrl = "https://github.com/$Repositorio/archive/refs/heads/$Branch.zip"
$tempRoot = Join-Path $env:TEMP "feira-labace-download"
$zipPath = Join-Path $tempRoot "repo.zip"
$extractRoot = Join-Path $tempRoot "extract"
$repoFolderName = ($Repositorio.Split("/")[-1]) + "-$Branch"
$sourceFolder = Join-Path $extractRoot $repoFolderName "FEIRA-LABACE"

Write-Step "Destino: $Destino"
Write-Step "Baixando $zipUrl"

New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
if (Test-Path $extractRoot) {
  Remove-Item -LiteralPath $extractRoot -Recurse -Force
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

Write-Step "Extraindo ZIP..."
Expand-Archive -LiteralPath $zipPath -DestinationPath $extractRoot -Force

if (-not (Test-Path -LiteralPath $sourceFolder)) {
  throw "Pasta FEIRA-LABACE nao encontrada no ZIP. Verifique se a branch '$Branch' contem a pasta."
}

Write-Step "Copiando arquivos..."
New-Item -ItemType Directory -Force -Path $Destino | Out-Null
Copy-Item -Path (Join-Path $sourceFolder "*") -Destination $Destino -Recurse -Force

Write-Step "Limpando arquivos temporarios..."
Remove-Item -LiteralPath $tempRoot -Recurse -Force

Write-Host ""
Write-Host "Concluido! Pasta disponivel em: $Destino" -ForegroundColor Green
Write-Host "Subpastas: originais, restauradas, restauradas_ia, videos, videos_restaurados"
