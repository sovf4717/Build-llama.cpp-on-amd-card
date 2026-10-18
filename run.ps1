# 若 llama.cpp 源码不存在则 clone，存在则跳过
if (-not (Test-Path "llama.cpp")) {
    git clone https://github.com/ggml-org/llama.cpp.git
} else {
    Write-Host "llama.cpp 已存在，跳过 clone" -ForegroundColor Yellow
}

# 若 Build.ps1 已在 llama.cpp 目录中则直接运行，否则复制过去再运行
$dst = Join-Path (Get-Location) "llama.cpp\Build.ps1"
if (Test-Path $dst) {
    Write-Host "Build.ps1 已在 llama.cpp 目录中，直接运行" -ForegroundColor Yellow
} else {
    $src = Join-Path $PSScriptRoot "Build.ps1"
    Copy-Item $src $dst
    Write-Host "Copied Build.ps1 to llama.cpp directory"
}

Write-Host "" -NoNewline
Write-Host "Starting build..." -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File $dst
