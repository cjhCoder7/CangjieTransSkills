会议主题：Telegram鸿蒙应用翻译与Skill构建研讨会
发言人：程浚航、门凯旋、23376044陈科屹
会议摘要：本次会议明确了基于Agent技术将Telegram应用从RTS翻译至仓颉语言的实施路径，确立了先构建鸿蒙开发Skill库再验证翻译效果的策略，并制定了后续文档分析与模型验证计划。
---
一、项目背景与核心目标
针对华为“揭榜挂帅”项目要求，会议明确了项目验收标准及技术选型方向：
1. 项目验收标准与范围
验收目标：将 Telegram 应用从 RTS 版本翻译为仓颉语言版本，完成 APP 开发。
语言选型：重点完成 Swift (iOS) 和 RTS (鸿蒙) 两种语言的翻译，第三种语言（Java/Python）作为备选，在项目后期视情况选择。
开发环境：需使用 DevEco Studio 并安装仓颉插件，否则无法开发仓颉版本的鸿蒙应用。
2. 技术路径与选型依据
技术选型：优先从 RTS 翻译到仓颉入手，利用仓颉语言与 RTS 的互操作特性（如调用接口、C语言互操作）降低翻译难度。
Agent 架构：采用 Agent 方式配合 Skill 进行翻译，而非单纯的检索增强生成。
Skill 分层：计划构建两个 Skill 库，一个是通用程序开发的 Skill，另一个是鸿蒙系统应用开发的 Skill，让 Agent 自主选择查询路径。
二、Skill 构建策略与验证机制
针对文档转换的复杂性，团队确立了基于样本分析的渐进式构建策略：
1. Skill 格式标准化
文档重构需求：鸿蒙应用开发文档较为分散，需将其整理为结构化 Skill，并借助大模型进行自动化 Type Line 处理。
结构设计：计划采用“渐进式披露”结构，将 Skill 分为 AI 接口、组件介绍等模块，便于 Agent 理解和使用。
检索集成：Skill 定义中需包含检索脚本或指令，规定在何种情况下触发文档检索以弥补知识盲区。
2. 验证与迭代方案
可行性验证：不直接翻译 Telegram 源码，而是先挑选鸿蒙系统提供的简单样例（Sample）进行翻译验证，以验证 Skill 的可行性并优化内容。
迭代反馈：通过运行生成的代码，在模拟器中验证功能效果，以此作为反馈来迭代优化 Skill 的 Pipeline 设计。
样本分析策略：门凯旋提议抽取通用 Skill 与鸿蒙文档中重叠度高的样本，利用强能力大模型总结转换范式，以此作为 Skill 构建的参考。
三、资源支持与后续安排
1. 模型资源与工具配置
模型调用：确认可通过 API 调用 Claude 等模型，并提供 Token 供前期验证使用。
成本控制：前期验证阶段优先使用开源模型或低成本模型（如 GLM5、MiniMax 2.5），避免直接使用昂贵模型。
工具调试：针对第三方工具访问受限的问题，程浚航将在群内提供具体的 URL 和 API Key 配置命令。
---
四、待办事项
填写问卷并下载 DevEco Studio 仓颉插件。 @23376044陈科屹 @门凯旋
整理并发送文档链接、API Key 配置命令及 URL 到群内。 @程浚航
各自阅读鸿蒙开发文档及通用 Skill 文档，寻找重叠样本并构思 Skill 格式。 @全体
明天同一时间（晚上 8 点）再次开会讨论 Skill 的具体格式和构建细节。 @全体


确定方案目标细节：以Telegram的iOS版本（对应Swfit）和Telegram的HarmonyOS版本（对应ArkTS）为源码，实现转换翻译到仓颉语言上的版本，实现的技术方法不做限制，只要有轨迹信息以及最后的完整的仓颉语言版本的仓库代码即可，考核完结方式为单测+人工功能核查。难题限制为至少3种编程语言到仓颉语言的转换，Telegram包含了两种语言，对于另一种语言，可以考虑Java或者是Python的代码转换。
- Telegram Swfit 版本（App开发，涉及视图组件）
- Telegram ArkTS 版本（App开发，涉及视图组件）
- Java/Python 代码仓库，待选择（计划通用三方库开发，涉及api使用，网络协议等）

---
报名 HarmonyOS 仓颉语言开发者体验版（目前处于内测及试点商用阶段），仍在审核中，只有通过后才可以查看 HarmonyOS 仓颉开发文档以及下载 DevEco Studio 仓颉开发插件。

