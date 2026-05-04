# 2026-04-13 Phase06 P20 Regular Promotion

## Goal

Promote the already frozen P20 official-reserve workset from the formal P19 / 181/181 live passed checkpoint to the next formal regular checkpoint, without reopening the draft lane, the public cangjiechallenge pool, register-level manual selection, or the exception rail, then close the promoted lane with the full formal chain: freeze -> sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> workset audit -> live curator -> aggregate audit -> coverage -> SSOT.

## Formal Startpoint

- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.validation.json
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json

## Inputs

- docs/reports/2026-04-13-phase06-p20-regular-mechanical-readiness.md
- docs/manifests/phase06_ui_sample_manifest.json
- raw_docs/phase06-ui-p20
- docs/manifests/phase06_ui_source_corpus_p20.json
- docs/manifests/phase06_ui_p20_file_manifest.json
- docs/manifests/phase06_ui_prompt_pilot_p20_batch1.json
- artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-batch1-mock-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-p20-workset-audit.json
- artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-batch1-live-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-order-ui-main-ability-live-curator-r2/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json

## Method

1. Carried forward the already repaired and mechanically frozen official-reserve P20 trio from the primary sample register and raw corpus: KuaiShouUI/SlowFeet, 08-AdaptiveUI, and OrderUI.
2. Preserved the formal checkpoint at P19 / 181/181 live passed until all thirty-nine P20 slices held non-mock live curator evidence.
3. Executed the controlled-shell live curator batch with explicit CANGJIE_HOME / PATH / LD_LIBRARY_PATH / CANGJIE_STDLIB_PATH injection, then sourced .env.local before invoking the live batch.
4. Classified the lone initial miss `phase06-ui-p20-order-ui-main-ability-model` as infrastructure-only translator noise because the first-round run stopped at `Hard wall-clock timeout exceeded after 600.0s` before review or verify, then recovered it via a one-slice targeted rerun.
5. Recomputed the aggregate regular expansion audit, validated it, refreshed live-pass coverage to include all P20 slices, and synced SSOT to the new formal checkpoint.

## Commands

- export CANGJIE_HOME="$PWD/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p20_batch1.json --run-label 20260413-phase06-ui-p20-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- export CANGJIE_HOME="$PWD/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p20_batch1.json --run-label 20260413-phase06-ui-p20-order-ui-main-ability-live-curator-r2 --slice-id phase06-ui-p20-order-ui-main-ability-model --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json --require-decision hold-current-checkpoint-await-sample-curation
- python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json --report artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation
- python3 - <<'PY' ... refresh artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json from artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json plus docs/manifests/phase06_ui_p20_file_manifest.json and the two P20 live batch reports

## Results

- docs/manifests/phase06_ui_sample_manifest.json
  - result: ordered_samples=66; the last three sample ids are harmonyos-examples-kuaishou-ui-slowfeet-entry-view, harmonyos-examples-adaptive-ui-entry-view, and harmonyos-examples-order-ui-entry-view.
  - interpretation: the primary sample manifest count now matches the formal promoted regular sample count at 66 after the P20 promotion closure.
- docs/manifests/phase06_ui_source_corpus_p20.json
  - result: sample_count=3, file_count=39.
- docs/manifests/phase06_ui_p20_file_manifest.json
  - result: slice_count=39, role_counts={ page: 6, component: 14, viewmodel: 19 }, structure_counts={ page-shell: 6, rich-component: 33 }.
- docs/manifests/phase06_ui_prompt_pilot_p20_batch1.json
  - result: pilot_count=39, source_sample_count=3; all P20 slices were selected into one residual workset.
- artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-batch1-mock-curator-r1/batch-report.json
  - result: status=passed, pilot_count=39, passed_count=39.
- artifacts/ui_pilots/20260413-phase06-ui-p20-workset-audit.json
  - result: covered_slice_count=39, missing_slice_count=0, overlap_slice_count=0, unknown_slice_count=0, coverage_ratio=1.0, exhausted_workset=true.
- artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-batch1-live-curator-r1/batch-report.json
  - result: status=partial, pilot_count=39, passed_count=38; the only miss was phase06-ui-p20-order-ui-main-ability-model, classified as infrastructure-error with verify_status=skipped.
- artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-order-ui-main-ability-live-curator-r2/batch-report.json
  - result: status=passed, pilot_count=1, passed_count=1; the one infrastructure-only miss closed in round 1 of the targeted rerun batch.
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json
  - result: source_corpus_summary.frozen_sample_count=66, file_manifest_summary.covered_sample_count=66, workset_summary.non_exhausted_workset_count=0, final_decision=hold-current-checkpoint-await-sample-curation.
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json
  - result: validation_class=valid-expansion-audit, issue_count=0, warning_count=0.
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json
  - result: expected_slice_count=220, passed_slice_count=220, coverage_ratio=1.0, regular_priority_counts={ P0: 12, P1: 9, P2: 3, P3: 3, P4: 3, P5: 2, P6: 3, P7: 3, P8: 3, P9: 3, P10: 3, P11: 3, P12: 4, P13: 6, P14: 9, P15: 8, P16: 13, P17: 13, P18: 27, P19: 51, P20: 39 }.

## Decision

- The formal regular P20 workset is now promoted and closed.
- The regular Phase06 checkpoint advances from P19 / 181/181 live passed to P20 / 220/220 live passed across P0/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11/P12/P13/P14/P15/P16/P17/P18/P19/P20.
- The prior primary sample manifest 66 vs formal promoted 63 gap is now closed at 66/66.
- No new draft-lane, manual-selection, or exception-rail evidence was introduced during this promotion; the only rerun was the minimal one-slice infrastructure recovery batch.
- Any further regular expansion must continue only from the remaining official reserve beyond docs/reports/2026-04-13-phase06-p20-regular-promotion.md, and it must again satisfy the same evidence-first closure before SSOT moves forward.
