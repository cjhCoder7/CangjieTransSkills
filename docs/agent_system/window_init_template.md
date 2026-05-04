# Window Init Template

每次新开窗口时，只注入本轮真正影响判断的动态变量。
不要把项目长期历史重新灌一遍，也不要让它代替 `task_handoff`。

## 推荐模板

```text
[Window Role]
- active_role:
- owner:
- why_this_window_exists:

[Objective]
- objective:
- done_when:

[Scope]
- in_scope:
- out_of_scope:
- current_approved_slice:

[Authoritative Inputs]
- must_read:
  - AGENTS / role prompt / current_state / runtime_contract / domain_review_rubric / task_handoff
- source_paths:
- approved_artifacts:
- current_summary:

[Constraints]
- must:
- forbidden:
- do_not_reopen:
- escalation_when:
- context_budget:

[Verification]
- required_tests:
- required_smoke:
- evidence_required:
- unacceptable_shortcuts:

[Output Contract]
- required_sections:
- required_links_or_paths:
- max_density:
```

## 使用规则

- 只填本轮会影响判断的变量
- 只允许收窄，不允许覆写宪法
- 优先引用 `task_handoff` 和 `current_state`，不要重复粘贴大段旧上下文
- 若字段过长，优先写摘要 + 路径，不贴整屏原文

## 与 `task_handoff` 的区别

- `task_handoff`
  - 当前 task 的持续状态
- `window_init`
  - 这次开窗要带进去的动态变量

如果一个字段在下一次开窗仍然应该保留，它更可能属于 `task_handoff`，而不是 `window_init`。
