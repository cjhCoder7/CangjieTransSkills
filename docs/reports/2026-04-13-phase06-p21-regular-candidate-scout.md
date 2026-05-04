# 2026-04-13 Phase06 P21 Regular Candidate Scout

## Goal

Determine the next direct regular Phase06 reserve workset after the formal `P20 / 220/220 live passed` checkpoint, using only the remaining official-repo reserve set and an explicit exclusion baseline so this scout-plus-freeze turn stays bounded, reproducible, and evidence-first.

## Formal Status Guardrail

- The formal regular checkpoint remains `P20 / 220/220 live passed`.
- This scout step does not refresh `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19*.json`, `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json`, or any promoted SSOT count.
- The current SSOT remains the promoted `P20 / 220/220 live passed` closure evidenced by `docs/reports/2026-04-13-phase06-p20-regular-promotion.md`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json`, and `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json`.

## Inputs

- `AGENTS.md`
- `/.claude/status/current-phase.md`
- `docs/reports/2026-04-13-phase06-p20-regular-promotion.md`
- `docs/manifests/phase06_ui_p0_file_manifest.json` through `docs/manifests/phase06_ui_p20_file_manifest.json`
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json`
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json`
- `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json`
- `/tmp/phase06-source-scout/HarmonyOS-Examples`
- `/tmp/phase06-source-scout/HarmonyOS-Cangjie-Cases`
- `artifacts/ui_pilots/20260413-phase06-ui-official-p21-regular-scout.json`

## Scout Roots

- `HarmonyOS-Examples`
  - url: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git`
  - branch: `main`
  - commit: `f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
- `HarmonyOS-Cangjie-Cases`
  - url: `https://gitcode.com/Cangjie/HarmonyOS-Cangjie-Cases.git`
  - branch: `dev`
  - commit: `58ff5a8aed2fb0ae002f4c3d36d3078c379526ef`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Cangjie-Cases`

## Exclusion Baseline

1. Treated `docs/manifests/phase06_ui_p0_file_manifest.json` through `docs/manifests/phase06_ui_p20_file_manifest.json` as the consumed-slice baseline for the formal regular lane.
2. Used `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json` plus `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json` to confirm the formal lane already covers `66` promoted regular samples with a valid aggregate audit.
3. Used `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json` to confirm the promoted regular lane already holds `220/220` live-passed slices through `P20`.
4. Explicitly excluded every official `source_path` already present in the P0..P20 file manifests and did not reopen the draft lane, the public `cangjiechallenge` pool, register-level manual selection, or the exception rail.
5. The exclusion baseline now covers `216` official manifest entries, collapsing to `191` unique official source paths across `46` official regular sample ids.

## Method

1. Reconfirmed from the hot SSOT that post-`P20` regular expansion must continue only from the remaining official `HarmonyOS-Examples` / `HarmonyOS-Cangjie-Cases` reserve while keeping the current formal checkpoint fixed at `P20 / 220/220 live passed`.
2. Re-audited the remaining official reserve roots after removing all already consumed official `source_path` entries contributed by `docs/manifests/phase06_ui_p0_file_manifest.json` through `docs/manifests/phase06_ui_p20_file_manifest.json`.
3. Compared the remaining candidates by bounded same-package closure size, router fan-out, `main_ability` / `AppStorage` pressure, timer or event-bus pressure, network-secret coupling, socket/hybrid-host coupling, and overlap risk with already consumed slices.
4. Preferred candidates whose freeze surface can be stated explicitly inside one repo-local package subtree, and deferred samples that still require network credentials, sockets, hybrid-host context, or broader multi-feature closure than the current post-`P20` window can justify.
5. Kept this step bounded to scout + mechanical freeze only: no live curator, no aggregate audit refresh, no live-pass coverage refresh, and no promoted SSOT move.

## Selected Regular Candidates

- `harmonyos-examples-ui-layout-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `02-UILayout/entry/src/main/cangjie/index.cj`, the four route-target pages `pages/{BadgeView,ListView,ScrollView,SimpleLayout}.cj`, the same-package `components/{Badge,List,ScrollLayout,SimpleLayout,entry,global,utils}` closure selected by those pages, and `utils/{color,counter,format}.cj` (`freeze_file_count=28`, excluding `ability_stage.cj`, `main_ability.cj`, `components/index.cj`, and `pages/index.cj`)
  - tags: `page-shell` + `router-backed-layout-gallery` + `same-package-layout-components`
  - reason: the sample keeps one router-backed gallery shell plus four route-target layout pages and a same-package component/helper closure without reopening any network, socket, or hybrid-host dependency lane.
