# 2026-04-14 Phase06 P23 Regular Candidate Scout

> Superseded note: this scout conclusion is now closed by [2026-04-14-phase06-p23-regular-freeze-review.md](/volume/wzhang/cky-workspace/my_projects/Cangjie/docs/reports/2026-04-14-phase06-p23-regular-freeze-review.md). The post-P22 scout/freeze review finished with `direct P23 mechanical-ready = No`, and `raw_docs/phase06-ui-p23` together with `docs/manifests/phase06_ui_*_p23*.json` plus `artifacts/ui_pilots/20260414-phase06-ui-p23-*` must be treated as exploratory evidence only rather than live input or promoted/mechanical-ready basis.

## Goal

Determine whether the remaining post-P22 official reserve can still produce one bounded, official-only, same-package regular trio beyond the formal `P22 / 311/311 live passed` checkpoint, without reopening the draft lane, the public `cangjiechallenge` pool, register-level manual selection, or the exception rail.

## Formal Status Guardrail

- The formal regular checkpoint remains `P22 / 311/311 live passed`.
- This scout step does not start any P23 live curator, does not refresh `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21*.json`, and does not refresh `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r17.json`.
- The current SSOT remains the promoted `P22 / 311/311 live passed` closure evidenced by `docs/reports/2026-04-14-phase06-p22-regular-promotion.md`, `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.json`, `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.validation.json`, and `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r17.json`.
- This turn begins with candidate scout only; P23 becomes mechanical-ready only if the selected trio can be frozen into a clean repo-local closure after this scout.

## Inputs

- `AGENTS.md`
- `/.claude/status/current-phase.md`
- `docs/reports/2026-04-14-phase06-post-p22-official-reserve-decision-review.md`
- `docs/reports/2026-04-14-phase06-p22-regular-promotion.md`
- `docs/manifests/phase06_ui_p0_file_manifest.json` through `docs/manifests/phase06_ui_p22_file_manifest.json`
- `docs/manifests/phase06_ui_sample_manifest.json`
- `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.json`
- `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.validation.json`
- `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r17.json`
- `/tmp/phase06-source-scout/HarmonyOS-Examples`

## Scout Root / Source Freeze

- `HarmonyOS-Examples`
  - url: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git`
  - branch: `main`
  - commit: `f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - access_date: `2026-04-14`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - purpose: `Pinned official reserve root for the post-P22 bounded scout over the residual BankUI, DateSelection, and RouletteUI candidate hypotheses.`

## Exclusion Baseline

1. Treat `docs/manifests/phase06_ui_p0_file_manifest.json` through `docs/manifests/phase06_ui_p22_file_manifest.json` as the consumed-slice baseline for the formal regular lane.
2. Use `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.json` plus `artifacts/ui_pilots/20260414-phase06-ui-regular-expansion-audit-r21.validation.json` to confirm the formal promoted regular lane already covers `72` promoted regular samples with a valid aggregate audit.
3. Use `artifacts/ui_pilots/20260414-phase06-ui-live-pass-coverage-r17.json` to confirm the promoted regular lane already holds `311/311` live-passed slices through `P22`.
4. Explicitly exclude every official `source_path` already present in the P0..P22 file manifests and do not reopen the draft lane, the public `cangjiechallenge` pool, register-level manual selection, or the exception rail.
5. The exclusion baseline now covers `307` consumed official slices, collapsing to `282` unique official source paths across `52` official regular sample ids.

## Method

1. Reconfirmed from the hot SSOT and the post-P22 decision review that any later regular expansion must stay inside the remaining official reserve beyond the promoted P22 lane.
2. Scoped this scout narrowly to the three residual hypotheses already called out for quality-first follow-up: `BankUI home`, `DateSelection CalendarPage`, and `RouletteUI home`.
3. For each hypothesis, enumerated the minimum same-package closure needed to keep UI entry/body/helper/model semantics source-backed while avoiding already consumed source paths.
4. Rejected any candidate that still required network-secret, socket, FFI, hybrid-host, or cross-feature home-shell expansion.
5. Promoted `RouletteUI home` from a raw `Home.cj` hypothesis to a more defensible `home-tab workflow` closure by including the unconsumed `index.cj` and `model/tabItemData.cj`, so the sample keeps a real `@Entry` host page instead of forcing a non-entry leaf component to stand alone.

## Evidence Commands

- Count current official consumed baseline:
  - `python3 - <<'PY' ... walk docs/manifests/phase06_ui_p*_file_manifest.json and count only HarmonyOS-Examples / HarmonyOS-Cangjie-Cases slices ... PY`
  - result: `consumed_official_slice_count=307`, `consumed_official_unique_source_path_count=282`, `consumed_official_sample_count=52`
- List candidate freeze sets:
  - `python3 - <<'PY' ... print bank/date/roulette selected source_paths ... PY`
  - result: `bank=10`, `date=4`, `roulette=9`
