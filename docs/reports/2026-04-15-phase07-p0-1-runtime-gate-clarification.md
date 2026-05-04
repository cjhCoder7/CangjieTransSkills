# 2026-04-15 Phase07 P0-1 Runtime Gate Clarification

## Goal

Clarify the effective runtime gate for `samples/telegram-ui-vertical-slice-001` after the P0-1 shared harness split, without changing any `Phase06`, `P23`, promotion, or live wording.

## Clarification

- `timeout 5s cjpm test` is a mixed build-and-startup budget check for `samples/telegram-ui-vertical-slice-001`.
- It does not isolate runtime deadlock behavior because it includes package startup, compile, link, and test-runner launch costs in the same 5-second budget.
- For this sample, the effective runtime no-deadlock gate is now:
  1. first complete one controlled-shell `cjpm test` build and test pass;
  2. then execute `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`.

## Effective Commands

- Build and test gate:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
- Runtime no-deadlock gate after build:
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`

## Boundary

- This clarification applies only to the repo-local `Phase07 Telegram UI Incubation` sample gate.
- It does not change `P22 / 311/311 live passed`.
- It does not change `P23 mechanical-ready = No`.
- It does not create any new `Phase06 regular`, promotion, live, or Windows `Staging-Full` claim.