---
找到一个官方的对于仓颉语言在opencode上适配的skill仓库：https://gitcode.com/Cangjie-SIG/CangjieSkills
.
├── .opencode/
│   ├── skills/                               # Skills 目录
│   │   ├── base-skill/                       # 强制前置 Skill（项目生成入口）
│   │   ├── cangjie-kernel/                   # 仓颉语法 & 标准库基础事实 Skill 集
│   │   ├── cangjie-vec-retriever-guide/      # [语义层] 向量 RAG 检索 
│   │   ├── cangjie-doc-search-guide/         # [考古层] 全量官方文档搜索
│   │   ├── cangjie-evolution/                # 仓颉项目问题沉淀
│   │   ├── harmonyos-build/                  # 鸿蒙构建流程 Skill
│   │   ├── harmonyos-evolution/              # 鸿蒙项目问题沉淀
│   │   ├── harmonyos-vec-retriever-guide/    # L1 RAG 检索 Skill
│   │   ├── harmonyos-doc-search-guide/       # L3 本地文档搜索 Skill
│   │   ├── harmonyos-requirement-analysis/   # 需求分析 Skill
│   │   └── harmonyos-stdx-dependency/        # stdx 依赖配置
│   └── script/                               # 构建脚本与工具
├── outputs/                                  # 生成的仓颉项目输出目录
└── AGENTS.md                                 # 本文件
在skill调用入口对于仓颉项目生成的约束是这样的

---
鸿蒙应用开发任务（HarmonyOS + 仓颉）  
   当 task.md 中要求开发鸿蒙应用（如 ArkUI、HAP 构建、module.json5、鸿蒙页面/组件等）时，严格按以下流程工作，每一步都要显式调用对应 Skill，并先阅读该 Skill 的 SKILL.md 说明再执行操作：  
     1) 需求分析（L0）：调用 `harmonyos-requirement-analysis` Skill，先阅读其 SKILL.md 中的需求分析模板与示例，然后按照该 Skill 的流程将业务需求拆解成 UI 组件、数据结构和交互行为，不直接查业务词。  （这个可以感觉写的挺好的，不过我们的目标是代码翻译任务，应该需要稍微微调一下。）
     2) 基础仓颉技能优先：在 L0 分析之后，调用 `.opencode/skills/cangjie-kernel` 中对应的基础技能（如 `array`、`string`、`function`、`std`、`stdx` 等 Skill），阅读各自 SKILL.md 的用法说明，再按照其中的示例完成语法、类型和标准库层面的推理与修复。    （cangjie-kernel中设计的不是很好，没有很好的实现渐进式披露，而是直接对官方文档进行Skill转换，这里需要替换为该仓库中的主分支中的对于通用仓颉任务的Skill包）
     3) 混合查询：如需进一步知识检索，调用 `harmonyos-vec-retriever-guide` Skill，先阅读该 Skill 的 SKILL.md 中的环境配置、查询策略和脚本路径说明，再通过 `.opencode/skills/utils/scripts/ask_cangjie.py` 按 API 关键字逐个检索。  
     4) 本地文档搜索：如需进一步知识检索，调用 `harmonyos-doc-search-guide` Skill，按照其 SKILL.md 中的初始化说明，首次使用或需要确保官方文档已初始化时，可以执行 `python ask_cangjie.py "test"` 生成本地文档树（初始化）；当 混合查询 无结果或不够时，再根据该 Skill 中给出的路径和搜索命令，基于 `.opencode/skills/utils/scripts/hm-docs/` 做本地官方文档搜索（UI、语法、stdx 文档），不要直接访问 `cangjie-docs-full`。  
（对于3和4，是作者针对于 HarmonyOS 仓颉开发文档进行处理，猜测是作者当时为了节省时间，做了一个 RAG 向量搜索，如果搜不到，就直接去原文档中进行检索，是一个比较粗糙化的逻辑。这里计划自己构建一个和canjie-kernel平级的cangjie-harmonyos的Skill库，如果在这两个平行的Skill中都不能学到相关的知识，才去原文档搜索。）
（原文档管理：复用该仓库的python脚本，能够定期从网站上爬取所有和 HarmonyOS 仓颉相关的文档。）
     5) stdx 依赖配置：当鸿蒙工程中需要 stdx 能力或出现 stdx 相关构建错误时，调用 `harmonyos-stdx-dependency` Skill，先阅读其 SKILL.md，按照其中描述的「解压到 `<项目根>/cjnative/stdx` + 修改 entry/cjpm.toml bin-dependencies.path-option」的步骤，通过 `.opencode/skills/harmonyos-stdx-dependency/` 中的资源自动或半自动完成配置。  （stdx 配置方法，可以进行保留）
     6) 构建与排错：调用 `harmonyos-build` Skill，严格按照其 SKILL.md 中的说明复制并执行 `build.ps1`，获取 `build-full.log`，每一次报错必须必须按文档中规定的优先级：先查 Evolution.md → 再用 `.opencode/skills/cangjie-kernel` 调试 → 再用 `harmonyos-vec-retriever-guide` 调试 → 最后用 `harmonyos-doc-search-guide` 文档，分步处理构建错误。必须注意每一次鸿蒙项目构建报错都要按照skill的要求处理。（HarmonyOS app 编译方法，可以进行保留）
     7) 迭代记录：每次构建成功后，调用 `harmonyos-evolution` Skill，阅读其 SKILL.md 中给出的记录格式和示例，将本次遇到的重要问题与解决方案记录到 `.opencode/skills/utils/Evolution.md` 中，以便在后续项目中迁移复用。（经验管理，这个思路可以保留，不过打算做一个渐进式的管理方式，不全部放在一个Evolutioon.md中，可以分成多个不同的经验池，例如UI组件、数据管理，语法知识等等，让Agent自主管理。）

