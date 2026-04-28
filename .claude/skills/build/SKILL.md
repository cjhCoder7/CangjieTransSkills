---
name: build
description: "编译构建仓颉 HarmonyOS 应用，执行 ohpm 依赖安装、仓颉资源同步和 HAP 包打包。用户说编译、构建、build、打包时触发"
allowed-tools: Bash(python3 *), Bash(ls *), Bash(cat *)
argument-hint: "[-v 8k|15k]"
---

# 仓颉 HarmonyOS 应用编译构建

执行编译构建：

```bash
python3 ${CLAUDE_SKILL_DIR}/build.py $ARGUMENTS
```

## 构建流程

脚本按顺序执行三个阶段：
1. **安装依赖** — `ohpm install --all`
2. **同步仓颉资源** — `hvigorw SyncCangjieResource`
3. **编译打包** — `hvigorw assembleHap`

## 前置配置

项目根目录需要 `.env` 文件：
```
DEVECO_HOME=/Applications/DevEco-Studio.app/Contents
```

仓颉 SDK 默认自动检测 `~/.cangjie-sdk/`，可在 `.env` 中覆盖：
```
CANGJIE_SDK_HOME-8k=/path/to/cangjie
```

`.openvk-version` 文件指定构建版本（`8k` 或 `15k`，默认 `8k`）。

## 常用参数

```bash
python3 ${CLAUDE_SKILL_DIR}/build.py -v 8k     # 8k 版本
python3 ${CLAUDE_SKILL_DIR}/build.py -v 15k    # 15k 版本
```

## 产物位置

```
entry/build/default/outputs/default/entry-default-unsigned.hap
```

## 编译失败排查

1. 仓颉编译错误会显示源文件路径和行号，定位到具体 `.cj` 文件
2. 查阅 `evolution` skill（`cangjie/syntax.md`、`cangjie/arkui.md`、`cangjie/state.md`）中的已知问题
3. `macro evaluation has failed` → 检查 `@Component`/`@Observed` 等宏的使用约束
4. 类型不匹配 → 注意 `Int32` vs `Int64`、`Array` vs `ArrayList` 等差异
5. 环境问题 → 确认 `.env` 中 `DEVECO_HOME` 路径正确
