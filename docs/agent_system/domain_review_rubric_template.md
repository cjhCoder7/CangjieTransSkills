# Domain Review Rubric Template

这个文件承载“仓库特有的审查词表、边界定义与 reviewer gate”。
它不是通用角色模板，也不是战略周报。

## 推荐结构

```markdown
# Domain Review Rubric

更新时间：`YYYY-MM-DD`

## 1. Canonical Boundary Pairs

### `A / B`

- 一句话定义：
- 正证据长什么样：
- 什么还不足以支持这个判断：
- 最常见混淆：
- 判错后果：

### `C / D`

- 一句话定义：
- 正证据长什么样：
- 什么还不足以支持这个判断：
- 最常见混淆：
- 判错后果：

## 2. Promotion Ladder

### `exploratory`

- 进入条件：
- 还不够进入下一层的伪证据：
- 对下游意味着什么：

### `mechanical-ready`

- 进入条件：
- 常见误写：
- 对下游意味着什么：

### `live`

- 进入条件：
- 还不够构成 live 的证据：
- 对下游意味着什么：

### `promoted`

- 进入条件：
- promotion 必须依赖的 authority：
- 对下游意味着什么：

## 3. Reviewer Gate

- 一票否决型 blocker：
- 可后置但必须显式说明的风险：
- 只影响叙述质量、不影响主线推进的问题：

## 4. Common Narrative Traps

- 把局部结果误写成阶段闭合：
- 把 evidence-only artifact 误写成 consumer contract：
- 把 baseline / compare / smoke 误写成正式放行：
- 把 partial handoff 误写成 downstream-ready：

## 5. Common Failure Modes

- 词义混写：
- 证据错位：
- path / schema / runtime boundary 混写：
- 当前主线与旧路线混写：
```

## 使用原则

- 仓库特有术语放这里，不放进通用 `planner` / `executor` 模板
- 除了定义，还要写“什么不算”
- reviewer gate 要能直接用于判 blocker / 非 blocker

## 什么时候更新

只在仓库特有词义或 reviewer gate 真正变化时更新，例如：

- promotion ladder 的进入条件改变
- boundary pair 定义改变
- 某类误判已反复出现，需要成为稳定审查规则

## 不该放进来什么

- 通用协作礼仪
- 单轮 task 过程
- 长 why-not 报告
- 与词义 / gate 无关的运行参数
