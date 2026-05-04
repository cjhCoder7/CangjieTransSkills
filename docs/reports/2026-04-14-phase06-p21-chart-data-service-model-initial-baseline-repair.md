# 2026-04-14 Phase06 P21 Chart Data Service Model Initial-Baseline Repair

## Goal

Clear the decisive entity blocker `phase06-ui-p21-stock-chart-chart-data-service-model` with a targeted non-mock replay, without reopening aggregate audit, live-pass coverage, or a fresh full P21 live `r3`.

## Inputs

- `docs/reports/2026-04-14-phase06-p21-live-curator-r2-failure-attribution.md`
- `artifacts/ui_pilots/20260414-phase06-ui-p21-repair-check-chart-data-service-model-r1/orchestration.json`
- `raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/services/ChartDataService.cj`
- `scripts/orchestrator.py`
- `tests/test_orchestrator.py`

## Code Repair

- Added an initial deterministic source-backed native `.cj` baseline lane to `scripts/orchestrator.py` for Phase06 UI targets on round 1 when no repair guidance or seed anchor is active.
- The new lane emits the full source file before translator drift can delete source-backed generic helper heads or `ArrayList<T>` contracts.
- The lane keeps the existing large-source special lane and reviewer-only alignment-repair fallback intact, and it allows later repair rounds if the initial baseline itself fails verify.
- Added/updated `tests/test_orchestrator.py` regressions so:
  - small source-backed native `.cj` targets bypass translator/reviewer on round 1,
  - large-source special-lane behavior still holds,
  - alignment-repair fallback still promotes correctly when translator drift is intentionally reintroduced via a seed anchor,
  - the source-equivalent bypass assertion matches the new initial-baseline reason.

## Verification

- `python3 -m py_compile scripts/orchestrator.py tests/test_orchestrator.py`
  - result: passed
- `python3 -m unittest discover -s tests -p 'test_*.py' -v`
  - result: passed (`289` tests)
- Controlled-shell targeted non-mock replay:
  - command: `export REPO_ROOT=... && export CANGJIE_HOME=... && export PATH=... && export LD_LIBRARY_PATH=... && export CANGJIE_STDLIB_PATH=... && set -a && source "$REPO_ROOT/.env.local" >/dev/null 2>&1 || true && set +a && python3 scripts/orchestrator.py --tu-json artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/phase06-ui-p21-stock-chart-chart-data-service-model/target.explicit_ui_tags.tu.json --architecture-skill docs/strategy/phase-06-ui-sample-taxonomy-and-prompt-constraints.md --pattern-limit 0 --workspace-root artifacts/ui_pilots/20260414-phase06-ui-p21-repair-check-chart-data-service-model-r2/temp_workspace --model Pro/zai-org/GLM-5 --timeout-seconds 600 --llm-max-retries 2 --max-rounds 2 --output artifacts/ui_pilots/20260414-phase06-ui-p21-repair-check-chart-data-service-model-r2/orchestration.json`
  - result: passed, `round_count=1`, `mock_mode=false`
  - key artifacts:
    - `artifacts/ui_pilots/20260414-phase06-ui-p21-repair-check-chart-data-service-model-r2/orchestration.json`
    - `artifacts/ui_pilots/20260414-phase06-ui-p21-repair-check-chart-data-service-model-r2/temp_workspace/20260414T010822Z-tu-phase06-ui-p21-batch1-phase06-ui-p21-stock-chart-chart-data-service-model-ser/attempt-01/translation_artifact.json`
    - `artifacts/ui_pilots/20260414-phase06-ui-p21-repair-check-chart-data-service-model-r2/temp_workspace/20260414T010822Z-tu-phase06-ui-p21-batch1-phase06-ui-p21-stock-chart-chart-data-service-model-ser/attempt-01/review_result.json`
    - `artifacts/ui_pilots/20260414-phase06-ui-p21-repair-check-chart-data-service-model-r2/temp_workspace/20260414T010822Z-tu-phase06-ui-p21-batch1-phase06-ui-p21-stock-chart-chart-data-service-model-ser/attempt-01/verify_result.json`

## Outcome

- `phase06-ui-p21-stock-chart-chart-data-service-model` is no longer blocked.
- The replay closed with reviewer bypass + verify passed on round 1 by emitting the exact source-backed `ChartDataService.cj` baseline, preserving:
  - `import std.collection.ArrayList`
  - `private func loadAndParseData<T>(...)`
  - source-backed `ArrayList<T>` return contracts
- The formal Phase06 checkpoint remains `P20 / 220/220 live passed`.
- The next allowed move is now the targeted non-mock replay for `phase06-ui-p21-stock-chart-style-extensions-helper`; a fresh full P21 live `r3`, aggregate audit refresh, and live-pass coverage refresh remain forbidden until that blocker also records reviewer passed + verify passed.
