# 2026-04-11 Phase06 P4 Regular Promotion

## Goal

Promote the mechanically ready `p4-draft` lane into the primary regular Phase06 source supply, then rerun the formal chain on the promoted lane until live curator evidence is closed.

## Inputs

- `docs/manifests/phase06_ui_sample_manifest.json`
- `docs/manifests/phase06_ui_sample_manifest_p4_draft.json`
- `raw_docs/phase06-ui-p4-draft/`
- `scripts/build_phase06_ui_source_corpus.py`
- `scripts/build_phase06_ui_file_manifest.py`
- `scripts/build_phase06_ui_prompt_pilot_manifest.py`
- `scripts/run_phase06_ui_prompt_pilot_batch.py`
- `scripts/phase06_ui_workset_audit.py`

## Promotion Actions

1. Merged `cangjiechallenge-aiatom-prototype-page`, `cangjiechallenge-secmeet-meeting-list-page`, and `cangjiechallenge-secmeet-audit-log-page` into `docs/manifests/phase06_ui_sample_manifest.json`.
2. Copied the frozen draft corpus from `raw_docs/phase06-ui-p4-draft/` to `raw_docs/phase06-ui-p4/`.
3. Extended `scripts/build_phase06_ui_file_manifest.py` so promoted `raw_docs/phase06-ui-p4/...` paths reuse the same file-level overrides as the draft lane, and added a regression in `tests/test_build_phase06_ui_file_manifest.py`.

## Commands

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p4 --manifest-name phase06-ui-source-corpus-p4 --priority P4 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p4.json`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p4.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p4_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p4_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p4_batch1 --artifacts-root artifacts/ui_pilots/20260411-phase06-ui-p4-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p4_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p4_batch1.json --run-label 20260411-phase06-ui-p4-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p4_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p4_batch1.json --output artifacts/ui_pilots/20260411-phase06-ui-p4-workset-audit.json --require-exhausted`
- Controlled shell live batch: `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p4_batch1.json --run-label 20260411-phase06-ui-p4-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`

## Results

- `docs/manifests/phase06_ui_source_corpus_p4.json` records `sample_count=3`, `file_count=3`, `corpus_root=../../raw_docs/phase06-ui-p4`.
- `docs/manifests/phase06_ui_p4_file_manifest.json` records `slice_count=3`, `role_counts={"page": 3}`, `structure_counts={"page-shell": 3}`.
- `docs/manifests/phase06_ui_prompt_pilot_p4_batch1.json` records `pilot_count=3` on the `residual-page-shell-controller-owned-state-page` track.
- `artifacts/ui_pilots/20260411-phase06-ui-p4-pilot-batch1/live_curator/20260411-phase06-ui-p4-batch1-mock-curator-r1/batch-report.json` records `status=passed`, `pilot_count=3`, `passed_count=3`; all three entries have `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-p4-workset-audit.json` records `expected_slice_count=3`, `covered_slice_count=3`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-p4-pilot-batch1/live_curator/20260411-phase06-ui-p4-batch1-live-curator-r1/batch-report.json` records `status=passed`, `pilot_count=3`, `passed_count=3`; all three entries have `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=false`.

## Decision

The `p4-draft` lane has been promoted into the main regular Phase06 path. The regular checkpoint advances from `15/15` to `18/18 live passed`, and the current P4 workset is exhausted; the next regular expansion should wait for a newly frozen source corpus rather than reopening manual register selection or the exception rail.
