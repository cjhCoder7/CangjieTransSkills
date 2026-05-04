# 2026-04-12 Phase06 P9 Regular Promotion

## Goal

Promote the mechanically ready `P9-draft` lane into the formal regular Phase06 workset, then close the promoted lane with mock curator, workset audit, live curator, and aggregate checkpoint evidence.

## Inputs

- `docs/reports/2026-04-12-phase06-p9-draft-candidate-scout.md`
- `docs/manifests/phase06_ui_sample_manifest_p9_draft.json`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `docs/manifests/phase06_ui_source_corpus_p9.json`
- `docs/manifests/phase06_ui_p9_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p9_batch1.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p9-workset-audit.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p9-pilot-batch1/live_curator/20260412-phase06-ui-p9-batch1-live-curator-r1/batch-report.json`
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r8.json`
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r8.validation.json`
- `artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r4.json`

## Method

1. Merged the three `P9-draft` reserve samples into the primary `phase06_ui_sample_manifest.json`.
2. Copied `raw_docs/phase06-ui-p9-draft` to `raw_docs/phase06-ui-p9` and reused the already-landed promoted `P9` file-level overrides plus regression coverage.
3. Rebuilt the promoted `P9` source corpus, file manifest, and prompt-pilot manifest.
4. Revalidated the promoted lane with a mock curator batch plus exhausted-workset audit.
5. Ran the promoted `P9` live curator batch in a controlled shell with `.env.local` sourced.
6. Recomputed the aggregate regular expansion audit, validated it, and refreshed cross-workset live-pass coverage.

## Commands

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p9 --manifest-name phase06-ui-source-corpus-p9 --priority P9 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p9.json`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p9.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p9_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p9_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p9_batch1 --artifacts-root artifacts/ui_pilots/20260412-phase06-ui-p9-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p9_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p9_batch1.json --run-label 20260412-phase06-ui-p9-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p9_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p9_batch1.json --output artifacts/ui_pilots/20260412-phase06-ui-p9-workset-audit.json --require-exhausted`
- `set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p9_batch1.json --run-label 20260412-phase06-ui-p9-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`
- `python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r8.json --require-decision hold-current-checkpoint-await-sample-curation`
- `python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r8.json --report artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r8.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation`

## Results

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: `exit 0`
  - artifact: promoted `P9` override sources compile cleanly.
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `18 tests OK`
  - artifact: promoted `P9` regular override coverage is now included in the regression suite.
- `docs/manifests/phase06_ui_sample_manifest.json`
  - result: `ordered_samples=33`; the last three sample ids are `harmonyos-examples-commonui-swiper-page`, `harmonyos-examples-commonui-text-input-page`, and `harmonyos-examples-helloword-entry-page`.
- `docs/manifests/phase06_ui_source_corpus_p9.json`
  - result: `sample_count=3`, `file_count=3`.
- `docs/manifests/phase06_ui_p9_file_manifest.json`
  - result: `slice_count=3`, `role_counts={"page": 3}`, `structure_counts={"page-shell": 3}`.
- `docs/manifests/phase06_ui_prompt_pilot_p9_batch1.json`
  - result: `pilot_count=3`, `track_counts={"residual-page-shell-controller-owned-state-page": 1, "residual-page-shell-view-model-renderer-page": 2}`.
- `artifacts/ui_pilots/20260412-phase06-ui-p9-pilot-batch1/live_curator/20260412-phase06-ui-p9-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=3`, `passed_count=3`; all three promoted `P9` slices passed in mock mode.
- `artifacts/ui_pilots/20260412-phase06-ui-p9-workset-audit.json`
  - result: `covered_slice_count=3`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- `artifacts/ui_pilots/20260412-phase06-ui-p9-pilot-batch1/live_curator/20260412-phase06-ui-p9-batch1-live-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=3`, `passed_count=3`; all three promoted `P9` slices record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=false`.
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r8.json`
  - result: `regular_sample_count=33`, `priority_counts={"P0": 6, "P1": 4, "P2": 3, "P3": 3, "P4": 3, "P5": 2, "P6": 3, "P7": 3, "P8": 3, "P9": 3}`, `final_decision=hold-current-checkpoint-await-sample-curation`.
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r8.validation.json`
  - result: `validation_class=valid-expansion-audit`, `issue_count=0`, `warning_count=0`, `exit_code=0`.
- `artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r4.json`
  - result: `expected_slice_count=44`, `passed_slice_count=27`, `coverage_ratio=0.6136`.

## Decision

- The formal regular `P9` workset is now promoted and closed.
- The regular Phase06 checkpoint advances from `41/41 live passed` to `44/44 live passed` across `P0/P1/P2/P3/P4/P5/P6/P7/P8/P9`.
- The current public `cangjiechallenge` pool still remains exhausted; if more regular supply is needed, continue from the remaining official-repo reserve set rather than reopening lower-quality or exception sources.
