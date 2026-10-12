# Entrada unica no Windows: alinha o branch (sem git pull) e publica as 9 PNGs.
# Se este arquivo nao existir ainda no PC, apos git fetch rode:
#   git show origin/cursor/landing-planos-por-dentro-8972:PUBLICAR-POR-DENTRO.ps1 | Out-File PUBLICAR-POR-DENTRO.ps1 -Encoding utf8
#   powershell -ExecutionPolicy Bypass -File .\PUBLICAR-POR-DENTRO.ps1
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$branch = "cursor/landing-planos-por-dentro-8972"
$remote = "origin/$branch"

$expected = [ordered]@{
  "CLIENTE_MENU_VERTICAL.png" = @("CLIENTE_MENU_VERTICAL")
  "CLIENTE_MEUS_AGENDAMENTOS.png" = @("CLIENTE_MEUS_AGENDAMENTOS")
  "CLIENTE_MEUS_PAGAMENTOS.png" = @("CLIENTE_MEUS_PAGAMENTOS")
  "CLIENTE_SERVICOS_CONCLUIDOS.png" = @("CLIENTE_SERVICOS_CONCLUIDOS")
  "PRESTADOR_LOGADO.png" = @("PRESTADOR_LOGADO")
  "PRESTADOR_SERVICOS_DISPONIVEIS.png" = @("PRESTADOR_SERVICOS_DISPONIVEIS")
  "PRESTADOR_CALENDARIO_DE_SERVICOS.png" = @("PRESTADOR_CALENDARIO_DE_SERVICOS")
  "PRESTADOR_MEUS_SERVICOS-MAPA.png" = @("PRESTADOR_MEUS_SERVICOS-MAPA")
  "PRESTADOR_MEUS_GANHOS.png" = @("PRESTADOR_MEUS_GANHOS")
}
$keepInRepo = @("logo.svg", "logo-icon.svg") + @($expected.Keys)

function Invoke-GitQuiet {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  & git @GitArgs
  $code = $LASTEXITCODE
  $ErrorActionPreference = $prev
  return $code
}

function Find-AssetByBaseName {
  param([System.IO.FileInfo[]]$Files, [string[]]$BaseNames)
  foreach ($base in $BaseNames) {
    $hit = $Files | Where-Object { $_.BaseName -ieq $base } | Select-Object -First 1
    if ($hit) { return $hit }
  }
  return $null
}

function Sync-ScriptFromOrigin {
  param([string]$RelativePath)
  $dest = Join-Path $root $RelativePath
  $dir = Split-Path $dest -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $text = git show "${remote}:${RelativePath}" 2>$null
  if ($LASTEXITCODE -ne 0 -or -not $text) { return $false }
  if ($text -is [array]) { $text = $text -join "`n" }
  Set-Content -LiteralPath $dest -Value $text -Encoding utf8
  return $true
}

Set-Location $root
$assetsDir = Join-Path $root "assets"
if (-not (Test-Path $assetsDir)) {
  Write-Error "Pasta nao encontrada: $assetsDir"
}

Write-Host "1/4 git fetch..."
if ((Invoke-GitQuiet fetch origin) -ne 0) { Write-Error "git fetch falhou." }

if (-not (git rev-parse --verify $remote 2>$null)) {
  Write-Error "Remoto nao encontrado: $remote"
}

Write-Host "2/4 Atualizando scripts/ (sem git pull)..."
$scriptPaths = @(
  "scripts/push-por-dentro-assets.ps1",
  "scripts/desbloquear-pull.ps1",
  "scripts/alinhar-branch.ps1"
)
foreach ($rel in $scriptPaths) {
  if (-not (Sync-ScriptFromOrigin $rel)) {
    Write-Host "  aviso: nao foi possivel baixar $rel (continuando)"
  }
}
Invoke-GitQuiet checkout $remote -- scripts/ | Out-Null

$current = git branch --show-current
if ($current -ne $branch) {
  if ((Invoke-GitQuiet switch $branch) -ne 0) {
    if ((Invoke-GitQuiet switch -c $branch $remote) -ne 0) {
      Write-Error "Nao foi possivel usar o branch $branch"
    }
  }
}

Write-Host "3/4 Alinhando branch (reset --mixed, mantem PNGs em assets/)..."
if ((Invoke-GitQuiet reset --mixed $remote) -ne 0) {
  Write-Error "git reset --mixed falhou."
}

Write-Host "4/4 Publicando 9 imagens..."
Invoke-GitQuiet checkout $remote -- scripts/ | Out-Null

git ls-files "assets/*" | ForEach-Object {
  $name = Split-Path $_ -Leaf
  if ($keepInRepo -contains $name) { return }
  if ($name -match '\.(png|PNG)$') {
    Invoke-GitQuiet rm -f --ignore-unmatch $_ | Out-Null
  }
}

$allFiles = Get-ChildItem -LiteralPath $assetsDir -File
$missing = @()

foreach ($canonical in $expected.Keys) {
  $source = Find-AssetByBaseName -Files $allFiles -BaseNames $expected[$canonical]
  if (-not $source) {
    $missing += $canonical
    continue
  }
  $dest = Join-Path $assetsDir $canonical
  $srcFull = [System.IO.Path]::GetFullPath($source.FullName)
  $destFull = [System.IO.Path]::GetFullPath($dest)
  if ($srcFull -ne $destFull) {
    Copy-Item -LiteralPath $source.FullName -Destination $dest -Force
  }
  if ((Invoke-GitQuiet add -f -- "assets/$canonical") -ne 0) {
    Write-Error "git add falhou: assets/$canonical"
  }
}

if ($missing.Count) {
  Write-Host ""
  Write-Host "Em assets/:"
  Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object { Write-Host "  - $($_.Name)" }
  Write-Error "Faltam $($missing.Count) PNG. Nomes esperados: $($expected.Keys -join ', ')"
}

Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object {
  if ($keepInRepo -contains $_.Name) { return }
  if ($_.Extension -match '^\.(png|PNG)$') {
    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
    Invoke-GitQuiet rm -f --ignore-unmatch "assets/$($_.Name)" | Out-Null
  }
}

git status
$pending = git diff --cached --name-only
if (-not $pending) {
  Write-Host ""
  Write-Host "Nada novo para commitar (GitHub ja tem as 9 imagens ou arquivos identicos)."
  exit 0
}

if ((Invoke-GitQuiet commit -m "assets: publica 9 capturas da secao Por Dentro") -ne 0) {
  Write-Error "git commit falhou."
}
if ((Invoke-GitQuiet push -u origin $branch) -ne 0) {
  Write-Error "git push falhou."
}
Write-Host ""
Write-Host "OK - 9 imagens publicadas no GitHub ($branch)."