- `harmonyos-examples-stock-chart-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `16-StockChart/entry/src/main/cangjie/index.cj`, `main_ability.cj`, the full local `constants/`, `models/`, `services/`, `viewmodels/`, and `views/` subtrees (`freeze_file_count=21`, excluding `ability_stage.cj`)
  - tags: `page-shell` + `appstorage-chart-shell` + `local-resource-renderer-stack`
  - reason: the sample keeps the AppStorage/window-wiring entry shell, local resource-backed data service, and same-package renderer/viewmodel stack in one closure without network, socket, or hybrid-host pressure.
- `harmonyos-examples-waterfall-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `WaterFall/entry/src/main/cangjie/src/index.cj`, `component/card/CoverCard.cj`, `component/waterfall/WaterColumn.cj`, `entity/media.cj`, `event/EventBus.cj`, `mock/mock.cj`, and `utils/DataSource.cj` (`freeze_file_count=7`, excluding `ability_stage.cj`, `main_ability.cj`, and `component/index.cj`)
  - tags: `page-shell` + `eventbus-waterfall` + `local-mock-feed`
  - reason: the sample keeps the host page, event-bus/timer waterfall components, and local mock/data-source helpers in one bounded closure without reopening any network, socket, or hybrid-host lane.

## Deferred / Excluded Findings

- `HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry shell still expands into a broader multi-page component playground than the selected P21 closures.
- `HarmonyOS-Examples/06-AIChatLite/entry/src/main/cangjie/src/index.cj`
  - deferred because the sample still hardcodes a SiliconFlow URL/key path and uses `net.http` plus `Authorization` headers.
- `HarmonyOS-Examples/AIClassify/entry/src/main/cangjie/src/index.cj`
  - deferred because the page couples file-picker permissions, image preprocessing, random rawfile fallback, and MindSpore native model loading in one entry shell.
- `HarmonyOS-Examples/AIChatPro/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry still mixes `net.http`, router-driven settings flow, global ability context, and local model-loading pressure.
- `HarmonyOS-Examples/DouYinUI/entry/src/main/cangjie/src/index.cj`
  - deferred because the tab shell still fans into a broader cross-tab subtree and carries local HTTP helper pressure.
- `HarmonyOS-Examples/News/NewsApp/entry/src/main/cangjie/src/index.cj`
  - deferred because the page performs `net.http`-backed news fetches and uses a hardcoded image host.
- `HarmonyOS-Examples/TCPChat/Client/entry/src/main/cangjie/src/index.cj`
  - deferred because the client is socket-backed rather than a low-variance UI-only reserve input.
- `HarmonyOS-Examples/WebviewMix/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry shell still expands into web/router multi-page flow plus API-backed helper pressure.
- `HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry still mixes `SearchComponent`, `FunctionalScenes`, foldable-display state, `AppStorage`, and `Timer.after` back-handling inside one cross-feature shell.
- `HarmonyOS-Cangjie-Cases/ArkTSCangjieHybridApp/hybrid_modules/commentlist/src/main/cangjie/CommentsPage.cj`
  - deferred because the remaining UI surface is a hybrid component entry that depends on hybrid host context rather than the current regular app page-shell lane.
- `HarmonyOS-Cangjie-Cases/ArkTSCangjieHybridApp/hybrid_modules/shortvideo/src/main/cangjie/src/index.cj`
  - deferred because the module entry is hybrid interop glue while the visible UI subtree still depends on timer-driven video-player behavior.

## Results

- `artifacts/ui_pilots/20260413-phase06-ui-official-p21-regular-scout.json`
  - result: `decision=prepare-p21-regular-freeze`; the selected `source_paths` now freeze at `28 + 21 + 7 = 56` files and remain outside the official P0..P20 consumed-path baseline.
- `docs/reports/2026-04-13-phase06-p21-regular-candidate-scout.md`
  - result: records the scout guardrail, the exact exclusion baseline, the selected trio, the deferred list, the frozen source roots, and the explicit statement that the formal checkpoint remains `P20 / 220/220 live passed`.

## Decision

- The next candidate trio beyond the promoted `P20` checkpoint is `02-UILayout`, `16-StockChart`, and `WaterFall`.
- The formal checkpoint remains `P20 / 220/220 live passed`; this scout step does not refresh aggregate audit, live-pass coverage, or promoted SSOT.
- The next allowed execution step is the P21 mechanical freeze chain: `raw_docs/phase06-ui-p21 -> source corpus -> file manifest -> prompt-pilot manifest -> mock curator -> workset audit`, while still keeping P21 non-live and non-promoted until a later controlled-shell live closure.
