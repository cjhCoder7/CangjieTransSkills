# 2026-04-15 Phase07 Shared Harness Module Boundary

## Goal

Define the `Phase07 Telegram UI Incubation` P0-1 implementation-prep boundary for `shared harness` and `module boundary` work without starting extraction code in this turn.

## Boundary Constraints

- This document belongs to the `Phase07 Telegram UI Incubation` continuation lane.
- The formal checkpoint remains `P22 / 311/311 live passed`.
- `P23 mechanical-ready = No` remains unchanged.
- This is an implementation-prep boundary note only. It does not claim compile/test rerun, live, promotion, or mechanical-ready status.

## Inputs

- `specs/phase07-telegram-ui-incubation/requirements.md`
- `specs/phase07-telegram-ui-incubation/design.md`
- `specs/phase07-telegram-ui-incubation/tasks.md`
- `samples/telegram-ui-vertical-slice-001/src/telegram_message_service_harness.cj`
- `samples/telegram-ui-vertical-slice-001/src/telegram_ui_slice.cj`
- `samples/real-message-service-cache-001/src/real_message_service_cache_harness.cj`
- `samples/ui-routing-defining-page-layout/FoodNavigator.cj`

## Boundary Decision Summary

- `samples/telegram-ui-vertical-slice-001` contributes the Telegram-specific UI skeleton and a duplicated message-service harness seed.
- `samples/real-message-service-cache-001` remains the stronger source for shared service / cache / refresh semantics and behavior-harness conventions.
- `samples/ui-routing-defining-page-layout` contributes route and page-shell reference only; it is not part of the first shared harness extraction write set.
- The first Phase07 implementation slice should extract only the duplicated repo-local service / refresh surface, not Telegram router/page/controller code and not app-shell assembly.

## Shared Harness Candidates

The following types and helpers are duplicated or strongly aligned across the Telegram seed slice and the cache harness, so they are the primary shared harness candidates:

- Core message-domain types:
  - `PeerId`
  - `DomainMessage`
  - `SendMessageParams`
  - `MessageSignal`
- Service and refresh interfaces:
  - `IMTProtoAdapter`
  - `DatasetRefreshObserver`
  - `DatasetRefreshBridge`
  - `EpochRegister`
- Default runtime implementations:
  - `MutexEpochRegister`
  - `PendingDatasetRefresh`
  - `NoopDatasetRefreshBridge`
  - `MainContextDatasetRefreshBridge`
  - `RealMessageService`
- Minimal runtime helpers:
  - `setExecutionContext`
  - `currentExecutionContext`
- Minimal collection helpers:
  - `cloneMessages`
  - `emptyMessages`
  - `takeMessages`
  - `appendMessage`

## Deferred Shared Candidates

The following items may become shared later, but they are not part of the first extractable write set:

- Test and observation helpers:
  - `FakeMessageAdapter`
  - `MockUiDatasetObserver`
  - `SignalRuntimeObserver`
  - `SignalRuntimeObserverRegistration`
- Cache-sample-only probe adapters:
  - `DirtyTLMessage`
  - `PurifyingMessageAdapter`
  - `ConcurrencyProbeAdapter`
  - `DelayedHandoffProbeAdapter`

Reason for deferral:

- they are valuable for regression design, but they are not the minimum surface needed to stop harness duplication between the Telegram seed slice and the cache harness;
- some of them are probe-specific or runtime-observer-specific and would widen the first write set beyond the current P0-1 boundary.

## Telegram-Specific UI Skeleton Retained Set

The following items must stay in the Telegram-specific UI skeleton for P0-1 and must not be pulled into the first shared harness boundary:

- Conversation and UI-facing domain:
  - `TelegramConversationSeed`
  - `TelegramConversationSummary`
- Route layer:
  - `TelegramRouteRequest`
  - `makeTelegramSessionListRoute`
  - `makeTelegramChatDetailRoute`
  - `TelegramPageRouter`
  - `MemoryTelegramPageRouter`
  - `SpyTelegramPageRouter`
- Controller and pages:
  - `TelegramSessionListController`
  - `TelegramSessionListPage`
  - `TelegramChatDetailPage`
- Telegram-specific helpers:
  - `buildConversationSummary`
  - `emptyConversationSummary`
  - `emptyConversationSummaries`
  - `cloneConversationSummaries`
  - `replaceConversationSummary`
  - `findConversationSummary`
  - `cloneConversationSeeds`
  - `emptyTelegramRouteRequests`
  - `appendTelegramRouteRequest`
  - `emptyRouteNames`
  - `appendRouteName`

P0-1 decision on worker helper:

- `runWorkerGetMessages` remains outside the first shared harness write set for now.
- It currently couples the Telegram session-load / refresh flow to the existing seed slice and can be reconsidered only after the P0-2 app-shell consume boundary is defined.

## First Minimum Extractable Write Set

If implementation starts after this document, the first writable slice should be limited to one bounded shared harness surface composed of:

- `PeerId`
- `DomainMessage`
- `SendMessageParams`
- `MessageSignal`
- `IMTProtoAdapter`
- `DatasetRefreshObserver`
- `DatasetRefreshBridge`
- `EpochRegister`
- `MutexEpochRegister`
- `PendingDatasetRefresh`
- `NoopDatasetRefreshBridge`
- `MainContextDatasetRefreshBridge`
- `RealMessageService`
- `setExecutionContext`
- `currentExecutionContext`
- `cloneMessages`
- `emptyMessages`
- `takeMessages`
- `appendMessage`

Write-set rule:

- the first slice may define or relocate only the shared harness surface above;
- it must leave Telegram router/page/controller code in place;
- it must not start generic route abstraction or app-shell assembly in the same change.

## Do-Not-Touch Set

The following areas are outside the first write set and should remain untouched in the Phase07 P0-1 slice:

- `samples/ui-routing-defining-page-layout/entry/*`
- `samples/ui-routing-defining-page-layout/AppScope/*`
- route/app-shell config or IDE/DevEco assembly files
- generic route abstraction beyond the existing `FoodNavigator.cj` reference pattern
- Telegram page/router/controller code listed in the retained set
- cache-sample-only probe adapters and observer extras listed in the deferred set
- any `raw_docs/phase06-ui-p23*`
- any `docs/manifests/phase06_ui_*_p23*.json`
- any `artifacts/ui_pilots/20260414-phase06-ui-p23-*`

## Next Step Handoff

- This document closes `tasks.md` item `P0-1` only at the implementation-prep boundary-definition level.
- The next implementation-facing step should consume this shared harness / module boundary to prepare one minimal code change for the first extractable write set.
- `P0-2` remains separate: route/app-shell consume boundary should be designed after, not merged into, the first shared harness slice.
