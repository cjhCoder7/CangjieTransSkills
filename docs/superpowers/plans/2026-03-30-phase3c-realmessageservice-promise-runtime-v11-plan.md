# Phase 3C RealMessageService Promise Runtime V11 Plan

- [ ] 复核 ArkTS `getMessages / fetchMessages / sendMessage` 的 Promise 语义边界
- [ ] 在 harness 内增加 package-local Promise resolution queue
- [ ] 保持 public whitelist 不变，不发明新的 public Promise API
- [ ] 新增 V11 红灯测试：seeded signal / fetch drain / UI queue
- [ ] 新增 V11 红灯测试：send promise trace settlement
- [ ] 适配现有测试 helper，使历史用例显式 drain fetch promise
- [ ] 跑 `phase3_source_alignment_asserts.py`
- [ ] 跑 `cjpm test`
- [ ] 跑 `timeout 5s ... cjpm test`
- [ ] 回写 contract matrix / trace / evidence
