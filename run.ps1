# 初始化子模块：若 llama.cpp 尚未初始化（目录为空或缺少 src）则 init
if (-not (Test-Path "llama.cpp\src")) {
    Write-Host "初始化 llama.cpp 子模块..." -ForegroundColor Cyan
    git submodule update --init --recursive
} else {
    Write-Host "llama.cpp 子模块已初始化，跳过" -ForegroundColor Yellow
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
