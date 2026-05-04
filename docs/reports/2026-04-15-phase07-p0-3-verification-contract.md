# 2026-04-15 Phase07 P0-3 Verification Contract

## Goal

Define the minimum `Phase07 Telegram UI Incubation` regression / verification contract for the current Linux `Staging-Core` continuation lane without widening the implementation scope beyond the landed `P0-1` / `P0-2` boundary stack.

## Boundary Constraints

- This document belongs to the `Phase07 Telegram UI Incubation` continuation lane only.
- The formal checkpoint remains `P22 / 311/311 live passed`.
- `P23 mechanical-ready = No` remains unchanged.
- This document does not create any `Phase06 regular`, promotion, live, mechanical-ready, Harmony live, or `Windows Staging-Full` claim.

## Inputs

- `specs/phase07-telegram-ui-incubation/requirements.md`
- `specs/phase07-telegram-ui-incubation/design.md`
- `specs/phase07-telegram-ui-incubation/tasks.md`
- `docs/reports/2026-04-15-phase07-shared-harness-module-boundary.md`
- `docs/reports/2026-04-15-phase07-p0-1-runtime-gate-clarification.md`
- `docs/reports/2026-04-15-phase07-app-shell-consume-boundary.md`
- `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`
- `samples/telegram-ui-vertical-slice-001/src/telegram_message_service_harness.cj`
- `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
- `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`
- `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`

## Contract Summary

- `P0-3` remains the canonical verification contract record for the continuation lane, and it now includes the landed `P1-5` shell refresh consume gate, the landed `P1-7` detail-route retarget consume gate, the landed `P1-8` retarget-back stability consume gate, the landed `P1-9` detail-projection reset consume gate, the landed `P1-10` back-to-list refresh isolation consume gate, the landed `P1-11` refresh-then-reopen coherence consume gate, the landed `P1-12` refresh-reopen-retarget coherence consume gate, the landed `P1-13` round-trip stability consume gate, the landed `P1-14` alternating-reopen bounded stability consume gate, the landed `P1-15` active-detail target refresh-back-reopen consume gate, the landed `P1-16` active-detail target refresh-retarget coherence consume gate, the landed `P1-17` active-detail target refresh-retarget-back-reopen original-target consume gate, the landed `P1-18` active-detail refresh-retarget alternating-reopen bounded-stability consume gate, the landed `P1-19` shared worker-fetch helper unification gate, the landed `P1-20` shared second-consumer send-refresh dispatch parity gate, the landed `P1-21` shared second-consumer optimistic-signal parity gate, the landed `P1-22` shared second-consumer invalidate/refetch parity gate, the landed `P1-23` shared second-consumer pre-drain invalidate discard parity gate, the landed `P1-24` shared second-consumer cold-send seeded pre-drain fetch parity gate, the landed `P1-25` shared second-consumer same-peer repeated get reuse-no-refetch parity gate, and the landed `P1-26` shared second-consumer warm-send append-without-refetch parity gate.
- The current minimum contract now spans the repo-local shared-harness landing package plus the Telegram consumer package.
- The current minimum contract also requires the worker-side fetch/drain/snapshot idiom to be expressed through one shared helper across the Telegram consumer and the Phase07 second consumer.
- The current minimum contract also requires the shared second consumer to prove `warmup fetch / drain -> worker send -> main-context dataset refresh dispatch` parity without introducing a new shared worker-send helper.
- The current minimum contract also requires the shared second consumer to prove that, once the existing shared `MessageSignal` has warmed up, `worker send` can update the signal snapshot before `main-context drain` while observer delivery remains main-gated.
- The current minimum contract also requires the shared second consumer to prove that the existing public `debugInvalidateCache(...)` surface can invalidate a warmed signal/cache pair, create a replacement signal, and refetch replacement history without delivering stale pre-invalidate payload to the observer.
- The current minimum contract also requires the shared second consumer to prove that, if the first fetch has already started but `debugDrainPromiseResolutions()` has not yet run, the existing public `debugInvalidateCache(...)` surface discards that pre-drain pending fetch so that only the replacement refetch can update the signal/observer path.
- The current minimum contract also requires the shared second consumer to prove that, after a cold `sendMessage(...)` seeds cache before the first shared `getMessages(...)`, the first signal still exposes that seeded local snapshot until fetch promise drain completes, then switches to remote history while observer delivery remains main-gated.
- The current minimum contract also requires the shared second consumer to prove that, once the same-peer shared signal has already warmed to remote history, a second `getMessages(...)` on that peer reuses the warmed signal/cache without a second `adapter.getHistory(...)` and without a second refresh delivery.
- The current minimum contract also requires the shared second consumer to prove that, once the same-peer shared signal has already warmed to remote history, a later warm `sendMessage(...)` appends payload onto that warmed signal/cache without a second `adapter.getHistory(...)` while observer delivery remains main-gated.
- `samples/telegram-ui-vertical-slice-001` remains the canonical consumer-side verification entry, but it is no longer the shared-harness landing host.
- Compile, unit, and behavior evidence must be reported separately even when one command produces more than one stage of evidence.
- The canonical command pair for the current lane remains:
  - `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
  - `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- In a clean shell, both commands require explicit repo-local `CANGJIE_HOME` / `PATH` / `LD_LIBRARY_PATH` / `CANGJIE_STDLIB_PATH` injection before execution.

## Verification Surface by Layer

### Shared Harness Layer

Scope:

- `samples/phase07-shared-service-refresh-harness/src/phase07_shared_service_refresh_harness.cj`
- `samples/telegram-ui-vertical-slice-001/src/telegram_message_service_harness.cj`
- `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`

Host / consumer split:

- the surviving shared-harness landing host is `samples/phase07-shared-service-refresh-harness`
- `samples/telegram-ui-vertical-slice-001` now consumes that shared surface through repo-local package wiring and no longer hosts the shared harness source file

Compile evidence:

- successful dependency build plus consumer package build/link during `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
- successful dependency build plus second-consumer package build/link during `cd samples/real-message-service-cache-001 && cjpm test`
- emitted test binary at `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`

