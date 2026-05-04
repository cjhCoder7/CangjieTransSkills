# 2026-04-15 Phase07 P1-5 Shell Refresh Consume Slice

## Goal

Land the first same-package app-shell refresh consume slice for `samples/telegram-ui-vertical-slice-001` without widening router/page/controller scope or reopening shared-harness extraction.

## Decision

- Landing path: `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
- Consumption direction: `TelegramAppShell.refreshConversation(peerId, limit)` delegates directly to the existing `TelegramSessionListPage.refreshConversation(peerId, limit)`
- Regression lock: `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`

## Why This Round Stops Here

- `P1-5` only upgrades shell refresh from deferred to explicit consume surface plus mandatory regression gate.
- This round does not widen into router/page/controller redesign, shell-level generic refresh orchestration, or cross-sample shared consumption.
- `samples/real-message-service-cache-001` remains untouched because the existing same-package shared harness plus Telegram sample already provide the minimum closed loop.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test` -> exit `0`, `TOTAL: 6`, `PASSED: 6`, `FAILED: 0`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` -> exit `0`, `TOTAL: 6`, `PASSED: 6`, `FAILED: 0`
- Runtime binary: `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
