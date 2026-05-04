# 2026-04-13 Phase06 P17 Regular Promotion

## Goal

Promote the next official-reserve P17 workset directly from the formal P16 / 90/90 live passed startpoint, without reopening the draft lane, the public cangjiechallenge pool, register-level manual selection, or the exception rail, then close the promoted lane with the full formal chain: sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> workset audit -> live curator -> aggregate audit -> coverage -> SSOT.

## Formal Startpoint

- artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.json
- artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r15.validation.json
- artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r11.json

## Inputs

- docs/manifests/phase06_ui_sample_manifest.json
- raw_docs/phase06-ui-p17
- docs/manifests/phase06_ui_source_corpus_p17.json
- docs/manifests/phase06_ui_p17_file_manifest.json
- docs/manifests/phase06_ui_prompt_pilot_p17_batch1.json
- artifacts/test_runs/20260413-phase06-ui-p17-builder-full-suite/summary.json
- artifacts/test_runs/20260413-phase06-ui-p17-builder-full-suite/test_build_phase06_ui_file_manifest.log
- artifacts/ui_pilots/20260413-phase06-ui-p17-pilot-batch1/live_curator/20260413-phase06-ui-p17-batch1-mock-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-p17-workset-audit.json
- artifacts/ui_pilots/20260413-phase06-ui-p17-pilot-batch1/live_curator/20260413-phase06-ui-p17-batch1-live-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.validation.json
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r12.json

## Method

1. Reconfirmed the formal lane still had to continue from the P16 official-reserve checkpoint and then froze three new official HarmonyOS-Examples samples into raw_docs/phase06-ui-p17 with every required helper kept explicit:
   - HarmonyOS-Examples/Game2048/entry/src/main/cangjie/src/index.cj + core/puzzle.cj + widget/common.cj
   - HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/index.cj + components/expression.cj + components/history.cj + components/keyboard.cj + components/theme.cj
   - HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/index.cj + cube/cube.cj + cube/matrix.cj + cube/permutation.cj + cube/rotation.cj
2. Merged the three P17 samples into docs/manifests/phase06_ui_sample_manifest.json and rebuilt the promoted P17 source corpus.
3. Extended scripts/build_phase06_ui_file_manifest.py and tests/test_build_phase06_ui_file_manifest.py with promoted P17 regular overrides, then reran the builder same-round full-suite chain instead of reusing the earlier fix-review evidence as a substitute.
4. Rebuilt the promoted P17 file manifest and prompt-pilot manifest.
5. Ran the promoted P17 mock curator batch and exhausted-workset audit.
6. Ran the promoted P17 live curator batch in a controlled shell with .env.local sourced; the whole workset closed without any infrastructure-only rerun.
7. Recomputed the aggregate regular expansion audit, validated it, refreshed live-pass coverage to include all P17 slices, and synced SSOT to the new formal checkpoint.

## Commands

- python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p17 --manifest-name phase06-ui-source-corpus-p17 --priority P17 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p17.json
- python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py
- python3 tests/test_build_phase06_ui_file_manifest.py
- python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p17.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p17_file_manifest.json
- python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p17_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p17_batch1 --artifacts-root artifacts/ui_pilots/20260413-phase06-ui-p17-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p17_batch1.json
- python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p17_batch1.json --run-label 20260413-phase06-ui-p17-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0
- python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p17_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p17_batch1.json --output artifacts/ui_pilots/20260413-phase06-ui-p17-workset-audit.json --require-exhausted
- set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p17_batch1.json --run-label 20260413-phase06-ui-p17-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.json --require-decision hold-current-checkpoint-await-sample-curation
- python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.json --report artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation
- python3 - <<'PY' ... refresh artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r12.json from artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r11.json plus docs/manifests/phase06_ui_p17_file_manifest.json and artifacts/ui_pilots/20260413-phase06-ui-p17-pilot-batch1/live_curator/20260413-phase06-ui-p17-batch1-live-curator-r1/batch-report.json

## Results

- docs/manifests/phase06_ui_sample_manifest.json
  - result: ordered_samples=57; the last three sample ids are harmonyos-examples-game2048-entry-shell, harmonyos-examples-pretty-calculator-home-view, and harmonyos-examples-cube-entry-view.
- docs/manifests/phase06_ui_source_corpus_p17.json
  - result: sample_count=3, file_count=13.
- artifacts/test_runs/20260413-phase06-ui-p17-builder-full-suite/summary.json
  - result: py_compile passed, and python3 tests/test_build_phase06_ui_file_manifest.py passed in the same round.
- artifacts/test_runs/20260413-phase06-ui-p17-builder-full-suite/test_build_phase06_ui_file_manifest.log
  - result: Ran 30 tests in 0.374s, OK.
- docs/manifests/phase06_ui_p17_file_manifest.json
  - result: slice_count=13, role_counts={ page: 3, component: 4, viewmodel: 6 }, structure_counts={ page-shell: 3, rich-component: 10 }.
- docs/manifests/phase06_ui_prompt_pilot_p17_batch1.json
  - result: pilot_count=13, source_sample_count=3; all P17 slices were selected into one residual workset.
- artifacts/ui_pilots/20260413-phase06-ui-p17-pilot-batch1/live_curator/20260413-phase06-ui-p17-batch1-mock-curator-r1/batch-report.json
  - result: status=passed, pilot_count=13, passed_count=13; all thirteen promoted P17 slices passed in mock mode.
- artifacts/ui_pilots/20260413-phase06-ui-p17-workset-audit.json
  - result: covered_slice_count=13, missing_slice_count=0, coverage_ratio=1.0, exhausted_workset=true.
- artifacts/ui_pilots/20260413-phase06-ui-p17-pilot-batch1/live_curator/20260413-phase06-ui-p17-batch1-live-curator-r1/batch-report.json
  - result: status=passed, pilot_count=13, passed_count=13; all thirteen promoted P17 slices record final_status=passed and verify_status=passed. phase06-ui-p17-game2048-puzzle-model, phase06-ui-p17-pretty-calculator-entry-page, and phase06-ui-p17-pretty-calculator-theme-model closed in round 2; the remaining ten slices closed in round 1.
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.json
  - result: source_corpus_summary.frozen_sample_count=57, file_manifest_summary.covered_sample_count=57, workset_summary.non_exhausted_workset_count=0, final_decision=hold-current-checkpoint-await-sample-curation.
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.validation.json
  - result: validation_class=valid-expansion-audit, issue_count=0, warning_count=0.
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r12.json
  - result: expected_slice_count=103, passed_slice_count=103, coverage_ratio=1.0, regular_priority_counts={ P0: 12, P1: 9, P2: 3, P3: 3, P4: 3, P5: 2, P6: 3, P7: 3, P8: 3, P9: 3, P10: 3, P11: 3, P12: 4, P13: 6, P14: 9, P15: 8, P16: 13, P17: 13 }.

## Decision

- The formal regular P17 workset is now promoted and closed.
- The regular Phase06 checkpoint advances from P16 / 90/90 live passed to P17 / 103/103 live passed across P0/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11/P12/P13/P14/P15/P16/P17.
- No duplicate P15/P16 live curator, mock curator, aggregate audit, or coverage evidence was introduced during this promotion.
- Any further regular expansion must continue only from the remaining official reserve beyond docs/reports/2026-04-13-phase06-p17-regular-promotion.md, and it must again satisfy the same evidence-first closure before SSOT moves forward.
