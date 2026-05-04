# 2026-04-13 Phase06 P21 Live Curator R1 Failure Attribution

## Goal

Record the first controlled-shell P21 non-mock live curator attempt as a partial, non-promoted lane, then freeze the decisive failure attribution before any aggregate audit, coverage refresh, or SSOT promotion move.

## Formal Status Guardrail

- The formal regular checkpoint remains `P20 / 220/220 live passed`.
- The formal promoted regular sample count remains `66`.
- `docs/manifests/phase06_ui_sample_manifest.json` still carries `ordered_samples=69`, but that count remains mechanical-only until a later fully closed P21 non-mock promotion chain exists.
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json`, and `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json` must remain untouched by this failed partial live attempt.

## Inputs

- `docs/reports/2026-04-13-phase06-p21-regular-mechanical-readiness.md`
- `docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r1/`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r1/phase06-ui-p21-ui-layout-user-model/summary.json`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r1/phase06-ui-p21-ui-layout-user-model/orchestration.json`
- `raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/List/User.cj`
- `AGENTS.md`
- `/.claude/status/current-phase.md`

## Command

- `export CANGJIE_HOME="$PWD/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json --run-label 20260413-phase06-ui-p21-batch1-live-curator-r1 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`
  - result: the batch root was created and slice-level evidence started landing, but the executor stopped the still-running process after the first decisive entity failure made infra-only recovery and promotion impossible for this run. The shell exited with `KeyboardInterrupt`, and no top-level `batch-report.json` was emitted.

## Partial Results

- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r1/`
  - result: the non-mock live attempt root exists.
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r1/batch-report.json`
  - result: missing, because the still-running batch was manually interrupted after the decisive entity blocker was confirmed.
- read-only inspection over the partial live root
  - result: `closed_slice_count=16`, `final_status_counts={passed: 15, failed: 1}`, `verify_status_counts={passed: 16}`, and one additional slice `phase06-ui-p21-ui-layout-intro-card-component` remained unclosed at interruption time.
- closed slice evidence
  - result: the already closed page/component slices remained healthy; for example the first nine UILayout entry/page/component slices all recorded `final_status=passed` and `verify_status=passed`.

## Failure Attribution

- decisive blocker slice: `phase06-ui-p21-ui-layout-user-model`
  - summary path: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r1/phase06-ui-p21-ui-layout-user-model/summary.json`
  - orchestration path: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r1/phase06-ui-p21-ui-layout-user-model/orchestration.json`
  - result: `final_status=failed`, `verify_status=passed`, `round_count=2`.
- round-1 behavior
  - result: the translator candidate hit the static blacklist on invented `ArrayList` handling and failed verification at `verify_failure_type=static-blacklist-failed`.
- round-2 behavior
  - result: verification passed, but review still failed with `review_issue_codes=['ARCH_SOURCE_ALIGNMENT_RUPTURE']`.
  - reviewer finding: `Candidate replaced ArrayList with Array despite source explicitly importing std.collection.ArrayList`.
  - interpretation: this is an entity failure, not an infrastructure-only miss, because the failure is anchored to source-backed contract drift inside the candidate rather than translator/network/timeout noise.
- source truth
  - path: `raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/List/User.cj`
  - result: the frozen source explicitly imports `std.collection.ArrayList` and uses source-backed `ArrayList<UserEntity>` at the helper boundary, so rewriting those exact tokens to `Array` is reviewer-visible contract drift.

## Decision

- The first P21 non-mock live attempt is blocked by at least one decisive entity failure.
- This run must not be classified as infra-only, and it must not use the P19/P20 targeted infra rerun lane.
- Do not refresh `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19*.json`, `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json`, `AGENTS.md`, or `/.claude/status/current-phase.md` toward any promoted P21 checkpoint language.
- The next allowed move is failure-focused repair/decision on `phase06-ui-p21-ui-layout-user-model` and the underlying `ArrayList` source-alignment conflict, followed by a later fresh live attempt only after that entity blocker is resolved.
