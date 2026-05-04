# Runtime Contract Template

这个文件承载“当前运行态合同”。
它回答的是“怎么跑、最低成功条件是什么、下游可以依赖什么输出”，而不是项目战略或 owner 路线。

## 推荐结构

```markdown
# Runtime Contract

更新时间：`YYYY-MM-DD`

## 1. Canonical Entrypoints

- 主入口命令：
- 辅助入口命令：
- 不再推荐的旧入口：

## 2. Required Inputs

- 必需输入文件 / manifest：
- 必需目录结构：
- 输入前置校验：

## 3. Required Environment

- 必需 env：
- 必需 PATH / toolchain：
- 缺失时的失败信号：

## 4. Runtime Boundary

- 明确会消费的字段 / 路径：
- 明确不会消费的字段 / 路径：
- 哪些只是 evidence-only，不是 runtime blocker：

## 5. Verification Ladder

- 最小 smoke：
- 有代表性的 bounded verification：
- 必做回归：
- 通过标准：

## 6. Consumer-Facing Outputs

- 产物路径：
- 字段级合同：
- 下游可依赖的最小面：

## 7. Failure Taxonomy And Escalation

- 常见失败类型：
- 哪些可以本地重试：
- 哪些必须升级：
```

## 使用原则

- 用合同语言写，不用周报语言写
- 明确 runtime 真正依赖什么，不依赖什么
- 尽量把“consumer-facing 可依赖面”写清，避免下游自己猜

## 什么时候更新

只在运行合同变化时更新，例如：

- canonical 命令变化
- 必需 env / toolchain 变化
- runtime boundary 变化
- consume boundary 变化
- smoke gate / regression gate 变化

## 不该放进来什么

- owner 路线
- 审查结论长叙事
- 阶段战略
- 与运行时无关的 planning / strategy 讨论
- 非当前合同需要的历史 artifacts
