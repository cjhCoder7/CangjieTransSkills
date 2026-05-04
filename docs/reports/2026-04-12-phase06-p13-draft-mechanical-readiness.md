# 2026-04-12 Phase06 P13 Draft Mechanical Readiness

## Goal

Advance the newly curated `P13-draft` official reserve lane from sample scouting into the standard mechanical builder chain, without promoting it to live curator yet.

## Inputs

- `docs/reports/2026-04-12-phase06-p13-draft-candidate-scout.md`
- `docs/manifests/phase06_ui_sample_manifest_p13_draft.json`
- `raw_docs/phase06-ui-p13-draft`
- `scripts/build_phase06_ui_file_manifest.py`
- `tests/test_build_phase06_ui_file_manifest.py`

## Commands

- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest_p13_draft.json --corpus-root raw_docs/phase06-ui-p13-draft --manifest-name phase06-ui-source-corpus-p13-draft --priority P13 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p13_draft.json`
- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p13_draft.json --sample-manifest docs/manifests/phase06_ui_sample_manifest_p13_draft.json --output docs/manifests/phase06_ui_p13_draft_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p13_draft_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p13_draft_batch1 --artifacts-root artifacts/ui_pilots/20260412-phase06-ui-p13-draft-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p13_draft_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p13_draft_batch1.json --run-label 20260412-phase06-ui-p13-draft-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p13_draft_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p13_draft_batch1.json --output artifacts/ui_pilots/20260412-phase06-ui-p13-draft-workset-audit.json --require-exhausted`

## Results

- `docs/manifests/phase06_ui_source_corpus_p13_draft.json`
  - result: `sample_count=3`, `file_count=6`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `25 tests OK`
- `docs/manifests/phase06_ui_p13_draft_file_manifest.json`
  - result: `slice_count=6`, `role_counts={'page': 3, 'viewmodel': 3}`, `structure_counts={'page-shell': 3, 'rich-component': 3}`
- `docs/manifests/phase06_ui_prompt_pilot_p13_draft_batch1.json`
  - result: `pilot_count=6`, `excluded_slice_count=0`, coverage holds both `page-shell` and `rich-component` plus both ownership rails
- `artifacts/ui_pilots/20260412-phase06-ui-p13-draft-pilot-batch1/live_curator/20260412-phase06-ui-p13-draft-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=6`, `passed_count=6`
- `artifacts/ui_pilots/20260412-phase06-ui-p13-draft-workset-audit.json`
  - result: `covered_slice_count=6`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`

## Decision

- The `P13-draft` lane is mechanically ready.
- The official reserve trio now closes cleanly through `sample manifest -> source corpus -> file manifest -> prompt pilot -> mock curator -> exhausted-workset audit` without reopening the public pool or exception rail.
- The next direct move, if more regular expansion is desired, is a controlled live curator run on `docs/manifests/phase06_ui_prompt_pilot_p13_draft_batch1.json`, followed by the usual promotion decision rather than any new sample scouting.
