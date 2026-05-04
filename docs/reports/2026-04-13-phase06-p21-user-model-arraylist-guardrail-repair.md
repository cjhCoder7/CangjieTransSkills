# 2026-04-13 Phase06 P21 User-Model ArrayList Guardrail Repair

## Goal

Repair the P21 `phase06-ui-p21-ui-layout-user-model` blocker without changing the formal checkpoint narrative, then prove the old `ArrayList` conflict no longer blocks the slice.

## Root Cause

- The first non-mock P21 live attempt blocked on a guardrail contradiction:
  - `scripts/static_blacklist_checker.py` still treated `ArrayList` as a blanket zero-tolerance token.
  - reviewer/source-alignment guardrails required exact parity when the frozen UI source already used `std.collection.ArrayList`.
- For `raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/List/User.cj`, the source-backed `ArrayList` fact lived inside the helper body (`ArrayList<UserEntity>(...)`) rather than only in a field or an explicit source signature.
- The existing static-check exception path already covered source-backed field/signature matches, but it did not cover:
  - source-backed helper-body `ArrayList(...)` constructor lines that only gained a leading `return`
  - source-backed helper boundaries where the candidate made the return type explicit while the source relied on inference

## Changes

- `scripts/static_blacklist_checker.py`
  - added a narrower UI-only `ArrayList` escape hatch for source-backed helper-body constructor lines
  - added a source-backed helper-function key collector so `func foo(...): ArrayList<T>` is allowed only when the same source-backed helper already uses `ArrayList` inside that function body
- `tests/test_static_blacklist_checker.py`
  - added a regression that mirrors the `components/List/User.cj` failure shape

## Verification

- `python3 -m py_compile scripts/static_blacklist_checker.py tests/test_static_blacklist_checker.py`
  - result: passed
- `python3 tests/test_static_blacklist_checker.py`
  - result: `29 tests OK`
- `PYTHONPATH=scripts python3 - <<'PY' ... StaticBlacklistChecker().check(attempt-01 User.cj, tu=...) ... PY`
  - result: `passed=True`, `violations=[]`
  - evidence: the former failing candidate at `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r1/phase06-ui-p21-ui-layout-user-model/temp_workspace/20260413T142005Z-tu-phase06-ui-p21-batch1-phase06-ui-p21-ui-layout-user-model-components-list-use/attempt-01/components/List/User.cj` is no longer blocked by static blacklist after the repair
- Controlled-shell non-mock orchestrator replay:
  - command: `export CANGJIE_HOME=... && export PATH=... && export LD_LIBRARY_PATH=... && export CANGJIE_STDLIB_PATH=... && set -a && source .env.local >/dev/null 2>&1 || true && set +a && python3 scripts/orchestrator.py --tu-json artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/phase06-ui-p21-ui-layout-user-model/target.explicit_ui_tags.tu.json --architecture-skill docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md --pattern-limit 0 --workspace-root artifacts/ui_pilots/20260413-phase06-ui-p21-repair-check-user-model-r2/temp_workspace --model Pro/zai-org/GLM-5 --timeout-seconds 600 --llm-max-retries 2 --max-rounds 2 --output artifacts/ui_pilots/20260413-phase06-ui-p21-repair-check-user-model-r2/orchestration.json`
  - result: `final_status=passed`, reviewer passed, verifier passed, one-round closure
  - evidence:
    - `artifacts/ui_pilots/20260413-phase06-ui-p21-repair-check-user-model-r2/orchestration.json`
    - `artifacts/ui_pilots/20260413-phase06-ui-p21-repair-check-user-model-r2/temp_workspace/20260413T144055Z-tu-phase06-ui-p21-batch1-phase06-ui-p21-ui-layout-user-model-components-list-use/attempt-01/static_check_result.json`
    - `artifacts/ui_pilots/20260413-phase06-ui-p21-repair-check-user-model-r2/temp_workspace/20260413T144055Z-tu-phase06-ui-p21-batch1-phase06-ui-p21-ui-layout-user-model-components-list-use/attempt-01/review_result.json`
    - `artifacts/ui_pilots/20260413-phase06-ui-p21-repair-check-user-model-r2/temp_workspace/20260413T144055Z-tu-phase06-ui-p21-batch1-phase06-ui-p21-ui-layout-user-model-components-list-use/attempt-01/verify_result.json`

## Decision

- The specific `phase06-ui-p21-ui-layout-user-model` blocker is repaired.
- The formal checkpoint still remains `P20 / 220/220 live passed`.
- Do not refresh aggregate audit or live-pass coverage from this repair check.
- The next allowed move is a fresh full P21 non-mock live curator attempt from `docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json`.

## Residual Risk

- Only the previously failing `user-model` slice was revalidated after the guardrail repair; the remaining P21 slices still need a fresh full-batch live pass before any promotion claim.
- The repair tightened one known `ArrayList` contradiction, but other source-backed collection edge cases may still surface on later P21 slices.
