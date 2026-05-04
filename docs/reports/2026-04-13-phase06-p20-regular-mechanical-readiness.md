# 2026-04-13 Phase06 P20 Regular Mechanical Readiness

## Goal

Record and reconcile the already-landed P20 official-reserve mechanical chain into explicit report evidence, while keeping the formal checkpoint fixed at `P19 / 181/181 live passed` and closing the full mechanical chain `freeze -> sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> exhausted workset audit`.

## Formal Status Guardrail

- The formal regular checkpoint remains `P19 / 181/181 live passed`.
- The formal promoted regular sample count remains `63`, exactly as recorded by `docs/reports/2026-04-13-phase06-p19-regular-promotion.md`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18.json`, and `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json`.
- `docs/manifests/phase06_ui_sample_manifest.json` now has `ordered_samples=66` because it already carries the frozen-but-not-promoted P20 trio (`KuaiShouUI/SlowFeet`, `08-AdaptiveUI`, `OrderUI`).
- This `66 vs 63` gap is intentional and explicitly mechanical only: `66` means the primary register includes the P20 trio, while `63` remains the formal promoted regular sample count until controlled-shell live curator, aggregate audit, coverage refresh, and promotion report all close.

## Inputs

- `docs/reports/2026-04-13-phase06-p20-regular-candidate-scout.md`
- `artifacts/ui_pilots/20260413-phase06-ui-official-p20-regular-scout.json`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `raw_docs/phase06-ui-p20`
- `docs/manifests/phase06_ui_source_corpus_p20.json`
- `docs/manifests/phase06_ui_p20_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p20_batch1.json`
- `artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-batch1-mock-curator-r1/batch-report.json`
- `artifacts/ui_pilots/20260413-phase06-ui-p20-workset-audit.json`
- `scripts/build_phase06_ui_file_manifest.py`
- `tests/test_build_phase06_ui_file_manifest.py`

## Verification

- `python3 - <<'PY' ...`
  - read-only verification over `docs/manifests/phase06_ui_sample_manifest.json`, `docs/manifests/phase06_ui_source_corpus_p20.json`, `docs/manifests/phase06_ui_p20_file_manifest.json`, `docs/manifests/phase06_ui_prompt_pilot_p20_batch1.json`, `artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-batch1-mock-curator-r1/batch-report.json`, and `artifacts/ui_pilots/20260413-phase06-ui-p20-workset-audit.json`
  - result: `ordered_sample_count=66`, appended `P20` sample ids present, `sample_count=3`, `file_count=39`, `slice_count=39`, `pilot_count=39`, `mock status=passed`, `passed_count=39`, `coverage_ratio=1.0`, `exhausted_workset=true`, and no non-mock `live_curator` directory exists yet under `artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/`
- `rg -n "P20|phase06-ui-p20|harmonyos-examples-kuaishou-ui-slowfeet-entry-view|harmonyos-examples-adaptive-ui-entry-view|harmonyos-examples-order-ui-entry-view" tests/test_build_phase06_ui_file_manifest.py scripts/build_phase06_ui_file_manifest.py`
  - result: confirmed the P20 file-slice overrides already exist in `scripts/build_phase06_ui_file_manifest.py` and the P20 mechanical regression block already exists in `tests/test_build_phase06_ui_file_manifest.py`.

## Results

- `raw_docs/phase06-ui-p20`
  - result: freezes `39` repo-local files across the three official-reserve samples, matching the scout-selected closure exactly (`6 + 8 + 25`).
- `docs/manifests/phase06_ui_sample_manifest.json`
  - result: `ordered_samples=66`; the appended P20 sample ids are `harmonyos-examples-kuaishou-ui-slowfeet-entry-view`, `harmonyos-examples-adaptive-ui-entry-view`, and `harmonyos-examples-order-ui-entry-view`.
  - interpretation: this advances the primary register only; it does not refresh the formal promoted sample count beyond `63`.
- `docs/manifests/phase06_ui_source_corpus_p20.json`
  - result: `sample_count=3`, `file_count=39`, `manifest_name=phase06-ui-source-corpus-p20`.
- `docs/manifests/phase06_ui_p20_file_manifest.json`
  - result: `slice_count=39`, `role_counts={'page': 6, 'viewmodel': 19, 'component': 14}`.
- `docs/manifests/phase06_ui_prompt_pilot_p20_batch1.json`
  - result: `pilot_count=39`, `source_sample_count=3`, `excluded_slice_count=0`.
- `artifacts/ui_pilots/20260413-phase06-ui-p20-pilot-batch1/live_curator/20260413-phase06-ui-p20-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=39`, `passed_count=39`.
- `artifacts/ui_pilots/20260413-phase06-ui-p20-workset-audit.json`
  - result: `covered_slice_count=39`, `missing_slice_count=0`, `overlap_slice_count=0`, `unknown_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- `scripts/build_phase06_ui_file_manifest.py`
  - result: already contains the P20 `FILE_SLICE_OVERRIDES` block for the SlowFeet, AdaptiveUI, and OrderUI freeze set.
- `tests/test_build_phase06_ui_file_manifest.py`
  - result: already contains the P20 regular mechanical-readiness assertions covering representative P20 page, component, and helper slices.

## Decision

- The P20 trio is mechanically ready.
- The next allowed move is the controlled-shell live curator run on `docs/manifests/phase06_ui_prompt_pilot_p20_batch1.json` with explicit `CANGJIE_HOME / PATH / LD_LIBRARY_PATH / CANGJIE_STDLIB_PATH` injection plus `.env.local` sourcing.
- Before that live run closes `39/39`, do not refresh `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r18*.json`, `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r14.json`, or the formal SSOT checkpoint.