Unit ownership:

- `sessionListShouldBuildSummariesFromRealMessageService`
- `refreshShouldReloadOnlyTheTargetConversationFromService`
- `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldSupportCacheSampleAsSecondConsumer`
- `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldDispatchSecondConsumerSendRefreshOnMainContext`
- `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldKeepSecondConsumerSignalOptimisticBeforeMainDrain`
- `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldRefetchSecondConsumerAfterInvalidate`
- `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldDiscardPreDrainFetchWhenSecondConsumerInvalidates`
- `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldExposeColdSendSeedBeforeFirstFetchDrain`
- `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldReuseWarmSecondConsumerSignalWithoutRefetch`
- `Phase07SecondConsumerCompatibilityTests.sharedHarnessShouldAppendWarmSendWithoutRefetchingHistory`

Behavior ownership:

- post-build `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- focus: shared `runWorkerGetMessages(...)` must preserve worker fetch -> promise drain -> main-context dataset refresh delivery without hang, and the second-consumer compatibility path must continue to resolve through that same shared helper

### Telegram UI Skeleton Layer

Scope:

- `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`

Compile evidence:

- successful package build and link during `cjpm test`

Unit ownership:

- `sessionListShouldBuildSummariesFromRealMessageService`
- `tappingConversationShouldNavigateToDetailPlaceholder`
- `refreshShouldReloadOnlyTheTargetConversationFromService`

Behavior ownership:

- post-build `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- focus: list load, route push/back, targeted refresh, and refresh queue drain must not deadlock

### Same-Package App-Shell Layer

Scope:

- `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj`

Compile evidence:

