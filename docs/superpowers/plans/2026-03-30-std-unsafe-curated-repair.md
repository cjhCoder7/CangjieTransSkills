# Std Unsafe Curated Repair Plan

1. 确认 `std.unsafe` repair 约束当前缺口。
2. 加固静态墙 `static-unsafe-keyword` repair hint。
3. 在 `orchestrator` 注入 `std.unsafe` 三层回灌警告。
4. 在 `prompt_assembler` 新增动态 repair 指令区。
5. 运行临时红绿测试，确认三层指令已进 stderr 和 prompt。
6. 如验证通过，再发起下一轮真实流水线。
