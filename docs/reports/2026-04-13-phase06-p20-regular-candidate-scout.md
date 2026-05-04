# 2026-04-13 Phase06 P20 Regular Candidate Scout

## Goal

Determine the next direct regular Phase06 reserve workset after the formal `P19 / 181/181 live passed` checkpoint, using only the remaining official-repo reserve set and an explicit exclusion baseline so this scout-only turn stays bounded, reproducible, and evidence-first.

## Formal Status Guardrail

- The formal regular checkpoint remains `P19 / 181/181 live passed`.
- This turn is `scout-only`: it does not mutate `docs/manifests/phase06_ui_sample_manifest.json`, any `raw_docs/phase06-ui-p20*`, any `docs/manifests/phase06_ui_source_corpus_p20.json`, any `docs/manifests/phase06_ui_p20_file_manifest.json`, any `docs/manifests/phase06_ui_prompt_p20_batch1.json`, any `*live-pass-coverage*`, any `*regular-expansion-audit*`, `AGENTS.md`, or `/.claude/status/current-phase.md`.
- The current SSOT remains the promoted `P19 / 181/181 live passed` closure evidenced by `docs/reports/2026-04-13-phase06-p19-regular-promotion.md`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.validation.json`, and `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json`.

## Inputs

- `AGENTS.md`
- `/.claude/status/current-phase.md`
- `docs/reports/2026-04-13-phase06-p19-regular-promotion.md`
- `docs/manifests/phase06_ui_p0_file_manifest.json` through `docs/manifests/phase06_ui_p19_file_manifest.json`
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json`
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.validation.json`
- `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json`
- `/tmp/phase06-source-scout/HarmonyOS-Examples`
- `/tmp/phase06-source-scout/HarmonyOS-Cangjie-Cases`
- `artifacts/ui_pilots/20260413-phase06-ui-official-p20-regular-scout.json`

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

1. Treated `docs/manifests/phase06_ui_p0_file_manifest.json` through `docs/manifests/phase06_ui_p19_file_manifest.json` as the direct consumed-slice baseline for the formal regular lane.
2. Used `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json` plus `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.validation.json` to confirm the formal lane already covers `63` regular samples with `non_exhausted_workset_count=0`.
3. Used `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json` to confirm the promoted regular lane already holds `181/181` live-passed slices through `P19`.
4. Explicitly excluded every official `source_path` already present in the P0..P19 file manifests and did not reopen the draft lane, the public `cangjiechallenge` pool, register-level manual selection, or the exception rail.
5. The exclusion baseline currently covers `152` consumed official source-backed slice paths, `152` unique official source paths, and `43` official regular sample ids when recalculated directly from the P0..P19 file-manifest `entries`.

## Method

1. Reconfirmed from the hot SSOT that post-`P19` regular expansion must continue only from the remaining official `HarmonyOS-Examples` / `HarmonyOS-Cangjie-Cases` reserve while keeping the current formal checkpoint fixed at `P19 / 181/181 live passed`.
2. Re-audited the remaining official reserve roots after removing all already consumed official `source_path` entries contributed by `docs/manifests/phase06_ui_p0_file_manifest.json` through `docs/manifests/phase06_ui_p19_file_manifest.json`.
3. Compared the remaining candidates by bounded same-package closure size, route fan-out, `main_ability` / `AppStorage` pressure, timer or event-bus pressure, network-secret coupling, hybrid-host coupling, and overlap risk with already consumed slices.
4. Preferred candidates whose freeze surface can be stated explicitly inside one repo-local package subtree, and deferred samples that still require network credentials, sockets, hybrid-host-only context, or broader timer-driven behavior than the current post-`P19` window can justify.
5. Kept this turn scout-only: no sample manifest append, no raw source freeze, no file manifest build, no prompt-pilot manifest build, no mock/live curator, no aggregate audit refresh, and no SSOT move.

## Selected Regular Candidates

- `harmonyos-examples-kuaishou-ui-slowfeet-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `KuaiShouUI/SlowFeet/src/main/cangjie/src/index.cj`, the route-target pages `Pages/chat.cj`, `Pages/video.cj`, and `Pages/user.cj`, plus the local `Model/ChatModel.cj` and `Model/VideoModel.cj` (`freeze_file_count=6`, excluding `main_ability.cj` and `ability_stage.cj`)
  - tags: `page-shell` + `route-target-backed` + `same-package-tabbed-shell`
  - reason: the entry shell stays inside one same-package tabbed UI subtree, the visible route targets are local and explicit, and the remaining closure avoids network, timer, event-bus, and `AppStorage` pressure.
