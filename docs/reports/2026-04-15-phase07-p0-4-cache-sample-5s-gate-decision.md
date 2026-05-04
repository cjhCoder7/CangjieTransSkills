# 2026-04-15 Phase07 P0-4 Cache Sample 5s Gate Decision

## Goal

Freeze a single, continuation-lane-only verification-contract decision for the controlled-shell `5s` gate on `samples/real-message-service-cache-001`, without reopening `P1-6` implementation scope.

## Boundary

- This decision belongs to `Phase07 Telegram UI Incubation` only.
- The formal checkpoint remains `P22 / 311/311 live passed`.
- `direct P23 mechanical-ready = No` remains unchanged.
- This round does not modify `phase07_shared_service_refresh_harness.cj`, `telegram_app_shell.cj`, `telegram_ui_slice.cj`, or any `cjpm.toml`.
- This decision does not create any `Phase06 regular`, promotion, live, mechanical-ready, Harmony live, or `Windows Staging-Full` claim.

## Inputs

- `docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
- `docs/reports/2026-04-15-phase07-p1-6-second-consumer-compatibility-slice.md`
- `specs/phase07-telegram-ui-incubation/tasks.md`
- `artifacts/verification_contracts/20260415-phase07-cache-sample-5s-gate/`

## Verification Evidence

### 1. Canonical build-and-test command

- Command:
  - `cd "$REPO_ROOT/samples/real-message-service-cache-001" && cjpm test`
- Exit code:
  - `0`
- Key output:
  - `Summary: TOTAL: 26`
  - `PASSED: 26`
  - `FAILED: 0`
- Artifact paths:
  - `artifacts/verification_contracts/20260415-phase07-cache-sample-5s-gate/cjpm-test.log`
  - `artifacts/verification_contracts/20260415-phase07-cache-sample-5s-gate/cjpm-test.exit`

### 2. Mixed controlled-shell 5s wrapper

- Command:
  - `timeout 5s bash -lc '... && cjpm test'`
- Exit code:
  - `124`
- Key output:
  - no stdout/stderr was flushed before timeout kill under the current wrapper
- Artifact paths:
  - `artifacts/verification_contracts/20260415-phase07-cache-sample-5s-gate/timeout-cjpm-test.log`
  - `artifacts/verification_contracts/20260415-phase07-cache-sample-5s-gate/timeout-cjpm-test.exit`

### 3. Post-build runtime/no-deadlock probe

- Command:
  - `timeout 5s bash -lc '... && cjpm test --skip-build'`
- Exit code:
  - `0`
- Key output:
  - `Summary: TOTAL: 26`
  - `PASSED: 26`
  - `FAILED: 0`
- Artifact paths:
  - `artifacts/verification_contracts/20260415-phase07-cache-sample-5s-gate/timeout-cjpm-test-skip-build.log`
  - `artifacts/verification_contracts/20260415-phase07-cache-sample-5s-gate/timeout-cjpm-test-skip-build.exit`

## Decision

- The canonical cache-sample build gate is now `cd samples/real-message-service-cache-001 && cjpm test`.
- The canonical cache-sample runtime/no-deadlock gate is now `timeout 5s bash -lc '... && cjpm test --skip-build'`.
- The mixed `timeout 5s bash -lc '... && cjpm test'` command is no longer the canonical pass/fail gate for this slice; it is retained only as a controlled-shell compile-budget probe.
- The current `124` on that mixed wrapper is therefore classified as `compile-budget known risk`, not as a packaging blocker and not as runtime deadlock evidence.
- Under this contract, the current `124` still allows the continuation lane to move forward as long as:
  - plain `cjpm test` keeps exiting `0`; and
  - the `5s` `--skip-build` probe keeps exiting `0`.

## Why

- The plain build-and-test command succeeds at `26/26`.
- The `5s` wrapper only fails when build is included.
- The same `5s` budget passes once build is removed, which isolates the surviving red point to build/startup budget rather than runtime deadlock.

## Outcome

- `P1-6` remains landed exactly as implemented.
- The cache sample now has a single consumable verification-contract answer:
  - build/unit = plain `cjpm test`
  - runtime/no-deadlock = `timeout 5s ... cjpm test --skip-build`
  - mixed `5s` `cjpm test` = observational compile-budget probe only
