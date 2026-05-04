# Runtime Contract v2

更新时间：`2026-04-21 03:26 UTC`

## 1. Canonical Entrypoints

- 当前 approved `M11` posture：`phase07_m11_telegram_active_detail_same_peer_draft_recovery_third_same_peer_refresh_before_first_reopen_preserve_slice_landed`
  - 这一步当前已是 latest landed same-package slice；其 landed truth 直接复用已闭合的 `M11` proof report / proof-round evidence bundle，不重跑测试，也不生成第二套 evidence bundle
  - `M11` 只在 `M10` 的 exact two-refresh same-peer preserve chain 上，再追加 exactly one same-peer refresh，总计三次 same-peer refresh before first reopen
  - `Phase07` 仍保持 exploratory-only；当前 `M11 landed` 不授权更宽 continuation family、repo-level promotion、或启动新的 bounded continuation slice

- 当前 `M10` landed posture：`phase07_m10_telegram_active_detail_same_peer_draft_recovery_repeated_same_peer_refresh_before_first_reopen_preserve_slice_landed`
  - 这一步当前已降为既有 landed Telegram consume checkpoint；其 landed truth 继续由 `M10` 自己的 landed report 与 proof-round evidence bundle承载
  - `M10` 只在 `M5` 的 one-hop same-peer refresh preserve 上，再追加 exactly one additional same-peer refresh，总计两次 same-peer refresh before first reopen
  - 它不再是当前 `latest_report` / `raw_log_root` 的来源

- 当前 `M9` landed posture：`phase07_m9_telegram_active_detail_same_peer_draft_recovery_refresh_reopen_then_direct_retarget_other_peer_drop_slice_landed`
  - 这一步已降为既有 landed checkpoint；`M8`、`M7`、`M6`、`M5`、`M4`、`M3`、`M2` 与 `P1-43` 继续保留为既有 checkpoint
  - `M10 landed` 当前消费的是更新后的 latest report / reused proof-round evidence bundle，而不是 `M9` 的旧 pointer pair

- 当前 `Phase07` Telegram build gate：`cd samples/telegram-ui-vertical-slice-001 && cjpm test`
- 当前 `Phase07` Telegram runtime / no-deadlock gate：`cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- 当前 cache sample build gate：`cd samples/real-message-service-cache-001 && cjpm test`
- 当前 cache sample runtime / no-deadlock gate：`timeout 5s bash -lc '... && cjpm test --skip-build'`
- 当前 mixed cache sample `5s` wrapper：`timeout 5s bash -lc '... && cjpm test'`
  - 它仍存在，但当前只保留为 observational compile-budget probe，不再是 pass/fail canonical gate
- 当前 `Phase05` keyless deterministic baseline 入口：`env -u SILICONFLOW_API_KEY bash scripts/run_mass_translation.sh docs/manifests/batch_manifest_phase05.json`
- 当前 `Phase05` fresh real translator baseline 入口：`bash scripts/run_mass_translation.sh docs/manifests/batch_manifest_phase05_fresh_real_translator.json`
  - 需要在受控 shell 中通过 `.env.local`、`SILICONFLOW_API_KEY` / `OPENAI_API_KEY` fallback 或 stdin 提供 key
- 当前不再推荐：把 `README.md` 里的泛化 phase 说明当作运行合同，或把 `P23` exploratory 资产当作 current input 重新点火。

## 2. Required Inputs

- 当前 `Phase07` Telegram consume 合同只认以下 repo-local source surface：
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_message_service_harness.cj`
  - `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`
  - `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`
- 当前 `Phase05` baseline 只认以下 manifest：
  - `docs/manifests/batch_manifest_phase05.json`
  - `docs/manifests/batch_manifest_phase05_fresh_real_translator.json`