---
对于第一步需求分析的思考，是打算将原代码仓库的功能需求点全部理清之后再进行翻译转换，还是先有一个大概的需求框架，然后搭建好仓颉版本的基础功能之后再进行扩充。个人比较推荐第二种，因为对于Telegram这种项目，是比较复杂的，即便最后翻译完毕功能肯定也不是完全等价的，所以使用渐进式改进的方式比较符合实际。
然后是对于单元测试翻译的思考，打算先翻译源码，然后在基本功能点实现完成以后（编译后人工检查），根据原代码仓库中的单测来编写仓颉版本的测试（与之相对应的是先翻译测试，然后再实现仓颉的源代码翻译），这样既能保证单元测试通过率较高，也能实现更好的测试代码覆盖率。（计划将这样的单测翻译包装为一个Skill库，总的来说是根据仓颉代码版本+X语言的源代码测试来生成仓颉的代码测试。）
其实这样考虑的主要原因是最后的交付不可能保证所有的功能原封不动的进行翻译，最后的结果一定是一个精简版的App，其实Swift版的Telegram和ArkTS的都不是完全一样的，所以根据代码来生成测试要合理一些。


# 华为仓颉翻译项目会议核心信息梳理（新手开发者版）
> 说明：已剔除所有通话测试、日常闲聊等无关内容，修正原文口误（如rts→ArkTS、仓体→仓颉、pampline→pipeline等），按新手认知逻辑结构化梳理全量核心信息，确保你能快速掌握项目全貌、技术要求与工作安排。

## 一、会议基础信息
- 会议主题：华为揭榜挂帅仓颉翻译项目专项沟通会
- 会议时间：2026年03月25日 20:02-20:33
- 参会人：程浚航、陈科屹、门凯旋
- 项目周期：约2个月

## 二、项目核心背景与验收目标
1.  **项目属性**：华为揭榜挂帅专项项目，核心是多编程语言到仓颉语言的自动化翻译与APP开发。
2.  **硬性验收目标**：完成Telegram应用到仓颉语言版本的翻译落地。
3.  **核心技术方向**：基于Agent+Skill的方案实现代码翻译，最终围绕Skill开发形成项目总结/相关论文。

## 三、翻译范围与实施优先级
项目需完成3种编程语言到仓颉的翻译能力建设，优先级与规划如下：
| 源语言 | 适配场景 | 实施安排 |
|--------|----------|----------|
| ArkTS  | 鸿蒙系统原生应用开发，已有成熟的Telegram ArkTS版本 | **最高优先级**，先行落地 |
| Swift  | iOS端应用开发，已有成熟的Telegram Swift版本 | 优先级次之，ArkTS方案跑通后启动 |
| Java/Python | 通用程序开发 | 最低优先级，项目收尾阶段选一个项目完成翻译验证即可 |

> 优先选ArkTS的核心原因：仓颉是新语言，很多功能特性尚未完善，但支持与ArkTS、C语言的互操作，可通过仓颉直接调用ArkTS接口，大幅降低翻译难度。

## 四、核心技术路线与架构
项目核心采用**Agent（Claude）+Skill**的技术架构，整体设计如下：
1.  **双Skill库架构**
    - 通用仓颉开发Skill库：官方已维护完成，覆盖仓颉通用语法、基础程序开发能力，无需自主开发。
    - 鸿蒙应用开发Skill库：**项目核心交付内容，需自主开发**，基于OpenHarmony仓颉开发文档构建，覆盖鸿蒙APP开发的UI框架、组件、AI接口、系统架构等专属能力。
2.  **Skill核心能力**
    - 不仅包含结构化的开发知识，还可配套Python脚本等执行工具，可定义模型动作规则（如遇到未知知识时，自动调用检索工具在原始文档中查询）。
    - 支持Agent自主判断开发场景，选择对应的Skill库查询知识，完成代码翻译。

