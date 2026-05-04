# 2026-04-13 Phase06 P19 Regular Mechanical Readiness

## Goal

Freeze the next official-reserve P19 regular workset into the primary Phase06 sample register and close the full mechanical chain `freeze -> sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> exhausted workset audit`, without refreshing the formal checkpoint, aggregate audit, live-pass coverage, or promotion state.

## Formal Status Guardrail

- The formal regular checkpoint remains `P18 / 130/130 live passed`.
- The formal promoted regular sample count remains `60`, exactly as recorded by `docs/reports/2026-04-13-phase06-p18-regular-promotion.md`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17.json`, and `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r13.json`.
- `docs/manifests/phase06_ui_sample_manifest.json` now has `ordered_samples=63` because it already carries the frozen-but-not-promoted P19 trio (`09-SlideUI`, `13-SeatSelection`, `05-ChatUI`).
- This `63 vs 60` gap is intentional and explicitly mechanical only: `63` means the primary register includes the P19 trio, while `60` remains the formal promoted regular sample count until controlled-shell live curator, aggregate audit, coverage refresh, and promotion report all close.

## Inputs

- `docs/reports/2026-04-13-phase06-p19-regular-candidate-scout.md`
- `artifacts/ui_pilots/20260413-phase06-ui-official-p19-regular-scout.json`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `raw_docs/phase06-ui-p19`
- `scripts/build_phase06_ui_file_manifest.py`
- `tests/test_build_phase06_ui_file_manifest.py`

## Commands

- `python - <<'PY' ... re-freeze the scout-selected P19 source_paths from /tmp/phase06-source-scout/HarmonyOS-Examples into raw_docs/phase06-ui-p19/HarmonyOS-Examples/... and append the three P19 entries into docs/manifests/phase06_ui_sample_manifest.json`
- `python - <<'PY' ... inject the 51 P19 FILE_SLICE_OVERRIDES entries into scripts/build_phase06_ui_file_manifest.py and add unittest coverage in tests/test_build_phase06_ui_file_manifest.py`
- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p19 --manifest-name phase06-ui-source-corpus-p19 --priority P19 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p19.json`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p19.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p19_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p19_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p19_batch1 --artifacts-root artifacts/ui_pilots/20260413-phase06-ui-p19-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json --run-label 20260413-phase06-ui-p19-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p19_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json --output artifacts/ui_pilots/20260413-phase06-ui-p19-workset-audit.json --require-exhausted`

## Results

- `raw_docs/phase06-ui-p19`
  - result: froze `51` repo-local files across the three official-reserve samples, matching the scout closure exactly (`13 + 17 + 21`).
- `docs/manifests/phase06_ui_sample_manifest.json`
  - result: `ordered_samples=63`; the appended P19 sample ids are `harmonyos-examples-slide-ui-entry-view`, `harmonyos-examples-seat-selection-entry-view`, and `harmonyos-examples-chat-ui-index-view`.
  - interpretation: this advances the primary register only; it does not refresh the formal promoted sample count beyond `60`.
- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: passed.
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `Ran 31 tests in 0.290s`, `OK`.
- `docs/manifests/phase06_ui_source_corpus_p19.json`
  - result: `sample_count=3`, `file_count=51`, `manifest_name=phase06-ui-source-corpus-p19`.
- `docs/manifests/phase06_ui_p19_file_manifest.json`
  - result: `slice_count=51`, `role_counts={'page': 4, 'viewmodel': 19, 'component': 28}`, `structure_counts={'page-shell': 4, 'rich-component': 47}`.
- `docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json`
  - result: `pilot_count=51`, `source_sample_count=3`, `excluded_slice_count=0`.
- `artifacts/ui_pilots/20260413-phase06-ui-p19-pilot-batch1/live_curator/20260413-phase06-ui-p19-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=51`, `passed_count=51`.
- `artifacts/ui_pilots/20260413-phase06-ui-p19-workset-audit.json`
  - result: `covered_slice_count=51`, `missing_slice_count=0`, `overlap_slice_count=0`, `unknown_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.

## Decision

- The P19 trio is mechanically ready.
- The next allowed move is the controlled-shell live curator run on `docs/manifests/phase06_ui_prompt_pilot_p19_batch1.json` with explicit `CANGJIE_HOME / PATH / LD_LIBRARY_PATH / CANGJIE_STDLIB_PATH` injection.
- Before that live run closes `51/51`, do not refresh `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r17*.json`, `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r13.json`, or the formal SSOT checkpoint.
