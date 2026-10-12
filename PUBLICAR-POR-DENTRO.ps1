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

function Invoke-Git {
  param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  $out = & git @GitArgs 2>&1
  $code = $LASTEXITCODE
  $ErrorActionPreference = $prev
  return @{ Code = $code; Out = ($out | Out-String).Trim() }
}

function Find-AssetByBaseName {
  param([System.IO.FileInfo[]]$Files, [string[]]$BaseNames)
  foreach ($base in $BaseNames) {
    $hit = $Files | Where-Object { $_.BaseName -ieq $base } | Select-Object -First 1
    if ($hit) { return $hit }
  }
  return $null
}

function Ensure-CanonicalPngsOnDisk {
  param([System.IO.FileInfo[]]$AllFiles)
  foreach ($canonical in $expected.Keys) {
    $source = Find-AssetByBaseName -Files $AllFiles -BaseNames $expected[$canonical]
    if (-not $source) { continue }
    $dest = Join-Path $assetsDir $canonical
    $srcFull = [System.IO.Path]::GetFullPath($source.FullName)
    $destFull = [System.IO.Path]::GetFullPath($dest)
    if ($srcFull -ne $destFull) {
      Copy-Item -LiteralPath $source.FullName -Destination $dest -Force
    }
  }
}

function Stage-LocalPorDentroPngs {
  $files = Get-ChildItem -LiteralPath $assetsDir -File
  Ensure-CanonicalPngsOnDisk -AllFiles $files
  foreach ($canonical in $expected.Keys) {
    $path = Join-Path $assetsDir $canonical
    if (-not (Test-Path -LiteralPath $path)) { continue }
    $r = Invoke-Git add -f -- "assets/$canonical"
    if ($r.Code -ne 0) {
      Write-Error "git add falhou: assets/$canonical`n$($r.Out)"
    }
  }
}

function Align-BranchToOrigin {
  $targetRev = (git rev-parse $remote).Trim()
  if (-not $targetRev) { Write-Error "git rev-parse $remote falhou." }

  if (Test-Path (Join-Path $root ".git\MERGE_HEAD")) {
    $abort = Invoke-Git merge --abort
    if ($abort.Code -ne 0) { Write-Host "aviso: merge abort: $($abort.Out)" }
  }

  $current = git branch --show-current
  $onBranch = $current -eq $branch

  if (-not $onBranch) {
    $sw = Invoke-Git switch $branch
    if ($sw.Code -ne 0) {
      $force = Invoke-Git branch -f $branch $targetRev
      if ($force.Code -ne 0) { Write-Error "git branch -f falhou:`n$($force.Out)" }
      $sw2 = Invoke-Git switch $branch
      if ($sw2.Code -ne 0) {
        $sw3 = Invoke-Git switch -c $branch $targetRev
        if ($sw3.Code -ne 0) {
          Write-Error "Nao foi possivel mudar para ${branch}:`n$($sw.Out)`n$($sw2.Out)`n$($sw3.Out)"
        }
      }
    }
  }

  $head = (git rev-parse HEAD 2>$null).Trim()
  if ($head -eq $targetRev) {
    Write-Host "  Branch ja esta em $targetRev"
    return
  }

  $reset = Invoke-Git reset --mixed $targetRev
  if ($reset.Code -eq 0) { return }

  Write-Host "  reset --mixed falhou, tentando alinhar so o ponteiro do branch..."
  Write-Host $reset.Out

  $bf = Invoke-Git branch -f $branch $targetRev
  if ($bf.Code -ne 0) { Write-Error "git branch -f falhou:`n$($bf.Out)" }

  $sw = Invoke-Git switch $branch
  if ($sw.Code -ne 0) { Write-Error "git switch falhou:`n$($sw.Out)" }

  $reset2 = Invoke-Git reset --mixed $targetRev
  if ($reset2.Code -ne 0) {
    Write-Error "git reset --mixed falhou:`n$($reset2.Out)"
  }
}

Set-Location $root
$assetsDir = Join-Path $root "assets"
if (-not (Test-Path $assetsDir)) {
  Write-Error "Pasta nao encontrada: $assetsDir"
}

Write-Host "1/5 git fetch..."
$r = Invoke-Git fetch origin
if ($r.Code -ne 0) { Write-Error "git fetch falhou:`n$($r.Out)" }

if (-not (git rev-parse --verify $remote 2>$null)) {
  Write-Error "Remoto nao encontrado: $remote"
}

Write-Host "2/5 Registrando PNGs locais (git add -f) antes de alinhar branch..."
Stage-LocalPorDentroPngs

Write-Host "3/5 Atualizando scripts/..."
$chk = Invoke-Git checkout $remote -- scripts/
if ($chk.Code -ne 0) {
  Write-Host "  aviso checkout scripts: $($chk.Out)"
}

Write-Host "4/5 Alinhando branch com o GitHub (sem git pull)..."
Align-BranchToOrigin

Write-Host "5/5 Publicando 9 imagens..."
Stage-LocalPorDentroPngs

git ls-files "assets/*" | ForEach-Object {
  $name = Split-Path $_ -Leaf
  if ($keepInRepo -contains $name) { return }
  if ($name -match '\.(png|PNG)$') {
    Invoke-Git rm -f --ignore-unmatch $_ | Out-Null
  }
}

$allFiles = Get-ChildItem -LiteralPath $assetsDir -File
$missing = @()
foreach ($canonical in $expected.Keys) {
  if (-not (Test-Path -LiteralPath (Join-Path $assetsDir $canonical))) {
    $missing += $canonical
  } else {
    $r = Invoke-Git add -f -- "assets/$canonical"
    if ($r.Code -ne 0) { Write-Error "git add falhou: assets/$canonical" }
  }
}

if ($missing.Count) {
  Write-Host ""
  Write-Host "Em assets/:"
  Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object { Write-Host "  - $($_.Name)" }
  Write-Error "Faltam $($missing.Count) PNG. Esperado: $($expected.Keys -join ', ')"
}

Get-ChildItem -LiteralPath $assetsDir -File | ForEach-Object {
  if ($keepInRepo -contains $_.Name) { return }
  if ($_.Extension -match '^\.(png|PNG)$') {
    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
    Invoke-Git rm -f --ignore-unmatch "assets/$($_.Name)" | Out-Null
  }
}

git status
$pending = git diff --cached --name-only
if (-not $pending) {
  Write-Host ""
  Write-Host "Nada novo para commitar (GitHub ja tem as 9 imagens ou arquivos identicos)."
  exit 0
}

$r = Invoke-Git commit -m "assets: publica 9 capturas da secao Por Dentro"
if ($r.Code -ne 0) { Write-Error "git commit falhou:`n$($r.Out)" }

$r = Invoke-Git push -u origin $branch
if ($r.Code -ne 0) { Write-Error "git push falhou:`n$($r.Out)" }

Write-Host ""
Write-Host "OK - 9 imagens publicadas no GitHub ($branch)."
