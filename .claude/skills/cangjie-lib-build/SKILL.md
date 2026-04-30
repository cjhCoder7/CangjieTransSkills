---
name: cangjie-lib-build
description: "编译纯仓颉 cjpm 库项目（非 HarmonyOS 应用）。自动检测仓颉 SDK，执行 cjpm build 与 cjpm test。在库目录下说编译/构建/build/打包/跑测试时使用"
allowed-tools: Bash(python3 *), Bash(ls *), Bash(cat *)
argument-hint: "[lib-path] [-v 8k|15k] [--no-test] [--clean]"
---

# 仓颉 cjpm 库构建

执行：

```bash
python3 ${CLAUDE_SKILL_DIR}/lib_build.py $ARGUMENTS
```

## 适用范围

**仅适用于纯仓颉库项目（cjpm 包），不适用于 HarmonyOS 应用。**

判定规则：

| 工程根含 | 应使用 |
|---------|--------|
| `cjpm.toml`，无 `entry/` / `module.json5` / `app.json5` | **本 skill** `/cangjie-lib-build` |
| `entry/` + `module.json5` + `app.json5` | `/build`（应用级） |

库项目可由 `/cangjie-translate-lib` 翻译产出；本 skill 是其 Phase 9（构建验证）的执行手段，也可独立使用。

## 构建流程

脚本按顺序执行：

1. **定位库根** — 由 `[lib-path]` 解析（默认当前目录），必须含 `cjpm.toml`，否则退出码 2
2. **加载 .env** — 优先读库根下的 `.env`，回退到 CangjieTransSkills 项目根的 `.env`；都没有则全靠自动检测
3. **检测仓颉 SDK** — 顺序：`.env` 中 `CANGJIE_SDK_HOME-<version>` → `CANGJIE_SDK_HOME` → `~/.cangjie-sdk/` 自动扫描
4. **加载 envsetup** — `source <sdk>/build-tools/envsetup.sh`（Windows 用 `.ps1`），让 `cjpm`/`cjc` 进入 PATH
5. **可选 `cjpm clean`** — 加 `--clean` 触发；失败仅警告，继续构建
6. **`cjpm build`** — 依次以 `static` → `dynamic` → `executable`（仅当 `src/main.cj` 存在时）构建全部产物，每次构建后恢复原始 `output-type`
7. **验证产物** — 扫描 `target/release/` 下的二进制文件（`.a`/`.dylib`/`.so`/`.dll`/`.cjo`/可执行文件）
8. **`cjpm test`** — 在库根含 `src/*_test.cj`、`tests/` 目录或 `cjpm.toml` 内有 `[test]` / `[[test]]` 段时执行；加 `--no-test` 跳过

## 与 `/build` 的关键差异

| 维度 | `/build`（应用级） | `/cangjie-lib-build`（库级） |
|------|------------------|---------------------------|
| 工具链 | ohpm + hvigorw + node + Java | cjpm + cjc |
| `DEVECO_HOME` | **必填** | **不需要** |
| 仓颉 SDK | 需要 | 需要 |
| 工作目录 | 项目根（脚本向上 4 级定位） | 库根（参数指定或当前目录） |
| 产物 | `entry/build/.../*.hap` | `<lib>/target/`（`.cjo` / `.a` / `.dylib` / `.so` / 可执行文件） |
| "运行" | 装 hap 到设备/模拟器 | 有 `main.cj` 时可执行；否则以 `cjpm test` 验证 |

## 前置配置

**最小可用配置：装好 `~/.cangjie-sdk/` 即可，`.env` 可空。**

如需锁定 SDK 路径或多版本切换，在 `.env` 中：

```
# 通用路径（所有版本回退）
CANGJIE_SDK_HOME=/Users/xxx/.cangjie-sdk/6.0/cangjie

# 版本专用路径（优先级高于通用路径）
CANGJIE_SDK_HOME-8k=/Users/xxx/.cangjie-sdk/6.0/cangjie
CANGJIE_SDK_HOME-15k=/Users/xxx/.cangjie-sdk/6.0/compatibility-sdk-xxx/compatibility
```

`.openvk-version` 文件（值 `8k` 或 `15k`）可锁定默认版本；未指定时按 `8k`。`.env` 与 `.openvk-version` 都按"先库根、后项目根"的顺序查找。

## 常用调用

```bash
# 当前目录就是库根
python3 ${CLAUDE_SKILL_DIR}/lib_build.py

# 指定库路径
python3 ${CLAUDE_SKILL_DIR}/lib_build.py /path/to/my-lib

# 跳过测试
python3 ${CLAUDE_SKILL_DIR}/lib_build.py --no-test

# 切版本 + 先清理再编
python3 ${CLAUDE_SKILL_DIR}/lib_build.py -v 15k --clean
```

## 失败排查

1. `未找到 cjpm.toml` → 路径不对；用 `ls` 确认库根目录
2. `未找到对应版本的仓颉 SDK` → `~/.cangjie-sdk/` 下无对应版本，或 `.env` 中 `CANGJIE_SDK_HOME` / `CANGJIE_SDK_HOME-<version>` 路径错
3. `未在 SDK 中找到 cjpm 可执行文件` → SDK 安装不全；查 `<sdk>/bin/cjpm` 是否存在
4. `cjpm build` 编译错误 → 错误信息含 `.cj` 文件路径与行号；先查 `evolution/cangjie/syntax.md`，再查 `cangjie-translate-lib/experience/`
5. `cjpm test` 失败 → 测试自身问题；用 `--no-test` 隔离再单独排查
