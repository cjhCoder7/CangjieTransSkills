# 2026-04-11 Phase06 P6 Regular Promotion

## Goal

Promote the mechanically ready `p6-draft` lane into the primary regular Phase06 source supply, then rerun the formal chain on the promoted lane until live curator evidence is closed.

## Inputs

- `docs/manifests/phase06_ui_sample_manifest.json`
- `docs/manifests/phase06_ui_sample_manifest_p6_draft.json`
- `raw_docs/phase06-ui-p6-draft/`
- `scripts/build_phase06_ui_source_corpus.py`
- `scripts/build_phase06_ui_file_manifest.py`
- `scripts/build_phase06_ui_prompt_pilot_manifest.py`
- `scripts/run_phase06_ui_prompt_pilot_batch.py`
- `scripts/phase06_ui_workset_audit.py`

## Promotion Actions

1. Merged `cangjiechallenge-aiatom-speak-page`, `cangjiechallenge-aiatom-entry-page`, and `cangjiechallenge-secmeet-app-shell-page` into `docs/manifests/phase06_ui_sample_manifest.json`.
2. Copied the frozen draft corpus from `raw_docs/phase06-ui-p6-draft/` to `raw_docs/phase06-ui-p6/`.
3. Added a promoted-`P6` regression in `tests/test_build_phase06_ui_file_manifest.py` so the regular `raw_docs/phase06-ui-p6/...` paths are covered alongside the draft-path test.

## Commands

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p6 --manifest-name phase06-ui-source-corpus-p6 --priority P6 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p6.json`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p6.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p6_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p6_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p6_batch1 --artifacts-root artifacts/ui_pilots/20260411-phase06-ui-p6-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p6_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p6_batch1.json --run-label 20260411-phase06-ui-p6-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p6_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p6_batch1.json --output artifacts/ui_pilots/20260411-phase06-ui-p6-workset-audit.json --require-exhausted`
- Controlled shell live batch: `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p6_batch1.json --run-label 20260411-phase06-ui-p6-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`

## Results

- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: first rerun `12 tests OK (skipped=1)` before `phase06_ui_source_corpus_p6.json` existed; second rerun `12 tests OK` after the promoted source corpus landed.
  - artifact: promoted `P6` regression now covers `phase06_ui_source_corpus_p6.json` in addition to the existing P0/P1/exception/P4/P5/P6-draft cases.
- `docs/manifests/phase06_ui_source_corpus_p6.json`
  - result: `sample_count=3`, `file_count=3`, `corpus_root=../../raw_docs/phase06-ui-p6`.
- `docs/manifests/phase06_ui_p6_file_manifest.json`
  - result: `slice_count=3`, `role_counts={"page": 3}`, `structure_counts={"page-shell": 3}`.
- `docs/manifests/phase06_ui_prompt_pilot_p6_batch1.json`
  - result: `pilot_count=3`, `track_counts={"residual-page-shell-controller-owned-state-page": 2, "residual-mixed-app-pattern-page-shell-controller-owned-state-page": 1}`.
- `artifacts/ui_pilots/20260411-phase06-ui-p6-pilot-batch1/live_curator/20260411-phase06-ui-p6-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=3`, `passed_count=3`; all entries record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-p6-workset-audit.json`
  - result: `expected_slice_count=3`, `covered_slice_count=3`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-p6-pilot-batch1/live_curator/20260411-phase06-ui-p6-batch1-live-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=3`, `passed_count=3`; all three entries record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=false`.

## Decision

The `p6-draft` lane has been promoted into the main regular Phase06 path. The regular checkpoint advances from `20/20` to `23/23 live passed`, and the current regular file workset is exhausted again; the next regular expansion should wait for a newly frozen source corpus rather than reopening register-level manual selection or the exception rail.
