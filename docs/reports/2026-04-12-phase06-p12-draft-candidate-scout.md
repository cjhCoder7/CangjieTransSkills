# 2026-04-12 Phase06 P12 Draft Candidate Scout

## Goal

Continue the regular Phase06 source-supply line after the formal checkpoint reached `50/50 live passed`, using only the remaining official-repo reserve set while preferring truly self-contained files and freezing helper pressure explicitly when that produces a more robust workset than forcing a weaker three-slice trio.

## Inputs

- `AGENTS.md`
- `.claude/status/current-phase.md`
- `docs/reports/2026-04-12-phase06-p11-regular-promotion.md`
- `/tmp/phase06-source-scout/HarmonyOS-Examples`
- `/tmp/phase06-source-scout/HarmonyOS-Cangjie-Cases`
- `docs/manifests/phase06_ui_sample_manifest_p12_draft.json`
- `docs/manifests/phase06_ui_source_corpus_p12_draft.json`
- `docs/manifests/phase06_ui_p12_draft_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p12_draft_batch1.json`
- `artifacts/ui_pilots/20260412-phase06-ui-official-p12-draft-scout.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p12-draft-workset-audit.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p12-draft-pilot-batch1/live_curator/20260412-phase06-ui-p12-draft-batch1-mock-curator-r1/batch-report.json`

## Method

1. Re-audited the remaining official reserve after the promoted `P11` closure, still restricting the search to `HarmonyOS-Examples` / `HarmonyOS-Cangjie-Cases`.
2. Rejected files whose apparently clean import lists still hid same-package support code after deeper tree inspection.
3. Selected two true single-file page shells and one explicit page-plus-helper sample, because that `3-sample / 4-slice` mix was more robust than forcing a lower-value `3-sample / 3-slice` trio.
4. Froze the selected files into `raw_docs/phase06-ui-p12-draft`, then landed draft and promoted `P12` file-level overrides plus regression coverage.
5. Built the `source corpus -> file manifest -> prompt-pilot manifest` chain and validated the draft lane with mock curator plus exhausted-workset audit.

## Selected draft candidates

- `harmonyos-examples-silkui-calendar-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - file: `Silkui/entry/src/main/cangjie/src/pages/calendar.cj`
  - tags: `page-shell` + `view-model-renderer`
- `harmonyos-examples-deepseek-about-view-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - file: `07-DeepSeek/entry/src/main/cangjie/src/pages/about_view.cj`
  - tags: `page-shell` + `view-model-renderer`
- `harmonyos-examples-chargingui-battery-shell`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - files:
    - `ChargingUI/entry/src/main/cangjie/src/index.cj`
    - `ChargingUI/entry/src/main/cangjie/src/electric_quantity.cj`
  - tags: `page-shell` + `controller-owned-state` + `rich-component`

## Deferred / excluded findings

- `HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/index.cj`
  - deferred because it is mechanically clean but duplicates the low-value routing-menu shape already covered by `Silkui/calendar.cj` while adding less behavioral breadth than the selected `ChargingUI` page-plus-component pair.
- `HarmonyOS-Examples/19-CangjiexArkTS/CalendarManager/entry/src/main/cangjie/views/EntryView.cj`
  - deferred because it only becomes viable after freezing a trivial logging helper, which is a weaker slice investment than the selected `ChargingUI` component pair.
- `HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/index.cj`
  - rejected after deeper tree inspection because it depends on same-package geometry helpers (`DGeometry.cj`, `Geometry.cj`), so the apparent single-file surface is misleading.

## Commands

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest_p12_draft.json --corpus-root raw_docs/phase06-ui-p12-draft --manifest-name phase06-ui-source-corpus-p12-draft --priority P12 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p12_draft.json`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p12_draft.json --sample-manifest docs/manifests/phase06_ui_sample_manifest_p12_draft.json --output docs/manifests/phase06_ui_p12_draft_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p12_draft_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p12_draft_batch1 --artifacts-root artifacts/ui_pilots/20260412-phase06-ui-p12-draft-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p12_draft_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p12_draft_batch1.json --run-label 20260412-phase06-ui-p12-draft-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p12_draft_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p12_draft_batch1.json --output artifacts/ui_pilots/20260412-phase06-ui-p12-draft-workset-audit.json --require-exhausted`

## Results

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: `exit 0`
  - artifact: builder and regression test sources compile cleanly after the `P12` draft/regular overrides were unified to one final candidate set.
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `24 tests OK (skipped=1)`
  - artifact: the new `P12` draft lane is now covered in the file-manifest regression suite; the promoted `P12` lane still skipped until regular artifacts were created.
- `docs/manifests/phase06_ui_source_corpus_p12_draft.json`
  - result: `sample_count=3`, `file_count=4`, `corpus_root=../../raw_docs/phase06-ui-p12-draft`.
- `docs/manifests/phase06_ui_p12_draft_file_manifest.json`
  - result: `slice_count=4`, `role_counts={"page": 3, "component": 1}`, `structure_counts={"page-shell": 3, "rich-component": 1}`.
- `docs/manifests/phase06_ui_prompt_pilot_p12_draft_batch1.json`
  - result: `pilot_count=4`, `track_counts={"residual-page-shell-view-model-renderer-page": 2, "residual-page-shell-controller-owned-state-page": 1, "residual-rich-component-controller-owned-state-component": 1}`.
- `artifacts/ui_pilots/20260412-phase06-ui-p12-draft-pilot-batch1/live_curator/20260412-phase06-ui-p12-draft-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=4`, `passed_count=4`; all four draft slices record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=true`.
- `artifacts/ui_pilots/20260412-phase06-ui-p12-draft-workset-audit.json`
  - result: `covered_slice_count=4`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.

## Decision

- The `p12-draft` lane is mechanically ready.
- The selected `3-sample / 4-slice` workset is preferable to forcing a weaker three-slice trio, because it keeps all dependency pressure explicit and still closes cleanly through mock curator plus exhausted-workset audit.
- The next direct move is to merge `docs/manifests/phase06_ui_sample_manifest_p12_draft.json` into the primary sample manifest, copy `raw_docs/phase06-ui-p12-draft` to `raw_docs/phase06-ui-p12`, and rerun the formal regular `source corpus -> file manifest -> prompt-pilot manifest -> live curator` chain on the promoted lane.
