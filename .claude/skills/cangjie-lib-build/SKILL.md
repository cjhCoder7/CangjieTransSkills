---
name: cangjie-lib-build
description: "编译纯仓颉 cjpm 库项目（非 HarmonyOS 应用）。自动检测仓颉 SDK，执行 cjpm build 与 cjpm test。在库目录下说编译/构建/build/打包/跑测试时使用"
allowed-tools: Bash(loopx *), Bash(python3 *), Bash(ls *), Bash(cat *)
argument-hint: "[lib-path] [-v 8k|15k] [--no-test] [--clean]"
---

# 仓颉 cjpm 库构建

## LoopX 管理（强制）

读取之外的构建或测试必须先加载 `cangjie-loopx-management`。若调用来自库翻译流程，复用当前 Goal 和构建 Todo；若用户独立调用 `/cangjie-lib-build`，自动创建或恢复一个有界构建/测试 Goal。

执行前读取 `quota should-run`。构建类型、测试结果、产物和失败摘要必须写回当前 Todo；脚本启动或部分产物生成不代表完成。

执行：

```bash
python3 ${CLAUDE_SKILL_DIR}/lib_build.py $ARGUMENTS
```

## 前置检查（构建前必须完成）

| # | 检查项 | 检查方式 | 未通过时 |
|---|-------|---------|---------|
| 1 | 项目类型是 cjpm 库 | 工程根含 `cjpm.toml`，无 `entry/` | 若是 HarmonyOS 应用 → 改用 `/build` |
| 2 | 仓颉 SDK 可用 | `~/.cangjie-sdk/` 存在或 `.env` 中已配置 | 提示用户安装仓颉 SDK |
| 3 | 构建版本确认 | `.openvk-version` 或 `-v` 参数 | 默认使用 `8k` |
| 4 | 是否需要运行测试 | 检查 `src/*_test.cj`、`tests/` 或 `cjpm.toml` 中 `[test]` 段 | 无测试则跳过；用户可加 `--no-test` |

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

## 配置说明

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
6. **经验回写**：排查并解决了非显而易见的构建问题后，通用问题写入 `evolution/cangjie/`，库工程化问题（包循环、导出不一致等）写入 `cangjie-translate-lib/experience/`

## LoopX 结果写回

- 成功：记录实际执行的输出类型、`cjpm build` 结果、测试总数/结果和 `target/` 下产物相对路径，验证后完成 Todo。
- 失败：保留 Todo 未完成，记录失败阶段、首个可操作错误和下一动作；使用 `--no-test` 隔离问题时不得把“只构建成功”误报为“测试通过”。
- SDK 缺失：创建或维持用户 Gate，与代码编译失败分开记录。
- 非显而易见修复只有在重新构建或测试通过后才写入经验库，并在 Todo 中引用对应经验文件。
