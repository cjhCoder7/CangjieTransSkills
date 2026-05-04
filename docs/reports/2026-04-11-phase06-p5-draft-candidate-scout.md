# 2026-04-11 Phase06 P5 Draft Candidate Scout

## Goal

Scout the next regular Phase06 source supply from the public `cangjiechallenge` org pool after the regular checkpoint reached `18/18 live passed`, then freeze only the pin-ready self-contained candidates into a draft-ready chain.

## Inputs

- `docs/reports/2026-04-11-phase06-regular-source-supply-check.md`
- `artifacts/ui_pilots/20260411-phase06-ui-regular-source-supply-check.json`
- `https://web-api.gitcode.com/api/v2/groups?search=cangjiechallenge`
- `https://web-api.gitcode.com/api/v2/groups/10512886/projects?page=1&per_page=100`
- Local scout clone root: `/tmp/cjchallenge_repo_scan`
- `docs/manifests/phase06_ui_sample_manifest_p5_draft.json`
- `docs/manifests/phase06_ui_source_corpus_p5_draft.json`
- `docs/manifests/phase06_ui_p5_draft_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p5_draft_batch1.json`
- `artifacts/ui_pilots/20260411-phase06-ui-p5-draft-scout.json`
- `artifacts/ui_pilots/20260411-phase06-ui-p5-draft-workset-audit.json`
- `artifacts/ui_pilots/20260411-phase06-ui-p5-draft-pilot-batch1/live_curator/20260411-phase06-ui-p5-draft-batch1-mock-curator-r1/batch-report.json`

## Method

1. Resolve the public `cangjiechallenge` group through `web-api.gitcode.com`, confirm `group_id=10512886`, and enumerate the visible public repo list.
2. Exclude the already consumed pinned repos `bb40...` (`AIAtom`) and `d45e...` (`XUPT_SEC1`) from the new scout set.
3. Shallow-clone the remaining six public repos and audit their `.cj` files for page-shell / rich-component suitability, self-containedness, and hybrid/bridge pressure.
4. Freeze only the self-contained page-local Makerizon files into `raw_docs/phase06-ui-p5-draft` and build the draft chain.
5. Validate the draft chain with `residual-workset` prompt-manifest generation, a mock curator batch, and an exhausted-workset audit.

## Selected draft candidates

- `cangjiechallenge-makerizon-history-page`
  - source: `https://gitcode.com/cangjiechallenge/6a27783ce2bf2047bab996b3994d601d @ 6993ef734acb2929e46b322b8120efb94595b5ba`
  - file: `MeetingAssistant/entry/src/main/cangjie/history.cj`
  - tags: `page-shell` + `controller-owned-state`
- `cangjiechallenge-makerizon-mine-page`
  - source: `https://gitcode.com/cangjiechallenge/6a27783ce2bf2047bab996b3994d601d @ 6993ef734acb2929e46b322b8120efb94595b5ba`
  - file: `MeetingAssistant/entry/src/main/cangjie/mine.cj`
  - tags: `page-shell` + `controller-owned-state`

## Deferred / excluded findings

- `TaskGenie/entry/src/main/cangjie/begin.cj`
  - deferred because it depends on sibling `index.cj` bridge registration via `globalJSFunction`, so a single-file freeze would not remain self-contained for the regular draft rail.
- `TaskGenie/entry/src/main/cangjie/a_i.cj`
  - deferred because `magic.dsl`, `agent.chat`, `spawn`, and mixed bridge callbacks make it too special for the current regular rail.
- `06ec...`
  - excluded because the visible `.cj` files are JS interop / manager helpers rather than UI pages.
- `d029...`
  - excluded because the visible `.cj` files are backend/controller/sql helpers.
- `eb8...` and `9246...`
  - excluded because no public `.cj` source files were present in the default-branch snapshot.

## Commands

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest_p5_draft.json --corpus-root raw_docs/phase06-ui-p5-draft --manifest-name phase06-ui-source-corpus-p5-draft --priority P5 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p5_draft.json`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p5_draft.json --sample-manifest docs/manifests/phase06_ui_sample_manifest_p5_draft.json --output docs/manifests/phase06_ui_p5_draft_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p5_draft_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p5_draft_batch1 --artifacts-root artifacts/ui_pilots/20260411-phase06-ui-p5-draft-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p5_draft_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p5_draft_batch1.json --run-label 20260411-phase06-ui-p5-draft-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p5_draft_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p5_draft_batch1.json --output artifacts/ui_pilots/20260411-phase06-ui-p5-draft-workset-audit.json --require-exhausted`

## Results

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
  - result: `exit 0`
  - artifact: builder / test source compiled successfully.
- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `9 tests OK`
  - artifact: regression now covers `phase06_ui_source_corpus_p5_draft.json` in addition to the existing P0/P1/exception/P4 cases.
- `docs/manifests/phase06_ui_source_corpus_p5_draft.json`
  - result: `sample_count=2`, `file_count=2`, `corpus_root=../../raw_docs/phase06-ui-p5-draft`.
- `docs/manifests/phase06_ui_p5_draft_file_manifest.json`
  - result: `slice_count=2`, `role_counts={"page": 2}`, `structure_counts={"page-shell": 2}`.
- `docs/manifests/phase06_ui_prompt_pilot_p5_draft_batch1.json`
  - result: `pilot_count=2`, `track_counts={"residual-page-shell-controller-owned-state-page": 2}`.
- `artifacts/ui_pilots/20260411-phase06-ui-p5-draft-pilot-batch1/live_curator/20260411-phase06-ui-p5-draft-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=2`, `passed_count=2`; both selected slices record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-p5-draft-workset-audit.json`
  - result: `covered_slice_count=2`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.

## Decision

- The `p5-draft` lane is now mechanically ready.
- The regular Phase06 checkpoint still holds at `18/18 live passed`; this turn did not open a live curator batch or promote the new lane.
- The next direct move is to review and merge `docs/manifests/phase06_ui_sample_manifest_p5_draft.json` into the main sample manifest, copy `raw_docs/phase06-ui-p5-draft` to `raw_docs/phase06-ui-p5`, and rerun the formal `source corpus -> file manifest -> prompt-pilot manifest -> live curator` chain on the promoted lane.