- 当前 `Phase07` 规格与解释层输入固定为：
  - `specs/phase07-telegram-ui-incubation/{requirements,design,tasks}.md`
  - `docs/reports/2026-04-15-phase07-app-shell-consume-boundary.md`
  - `docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
  - `docs/reports/2026-04-15-phase07-p0-4-cache-sample-5s-gate-decision.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-freeze-draft.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-freeze-draft.md`
  - `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `docs/reports/2026-04-20-phase07-m9-telegram-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice.md`
  - `docs/reports/2026-04-20-phase07-m8-telegram-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice.md`
  - `docs/reports/2026-04-20-phase07-m7-telegram-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice.md`
  - `docs/reports/2026-04-20-phase07-m6-telegram-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice.md`
  - `docs/reports/2026-04-20-phase07-m5-telegram-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice.md`
  - `docs/reports/2026-04-20-phase07-m4-telegram-active-detail-same-peer-draft-recovery-slice.md`
  - `docs/reports/2026-04-18-phase07-m2-telegram-active-detail-usable-thread-slice.md`
  - `docs/reports/2026-04-18-phase07-p1-43-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence-consume-slice.md`
  - `docs/reports/2026-04-18-phase07-p1-42-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability-consume-slice.md`
  - `docs/reports/2026-04-18-phase07-p1-41-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-coherence-consume-slice.md`
  - `docs/reports/2026-04-18-phase07-p1-40-telegram-active-detail-warm-send-back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target-coherence-consume-slice.md`
  - `docs/reports/2026-04-18-phase07-p1-39-telegram-active-detail-warm-send-back-reopen-other-visible-conversation-stability-consume-slice.md`
  - `docs/reports/2026-04-18-phase07-p1-38-telegram-active-detail-warm-send-back-reopen-same-sent-target-then-direct-retarget-other-visible-conversation-coherence-consume-slice.md`
  - `docs/reports/2026-04-18-phase07-m1-telegram-warm-send-recovery-closure.md`
  - `docs/reports/2026-04-18-phase07-p1-34-telegram-active-detail-warm-send-back-list-route-send-noop-then-reopen-same-sent-target-coherence-consume-slice.md`
  - `docs/reports/2026-04-18-phase07-p1-33-telegram-active-detail-warm-send-back-list-route-send-noop-boundary-consume-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-32-telegram-active-detail-warm-send-back-reopen-sent-target-coherence-consume-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-31-telegram-active-detail-warm-send-retarget-alternating-reopen-bounded-stability-consume-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-30-telegram-active-detail-warm-send-retarget-back-reopen-original-sent-target-consume-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-29-telegram-active-detail-warm-send-retarget-coherence-consume-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-28-telegram-active-detail-warm-send-summary-coherence-consume-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-27-shared-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-26-shared-second-consumer-warm-send-append-without-refetch-parity-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-25-shared-second-consumer-same-peer-repeated-get-reuse-no-refetch-parity-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-24-shared-second-consumer-cold-send-seeded-pre-drain-fetch-parity-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-23-shared-second-consumer-pre-drain-invalidate-discard-parity-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-22-shared-second-consumer-invalidate-refetch-parity-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-21-shared-second-consumer-optimistic-signal-parity-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-18-active-detail-refresh-retarget-alternating-reopen-bounded-stability-consume-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-19-shared-worker-fetch-helper-unification-slice.md`
  - `docs/reports/2026-04-17-phase07-p1-20-shared-second-consumer-send-refresh-dispatch-parity-slice.md`
- 当前 formal checkpoint 仍只认：
  - `docs/reports/2026-04-14-phase06-p22-regular-promotion.md`
  - `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.json`
  - `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.validation.json`
  - `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r17.json`

## 3. Required Environment

- clean shell 下必须显式注入 repo-local 仓颉 toolchain：
  - `REPO_ROOT="/volume/wzhang/cky-workspace/my_projects/Cangjie"`
  - `export CANGJIE_HOME="$REPO_ROOT/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie"`
  - `export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH"`
  - `export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}"`
  - `export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std"`
- 对 `Phase05` fresh real translator 路径，当前允许的密钥提供方式只有：
  - 受控 shell 中预先 source `.env.local`
  - `SILICONFLOW_API_KEY`
  - `OPENAI_API_KEY`
  - stdin 注入
- `cjpm: command not found`、stdlib / runtime library 缺失、或路径未注入，都属于环境 blocker，不是当前 slice 的代码红灯。

## 4. Runtime Boundary

- `Phase07` 当前只证明 Linux `Staging-Core` 范围内的：
  - repo-local compile
  - repo-local unit / behavior test
  - bounded app-shell consume boundary
  它不证明更宽的非 repo-local deployment、broader repo lane 或 full-pass outcome。
- 当前 Telegram app-shell consume boundary 已冻结为 same-package 最小组合：
  - `TelegramSessionListPage`
  - `TelegramChatDetailPage`
  - `TelegramPageRouter` state
  - `buildTelegramAppShell(...)`
  它不允许引入 route generalization、视觉重设计、跨 sample 共享依赖扩散，或 IDE / DevEco assembly layer。
