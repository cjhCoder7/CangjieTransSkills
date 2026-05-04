# 2026-04-14 Phase06 P22 Live Decision Review

## Goal

Prepare the decision input for a later fresh full P22 non-mock live curator, without starting that live run yet and without changing the formal checkpoint, aggregate audit, live-pass coverage, or promotion state.

## Formal Status Guardrail

- The formal regular checkpoint remains `P21 / 276/276 live passed`.
- P22 is still mechanical-ready only.
- No P22 non-mock live curator, no `r21` aggregate audit, no `r17` coverage refresh, no P22 promotion report, and no SSOT checkpoint move are performed in this review turn.

## Unique Candidate Live Input Bundle

The only allowed live input bundle for a future fresh full P22 live curator is:

- `raw_docs/phase06-ui-p22`
- `docs/manifests/phase06_ui_source_corpus_p22.json`
- `docs/manifests/phase06_ui_p22_file_manifest.json`
- `docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json`
- `artifacts/ui_pilots/20260414-phase06-ui-p22-workset-audit.json`

Supporting mechanical evidence remains:

- `docs/reports/2026-04-14-phase06-p22-regular-candidate-scout.md`
- `docs/reports/2026-04-14-phase06-p22-regular-mechanical-readiness.md`
- `artifacts/ui_pilots/20260414-phase06-ui-p22-pilot-batch1/live_curator/20260414-phase06-ui-p22-batch1-mock-curator-r1/batch-report.json`

## Proposed Fresh Full Live Curator Command

- Controlled-shell wrapper:
  - `export REPO_ROOT="/volume/wzhang/cky-workspace/my_projects/Cangjie" && export CANGJIE_HOME="$REPO_ROOT/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source "$REPO_ROOT/.env.local" >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json --run-label 20260414-phase06-ui-p22-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`
- Intended live root if approved and executed later:
  - `artifacts/ui_pilots/20260414-phase06-ui-p22-pilot-batch1/live_curator/20260414-phase06-ui-p22-batch1-live-curator-r1/`

## Required Controlled-Shell Environment

The live curator must run with explicit controlled-shell injection for:

- `CANGJIE_HOME`
- `PATH`
- `LD_LIBRARY_PATH`
- `CANGJIE_STDLIB_PATH`

This review intentionally does not validate or print secret material. It only checks toolchain-path readiness and preserves the prior `.env.local`-sourcing pattern from the successful P21 live closure.

## Read-Only Precheck

### Bundle Existence

- Command:
  - `python3 - <<'PY' ... check raw_docs/phase06-ui-p22, phase06_ui_source_corpus_p22.json, phase06_ui_p22_file_manifest.json, phase06_ui_prompt_pilot_p22_batch1.json, phase06-ui-p22-workset-audit.json`
- Result:
  - all five bundle paths exist.

### Prompt-Pilot Count

- Command:
  - `python3 - <<'PY' ... read docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json summary`
- Result:
  - `pilot_count=35`, `source_sample_count=3`, `excluded_slice_count=0`.

### Mock Batch vs Workset Audit Alignment

- Command:
  - `python3 - <<'PY' ... compare batch-report.json against phase06-ui-p22-workset-audit.json`
- Result:
  - mock batch `status=passed`
  - `mock_pilot_count=35`
  - `mock_passed_count=35`
  - audit `covered_slice_count=35`
  - audit `missing_slice_count=0`
  - audit `coverage_ratio=1.0`
  - audit `exhausted_workset=true`
  - alignment check: `counts_align=True`

### Toolchain Path Locatability In Current Shell

- Command:
  - `python3 - <<'PY' ... inspect CANGJIE_HOME / CANGJIE_STDLIB_PATH / PATH / LD_LIBRARY_PATH plus shutil.which('cjpm') and shutil.which('cjc')`
  - `find artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie -type f \\( -name 'cjpm' -o -name 'cjc' \\) | sort`
  - `ls -ld artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/runtime/lib/linux_x86_64_cjnative artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/modules/linux_x86_64_cjnative/std`
