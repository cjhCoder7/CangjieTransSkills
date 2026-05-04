# 2026-04-13 Phase06 P19 Regular Candidate Scout

## Goal

Determine the next direct regular Phase06 reserve workset after the formal `P18 / 130/130 live passed` checkpoint, using only the remaining official-repo reserve set and keeping the next freeze bounded, reproducible, and evidence-first.

## Inputs

- `AGENTS.md`
- `/.claude/status/current-phase.md`
- `docs/reports/2026-04-13-phase06-p18-regular-promotion.md`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.json`
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.validation.json`
- `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r13.json`
- `/tmp/phase06-source-scout/HarmonyOS-Examples`
- `/tmp/phase06-source-scout/HarmonyOS-Cangjie-Cases`
- `artifacts/ui_pilots/20260413-phase06-ui-official-p19-regular-scout.json`

## Method

1. Reconfirmed from the hot SSOT that any post-`P18` regular expansion must continue only from the remaining official reserve and must not reopen the draft lane, the public `cangjiechallenge` pool, register-level manual selection, or the exception rail.
2. Re-scanned the remaining official reserve roots and compared candidates by bounded same-package closure, timer/network pressure, route fan-out, and reproducibility risk.
3. For each promoted candidate hypothesis, treated the freeze surface conservatively: start from `index.cj`, include every currently hit same-package file, and add `main_ability` / `MainAbility` or explicit route targets when the entry UI depends on ability context, `AppStorage`, or route-driven pages.
4. Explicitly excluded `ability_stage.cj` / `AbilityStage.cj` when no selected file imported or referenced that stage file, and excluded the empty `05-ChatUI/.../components/index.cj` marker because it does not contribute runtime symbols.
5. Deferred candidates whose visible entry shell already expands into timer-backed behavior, hardcoded network credentials, or multi-page cross-feature fan-out that would make the next direct freeze less reliable.

## Selected regular candidates

- `harmonyos-examples-slide-ui-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - freeze set: `09-SlideUI/entry/src/main/cangjie/index.cj`, `main_ability.cj`, the full local `components/` subtree, and the full local `datas/` subtree (`freeze_file_count=13`, excluding only `ability_stage.cj`)
  - tags: `page-shell` + `gesture-driven-panel` + `ability-context-backed`
  - reason: `index.cj` wildcard-imports the local component and data packages and directly reads `globalAbilityContext`; adding `main_ability.cj` closes that dependency while keeping the freeze surface bounded to one same-package subtree.
- `harmonyos-examples-seat-selection-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - freeze set: `13-SeatSelection/entry/src/main/cangjie/index.cj`, `MainAbility.cj`, the full local `components/` subtree, the full local `constants/` subtree, and `view_model/SeatSelection.cj` (`freeze_file_count=17`, excluding only `AbilityStage.cj`)
  - tags: `page-shell` + `appstorage-backed-layout` + `same-package-full-closure`
  - reason: `index.cj` depends on the local constants and component packages, the components depend on `SeatSelection` view-model state, and `MainAbility.cj` writes the `AppStorage['topRectHeight']` consumed by the entry page; taking the full same-package closure keeps the next freeze reproducible.
- `harmonyos-examples-chat-ui-index-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - freeze set: `05-ChatUI/entry/src/main/cangjie/src/index.cj`, the active `avatar/`, `badge/`, `chat/`, `dynamic/`, and `friend/` component files, `components/index/TabBar.cj`, the full local `entity/` subtree, `global/store.cj`, `mock/dataMock.cj`, `pages/ChatView.cj`, and local `util/` helpers (`freeze_file_count=21`, excluding `main_ability.cj`, `ability_stage.cj`, and the empty `components/index.cj` marker)
  - tags: `page-shell` + `route-target-backed` + `same-package-full-closure`
  - reason: the entry page fans into chat, friend, and dynamic tabs; `ChatList.cj` pushes the `ChatView` route, and `ChatView.cj` consumes the same-package badge/avatar/chat/global/entity/mock layers. Keeping that explicit 21-file closure avoids a brittle under-freeze while still excluding boot-only files.

## Deferred / excluded findings

- `HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry page drives progress with `Timer.repeat` plus `launch`-based updates, so its runtime behavior is more timer-sensitive than the selected trio.
- `HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/index.cj`
  - deferred because the sample couples `EventBus` wiring with `Timer.after` scroll-unlock logic, which raises reproducibility pressure for the next direct freeze.
- `HarmonyOS-Examples/06-AIChatLite/entry/src/main/cangjie/src/index.cj`
  - deferred because `index.cj` hardcodes a SiliconFlow URL and key, and `utils/llm.cj` uses `net.http` plus `Authorization: Bearer ...`, so the sample is not a clean regular reserve input.
- `HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/index.cj`
  - deferred because the visible entry shell immediately routes into `ScrollView`, `ListView`, `BadgeView`, and `SimpleLayoutView`, so the true freeze surface expands well beyond the headline file.
- `HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry page already mixes `SearchComponent`, `FunctionalScenes`, display-backed foldable state, `PromptAction`, and timer-based back handling, so the reserve surface is too cross-feature for the next bounded freeze.

## Results

- `artifacts/ui_pilots/20260413-phase06-ui-official-p19-regular-scout.json`
  - result: `selected_candidate_count=3`, `deferred_candidate_count=5`, `decision=prepare-p19-regular-freeze`; the selected `source_paths` now carry conservative same-package closures at `13 + 17 + 21` files.
- `docs/reports/2026-04-13-phase06-p19-regular-candidate-scout.md`
  - result: fixes the next official-only direct regular trio without touching the formal checkpoint and records the explicit inclusion/exclusion boundary for `ability_stage`, `MainAbility`, route targets, and boot-only files.

## Decision

- The next task is to freeze a direct `P19` regular reserve workset from `09-SlideUI`, `13-SeatSelection`, and `05-ChatUI`.
- The formal checkpoint remains `P18 / 130/130 live passed`; this scout-only turn does not mutate the primary sample manifest, live-pass coverage, aggregate audit, or SSOT checkpoint.
- The next execution step is to freeze these official-reserve files into `raw_docs/phase06-ui-p19` and then run the standard regular chain: `source corpus -> file manifest -> prompt-pilot manifest -> mock curator -> workset audit -> live curator -> aggregate audit -> coverage -> SSOT`.
