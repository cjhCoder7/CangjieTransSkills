# 2026-04-13 Phase06 P18 Regular Candidate Scout

## Goal

Determine the next direct regular Phase06 reserve workset after the formal `P17 / 103/103 live passed` checkpoint, using only the remaining official-repo reserve set and keeping the next freeze bounded, reproducible, and evidence-first.

## Inputs

- `AGENTS.md`
- `/.claude/status/current-phase.md`
- `docs/reports/2026-04-13-phase06-p17-regular-promotion.md`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.json`
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.validation.json`
- `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r12.json`
- `/tmp/phase06-source-scout/HarmonyOS-Examples`
- `/tmp/phase06-source-scout/HarmonyOS-Cangjie-Cases`
- `artifacts/ui_pilots/20260413-phase06-ui-official-p18-regular-scout.json`

## Method

1. Reconfirmed that any post-`P17` expansion must stay on the official reserve path and must not reopen the draft lane, the public `cangjiechallenge` pool, register-level manual selection, or the exception rail.
2. Re-audited the remaining official reserve roots and compared candidates by explicit freeze surface, transitive helper pressure, timing/display sensitivity, and reproducibility risk.
3. Preferred samples whose page-shell state, builders, and helper logic stay source-backed inside one bounded subtree, even if that subtree spans multiple files.
4. Re-scanned each selected candidate for direct same-package dependencies across `index.cj` and every currently selected `source_paths`; this round specifically pulled `10-Schedule/entry/src/main/cangjie/main_ability.cj` into the candidate because `index.cj` directly references `MainAbility.abilityContext`.
5. Rejected candidates whose visible entry page hides cross-feature imports, timer/display coupling, random/mock pressure, or package-namespace ambiguity that would make the next direct freeze less robust.

## Selected regular candidates

- `harmonyos-examples-calculator-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - freeze set: `04-Calculator/entry/src/main/cangjie/src/index.cj` plus `service/dynamic_param.cj`, the full `entity/` keypad model set, and the local `utils/` evaluator helpers (`freeze_file_count=11`)
  - tags: `page-shell` + `controller-owned-state` + `deterministic-utility-backed`
  - reason: `EntryView` owns a deterministic keypad grid while every evaluator helper stays explicit under the same subtree; the selected freeze surface carries no timer, display, network, or `ResourceManager` pressure.
- `harmonyos-examples-schedule-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - freeze set: `10-Schedule/entry/src/main/cangjie/index.cj` plus `components/BackRow.cj`, `Course.cj`, `SectionRow.cj`, `SectionTime.cj`, `dataModel/CourseEntity.cj` / `CourseItem.cj`, and `main_ability.cj` (`freeze_file_count=8`)
  - tags: `page-shell` + `controller-owned-state` + `builder-heavy-grid`
  - reason: The schedule page keeps `TabsController`, `Scroller` synchronization, course rendering, and the direct `MainAbility.abilityContext` dependency inside one bounded subtree; although it is resource-backed, the helper surface is explicit and deterministic after adding `main_ability.cj`.
- `harmonyos-examples-custom-keyboard-entry-view`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - freeze set: `17-CustomKeyboard/entry/src/main/cangjie/index.cj` plus `components/FooterBuilder.cj`, `LicensePlateInputBuilder.cj`, `PaymentInfoBuilder.cj`, `TitleBuilder.cj`, `constants/KeyboardConstants.cj`, `constants/StyleConstants.cj`, and `model/Keyboard.cj` (`freeze_file_count=8`)
  - tags: `page-shell` + `controller-owned-state` + `custom-keyboard-builder`
  - reason: The license-plate flow closes through explicit `AppStorage` / `StorageLink` state, local builders, and local constants/model files, giving a bounded interactive sample without timer or cross-feature imports.

## Deferred / excluded findings

- `HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/index.cj`
  - deferred because the page depends on a repeat timer, `launch`-based progress updates, and display/window helpers, so its runtime behavior is less deterministic than the selected trio.
- `HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/index.cj`
  - deferred because the sample couples timer-driven unlock logic, `EventBus` wiring, and mock/random-backed content, which weakens reproducibility for the next direct reserve freeze.
- `HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/entry/src/main/cangjie/src/index.cj`
  - deferred because the apparent entry page imports `SearchComponent`, `FunctionalScenes`, custom tab bar, address exchange, modal window, and secondary linkage features, so the true freeze surface is materially larger than the visible file count.
- `HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/index.cj`
  - deferred because the sample still carries package-namespace indirection and multiple page/model hops, making its import surface less straightforward than the three selected candidates.

## Results

- `artifacts/ui_pilots/20260413-phase06-ui-official-p18-regular-scout.json`
  - result: `selected_candidate_count=3`, `deferred_candidate_count=4`, `decision=prepare-p18-regular-freeze`; the `10-Schedule` candidate now records `main_ability.cj` in `source_paths` and `freeze_file_count=8`.
- `docs/reports/2026-04-13-phase06-p18-regular-candidate-scout.md`
  - result: fixes the next direct regular reserve trio and the exclusion rationale without advancing the formal checkpoint, and now documents the `10-Schedule` direct same-package rescan.

## Decision

- The next task is to freeze a direct `P18` regular reserve workset from `04-Calculator`, `10-Schedule`, and `17-CustomKeyboard`.
- The formal checkpoint remains `P17 / 103/103 live passed`; this scout-only turn does not mutate the primary sample manifest, live-pass coverage, aggregate audit, or SSOT checkpoint.
- The next execution step is to freeze these official-reserve files into `raw_docs/phase06-ui-p18` and then run the standard regular chain: `source corpus -> file manifest -> prompt-pilot manifest -> mock curator -> workset audit -> live curator -> aggregate audit -> coverage -> SSOT`.