- shared harness landing host 现在是 `samples/phase07-shared-service-refresh-harness`；`samples/telegram-ui-vertical-slice-001` 只消费这层 shared surface，不再把自己当 shared harness 原位宿主。
- shared harness landing host 现在也拥有统一的 worker-side `runWorkerGetMessages(...)` helper；Telegram consumer 与 Phase07 second consumer 都通过这一个 shared helper 表达 fetch/drain/snapshot idiom，而不是继续保留 consumer-local 副本。
- `P1-20` 进一步证明同一个 second consumer 还能在不新增 shared worker-send helper 的前提下，沿现有 shared service surface 保持 `worker send -> main-context dataset refresh dispatch` 的最小 parity contract。
- `P1-21` 进一步证明同一个 second consumer 还能在不新增 shared API 的前提下，沿现有 shared `MessageSignal` / `sendMessage(...)` surface 保持 `worker send -> optimistic signal snapshot before main drain` 的最小 parity contract。
- `P1-22` 进一步证明同一个 second consumer 还能在不新增 shared helper/API 的前提下，沿现有 public `debugInvalidateCache(...)` / `getMessages(...)` / `MessageSignal.currentSnapshot()` surface 失效已 warmup 的 cache/signal 并 refetch replacement history，同时保持 observer delivery main-gated。
- `P1-23` 进一步证明同一个 second consumer 还能在不新增 shared helper/API 的前提下，沿现有 public `debugInvalidateCache(...)` / `getMessages(...)` / `debugDrainPromiseResolutions()` / `MessageSignal.currentSnapshot()` surface 丢弃 pre-drain 旧 pending fetch，并只允许 replacement refetch 成为后续唯一有效 handoff。
- `P1-24` 进一步证明同一个 second consumer 还能在不新增 shared helper/API 的前提下，沿现有 public `sendMessage(...)` / `getMessages(...)` / `debugDrainPromiseResolutions()` / `MessageSignal.currentSnapshot()` surface 先暴露 cold-send seeded local snapshot，再在 fetch promise drain 后切到 remote history，同时保持 observer delivery main-gated。
- `P1-25` 进一步证明同一个 second consumer 还能在不新增 shared helper/API 的前提下，沿现有 public `getMessages(...)` / `debugDrainPromiseResolutions()` / `MessageSignal.currentSnapshot()` / `MainContextDatasetRefreshBridge` surface 在 same-peer repeated get 场景复用已 warmup 的 signal/cache，不触发第二次 `adapter.getHistory(...)`，也不产生新的 refresh delivery。
- `P1-26` 进一步证明同一个 second consumer 还能在不新增 shared helper/API 的前提下，沿现有 public `getMessages(...)` / `sendMessage(...)` / `debugDrainPromiseResolutions()` / `MessageSignal.currentSnapshot()` / `MainContextDatasetRefreshBridge` surface 在 warm-send 场景把 payload 追加到已 warmup 的 signal/cache，而不触发第二次 `adapter.getHistory(...)`。
- `P1-27` 进一步证明同一个 second consumer 还能在不新增 shared helper/API 的前提下，沿现有 public `getMessages(...)` / `sendMessage(...)` / `debugDrainPromiseResolutions()` / `MessageSignal.currentSnapshot()` / `MainContextDatasetRefreshBridge` surface 在 warm-send 之后再次执行 same-peer `getMessages(...)` 读取时继续复用 append 后的 signal/cache，不触发第二次 `adapter.getHistory(...)`，也不新增额外 refresh delivery。
- `P1-28` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 shared `sendMessage(...)` / `MainContextDatasetRefreshBridge` surface 通过 `TelegramAppShell.sendMessageToActiveConversation(...)`、`TelegramSessionListPage.sendMessage(...)` 与 `TelegramSessionListController.sendMessage(...)` 首次消费 active-detail same-peer warm-send 路径，同时保持 detail route ownership、bounded history 与 summary coherence。
- `P1-29` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + active-detail `openConversation(...)` surface 把 same-peer warm-send 之后的 direct-retarget 路径冻结为 bounded consume contract：retarget 后 detail ownership 切到另一个 visible conversation，但原 target summary 继续保留 sent text / `messageCount = 3`，non-target summary 不被污染，且不新增 history refetch。
- `P1-30` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + active-detail `openConversation(...)` + `backFromDetail()` surface 把 same-peer warm-send 之后的 direct-retarget-back-reopen original-target 路径冻结为 bounded consume contract：back 后 detail getters 清空并回到 `TelegramSessionListPage`，reopen 原 sent target 后 detail ownership 重新绑定原目标，sent summary 继续保留 sent text / `messageCount = 3`，non-target summary 不被污染，且不新增 history refetch。
- `P1-31` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + active-detail `openConversation(...)` + `backFromDetail()` surface 把 same-peer warm-send 之后的 direct-retarget alternating-reopen 路径冻结为 bounded consume contract：两次 back 后 detail getters 都会清空并回到 `TelegramSessionListPage`，最终 reopen other visible conversation 后 detail ownership 绑定回另一条 visible conversation，原 sent target summary 继续保留 sent text / `messageCount = 3`，other visible summary 始终不被污染，且不新增 history refetch。
- `P1-32` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` surface 把 same-peer warm-send 之后的 direct-back-reopen same-target 路径冻结为 bounded consume contract：send 后 detail ownership 继续绑定原目标，back 后 detail getters 清空并回到 `TelegramSessionListPage`，reopen 同一个 sent target 后 detail ownership 重新绑定原目标，sent summary 继续保留 sent text / `messageCount = 3`，non-target summary 不被污染，且不新增 history refetch。
- `P1-39` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` + `openConversation(...)` surface 把 same-peer warm-send 之后的 back-reopen-other-visible-conversation 路径冻结为 bounded consume contract：第一次 back 后 detail getters 清空并回到 `TelegramSessionListPage`，随后 reopen 另一条 visible conversation 时 detail ownership 必须切到该 visible conversation，原 sent target summary 继续保留 sent text / `messageCount = 3`，reopened visible conversation summary 不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，且不新增 history refetch。
- `P1-40` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API、也不扩 generic send API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` + `openConversation(...)` surface 把 same-peer warm-send 之后的 back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target 路径冻结为 bounded consume contract：第一次 back 后 detail getters 清空并回到 `TelegramSessionListPage`，随后 reopen 另一条 visible conversation 时 detail ownership 先切到该 visible conversation，最后 direct retarget 回原 sent target 时 detail ownership 必须重新绑定原目标，原 sent target summary 继续保留 sent text / `messageCount = 3`，中间 reopened visible conversation summary 不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，且不新增 history refetch。
- `P1-41` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API、也不扩 generic send API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + active-detail `openConversation(...)` surface 把 same-peer warm-send 之后的 direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target 路径冻结为 bounded consume contract：send 后 detail ownership 继续绑定原 sent target，第一次 direct retarget 时 detail ownership 切到另一条 visible conversation，第二次 direct retarget 回原 sent target 时 detail ownership 重新绑定原目标，detail 全程停留在 `TelegramChatDetailPage`，原 sent target summary 继续保留 sent text / `messageCount = 3`，中间 other visible summary 在 send 与两次 retarget 前后都不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，`adapter.getHistoryCallCount()` 保持 `2`，且 git tracked baseline 不可用时从当前 verification surface 看未观察到 `telegram_app_shell.cj` / `telegram_ui_slice.cj` 的 `P1-41` 专属 widening。
- `P1-42` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API、也不扩 generic send API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + active-detail `openConversation(...)` + `backFromDetail()` surface 把 same-peer warm-send 之后的 direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation 路径冻结为 bounded consume contract：send 与两次 direct retarget 后 detail 全程继续停留在 `TelegramChatDetailPage`，第二次 direct retarget 回原 sent target 之后的 `backFromDetail()` 会清空 detail getters 并回到 `TelegramSessionListPage`，最终 reopen 另一条 visible conversation 后 detail ownership 绑定回该 visible conversation，historySize() 全程保持 `2`，原 sent target summary 继续保留 sent text / `messageCount = 3`，other visible summary 在最终 reopen 前后都不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，`adapter.getHistoryCallCount()` 保持 `2`，且 git tracked baseline 不可用时从当前 verification surface 看未观察到 `telegram_app_shell.cj` / `telegram_ui_slice.cj` 的 `P1-42` 专属 widening。
- `P1-43` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API、也不扩 generic send API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + active-detail `openConversation(...)` + `backFromDetail()` surface 把 same-peer warm-send 之后的 direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target 路径冻结为 bounded consume contract：send 与两次 direct retarget 后 detail 全程继续停留在 `TelegramChatDetailPage`，第二次 direct retarget 回原 sent target 之后的 `backFromDetail()` 会清空 detail getters 并回到 `TelegramSessionListPage`，最终 reopen 原 sent target 后 detail ownership 重新绑定回该 sent target，historySize() 全程保持 `2`，原 sent target summary 全程继续保留 sent text / `messageCount = 3`，other visible summary 在第二次 retarget 后、back 后与最终 reopen original sent target 后都不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，`adapter.getHistoryCallCount()` 保持 `2`，且 git tracked baseline 不可用时从当前 verification surface 看未观察到 `telegram_app_shell.cj` / `telegram_ui_slice.cj` 的 `P1-43` 专属 widening。
- `M2` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API、也不扩 generic send API 的前提下，把 `TelegramChatDetailPage` 从 placeholder-only detail 提升为 same-package real-history projection：controller 会沿现有 dataset refresh rail 保存 per-peer thread snapshot，detail page 会在 active detail route 下投影当前线程消息；打开 detail 后必须看到该会话当前消息列表，active-detail `sendMessageToActiveConversation(...)` 后 detail 线程必须立即追加新消息且 list summary 继续同步 sent text / `messageCount`，direct retarget 到另一条 visible conversation 后 detail 线程必须切到新目标，`backFromDetail()` 后 detail projection 必须清空，reopen 任一可见会话后 detail 线程必须恢复到正确 ownership；当前 verification surface 对应 same-package production edits 仅落在 `telegram_ui_slice.cj` / `telegram_app_shell.cj`，不构成 shared continuation、shared helper rollout 或 generic send expansion。
- `M3` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API、也不扩 generic send API 的前提下，把 `TelegramChatDetailPage` 从 usable-thread projection 提升为 same-package active-detail composer slice：detail page 现在会暴露本地 draft 状态并允许 shell 侧 `currentDetailDraft()` / `updateDetailDraft(...)` / `sendDetailDraft()` 消费；active-detail composer send 会复用现有 `TelegramSessionListPage.sendMessage(...)` 路径把 draft 文本追加到当前投影线程、继续同步 list summary 的 sent text / `messageCount` 并清空 draft；list-route composer update/send 必须 no-op；direct retarget 到另一条 visible conversation、`backFromDetail()` 回列表以及随后 reopen 任一会话都必须把 draft 重置为 empty，同时保持线程 ownership 不漂移；当前 verification surface 对应 same-package production edits 仍只落在 `telegram_ui_slice.cj` / `telegram_app_shell.cj`，不构成 per-peer draft persistence rollout、shared continuation、shared helper rollout 或 generic send expansion。
- `M4` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API、也不扩 generic send API 的前提下，把 `TelegramChatDetailPage` 从 same-package active-detail composer slice 提升为 bounded same-peer draft recovery slice：detail page 现在会在 `backFromDetail()` 返回 list 且当前 active detail 持有未发送 draft 时武装一个单槽、short-lived、peer-bound recovery slot；随后只有首次 same-peer reopen 才允许恢复该 draft 且必须立即消费 slot；`sendDetailDraft()` 成功发送后、direct retarget 到其他 peer、以及 `backFromDetail()` 后 reopen 另一条 visible conversation 都必须清空 draft / slot；list-route `currentDetailDraft()` 仍只暴露 empty，`updateDetailDraft(...)` / `sendDetailDraft()` 仍必须 strict pure no-op，不得创建、恢复、消费、泄漏或清空 recovery slot；当前 verification surface 对应 same-package production edits 仍只落在 `telegram_ui_slice.cj` / `telegram_app_shell.cj` / `telegram_ui_vertical_slice_test.cj`，不构成 per-peer draft persistence rollout、shared continuation、shared helper rollout 或 generic send expansion。
- `M5` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API、也不扩 generic send API 的前提下，把 `M4` 已落地的 same-peer recovery surface 提升为 bounded refresh-before-reopen coherence slice：当 `backFromDetail()` 已武装单槽 same-peer recovery slot 后，一次 list-route same-peer `refreshConversation(peer, limit)` 仍只允许沿既有 refresh rail 更新 refreshed summary，不得暴露 draft，也不得创建、恢复、消费、清空或改写 recovery slot；随后只有首次 reopen 同一条 refreshed visible conversation 才允许恢复该 draft 并立即消费 slot；恢复后的 `sendDetailDraft()` 仍必须清空 draft / slot，而 list-route `currentDetailDraft()`、`updateDetailDraft(...)` 与 `sendDetailDraft()` 仍保持 strict pure no-op。当前 verification surface 说明这条更窄的 M5 edge 已由既有 `M4` same-package production code 满足，本轮 landed 只新增 regression locks、evidence 与 state sync，不构成 broader refresh family、per-peer draft persistence、shared continuation、shared helper rollout 或 generic send expansion。
- `P1-38` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` + `openConversation(...)` surface 把 same-peer warm-send 之后的 back-reopen-same-target-then-direct-retarget 路径冻结为 bounded consume contract：same-target recovery reopen 之后再 direct retarget 到另一条 visible conversation 时，detail ownership 必须切到新目标，原 sent target summary 继续保留 sent text / `messageCount = 3`，retarget 目标 summary 不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，且不新增 history refetch。
- `P1-33` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` surface 把 same-peer warm-send 之后的 back-to-list send-noop 边界冻结为 bounded consume contract：一旦 shell 已经回到 `TelegramSessionListPage`，后续 list-route `sendMessageToActiveConversation("should-not-send")` 必须 no-op，detail getters 继续为空，sent summary 继续保留 sent text / `messageCount = 3`，non-target summary 不被污染，`adapter.sendMessageCallCount()` 不得增长到 `2`，且不新增 history refetch。
- `P1-34` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` + `openConversation(...)` surface 把 same-peer warm-send 之后的 back-to-list send-noop-then-reopen same-target 路径冻结为 bounded consume contract：list-route `sendMessageToActiveConversation("should-not-send")` 继续 no-op，随后 reopen 同一个 sent target 后 detail ownership 重新绑定原目标，sent summary 继续保留 sent text / `messageCount = 3`，non-target summary 不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，且不新增 history refetch。
- `P1-35` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` + `openConversation(...)` surface 把 same-peer warm-send 之后的 back-to-list send-noop-then-reopen other-visible-conversation 路径冻结为 bounded consume contract：list-route `sendMessageToActiveConversation("should-not-send")` 继续 no-op，随后 reopen 另一条 visible conversation 后 detail ownership 绑定到该 visible conversation，原 sent target summary 继续保留 sent text / `messageCount = 3`，other visible summary 不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，且不新增 history refetch。
- `P1-36` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` + `openConversation(...)` surface 把 same-peer warm-send 之后的 back-to-list send-noop-reopen-same-target-then-direct-retarget 路径冻结为 bounded consume contract：same-target recovery reopen 之后再 direct retarget 到另一条 visible conversation 时，detail ownership 必须切到新目标，原 sent target summary 继续保留 sent text / `messageCount = 3`，retarget 目标 summary 不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，且不新增 history refetch。
- `P1-37` 进一步证明 Telegram app-shell 还能在不新增 shared helper/API 的前提下，沿现有 `TelegramAppShell.sendMessageToActiveConversation(...)` + `backFromDetail()` + `openConversation(...)` surface 把 same-peer warm-send 之后的 back-to-list send-noop-reopen-same-target-back-then-reopen-other-visible-conversation 路径冻结为 bounded consume contract：same-target recovery reopen 之后第二次 back 仍会清空 detail getters 并回到 `TelegramSessionListPage`，最终 reopen 另一条 visible conversation 后 detail ownership 绑定到该 visible conversation，原 sent target summary 继续保留 sent text / `messageCount = 3`，other visible summary 不被污染，`adapter.sendMessageCallCount()` 仍为 `1`，且不新增 history refetch。
- 当前 approved step 已推进到 `M11 Telegram Active-Detail Same-Peer Draft Recovery Third Same-Peer Refresh Before First-Reopen Preserve Slice landed`。与此同时，当前 Telegram consume entry / latest landed report 已切到 `M11` landed report，当前 `raw_log_root` 已切到现有 `M11` proof-round evidence bundle；`M11` proof report 继续只作为 supporting proof surface；`M10`、`M9`、`M8`、`M7`、`M6`、`M5`、`M4`、`M3`、`M2` 与 `P1-43` 保留为已落地 checkpoint；当前 latest shared-harness checkpoint 仍停在 `P1-27`。
- `Phase05` baseline 继续承担翻译 / verifier guardrail，不应被写成 `Phase07` 的继续推进证据。
- mixed `timeout 5s ... cjpm test` 只用于观测 compile budget；当前 runtime/no-deadlock contract 明确不依赖它给出绿色。

