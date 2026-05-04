# 2026-04-13 Phase06 P18 Regular Promotion

## Goal

Promote the next official-reserve P18 workset directly from the formal P17 / 103/103 live passed startpoint, without reopening the draft lane, the public cangjiechallenge pool, register-level manual selection, or the exception rail, then close the promoted lane with the full formal chain: freeze -> sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> workset audit -> live curator -> aggregate audit -> coverage -> SSOT.

## Formal Startpoint

- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r16.validation.json
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r12.json

## Inputs

- docs/reports/2026-04-13-phase06-p18-regular-mechanical-readiness.md
- docs/manifests/phase06_ui_sample_manifest.json
- raw_docs/phase06-ui-p18
- docs/manifests/phase06_ui_source_corpus_p18.json
- docs/manifests/phase06_ui_p18_file_manifest.json
- docs/manifests/phase06_ui_prompt_pilot_p18_batch1.json
- artifacts/ui_pilots/20260413-phase06-ui-p18-pilot-batch1/live_curator/20260413-phase06-ui-p18-batch1-mock-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-p18-workset-audit.json
- artifacts/ui_pilots/20260413-phase06-ui-p18-pilot-batch1/live_curator/20260413-phase06-ui-p18-batch1-live-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.validation.json
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r13.json

## Method

1. Carried forward the already repaired and mechanically frozen official-reserve P18 trio from the primary sample register and raw corpus: 04-Calculator, 10-Schedule, and 17-CustomKeyboard.
2. Preserved the formal checkpoint at P17 / 103/103 live passed until the controlled-shell live curator evidence closed.
3. Reused the existing P18 source corpus, file manifest, prompt-pilot manifest, mock curator report, and exhausted workset audit that had already been validated in the same-day mechanical-readiness report.
4. Executed the controlled-shell live curator batch with explicit CANGJIE_HOME / PATH / LD_LIBRARY_PATH / CANGJIE_STDLIB_PATH injection, then sourced .env.local before invoking the live batch.
5. Recomputed the aggregate regular expansion audit, validated it, refreshed live-pass coverage to include all P18 slices, and synced SSOT to the new formal checkpoint.

## Commands

- python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py
- python3 tests/test_build_phase06_ui_file_manifest.py
- python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p18 --manifest-name phase06-ui-source-corpus-p18 --priority P18 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p18.json
- python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p18.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p18_file_manifest.json
- python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p18_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p18_batch1 --artifacts-root artifacts/ui_pilots/20260413-phase06-ui-p18-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p18_batch1.json
- python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p18_batch1.json --run-label 20260413-phase06-ui-p18-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0
- python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p18_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p18_batch1.json --output artifacts/ui_pilots/20260413-phase06-ui-p18-workset-audit.json --require-exhausted
- export CANGJIE_HOME="$PWD/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p18_batch1.json --run-label 20260413-phase06-ui-p18-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.json --require-decision hold-current-checkpoint-await-sample-curation
- python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.json --report artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation
- python3 - <<'PY' ... refresh artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r13.json from artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r12.json plus docs/manifests/phase06_ui_p18_file_manifest.json and artifacts/ui_pilots/20260413-phase06-ui-p18-pilot-batch1/live_curator/20260413-phase06-ui-p18-batch1-live-curator-r1/batch-report.json

## Results

- docs/manifests/phase06_ui_sample_manifest.json
  - result: ordered_samples=60; the last three sample ids are harmonyos-examples-calculator-entry-view, harmonyos-examples-schedule-entry-view, and harmonyos-examples-custom-keyboard-entry-view.
  - interpretation: the primary sample manifest count now matches the formal promoted regular sample count at 60 after the P18 promotion closure.
- docs/manifests/phase06_ui_source_corpus_p18.json
  - result: sample_count=3, file_count=27.
- docs/manifests/phase06_ui_p18_file_manifest.json
  - result: slice_count=27, role_counts={ page: 3, component: 8, viewmodel: 16 }, structure_counts={ page-shell: 3, rich-component: 24 }.
- docs/manifests/phase06_ui_prompt_pilot_p18_batch1.json
  - result: pilot_count=27, source_sample_count=3; all P18 slices were selected into one residual workset.
- artifacts/ui_pilots/20260413-phase06-ui-p18-pilot-batch1/live_curator/20260413-phase06-ui-p18-batch1-mock-curator-r1/batch-report.json
  - result: status=passed, pilot_count=27, passed_count=27.
- artifacts/ui_pilots/20260413-phase06-ui-p18-workset-audit.json
  - result: covered_slice_count=27, missing_slice_count=0, overlap_slice_count=0, unknown_slice_count=0, coverage_ratio=1.0, exhausted_workset=true.
- artifacts/ui_pilots/20260413-phase06-ui-p18-pilot-batch1/live_curator/20260413-phase06-ui-p18-batch1-live-curator-r1/batch-report.json
  - result: status=passed, pilot_count=27, passed_count=27; all twenty-seven promoted P18 slices record final_status=passed and verify_status=passed, and the full workset closed in the initial live batch without any single-slice rerun.
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.json
  - result: source_corpus_summary.frozen_sample_count=60, file_manifest_summary.covered_sample_count=60, workset_summary.non_exhausted_workset_count=0, final_decision=hold-current-checkpoint-await-sample-curation.
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.validation.json
  - result: validation_class=valid-expansion-audit, issue_count=0, warning_count=0.
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r13.json
  - result: expected_slice_count=130, passed_slice_count=130, coverage_ratio=1.0, regular_priority_counts={ P0: 12, P1: 9, P2: 3, P3: 3, P4: 3, P5: 2, P6: 3, P7: 3, P8: 3, P9: 3, P10: 3, P11: 3, P12: 4, P13: 6, P14: 9, P15: 8, P16: 13, P17: 13, P18: 27 }.

## Decision

- The formal regular P18 workset is now promoted and closed.
- The regular Phase06 checkpoint advances from P17 / 103/103 live passed to P18 / 130/130 live passed across P0/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11/P12/P13/P14/P15/P16/P17/P18.
- The prior sample manifest 60 vs formal 57 interpretation gap is now closed at 60/60.
- Any further regular expansion must continue only from the remaining official reserve beyond docs/reports/2026-04-13-phase06-p18-regular-promotion.md, and it must again satisfy the same evidence-first closure before SSOT moves forward.