- successful package build and link during `cjpm test`

Unit ownership:

- `appShellShouldStartOnSessionListRouteAndExposeSessions`
- `appShellShouldConsumeListSelectionIntoDetailPlaceholder`
- `appShellRefreshShouldUpdateOnlyTheTargetSummaryWithoutBreakingDetailBoundary`
- `appShellShouldRetargetActiveDetailConversationWithoutGrowingRouteHistory`
- `appShellBackShouldReturnToSessionListAfterDetailRetargetsWithoutForwardHistoryGrowth`
- `appShellBackShouldClearDetailProjectionAfterReturningToSessionList`
- `appShellRefreshAfterBackShouldKeepListRouteAndDetailProjectionIsolation`
- `appShellRefreshThenReopenShouldPreserveCoherentDetailAndListState`
- `appShellRefreshActiveDetailTargetThenBackAndReopenShouldPreserveBoundedCoherence`
- `appShellRefreshActiveDetailTargetThenRetargetShouldPreserveBoundedCoherence`
- `appShellRefreshActiveDetailRetargetBackThenReopenOriginalTargetShouldPreserveRoundTripStability`
- `appShellRefreshActiveDetailRetargetAlternatingReopenShouldKeepBoundedStableDetailOwnership`
- `appShellRefreshReopenThenRetargetShouldKeepDetailCoherenceAndListStability`
- `appShellRefreshReopenRetargetBackThenReopenShouldPreserveRoundTripStability`
- `appShellAlternatingReopenAfterRoundTripShouldKeepBoundedStableDetailOwnership`

Behavior ownership:

- post-build `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`
- focus: same-package shell startup, list exposure, list-to-detail consume path, targeted shell refresh, active-detail retarget, retarget-back stability, detail-projection reset after list return, back-to-list refresh isolation, refresh-then-reopen coherence, active-detail target refresh-back-reopen coherence, active-detail target refresh-retarget coherence, active-detail target refresh-retarget-back-reopen original-target coherence, active-detail refresh-retarget alternating-reopen bounded stability, refresh-reopen-retarget coherence, round-trip stability, alternating-reopen bounded stability, and detail-to-list return path must not hang

Mandatory gate:

- shell-level targeted refresh is now part of the app-shell contract
- the app-shell regression set must prove target-summary update, non-target stability, intact route/detail placeholder ownership, detail-route reuse without history growth, and post-retarget back stability without forward-history drift
- the app-shell regression set must also prove that the stale detail projection clears once the shell has returned to the session-list route
- the app-shell regression set must also prove that a later list-route refresh does not reactivate detail projection, widen history, or pollute non-target summaries
- the app-shell regression set must also prove that reopening the refreshed visible target conversation restores coherent detail ownership without losing the list-side refreshed summary state
- the app-shell regression set must also prove that when refresh runs against the currently active detail target, backing to list and reopening that same refreshed target restores coherent detail ownership without losing the refreshed target summary or polluting non-target summaries
- the app-shell regression set must also prove that when refresh runs against the currently active detail target, directly retargeting to another visible conversation keeps detail-route stability, preserves the refreshed original target summary, leaves the other visible summary unpolluted, and avoids any extra service-history pull beyond the refresh itself
- the app-shell regression set must also prove that when refresh runs against the currently active detail target, directly retargeting to another visible conversation, backing to list, and reopening the original refreshed target restores coherent original-target detail ownership without losing refreshed or non-target list state
- the app-shell regression set must also prove that when refresh runs against the currently active detail target, directly retargeting to another visible conversation, backing to list, reopening the original refreshed target, backing again, and reopening the other visible conversation still keeps bounded history at `2`, rebinds final detail ownership to the other visible conversation, preserves the refreshed original target summary/messageCount, leaves the other visible summary unpolluted before and after the final reopen, and avoids any extra service-history pull beyond the refresh itself
- the app-shell regression set must also prove that retargeting away from that reopened refreshed conversation keeps detail-route stability while preserving the previously refreshed list-side summary state
- the app-shell regression set must also prove that after retargeting away from that reopened refreshed conversation and backing to list, reopening the original refreshed target still restores coherent detail ownership without losing refreshed or non-target list state
- the app-shell regression set must also prove that after that round trip has completed, backing again and reopening another visible conversation still keeps bounded history at `2`, rebinds detail ownership to the reopened visible conversation, preserves the refreshed original target summary, and leaves the other visible summary unpolluted

