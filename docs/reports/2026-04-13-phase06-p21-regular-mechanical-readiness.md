# 2026-04-13 Phase06 P21 Regular Mechanical Readiness

## Goal

Record the newly closed P21 official-reserve scout plus mechanical-freeze chain into explicit readiness evidence, while keeping the formal checkpoint fixed at `P20 / 220/220 live passed` and closing the full mechanical chain `scout -> freeze -> sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> exhausted workset audit`.

## Formal Status Guardrail

- The formal regular checkpoint remains `P20 / 220/220 live passed`.
- The formal promoted regular sample count remains `66`, exactly as recorded by `docs/reports/2026-04-13-phase06-p20-regular-promotion.md`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json`, and `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json`.
- `docs/manifests/phase06_ui_sample_manifest.json` now has `ordered_samples=69` because it already carries the frozen-but-not-promoted P21 trio (`harmonyos-examples-ui-layout-entry-view`, `harmonyos-examples-stock-chart-entry-view`, and `harmonyos-examples-waterfall-entry-view`).
- This `69 vs 66` gap is intentional and explicitly mechanical only: `69` means the primary register includes the P21 trio, while `66` remains the formal promoted regular sample count until controlled-shell live curator, aggregate audit, coverage refresh, and promotion report all close.

## Inputs

- `docs/reports/2026-04-13-phase06-p21-regular-candidate-scout.md`
- `artifacts/ui_pilots/20260413-phase06-ui-official-p21-regular-scout.json`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `raw_docs/phase06-ui-p21`
- `docs/manifests/phase06_ui_source_corpus_p21.json`
- `docs/manifests/phase06_ui_p21_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-mock-curator-r1/batch-report.json`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-workset-audit.json`
- `scripts/build_phase06_ui_file_manifest.py`
- `tests/test_build_phase06_ui_file_manifest.py`

## Verification

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: passed.
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `Ran 33 tests` and `OK (skipped=1)`.
- `find raw_docs/phase06-ui-p21 -type f | sort | wc -l`
  - result: `56`.
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p21 --manifest-name phase06-ui-source-corpus-p21 --priority P21 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p21.json`
  - result: passed; `docs/manifests/phase06_ui_source_corpus_p21.json` records `sample_count=3` and `file_count=56`.
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p21.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p21_file_manifest.json`
  - result: passed; `docs/manifests/phase06_ui_p21_file_manifest.json` records `slice_count=56`.
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p21_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p21_batch1 --artifacts-root artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json`
  - result: passed; `docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json` records `pilot_count=56`.
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json --run-label 20260413-phase06-ui-p21-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
  - result: passed; `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-mock-curator-r1/batch-report.json` records `status=passed`, `pilot_count=56`, and `passed_count=56`.
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p21_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json --output artifacts/ui_pilots/20260413-phase06-ui-p21-workset-audit.json --require-exhausted`
  - result: passed; `artifacts/ui_pilots/20260413-phase06-ui-p21-workset-audit.json` records `coverage_ratio=1.0` and `exhausted_workset=true`.
- `find artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator -maxdepth 1 -mindepth 1 -type d | sort`
  - result: only `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-mock-curator-r1` exists, so no non-mock P21 live curator has started yet.

## Results

- `artifacts/ui_pilots/20260413-phase06-ui-official-p21-regular-scout.json`
  - result: `decision=prepare-p21-regular-freeze`; the selected trio is `harmonyos-examples-ui-layout-entry-view`, `harmonyos-examples-stock-chart-entry-view`, and `harmonyos-examples-waterfall-entry-view`, with `freeze_file_count=28 + 21 + 7 = 56`.
- `raw_docs/phase06-ui-p21`
  - result: freezes `56` repo-local files across the three official-reserve samples, matching the scout-selected closure exactly.
- `docs/manifests/phase06_ui_sample_manifest.json`
  - result: `ordered_samples=69`; the appended P21 sample ids are `harmonyos-examples-ui-layout-entry-view`, `harmonyos-examples-stock-chart-entry-view`, and `harmonyos-examples-waterfall-entry-view`.
  - interpretation: this advances the primary register only; it does not refresh the formal promoted sample count beyond `66`.
- `docs/manifests/phase06_ui_source_corpus_p21.json`
  - result: `sample_count=3`, `file_count=56`, `manifest_name=phase06-ui-source-corpus-p21`.
- `docs/manifests/phase06_ui_p21_file_manifest.json`
  - result: `slice_count=56`, `role_counts={'page': 7, 'component': 25, 'viewmodel': 24}`, `structure_counts={'page-shell': 7, 'rich-component': 49}`.
- `docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json`
  - result: `pilot_count=56`, `source_sample_count=3`, `excluded_slice_count=0`.
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=56`, `passed_count=56`.
- `artifacts/ui_pilots/20260413-phase06-ui-p21-workset-audit.json`
  - result: `covered_slice_count=56`, `missing_slice_count=0`, `overlap_slice_count=0`, `unknown_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- `scripts/build_phase06_ui_file_manifest.py`
  - result: already contains the P21 `FILE_SLICE_OVERRIDES` block for the scout-selected `02-UILayout`, `16-StockChart`, and `WaterFall` freeze set.
- `tests/test_build_phase06_ui_file_manifest.py`
  - result: already contains the P21 regular mechanical-readiness assertions covering representative P21 page, component, and helper/viewmodel slices.

## Decision

- The P21 trio is mechanically ready.
- The next allowed move is the controlled-shell live curator run on `docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json` with explicit `CANGJIE_HOME / PATH / LD_LIBRARY_PATH / CANGJIE_STDLIB_PATH` injection plus `.env.local` sourcing.
- Before that live run closes `56/56`, do not refresh `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19*.json`, `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json`, or the formal SSOT checkpoint.
