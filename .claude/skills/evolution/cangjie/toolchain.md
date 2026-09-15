# 仓颉工具链 — SDK 安装与 cjpm 工程

## DevEco 6.x 的 Cangjie 插件与 SDK 获取方式

**问题**: DevEco Studio 6.0.2 安装后没有 Cangjie 工具链（`~/.cangjie-sdk` 不存在）；Settings 里也找不到独立的 "SDK" 页面
**原因**: DevEco 只内置 `cangjie-mgmt-plugin`（插件管理器，位于 `plugins/harmony/lib/`），真正的 Cangjie 插件和 SDK 需要手动触发下载；"语言与框架 > Cangjie" 页面上的勾选/启用不会触发下载
**解决方案**:
1. `File → Settings → 语言与框架 → Cangjie` → 点「**下载**」按钮 → 确认对话框 → 等提示下载成功 → **重启 IDE**
2. SDK 不会随插件立刻出现：**新建（或打开）一个仓颉工程**，首次 sync 时才下载到 `~/.cangjie-sdk/<version>/`
3. 验证：`~/.cangjie-sdk/<version>/cangjie/build-tools/bin/cjc -v`
4. IDE 内下载失败时，可到 developer.huawei.com 下载与 DevEco **版本号严格匹配**的 Cangjie Plugin zip，`Plugins → 齿轮 → Install Plugin from Disk`（版本不匹配会拒绝启用）

---

## SDK 26.0 新目录布局与 envsetup

**问题**: 按老文档找 `<sdk>/cangjie/compiler/bin/cjc` 不存在；直接运行 `cjpm` 报 `Created process failed`
**原因**: 新版 SDK（26.0）布局变了，工具链移到 `build-tools/` 下，且 `cjpm` 依赖 `CANGJIE_HOME` 等环境变量
**解决方案**: 工具位置与必须的初始化：
```bash
# cjc: <sdk>/build-tools/bin/cjc
# cjpm: <sdk>/build-tools/tools/bin/cjpm
source ~/.cangjie-sdk/26.0/cangjie/build-tools/envsetup.sh   # 设置 CANGJIE_HOME/PATH/DYLD_FALLBACK_LIBRARY_PATH
cjc -v && cjpm -v
```
`envsetup.sh` 会设置 `CANGJIE_HOME`、把 `bin` 和 `tools/bin` 加入 PATH、设置 `DYLD_FALLBACK_LIBRARY_PATH`。**每个新 shell 都要重新 source**（或在脚本里显式 source）。

---

## 编译产物运行报 dyld 找不到 libcangjie-runtime.dylib

**问题**: `cjpm build success`，但运行 `target/release/bin/main` 报 `dyld: Library not loaded: @rpath/libcangjie-runtime.dylib ... no LC_RPATH's found`
**原因**: 二进制依赖仓颉运行时动态库，靠 `DYLD_FALLBACK_LIBRARY_PATH`（由 `envsetup.sh` 设置）定位；构建 shell 与运行 shell 环境不一致时触发
**解决方案**: 运行前在同一 shell 中 `source <sdk>/build-tools/envsetup.sh`。构建成功但运行失败时先怀疑环境变量，不要误判为产物问题。

---

## 最小 cjpm 工程的正确结构

**问题**: 手写最小工程构建报 `the package name in <src-dir> is wrong, the right name should be 'xxx'`；或警告 `there is no '.cj' file in directory '<src-dir>'`
**原因**: 报错指的是 **`.cj` 文件内缺少/不匹配 `package` 声明**（并非目录名问题）；且 `src-dir` 默认为 `src`，需指向实际存放源文件的目录
**解决方案**: 最小可用结构：
```
cjpm.toml:
[package]
  cjc-version = "1.2.0"
  name = "hello"
  output-type = "executable"
  src-dir = "src"

src/main.cj:          # 首行必须有 package 声明，与 toml 的 name 一致
package hello

main(): Unit { println("hi") }
```
可执行产物路径为 `target/release/bin/main`（非 `target/release/<name>`）。

---

## macOS DevEco 内置 JBR 的 JAVA_HOME

**问题**: 仓颉源码、资源均编译通过，但 `PackageHap` 阶段报 “Unable to locate a Java Runtime”；构建日志看似已经注入 `<DevEco>/jbr`。

**原因**: macOS 的 DevEco Studio 以应用包形式携带 JetBrains Runtime，真正的 JDK 根目录是 `<DEVECO_HOME>/jbr/Contents/Home`，其 `bin/java` 位于该目录下。把 `<DEVECO_HOME>/jbr` 直接设为 `JAVA_HOME` 时，macOS 会回退到系统 `/usr/bin/java`，没有全局 JRE 的机器就会在 HAP 打包阶段失败。

**解决方案**:

```bash
export JAVA_HOME="$DEVECO_HOME/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
```

跨平台脚本应先检测 `platform.system() == "Darwin"` 且 `jbr/Contents/Home` 存在，再选用该路径；Windows/Linux 继续使用 DevEco 对应的 `jbr` 根目录。验证时必须实际执行 `"$JAVA_HOME/bin/java" -version` 和 `assembleHap`，仅检查目录存在不足以证明配置正确。