- Result:
  - current shell does **not** export `CANGJIE_HOME`
  - current shell does **not** export `CANGJIE_STDLIB_PATH`
  - current shell `which cjpm` = `None`
  - current shell `which cjc` = `None`
  - repo-local toolchain root exists
  - repo-local binary paths exist at:
    - `artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/bin/cjc`
    - `artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie/build-tools/tools/bin/cjpm`
  - repo-local runtime lib, llvm bin, and stdlib directories all exist
- Interpretation:
  - the current raw shell is not directly live-ready
  - the repo-local toolchain is present and can be made live-ready through the explicit controlled-shell wrapper above

## Success Path If A Later Live Is Approved

If the fresh full P22 live curator closes successfully, the allowed next actions are:

1. Aggregate audit refresh
   - `python3 scripts/phase06_ui_expansion_audit.py --output artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.json --require-decision hold-current-checkpoint-await-sample-curation`
2. Audit validation
   - `python3 scripts/phase06_ui_expansion_audit_validate.py --audit artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.json --report artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.validation.json --require-audit-version 2 --require-final-decision hold-current-checkpoint-await-sample-curation`
3. Coverage refresh
   - refresh into `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r17.json`
4. Promotion report
   - write `docs/reports/2026-04-14-phase06-p22-regular-promotion.md`
5. SSOT sync
   - update `AGENTS.md`
   - update `/.claude/status/current-phase.md`

No earlier step in this success chain may be skipped when narrating a promoted P22 checkpoint.

## Failure Freeze Rules

### Failure-Attribution-Only Conditions

A future P22 live attempt must be frozen as failure-attribution-only if any of the following occurs:

- the non-mock live root lands but the batch does not reach normal closeout and no trustworthy top-level `batch-report.json` is emitted
- any decisive slice ends as a bounded entity failure such as source-alignment rupture, reviewer-visible contract drift, static-blacklist failure, or verifier-blocked entity mismatch
- the batch is interrupted by `KeyboardInterrupt`, streaming interruption, or other infrastructure interruption before the full workset closes
- partial live evidence exists with failed / infrastructure-error / interrupted / unstarted slices, so promotion, aggregate refresh, and coverage refresh would overstate the run

When frozen as failure-attribution-only:

- do **not** refresh aggregate audit
- do **not** refresh coverage
- do **not** write a promotion report
- do **not** move SSOT away from `P21 / 276/276 live passed`

### When Targeted Replay Is Allowed

Targeted replay is allowed only if failure attribution isolates a bounded decisive blocker that satisfies all of the following:

- the blocker is traceable to one slice or a very small set of slices
- the source-backed contract for that slice is already frozen in the current P22 bundle
- the replay can remain slice-level and does not require changing the rest of the bundle selection
- the replay is used only to close the attributed blocker before any later separate decision on whether a fresh full-batch rerun is warranted

Targeted replay is **not** by itself a promotion action and must not trigger aggregate audit refresh, coverage refresh, promotion reporting, or SSOT movement.

Infra-only misses may be documented in the failure-attribution lane, but they do not justify any optimistic SSOT move and do not automatically authorize ad hoc reruns outside a later explicit decision.

## Recommendation

- Recommendation: `Go`, but only for a later controlled-shell fresh full P22 live curator decision.
- Rationale:
  - the unique P22 live input bundle exists and is internally consistent
  - `docs/manifests/phase06_ui_prompt_pilot_p22_batch1.json` selects `35` pilots with `excluded_slice_count=0`
  - the mock batch and exhausted workset audit still align at `35/35` with `coverage_ratio=1.0`
  - the repo-local toolchain path exists and contains both `cjc` and `cjpm`
  - the current raw shell is not directly ready, but the controlled-shell wrapper fully specifies the required environment injection
- Decision caveat:
  - approval should be for the exact controlled-shell command above, not for running the live curator directly in the current shell as-is

