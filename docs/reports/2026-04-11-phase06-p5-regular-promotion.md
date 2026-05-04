# 2026-04-11 Phase06 P5 Regular Promotion

## Goal

Promote the mechanically ready `p5-draft` lane into the primary regular Phase06 source supply, then rerun the formal chain on the promoted lane until live curator evidence is closed.

## Inputs

- `docs/manifests/phase06_ui_sample_manifest.json`
- `docs/manifests/phase06_ui_sample_manifest_p5_draft.json`
- `raw_docs/phase06-ui-p5-draft/`
- `scripts/build_phase06_ui_source_corpus.py`
- `scripts/build_phase06_ui_file_manifest.py`
- `scripts/build_phase06_ui_prompt_pilot_manifest.py`
- `scripts/run_phase06_ui_prompt_pilot_batch.py`
- `scripts/phase06_ui_workset_audit.py`

## Promotion Actions

1. Merged `cangjiechallenge-makerizon-history-page` and `cangjiechallenge-makerizon-mine-page` into `docs/manifests/phase06_ui_sample_manifest.json`.
2. Copied the frozen draft corpus from `raw_docs/phase06-ui-p5-draft/` to `raw_docs/phase06-ui-p5/`.
3. Added a promoted-`P5` regression in `tests/test_build_phase06_ui_file_manifest.py` so the regular `raw_docs/phase06-ui-p5/...` paths are covered alongside the existing draft-path test.

## Commands

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p5 --manifest-name phase06-ui-source-corpus-p5 --priority P5 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p5.json`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p5.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p5_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p5_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p5_batch1 --artifacts-root artifacts/ui_pilots/20260411-phase06-ui-p5-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p5_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p5_batch1.json --run-label 20260411-phase06-ui-p5-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p5_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p5_batch1.json --output artifacts/ui_pilots/20260411-phase06-ui-p5-workset-audit.json --require-exhausted`
- Controlled shell live batch: `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p5_batch1.json --run-label 20260411-phase06-ui-p5-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`

## Results

- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `10 tests OK (skipped=1)`
  - artifact: promoted `P5` regression now covers `phase06_ui_source_corpus_p5.json` in addition to the existing P0/P1/exception/P4/P5-draft cases.
- `docs/manifests/phase06_ui_source_corpus_p5.json`
  - result: `sample_count=2`, `file_count=2`, `corpus_root=../../raw_docs/phase06-ui-p5`.
- `docs/manifests/phase06_ui_p5_file_manifest.json`
  - result: `slice_count=2`, `role_counts={"page": 2}`, `structure_counts={"page-shell": 2}`.
- `docs/manifests/phase06_ui_prompt_pilot_p5_batch1.json`
  - result: `pilot_count=2`, `track_counts={"residual-page-shell-controller-owned-state-page": 2}`.
- `artifacts/ui_pilots/20260411-phase06-ui-p5-pilot-batch1/live_curator/20260411-phase06-ui-p5-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=2`, `passed_count=2`; both entries record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-p5-workset-audit.json`
  - result: `expected_slice_count=2`, `covered_slice_count=2`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-p5-pilot-batch1/live_curator/20260411-phase06-ui-p5-batch1-live-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=2`, `passed_count=2`; both entries record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=false`.

## Decision

The `p5-draft` lane has been promoted into the main regular Phase06 path. The regular checkpoint advances from `18/18` to `20/20 live passed`, and the current regular file workset is exhausted again; the next regular expansion should wait for a newly frozen source corpus rather than reopening register-level manual selection or the exception rail.
