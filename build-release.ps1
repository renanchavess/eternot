Param(
  [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "[build-release] Inicializando ambiente e preparando build Release..."

# Localiza vcvars64.bat do VS Build Tools 2022
$pf86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
$pf   = [Environment]::GetEnvironmentVariable('ProgramFiles')
$vcvarsCandidates = @(
  (Join-Path $pf86 'Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'),
  (Join-Path $pf   'Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat')
)

$vcvarsPath = $vcvarsCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $vcvarsPath) {
  throw "vcvars64.bat não encontrado. Instale o Visual Studio Build Tools 2022 com o workload 'Desktop development with C++'."
}

# Limpa build directory opcionalmente
if ($Clean) {
  Write-Host "[build-release] Limpando 'build\\windows-release'..."
  Remove-Item -Recurse -Force (Join-Path $PSScriptRoot 'build\windows-release') -ErrorAction SilentlyContinue
}

# Comandos CMake
$configureCmd = "cmake --preset windows-release"
$buildCmd     = "cmake --build build/windows-release --config Release"

Write-Host "[build-release] Usando vcvars: $vcvarsPath"
Write-Host "[build-release] Configurando e compilando (Release)..."

# Execute tudo no mesmo processo CMD para preservar variáveis de ambiente do vcvars
& cmd /c "`"$vcvarsPath`" && $configureCmd && $buildCmd"
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
  throw "Build falhou com código $exitCode."
}

# Verifica artefato
$exePath = Join-Path $PSScriptRoot "build\windows-release\bin\crystalserver.exe"
if (Test-Path $exePath) {
  $fi = Get-Item $exePath
  Write-Host "[build-release] Build concluído: $($fi.FullName) (tamanho: $([math]::Round($fi.Length/1MB,2)) MB)"
} else {
  Write-Warning "[build-release] Executável não encontrado em $exePath. Verifique a saída do CMake."
}

Write-Host "[build-release] Finalizado."