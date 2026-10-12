@echo off
cd /d "%~dp0"
echo Baixando PUBLICAR-POR-DENTRO.ps1 do GitHub (se precisar)...
git fetch origin
if errorlevel 1 (
  echo git fetch falhou.
  pause
  exit /b 1
)
if not exist "PUBLICAR-POR-DENTRO.ps1" (
  git show origin/cursor/landing-planos-por-dentro-8972:PUBLICAR-POR-DENTRO.ps1 > "%TEMP%\PUBLICAR-POR-DENTRO.ps1"
  if errorlevel 1 (
    echo Nao foi possivel baixar o script. Verifique a internet e o git fetch.
    pause
    exit /b 1
  )
  copy /y "%TEMP%\PUBLICAR-POR-DENTRO.ps1" "PUBLICAR-POR-DENTRO.ps1" >nul
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PUBLICAR-POR-DENTRO.ps1"
if errorlevel 1 pause
exit /b %errorlevel%
