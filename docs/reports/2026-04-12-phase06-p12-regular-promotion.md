# 2026-04-12 Phase06 P12 Regular Promotion

## Goal

Promote the mechanically ready `P12-draft` lane into the formal regular Phase06 workset, then close the promoted lane with mock curator, workset audit, live curator, and aggregate checkpoint evidence.

## Inputs

- `docs/reports/2026-04-12-phase06-p12-draft-candidate-scout.md`
- `docs/manifests/phase06_ui_sample_manifest_p12_draft.json`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `docs/manifests/phase06_ui_source_corpus_p12.json`
- `docs/manifests/phase06_ui_p12_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p12_batch1.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p12-workset-audit.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p12-pilot-batch1/live_curator/20260412-phase06-ui-p12-batch1-live-curator-r1/batch-report.json`
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r11.json`
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r11.validation.json`
- `artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r7.json`

## Method

1. Merged the three `P12-draft` reserve samples into the primary `phase06_ui_sample_manifest.json`.
2. Copied `raw_docs/phase06-ui-p12-draft` to `raw_docs/phase06-ui-p12` and reused the already-landed promoted `P12` file-level overrides plus regression coverage.
3. Rebuilt the promoted `P12` source corpus, file manifest, and prompt-pilot manifest.
4. Revalidated the promoted lane with a mock curator batch plus exhausted-workset audit.
5. Ran the promoted `P12` live curator batch in a controlled shell with `.env.local` sourced.
6. Recomputed the aggregate regular expansion audit, validated it, and refreshed cross-workset live-pass coverage to include the new `P12` slices.

## Commands

- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p12 --manifest-name phase06-ui-source-corpus-p12 --priority P12 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p12.json`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p12.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p12_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p12_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p12_batch1 --artifacts-root artifacts/ui_pilots/20260412-phase06-ui-p12-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p12_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p12_batch1.json --run-label 20260412-phase06-ui-p12-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p12_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p12_batch1.json --output artifacts/ui_pilots/20260412-phase06-ui-p12-workset-audit.json --require-exhausted`
- `set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p12_batch1.json --run-label 20260412-phase06-ui-p12-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`
- `python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r11.json --require-decision hold-current-checkpoint-await-sample-curation`
- `python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r11.json --report artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r11.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation`
- `python3 - <<'PY' ... refresh artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r7.json from the prior r6 baseline plus docs/manifests/phase06_ui_p12_file_manifest.json and artifacts/ui_pilots/20260412-phase06-ui-p12-pilot-batch1/live_curator/20260412-phase06-ui-p12-batch1-live-curator-r1/batch-report.json`

## Results

- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `24 tests OK`
  - artifact: promoted `P12` regular override coverage is now included in the regression suite.
- `docs/manifests/phase06_ui_sample_manifest.json`
  - result: `ordered_samples=42`; the last three sample ids are `harmonyos-examples-silkui-calendar-page`, `harmonyos-examples-deepseek-about-view-page`, and `harmonyos-examples-chargingui-battery-shell`.
- `docs/manifests/phase06_ui_source_corpus_p12.json`
  - result: `sample_count=3`, `file_count=4`.
- `docs/manifests/phase06_ui_p12_file_manifest.json`
  - result: `slice_count=4`, `role_counts={"page": 3, "component": 1}`, `structure_counts={"page-shell": 3, "rich-component": 1}`.
- `docs/manifests/phase06_ui_prompt_pilot_p12_batch1.json`
  - result: `pilot_count=4`, `track_counts={"residual-page-shell-view-model-renderer-page": 2, "residual-page-shell-controller-owned-state-page": 1, "residual-rich-component-controller-owned-state-component": 1}`.
- `artifacts/ui_pilots/20260412-phase06-ui-p12-pilot-batch1/live_curator/20260412-phase06-ui-p12-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=4`, `passed_count=4`; all four promoted `P12` slices passed in mock mode.
- `artifacts/ui_pilots/20260412-phase06-ui-p12-workset-audit.json`
  - result: `covered_slice_count=4`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- `artifacts/ui_pilots/20260412-phase06-ui-p12-pilot-batch1/live_curator/20260412-phase06-ui-p12-batch1-live-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=4`, `passed_count=4`; all four promoted `P12` slices record `final_status=passed`, `verify_status=passed`, `mock_mode_used=false`, `round_count=1`.
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r11.json`
  - result: `regular_sample_count=42`, `priority_counts={"P0": 6, "P1": 4, "P10": 3, "P11": 3, "P12": 3, "P2": 3, "P3": 3, "P4": 3, "P5": 2, "P6": 3, "P7": 3, "P8": 3, "P9": 3}`, `final_decision=hold-current-checkpoint-await-sample-curation`.
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r11.validation.json`
  - result: `validation_class=valid-expansion-audit`, `issue_count=0`, `warning_count=0`, `exit_code=0`.
- `artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r7.json`
  - result: `expected_slice_count=54`, `passed_slice_count=54`, `coverage_ratio=1.0`, `regular_priority_counts={"P0": 12, "P1": 9, "P2": 3, "P3": 3, "P4": 3, "P5": 2, "P6": 3, "P7": 3, "P8": 3, "P9": 3, "P10": 3, "P11": 3, "P12": 4}`.

## Decision

- The formal regular `P12` workset is now promoted and closed.
- The regular Phase06 checkpoint advances from `50/50 live passed` to `54/54 live passed` across `P0/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11/P12`.
- The current public `cangjiechallenge` pool still remains exhausted; if more regular supply is needed, continue from the remaining official-repo reserve set rather than reopening lower-quality or exception sources.
