# Phase 03 物理编译器接线说明

## 一、最新结论（2026-03-27）

本轮已确认并打通 **Linux x86_64** 宿主机上的真实仓颉物理编译链。

关键结论：

- 可用 Linux SDK 资源已确认：`资源/cangjie-sdk-linux-x64-6.1.0.818.zip`
- 真实编译器可执行入口已确认：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc`
- 真实包管理器入口已确认：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm`
- `cjc --version` 可正常运行，说明不是伪入口，也不是平台不兼容二进制
- `hello.cj` 可被真实编译为 Linux ELF 可执行文件
- `hello_invalid.cj` 可返回带有**真实文件路径与行列号**的语法错误

这意味着：

- `scripts/verifier.py` 的 CompileChecker 已经具备接入真实物理编译器的条件；
- 当前流水线可以在 **真实编译 + dry-run 单测 / 行为检查** 模式下运行；
- 第二阶段后续若把真实仓颉候选 `.cj` 代码落盘，就可以直接进入“生成 → 真实编译 → 回传 stderr → Repair”闭环。

## 二、宿主机与 SDK 盘点

### 2.1 宿主机环境

- 宿主机：`Linux x86_64`
- 当前项目根目录：`/volume/wzhang/cky-workspace/my_projects/Cangjie`

### 2.2 Linux SDK 资源

- 源压缩包：`资源/cangjie-sdk-linux-x64-6.1.0.818.zip`
- 当前宿主绝对路径：`/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip`
- 推荐提取目录：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip`

其中，`/volume/wzhang/cky-workspace/my_projects/Cangjie/资源/cangjie-sdk-linux-x64-6.1.0.818.zip` 是当前 Linux `Staging-Core` 物理编译链的权威源资产；`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip` 则是面向 `cjc` / `cjpm` / runtime 接线的工作目录。

**注意：必须使用能保留符号链接的方式提取。**

本轮已验证：

- 使用 Python `zipfile` 直接提取会破坏部分 symlink，导致动态库占位文件失真；
- 使用系统 `unzip` 提取可保留 symlink，适合作为真实编译器工作目录。

### 2.3 真实入口

- SDK 根：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie`
- 编译器：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc`
- 包管理器：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm`
- 运行时库：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative`
- 标准库：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/modules/linux_x86_64_cjnative/std`
- LLVM 工具链：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/third_party/llvm/bin`
- LLVM 动态库：`artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/third_party/llvm/lib`

## 三、版本与运行时确认

### 3.1 `cjc --version`

已实测输出：

- `Cangjie Compiler: 1.1.0-beta.22 (cjnative)`
- `Target: x86_64-unknown-linux-gnu`

### 3.2 文件类型确认

已实测：

- `cjc` 为 `ELF 64-bit LSB pie executable, x86-64`
- `cjpm` 为 `ELF 64-bit LSB pie executable, x86-64`
- `opt` / `llc` 同样为 `ELF x86-64`

说明当前 SDK 与宿主机架构**完全匹配**。

## 四、接线时的关键兼容点

### 4.1 必须完整提取 `third_party/llvm`

早期失败的根因不是源码，也不是 `verifier.py`，而是 Linux SDK 工作目录只被“半提取”了，缺少：

- `build-tools/third_party/llvm/bin/opt`
- `build-tools/third_party/llvm/bin/llc`
- `build-tools/third_party/llvm/lib/libLLVM.so`

在缺失这些文件时，`cjc` 会报：

- `error: not found \`opt\` in the Cangjie installation, CANGJIE_HOME`

补全 `third_party/llvm` 后，该错误消失。

### 4.2 需要兼容 `modules` 布局

本轮还发现 `cjc` 会优先寻找：

- `<CANGJIE_HOME>/modules/linux_x86_64_cjnative`

而 SDK 实际标准库目录位于：

- `<CANGJIE_HOME>/build-tools/modules/linux_x86_64_cjnative`

因此需要兼容性布局之一：

- 创建软链：`cangjie/modules -> build-tools/modules`

后续已在 `scripts/verifier.py` 中加入兼容处理，尽量自动补齐该软链。

### 4.3 建议注入的环境变量

建议最少注入：

- `DEVECO_CANGJIE_PATH=<sdk_root>`
- `CANGJIE_HARMONY_SDK_PATH=<sdk_root>`
- `CANGJIE_HOME=<sdk_root>`
- `CANGJIE_PATH=<sdk_root>/modules`（或兼容后的 modules 路径）
- `PATH=<sdk_root>/build-tools/bin:<sdk_root>/build-tools/tools/bin:<sdk_root>/build-tools/third_party/llvm/bin:$PATH`
- `LD_LIBRARY_PATH=<runtime_lib>:<llvm_lib>:$LD_LIBRARY_PATH`

### 4.4 Artifact 元数据缺失时的 Graceful Degradation

`verifier.py` 现已固定采用“**元数据优先，物理状态兜底**”的判定策略，避免旧 artifact、最小化 smoke artifact 或上游临时漏字段时出现假性 `empty-candidate-file`。

判定顺序应为：

1. 若 `metadata.candidate_file_path` 缺失：直接报 `missing-candidate-file`；
2. 若 `candidate_file_path` 指向的物理文件不存在：直接报 `missing-candidate-file`；
3. 若 `candidate_bytes_written`（或兼容别名 `bytes_written`）存在：以“元数据字节数 + 物理文件大小”双重校验，任一为空都判 `empty-candidate-file`；
4. 若该字段缺失：不得直接按 `0` 处理，而必须回退到物理文件 `stat().st_size` 做 fallback 核验；
5. 只有在物理文件确实为空时，才允许触发 `empty-candidate-file` 硬拦截。

