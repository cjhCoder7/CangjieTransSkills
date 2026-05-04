# 2026-04-12 Phase06 P16 Regular Promotion

## Goal

Promote the next official-reserve P16 workset directly from the formal P15 / 77/77 live passed startpoint, without reopening the draft lane, the public cangjiechallenge pool, register-level manual selection, or the exception rail, then close the promoted lane with the full formal chain: sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> workset audit -> live curator -> aggregate audit -> coverage -> SSOT.

## Formal Startpoint

- artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r14.json
- artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r14.validation.json
- artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r10.json

## Inputs

- docs/manifests/phase06_ui_sample_manifest.json
- raw_docs/phase06-ui-p16
- docs/manifests/phase06_ui_source_corpus_p16.json
- docs/manifests/phase06_ui_p16_file_manifest.json
- docs/manifests/phase06_ui_prompt_pilot_p16_batch1.json
- artifacts/ui_pilots/20260412-phase06-ui-p16-pilot-batch1/live_curator/20260412-phase06-ui-p16-batch1-mock-curator-r1/batch-report.json
- artifacts/ui_pilots/20260412-phase06-ui-p16-workset-audit.json
- artifacts/ui_pilots/20260412-phase06-ui-p16-pilot-batch1/live_curator/20260412-phase06-ui-p16-batch1-live-curator-r1/batch-report.json
- artifacts/ui_pilots/20260412-phase06-ui-p16-pilot-batch1/live_curator/20260412-phase06-ui-p16-bankui-search-live-curator-r2/batch-report.json
- artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.json
- artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.validation.json
- artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r11.json

## Method

1. Froze three new official-reserve samples directly into raw_docs/phase06-ui-p16 with every required helper kept explicit:
   - HarmonyOS-Examples/BankUI/entry/src/main/cangjie/src/Page/search.cj + Component/searchInput.cj + Component/searchDelete.cj + Component/searchLayout.cj
   - HarmonyOS-Examples/CanvasPoker/entry/src/main/cangjie/src/index.cj + card/cards.cj + card/const.cj
   - HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/index.cj + color_picker/color_picker.cj + color_slider.cj + color_palette.cj + color_utils.cj + hsv.cj
2. Merged the three P16 samples into docs/manifests/phase06_ui_sample_manifest.json.
3. Extended scripts/build_phase06_ui_file_manifest.py and tests/test_build_phase06_ui_file_manifest.py with promoted P16 regular overrides while also normalizing the stale promoted P15 FunctionalScenes naming to the formal slice ids already recorded by the baseline checkpoint; no duplicate P15 live curator, mock curator, or test reruns were introduced.
4. Rebuilt the promoted P16 source corpus, file manifest, and prompt-pilot manifest.
5. Revalidated the promoted lane with py_compile, a targeted promoted-P16 builder regression, a mock curator batch, and an exhausted-workset audit.
6. Ran the promoted P16 live curator batch in a controlled shell with .env.local sourced. The initial batch closed 12/13 slices and left only phase06-ui-p16-bankui-search-page in infrastructure-error; the corresponding run.log and orchestration.json record LLMNetworkException / translator returned empty candidate code, so the miss was infrastructure-only rather than a translator-or-verifier regression.
7. Performed a minimal single-slice live rerun only for phase06-ui-p16-bankui-search-page; the rerun passed in round 1 and completed the live curator evidence set without replaying the rest of the workset.
8. Recomputed the aggregate regular expansion audit, validated it, refreshed live-pass coverage to include all P16 slices, and synced SSOT to the new formal checkpoint.

## Commands

- python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p16 --manifest-name phase06-ui-source-corpus-p16 --priority P16 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p16.json
- python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py
- python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p16.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p16_file_manifest.json
- python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p16_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p16_batch1 --artifacts-root artifacts/ui_pilots/20260412-phase06-ui-p16-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p16_batch1.json
- python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p16_batch1.json --run-label 20260412-phase06-ui-p16-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0
- python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p16_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p16_batch1.json --output artifacts/ui_pilots/20260412-phase06-ui-p16-workset-audit.json --require-exhausted
- set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p16_batch1.json --run-label 20260412-phase06-ui-p16-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p16_batch1.json --run-label 20260412-phase06-ui-p16-bankui-search-live-curator-r2 --slice-id phase06-ui-p16-bankui-search-page --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.json --require-decision hold-current-checkpoint-await-sample-curation
- python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.json --report artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation
- python3 - <<'PY' ... refresh artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r11.json from artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r10.json plus docs/manifests/phase06_ui_p16_file_manifest.json and the two P16 live batch reports

## Results

- docs/manifests/phase06_ui_sample_manifest.json
  - result: ordered_samples=54; the last three sample ids are harmonyos-examples-bankui-search-page, harmonyos-examples-canvas-poker-card-fan, and harmonyos-examples-color-picker-dialog.
- docs/manifests/phase06_ui_source_corpus_p16.json
  - result: sample_count=3, file_count=13.