## 五、开发环境配置硬性要求
1.  基础工具：必须安装**DevEco Studio**（鸿蒙官方配套开发环境）。
2.  仓颉开发权限：
    - 仅安装DevEco Studio，只能开发ArkTS版本应用，无法开发仓颉鸿蒙应用。
    - 需填写指定问卷提交申请，审批通过后，方可下载安装DevEco Studio的仓颉插件，获得仓颉鸿蒙应用开发能力。
3.  当前进度：你（陈科屹）和门凯旋已提交问卷申请，程浚航会跟进催办审批。

## 六、项目实施路径与验证方案
为降低开发风险，确定**小样本验证→迭代优化→全量翻译**的分步实施路径，严禁直接上手翻译全量Telegram代码：
1.  第一步：完成鸿蒙应用开发Skill库的结构设计，搭建「开发文档→Skill」的自动化Pipeline。
2.  第二步：选取鸿蒙ArkTS应用开发的简单样例（小体量、功能单一），验证Skill实现ArkTS→仓颉翻译的可行性。
3.  第三步：基于小样本验证结果，持续迭代优化Skill的内容、结构与Pipeline规则。
4.  第四步：Skill能力验证达标后，再启动Telegram ArkTS版本的全量翻译工作。

## 七、核心难点与确定的解决方案
| 核心难点 | 会议敲定的解决方案 |
|----------|--------------------|
| 鸿蒙应用开发Skill的结构/格式无参考标准 | 1. 参考官方通用仓颉Skill库的成熟结构；2. 采用模块化设计，按AI接口、UI组件、框架能力等维度拆分；3. 借助大模型生成初步结构方案 |
| 开发文档转Skill无法通过规则化实现，内容抽离难度大 | 1. 放弃规则化转换，采用大模型完成文档内容的结构化抽离；2. 对单个Skill单元，增加编译、程序运行环节验证内容准确性 |
| 无明确的文档转Skill转化范式 | 1. 梳理鸿蒙开发文档与官方通用Skill文档中重叠度高的内容作为标准样本；2. 用强能力大模型基于样本总结转化范式，再全量复用 |
| 暂无完全自动化的Skill效果验证方案 | 1. 用小功能样例持续迭代优化初步Skill；2. 代码层面用单元测试验证基础功能；3. 最终效果必须人工在模拟器中运行验证，确认应用运行符合预期 |
| 模型遇到Skill未覆盖的知识无法处理 | 把文档检索能力封装成Skill工具，定义规则：模型遇到未知知识时，自动调用检索工具在原始开发文档中查找内容 |

## 八、大模型使用规则
1.  核心主模型：采用Claude，token用量无严格限制，优先保障翻译效果。
2.  调用方式：可通过指定BASE URL+API Key调用多种大模型（含GPT等），程浚航会提供模型列表查询命令。
3.  成本控制：前期方案验证阶段，优先使用低成本/开源模型（如GLM-4、MiniMax 2.5），程浚航会提供对应模型的token。
4.  技术要求：前期需搭建Pipeline框架，实现开发文档的自动化转换与预处理。

## 九、下一步明确工作计划与分工
1.  **全体参会人（含你）**
    - 完整通读OpenHarmony仓颉开发文档（优先看中文文档），形成鸿蒙仓颉应用开发的整体认知。
    - 梳理开发文档与官方通用Skill文档的共同点，寻找可提炼转化范式的样本。
    - 2026年03月26日晚20:00再次参会，讨论确定Skill整体结构、转化范式与Pipeline设计。
2.  **程浚航专项工作**
    - 跟进催办仓颉插件申请的审批进度。
    - 整理项目相关的文档链接、资料、模型调用命令，统一发至项目群。
    - 提供前期验证用的平价模型token。
3.  整体节奏：加快推进，争取几周内完成Skill的初步开发与验证。

## 十、最终产出要求
1.  核心交付物：完成Telegram到仓颉语言版本的翻译，满足华为揭榜挂帅项目的验收要求。
2.  成果沉淀：围绕Skill开发全流程形成项目总结/相关论文，可基于开发中发现的问题优化Pipeline、补充限制条件，完善技术方案。

之前的一个周报：https://my.feishu.cn/docx/QaZAdbBn8oRpgXx6nupceaHlndf
ArkTS一些小demo：https://gitcode.com/openharmony/applications_app_samples
CangjieSkill：https://gitcode.com/Cangjie-SIG/CangjieSkills
Cangjie鸿蒙开发文档：https://gitcode.com/openharmony/docs_cangjie
IDE下载（DevEco Studio和Cangjie 插件）：https://developer.huawei.com/consumer/cn/download
Telegram ArkTS版本：https://github.com/ForestBook/TelegramHarmony
Cangjie官方网站：https://cangjie-lang.cn/

sk-jpuqxffoljwfmvbzzcsskufqnvoxtqkiqlawdcwvcsnuchyu
硅基流动API Key