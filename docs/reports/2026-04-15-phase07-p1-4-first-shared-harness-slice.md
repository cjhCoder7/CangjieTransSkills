# 2026-04-15 Phase07 P1-4 First Shared Harness Slice

## Target Path

- shared harness landing path:
  - `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`
- superseded note:
  - the original same-package landing used during the first `P1-4` cut was later relocated by `P1-6` into the repo-local shared package above; this note now records the surviving landing path rather than the transient Telegram-local path

## Consume Direction

- the extracted service / refresh shared surface is now hosted in package `phase07_shared_service_refresh_harness`
- `samples/telegram-ui-vertical-slice-001` continues to consume the shared surface through repo-local `cjpm` path dependency and package imports
- this slice still does not widen app-shell/router/page/controller scope beyond the original `P1-4` boundary

## Why This Turn Does Not Touch P1-5

- `P1-4` is limited to the first minimum extractable write set frozen by `docs/reports/2026-04-15-phase07-shared-harness-module-boundary.md`
- `P1-5` owns the future shell-level refresh consume slice, so this turn must not widen `telegram_app_shell.cj` or add shell refresh surface

## Why This Turn Does Not Force Cache-Sample Dual Consumption

- the current goal is the smallest repo-local extraction closure: explicit shared harness landing path plus continued Telegram sample consumption
- forcing `samples/real-message-service-cache-001` onto the new landing in the same turn would turn this slice into build-system/path-dependency exploration rather than a bounded first extraction
- the cache sample remains the authoritative semantic reference for later follow-up, but not a required write target for this first landed slice
