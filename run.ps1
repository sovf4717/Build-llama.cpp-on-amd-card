git clone https://github.com/ggml-org/llama.cpp.git



$src = Join-Path $PSScriptRoot "Build.ps1"

$dst = Join-Path (Get-Location) "llama.cpp\Build.ps1"

Copy-Item $src $dst

Write-Host "Copied Build.ps1 to llama.cpp directory"

Write-Host "" -NoNewline
Write-Host "Starting build..." -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File (Join-Path (Get-Location) "llama.cpp\Build.ps1")