这条策略的目的不是纵容上游漏字段，而是确保下游验证器具备最小防御性，不会把“元数据不完整”误判成“候选代码为空”。

## 五、真实冒烟测试结果

### 5.1 测试输入

工作区：`artifacts/temp_workspace/phase03-physical-smoke-001`

样例文件：

- 合法样例：`artifacts/temp_workspace/phase03-physical-smoke-001/hello.cj`
- 非法样例：`artifacts/temp_workspace/phase03-physical-smoke-001/hello_invalid.cj`

### 5.2 合法样例结果

命令形态（简化后）：

```bash
cjc --diagnostic-format noColor -o hello_verify_bin hello.cj
```

结果：

- 成功生成：`artifacts/temp_workspace/phase03-physical-smoke-001/hello_verify_bin`
- 文件类型：Linux ELF 可执行文件
- 在补充 `LD_LIBRARY_PATH` 后成功运行，输出：`hello from cangjie`

### 5.3 非法样例结果

非法样例内容故意制造了参数列表语法错误。

真实编译器 stderr 已成功返回类似信息：

- `hello_invalid.cj:3:6`
- `expected a argument name after '(' in parameter list, found ':'`

这证明：

- 真实 `cjc` 已经进入语法分析阶段；
- `scripts/verifier.py` 已能正确抓取物理 stderr；
- 行号与列号可以直接回灌到 Repair 流程。

### 5.4 旧 Artifact 兼容性回归结果

在 `2026-03-30` 的兼容性修复后，以下场景已被明确区分：

- 旧版 `hello.artifact.json` 缺失 `candidate_bytes_written`，但 `hello.cj` 物理文件非空时，`verifier.py` 会自动回退到物理文件大小检查，并继续进入真实编译；
- 若物理文件本身为空，即使元数据缺失，也仍然会被拦截为 `empty-candidate-file`；
- 因此，`empty-candidate-file` 现在只代表“候选文件物理上为空”或“上游显式报告写入 0 字节”，不再代表“某个历史 artifact 少写了元数据字段”。

## 六、对 `verifier.py` 的落地要求

本轮验证后，`scripts/verifier.py` 的真实接线策略应固定为：

1. 默认使用真实可执行的单文件编译命令模板：
   - `cjc --diagnostic-format noColor --output-type staticlib -o {attempt_dir}/candidate_output {candidate_file_path}`
2. 自动注入：
   - `compiler_home`
   - `runtime_lib_path`
   - LLVM 动态库路径
   - 工具链 PATH
3. 在必要时自动补齐：
   - `cangjie/modules -> build-tools/modules`
4. 捕获并回写：
   - `stdout`
   - `stderr`
   - `returncode`
   - 带文件行号的诊断摘要
5. 所有真实 subprocess 必须设置 timeout，避免卡死流水线。
6. 遵守一条明确的上下游契约：
   - **上游生成器**（如 translator artifact builder、workspace writer）应尽可能保证 `candidate_file_path`、`workspace_dir`、`attempt_dir`、`candidate_bytes_written` 等元数据完整；
   - **下游验证器**（`verifier.py`）不得把“元数据缺失”直接等价为“候选为空”，而必须降级到物理文件状态核验；
   - 只有当物理文件不存在、物理文件确实为空，或上游显式写入 `candidate_bytes_written=0` 时，才允许命中空候选硬拦截。

## 七、当前阶段仍未打通的部分

已经打通：

- 真实编译器启动
- 真实源码解析
- 真实 ELF 产物生成
- 真实语法报错抓取
- `verifier.py` 真实 compile 阶段闭环

暂未打通：

- `cjpm test` 的真实项目级单测链路
- 真实业务模块的仓颉成功翻译编译
- HarmonyOS 模拟器 / 真机运行验证

因此当前最合理的执行模式是：

- `Translate / Review`：真实 LLM
- `Compile`：真实 `cjc`
- `UnitTest / Behavior`：先保留 dry-run 或 mock

## 八、推荐命令模板

### 8.1 直接调用 `verifier.py`

```bash
python scripts/verifier.py   --tu-json artifacts/temp_workspace/phase03-physical-smoke-001/hello.tu.json   --artifact-json artifacts/temp_workspace/phase03-physical-smoke-001/hello.artifact.json   --output artifacts/verification/hello.verify.real.json   --no-dry-run   --real-compile   --compiler-home artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie   --compiler-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc   --package-manager-executable artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm   --runtime-lib-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative   --tool-bin-path artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin
```

### 8.2 推荐给流水线的编译命令模板

```text
cjc --diagnostic-format noColor --output-type staticlib -o {attempt_dir}/candidate_output {candidate_file_path}
```

## 九、阶段结论

到本文件更新时间为止，Phase 03 的“物理编译器接线”已经从“纸面可行”推进到“本机 Linux x64 真实可编译”。

下一步最值得推进的是：

1. 把 `pipeline_runner.py` / `orchestrator.py` 的默认 compile template 切换到真实可用模板；
2. 让 `RealMessageService.ets` 的候选 `.cj` 代码第一次进入真实 `cjc`；
3. 基于真实 stderr 做一轮真正的 Repair 闭环。
