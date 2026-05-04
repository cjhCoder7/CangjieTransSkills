# 2026-04-14 Phase06 P21 Live Curator R2 Failure Attribution

## Goal

Record the second controlled-shell P21 non-mock live curator attempt as a partial, non-promoted failure-attribution lane, then freeze the exact entity-vs-infrastructure split before any fresh `r3`, aggregate audit refresh, or live-pass coverage refresh.

## Formal Status Guardrail

- The formal regular checkpoint remains `P20 / 220/220 live passed`.
- The formal promoted regular sample count remains `66`.
- `docs/manifests/phase06_ui_sample_manifest.json` still carries `ordered_samples=69`, but that remains a primary-register count rather than promoted coverage.
- `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.json`, `artifacts/ui_pilots/20260413-phase06-ui-regular-expansion-audit-r19.validation.json`, and `artifacts/ui_pilots/20260413-phase06-ui-live-pass-coverage-r15.json` must remain untouched by this partial live lane.

## Inputs

- `docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json`
- `docs/reports/2026-04-13-phase06-p21-live-curator-r1-failure-attribution.md`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-chart-data-service-model/{summary.json,orchestration.json,run.log}`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-style-extensions-helper/{summary.json,orchestration.json,run.log}`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-chart-dimensions-model/{summary.json,orchestration.json,run.log}`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-data-constants-model/{summary.json,orchestration.json,run.log}`
- `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-waterfall-entry-page/{orchestration.json,run.log}`
- `raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/services/ChartDataService.cj`
- `raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/StyleExtensions.cj`
- `AGENTS.md`
- `/.claude/status/current-phase.md`

## Startup Command

- Controlled-shell wrapper invocation:
  - `export REPO_ROOT="/volume/wzhang/cky-workspace/my_projects/Cangjie" && export CANGJIE_HOME="$REPO_ROOT/artifacts/toolchains/cangjie-sdk-linux-x64-6.1.0.818-unzip/cangjie" && export PATH="$CANGJIE_HOME/build-tools/bin:$CANGJIE_HOME/build-tools/tools/bin:$CANGJIE_HOME/build-tools/third_party/llvm/bin:$PATH" && export LD_LIBRARY_PATH="$CANGJIE_HOME/build-tools/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/build-tools/third_party/llvm/lib:${LD_LIBRARY_PATH:-}" && export CANGJIE_STDLIB_PATH="$CANGJIE_HOME/build-tools/modules/linux_x86_64_cjnative/std" && set -a && source "$REPO_ROOT/.env.local" >/dev/null 2>&1 || true && set +a && python3 scripts/run_phase06_ui_prompt_pilot_batch.py --manifest docs/manifests/phase06_ui_prompt_pilot_p21_batch1.json --run-label 20260413-phase06-ui-p21-batch1-live-curator-r2 --max-rounds 2 --timeout-seconds 600 --llm-max-retries 2 --pattern-limit 0`
  - result: the live root was created and 50 slice directories landed, but the executor stopped the batch after the decisive failures were already attributable. The shell exited through `KeyboardInterrupt`, so the batch never reached normal closeout.

## Partial Results

- Live root:
  - `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/`
  - result: exists with `50` slice directories.
- Top-level batch report:
  - `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/batch-report.json`
  - result: missing, because the batch was manually interrupted by `KeyboardInterrupt` before the wrapper emitted closeout artifacts.
- Read-only batch census over the live root plus the prompt manifest:
  - result: `50 dir / 49 summary / 45 passed / 2 failed / 2 infrastructure-error / 1 interrupted / 6 unstarted`
  - interpretation:
    - `45 passed`: completed slices with `final_status=passed`
    - `2 failed`: decisive entity blockers
    - `2 infrastructure-error`: completed infra-only misses with `summary.json`
    - `1 interrupted`: `phase06-ui-p21-waterfall-entry-page`, which emitted `run.log` + `orchestration.json` but no `summary.json`
    - `6 unstarted`: manifest entries with no slice directory under the live root

## Failure Attribution

### Decisive Entity Blockers

- `phase06-ui-p21-stock-chart-chart-data-service-model`
  - summary: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-chart-data-service-model/summary.json`
  - orchestration: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-chart-data-service-model/orchestration.json`
  - log: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-chart-data-service-model/run.log`
  - result: `final_status=failed`, `verify_status=blocked`, `round_count=2`
  - decisive reason: the candidate degraded source-backed generic helper facts into untyped `Option` / `ArrayList` / `ArrayList()`, which then hit the static blacklist before the slice could reach reviewer/compiler.

- `phase06-ui-p21-stock-chart-style-extensions-helper`
  - summary: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-style-extensions-helper/summary.json`
  - orchestration: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-style-extensions-helper/orchestration.json`
  - log: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-style-extensions-helper/run.log`
  - result: `final_status=failed`, `verify_status=passed`, `round_count=2`
  - decisive reason: the repair step fixed postfix `!` but drifted a same-file helper invocation from `drawLine` to `DrawLine`, producing a case-sensitive source-alignment rupture rather than an infrastructure miss.

### Infra-Only Misses

- `phase06-ui-p21-stock-chart-chart-dimensions-model`
  - summary: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-chart-dimensions-model/summary.json`
  - log: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-chart-dimensions-model/run.log`
  - result: `final_status=infrastructure-error`
  - attribution: translator returned empty candidate code.

- `phase06-ui-p21-stock-chart-data-constants-model`
  - summary: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-data-constants-model/summary.json`
  - log: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-stock-chart-data-constants-model/run.log`
  - result: `final_status=infrastructure-error`
  - attribution: translator returned empty candidate code.

### Interrupted Infrastructure Slice

- `phase06-ui-p21-waterfall-entry-page`
  - orchestration: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-waterfall-entry-page/orchestration.json`
  - log: `artifacts/ui_pilots/20260413-phase06-ui-p21-pilot-batch1/live_curator/20260413-phase06-ui-p21-batch1-live-curator-r2/phase06-ui-p21-waterfall-entry-page/run.log`
  - result: no `summary.json` was emitted; the run log closes with `API failure -> infrastructure failure: Streaming interrupted by KeyboardInterrupt`
  - classification guardrail: this slice belongs to the infrastructure lane. `phase06-ui-p21-waterfall-entry-page` must **not** be counted as an entity failure.

### Unstarted Residual Slices

- `phase06-ui-p21-waterfall-cover-card-component`
- `phase06-ui-p21-waterfall-water-column-component`
- `phase06-ui-p21-waterfall-media-model`
- `phase06-ui-p21-waterfall-event-bus-model`
- `phase06-ui-p21-waterfall-mock-data-model`
- `phase06-ui-p21-waterfall-data-source-model`

## Decision

- The P21 `r2` live lane is a partial failure-attribution-only run.
- The decisive entity blockers are exactly:
  - `phase06-ui-p21-stock-chart-chart-data-service-model`
  - `phase06-ui-p21-stock-chart-style-extensions-helper`
- The infra-only misses are exactly:
  - `phase06-ui-p21-stock-chart-chart-dimensions-model`
  - `phase06-ui-p21-stock-chart-data-constants-model`
- `phase06-ui-p21-waterfall-entry-page` is a `KeyboardInterrupt`-caused infrastructure interruption and must not be narrated as an entity blocker.
- Do not refresh aggregate audit or live-pass coverage from this lane.
- The next allowed move is not `r3` by default; first close the two decisive entity blockers with targeted repair + targeted non-mock replay, then decide whether a fresh full `P21` live `r3` is warranted.
