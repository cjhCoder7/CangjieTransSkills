# 2026-04-14 Phase06 P21 Regular Promotion

## Goal

Promote the already frozen P21 official-reserve workset from the formal P20 / 220/220 live passed checkpoint to the next formal regular checkpoint, without reopening the draft lane, the public cangjiechallenge pool, register-level manual selection, or the exception rail, then close the promoted lane with the full formal chain: freeze -> sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> live curator -> aggregate audit -> coverage -> SSOT.

## Formal Startpoint

- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json
- artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json
- artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json

## Inputs

- docs/reports/2026-04-13-phase06-p21-regular-mechanical-readiness.md
- docs/reports/2026-04-13-phase06-p21-live-curator-r1-failure-attribution.md
- docs/reports/2026-04-14-phase06-p21-live-curator-r2-failure-attribution.md
- docs/reports/2026-04-13-phase06-p21-user-model-arraylist-guardrail-repair.md
- docs/reports/2026-04-14-phase06-p21-chart-data-service-model-initial-baseline-repair.md
- docs/reports/2026-04-14-phase06-p21-style-extensions-helper-initial-baseline-repair.md
- docs/manifests/phase06_ui_sample_manifest.json
- raw_docs/phase06-ui-p21
- docs/manifests/phase06_ui_source_corpus_p21.json
- docs/manifests/phase06_ui_p21_file_manifest.json
- docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json
- artifacts/ui_pilots/20260413-phase06-ui-p21-workset-audit.json
- artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-mock-curator-r1/batch-report.json
- artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260414-phase06-ui-p21-batch1-live-curator-r3/batch-report.json
- artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r20.json
- artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r20.validation.json
- artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r16.json

## Method

1. Carried forward the already repaired and mechanically frozen P21 trio from the primary sample register and raw corpus: 02-UILayout, 16-StockChart, and WaterFall.
2. Preserved the formal checkpoint at P20 / 220/220 live passed until all fifty-six P21 slices held fresh non-mock live curator evidence.
3. Executed the controlled-shell full-batch live curator with explicit CANGJIE_HOME / PATH / LD_LIBRARY_PATH / CANGJIE_STDLIB_PATH injection, then sourced `.env.local` before invoking the live batch.
4. Closed the fresh full P21 live `r3` in one pass with no targeted rerun: all fifty-six slices finished with `final_status=passed`, `verify_status=passed`, and `round_count=1`.
5. Recomputed the aggregate regular expansion audit, validated it, refreshed live-pass coverage to include all P21 slices, and synced SSOT to the new formal checkpoint.

## Commands

- export REPO_ROOT="/volume/wzhang/cky-workspace/my_projects/Cangjie" && export CANGJIE_HOME="$REPO_ROOT/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source "$REPO_ROOT/.env.local" >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json --run-label 20260414-phase06-ui-p21-batch1-live-curator-r3 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0
- python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r20.json --require-decision hold-current-checkpoint-await-sample-curation
- python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r20.json --report artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r20.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation
- python3 - <<'PY' ... refresh artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r16.json from artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json plus docs/manifests/phase06_ui_p21_file_manifest.json and artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260414-phase06-ui-p21-batch1-live-curator-r3/batch-report.json

## Results

- docs/manifests/phase06_ui_sample_manifest.json
  - result: `ordered_samples=69`.
  - interpretation: the primary sample manifest now aligns with the formal promoted regular sample count at `69/69`.
- docs/manifests/phase06_ui_source_corpus_p21.json
  - result: `sample_count=3`, `file_count=56`.
- docs/manifests/phase06_ui_p21_file_manifest.json
  - result: `sample_count=3`, `slice_count=56`, `role_counts={ page: 7, component: 25, viewmodel: 24 }`, `structure_counts={ page-shell: 7, rich-component: 49 }`.
- docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json
  - result: `pilot_count=56`, `source_sample_count=3`; all P21 slices were selected into one residual workset.
- artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-mock-curator-r1/batch-report.json
  - result: `status=passed`, `pilot_count=56`, `passed_count=56`.
- artifacts/ui_pilots/20260413-phase06-ui-p21-workset-audit.json
  - result: `covered_slice_count=56`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260414-phase06-ui-p21-batch1-live-curator-r3/batch-report.json
  - result: `status=passed`, `pilot_count=56`, `passed_count=56`; all entries closed with `verify_status=passed` and `round_count=1`.
- artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r20.json
  - result: `sample_manifest.regular_sample_count=69`, `source_corpus_summary.frozen_sample_count=69`, `file_manifest_summary.covered_sample_count=69`, `workset_summary.non_exhausted_workset_count=0`, `final_decision=hold-current-checkpoint-await-sample-curation`.
- artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r20.validation.json
  - result: `validation_class=valid-expansion-audit`, `issue_count=0`, `warning_count=0`.
- artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r16.json
  - result: `expected_slice_count=276`, `passed_slice_count=276`, `coverage_ratio=1.0`, `regular_priority_counts={ P0: 12, P1: 9, P2: 3, P3: 3, P4: 3, P5: 2, P6: 3, P7: 3, P8: 3, P9: 3, P10: 3, P11: 3, P12: 4, P13: 6, P14: 9, P15: 8, P16: 13, P17: 13, P18: 27, P19: 51, P20: 39, P21: 56 }`.

## Decision

- The formal regular P21 workset is now promoted and closed.
- The regular Phase06 checkpoint advances from `P20 / 220/220 live passed` to `P21 / 276/276 live passed` across P0/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11/P12/P13/P14/P15/P16/P17/P18/P19/P20/P21.
- The prior primary sample manifest `69` vs formal promoted regular sample count `66` gap is now closed at `69/69`.
- The earlier P21 `r1` / `r2` lanes and the three targeted blocker-repair runs remain valid precursor evidence, but the canonical promotion closure is now the fresh full-batch `r3` plus aggregate audit / validation / coverage refresh.
- Any further regular expansion must continue only from the remaining official reserve beyond docs/reports/2026-04-14-phase06-p21-regular-promotion.md, and it must again satisfy the same evidence-first closure before SSOT moves forward.
