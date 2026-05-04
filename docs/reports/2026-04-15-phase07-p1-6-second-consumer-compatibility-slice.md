# 2026-04-15 Phase07 P1-6 Second-Consumer Compatibility Slice

## Goal

Prove that the `Phase07` shared service / refresh surface is no longer a Telegram-only same-package landing by wiring one repo-local second consumer with the minimum packaging and import changes.

## Packaging / Import Strategy

- Shared harness landing path:
  - `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`
- Package wiring:
  - `samples/telegram-ui-vertical-slice-001/cjpm.toml`
  - `samples/real-message-service-cache-001/cjpm.toml`
  - both consume the shared harness through the local dependency `phase07_shared_service_refresh_harness = { path = "../phase07-shared-service-refresh-harness" }`
- Telegram consumer direction:
  - the existing Telegram sample keeps its current package and behavior scope
  - `telegram_message_service_harness.cj`, `telegram_ui_slice.cj`, `telegram_app_shell.cj`, and `telegram_ui_vertical_slice_test.cj` only rebind to the repo-local shared package
- Second-consumer direction:
  - `samples/real-message-service-cache-001` proves compatibility through the additive regression `src/phase07_second_consumer_compatibility_test.cj`
  - the cache sample uses alias-imports from the shared package instead of a wholesale rewrite of `real_message_service_cache_harness.cj`

## Why This Round Stops Here

- `P1-6` only proves repo-local shared-harness compatibility across two consumers.
- This round does not reopen `P1-5`, does not expand Telegram router/page/controller semantics, and does not introduce shell-level refresh surface beyond what `P1-5` already landed.
- This round also does not turn into workspace or build-system refactoring; the only build-level change is the bounded local `cjpm` path dependency.

## Verification

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - exit `0`
  - `TOTAL: 6`, `PASSED: 6`, `FAILED: 0`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
  - exit `0`
  - `TOTAL: 6`, `PASSED: 6`, `FAILED: 0`
- `cd samples/real-message-service-cache-001 && cjpm test`
  - exit `0`
  - `TOTAL: 26`, `PASSED: 26`, `FAILED: 0`
  - includes `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldSupportCacheSampleAsSecondConsumer`
- `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test'`
  - exit `124`
- diagnostic classification:
  - `timeout 5s bash -lc 'cd samples/real-message-service-cache-001 && cjpm test --skip-build'` -> exit `0`, `TOTAL: 26`, `PASSED: 26`, `FAILED: 0`

## Outcome

- `second consumer 已落地`
- The remaining controlled-shell red point is currently classified as a build-time budget risk under the 5-second wrapper, not as a packaging blocker and not as evidence of a new runtime deadlock introduced by the shared harness relocation.
