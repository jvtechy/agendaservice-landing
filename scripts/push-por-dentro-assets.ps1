# Publica exatamente 9 capturas em assets/ no branch da landing (raiz do repo).
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$branch = "cursor/landing-planos-por-dentro-8972"

# Nomes oficiais em assets/ (ASCII: SERVICOS, sem cedilha)
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

$assetsDir = Join-Path $root "assets"
if (-not (Test-Path $assetsDir)) {
  Write-Error "Pasta nao encontrada: $assetsDir"
}

Set-Location $root
if ((Invoke-GitQuiet fetch origin) -ne 0) {
  Write-Error "git fetch origin falhou."
}

if (-not (git rev-parse --verify "origin/$branch" 2>$null)) {
  Write-Error "Branch remoto nao encontrado: origin/$branch"
}

$current = git branch --show-current
if ($current -ne $branch) {
  if ((Invoke-GitQuiet switch $branch) -ne 0) {
    if ((Invoke-GitQuiet switch -c $branch "origin/$branch") -ne 0) {
      Write-Error "Nao foi possivel mudar para o branch $branch"
    }
  }
}

# Nao use git pull / merge: PNGs locais nao rastreados (mesmo nome do remoto) abortam o merge.
Write-Host "Alinhando com origin/$branch (mantem seus arquivos em assets/)..."
if ((Invoke-GitQuiet reset --mixed "origin/$branch") -ne 0) {
  Write-Error "git reset --mixed falhou."
}

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
  $baseNames = $expected[$canonical]
  $source = Find-AssetByBaseName -Files $allFiles -BaseNames $baseNames
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
    Write-Error "git add falhou para assets/$canonical"
  }
}

if ($missing.Count) {
  Write-Host ""
  Write-Host "Arquivos em assets/:"
  Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object { Write-Host "  - $($_.Name)" }
  Write-Error "Faltam $($missing.Count) imagem(ns). Esperado: $($expected.Keys -join ', ')"
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
  Write-Host "Nada novo para commitar."
  exit 0
}

if ((Invoke-GitQuiet commit -m "assets: publica 9 capturas da secao Por Dentro") -ne 0) {
  Write-Error "git commit falhou."
}
if ((Invoke-GitQuiet push -u origin $branch) -ne 0) {
  Write-Error "git push falhou."
}
Write-Host "OK - 9 imagens publicadas no GitHub (branch $branch)."