## 5. Consume Boundary

- 当前 formal truth consume surface 仍是：
  - `AGENTS.md`
  - `.claude/status/current-phase.md`
  - `docs/reports/2026-04-14-phase06-p22-regular-promotion.md`
  - `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21*.json`
- 当前 active continuation-lane consume surface 是：
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-freeze-draft.md`
  - `docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - `docs/reports/2026-04-20-phase07-m9-telegram-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m9-active-detail-same-peer-draft-recovery-refresh-reopen-then-direct-retarget-other-peer-drop-slice/`
  - `docs/reports/2026-04-20-phase07-m8-telegram-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m8-active-detail-same-peer-draft-recovery-other-peer-refresh-then-same-peer-refresh-no-restore-slice/`
  - `docs/reports/2026-04-20-phase07-m7-telegram-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m7-active-detail-same-peer-draft-recovery-same-peer-refresh-then-other-peer-drop-slice/`
  - `docs/reports/2026-04-20-phase07-m6-telegram-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m6-active-detail-same-peer-draft-recovery-other-peer-refresh-drop-boundary-slice/`
  - `docs/reports/2026-04-20-phase07-m5-telegram-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m5-active-detail-same-peer-draft-recovery-refresh-before-reopen-coherence-slice/`
  - `docs/reports/2026-04-20-phase07-m4-telegram-active-detail-same-peer-draft-recovery-slice.md`
  - `artifacts/verification_contracts/20260420-phase07-telegram-m4-active-detail-same-peer-draft-recovery-slice/`
  - `docs/reports/2026-04-18-phase07-m3-telegram-active-detail-composer-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-m3-active-detail-composer-slice/`
  - `docs/reports/2026-04-18-phase07-m2-telegram-active-detail-usable-thread-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-m2-active-detail-usable-thread-slice/`
  - `docs/reports/2026-04-18-phase07-p1-43-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-43-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-original-sent-target-coherence/`
  - `docs/reports/2026-04-18-phase07-p1-42-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-42-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-back-reopen-other-visible-conversation-bounded-stability/`
  - `docs/reports/2026-04-18-phase07-p1-41-telegram-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-41-active-detail-warm-send-direct-retarget-other-visible-conversation-then-direct-retarget-original-sent-target-coherence/`
  - `docs/reports/2026-04-18-phase07-p1-40-telegram-active-detail-warm-send-back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-40-active-detail-warm-send-back-reopen-other-visible-conversation-then-direct-retarget-original-sent-target-coherence/`
  - `docs/reports/2026-04-18-phase07-p1-39-telegram-active-detail-warm-send-back-reopen-other-visible-conversation-stability-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-39-active-detail-warm-send-back-reopen-other-visible-conversation-stability/`
  - `docs/reports/2026-04-18-phase07-p1-38-telegram-active-detail-warm-send-back-reopen-same-sent-target-then-direct-retarget-other-visible-conversation-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-38-active-detail-warm-send-back-reopen-same-sent-target-then-direct-retarget-other-visible-conversation-coherence/`
  - `docs/reports/2026-04-18-phase07-m1-telegram-warm-send-recovery-closure.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-m1-warm-send-recovery-closure/`
  - `docs/reports/2026-04-18-phase07-p1-34-telegram-active-detail-warm-send-back-list-route-send-noop-then-reopen-same-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-34-active-detail-warm-send-back-list-route-send-noop-then-reopen-same-sent-target-coherence/`
  - `docs/reports/2026-04-18-phase07-p1-33-telegram-active-detail-warm-send-back-list-route-send-noop-boundary-consume-slice.md`
  - `artifacts/verification_contracts/20260418-phase07-telegram-p1-33-active-detail-warm-send-back-list-route-send-noop-boundary/`
  - `docs/reports/2026-04-17-phase07-p1-32-telegram-active-detail-warm-send-back-reopen-sent-target-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-32-active-detail-warm-send-back-reopen-sent-target-coherence/`
  - `docs/reports/2026-04-17-phase07-p1-31-telegram-active-detail-warm-send-retarget-alternating-reopen-bounded-stability-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-31-active-detail-warm-send-retarget-alternating-reopen-bounded-stability/`
  - `docs/reports/2026-04-17-phase07-p1-30-telegram-active-detail-warm-send-retarget-back-reopen-original-sent-target-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-30-active-detail-warm-send-retarget-back-reopen-original-sent-target/`
  - `docs/reports/2026-04-17-phase07-p1-29-telegram-active-detail-warm-send-retarget-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-29-active-detail-warm-send-retarget-coherence/`
  - `docs/reports/2026-04-17-phase07-p1-28-telegram-active-detail-warm-send-summary-coherence-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-28-active-detail-warm-send-summary-coherence/`
  - `docs/reports/2026-04-17-phase07-p1-27-shared-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-27-second-consumer-warm-send-repeated-get-reuse-no-refetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-26-shared-second-consumer-warm-send-append-without-refetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-26-second-consumer-warm-send-append-without-refetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-25-shared-second-consumer-same-peer-repeated-get-reuse-no-refetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-25-second-consumer-same-peer-repeated-get-reuse-no-refetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-24-shared-second-consumer-cold-send-seeded-pre-drain-fetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-24-second-consumer-cold-send-seeded-pre-drain-fetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-23-shared-second-consumer-pre-drain-invalidate-discard-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-23-second-consumer-pre-drain-invalidate-discard-parity/`
  - `docs/reports/2026-04-17-phase07-p1-22-shared-second-consumer-invalidate-refetch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-22-second-consumer-invalidate-refetch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-21-shared-second-consumer-optimistic-signal-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-21-second-consumer-optimistic-signal-parity/`
  - `docs/reports/2026-04-17-phase07-p1-20-shared-second-consumer-send-refresh-dispatch-parity-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-20-second-consumer-send-refresh-dispatch-parity/`
  - `docs/reports/2026-04-17-phase07-p1-19-shared-worker-fetch-helper-unification-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`
  - `docs/reports/2026-04-17-phase07-p1-18-active-detail-refresh-retarget-alternating-reopen-bounded-stability-consume-slice.md`
  - `artifacts/verification_contracts/20260417-phase07-telegram-p1-18-active-detail-refresh-retarget-alternating-reopen-bounded-stability/`
  - `samples/telegram-ui-vertical-slice-001/**`
  - `samples/phase07-shared-service-refresh-harness/**`
  - `samples/real-message-service-cache-001/**`
