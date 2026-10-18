# Build-llama.cpp-on-amd-card



在 Windows 上使用 HIP/ROCm 后端构建 llama.cpp，适用于 AMD GPU。



[English documentation](README.md) | 英文文档



## 前置要求



- Windows 10/11

- AMD GPU（本环境为 gfx1200 / RX 9060 XT）

- ROCm SDK for Windows（通过 Python 包 `rocm-sdk` 安装）：

  - `_rocm_sdk_core` - Clang 编译器 + HIP 运行时

  - `_rocm_sdk_libraries` - hipblas/rocblas/rocsolver 等

- Visual Studio 2022 Build Tools（提供 MSVC linker + rc.exe）

- CMake（带 Ninja 生成器）

- Git



## 文件结构



```

Build-llama.cpp-on-amd-card/

  run.ps1        - 一键执行：clone + 复制构建脚本 + 构建

  Build.ps1      - CMake 配置 + 编译 + 复制运行时 DLL

```



## 使用方法



```powershell

cd E:\Build-llama.cpp-on-amd-card

powershell -ExecutionPolicy Bypass -File run.ps1

```



该脚本会自动执行：

1. 克隆 llama.cpp

2. 将 Build.ps1 复制到克隆目录

3. 自动运行构建



构建完成后，可执行文件位于 `llama.cpp\build\bin`：

- `llama-cli.exe`

- `llama-server.exe`

- `llama-bench.exe`

- `ggml-hip.dll`（HIP 后端）

- 所有 ROCm 运行时 DLL



## Build.ps1 路径依赖（硬编码）



| 依赖项 | 预期路径 |

|---|---|

| ROCm SDK core | `E:\Python312\Lib\site-packages\_rocm_sdk_core` |

| ROCm SDK libs | `E:\Python312\Lib\site-packages\_rocm_sdk_libraries` |

| ROCm cmake 配置 | `E:\llama.cpp\.cecli\temp\rocm-pkgs` |

| MSVC Build Tools | `E:\Microsoft Visual Studio\2022\BuildTools` |

| CMake | `E:\cmake-4.4.2-windows-x86_64` |

| Git | `E:\Git` |



如果你的安装路径不同，请修改 Build.ps1 中的对应路径。



## 注意事项



- GPU 目标架构（gfx1200）由 ROCm SDK 中预编译的 device bitcode 决定，而非 CMake 参数。如需构建其他架构（如 gfx1100），需安装对应架构的 ROCm SDK。

- Build.ps1 每次都是全新构建（删除 `build/` 目录）。

- 构建前会从 build.ninja 中移除 `RERUN_CMAKE` 规则，以防止 Ninja 因 `.git/index` 时间戳变化导致的 dirty-manifest 死循环。