## Compile / Unit / Behavior Separation Rule

- `Compile` means package build/link success plus binary emission. Do not report it as a standalone harness-only compile pass unless a dedicated compile command exists later.
- `Unit` means named `@TestCase` assertions in `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj` plus the second-consumer regression in `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`.
- `Behavior` means post-build runtime no-deadlock verification from the standalone unittest binary under `timeout 5s`.
- Do not collapse the second command back into “just another unit run”; its purpose is to isolate startup/runtime hang risk after the build has already completed.

## Default Command Contract

Package-local commands:

- `cd samples/telegram-ui-vertical-slice-001 && cjpm test`
- `cd samples/telegram-ui-vertical-slice-001 && timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`

Controlled-shell wrapper used on the current host:

```bash
REPO_ROOT="/volume/wzhang/cky-workspace/my_projects/Cangjie"
export CANGJIE_HOME="$REPO_ROOT/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie"
export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH"
export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}"
export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std"
cd "$REPO_ROOT/samples/telegram-ui-vertical-slice-001"
```

## Expected Evidence Paths

- package root:
  - `samples/telegram-ui-vertical-slice-001`
- test source:
  - `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- post-build runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- contract record:
  - `docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`

## Failure Classification

### Compile Failure

Signal:

- `cjpm test` exits non-zero before reporting test-case results
- or the standalone binary is not emitted at `target/release/unittest_bin/telegram_ui_vertical_slice_001`

Meaning:

- consumer-package compile/link regression, including failure to build the repo-local shared-harness dependency

Primary inspection points:

- `cjpm test` stderr/stdout in the executing shell
- source files touched in the current slice

### Unit Failure

Signal:

- `cjpm test` reports one or more failing `@TestCase`

Meaning:

- logical contract regression in the owning layer named above

Primary inspection points:

- failing test case names in `samples/telegram-ui-vertical-slice-001/src/telegram_ui_vertical_slice_test.cj`
- source file owned by the failing layer

### Behavior Failure

Signal:

- `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` exits non-zero after a successful `cjpm test`

Meaning:

- runtime/startup/no-deadlock regression

Sub-classification:

- timeout or signal kill -> runtime deadlock/startup budget failure
- assertion failure on second run -> runtime-only behavior divergence after build

### Environment Blocker

Signal:

- `cjpm: command not found`
- missing repo-local toolchain libraries or stdlib path

Meaning:

- shell/toolchain injection issue, not an entity failure in the Phase07 slice itself

## Refresh Loop Decision

Decision:

- shell refresh loop is now included in the first mandatory app-shell regression contract

Reason:

- `samples/telegram-ui-vertical-slice-001/src/telegram_app_shell.cj` now exposes shell-level targeted refresh without introducing a new router/page/controller abstraction
- the new app-shell regression proves that refresh updates the target summary while keeping the active detail route and placeholder-owned conversation intact
- this is the smallest slice that upgrades shell refresh from deferred coverage to explicit consume surface

Mandatory coverage:

- app-shell targeted refresh regression:
  - `appShellRefreshShouldUpdateOnlyTheTargetSummaryWithoutBreakingDetailBoundary`
- app-shell active-detail retarget regression:
  - `appShellShouldRetargetActiveDetailConversationWithoutGrowingRouteHistory`
- app-shell retarget-back stability regression:
  - `appShellBackShouldReturnToSessionListAfterDetailRetargetsWithoutForwardHistoryGrowth`
- app-shell detail-projection reset regression:
  - `appShellBackShouldClearDetailProjectionAfterReturningToSessionList`
- app-shell back-to-list refresh isolation regression:
  - `appShellRefreshAfterBackShouldKeepListRouteAndDetailProjectionIsolation`
- app-shell refresh-then-reopen coherence regression:
  - `appShellRefreshThenReopenShouldPreserveCoherentDetailAndListState`
- app-shell active-detail target refresh-back-reopen coherence regression:
  - `appShellRefreshActiveDetailTargetThenBackAndReopenShouldPreserveBoundedCoherence`
- app-shell active-detail target refresh-retarget coherence regression:
  - `appShellRefreshActiveDetailTargetThenRetargetShouldPreserveBoundedCoherence`
- app-shell active-detail target refresh-retarget-back-reopen original-target coherence regression:
  - `appShellRefreshActiveDetailRetargetBackThenReopenOriginalTargetShouldPreserveRoundTripStability`
- app-shell active-detail refresh-retarget alternating-reopen bounded-stability regression:
  - `appShellRefreshActiveDetailRetargetAlternatingReopenShouldKeepBoundedStableDetailOwnership`
- app-shell refresh-reopen-retarget coherence regression:
  - `appShellRefreshReopenThenRetargetShouldKeepDetailCoherenceAndListStability`
- app-shell round-trip stability regression:
  - `appShellRefreshReopenRetargetBackThenReopenShouldPreserveRoundTripStability`
- page-level targeted refresh regression remains as lower-layer ownership:
  - `refreshShouldReloadOnlyTheTargetConversationFromService`
- post-build runtime no-deadlock gate:
  - `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001`

## Verification Record

Verification commands executed in this turn:

- `cd samples/real-message-service-cache-001 && cjpm test`

Verification note:

- this turn only refreshed the cache-sample canonical build gate because no shared-harness source file or Telegram consumer source file moved
- the latest Telegram build/runtime evidence therefore continues to inherit the green `P1-19` checkpoint

Controlled-shell wrapper used for the actual run on this host:

```bash
REPO_ROOT="/volume/wzhang/cky-workspace/my_projects/Cangjie"
export CANGJIE_HOME="$REPO_ROOT/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie"
export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH"
export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}"
export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std"
cd "$REPO_ROOT/samples/real-message-service-cache-001"
```

Result summary:

- latest Telegram `cjpm test` evidence remains `exit 0` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0` from the `P1-19` bundle
- latest post-build `timeout 5s ./target/release/unittest_bin/telegram_ui_vertical_slice_001` evidence remains `exit 0` with `TOTAL: 18`, `PASSED: 18`, `FAILED: 0` from the `P1-19` bundle
- cache sample `cjpm test` exited `0` with `TOTAL: 33`, `PASSED: 33`, `FAILED: 0`
- the latest emitted Telegram runtime binary remains at `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`

Artifact paths used as evidence in this turn:

- contract record:
  - `docs/reports/2026-04-15-phase07-p0-3-verification-contract.md`
- latest shared-harness evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-26-second-consumer-warm-send-append-without-refetch-parity/`
- inherited Telegram build/runtime evidence bundle:
  - `artifacts/verification_contracts/20260417-phase07-shared-p1-19-worker-fetch-helper-unification/`
- built runtime binary:
  - `samples/telegram-ui-vertical-slice-001/target/release/unittest_bin/telegram_ui_vertical_slice_001`
- test source:
  - `samples/real-message-service-cache-001/src/phase07_second_consumer_compatibility_test.cj`

Failure classification outcome for this turn:

- no compile failure
- no unit failure
- no environment blocker after explicit toolchain injection
- Telegram / cache runtime-no-deadlock gates remain inherited from prior frozen evidence; this turn did not reopen them