- docs/manifests/phase06_ui_p16_file_manifest.json
  - result: slice_count=13, role_counts={ page: 3, component: 6, viewmodel: 4 }, structure_counts={ page-shell: 3, rich-component: 10 }.
- docs/manifests/phase06_ui_prompt_pilot_p16_batch1.json
  - result: pilot_count=13, source_sample_count=3; all P16 slices were selected into one residual workset.
- artifacts/ui_pilots/20260412-phase06-ui-p16-pilot-batch1/live_curator/20260412-phase06-ui-p16-batch1-mock-curator-r1/batch-report.json
  - result: status=passed, pilot_count=13, passed_count=13; all thirteen promoted P16 slices passed in mock mode.
- artifacts/ui_pilots/20260412-phase06-ui-p16-workset-audit.json
  - result: covered_slice_count=13, missing_slice_count=0, coverage_ratio=1.0, exhausted_workset=true.
- artifacts/ui_pilots/20260412-phase06-ui-p16-pilot-batch1/live_curator/20260412-phase06-ui-p16-batch1-live-curator-r1/batch-report.json
  - result: status=partial, pilot_count=13, passed_count=12; the only non-green slice is phase06-ui-p16-bankui-search-page, and its paired evidence records error_type=LLMNetworkException with message=translator API 调用失败：translator returned empty candidate code.
- artifacts/ui_pilots/20260412-phase06-ui-p16-pilot-batch1/live_curator/20260412-phase06-ui-p16-bankui-search-live-curator-r2/batch-report.json
  - result: status=passed, pilot_count=1, passed_count=1; phase06-ui-p16-bankui-search-page now records final_status=passed, verify_status=passed, round_count=1.
- Combined live P16 evidence across the two reports
  - result: all 13/13 promoted P16 slices now record final_status=passed, verify_status=passed; each P16 slice closed in round 1.
- artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.json
  - result: regular_sample_count=54, priority_counts={ P0: 6, P1: 4, P2: 3, P3: 3, P4: 3, P5: 2, P6: 3, P7: 3, P8: 3, P9: 3, P10: 3, P11: 3, P12: 3, P13: 3, P14: 3, P15: 3, P16: 3 }, final_decision=hold-current-checkpoint-await-sample-curation.
- artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.validation.json
  - result: validation_class=valid-expansion-audit, issue_count=0, warning_count=0.
- artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r11.json
  - result: expected_slice_count=90, passed_slice_count=90, coverage_ratio=1.0, regular_priority_counts={ P0: 12, P1: 9, P2: 3, P3: 3, P4: 3, P5: 2, P6: 3, P7: 3, P8: 3, P9: 3, P10: 3, P11: 3, P12: 4, P13: 6, P14: 9, P15: 8, P16: 13 }.

## Builder/Test Evidence Supplement

- Scope: this formal evidence supplement reran only builder/test coverage for the promoted `P15`/`P16` file-manifest changes; it did not replay any `P15` or `P16` live curator, mock curator, aggregate audit, or coverage refresh command.
- Command: `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: `passed`.
  - artifact path: `artifacts/test_runs/20260412-phase06-ui-p16-builder-regression/py_compile.log`
  - related builder artifact path: `docs/manifests/phase06_ui_p16_file_manifest.json`
- Command: `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `failed`; `Ran 29 tests in 0.200s`, `FAILED (failures=2)`, with failures in `test_manifest_can_expand_p13_draft_source_corpus_with_new_overrides` and `test_manifest_can_expand_promoted_p14_source_corpus_with_regular_overrides`.
  - artifact path: `artifacts/test_runs/20260412-phase06-ui-p16-builder-regression/test_build_phase06_ui_file_manifest.log`
  - related builder artifact path: `docs/manifests/phase06_ui_p16_file_manifest.json`
- Command: `python3 tests/test_build_phase06_ui_file_manifest.py Phase06UiFileManifestBuilderTests.test_manifest_can_expand_promoted_p15_source_corpus_with_regular_overrides Phase06UiFileManifestBuilderTests.test_manifest_can_expand_promoted_p16_source_corpus_with_regular_overrides`
  - result: `passed`; `Ran 2 tests in 0.004s`, `OK`, so the promoted `P15` naming normalization plus the promoted `P16` regular overrides remain covered directly by targeted regression.
  - artifact path: `artifacts/test_runs/20260412-phase06-ui-p16-builder-regression/targeted_p15_p16_regression.log`
  - related builder artifact path: `docs/manifests/phase06_ui_p16_file_manifest.json`
- Summary artifact path: `artifacts/test_runs/20260412-phase06-ui-p16-builder-regression/summary.json`

## Decision

- The formal regular P16 workset is now promoted and closed.
- The regular Phase06 checkpoint advances from P15 / 77/77 live passed to P16 / 90/90 live passed across P0/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11/P12/P13/P14/P15/P16.
- The regular lane remains closed to draft-only completion, the public cangjiechallenge pool, register-level manual selection, and the exception rail.
- Any further regular expansion must continue only from the remaining official reserve beyond docs/reports/2026-04-12-phase06-p16-regular-promotion.md, and it must again satisfy the same evidence-first closure before SSOT moves forward.
