# Trace - Phase-03 RealMessageService 物理编译 Iron Test 007（Round 12 / Comment-Aware Static Firewall）

## 1. 本轮目标

Round 12 的目标是给静态铁穹增加“敌我识别”：

1. **扫描时忽略注释**，不再误伤那些在注释里写“我要移除 TLUser”的好模型；
2. 观察模型在通过“只扫代码、不扫注释”的静态防火墙后，是否终于能：
   - 真正把协议隔离到 Adapter；
   - 不再出现 `0UL`、ArkTS `import ... from` 等语法倒退；
   - 产出更纯净的 Service 候选。

## 2. 静态墙 IFF 升级

### 2.1 注释脱敏逻辑

修改文件：`scripts/static_blacklist_checker.py`

新增函数：`strip_comments_preserve_layout(source: str) -> str`

策略：

- **单行注释** `// ...`
  - 替换为等长空格；
  - 保留换行符；
- **多行注释** `/* ... */`
  - 所有非换行字符替换为空格；
  - 换行保留，确保行号与列号映射不漂移；
- **字符串字面量**
  - 不进行注释剥离；
  - 用简单状态机保护 `"`、`'`、`` ` `` 内部内容。

核心原则：

> 注释脱敏仅发生在内存中的静态扫描副本上，不会修改真实落盘给 `cjc` 编译的 `.cj` 文件。

### 2.2 升级后行为验证

使用一个简单样本验证后，结果符合预期：

- 注释里的 `TLUser` / `createInputPeer` 不再被误报；
- 真实代码里的 `import std.unsafe.*`、`Array<TLUser>` 仍然会被命中。

这证明“只扫代码，不扫注释”的 IFF 已成功上线。

## 3. 本轮执行配置

运行目录：`artifacts/pipeline_runs/phase03-physical-iron-test-realmessageservice-009-round12-comment-aware-firewall`

关键参数：

- 模型：`Pro/zai-org/GLM-4.7`
- 最大轮数：`5`
- 静态防火墙：启用
- 注释脱敏：启用
- 真实编译器：Linux x64 `cjc`

## 4. 总体结果

- `summary.json.status = passed`
- `RealMessageService.orchestration.json.final_status = failed`

五轮结果：

1. Attempt 1：静态拦截，命中 `unsafe`
2. Attempt 2：**静态通过 + Reviewer 通过 + 真实编译失败**
3. Attempt 3：静态拦截，命中 `unsafe` / `TLUser` / `TLChannel` / `InputPeer` / `createInputPeer` / `TLDeserializer`
4. Attempt 4：静态拦截，命中 `unsafe`
5. Attempt 5：静态拦截，命中 `TLUser` / `TLChannel` / `InputPeer` / `createInputPeer`

也就是说：

> Round 12 的关键进展不是“编译通过”，而是：静态墙已经足够干净，能够让真正没有词法毒瘤的候选至少走到 Reviewer 和 `cjc` 面前。

## 5. 本轮关键发现

### 5.1 注释友伤大幅下降

对比 Round 11：

- Round 11 中，注释里写着“移除 TLUser / createInputPeer / 0UL”的候选，也会被直接击落；
- Round 12 中，这类解释性注释不再误伤。

最直观的证据是：

- Attempt 1 只剩一个真实代码级命中：`unsafe`
- Attempt 4 也只剩一个真实代码级命中：`unsafe`

这说明 IFF 升级确实把噪声压下去了。

### 5.2 Attempt 2 首次真正穿过“注释友伤修复后的铁穹”

Attempt 2 是 Round 12 最关键的一轮：

- `static_passed = true`
- `review_passed = true`
- 然后被真实 `cjc` 打回

这说明：

1. 注释脱敏之后，静态墙不再把“注释里的整改计划”误判成代码残留；
2. 候选在词法层面确实一度足够干净，能继续走到更深层验证。

### 5.3 真正阻塞 Attempt 2 的，是更深层的仓颉语法问题

Attempt 2 的真实编译错误不再是 `TLUser`、`0UL`、`import ... from`，而是：

- `public class RealMessageService implements IMessageService` 不合法
- `return Promise(=> { ... })` 不合法

这说明一件非常重要的事：

> 当我们把显式协议毒瘤和源语言残留扫干净之后，模型终于暴露出了更“纯粹”的仓颉语法映射问题。

换句话说，Round 12 已经把问题推进到了一个更高质量的层次：

- 不是还在和 `TLUser`、`unsafe` 这些脏词搏斗；
- 而是开始真正面对仓颉类声明与异步闭包的语法落地。

### 5.4 模型仍然会回退到“协议泄漏老路”

虽然 Attempt 2 暂时干净，但 Attempt 3 / 5 还是迅速回退：

- Attempt 3 命中：
  - `unsafe`
  - `TLUser`
  - `TLChannel`
  - `InputPeer`
  - `createInputPeer`
  - `TLDeserializer`
- Attempt 5 命中：
  - `TLUser`
  - `TLChannel`
  - `InputPeer`
  - `createInputPeer`

说明：

> 模型还没有稳定学会“纯净 Service 模式”，它只是偶尔能写出一版足够干净的候选，但在后续 Repair 中仍会回落到旧习惯。

## 6. 这一轮离目标有多近？

用户要求观察的三个目标是：

1. 真正把协议隔离到 Adapter
2. 没有任何语法降级（`0UL`、ArkTS `import`）
3. 纯净的 Service 代码

Round 12 的实际结果：

- **目标 1：部分达到，但不稳定**
  - Attempt 2 在静态层面看起来已基本剥离显式协议毒瘤；
  - 但 Attempt 3 / 5 又退回 `TL*` / `createInputPeer`。
- **目标 2：在 Attempt 2 达到**
  - Attempt 2 未再触发 `0UL` 或 ArkTS `import ... from` 静态拦截；
  - 但随后卡在更深层仓颉语法上。
- **目标 3：尚未稳定达到**
  - 因为后续轮次仍频繁把 `TL*` 与 `InputPeer` 带回 Service。

## 7. 本轮裁决

Round 12 的价值非常高，原因有三：

1. **静态墙终于不再误伤注释**
2. **系统第一次明确证明：有候选能穿过静态墙并进入 Reviewer + `cjc`**
3. **真正的剩余瓶颈开始集中到更深层仓颉语法，而不是低级脏词残留**

一句话总结：

> Round 12 证明“注释友伤”已经被修好，静态防火墙开始只针对真实代码本体开火；模型也因此第一次交出了一份能穿过静态墙并进入真实编译器的候选，但它仍未稳定掌握纯净 Service 切分，且在后续轮次会重新掉回 `TL*` / `InputPeer` 老路。

## 8. 下一步最合理的方向

如果继续推进，最值钱的不是再加更多黑名单，而是两条更精细的收敛策略：

1. **把 Attempt 2 暴露的纯仓颉语法问题做成新 Skill**
   - `implements` 语法
   - `Promise(=> { ... })` 写法
2. **给 Repair 增加“成功回滚保护”**
   - 一旦某一轮已经消灭了 `TL*` / `InputPeer` / `unsafe`，后续轮次如果又把这些词带回来，应直接视为回归缺陷并重点惩罚。