- 当前 explicit forbidden consume surface：
  - `raw_docs/phase06-ui-p23`
  - `docs/manifests/phase06_ui_*_p23*.json`
  - `artifacts/ui_pilots/20260414-phase06-ui-p23-*`
  这些只能当 exploratory evidence，不能重新进入 current input。
- 更宽的非 repo-local / full-pass artifacts 仍是独立历史证据面，不应被当前 `Phase07` repo-local sample consume 直接继承。

## 6. Validation / Smoke

- 当前 `M11 landed` 合同：
  - `M11` 当前 landed report：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `M11` 当前 supporting proof report：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `M11` 当前 raw evidence bundle：`artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - `M11` 当前 posture：`landed`
  - `M11` 只冻结“在 M10 的 exact two-refresh same-peer preserve chain 上，再追加 exactly one same-peer refresh；总计三次 same-peer refresh before first reopen”
  - `M11` 当前 `latest_report` 已切到 landed report，`raw_log_root` 已切到现有 proof-round evidence bundle；这是 landed truth sync 对既有 proof-round report / evidence 的直接复用，而不是二次 rerun

- 当前 `M10 landed` 合同：
  - `M10` 当前 landed report：`docs/reports/2026-04-21-phase07-m10-telegram-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice.md`
  - `M10` 当前 supporting proof bundle：`artifacts/verification_contracts/20260421-phase07-telegram-m10-active-detail-same-peer-draft-recovery-repeated-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - `M10` 继续作为既有 landed checkpoint 被保留，但不再占用当前 `latest_report` / `raw_log_root`

