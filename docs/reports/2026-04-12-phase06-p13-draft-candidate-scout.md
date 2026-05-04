# 2026-04-12 Phase06 P13 Draft Candidate Scout

## Goal

Continue the regular Phase06 source-supply line after the formal checkpoint reached `54/54 live passed`, using only the remaining official-repo reserve set while preferring honest file boundaries over misleading single-file picks.

## Inputs

- `AGENTS.md`
- `.claude/status/current-phase.md`
- `docs/reports/2026-04-12-phase06-p12-regular-promotion.md`
- `/tmp/phase06-source-scout/HarmonyOS-Examples`
- `/tmp/phase06-source-scout/HarmonyOS-Cangjie-Cases`
- `docs/manifests/phase06_ui_sample_manifest_p13_draft.json`
- `artifacts/ui_pilots/20260412-phase06-ui-official-p13-draft-scout.json`

## Method

1. Re-audited the remaining official reserve after the promoted `P12` closure, still restricting the search to `HarmonyOS-Examples` / `HarmonyOS-Cangjie-Cases`.
2. Kept one truly single-file route shell as the narrow anchor, then preferred explicit helper freezes whenever the alternative would be a misleading “single-file” interpretation.
3. Selected one bounded timer-driven canvas sample and one geometry playground only after freezing every same-package helper it actually depends on.
4. Deferred the still-valid but narrower or heavier official candidates whose coverage-to-freeze ratio is weaker than the selected trio at the current checkpoint.
5. Froze the selected files into `raw_docs/phase06-ui-p13-draft` and landed the draft sample manifest for the next builder stage.

## Selected draft candidates

- `harmonyos-examples-commonui-entry-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - file: `CommonUI/entry/src/main/cangjie/src/index.cj`
  - tags: `page-shell` + `view-model-renderer`
- `harmonyos-examples-clock-canvas-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - files:
    - `11-Clock/entry/src/main/cangjie/src/index.cj`
    - `11-Clock/entry/src/main/cangjie/src/utils/clock.cj`
  - tags: `page-shell` + `controller-owned-state`
- `harmonyos-examples-simpledraw-geometry-shell`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - files:
    - `SimpleDraw/entry/src/main/cangjie/src/index.cj`
    - `SimpleDraw/entry/src/main/cangjie/src/DGeometry.cj`
    - `SimpleDraw/entry/src/main/cangjie/src/Geometry.cj`
  - tags: `page-shell` + `controller-owned-state`

## Deferred / excluded findings

- `19-CangjiexArkTS/CalendarManager/entry/src/main/cangjie/views/EntryView.cj`
  - deferred because the page-plus-applog pair is mechanically clean but contributes narrower behavior coverage than the selected `11-Clock` timer/canvas lane.
- `CangjieAppDevelopment/feature/secondarylinkage/src/main/cangjie/src/SecondaryLinkageExample.cj`
  - deferred because it still depends on `FunctionDescription` plus custom data-source support types, so the freeze surface remains materially larger than the current draft target.
- `CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/pages/ToDoList.cj`
  - deferred because it still needs dialog, item, and model companions, keeping its helper surface above the current regular-lane reserve threshold.

## Results

- `raw_docs/phase06-ui-p13-draft`
  - result: `sample_count=3`, `file_count=6`; the draft freeze now holds one single-file route shell plus two explicit helper-backed official reserve samples.
- `docs/manifests/phase06_ui_sample_manifest_p13_draft.json`
  - result: draft sample manifest written with `P13` priority and explicit helper freezes for `11-Clock` and `SimpleDraw`.
- `artifacts/ui_pilots/20260412-phase06-ui-official-p13-draft-scout.json`
  - result: scout evidence records the selected trio, deferred candidates, and the post-`P12` reserve rationale.

## Decision

- The `p13-draft` lane is now curated at the sample-selection level.
- The next direct move is to extend `scripts/build_phase06_ui_file_manifest.py` plus its regression tests with `P13-draft` overrides, then run the standard `source corpus -> file manifest -> prompt-pilot manifest -> mock curator -> exhausted-workset audit` chain on the draft lane.
