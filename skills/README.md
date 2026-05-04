# Skill 目录

用于存放项目自建的 Skill 内容、模板或转换结果。

当前建议：

- 先定义最小 Skill 单元模板；
- 再逐步补齐鸿蒙应用开发相关 Skill；
- 如果后续决定兼容官方 `.opencode/skills/` 结构，再统一调整目录布局。

当前已建立：

- `SKILL_SCHEMA_V1.md`
  - 鸿蒙仓颉应用 Skill 的统一字段定义、渐进式披露结构、检索降级与测试排错规范。
- `ui-list-grid-layout.md`
  - 面向 ArkUI List / Grid 场景的仓颉映射 Skill，覆盖状态绑定、列表渲染、双列网格降级策略与调试方法。
- `page-routing-and-param-passing.md`
  - 面向页面跳转与参数传递场景的仓颉映射 Skill，覆盖路由适配层、详情读参与返回行为的测试策略。
- `data-persistence-preferences.md`
  - 面向用户首选项持久化场景的仓颉映射 Skill，覆盖默认值回退、显式落盘、页面恢复、检索降级与单测设计。
