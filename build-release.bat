@echo off
setlocal
REM Wrapper para executar o script PowerShell de build Release
powershell -ExecutionPolicy Bypass -File "%~dp0build-release.ps1" %*
endlocal