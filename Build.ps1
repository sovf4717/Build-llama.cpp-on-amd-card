# HIP env vars from hipconfig (Devel module has no __file__, falls back to core)
$env:ROCM_PATH         = "E:\Python312\Lib\site-packages\_rocm_sdk_core"
$env:HIP_PATH          = "E:\Python312\Lib\site-packages\_rocm_sdk_core"
$env:HIPCXX            = "E:\Python312\Lib\site-packages\_rocm_sdk_core\lib\llvm\bin"
$env:HIP_DEVICE_LIB_PATH = "E:\Python312\Lib\site-packages\_rocm_sdk_core\lib\llvm\amdgcn\bitcode"
$env:HIP_PLATFORM      = "amd"
$env:PATH = "E:\Python312\Lib\site-packages\_rocm_sdk_core\bin;E:\Python312\Lib\site-packages\_rocm_sdk_core\lib\llvm\bin;" + $env:PATH

# MSVC environment (vcvars64) for linker and rc.exe, import via temp batch
# to avoid native command quoting issues with the spaced path
$vcvars = 'E:\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat'
$bat = Join-Path ([System.IO.Path]::GetTempPath()) "llama-vcvars_$PID.bat"
Set-Content -Path $bat -Value "call `"$vcvars`"`r`nset"
cmd /c $bat | ForEach-Object { if ($_ -match '^(.*?)=(.*)$') { Set-Item -Force "Env:$($matches[1])" $matches[2] } }
Remove-Item $bat -Force

# clean build: remove build folder before every build

Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue

Write-Host "Removed build folder, starting fresh build"



$cmake = "E:\cmake-4.4.2-windows-x86_64\bin\cmake.exe"

$configureArgs = @(

    '-S', '.',

    '-B', 'build',

    '-G', 'Ninja',

    '-DCMAKE_BUILD_TYPE=Release',

    '-DCMAKE_C_COMPILER=E:\Python312\Lib\site-packages\_rocm_sdk_core\lib\llvm\bin\clang.exe',

    '-DCMAKE_CXX_COMPILER=E:\Python312\Lib\site-packages\_rocm_sdk_core\lib\llvm\bin\clang++.exe',

    '-DCMAKE_PREFIX_PATH=E:\Python312\Lib\site-packages\_rocm_sdk_core;E:\llama.cpp\.cecli\temp\rocm-pkgs',

    '-Dhip_DIR=E:\llama.cpp\.cecli\temp\rocm-pkgs',

    '-Dhipblas_DIR=E:\llama.cpp\.cecli\temp\rocm-pkgs',

    '-Drocblas_DIR=E:\llama.cpp\.cecli\temp\rocm-pkgs',

    '-DCMAKE_CXX_FLAGS=-Wno-cast-qual',


    '-DGGML_HIP=ON',

    '-DGGML_CCACHE=OFF'

)

$rcExe = Get-Command rc -ErrorAction SilentlyContinue

if (-not $rcExe) { throw "rc.exe not found after vcvars import" }

$env:RC = $rcExe.Source -replace '\\\\', '\\'

& $cmake @configureArgs

if ($LASTEXITCODE -ne 0) { exit 1 }



# remove RERUN_CMAKE section from build.ninja to stop the dirty-manifest loop
# (root cause: .git/index is a dep; CMake re-runs update it, triggering infinite re-runs)
$bf = "build\build.ninja"
if (Test-Path $bf) {
    $lines = [System.IO.File]::ReadAllLines($bf)
    $result = [System.Collections.Generic.List[string]]::new()
    $skipSection = $false
    foreach ($line in $lines) {
        if ($line -match '^# Re-run CMake if any of its inputs changed\.$') {
            $skipSection = $true
            $result.Add("# auto-regeneration disabled")
            continue
        }
        if ($skipSection -and $line -match '^###') { $skipSection = $false }
        if ($skipSection) { continue }
        if ($line -match '^rule RERUN_CMAKE') { continue }
        $result.Add($line)
    }
    [System.IO.File]::WriteAllLines($bf, $result)
}

& "E:\cmake-4.4.2-windows-x86_64\bin\cmake.exe" --build build --config Release
if ($LASTEXITCODE -ne 0) { exit 1 }

# copy ROCm runtime DLLs to build\bin so binaries can run standalone
$rocmLibs = "E:\Python312\Lib\site-packages\_rocm_sdk_libraries\bin"
$rocmBin  = "E:\Python312\Lib\site-packages\_rocm_sdk_core\bin"
$binDir   = "build\bin"
if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Force -Path $binDir | Out-Null }
Copy-Item "$rocmLibs\*.dll" $binDir -Force
Copy-Item "$rocmBin\*.dll" $binDir -Force
Write-Host "ROCm runtime DLLs copied to $binDir"
powershell