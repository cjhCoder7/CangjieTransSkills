# 2026-04-12 Phase06 P14 Regular Promotion

## Goal

Promote the next reserve-only official `P14` workset directly through the formal regular Phase06 lane without reopening the draft lane, then close the promoted lane with mock curator, workset audit, live curator, aggregate audit, validation, coverage refresh, and SSOT sync.

## Inputs

- `docs/manifests/phase06_ui_sample_manifest.json`
- `raw_docs/phase06-ui-p14`
- `docs/manifests/phase06_ui_source_corpus_p14.json`
- `docs/manifests/phase06_ui_p14_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p14_batch1.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p14-workset-audit.json`
- `artifacts/ui_pilots/20260412-phase06-ui-p14-pilot-batch1/live_curator/20260412-phase06-ui-p14-batch1-live-curator-r1/batch-report.json`
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r13.json`
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r13.validation.json`
- `artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r9.json`

## Method

1. Froze three new official-reserve samples straight into `raw_docs/phase06-ui-p14` with every required helper kept explicit:
   - `HarmonyOS-Examples/19-CangjiexArkTS/CalendarManager/entry/src/main/cangjie/views/EntryView.cj + applog/Applog.cj`
   - `HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/secondarylinkage/src/main/cangjie/src/SecondaryLinkageExample.cj + DataType.cj + common/utils/src/main/cangjie/src/component/FunctionDescription.cj`
   - `HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/pages/ToDoList.cj + ToDoListItem.cj + model/ConstData.cj + model/ToDo.cj`
2. Merged the three `P14` samples into `docs/manifests/phase06_ui_sample_manifest.json`.
3. Extended `scripts/build_phase06_ui_file_manifest.py` and `tests/test_build_phase06_ui_file_manifest.py` with promoted `P14` regular overrides and regression coverage.
4. Rebuilt the promoted `P14` source corpus, file manifest, and prompt-pilot manifest.
5. Revalidated the promoted lane with `py_compile`, the full `test_build_phase06_ui_file_manifest.py` suite, a mock curator batch, and an exhausted-workset audit.
6. Ran the promoted `P14` live curator batch in a controlled shell with `.env.local` sourced.
7. Recomputed the aggregate regular expansion audit, validated it, refreshed live-pass coverage to include the new `P14` slices, and synced SSOT to the new formal checkpoint.

## Commands

- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --corpus-root raw_docs/phase06-ui-p14 --manifest-name phase06-ui-source-corpus-p14 --priority P14 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p14.json`
- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p14.json --sample-manifest docs/manifests/phase06_ui_sample_manifest.json --output docs/manifests/phase06_ui_p14_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p14_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p14_batch1 --artifacts-root artifacts/ui_pilots/20260412-phase06-ui-p14-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p14_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p14_batch1.json --run-label 20260412-phase06-ui-p14-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p14_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p14_batch1.json --output artifacts/ui_pilots/20260412-phase06-ui-p14-workset-audit.json --require-exhausted`
- `set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p14_batch1.json --run-label 20260412-phase06-ui-p14-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`
- `python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r13.json --require-decision hold-current-checkpoint-await-sample-curation`
- `python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r13.json --report artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r13.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation`
- `python3 - <<'PY' ... refresh artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r9.json from the prior r8 baseline plus docs/manifests/phase06_ui_p14_file_manifest.json and artifacts/ui_pilots/20260412-phase06-ui-p14-pilot-batch1/live_curator/20260412-phase06-ui-p14-batch1-live-curator-r1/batch-report.json`

## Results

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: `passed`
  - artifact: promoted `P14` regular override coverage is loadable by the builder and test suite.
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `27 tests OK`
  - artifact: promoted `P14` override coverage is included in the file-manifest suite.
- `docs/manifests/phase06_ui_sample_manifest.json`
  - result: `ordered_samples=48`; the last three sample ids are `harmonyos-examples-calendar-manager-entry-view`, `harmonyos-cangjie-cases-secondary-linkage-page`, and `harmonyos-cangjie-cases-pending-items-todo-list`.
- `docs/manifests/phase06_ui_source_corpus_p14.json`
  - result: `sample_count=3`, `file_count=9`.
- `docs/manifests/phase06_ui_p14_file_manifest.json`
  - result: `slice_count=9`, `role_counts={"page": 3, "viewmodel": 4, "component": 2}`, `structure_counts={"page-shell": 3, "rich-component": 6}`.
- `docs/manifests/phase06_ui_prompt_pilot_p14_batch1.json`
  - result: `pilot_count=9`, `source_sample_count=3`, and all `P14` slices were selected into one residual workset.
- `artifacts/ui_pilots/20260412-phase06-ui-p14-pilot-batch1/live_curator/20260412-phase06-ui-p14-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=9`, `passed_count=9`; all nine promoted `P14` slices passed in mock mode.
- `artifacts/ui_pilots/20260412-phase06-ui-p14-workset-audit.json`
  - result: `covered_slice_count=9`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.
- `artifacts/ui_pilots/20260412-phase06-ui-p14-pilot-batch1/live_curator/20260412-phase06-ui-p14-batch1-live-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=9`, `passed_count=9`; all nine promoted `P14` slices record `final_status=passed`, `verify_status=passed`, `mock_mode_used=false`, and every slice closed in round 1.
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r13.json`
  - result: `regular_sample_count=48`, `priority_counts={"P0": 6, "P1": 4, "P10": 3, "P11": 3, "P12": 3, "P13": 3, "P14": 3, "P2": 3, "P3": 3, "P4": 3, "P5": 2, "P6": 3, "P7": 3, "P8": 3, "P9": 3}`, `final_decision=hold-current-checkpoint-await-sample-curation`.
- `artifacts/ui_pilots/20260412-phase06-ui-regular-expansion-audit-r13.validation.json`
  - result: `validation_class=valid-expansion-audit`, `issue_count=0`, `warning_count=0`.
- `artifacts/ui_pilots/20260412-phase06-ui-live-pass-coverage-r9.json`
  - result: `expected_slice_count=69`, `passed_slice_count=69`, `coverage_ratio=1.0`, `regular_priority_counts={"P0": 12, "P1": 9, "P2": 3, "P3": 3, "P4": 3, "P5": 2, "P6": 3, "P7": 3, "P8": 3, "P9": 3, "P10": 3, "P11": 3, "P12": 4, "P13": 6, "P14": 9}`.

## Decision

- The formal regular `P14` workset is now promoted and closed.
- The regular Phase06 checkpoint advances from `60/60 live passed` to `69/69 live passed` across `P0/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11/P12/P13/P14`.
- The regular lane remains closed to public `cangjiechallenge`, register-level manual selection, and the exception rail; any further expansion must continue only from the remaining official reserve beyond `docs/reports/2026-04-12-phase06-p14-regular-promotion.md`.
