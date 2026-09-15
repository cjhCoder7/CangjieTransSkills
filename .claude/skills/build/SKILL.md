---
name: build
description: "编译构建仓颉 HarmonyOS 应用，执行 ohpm 依赖安装、仓颉资源同步和 HAP 包打包。用户说编译、构建、build、打包时触发"
allowed-tools: Bash(loopx *), Bash(python3 *), Bash(ls *), Bash(cat *)
argument-hint: "[-v 8k|15k]"
---

# 仓颉 HarmonyOS 应用编译构建

## LoopX 管理（强制）

读取之外的构建必须先加载 `cangjie-loopx-management`。若构建来自翻译流程，复用当前 Goal 和构建 Todo；若用户独立调用 `/build`，自动创建或恢复一个有界构建 Goal，不要求用户预先执行 `/loopx`。

执行前读取 `quota should-run`，只在当前构建 Todo 获准时运行。构建结果、HAP 路径和错误摘要必须写回；不能仅凭脚本已运行就完成 Todo。

执行编译构建：

```bash
python3 ${CLAUDE_SKILL_DIR}/build.py $ARGUMENTS
```

## 前置检查（构建前必须完成）

| # | 检查项 | 检查方式 | 未通过时 |
|---|-------|---------|---------|
| 1 | 项目类型是 HarmonyOS 应用 | 工程根含 `entry/` + `module.json5` | 若是 cjpm 库 → 改用 `/cangjie-lib-build` |
| 2 | `.env` 中 `DEVECO_HOME` 已配置 | 读取 `.env` 文件 | 提示用户补充，给出平台典型值 |
| 3 | 仓颉 SDK 可用 | `.env` 中配置或 `~/.cangjie-sdk/` 存在 | 提示用户安装 SDK |
| 4 | 构建版本确认 | 检查 `.openvk-version` 或用户传 `-v` 参数 | 默认使用 `8k` |

## 构建流程

脚本按顺序执行三个阶段：
1. **安装依赖** — `ohpm install --all`
2. **同步仓颉资源** — `hvigorw SyncCangjieResource`
3. **编译打包** — `hvigorw assembleHap`

## 配置说明

- `.env` 中 `DEVECO_HOME` 和 `CANGJIE_SDK_HOME-*` 的配置详见 `base-skill` 平台典型值
- `.openvk-version` 文件指定构建版本（`8k` 或 `15k`，默认 `8k`），也可通过 `-v` 参数覆盖

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
6. **经验回写**：排查并解决了非显而易见的编译问题后，将经验写入 `evolution/cangjie/` 对应主题文件（格式参见 `evolution/SKILL.md`）

## LoopX 结果写回

- 成功：记录三个阶段的真实结果和 HAP 相对路径，验证产物存在后完成构建 Todo。
- 失败：保留 Todo 未完成，记录失败阶段、首个可操作错误、已验证排查结果和下一动作；原始构建日志留在忽略目录。
- 环境缺失：创建或维持具体用户 Gate，不把 `DEVECO_HOME`、SDK 或工具链缺失记成代码失败。
- 修复后重跑：只有新的真实构建成功才能替代旧失败证据；经验回写必须发生在方案验证成功之后。
