# 2026-04-12 Phase06 P7 Draft Candidate Scout

## Goal

Scout the next regular Phase06 source supply outside the exhausted current public `cangjiechallenge` pool, then freeze only the strongest low-coupling official-repo candidates into a draft-ready chain.

## Inputs

- `AGENTS.md`
- `.claude/status/current-phase.md`
- `/tmp/phase06-source-scout/HarmonyOS-Examples`
- `/tmp/phase06-source-scout/HarmonyOS-Cangjie-Cases`
- `docs/manifests/phase06_ui_sample_manifest_p7_draft.json`
- `docs/manifests/phase06_ui_source_corpus_p7_draft.json`
- `docs/manifests/phase06_ui_p7_draft_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p7_draft_batch1.json`
- `artifacts/ui_pilots/20260412-phase06-ui-official-p7-draft-scout.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p7-draft-workset-audit.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p7-draft-pilot-batch1/live_curator/20260412-phase06-ui-p7-draft-batch1-mock-curator-r1/batch-report.json`

## Method

1. Re-audited external UI sources outside the exhausted current public `cangjiechallenge` pool, prioritizing already approved official repos.
2. Enumerated unconsumed `.cj` files with direct `@Entry` / `@Component` ArkUI decorators.
3. Preferred single-file page shells without hybrid/web/bridge/bootstrap pressure and with minimal extra freeze surface.
4. Frozen the selected CommonUI files into `raw_docs/phase06-ui-p7-draft`, then built the `source corpus -> file manifest -> prompt-pilot manifest` chain.
5. Validated the draft lane with a mock curator batch plus exhausted-workset audit.

## Selected draft candidates

- `harmonyos-examples-commonui-text-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - file: `CommonUI/entry/src/main/cangjie/src/pages/textSample.cj`
  - tags: `page-shell` + `view-model-renderer`
- `harmonyos-examples-commonui-slider-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - file: `CommonUI/entry/src/main/cangjie/src/pages/sliderSample.cj`
  - tags: `page-shell` + `view-model-renderer`
- `harmonyos-examples-commonui-tabs-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples @ f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - file: `CommonUI/entry/src/main/cangjie/src/pages/tabsSample.cj`
  - tags: `page-shell` + `controller-owned-state`

## Deferred / excluded findings

- `HarmonyOS-Cangjie-Cases/.../AddressExchangeView.cj`
  - kept as a valid reserve candidate, but the selected CommonUI trio provided three same-commit single-file page shells with lower freeze cost in one batch.
- `HarmonyOS-Cangjie-Cases/.../SecondaryLinkageExample.cj`
  - deferred because it imports `FunctionDescription` plus custom data-source support types, increasing freeze surface relative to the current draft target.
- `HarmonyOS-Cangjie-Cases/.../ToDoList.cj`
  - deferred because it depends on model types, dialog builder, style config, and paired item component, making the freeze set materially larger than the current draft needs.
- `HarmonyOS-Examples/.../buttonSample.cj` and `checkBoxSample.cj`
  - kept as reserves because they are valid single-file pages but offer narrower event/state coverage than the selected text/slider/tabs trio.

## Commands

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest_p7_draft.json --corpus-root raw_docs/phase06-ui-p7-draft --manifest-name phase06-ui-source-corpus-p7-draft --priority P7 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p7_draft.json`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p7_draft.json --sample-manifest docs/manifests/phase06_ui_sample_manifest_p7_draft.json --output docs/manifests/phase06_ui_p7_draft_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p7_draft_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p7_draft_batch1 --artifacts-root artifacts/ui_pilots/20260412-phase06-ui-p7-draft-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p7_draft_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p7_draft_batch1.json --run-label 20260412-phase06-ui-p7-draft-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p7_draft_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p7_draft_batch1.json --output artifacts/ui_pilots/20260412-phase06-ui-p7-draft-workset-audit.json --require-exhausted`

## Results

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: `exit 0`
  - artifact: builder and regression test sources compile cleanly after the new `P7` overrides landed.
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `13 tests OK (skipped=1)`
  - artifact: draft `P7` overrides are now covered alongside the existing regular/draft lanes.
- `docs/manifests/phase06_ui_source_corpus_p7_draft.json`
  - result: `sample_count=3`, `file_count=3`, `corpus_root=../../raw_docs/phase06-ui-p7-draft`.
- `docs/manifests/phase06_ui_p7_draft_file_manifest.json`
  - result: `slice_count=3`, `role_counts={"page": 3}`, `structure_counts={"page-shell": 3}`.
- `docs/manifests/phase06_ui_prompt_pilot_p7_draft_batch1.json`
  - result: `pilot_count=3`, `track_counts={"residual-page-shell-view-model-renderer-page": 2, "residual-page-shell-controller-owned-state-page": 1}`.
- `artifacts/ui_pilots/20260412-phase06-ui-p7-draft-pilot-batch1/live_curator/20260412-phase06-ui-p7-draft-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=3`, `passed_count=3`; all three slices record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=true`.
- `artifacts/ui_pilots/20260412-phase06-ui-p7-draft-workset-audit.json`
  - result: `covered_slice_count=3`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.

## Decision

- The `p7-draft` lane is now mechanically ready.
- The regular Phase06 live checkpoint remains `35/35 live passed`; this turn did not promote the new lane or open a live curator batch on the promoted rail.
- The next direct move is to review and merge `docs/manifests/phase06_ui_sample_manifest_p7_draft.json` into the primary sample manifest, copy `raw_docs/phase06-ui-p7-draft` to `raw_docs/phase06-ui-p7`, and rerun the formal regular `source corpus -> file manifest -> prompt-pilot manifest -> live curator` chain on the promoted lane.
