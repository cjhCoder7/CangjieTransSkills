# 2026-04-11 Phase06 P6 Draft Candidate Scout

## Goal

Scout the next regular Phase06 source supply after the formal `P5` promotion exhausted the `20/20 live passed` regular pool, then freeze only the strongest remaining regular-lane files into a draft-ready chain.

## Inputs

- `AGENTS.md`
- `.claude/status/current-phase.md`
- `/tmp/phase06-repo-scout/aiatom`
- `/tmp/phase06-repo-scout/secmeet`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `scripts/build_phase06_ui_source_corpus.py`
- `scripts/build_phase06_ui_file_manifest.py`
- `scripts/build_phase06_ui_prompt_pilot_manifest.py`
- `scripts/run_phase06_ui_prompt_pilot_batch.py`
- `scripts/phase06_ui_workset_audit.py`

## Method

1. Re-audited the already approved pinned `AIAtom` and `SecureMeet` repos for unconsumed regular `.cj` files after `P0/P1/P2/P3/P4/P5` closed.
2. Kept only files that still look like direct regular page-shell candidates under the current rail.
3. Deferred `HanziPage.cj` because its page contract drives `HanziWriterCanvas` through direct `animate()/resetQuiz()` bridge calls, which is materially heavier than the already accepted `PrototypePage.cj` pattern.
4. Frozen the selected files into `raw_docs/phase06-ui-p6-draft`, then built the draft chain and validated it with a mock curator batch plus exhausted-workset audit.

## Selected draft candidates

- `cangjiechallenge-aiatom-speak-page`
  - source: `https://gitcode.com/cangjiechallenge/bb40b887dcf53d1a8b72884ad862fdf9 @ c99988534078e0c0409ffb20d298b79853f013ed`
  - file: `cangjieApp/entry/src/main/cangjie/pages/SpeakPage.cj`
  - tags: `page-shell` + `controller-owned-state`
- `cangjiechallenge-aiatom-entry-page`
  - source: `https://gitcode.com/cangjiechallenge/bb40b887dcf53d1a8b72884ad862fdf9 @ c99988534078e0c0409ffb20d298b79853f013ed`
  - file: `cangjieApp/entry/src/main/cangjie/index.cj`
  - tags: `page-shell` + `controller-owned-state`
- `cangjiechallenge-secmeet-app-shell-page`
  - source: `https://gitcode.com/cangjiechallenge/d45e5bcde569dadcaf4fcc0524ac8f38 @ c18f350c6aecbeadd9b9115b739e3f3a0fa73212`
  - file: `entry/src/main/cangjie/index.cj`
  - tags: `page-shell` + `controller-owned-state` + `mixed-app-pattern`

## Deferred / excluded findings

- `aiatom/cangjieApp/entry/src/main/cangjie/pages/HanziPage.cj`
  - deferred because the page directly drives `HanziWriterCanvas.animate()` and `resetQuiz()` in addition to routing and speech flow, making it a riskier regular-lane first pick than `SpeakPage.cj`.
- `secmeet/entry/src/main/cangjie/meeting_detail_page.cj`
  - excluded because it is command-line style rendering/orchestration, not an ArkUI regular page shell.
- `secmeet/entry/src/main/cangjie/ui_components.cj`
  - excluded because it is render-helper scaffolding rather than a direct regular page/component sample.
- `secmeet/entry/src/main/cangjie/ui_enhancements.cj`
  - excluded because it is utility/constants scaffolding rather than a direct regular page/component sample.
- `makerizon/MeetingAssistant/entry/src/main/cangjie/index.cj`
  - excluded because it is bridge/bootstrap registration rather than a direct regular page shell.

## Commands

- `python3 -m py_compile scripts/build_phase06_ui_file_manifest.py tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_source_corpus.py --sample-manifest docs/manifests/phase06_ui_sample_manifest_p6_draft.json --corpus-root raw_docs/phase06-ui-p6-draft --manifest-name phase06-ui-source-corpus-p6-draft --priority P6 --adoption-decision primary --source-type external_repo --output docs/manifests/phase06_ui_source_corpus_p6_draft.json`
- `python3 tests/test_build_phase06_ui_file_manifest.py`
- `python3 scripts/build_phase06_ui_file_manifest.py --source-corpus docs/manifests/phase06_ui_source_corpus_p6_draft.json --sample-manifest docs/manifests/phase06_ui_sample_manifest_p6_draft.json --output docs/manifests/phase06_ui_p6_draft_file_manifest.json`
- `python3 scripts/build_phase06_ui_prompt_pilot_manifest.py --file-manifest docs/manifests/phase06_ui_p6_draft_file_manifest.json --selection-mode residual-workset --manifest-name phase06_ui_prompt_pilot_p6_draft_batch1 --artifacts-root artifacts/ui_pilots/20260411-phase06-ui-p6-draft-pilot-batch1 --output docs/manifests/phase06_ui_prompt_pilot_p6_draft_batch1.json`
- `python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p6_draft_batch1.json --run-label 20260411-phase06-ui-p6-draft-batch1-mock-curator-r1 --mock-mode --max-rounds 1 --timeout-seconds 300 --llm-max-retries 1 --pattern-limit 0`
- `python3 scripts/phase06_ui_workset_audit.py --file-manifest docs/manifests/phase06_ui_p6_draft_file_manifest.json --pilot-manifest docs/manifests/phase06_ui_prompt_pilot_p6_draft_batch1.json --output artifacts/ui_pilots/20260411-phase06-ui-p6-draft-workset-audit.json --require-exhausted`

## Results

- `python3 tests/test_build_phase06_ui_file_manifest.py`
  - result: `11 tests OK`
  - artifact: draft `P6` overrides are covered alongside the existing regular/draft lanes.
- `docs/manifests/phase06_ui_source_corpus_p6_draft.json`
  - result: `sample_count=3`, `file_count=3`, `corpus_root=../../raw_docs/phase06-ui-p6-draft`.
- `docs/manifests/phase06_ui_p6_draft_file_manifest.json`
  - result: `slice_count=3`, `role_counts={"page": 3}`, `structure_counts={"page-shell": 3}`.
- `docs/manifests/phase06_ui_prompt_pilot_p6_draft_batch1.json`
  - result: `pilot_count=3`, `track_counts={"residual-page-shell-controller-owned-state-page": 2, "residual-mixed-app-pattern-page-shell-controller-owned-state-page": 1}`.
- `artifacts/ui_pilots/20260411-phase06-ui-p6-draft-pilot-batch1/live_curator/20260411-phase06-ui-p6-draft-batch1-mock-curator-r1/batch-report.json`
  - result: `status=passed`, `pilot_count=3`, `passed_count=3`; all three draft slices record `final_status=passed`, `verify_status=passed`, `round_count=1`, `mock_mode_used=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-p6-draft-workset-audit.json`
  - result: `covered_slice_count=3`, `missing_slice_count=0`, `coverage_ratio=1.0`, `exhausted_workset=true`.

## Decision

The `p6-draft` lane is mechanically ready. Formal promotion is recorded separately in `docs/reports/2026-04-11-phase06-p6-regular-promotion.md`.