- Confirm selected paths do not overlap the promoted baseline:
  - `python3 - <<'PY' ... compare selected source_paths against docs/manifests/phase06_ui_sample_manifest.json ... PY`
  - result: `bank overlap_count=0`, `date overlap_count=0`, `roulette overlap_count=0`
- Candidate risk scan:
  - `rg -n --glob '*.cj' --glob 'cjpm.toml' --glob 'oh-package.json5' --glob 'build-profile.json5' "net\.http|Authorization|std\.socket|mindspore|hybrid|ffi" <selected candidate files>; echo candidate_risk_scan_exit:$?`
  - result: `candidate_risk_scan_exit:1`, meaning no risk-keyword hits across the selected freeze files

## Selected Regular Candidates

- `harmonyos-examples-bankui-home-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `BankUI/entry/src/main/cangjie/src/Page/home.cj`, the eight direct same-package `Component/home*.cj` helpers, and `Model/homeDataModel.cj` (`freeze_file_count=10`)
  - tags: `page-shell` + `controller-owned-state` + `deveco-import+manual-ui-smoke`
  - reason: keeps the BankUI home page, top-bar routing affordances, and local banner/entrance/news/recommend data source in one bounded closure without reopening the already promoted search slice. Route strings to `Search`, `Login`, and `MyView` stay link-level only and do not require target-page reopen.
- `harmonyos-examples-date-selection-calendar-page`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `14-DateSelection/entry/src/main/cangjie/pages/CalendarPage.cj` plus the same-package `model/{DayDataType,GetDate,MonthDataType}.cj` closure (`freeze_file_count=4`)
  - tags: `page-shell` + `controller-owned-state` + `deveco-import+manual-ui-smoke`
  - reason: keeps the date-selection calendar page and its local day/month/date helpers source-backed in a compact closure with no network, socket, hybrid, or native-runtime pressure. The return handoff to `MainPage` remains route-level only and does not reopen the already promoted `MainPage` file.
- `harmonyos-examples-roulette-ui-home-tab-workflow`
  - source: `https://gitcode.com/Cangjie/HarmonyOS-Examples.git @ main / f29257acc564b5daedaba4c32b0f9530b3fc0c31`
  - local clone path: `/tmp/phase06-source-scout/HarmonyOS-Examples`
  - freeze set: `RouletteUI/entry/src/main/cangjie/src/index.cj`, `model/tabItemData.cj`, the same-package `page/home/{Home,global,homeBody,homeTop,turntable}.cj` subtree, `model/circleModel.cj`, and `util/circleUtil.cj` (`freeze_file_count=9`)
  - tags: `page-shell` + `controller-owned-state` + `deveco-import+manual-ui-smoke`
  - reason: this tighter `home-tab workflow` keeps a real entry page, local tab-model wiring, the home-page subtree, and the local turntable drawing helpers together without reopening the already promoted `PublicPage` files. The remaining `Router.push("PublicPage")` call stays a downstream route handoff to an already promoted workflow rather than a new closure dependency.

## Deferred / Excluded Findings

- `06-AIChatLite`
  - deferred because the residual lane still carries `net.http` plus bearer-token semantics under `utils/llm.cj`.
- `News`
  - deferred because the repo couples UI with `net.http` and `mysqlclient_ffi` server/FFI layers.
- `TCPChat`
  - deferred because the client/server lane depends on `std.socket`.
- `AIClassify`
  - deferred because the entry lane still depends on MindSpore/native runtime linkage.
- `WebviewMix`
  - deferred because the residual page set is coupled to `ohos.net.http` API files.
- `ArkTSCangjieHybridApp`
  - excluded because it belongs to the hybrid rail, not the regular official-reserve lane.
- Residual `02-UIComponent` pages beyond the promoted P22 closure
  - de-prioritized because they mostly reopen already covered component-gallery/text-playground surfaces rather than creating a cleaner new trio.

## Results

- `artifacts/ui_pilots/20260414-phase06-ui-official-p23-regular-scout.json`
  - result: `decision=prepare-p23-regular-freeze`; the selected trio freezes `10 + 4 + 9 = 23` files and stays outside the official P0..P22 consumed-path baseline.
- `docs/reports/2026-04-14-phase06-p23-regular-candidate-scout.md`
  - result: records the post-P22 scout guardrail, the pinned official source root, the exact exclusion baseline, the selected trio, and the explicit statement that the formal checkpoint remains `P22 / 311/311 live passed`.

## Decision

- A defensible post-P22 official-only trio exists: `BankUI home page`, `DateSelection calendar page`, and `RouletteUI home-tab workflow`.
- The formal checkpoint remains `P22 / 311/311 live passed`; this scout step does not refresh aggregate audit, live-pass coverage, or promoted SSOT.
- This scout-only conclusion is superseded by `docs/reports/2026-04-14-phase06-p23-regular-freeze-review.md`, which records the completed post-P22 scout/freeze review as `direct P23 mechanical-ready = No`; the P23 raw_docs/manifests/artifacts remain exploratory evidence only and must not be used as live input or promoted/mechanical-ready basis.
