# Trace - Phase-03 RealMessageService 物理编译 Iron Test 006（Round 11 / Static Grep Firewall）

## 1. 本轮目标

Round 11 的目标不是继续测试 LLM Reviewer 会不会漏判，而是直接把“确定性词法拦截”前移到 Reviewer 之前：

1. 用静态黑名单拦截器抢先拦住：
   - `TL*`
   - `InputPeer`
   - `createInputPeer`
   - `ProtocolContext`
   - `0L` / `0UL`
   - `import ... from`
   - `unsafe`
   - `!!`
2. 一旦命中黑名单，立即：
   - 跳过 LLM Reviewer
   - 跳过真实编译器
   - 直接把命中词、行号、代码片段砸回 RepairEngine

也就是说，本轮的核心不再是“让模型自己意识到错误”，而是：

> 用物理规则先把所有低级逃生门焊死。

## 2. 本轮实现

### 2.1 新增静态黑名单拦截器

新增：`scripts/static_blacklist_checker.py`

核心能力：

- 对候选代码逐行做确定性正则扫描；
- 输出结构化 `StaticCheckResult`：
  - `passed`
  - `violations[]`
  - 每条 violation 带：
    - `issue_code`
    - `line`
    - `column`
    - `matched_text`
    - `line_text`
    - `repair_hint`
- 黑名单覆盖：
  - 协议毒瘤：`TL*`、`InputPeer`、`createInputPeer`
  - 作弊伪装：`ProtocolContext`
  - 语法倒退：`0L` / `0UL`、`import ... from`、`unsafe`
  - TypeScript 恶习：`!!`

### 2.2 Orchestrator 短路拓扑

修改：`scripts/orchestrator.py`

新拓扑：

1. Translator 先产出候选
2. 先跑 `StaticReviewerFirewall`
3. 若命中黑名单：
   - 直接写出 `static_check_result.json`
   - 生成 synthetic `ReviewResult`
   - 生成 synthetic `VerifyResult(status=blocked, failure_type=static-blacklist-failed)`
   - **完全跳过** LLM Reviewer 与真实 `cjc`
4. 若静态扫描通过：
   - 才允许进入 Reviewer 与 Compiler

## 3. 本轮执行配置

运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-008-round11-static-firewall`

关键参数：

- 模型：`Pro/zai-org/GLM-4.7`
- Parser：`ast`
- 真实编译器配置已挂载，但本轮大部分情况下根本到不了编译阶段
- 最大轮数：`5`
- 挂载硬模板：
  - `domain-purity-hard-template`
  - `cangjie-syntax-pitfalls-v1.2`
  - 其他协议/并发/ACL Skill

## 4. 最终结果

- `summary.json.status = passed`
- `RealMessageService.orchestration.json.final_status = failed`

五轮状态全部为：

- `review_passed = false`
- `verify_status = blocked`
- `verify_failure_type = static-blacklist-failed`

也就是说：

> Round 11 的静态铁穹成功把 5 轮候选全部拦死在 Reviewer 和 Compiler 之前，没有再给模型任何“带病闯关”的机会。

## 5. 五轮静态拦截摘要

### 5.1 Attempt 1

首轮就命中：

- `unsafe`
- `TLUser`
- `TLChannel`
- `createInputPeer`

典型证据：

- `import std.unsafe.*`
- `public func cacheUsers(users: ArrayList<TLUser>)`
- `public func cacheChannels(channels: ArrayList<TLChannel>)`
- `createInputPeer`

结论：

- 模型第一轮依然试图保留典型协议残留；
- 静态墙在 LLM Reviewer 之前就直接开火，效果立竿见影。

### 5.2 Attempt 2

第二轮命中：

- `TLUser`
- `TLChannel`
- `createInputPeer`
- `0UL`
- `TLSerializer`
- `TLDeserializer`

这非常关键，因为它说明：

- 就算模型在 `repair_thought_process` 里写了“我会移除协议逻辑”，
- 只要代码里仍残留协议名词或数字后缀，
- 静态墙就不会给它去 Reviewer 里“狡辩”的机会。

### 5.3 Attempt 3

第三轮全部命中 ArkTS `import ... from`：

- `import { Signal, ValueSignal, SignalPipe } from`
- `import { Message, PeerId, DomainUser, DomainChannel } from`
- `import { IMessageService, SendMessageParams, GetHistoryParams } from`
- `import { TelegramProtocolAdapter } from`

这说明：

> Round 10 里曾经让 Reviewer 漏过去的一类“源语言导入语法回退”，在 Round 11 被静态规则 100% 抓住了。

### 5.4 Attempt 4

第四轮继续命中：

- `unsafe`
- `TLUser`
- `TLChannel`

模型仍在试图回到“让 Service 直接接 TL 类型”的老路，但这条路已经彻底被物理规则封死。

### 5.5 Attempt 5

最终轮命中：

- `TLUser`
- `TLChannel`
- `createInputPeer`
- `InputPeer`

这说明即使到最后一轮，模型依然没有真正接受：

- Service 层方法签名不得出现 `TL*`
- Service 层内部不得出现 `createInputPeer`
- Service 层不得出现 `InputPeer`

但最重要的是：

> 它再也无法像 Round 10 第 3 轮那样侥幸混过 Reviewer 了。

## 6. 本轮最关键的系统结论

### 6.1 静态墙彻底补上了 Reviewer 的漏判短板

Round 10 最危险的问题是：

- Reviewer 曾对明显的 `TL*`、`0UL`、`unsafe`、`implements` 残留放行一次；
- 真实编译器才在下一关把它打下来。

Round 11 之后，这个缺口被补上了：

- 黑名单命中就直接短路；
- 不再把明显词法违规交给 LLM 自己“理解”。

### 6.2 现在的闭环是“规则优先，LLM 次之”

Round 11 证明，当前最稳妥的顺序是：

1. 静态规则先杀掉显式违规
2. Reviewer 再审更高层的职责与边界
3. 编译器再审真实目标语言语法与类型

这也正是混合审查架构的核心价值：

> Grep 不会幻觉，LLM 才负责更高层的结构推理。

### 6.3 当前副作用：注释中的违规词也会被拦截

本轮静态扫描有一个非常“铁血”的特征：

- 它不区分注释和代码；
- 只要注释里还写着 `TLUser`、`createInputPeer`、`0UL` 等黑名单词，也一样会触发拦截。

这带来的后果是：

- 某些轮次里，模型虽然是在“解释自己要删除这些词”，
- 但因为解释文本本身包含了黑名单词，依然被当场击落。

这在当前阶段反而是符合目标的：

> 我们就是要极其粗暴地要求模型把这些危险词汇从候选文件里彻底清空。

## 7. 本轮裁决

Round 11 没有让 `RealMessageService` 通过，但它完成了一次比“通过”更重要的系统升级：

1. **LLM Reviewer 的漏判口子被静态墙补上了**；
2. **所有显式词法违规都被挡在了 Reviewer / Compiler 之前**；
3. **模型现在连“带着明显脏词进审查”这条路都走不通了**。

一句话结论：

> Round 11 的静态铁穹成功把大模型的狡辩空间压缩到最小：它可以继续胡思乱想，但只要候选文件里还残留 `TL*`、`InputPeer`、`createInputPeer`、`unsafe`、`0L/0UL`、`import ... from`，就根本摸不到 Reviewer，更别提编译器。
