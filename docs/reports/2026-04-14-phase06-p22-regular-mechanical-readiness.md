# 2026-04-14 Phase06 P22 Regular Mechanical Readiness

## Goal

Record the newly closed P22 official-reserve scout plus mechanical-freeze chain into explicit readiness evidence, while keeping the formal checkpoint fixed at `P21 / 276/276 live passed` and closing the full mechanical chain `scout -> freeze -> sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> exhausted workset audit`.

## Formal Status Guardrail

- The formal regular checkpoint remains `P21 / 276/276 live passed`.
- The formal promoted regular sample count remains `69`, exactly as recorded by `docs/reports/2026-04-14-phase06-p21-regular-promotion.md`, `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r20.json`, and `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r16.json`.
- `docs/manifests/phase06_ui_sample_manifest.json` now has `ordered_samples=72` because it already carries the frozen-but-not-promoted P22 trio.
- This `72 vs 69` gap is intentional and explicitly mechanical only: `72` means the primary register includes the P22 trio, while `69` remains the formal promoted regular sample count until controlled-shell live curator, aggregate audit, coverage refresh, and promotion report all close.

## Inputs

- `docs/reports/2026-04-14-phase06-p22-regular-candidate-scout.md`
- `artifacts/ui_pilots/20260414-phase06-ui-official-p22-regular-scout.json`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `raw_docs/phase06-ui-p22`
- `docs/manifests/phase06_ui_source_corpus_p22.json`
- `docs/manifests/phase06_ui_p22_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json`
- `artifacts/ui_pilots/20260414-phase06-ui-p22-pilot-batch1/live_curator/20260414-phase06-ui-p22-batch1-mock-curator-r1/batch-report.json`
- `artifacts/ui_pilots/20260414-phase06-ui-p22-workset-audit.json`
- `scripts/build_phase06_ui_file_manifest.py`
- `tests/test_build_phase06_ui_file_manifest.py`

## Verification

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: passed.
- `find raw_docs/phase06-ui-p22 -type f | sort | wc -l`
  - result: `35`.
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p22 --manifest-name phase06-ui-source-corpus-p22 --priority P22 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p22.json`
  - result: passed; `docs/manifests/phase06_ui_source_corpus_p22.json` records `sample_count=3` and `file_count=35`.
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `Ran 34 tests` and `OK`.
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p22.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p22_file_manifest.json`
  - result: passed; `docs/manifests/phase06_ui_p22_file_manifest.json` records `slice_count=35`, `role_counts={'page': 3, 'component': 23, 'viewmodel': 9}`, and `structure_counts={'page-shell': 3, 'rich-component': 32}`.
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p22_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p22_batch1 --artifacts-root artifacts/ui_pilots/20260414-phase06-ui-p22-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json`
  - result: passed; `docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json` records `pilot_count=35`, `source_sample_count=3`, and `excluded_slice_count=0`.
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json --run-label 20260414-phase06-ui-p22-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
  - result: passed; `artifacts/ui_pilots/20260414-phase06-ui-p22-pilot-batch1/live_curator/20260414-phase06-ui-p22-batch1-mock-curator-r1/batch-report.json` records `status=passed`, `pilot_count=35`, and `passed_count=35`.
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p22_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json --output artifacts/ui_pilots/20260414-phase06-ui-p22-workset-audit.json --require-exhausted`
  - result: passed; `artifacts/ui_pilots/20260414-phase06-ui-p22-workset-audit.json` records `coverage_ratio=1.0` and `exhausted_workset=true`.

## Results

- `artifacts/ui_pilots/20260414-phase06-ui-official-p22-regular-scout.json`
  - result: `decision=prepare-p22-regular-freeze`; the selected trio is `harmonyos-examples-ui-component-gallery-entry-view`, `harmonyos-examples-ui-component-text-playground-page`, and `harmonyos-examples-roulette-ui-public-page-workflow`, with `freeze_file_count=12 + 17 + 6 = 35`.
  - note: sample-level scout tag semantics now stay aligned across the report and raw scout artifact; `harmonyos-examples-ui-component-gallery-entry-view` is summarized as `page-shell + view-model-renderer + deveco-import+manual-ui-smoke`, while the later `phase06-ui-p22-ui-component-music-player-card-component` slice remains a narrower downstream `controller-owned-state` exception rather than changing the sample-level candidate tag.
- `raw_docs/phase06-ui-p22`
  - result: freezes `35` repo-local files across the three official-reserve samples, matching the scout-selected closure exactly.
- `docs/manifests/phase06_ui_sample_manifest.json`
  - result: `ordered_samples=72`; the appended P22 sample ids are `harmonyos-examples-ui-component-gallery-entry-view`, `harmonyos-examples-ui-component-text-playground-page`, and `harmonyos-examples-roulette-ui-public-page-workflow`.
  - interpretation: this advances the primary register only; it does not refresh the formal promoted sample count beyond `69`.
- `docs/manifests/phase06_ui_source_corpus_p22.json`
  - result: `sample_count=3`, `file_count=35`, `manifest_name=phase06-ui-source-corpus-p22`.
- `docs/manifests/phase06_ui_p22_file_manifest.json`
  - result: `slice_count=35`, `role_counts={'page': 3, 'component': 23, 'viewmodel': 9}`, `structure_counts={'page-shell': 3, 'rich-component': 32}`.
- `docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json`
  - result: `pilot_count=35`, `source_sample_count=3`, `excluded_slice_count=0`.
- `artifacts/ui_pilots/20260414-phase06-ui-p22-pilot-batch1/live_curator/20260414-phase06-ui-p22-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=35`, `passed_count=35`.
- `artifacts/ui_pilots/20260414-phase06-ui-p22-workset-audit.json`
  - result: `covered_slice_count=35`, `missing_slice_count=0`, `overlap_slice_count=0`, `unknown_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.

## Decision

- The P22 trio is mechanically ready.
- This is not a promotion and not a live-closure claim; it is repo-local mechanical-freeze evidence only.
- The next allowed move is not an automatic live curator launch. Any future P22 live step must be an explicit later decision and, if approved, must run as a fresh full P22 live curator with explicit `CANGJIE_HOME / PATH / LD_LIBRARY_PATH / CANGJIE_STDLIB_PATH` injection while the formal SSOT stays at `P21 / 276/276 live passed` until that later closure exists.
