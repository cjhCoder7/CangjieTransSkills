# 2026-04-11 Phase06 Regular Source Supply Check

## Goal

Determine whether Phase06 can open another regular prompt-pilot batch after the current `35/35 live passed` checkpoint, or whether the repo-local regular sample supply is already exhausted.

## Inputs

- `docs/manifests/phase06_ui_sample_manifest.json`
- `docs/manifests/phase06_ui_source_corpus_p0.json`
- `docs/manifests/phase06_ui_source_corpus_p1.json`
- `docs/manifests/phase06_ui_source_corpus_p2.json`
- `docs/manifests/phase06_ui_source_corpus_p3.json`
- `docs/manifests/phase06_ui_source_corpus_p4.json`
- `docs/manifests/phase06_ui_source_corpus_p5.json`
- `docs/manifests/phase06_ui_source_corpus_p6.json`
- `docs/manifests/phase06_ui_p0_file_manifest.json`
- `docs/manifests/phase06_ui_p1_file_manifest.json`
- `docs/manifests/phase06_ui_p2_file_manifest.json`
- `docs/manifests/phase06_ui_p3_file_manifest.json`
- `docs/manifests/phase06_ui_p4_file_manifest.json`
- `docs/manifests/phase06_ui_p5_file_manifest.json`
- `docs/manifests/phase06_ui_p6_file_manifest.json`
- `artifacts/ui_pilots/20260410-phase06-ui-p0-workset-audit.json`
- `artifacts/ui_pilots/20260410-phase06-ui-p1-workset-audit.json`
- `artifacts/ui_pilots/20260411-phase06-ui-p2-workset-audit.json`
- `artifacts/ui_pilots/20260411-phase06-ui-p3-workset-audit.json`
- `artifacts/ui_pilots/20260411-phase06-ui-p4-workset-audit.json`
- `artifacts/ui_pilots/20260411-phase06-ui-p5-workset-audit.json`
- `artifacts/ui_pilots/20260411-phase06-ui-p6-workset-audit.json`
- `artifacts/ui_pilots/20260411-phase06-ui-regular-expansion-audit-r5.json`
- `artifacts/ui_pilots/20260411-phase06-ui-regular-expansion-audit-r5.validation.json`
- `artifacts/ui_pilots/20260411-phase06-ui-live-pass-coverage-r1.json`

## Method

1. Read `ordered_samples` from `phase06_ui_sample_manifest.json` and keep only regular samples (`adoption_decision=primary`, `source_type=external_repo`, no `role`).
2. Re-run `scripts/phase06_ui_expansion_audit.py` after tightening the aggregate filter so draft and exception lanes do not pollute the regular checkpoint, then validate the result with `scripts/phase06_ui_expansion_audit_validate.py`.
3. Sum `entries` across the promoted `P0/P1/P2/P3/P4/P5/P6` file manifests and reconcile them against the seven matching workset-audit artifacts.
4. Reconcile the nine non-draft prompt-pilot manifests against non-draft, non-mock `live_curator/**/summary.json` evidence and persist the result to `20260411-phase06-ui-live-pass-coverage-r1.json`.
5. Treat draft scouting lanes and the exception rail as excluded metadata, not as reopenable regular supply.

## Results

- Current regular sample manifest count: `24`, grouped as `P0=6`, `P1=4`, `P2=3`, `P3=3`, `P4=3`, `P5=2`, `P6=3`.
- Current frozen regular sample count: `24`.
- Remaining regular sample ids: `[]`.
- The refreshed aggregate audit `artifacts/ui_pilots/20260411-phase06-ui-regular-expansion-audit-r5.json` records `source_manifest_count=7`, `file_manifest_count=7`, `workset_audit_count=7`, `final_decision=hold-current-checkpoint-await-sample-curation`; the validator report records `issue_count=0`, `warning_count=0`, `validation_class=valid-expansion-audit`, `exit_code=0`.
- Current regular file-manifest slice count: `35` across `P0/P1/P2/P3/P4/P5/P6`.
- All seven promoted workset audits record `coverage_ratio=1.0`, `missing_slice_count=0`, `exhausted_workset=true`.
- `artifacts/ui_pilots/20260411-phase06-ui-live-pass-coverage-r1.json` records `manifest_slice_count=35`, `live_passed_slice_count=35`, `missing_live_pass_slice_ids=[]`, grouped as `P0=12`, `P1=9`, `P2=3`, `P3=3`, `P4=3`, `P5=2`, `P6=3`.
- Draft and exception lanes remain excluded from the regular aggregate: audit `r5` ignored `4` draft/exception source corpus manifests, `4` draft/exception file manifests, and `3` draft workset audits.

## Decision

- Do not open a new regular prompt-pilot batch now.
- The current repo-local regular supply is exhausted: `24/24` regular samples are already frozen, `35/35` regular file-manifest slices are exhausted, and `35/35` regular prompt-pilot slices already hold non-mock live pass evidence.
- The next Phase06 move is supply-side work: curate new approved pinned repos / commits / file paths, freeze a new regular source corpus, build a new file manifest, and only then reopen the regular prompt-pilot lane.

## Evidence Artifacts

- `artifacts/ui_pilots/20260411-phase06-ui-regular-expansion-audit-r5.json`
- `artifacts/ui_pilots/20260411-phase06-ui-regular-expansion-audit-r5.validation.json`
- `artifacts/ui_pilots/20260411-phase06-ui-live-pass-coverage-r1.json`

