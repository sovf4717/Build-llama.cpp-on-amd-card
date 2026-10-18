# Build-llama.cpp-on-amd-card
Build llama.cpp with HIP/ROCm backend on AMD GPUs (Windows).



[Chinese documentation](zh_readme.md) | 中文文档



## Requirements



- Windows 10/11

- AMD GPU (gfx1200 / RX 9060 XT in this setup)

- ROCm SDK for Windows (via Python package `rocm-sdk`):

  - `_rocm_sdk_core` - Clang compiler + HIP runtime

  - `_rocm_sdk_libraries` - hipblas/rocblas/rocsolver etc.

- Visual Studio 2022 Build Tools (for MSVC linker + rc.exe)

- CMake (with Ninja generator)

- Git



## File layout



```

Build-llama.cpp-on-amd-card/

  run.ps1        - one-shot: clone + copy build script + build

  Build.ps1      - CMake configure + build + copy runtime DLLs

```r


## Usage



```powershellr
cd E:\Build-llama.cpp-on-amd-card

powershell -ExecutionPolicy Bypass -File run.ps1

```



This will:

1. Clone llama.cpp

2. Copy Build.ps1 into the clone

3. Run the build automatically



After build, binaries are in `llama.cpp\build\bin`:

- `llama-cli.exe`

- `llama-server.exe`

- `llama-bench.exe`

- `ggml-hip.dll` (HIP backend)

- All ROCm runtime DLLs



## Build.ps1 prerequisites (hardcoded paths)



| Dependency | Expected path |

|---|---|

| ROCm SDK core | `E:\Python312\Lib\site-packages\_rocm_sdk_core` |

| ROCm SDK libs | `E:\Python312\Lib\site-packages\_rocm_sdk_libraries` |

| ROCm cmake configs | `E:\llama.cpp\.cecli\temp\rocm-pkgs` |

| MSVC Build Tools | `E:\Microsoft Visual Studio\2022\BuildTools` |

| CMake | `E:\cmake-4.4.2-windows-x86_64` |

| Git | `E:\Git` |



Adjust paths in Build.ps1 if your installation differs.



## Notes



- GPU target (gfx1200) is determined by the ROCm SDK's pre-compiled device bitcode, not by a CMake flag. To build for a different GPU arch, install the matching ROCm SDK.

- Build.ps1 does a clean build every time (removes `build/` directory).

- The `RERUN_CMAKE` rule is stripped from build.ninja to prevent a Ninja dirty-manifest loop caused by `.git/index` timestamp changes during CMake re-runs.