- 当前 `M11 supporting proof-round` 合同：
  - `M11` 当前 proof report：`docs/reports/2026-04-21-phase07-m11-telegram-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round.md`
  - `M11` 当前 proof evidence bundle：`artifacts/verification_contracts/20260421-phase07-telegram-m11-active-detail-same-peer-draft-recovery-third-same-peer-refresh-before-first-reopen-preserve-slice-proof-round/`
  - 该 proof surface 证明 exact third same-peer refresh preserve chain 已在 same-package rail 闭合，并被当前 `M11 landed` 直接复用

- 当前 Telegram `M11` canonical build gate：
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - 当前 `M11 landed` 复用的 proof-round 证据是 `TOTAL: 64`、`PASSED: 64`、`FAILED: 0`
- 当前 Telegram `M11` canonical runtime / no-deadlock gate：
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - 当前 `M11 landed` 复用的 proof-round 证据同样是 `TOTAL: 64`、`PASSED: 64`、`FAILED: 0`
- 当前 cache sample canonical build gate：
  - `cd samples/real-message-service-cache-001 && cjpm test`
  - 当前 `P1-27` 证据是 `TOTAL: 34`、`PASSED: 34`、`FAILED: 0`
- 当前 cache sample canonical runtime / no-deadlock gate：
  - `timeout 5s bash -lc '... && cjpm test --skip-build'`
  - 当前冻结证据仍沿用前序 checkpoint 的 `TOTAL: 26`、`PASSED: 26`、`FAILED: 0`；`P1-27` 本轮未重跑 `--skip-build` runtime gate
