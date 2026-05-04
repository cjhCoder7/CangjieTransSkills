# 2026-04-13 Phase06 P19 Regular Promotion

## Goal

Promote the next official-reserve P19 workset directly from the formal P18 / 130/130 live passed startpoint, without reopening the draft lane, the public cangjiechallenge pool, register-level manual selection, or the exception rail, then close the promoted lane with the full formal chain: freeze -> sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> workset audit -> live curator -> aggregate audit -> coverage -> SSOT.

## Formal Startpoint

- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.validation.json
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r13.json

## Inputs

- docs/reports/2026-04-13-phase06-p19-regular-mechanical-readiness.md
- docs/manifests/phase06_ui_sample_manifest.json
- raw_docs/phase06-ui-p19
- docs/manifests/phase06_ui_source_corpus_p19.json
- docs/manifests/phase06_ui_p19_file_manifest.json
- docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json
- artifacts/ui_pilots/20260413-phase06-ui-p19-pilot-batch1/live_curator/20260413-phase06-ui-p19-batch1-mock-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-p19-workset-audit.json
- artifacts/ui_pilots/20260413-phase06-ui-p19-pilot-batch1/live_curator/20260413-phase06-ui-p19-batch1-live-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-p19-pilot-batch1/live_curator/20260413-phase06-ui-p19-infra-trio-live-curator-r2/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.validation.json
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json

## Method

1. Carried forward the already repaired and mechanically frozen official-reserve P19 trio from the primary sample register and raw corpus: 09-SlideUI, 13-SeatSelection, and 05-ChatUI.
2. Preserved the formal checkpoint at P18 / 130/130 live passed until all fifty-one P19 slices held live curator evidence.
3. Executed the controlled-shell live curator batch with explicit CANGJIE_HOME / PATH / LD_LIBRARY_PATH / CANGJIE_STDLIB_PATH injection, then sourced .env.local before invoking the live batch.
4. Classified the three initial misses as infrastructure-only translator noise and recovered them via a minimal targeted rerun over the failed slice set only.
5. Recomputed the aggregate regular expansion audit, validated it, refreshed live-pass coverage to include all P19 slices, and synced SSOT to the new formal checkpoint.

## Commands

- export CANGJIE_HOME="$PWD/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json --run-label 20260413-phase06-ui-p19-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- export CANGJIE_HOME="$PWD/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json --run-label 20260413-phase06-ui-p19-infra-trio-live-curator-r2 --slice-id phase06-ui-p19-seat-selection-area-info-model --slice-id phase06-ui-p19-seat-selection-view-model --slice-id phase06-ui-p19-chat-ui-chat-model --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json --require-decision hold-current-checkpoint-await-sample-curation
- python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json --report artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation
- python3 - <<'PY' ... refresh artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json from artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r13.json plus docs/manifests/phase06_ui_p19_file_manifest.json and the two P19 live batch reports

## Results

- docs/manifests/phase06_ui_sample_manifest.json
  - result: ordered_samples=63; the last three sample ids are harmonyos-examples-slide-ui-entry-view, harmonyos-examples-seat-selection-entry-view, and harmonyos-examples-chat-ui-index-view.
  - interpretation: the primary sample manifest count now matches the formal promoted regular sample count at 63 after the P19 promotion closure.
- docs/manifests/phase06_ui_source_corpus_p19.json
  - result: sample_count=3, file_count=51.
- docs/manifests/phase06_ui_p19_file_manifest.json
  - result: slice_count=51, role_counts={ page: 4, component: 28, viewmodel: 19 }, structure_counts={ page-shell: 4, rich-component: 47 }.
- docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json
  - result: pilot_count=51, source_sample_count=3; all P19 slices were selected into one residual workset.
- artifacts/ui_pilots/20260413-phase06-ui-p19-pilot-batch1/live_curator/20260413-phase06-ui-p19-batch1-mock-curator-r1/batch-report.json
  - result: status=passed, pilot_count=51, passed_count=51.
- artifacts/ui_pilots/20260413-phase06-ui-p19-workset-audit.json
  - result: covered_slice_count=51, missing_slice_count=0, overlap_slice_count=0, unknown_slice_count=0, coverage_ratio=1.0, exhausted_workset=true.
- artifacts/ui_pilots/20260413-phase06-ui-p19-pilot-batch1/live_curator/20260413-phase06-ui-p19-batch1-live-curator-r1/batch-report.json
  - result: status=partial, pilot_count=51, passed_count=48; the only misses were phase06-ui-p19-seat-selection-area-info-model, phase06-ui-p19-seat-selection-view-model, and phase06-ui-p19-chat-ui-chat-model, each classified as infrastructure-error with verify_status=skipped.
- artifacts/ui_pilots/20260413-phase06-ui-p19-pilot-batch1/live_curator/20260413-phase06-ui-p19-infra-trio-live-curator-r2/batch-report.json
  - result: status=passed, pilot_count=3, passed_count=3; all three infrastructure-only misses closed in round 1 of the targeted rerun batch.
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json
  - result: source_corpus_summary.frozen_sample_count=63, file_manifest_summary.covered_sample_count=63, workset_summary.non_exhausted_workset_count=0, final_decision=hold-current-checkpoint-await-sample-curation.
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.validation.json
  - result: validation_class=valid-expansion-audit, issue_count=0, warning_count=0.
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json
  - result: expected_slice_count=181, passed_slice_count=181, coverage_ratio=1.0, regular_priority_counts={ P0: 12, P1: 9, P2: 3, P3: 3, P4: 3, P5: 2, P6: 3, P7: 3, P8: 3, P9: 3, P10: 3, P11: 3, P12: 4, P13: 6, P14: 9, P15: 8, P16: 13, P17: 13, P18: 27, P19: 51 }.

## Decision

- The formal regular P19 workset is now promoted and closed.
- The regular Phase06 checkpoint advances from P18 / 130/130 live passed to P19 / 181/181 live passed across P0/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11/P12/P13/P14/P15/P16/P17/P18/P19.
- The prior sample manifest 63 vs formal promoted 60 interpretation gap is now closed at 63/63.
- No new draft-lane, manual-selection, or exception-rail evidence was introduced during this promotion; the only rerun was the minimal three-slice infrastructure recovery batch.
- Any further regular expansion must continue only from the remaining official reserve beyond docs/reports/2026-04-13-phase06-p19-regular-promotion.md, and it must again satisfy the same evidence-first closure before SSOT moves forward.
