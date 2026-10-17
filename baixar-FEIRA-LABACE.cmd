@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\baixar-FEIRA-LABACE.ps1" %*
if errorlevel 1 exit /b 1
endlocal