- 当前 mixed cache sample `5s` wrapper：
  - `timeout 5s bash -lc '... && cjpm test'`
  - 当前返回 `124`
  - 只代表 compile-budget known risk，不代表 runtime deadlock
- 当前 `Phase05` 双 baseline 事实：
  - `artifacts/batch_runs/telegramharmony-phase05-mass-translation-initialization/batch-summary.json` 记录 `10/10 passed`
  - `artifacts/batch_runs/telegramharmony-phase05-mass-translation-fresh-real-translator/batch-summary.json` 记录 `10/10 passed`

## 7. Failure Taxonomy / Escalation

- environment blocker：
  - `cjpm: command not found`
  - missing `CANGJIE_HOME`
  - missing `LD_LIBRARY_PATH`
  - missing `CANGJIE_STDLIB_PATH`
  这些先解释为 shell / toolchain 注入失败，不应立即归因到当前代码切片。
- compile failure：
  - `cjpm test` 非零退出
  - `telegram_ui_vertical_slice_001` 二进制未产出
  这些说明 build/link 边界没有闭合。
- unit failure：
  - `@TestCase` 断言失败
  - sample/package regression 出现红灯
  这些说明逻辑 contract 破裂，但仍区别于 runtime hang。
- behavior failure：
  - `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` 非零退出
  - `timeout 5s ... cjpm test --skip-build` 非零退出
  这些才属于 runtime / no-deadlock contract 红灯。
- compile-budget known risk：
  - mixed `timeout 5s ... cjpm test = 124`
  当前只允许被解释为 build budget 问题，不能升级成 runtime deadlock。
- translator / provider 噪声：
  - `Phase05` fresh real translator 路径中的 key / network / provider 问题
  这些可以影响 baseline rerun，但不应直接改写 `Phase07` 的 repo-local consume 结论。
- 任何涉及：
  - 改写 `P22 / 311/311`
  - 重开 `P23`
  - 重新使用 p23 exploratory 资产作为 current input
  - 把 `Phase07` 写成 broader non-repo-local rollout / full-pass outcome
  都必须先升级给 reviewer / 用户。

## 更新规则

只有当运行合同变化时才更新本文件。
