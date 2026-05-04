# 2026-04-18 Phase07 M2 Telegram Active-Detail Usable Thread Slice

## Goal

Land `M2 Telegram Active-Detail Usable Thread Slice` inside `samples/telegram-ui-vertical-slice-001` by promoting `TelegramChatDetailPage` from placeholder-only detail to same-package real-history projection: when a visible conversation is opened into detail, the page must project that conversation's current thread; active-detail send must append into the projected thread immediately; direct retarget / back / reopen must preserve projected thread ownership without reopening shared harness work or widening the generic send surface.

## Decision

- landing path:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
  - `specs/phase07-telegram-ui-incubation/tasks.md`
  - `docs/reports/2026-04-15-phase07-app-shell-consume-boundary.md`
  - `docs/reports/2026-04-18-phase07-m2-telegram-active-detail-usable-thread-slice.md`
  - `docs/status/current_committed_plan.md`
  - `docs/status/INDEX.md`
  - `docs/current_state.v2.md`
  - `docs/runtime_contract.v2.md`
  - `docs/status/current_task_handoff.md`
  - `docs/agent_system/execution_routing.md`
  - `AGENTS.md`
- milestone scope:
  - real-history projection on open detail:
    - regression lock: `appShellOpenDetailShouldProjectRealHistoryForActiveConversation`
  - active-detail send appends into projected thread while list summary stays coherent:
    - regression lock: `appShellActiveDetailSendShouldAppendIntoProjectedThreadWithoutBreakingSummaryCoherence`
  - direct retarget / back / reopen keep projected thread ownership coherent:
    - regression lock: `appShellRetargetBackReopenShouldKeepProjectedThreadOwnershipCoherent`
- boundary distinction:
  - `P1-43` remains a landed checkpoint for bounded warm-send / retarget / back-reopen coherence.
  - `M2` is the next same-package Telegram UI milestone: it stops pursuing sibling route permutations and instead upgrades detail consumption from placeholder-only to usable thread projection.
  - This round still does not touch `samples/phase07-shared-service-refresh-harness/**`, `samples/real-message-service-cache-001/**`, `P23`, shared helper/API, or generic send abstraction.

## Production Changes

- `TelegramSessionListController` now stores same-package per-peer thread snapshots alongside conversation summaries, using the already-landed dataset refresh flow rather than introducing any new shared helper/API.
- `TelegramSessionListPage` now exposes those per-peer thread snapshots to same-package consumers.
- `TelegramChatDetailPage` now consumes the active route's peer plus controller-kept thread snapshots through `projectedMessages()`, while keeping the old placeholder body contract available as a secondary compatibility surface.
- `TelegramAppShell` now exposes `currentDetailMessages()` so shell-level regressions can assert the projected thread directly.

## Behavior Frozen By M2

- Opening a visible conversation into detail now projects the active conversation's current real history instead of exposing only title / peer / placeholder body.
- While detail is active, `sendMessageToActiveConversation(...)` immediately appends the new message into the projected thread and continues to keep the target list summary synchronized with sent text and `messageCount`.
- Direct retarget to another visible conversation switches the projected thread to the new target.
- `backFromDetail()` still clears detail projection.
- Reopening any visible conversation after back restores the correct projected thread for that conversation.

## Why This Round Stops Here

- `M2` only upgrades same-package Telegram detail consumption to usable thread projection.
- It does not widen into broader UI redesign, shared continuation, shared helper rollout, generic send expansion, Harmony live / promoted wording, or any non-repo-local claim.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 37`, `PASSED: 37`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-m2-active-detail-usable-thread-slice/cjpm-test.log`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 37`, `PASSED: 37`, `FAILED: 0`
  - log: `artifacts/verification_contracts/20260418-phase07-telegram-m2-active-detail-usable-thread-slice/timeout-unittest.log`
- verification-side support logs:
  - case existence: `artifacts/verification_contracts/20260418-phase07-telegram-m2-active-detail-usable-thread-slice/case-existence.log`
  - git scope visibility: `artifacts/verification_contracts/20260418-phase07-telegram-m2-active-detail-usable-thread-slice/git-scope-check.log`

## Runtime Artifact

- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- evidence bundle:
  - `artifacts/verification_contracts/20260418-phase07-telegram-m2-active-detail-usable-thread-slice/`

## Outcome

- `M2` now becomes the current latest Telegram consume entry while the latest shared-harness checkpoint remains `P1-27`.
- `P1-43` remains a landed bounded checkpoint, but `M2` is the current answer for the more usable same-package Telegram detail direction.
- The milestone remains exploratory-only input within `Phase07 Telegram UI Incubation`; it does not authorize shared-helper expansion, generic send expansion, or broader repo-scope escalation wording.
