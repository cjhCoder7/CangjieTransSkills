---
name: download-script
description: "从 GitCode 下载最新仓颉语言和 HarmonyOS 原始文档。当 cangjie-kernel 和 cangjie-harmony 未覆盖所需内容时作为兜底使用"
disable-model-invocation: true
allowed-tools: Bash(loopx *), Bash(python3 *), Bash(cd *), Bash(ls *)
argument-hint: "[--sources stdlib|stdx|syntax|ui-dev|tools]"
---

# 仓颉文档下载与查询工具

> 当 `cangjie-kernel` 和 `cangjie-harmony` 技能中的文档无法解决问题时，使用此工具下载最新的原始文档。

## LoopX 管理

`--list-sources` 等不产生写入的查询可直接运行。实际下载会访问网络并写入 `hm-docs/`，必须先加载 `cangjie-loopx-management`：

- 作为翻译、构建或修复的一部分时，复用当前 Goal 和 Todo；
- 独立下载时，自动创建或恢复一个有界文档获取 Goal；
- 执行前读取 `quota should-run`，并遵守网络权限和目标写入边界；
- 成功后记录文档源、语言、索引统计和目标相对路径；失败时保留 Todo 未完成并记录可操作错误；
- `hm-docs/`、下载日志和临时仓库保持 Git 忽略，不把原始下载内容复制进 LoopX 状态。

若当前环境没有网络权限，创建或维持具体用户 Gate，不得把本地已有旧文档假报为最新下载结果。

## 快速使用

```bash
# 下载全部文档（约 1100+ 篇 Markdown）
python3 ${CLAUDE_SKILL_DIR}/download_hm_docs.py

# 下载指定文档源
python3 ${CLAUDE_SKILL_DIR}/download_hm_docs.py --sources stdlib
python3 ${CLAUDE_SKILL_DIR}/download_hm_docs.py --sources "标准扩展库"

# 列出可用文档源
python3 ${CLAUDE_SKILL_DIR}/download_hm_docs.py --list-sources

# 下载英文文档
python3 ${CLAUDE_SKILL_DIR}/download_hm_docs.py --lang en
```

### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--sources <名称>` | 指定下载的文档源（支持模糊匹配） | 全部下载 |
| `--list-sources` | 列出所有可用文档源 | - |
| `--lang zh\|en` | 文档语言版本 | zh |
| `--base-dir <路径>` | 下载基础目录 | 当前目录 |

## 五个文档源

| 目录 | 文档源 | 内容 | 文件数 | 适用场景 |
|------|--------|------|--------|----------|
| `hm-docs/ui-dev/` | UI开发和鸿蒙应用 | 应用框架、UI组件、API参考 | ~1375 | 界面开发、用户交互、系统API |
| `hm-docs/stdlib/` | 标准库API | core/collection/io/net/fs 等 40+ 包 | ~248 | 基础数据结构、算法、标准API |
| `hm-docs/stdx/` | 标准扩展库 | crypto/http/tls/unittest/logger 等 | ~114 | 加密、网络、测试、日志等扩展功能 |
| `hm-docs/syntax/` | 语法和语言特性 | 数据类型/函数/类/泛型/并发/宏 等 | ~106 | 语法问题、语言特性查询 |
| `hm-docs/tools/` | 命令行工具 | cjpm/cjfmt/cjlint/cjdb/cjcov/cjprof | ~10 | 构建、格式化、调试、覆盖率 |

## 下载后的文档结构

```
hm-docs/
├── README.md                    # 文档说明
├── index.json                   # 元数据与文件统计
│
├── ui-dev/                      # HarmonyOS 应用开发（最高优先级）
│   ├── application-models/      #   应用模型（Ability Kit）
│   ├── arkui-cj/                #   ArkUI 框架
│   ├── cj-start/                #   快速入门
│   ├── reference/               #   API 参考（按 Kit 分类）
│   │   ├── AbilityKit/
│   │   ├── ArkData/
│   │   ├── arkui-cj/
│   │   ├── NetworkKit/
│   │   └── ...（20+ Kit）
│   ├── security/                #   安全服务
│   ├── network/                 #   网络服务
│   ├── media/                   #   媒体服务
│   └── ...
│
├── stdlib/                      # 标准库 API
│   ├── core/                    #   核心库
│   │   ├── core_package_overview.md
│   │   ├── core_package_api/    #   详细 API
│   │   └── core_samples/        #   示例代码
│   ├── collection/              #   集合
│   ├── io/                      #   I/O
│   ├── net/                     #   网络
│   ├── fs/                      #   文件系统
│   ├── sync/                    #   同步原语
│   ├── math/                    #   数学
│   ├── regex/                   #   正则表达式
│   ├── time/                    #   时间
│   ├── crypto/                  #   加密
│   └── ...（40+ 包）
│
├── stdx/                        # 标准扩展库
│   ├── crypto/                  #   加密（crypto/digest/x509/keys）
│   ├── net/                     #   网络（http/tls）
│   ├── unittest/                #   单元测试
│   ├── compress/                #   压缩（zlib）
│   ├── logger/                  #   日志
│   ├── serialization/           #   序列化
│   ├── encoding/                #   编码（hex/base64/url）
│   └── aspectCJ/                #   AOP 面向切面
│
├── syntax/                      # 语言特性
│   ├── basic_data_type/         #   基础数据类型
│   ├── function/                #   函数
│   ├── class_and_interface/     #   类和接口
│   ├── generic/                 #   泛型
│   ├── concurrency/             #   并发
│   ├── Macro/                   #   宏
│   ├── FFI/                     #   外部函数接口
│   └── ...
│
└── tools/                       # 命令行工具
    ├── command_line_overview.md  #   工具概览
    ├── cmd-tools/               #   各工具手册
    │   ├── cjpm_manual.md       #     包管理器
    │   ├── cjfmt_manual.md      #     代码格式化
    │   ├── cjlint_manual.md     #     代码检查
    │   ├── cjdb_manual.md       #     调试器
    │   ├── cjcov_manual.md      #     覆盖率工具
    │   └── cjprof_manual.md     #     性能分析器
    └── cangjie-language-server/  #   LSP 语言服务
        └── LSPServer_manual.md
```

## 查询建议

### 标准库 API
在 `hm-docs/stdlib/<包名>/` 下查找。每个包含：
- `*_package_overview.md` — 包概览与用法示例
- `*_package_api/` — 类/函数/接口的详细 API 文档
- `*_samples/` — 示例代码

### 扩展库 API
在 `hm-docs/stdx/<模块名>/` 下查找，结构同标准库。

### HarmonyOS API
在 `hm-docs/ui-dev/reference/` 下按 Kit 名称查找，每个 Kit 包含仓颉 API 文档和错误码。

### 语言特性
在 `hm-docs/syntax/` 下按主题查找。

### 工具用法
在 `hm-docs/tools/cmd-tools/` 下查找对应工具手册。

## 技术细节

- 脚本使用 **sparse git checkout** 高效克隆，仅下载所需文档目录
- 自动尝试分支回退（master → main）
- 下载完成后生成 `index.json` 包含元数据和文件统计
- 日志记录在 `download_hm_docs.log`
- 临时仓库文件在下载完成后自动清理