- `harmonyos-examples-adaptive-ui-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `08-AdaptiveUI/entry/src/main/cangjie/src/index.cj`, `main_ability.cj`, `common/constants.cj`, the full local `component/` subtree, and `utils/hilog.cj` plus `utils/windows_manager.cj` (`freeze_file_count=8`, excluding `ability_stage.cj`)
  - tags: `page-shell` + `appstorage-backed-layout` + `timer-backed-progress`
  - reason: the sample still has timer-backed progress, but unlike the heavier remaining timer candidates it keeps that behavior local to the entry page, one `main_ability` file, and one same-package component subtree without network or event-bus coupling.
- `harmonyos-examples-order-ui-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `OrderUI/entry/src/main/cangjie/src/index.cj`, `main_ability.cj`, `api/ShopApi.cj`, the full local `components/home/` subtree, same-package `components/me/me.cj` and `components/message/message.cj`, `constants/{baseConstants,breakpointConstants,homeConstants}.cj`, `models/{homeMenuModel,productInfoModel,shopInfoModel,tab,temp}.cj`, and `utils/{BreakpointType,ResourceUtil,WindowUtil}.cj` (`freeze_file_count=25`, excluding `ability_stage.cj`, `components/package.cj`, and `pages/package.cj`)
  - exclusion note: `/tmp/phase06-source-scout/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/utils/dataSource.cj` stays out because no selected OrderUI source file imports or references `ohos_app_cangjie_entry.utils.MyDataSource`; `/tmp/phase06-source-scout/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/utils/resourceManager.cj` also stays out because it is a commented-out draft helper and no selected source file imports it. The current source-backed closure only pulls `BreakpointType.cj`, `ResourceUtil.cj`, and `WindowUtil.cj` from `utils/`.
  - tags: `page-shell` + `safe-area-appstorage` + `same-package-home-tabs`
  - reason: the visible app shell remains inside one same-package home-tab closure, the required safe-area and breakpoint wiring is explicit in `main_ability.cj` and `WindowUtil.cj`, and the only data-loader pressure is the local mock `ShopApi` sleep-backed fetch rather than a network dependency.

## Deferred / Excluded Findings

- `HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry shell expands into a `54`-file multi-page component playground and is much broader than the currently selected bounded closures.
- `HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/index.cj`
  - deferred because the visible shell immediately fans into `ScrollView`, `ListView`, `BadgeView`, and `SimpleLayoutView`, so the next direct freeze would sprawl across already familiar patterns instead of producing a tighter new workset.
- `HarmonyOS-Examples/06-AIChatLite/entry/src/main/cangjie/src/index.cj`
  - deferred because the sample still hardcodes a SiliconFlow URL/key path and uses `net.http` plus `Authorization: Bearer ...`.
- `HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/index.cj`
  - deferred because the required closure still includes `main_ability` / `AppStorage` support plus `TimeLineViewModel` timer-driven updates across the chart renderer stack, making it heavier than the selected trio.
- `HarmonyOS-Examples/AIClassify/entry/src/main/cangjie/src/index.cj`
  - deferred because the page couples file-picker permissions, image preprocessing, random rawfile fallback, and MindSpore native model loading in one entry shell.
- `HarmonyOS-Examples/AIChatPro/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry still mixes `net.http`, router-driven settings flow, global ability context, and local model-loading pressure.
- `HarmonyOS-Examples/DouYinUI/entry/src/main/cangjie/src/index.cj`
  - deferred because the tab shell fans into a `37`-file cross-tab subtree and still carries local HTTP helper pressure.
- `HarmonyOS-Examples/News/NewsApp/entry/src/main/cangjie/src/index.cj`
  - deferred because the page performs `net.http`-backed news fetches and uses a hardcoded image host.
- `HarmonyOS-Examples/TCPChat/Client/entry/src/main/cangjie/src/index.cj`
  - deferred because the client is socket-backed rather than a low-variance UI-only reserve input.
- `HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/index.cj`
  - deferred because the sample still couples `EventBus` wiring with timer-based scroll unlock behavior.
- `HarmonyOS-Examples/WebviewMix/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry shell still expands into web/router multi-page flow plus API-backed helper pressure.
- `HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/entry/src/main/cangjie/src/index.cj`
  - deferred because the entry still mixes `SearchComponent`, `FunctionalScenes`, foldable-display state, `AppStorage`, and `Timer.after` back-handling inside one cross-feature shell.
- `HarmonyOS-Cangjie-Cases/ArkTSCangjieHybridApp/hybrid_modules/commentlist/src/main/cangjie/CommentsPage.cj`
  - deferred because the remaining UI surface is a hybrid component entry that depends on hybrid host context rather than the current regular app page-shell lane.
- `HarmonyOS-Cangjie-Cases/ArkTSCangjieHybridApp/hybrid_modules/shortvideo/src/main/cangjie/src/index.cj`
  - deferred because the module entry is hybrid interop glue while the visible UI subtree still depends on timer-driven video-player behavior.

## Results

- `artifacts/ui_pilots/20260413-phase06-ui-official-p20-regular-scout.json`
  - result: `selected_candidate_count=3`, `deferred_candidate_count=14`, `decision=prepare-p20-regular-freeze`; the selected `source_paths` now freeze at `6 + 8 + 25` files and remain outside the official P0..P19 consumed-slice baseline.
- `docs/reports/2026-04-13-phase06-p20-regular-candidate-scout.md`
  - result: records the scout-only guardrail, the exact exclusion baseline, the selected trio, the deferred list, the frozen source roots, and the explicit statement that the formal checkpoint remains `P19 / 181/181 live passed`.

## Decision

- The next candidate trio beyond the promoted `P19` checkpoint is `KuaiShouUI/SlowFeet`, `08-AdaptiveUI`, and `OrderUI`.
- The formal checkpoint remains `P19 / 181/181 live passed`; this scout-only turn does not mutate the sample manifest, raw corpus, aggregate audit, live-pass coverage, or SSOT.
- If a later turn authorizes mechanical work, the next execution step is to freeze the selected official-reserve files into `raw_docs/phase06-ui-p20` and then run the standard regular chain: `source corpus -> file manifest -> prompt-pilot manifest -> mock curator -> workset audit -> live curator -> aggregate audit -> coverage -> SSOT`.
