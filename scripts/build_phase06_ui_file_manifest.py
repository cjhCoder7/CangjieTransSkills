#!/usr/bin/env python3
"""Build a file-level Phase06 UI manifest from a frozen Phase06 source corpus."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any, Dict, List


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE_CORPUS_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_source_corpus_p0.json"
DEFAULT_SAMPLE_MANIFEST_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_sample_manifest.json"
DEFAULT_FEW_SHOT_PACK_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_few_shot_pack.json"
DEFAULT_OUTPUT_PATH = PROJECT_ROOT / "docs" / "manifests" / "phase06_ui_p0_file_manifest.json"



def manifest_name_to_filename(manifest_name: str) -> str:
    value = manifest_name.strip()
    if not value:
        return "phase06_ui_source_corpus.json"
    return value.replace("-", "_") + ".json"


def derive_file_manifest_name(source_corpus_manifest_name: str) -> str:
    value = source_corpus_manifest_name.strip() or "phase06-ui-source-corpus"
    marker = "-source-corpus"
    if marker in value:
        return value.replace(marker, "", 1) + "-file-manifest"
    return f"{value}-file-manifest"


FILE_SLICE_OVERRIDES: Dict[str, Dict[str, Any]] = {
    "raw_docs/phase06-ui-p0/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/badgeSample.cj": {
        "slice_id": "phase06-ui-p0-badgeview-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Direct page-shell seed for @State/@Link propagation, nested badge components, and grid/list composition.",
        "notes": [
            "Single entry file that already contains nested child components.",
            "Treat as a direct page-shell pilot instead of splitting child badges into standalone slices.",
        ],
    },
    "raw_docs/phase06-ui-p0/HarmonyOS-Examples/15-Ledger/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p0-ledger-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Primary page-shell orchestration slice for builder-layered ledger dashboard composition.",
        "notes": [
            "Keep page-shell responsibilities here; supporting components are sliced separately.",
        ],
    },
    "raw_docs/phase06-ui-p0/HarmonyOS-Examples/15-Ledger/entry/src/main/cangjie/ui/top_bar.cj": {
        "slice_id": "phase06-ui-p0-ledger-top-bar-component",
        "target_role": "component",
        "slice_kind": "support-component",
        "structure_tag": "rich-component",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Reusable header/title component extracted from a page-shell sample.",
        "notes": [
            "Refines the sample-level page-shell tag into a file-level rich-component slice.",
        ],
    },
    "raw_docs/phase06-ui-p0/HarmonyOS-Examples/15-Ledger/entry/src/main/cangjie/ui/details_list.cj": {
        "slice_id": "phase06-ui-p0-ledger-details-list-component",
        "target_role": "component",
        "slice_kind": "support-component",
        "structure_tag": "rich-component",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Reusable list/detail component slice from the ledger page decomposition sample.",
        "notes": [
            "Refines the sample-level page-shell tag into a file-level rich-component slice.",
        ],
    },
    "raw_docs/phase06-ui-p0/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/modalwindow/src/main/cangjie/src/ModalWindowView.cj": {
        "slice_id": "phase06-ui-p0-modal-window-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": ["mixed-app-pattern"],
        "usage_goal": "Entry page slice for modal presentation, builder layering, and page-owned visibility state.",
        "notes": [
            "Mixed-app pattern stays tagged at file level because builder/modal behavior lives in this page file.",
        ],
    },
    "raw_docs/phase06-ui-p0/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/customtabbar/src/main/cangjie/src/view/CustomTabBarPage.cj": {
        "slice_id": "phase06-ui-p0-custom-tab-bar-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": ["mixed-app-pattern"],
        "usage_goal": "Entry page slice for controller-owned tab state, @Provide/@Link propagation, and custom tab/page boundaries.",
        "notes": [
            "Nested supporting components stay inline in the same file; keep the page/controller boundary as the primary contract.",
        ],
    },
    "raw_docs/phase06-ui-p0/markdown4cj/entry/src/main/cangjie/src/index_page.cj": {
        "slice_id": "phase06-ui-p0-markdown-index-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Host page slice for markdown component composition without absorbing parser/config ownership into the page contract.",
        "notes": [
            "Refines the sample-level rich-component seed into a page-shell host slice.",
        ],
    },
    "raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src/components/markdown_heading_component.cj": {
        "slice_id": "phase06-ui-p0-markdown-heading-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Primary rich-component slice for heading rendering, configuration-driven layout, and component-local display state.",
        "notes": [
            "Keep parsing/config truth outside the component boundary.",
        ],
    },
    "raw_docs/phase06-ui-p0/markdown4cj/markdown/src/main/cangjie/src/components/markdown_table_block_component.cj": {
        "slice_id": "phase06-ui-p0-markdown-table-block-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Primary rich-component slice for table rendering and refreshable component state.",
        "notes": [
            "Pairs with markdown heading component as the second rich-component anchor from markdown4cj.",
        ],
    },
    "raw_docs/phase06-ui-p0/photoview4cj/entry/src/main/cangjie/simple_sample.cj": {
        "slice_id": "phase06-ui-p0-photoview-simple-sample-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": ["gesture-component"],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Gesture demo page slice wiring PhotoViewModel, listener callbacks, and page-owned hosting state.",
        "notes": [
            "Refines the sample-level gesture component seed into a page-shell host slice.",
        ],
    },
    "raw_docs/phase06-ui-p0/photoview4cj/photoView/src/main/cangjie/photo_view.cj": {
        "slice_id": "phase06-ui-p0-photo-view-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": ["gesture-component"],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Primary gesture component slice for transform state, zoom control, and callback-driven view updates.",
        "notes": [
            "This is the direct component anchor for gesture-heavy Phase06 targets.",
        ],
    },
    "raw_docs/phase06-ui-p0/photoview4cj/photoView/src/main/cangjie/photo_view_model.cj": {
        "slice_id": "phase06-ui-p0-photo-view-model",
        "target_role": "viewmodel",
        "slice_kind": "support-model",
        "structure_tag": "rich-component",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": ["gesture-component"],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Supporting model slice for transform state ownership, image source wiring, and gesture-facing controller state.",
        "notes": [
            "Not a direct UI component; keep it as a supporting model slice attached to the gesture-component lane.",
        ],
    },
    "raw_docs/phase06-ui-p1/svg4cj/svg/src/main/cangjie/src/svg_image_view.cj": {
        "slice_id": "phase06-ui-p1-svg-image-view-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Primary renderer/component slice for SVGImageView plus the embedded observed model contract that drives render state.",
        "notes": [
            "The same file contains both SVGImageView and SVGImageViewModel; keep the render-facing component boundary as the primary slice.",
        ],
    },
    "raw_docs/phase06-ui-p1/svg4cj/entry/src/main/cangjie/src/render_merman.cj": {
        "slice_id": "phase06-ui-p1-svg-render-merman-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Entry page slice hosting SVGImageView and page-owned model state for renderer-backed asset display.",
        "notes": [
            "Use this file as the page-shell host; renderer internals stay in the paired component slice.",
        ],
    },
    "raw_docs/phase06-ui-p1/editor4cj/entry/src/main/cangjie/src/editor_kit/editorText.cj": {
        "slice_id": "phase06-ui-p1-editor-kit-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Primary editor component slice covering controller binding, layout measurement, and large rich-text editing state.",
        "notes": [
            "Controller and component live in one file; keep the direct EditorKit component contract as the slice boundary.",
        ],
    },
    "raw_docs/phase06-ui-p1/editor4cj/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p1-editor-kit-host-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Entry page slice that wires EditorKitController into a host page without pulling editor internals into the page contract.",
        "notes": [
            "Algorithm demo helpers remain incidental noise; the page-shell to controller handoff is the contract to keep.",
        ],
    },
    "raw_docs/phase06-ui-p1/HttpNewsApp-Cangjie/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p1-httpnews-index-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": ["mixed-app-pattern"],
        "usage_goal": "Integrated client page slice for list/search/swiper composition, Router navigation, and page-owned HTTP-backed state.",
        "notes": [
            "Keep the mixed-app-pattern tag because routing, async loading, and page composition all live in this file.",
        ],
    },
    "raw_docs/phase06-ui-p1/HttpNewsApp-Cangjie/entry/src/main/cangjie/src/news.cj": {
        "slice_id": "phase06-ui-p1-httpnews-news-model",
        "target_role": "viewmodel",
        "slice_kind": "support-model",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": ["mixed-app-pattern"],
        "usage_goal": "Supporting model slice for News DTOs and NewsManager request/state ownership behind the integrated client pages.",
        "notes": [
            "No @Entry or @Component lives here; keep it attached to the integrated page-shell lane as a support-model slice.",
        ],
    },
    "raw_docs/phase06-ui-p1/HttpNewsApp-Cangjie/entry/src/main/cangjie/src/news_detail.cj": {
        "slice_id": "phase06-ui-p1-httpnews-detail-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": ["mixed-app-pattern"],
        "usage_goal": "Detail page slice for Router param handoff, async detail loading, and page-local news presentation state.",
        "notes": [
            "Use as the detail-page companion to the integrated index page instead of absorbing NewsManager logic into the page slice.",
        ],
    },
    "raw_docs/phase06-ui-p1/titlebar4cj/titlebar/src/titlebar.cj": {
        "slice_id": "phase06-ui-p1-title-bar-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Primary reusable title bar component slice for @Link-driven model rendering and builder-composed slot layout.",
        "notes": [
            "Treat this as the narrow reusable widget anchor; hosting page concerns stay in the paired entry page.",
        ],
    },
    "raw_docs/phase06-ui-p1/titlebar4cj/entry/src/main/cangjie/index_page.cj": {
        "slice_id": "phase06-ui-p1-title-bar-index-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Entry page slice that hosts TitleBarModel state and composes the narrow reusable title bar component.",
        "notes": [
            "Keep the page-shell host separate from the reusable widget so later pilots can target either boundary independently.",
        ],
    },
    "raw_docs/phase06-ui-exception/avif-ffi/entry/src/main/cangjie/example2.cj": {
        "slice_id": "phase06-ui-exception-avif-example-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": ["ffi-exception"],
        "sample_scope_tags": [],
        "usage_goal": "Exception-track page slice for resource-backed AVIF loading and AvifImage host composition without leaking native decoder details into the page shell.",
        "notes": [
            "Keep raw-file loading and lifecycle state in the host page; decoder and PixelMap lifecycle stay behind the avif4cj boundary.",
        ],
    },
    "raw_docs/phase06-ui-exception/avif-ffi/avif4cj/src/main/cangjie/avif_decoder.cj": {
        "slice_id": "phase06-ui-exception-avif-decoder-adapter",
        "target_role": "viewmodel",
        "slice_kind": "support-model",
        "structure_tag": "rich-component",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": ["ffi-exception"],
        "sample_scope_tags": [],
        "usage_goal": "Exception-track adapter slice for AVIF decoder lifecycle, PixelMap conversion, and FFI resource ownership behind a UI-facing image component.",
        "notes": [
            "Treat this as a private native-boundary support slice rather than a reusable UI contract.",
        ],
    },
    "raw_docs/phase06-ui-exception/svga-cj/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-exception-svga-hybrid-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": ["hybrid-exception"],
        "sample_scope_tags": [],
        "usage_goal": "Exception-track hybrid component slice for Cangjie-authored UI mounted through HybridComponentEntry without treating the ETS host as the default page pattern.",
        "notes": [
            "Keep the Cangjie component boundary explicit; do not collapse the CJ and ETS sides into one default prompt path.",
        ],
    },
    "raw_docs/phase06-ui-exception/svga-cj/entry/src/main/ets/pages/index.ets": {
        "slice_id": "phase06-ui-exception-svga-ets-host-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": ["hybrid-exception"],
        "sample_scope_tags": [],
        "usage_goal": "Exception-track ETS host page slice for CJHybridComponentV2 mounting and hybrid runtime handoff around the Cangjie component.",
        "notes": [
            "This host page belongs on the hybrid-exception rail and should not be learned as a normal Cangjie page-shell baseline.",
        ],
    },
    "raw_docs/phase06-ui-p2/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/LevelPage.cj": {
        "slice_id": "phase06-ui-p2-aiatom-level-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P2 page-shell slice for Grid-based level progression, Router handoff, and page-owned progress state without pulling WebView practice rails into the default prompt path.",
        "notes": [
            "Keep GameState-backed progress ownership at the page boundary.",
            "Exclude PrototypePage and SplashScreen from the regular rail because they introduce special interaction and hybrid concerns.",
        ],
    },
    "raw_docs/phase06-ui-p2/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/login_page.cj": {
        "slice_id": "phase06-ui-p2-xupt-sec1-login-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P2 login page slice for user-card selection, PIN entry, and page-local auth flow state managed inside a single page shell.",
        "notes": [
            "Treat the login success callback as an explicit page boundary instead of leaking downstream app state into the slice.",
        ],
    },
    "raw_docs/phase06-ui-p2/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/web_demo_page.cj": {
        "slice_id": "phase06-ui-p2-xupt-sec1-web-demo-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P2 display-oriented page slice for Scroll-based feature-card composition and builder-extracted repeated rendering with minimal state coupling.",
        "notes": [
            "Keep this as a narrow renderer-leaning page-shell example rather than promoting the repo's security workflow internals into the prompt rail.",
        ],
    },

    "raw_docs/phase06-ui-p3/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/HomePage.cj": {
        "slice_id": "phase06-ui-p3-aiatom-home-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P3 home dashboard page slice for progress-backed level composition, completion overlay state, and Router handoff from a single page shell.",
        "notes": [
            "Keep the splash-screen web bridge and study subpages outside this page-shell slice.",
            "Treat GameState as the controller-owned source of truth while the page mirrors only display and routing state.",
        ],
    },
    "raw_docs/phase06-ui-p3/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/ListenPage.cj": {
        "slice_id": "phase06-ui-p3-aiatom-listen-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P3 quiz page slice for timer-driven answer progression, speech-playback callbacks, and page-owned listening-practice state.",
        "notes": [
            "Keep text-to-speech service coordination inside the page boundary without inventing extra mediator layers.",
            "Treat question generation and answer feedback as page-shell state instead of leaking hidden controller facades into the prompt rail.",
        ],
    },
    "raw_docs/phase06-ui-p3/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/transcription_page.cj": {
        "slice_id": "phase06-ui-p3-secmeet-transcription-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P3 callback-driven transcription panel slice for recording controls, transcript display, and component-owned volatile workflow state.",
        "notes": [
            "Preserve the callback-style host integration instead of collapsing it into a page-shell or service-owned facade.",
            "Keep risk alert, transcript list, and recording status as component-local display state anchored to the existing builders.",
        ],
    },
    "raw_docs/phase06-ui-p4/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/PrototypePage.cj": {
        "slice_id": "phase06-ui-p4-aiatom-prototype-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P4 practice page slice for mode switching, input validation, and page-owned canvas host state without promoting web-bridge internals into the page contract.",
        "notes": [
            "Keep HanziWriterCanvas as a source-backed dependency instead of absorbing bridge details into the page shell.",
            "Treat mode toggle, status messaging, and character input as the page-owned state boundary.",
        ],
    },
    "raw_docs/phase06-ui-p4/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/meeting_list_page.cj": {
        "slice_id": "phase06-ui-p4-secmeet-meeting-list-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P4 list page slice for stats cards, filter/search state, and detail-page routing from a single controller-owned page shell.",
        "notes": [
            "Preserve the source-backed render helpers and list filtering flow without inventing ArkUI-only facades.",
            "Treat list refresh, search keyword, and route handoff as page-shell state rather than service-owned behavior.",
        ],
    },
    "raw_docs/phase06-ui-p4/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/audit_log_page.cj": {
        "slice_id": "phase06-ui-p4-secmeet-audit-log-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P4 audit-log page slice for analytics counters, filter state, and log-list rendering without leaking security-service internals into the public UI boundary.",
        "notes": [
            "Keep alert/log rendering semantics source-backed through the existing audit state object and render helpers.",
            "Treat statistics refresh and filter state as page-owned orchestration instead of fabricating provider layers.",
        ],
    },
    "raw_docs/phase06-ui-p4-draft/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/PrototypePage.cj": {
        "slice_id": "phase06-ui-p4-aiatom-prototype-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P4 practice page slice for mode switching, input validation, and page-owned canvas host state without promoting web-bridge internals into the page contract.",
        "notes": [
            "Keep HanziWriterCanvas as a source-backed dependency instead of absorbing bridge details into the page shell.",
            "Treat mode toggle, status messaging, and character input as the page-owned state boundary.",
        ],
    },
    "raw_docs/phase06-ui-p4-draft/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/meeting_list_page.cj": {
        "slice_id": "phase06-ui-p4-secmeet-meeting-list-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P4 list page slice for stats cards, filter/search state, and detail-page routing from a single controller-owned page shell.",
        "notes": [
            "Preserve the source-backed render helpers and list filtering flow without inventing ArkUI-only facades.",
            "Treat list refresh, search keyword, and route handoff as page-shell state rather than service-owned behavior.",
        ],
    },
    "raw_docs/phase06-ui-p4-draft/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/audit_log_page.cj": {
        "slice_id": "phase06-ui-p4-secmeet-audit-log-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P4 audit-log page slice for analytics counters, filter state, and log-list rendering without leaking security-service internals into the public UI boundary.",
        "notes": [
            "Keep alert/log rendering semantics source-backed through the existing audit state object and render helpers.",
            "Treat statistics refresh and filter state as page-owned orchestration instead of fabricating provider layers.",
        ],
    },

    "raw_docs/phase06-ui-p5/6a27783ce2bf2047bab996b3994d601d/MeetingAssistant/entry/src/main/cangjie/history.cj": {
        "slice_id": "phase06-ui-p5-makerizon-history-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P5 history page slice for search, quick filters, and meeting-list rendering from a self-contained page shell without inventing service facades.",
        "notes": [
            "Keep the source-backed hybrid-entry imports intact, but do not invent extra ETS or runtime bridge layers absent from this file.",
            "Treat activeFilter and searchText as the page-owned state boundary while the record card rendering stays local to the page shell.",
        ],
    },
    "raw_docs/phase06-ui-p5/6a27783ce2bf2047bab996b3994d601d/MeetingAssistant/entry/src/main/cangjie/mine.cj": {
        "slice_id": "phase06-ui-p5-makerizon-mine-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P5 profile/settings page slice for user-summary cards, grouped menu rows, and page-local display state inside a single shell.",
        "notes": [
            "Keep the source-backed hybrid-entry imports intact, but do not fabricate host-runtime adapters or extra provider layers.",
            "Treat the profile summary, stats cards, and grouped settings/help sections as one page-shell composition instead of splitting invented subpages.",
        ],
    },
    "raw_docs/phase06-ui-p5-draft/6a27783ce2bf2047bab996b3994d601d/MeetingAssistant/entry/src/main/cangjie/history.cj": {
        "slice_id": "phase06-ui-p5-makerizon-history-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P5 history page slice for search, quick filters, and meeting-list rendering from a self-contained page shell without inventing service facades.",
        "notes": [
            "Keep the source-backed hybrid-entry imports intact, but do not invent extra ETS or runtime bridge layers absent from this file.",
            "Treat activeFilter and searchText as the page-owned state boundary while the record card rendering stays local to the page shell.",
        ],
    },
    "raw_docs/phase06-ui-p5-draft/6a27783ce2bf2047bab996b3994d601d/MeetingAssistant/entry/src/main/cangjie/mine.cj": {
        "slice_id": "phase06-ui-p5-makerizon-mine-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P5 profile/settings page slice for user-summary cards, grouped menu rows, and page-local display state inside a single shell.",
        "notes": [
            "Keep the source-backed hybrid-entry imports intact, but do not fabricate host-runtime adapters or extra provider layers.",
            "Treat the profile summary, stats cards, and grouped settings/help sections as one page-shell composition instead of splitting invented subpages.",
        ],
    },

    "raw_docs/phase06-ui-p6/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/SpeakPage.cj": {
        "slice_id": "phase06-ui-p6-aiatom-speak-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P6 speak practice page slice for speech-recognition driven scoring, TTS prompts, and page-local quiz state without inventing extra controller facades.",
        "notes": [
            "Keep SpeechRecognizerService, TextToSpeechService, and GameState usage source-backed inside the page boundary.",
            "Treat recognizedText, scoreState, and currentIndex as page-owned workflow state rather than extracting invented view models.",
        ],
    },
    "raw_docs/phase06-ui-p6/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p6-aiatom-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P6 entry menu page slice for button-driven router handoff and minimal local state inside a lightweight page shell.",
        "notes": [
            "Keep the page as a lightweight menu shell; do not fabricate nested route coordinators or extra controller layers.",
            "Treat message text and button-triggered router pushes as the only page-owned state contract.",
        ],
    },
    "raw_docs/phase06-ui-p6/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p6-secmeet-app-shell-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": ["mixed-app-pattern"],
        "usage_goal": "P6 SecureMeet app-shell page slice for login gating, dashboard summary state, and meeting workflow orchestration inside one controller-owned boundary.",
        "notes": [
            "Keep the existing same-file login + main-app composition source-backed instead of splitting invented subpages.",
            "Treat authenticated app state, selectedMeetingId, and toast/loading workflow as the page-owned orchestration boundary.",
        ],
    },
    "raw_docs/phase06-ui-p6-draft/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/pages/SpeakPage.cj": {
        "slice_id": "phase06-ui-p6-aiatom-speak-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P6 speak practice page slice for speech-recognition driven scoring, TTS prompts, and page-local quiz state without inventing extra controller facades.",
        "notes": [
            "Keep SpeechRecognizerService, TextToSpeechService, and GameState usage source-backed inside the page boundary.",
            "Treat recognizedText, scoreState, and currentIndex as page-owned workflow state rather than extracting invented view models.",
        ],
    },
    "raw_docs/phase06-ui-p6-draft/bb40b887dcf53d1a8b72884ad862fdf9/cangjieApp/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p6-aiatom-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P6 entry menu page slice for button-driven router handoff and minimal local state inside a lightweight page shell.",
        "notes": [
            "Keep the page as a lightweight menu shell; do not fabricate nested route coordinators or extra controller layers.",
            "Treat message text and button-triggered router pushes as the only page-owned state contract.",
        ],
    },
    "raw_docs/phase06-ui-p6-draft/d45e5bcde569dadcaf4fcc0524ac8f38/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p6-secmeet-app-shell-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": ["mixed-app-pattern"],
        "usage_goal": "Draft P6 SecureMeet app-shell page slice for login gating, dashboard summary state, and meeting workflow orchestration inside one controller-owned boundary.",
        "notes": [
            "Keep the existing same-file login + main-app composition source-backed instead of splitting invented subpages.",
            "Treat authenticated app state, selectedMeetingId, and toast/loading workflow as the page-owned orchestration boundary.",
        ],
    },
    "raw_docs/phase06-ui-p7-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/textSample.cj": {
        "slice_id": "phase06-ui-p7-commonui-text-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P7 typography controls page slice for page-owned text, font size, and font-style state without inventing detached control layers.",
        "notes": [
            "Keep button and checkbox event wiring source-backed inside the page boundary.",
            "Treat text, fontSize, fontStyle, and fontWeight as direct render-facing page state."
        ],
    },
    "raw_docs/phase06-ui-p7-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/sliderSample.cj": {
        "slice_id": "phase06-ui-p7-commonui-slider-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P7 slider demo page slice for four slider values, orientation variants, and same-file value readback state.",
        "notes": [
            "Keep slider value ownership and onChange handlers in the page instead of inventing helper controllers.",
            "Treat horizontal and vertical slider variants as one direct page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p7-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/tabsSample.cj": {
        "slice_id": "phase06-ui-p7-commonui-tabs-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P7 vertical tabs page slice for same-file TabsController hosting and fixed tab-content boundaries inside one controller-owned page shell.",
        "notes": [
            "Keep TabsController and tab host structure source-backed instead of fabricating router or coordinator layers.",
            "Treat the vertical tab shell as the primary page contract; inline tab content stays in the same file."
        ],
    },
    "raw_docs/phase06-ui-p7/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/textSample.cj": {
        "slice_id": "phase06-ui-p7-commonui-text-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P7 typography controls page slice for page-owned text, font size, and font-style state without inventing detached control layers.",
        "notes": [
            "Keep button and checkbox event wiring source-backed inside the page boundary.",
            "Treat text, fontSize, fontStyle, and fontWeight as direct render-facing page state."
        ],
    },
    "raw_docs/phase06-ui-p7/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/sliderSample.cj": {
        "slice_id": "phase06-ui-p7-commonui-slider-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P7 slider demo page slice for four slider values, orientation variants, and same-file value readback state.",
        "notes": [
            "Keep slider value ownership and onChange handlers in the page instead of inventing helper controllers.",
            "Treat horizontal and vertical slider variants as one direct page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p7/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/tabsSample.cj": {
        "slice_id": "phase06-ui-p7-commonui-tabs-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P7 vertical tabs page slice for same-file TabsController hosting and fixed tab-content boundaries inside one controller-owned page shell.",
        "notes": [
            "Keep TabsController and tab host structure source-backed instead of fabricating router or coordinator layers.",
            "Treat the vertical tab shell as the primary page contract; inline tab content stays in the same file."
        ],
    },
    "raw_docs/phase06-ui-p8-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/buttonSample.cj": {
        "slice_id": "phase06-ui-p8-commonui-button-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P8 button demo page slice for same-file button composition, style extensions, and shape-based builder reuse without inventing detached helper layers.",
        "notes": [
            "Keep Text/Button extend helpers and buttonGroup builder source-backed inside the page boundary.",
            "Treat common/capsule/circle button presentation as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p8-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/checkBoxSample.cj": {
        "slice_id": "phase06-ui-p8-commonui-checkbox-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P8 checkbox demo page slice for grouped checkbox presentation and same-file onChange event wiring without introducing synthetic state holders.",
        "notes": [
            "Keep checkbox group membership, selected colors, and onChange logging source-backed inside the page boundary.",
            "Treat the dual-checkbox row as a narrow event-driven page-shell example rather than splitting invented child components."
        ],
    },
    "raw_docs/phase06-ui-p8-draft/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/addressexchange/src/main/cangjie/src/view/AddressExchangeView.cj": {
        "slice_id": "phase06-ui-p8-address-exchange-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P8 address exchange page slice for same-file swap animation, translate/rotate state, and toast-backed click affordances inside one page shell.",
        "notes": [
            "Keep rotateAngle, translateX, and swap as direct page-owned state instead of inventing controller facades.",
            "Preserve the source-backed animateTo and PromptAction usage rather than collapsing the page into a static card example."
        ],
    },
    "raw_docs/phase06-ui-p8/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/buttonSample.cj": {
        "slice_id": "phase06-ui-p8-commonui-button-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P8 button demo page slice for same-file button composition, style extensions, and shape-based builder reuse without inventing detached helper layers.",
        "notes": [
            "Keep Text/Button extend helpers and buttonGroup builder source-backed inside the page boundary.",
            "Treat common/capsule/circle button presentation as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p8/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/checkBoxSample.cj": {
        "slice_id": "phase06-ui-p8-commonui-checkbox-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P8 checkbox demo page slice for grouped checkbox presentation and same-file onChange event wiring without introducing synthetic state holders.",
        "notes": [
            "Keep checkbox group membership, selected colors, and onChange logging source-backed inside the page boundary.",
            "Treat the dual-checkbox row as a narrow event-driven page-shell example rather than splitting invented child components."
        ],
    },
    "raw_docs/phase06-ui-p8/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/addressexchange/src/main/cangjie/src/view/AddressExchangeView.cj": {
        "slice_id": "phase06-ui-p8-address-exchange-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P8 address exchange page slice for same-file swap animation, translate/rotate state, and toast-backed click affordances inside one page shell.",
        "notes": [
            "Keep rotateAngle, translateX, and swap as direct page-owned state instead of inventing controller facades.",
            "Preserve the source-backed animateTo and PromptAction usage rather than collapsing the page into a static card example."
        ],
    },
    "raw_docs/phase06-ui-p9-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/swiperSample.cj": {
        "slice_id": "phase06-ui-p9-commonui-swiper-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P9 swiper demo page slice for dual SwiperController ownership, autoplay variants, and same-file prev/next navigation inside one controller-owned page shell.",
        "notes": [
            "Keep SwiperController ownership and onChange callbacks source-backed inside the page boundary.",
            "Treat the dual vertical swiper sections as one controller-owned page-shell contract instead of fabricating carousel helpers."
        ],
    },
    "raw_docs/phase06-ui-p9-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/textInputSample.cj": {
        "slice_id": "phase06-ui-p9-commonui-text-input-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P9 text-input demo page slice for placeholder/caret styling and same-file @State echo without inventing detached form models.",
        "notes": [
            "Keep @State text and TextInput.onChange wiring source-backed inside the page boundary.",
            "Treat placeholder/font styling and echoed text as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p9-draft/HarmonyOS-Examples/01-HelloWord/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p9-helloword-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P9 hello-word entry page slice for display-derived typography, random rune generation, and Scroll/ForEach layout composition inside one page shell.",
        "notes": [
            "Keep random rune generation and display-width sizing source-backed instead of inventing providers or layout services.",
            "Treat the Scroll + Stack + ForEach composition as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p9/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/swiperSample.cj": {
        "slice_id": "phase06-ui-p9-commonui-swiper-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P9 swiper demo page slice for dual SwiperController ownership, autoplay variants, and same-file prev/next navigation inside one controller-owned page shell.",
        "notes": [
            "Keep SwiperController ownership and onChange callbacks source-backed inside the page boundary.",
            "Treat the dual vertical swiper sections as one controller-owned page-shell contract instead of fabricating carousel helpers."
        ],
    },
    "raw_docs/phase06-ui-p9/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/pages/textInputSample.cj": {
        "slice_id": "phase06-ui-p9-commonui-text-input-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P9 text-input demo page slice for placeholder/caret styling and same-file @State echo without inventing detached form models.",
        "notes": [
            "Keep @State text and TextInput.onChange wiring source-backed inside the page boundary.",
            "Treat placeholder/font styling and echoed text as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p9/HarmonyOS-Examples/01-HelloWord/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p9-helloword-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P9 hello-word entry page slice for display-derived typography, random rune generation, and Scroll/ForEach layout composition inside one page shell.",
        "notes": [
            "Keep random rune generation and display-width sizing source-backed instead of inventing providers or layout services.",
            "Treat the Scroll + Stack + ForEach composition as one direct render-facing page-shell contract."
        ],
    },

    "raw_docs/phase06-ui-p10-draft/HarmonyOS-Examples/Browser/entry/src/main/cangjie/src/about.cj": {
        "slice_id": "phase06-ui-p10-browser-about-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P10 browser about page slice for Router.back navigation, resource-backed branding, and simple two-column layout composition inside one render-facing page shell.",
        "notes": [
            "Keep Router.back wiring and resource-backed branding content source-backed inside the page boundary.",
            "Treat the back-row plus centered branding column as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p10-draft/HarmonyOS-Examples/Browser/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p10-browser-main-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P10 browser main page slice for WebviewController ownership, dark-mode script injection, search/url state, and same-file settings menu builders inside one controller-owned page shell.",
        "notes": [
            "Keep webviewController, darkmodeScript, Search.onSubmit flow, and builder menus source-backed inside the page boundary.",
            "Treat the browser shell as one controller-owned contract instead of fabricating services or detached menu layers."
        ],
    },
    "raw_docs/phase06-ui-p10-draft/HarmonyOS-Examples/18-WebViewGame/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p10-webviewgame-snake-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P10 webview game page slice for score state, JavaScript bridge callbacks, and same-file control builders inside one controller-owned page shell.",
        "notes": [
            "Keep webController ownership, JavaScript proxy registration, and score/game state source-backed inside the page boundary.",
            "Treat DirectionBtn, ControlBtn, and WebPlayground builders as one page-shell contract instead of splitting bridge wrappers."
        ],
    },
    "raw_docs/phase06-ui-p10/HarmonyOS-Examples/Browser/entry/src/main/cangjie/src/about.cj": {
        "slice_id": "phase06-ui-p10-browser-about-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P10 browser about page slice for Router.back navigation, resource-backed branding, and simple two-column layout composition inside one render-facing page shell.",
        "notes": [
            "Keep Router.back wiring and resource-backed branding content source-backed inside the page boundary.",
            "Treat the back-row plus centered branding column as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p10/HarmonyOS-Examples/Browser/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p10-browser-main-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P10 browser main page slice for WebviewController ownership, dark-mode script injection, search/url state, and same-file settings menu builders inside one controller-owned page shell.",
        "notes": [
            "Keep webviewController, darkmodeScript, Search.onSubmit flow, and builder menus source-backed inside the page boundary.",
            "Treat the browser shell as one controller-owned contract instead of fabricating services or detached menu layers."
        ],
    },
    "raw_docs/phase06-ui-p10/HarmonyOS-Examples/18-WebViewGame/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p10-webviewgame-snake-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P10 webview game page slice for score state, JavaScript bridge callbacks, and same-file control builders inside one controller-owned page shell.",
        "notes": [
            "Keep webController ownership, JavaScript proxy registration, and score/game state source-backed inside the page boundary.",
            "Treat DirectionBtn, ControlBtn, and WebPlayground builders as one page-shell contract instead of splitting bridge wrappers."
        ],
    },

    "raw_docs/phase06-ui-p11-draft/HarmonyOS-Examples/OPDSClient/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p11-opdsclient-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P11 OPDS client entry page slice for credential toggle state, inline style extensions, AppStorage handoff, and Router push flow inside one controller-owned page shell.",
        "notes": [
            "Keep verify/user/password/url state, inline style/password helpers, and Router/AppStorage flow source-backed inside the page boundary.",
            "Treat the login form shell as one controller-owned contract instead of inventing detached auth helpers or style wrappers."
        ],
    },
    "raw_docs/phase06-ui-p11-draft/HarmonyOS-Examples/ParticleEmission/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p11-particle-emission-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P11 particle emission page slice for canvas animation state, inspector-derived component coordinates, and TextTimer-driven particle updates inside one controller-owned page shell.",
        "notes": [
            "Keep CanvasRenderingContext2D ownership, TextTimer loop, and getInspectorByKey-derived particle spawning source-backed inside the page boundary.",
            "Treat the List plus Canvas overlay as one controller-owned page-shell contract instead of splitting animation services or geometry helpers."
        ],
    },
    "raw_docs/phase06-ui-p11-draft/HarmonyOS-Examples/14-DateSelection/entry/src/main/cangjie/pages/MainPage.cj": {
        "slice_id": "phase06-ui-p11-date-selection-main-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P11 date-selection main page slice for Router param hydration, TabsController ownership, and same-file booking builders inside one controller-owned page shell.",
        "notes": [
            "Keep Router.getParamsObject hydration, start/end date state, and builder-based reservation sections source-backed inside the page boundary.",
            "Treat the booking home shell as one controller-owned contract instead of extracting detached tab, booking, or calendar adapters."
        ],
    },
    "raw_docs/phase06-ui-p11/HarmonyOS-Examples/OPDSClient/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p11-opdsclient-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P11 OPDS client entry page slice for credential toggle state, inline style extensions, AppStorage handoff, and Router push flow inside one controller-owned page shell.",
        "notes": [
            "Keep verify/user/password/url state, inline style/password helpers, and Router/AppStorage flow source-backed inside the page boundary.",
            "Treat the login form shell as one controller-owned contract instead of inventing detached auth helpers or style wrappers."
        ],
    },
    "raw_docs/phase06-ui-p11/HarmonyOS-Examples/ParticleEmission/entry/src/main/cangjie/index.cj": {
        "slice_id": "phase06-ui-p11-particle-emission-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P11 particle emission page slice for canvas animation state, inspector-derived component coordinates, and TextTimer-driven particle updates inside one controller-owned page shell.",
        "notes": [
            "Keep CanvasRenderingContext2D ownership, TextTimer loop, and getInspectorByKey-derived particle spawning source-backed inside the page boundary.",
            "Treat the List plus Canvas overlay as one controller-owned page-shell contract instead of splitting animation services or geometry helpers."
        ],
    },
    "raw_docs/phase06-ui-p11/HarmonyOS-Examples/14-DateSelection/entry/src/main/cangjie/pages/MainPage.cj": {
        "slice_id": "phase06-ui-p11-date-selection-main-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P11 date-selection main page slice for Router param hydration, TabsController ownership, and same-file booking builders inside one controller-owned page shell.",
        "notes": [
            "Keep Router.getParamsObject hydration, start/end date state, and builder-based reservation sections source-backed inside the page boundary.",
            "Treat the booking home shell as one controller-owned contract instead of extracting detached tab, booking, or calendar adapters."
        ],
    },

    "raw_docs/phase06-ui-p12-draft/HarmonyOS-Examples/Silkui/entry/src/main/cangjie/src/pages/calendar.cj": {
        "slice_id": "phase06-ui-p12-silkui-calendar-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P12 Silkui calendar route page slice for button-driven Router.push handoff inside one lightweight render-facing page shell.",
        "notes": [
            "Keep the three Router.push targets and stacked button layout source-backed inside the page boundary.",
            "Treat this file as a direct route menu shell instead of inventing separate navigation coordinators or helper wrappers."
        ],
    },
    "raw_docs/phase06-ui-p12-draft/HarmonyOS-Examples/07-DeepSeek/entry/src/main/cangjie/src/pages/about_view.cj": {
        "slice_id": "phase06-ui-p12-deepseek-about-view-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P12 DeepSeek about page slice for Router param hydration, back navigation, and embedded Web rendering inside one render-facing page shell.",
        "notes": [
            "Keep Router.getParamsObject title/src hydration, Router.back wiring, and resource-backed icons source-backed inside the page boundary.",
            "Treat the header row plus Web content region as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p12-draft/HarmonyOS-Examples/ChargingUI/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p12-chargingui-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P12 charging host page slice for page-owned battery percentage, charging toggle state, and slider-driven component handoff inside one controller-owned page shell.",
        "notes": [
            "Keep power/isCharging state plus Slider and Toggle wiring source-backed in the page host.",
            "Treat ElectricQuantity as an explicitly frozen companion slice rather than collapsing the sample into a fake single-file page."
        ],
    },
    "raw_docs/phase06-ui-p12-draft/HarmonyOS-Examples/ChargingUI/entry/src/main/cangjie/src/electric_quantity.cj": {
        "slice_id": "phase06-ui-p12-chargingui-electric-quantity-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "Draft P12 battery indicator component slice for canvas-backed fill rendering, bubble animation, and charging-state visual logic inside one rich-component boundary.",
        "notes": [
            "Keep CanvasRenderingContext2D ownership, bubble animation loop, and gradient fill logic source-backed inside the component boundary.",
            "Refines the sample-level page-shell tag into an explicit rich-component slice instead of hiding the helper behind same-package pressure."
        ],
    },
    "raw_docs/phase06-ui-p12/HarmonyOS-Examples/Silkui/entry/src/main/cangjie/src/pages/calendar.cj": {
        "slice_id": "phase06-ui-p12-silkui-calendar-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P12 Silkui calendar route page slice for button-driven Router.push handoff inside one lightweight render-facing page shell.",
        "notes": [
            "Keep the three Router.push targets and stacked button layout source-backed inside the page boundary.",
            "Treat this file as a direct route menu shell instead of inventing separate navigation coordinators or helper wrappers."
        ],
    },
    "raw_docs/phase06-ui-p12/HarmonyOS-Examples/07-DeepSeek/entry/src/main/cangjie/src/pages/about_view.cj": {
        "slice_id": "phase06-ui-p12-deepseek-about-view-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "view-model-renderer",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P12 DeepSeek about page slice for Router param hydration, back navigation, and embedded Web rendering inside one render-facing page shell.",
        "notes": [
            "Keep Router.getParamsObject title/src hydration, Router.back wiring, and resource-backed icons source-backed inside the page boundary.",
            "Treat the header row plus Web content region as one direct render-facing page-shell contract."
        ],
    },
    "raw_docs/phase06-ui-p12/HarmonyOS-Examples/ChargingUI/entry/src/main/cangjie/src/index.cj": {
        "slice_id": "phase06-ui-p12-chargingui-entry-page",
        "target_role": "page",
        "slice_kind": "entry-page",
        "structure_tag": "page-shell",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P12 charging host page slice for page-owned battery percentage, charging toggle state, and slider-driven component handoff inside one controller-owned page shell.",
        "notes": [
            "Keep power/isCharging state plus Slider and Toggle wiring source-backed in the page host.",
            "Treat ElectricQuantity as an explicitly frozen companion slice rather than collapsing the sample into a fake single-file page."
        ],
    },
    "raw_docs/phase06-ui-p12/HarmonyOS-Examples/ChargingUI/entry/src/main/cangjie/src/electric_quantity.cj": {
        "slice_id": "phase06-ui-p12-chargingui-electric-quantity-component",
        "target_role": "component",
        "slice_kind": "primary-component",
        "structure_tag": "rich-component",
        "ownership_tag": "controller-owned-state",
        "interaction_tags": [],
        "exception_tags": [],
        "sample_scope_tags": [],
        "usage_goal": "P12 battery indicator component slice for canvas-backed fill rendering, bubble animation, and charging-state visual logic inside one rich-component boundary.",
        "notes": [
            "Keep CanvasRenderingContext2D ownership, bubble animation loop, and gradient fill logic source-backed inside the component boundary.",
            "Refines the sample-level page-shell tag into an explicit rich-component slice instead of hiding the helper behind same-package pressure."
        ],
    },
    'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p13-commonui-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'Draft P13 CommonUI entry page slice for extend-based button styling and direct Router.push handoff inside one render-facing page shell.',
        'notes': [
            'Keep the extend Button.jump helper and the eight Router.push targets source-backed inside the page boundary.',
            'Treat this file as a lightweight route menu shell instead of inventing detached coordinators or helper layers.',
        ],
    },
    'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/11-Clock/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p13-clock-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'Draft P13 clock host page slice for page-owned Timer lifecycle, Canvas context ownership, and display-size hydration around a renderer helper.',
        'notes': [
            'Keep Timer lifecycle, CanvasRenderingContext2D ownership, and display-size hydration source-backed in the page host.',
            'Treat utils/clock.cj as the explicitly frozen renderer helper instead of collapsing the sample into a fake single-file canvas page.',
        ],
    },
    'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/11-Clock/entry/src/main/cangjie/src/utils/clock.cj': {
        'slice_id': 'phase06-ui-p13-clock-renderer-helper',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'Draft P13 clock renderer helper slice for dial, hand, and timestamp drawing logic behind the canvas host page.',
        'notes': [
            'Keep dial background, frame, cursor, and text drawing logic source-backed in this helper.',
            'Treat this as a renderer support slice behind the page shell rather than a standalone page/component contract.',
        ],
    },
    'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p13-simpledraw-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'Draft P13 geometry host page slice for mode switching, touch dispatch, and page-owned point/circle state inside one interactive shell.',
        'notes': [
            'Keep current mode selection, touch dispatch, point/circle ownership, and Shape event wiring source-backed inside the page shell.',
            'Treat DGeometry.cj and Geometry.cj as explicitly frozen support slices rather than pretending the page is self-contained.',
        ],
    },
    'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/DGeometry.cj': {
        'slice_id': 'phase06-ui-p13-simpledraw-dgeometry-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'Draft P13 dynamic geometry support-model slice for observed point/circle entities, follow relationships, and hit-testing helpers behind the geometry host page.',
        'notes': [
            'Keep DPoint/DCircle ownership, follower propagation, and hit-testing helpers source-backed in this support slice.',
            'This file stays attached to the interactive geometry lane instead of being promoted as a standalone UI component.',
        ],
    },
    'raw_docs/phase06-ui-p13-draft/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/Geometry.cj': {
        'slice_id': 'phase06-ui-p13-simpledraw-geometry-math-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'Draft P13 geometry math support-model slice for point, line, circle, and intersection calculations behind the interactive host page.',
        'notes': [
            'Keep the low-level geometric primitives and intersection math source-backed in this helper instead of hiding them behind invented UI abstractions.',
            'This file remains a renderer-facing support slice, not a standalone page/component boundary.',
        ],
    },
    'raw_docs/phase06-ui-p13/HarmonyOS-Examples/CommonUI/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p13-commonui-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P13 CommonUI entry page slice for extend-based button styling and direct Router.push handoff inside one render-facing page shell.',
        'notes': [
            'Keep the extend Button.jump helper and the eight Router.push targets source-backed inside the page boundary.',
            'Treat this file as a lightweight route menu shell instead of inventing detached coordinators or helper layers.',
        ],
    },
    'raw_docs/phase06-ui-p13/HarmonyOS-Examples/11-Clock/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p13-clock-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P13 clock host page slice for page-owned Timer lifecycle, Canvas context ownership, and display-size hydration around a renderer helper.',
        'notes': [
            'Keep Timer lifecycle, CanvasRenderingContext2D ownership, and display-size hydration source-backed in the page host.',
            'Treat utils/clock.cj as the explicitly frozen renderer helper instead of collapsing the sample into a fake single-file canvas page.',
        ],
    },
    'raw_docs/phase06-ui-p13/HarmonyOS-Examples/11-Clock/entry/src/main/cangjie/src/utils/clock.cj': {
        'slice_id': 'phase06-ui-p13-clock-renderer-helper',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P13 clock renderer helper slice for dial, hand, and timestamp drawing logic behind the canvas host page.',
        'notes': [
            'Keep dial background, frame, cursor, and text drawing logic source-backed in this helper.',
            'Treat this as a renderer support slice behind the page shell rather than a standalone page/component contract.',
        ],
    },
    'raw_docs/phase06-ui-p13/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p13-simpledraw-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P13 geometry host page slice for mode switching, touch dispatch, and page-owned point/circle state inside one interactive shell.',
        'notes': [
            'Keep current mode selection, touch dispatch, point/circle ownership, and Shape event wiring source-backed inside the page shell.',
            'Treat DGeometry.cj and Geometry.cj as explicitly frozen support slices rather than pretending the page is self-contained.',
        ],
    },
    'raw_docs/phase06-ui-p13/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/DGeometry.cj': {
        'slice_id': 'phase06-ui-p13-simpledraw-dgeometry-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P13 dynamic geometry support-model slice for observed point/circle entities, follow relationships, and hit-testing helpers behind the geometry host page.',
        'notes': [
            'Keep DPoint/DCircle ownership, follower propagation, and hit-testing helpers source-backed in this support slice.',
            'This file stays attached to the interactive geometry lane instead of being promoted as a standalone UI component.',
        ],
    },
    'raw_docs/phase06-ui-p13/HarmonyOS-Examples/SimpleDraw/entry/src/main/cangjie/src/Geometry.cj': {
        'slice_id': 'phase06-ui-p13-simpledraw-geometry-math-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P13 geometry math support-model slice for point, line, circle, and intersection calculations behind the interactive host page.',
        'notes': [
            'Keep the low-level geometric primitives and intersection math source-backed in this helper instead of hiding them behind invented UI abstractions.',
            'This file remains a renderer-facing support slice, not a standalone page/component boundary.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Examples/19-CangjiexArkTS/CalendarManager/entry/src/main/cangjie/views/EntryView.cj': {
        'slice_id': 'phase06-ui-p14-calendar-manager-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P14 calendar-manager entry page slice for button-driven Hilog handoff inside one lightweight render-facing page shell.',
        'notes': [
            'Keep the button host, onClick callback, and appLog.info handoff source-backed inside the page boundary.',
            'Treat applog/Applog.cj as the explicitly frozen support helper instead of inlining logging behavior or inventing detached controller layers.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Examples/19-CangjiexArkTS/CalendarManager/entry/src/main/cangjie/applog/Applog.cj': {
        'slice_id': 'phase06-ui-p14-calendar-manager-applog-helper',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P14 calendar-manager applog helper slice for Hilog channel ownership behind the lightweight entry page shell.',
        'notes': [
            'Keep the HilogChannel construction source-backed in this helper instead of turning logging into prompt-invented globals.',
            'This file stays attached to the page shell as a narrow support-model slice rather than a standalone UI contract.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/secondarylinkage/src/main/cangjie/src/SecondaryLinkageExample.cj': {
        'slice_id': 'phase06-ui-p14-secondary-linkage-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': ['mixed-app-pattern'],
        'usage_goal': 'P14 secondary-linkage page slice for dual Scroller ownership, LazyForEach coordination, and page-owned linkage state inside one controller-owned shell.',
        'notes': [
            'Keep the dual-list linkage flow, scroll index callbacks, and currentTagIndex ownership source-backed in the page shell.',
            'Treat DataType.cj plus the cross-module FunctionDescription component as explicitly frozen companions instead of pretending the page is self-contained.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/secondarylinkage/src/main/cangjie/src/DataType.cj': {
        'slice_id': 'phase06-ui-p14-secondary-linkage-data-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': ['mixed-app-pattern'],
        'usage_goal': 'P14 secondary-linkage data-source model slice for CustomDataType payloads, LazyForEach listener plumbing, and list-layout constants behind the linkage page.',
        'notes': [
            'Keep BasicDataSource and MyDataSource source-backed here instead of moving data-listener behavior into the page shell.',
            'This file remains a support-model slice attached to the mixed-app linkage lane, not a standalone page/component boundary.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/common/utils/src/main/cangjie/src/component/FunctionDescription.cj': {
        'slice_id': 'phase06-ui-p14-secondary-linkage-function-description-component',
        'target_role': 'component',
        'slice_kind': 'primary-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': ['mixed-app-pattern'],
        'usage_goal': 'P14 shared FunctionDescription component slice for title-plus-content presentation reused by the secondary-linkage page.',
        'notes': [
            'Keep the shared description card source-backed as a reusable component instead of flattening it into the page prompt context.',
            'This cross-module helper is the honest mixed-app companion for the linkage sample.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/pages/ToDoList.cj': {
        'slice_id': 'phase06-ui-p14-pending-items-todo-list-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': ['gesture-component'],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P14 pending-items host page slice for dialog-driven item creation, swipe-action list ownership, and pending/completed state transitions inside one controller-owned shell.',
        'notes': [
            'Keep the dialogController flow, ObservedArrayList ownership, and swipeAction wiring source-backed in the page shell.',
            'Treat ToDoListItem.cj plus the model files as explicitly frozen companions instead of collapsing the sample into a fake single-file todo page.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/pages/ToDoListItem.cj': {
        'slice_id': 'phase06-ui-p14-pending-items-list-item-component',
        'target_role': 'component',
        'slice_kind': 'primary-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': ['gesture-component'],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P14 pending-items list-item component slice for edit-state toggling, checkbox completion flow, and swipe-afforded task presentation.',
        'notes': [
            'Keep the @Link-backed task movement and edit-state UI source-backed inside this component.',
            'This file is the direct interaction-heavy component anchor behind the todo page shell.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/model/ConstData.cj': {
        'slice_id': 'phase06-ui-p14-pending-items-style-config-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': ['gesture-component'],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P14 pending-items style-config support-model slice for layout constants, image sizing, and animation timing behind the todo page and list item.',
        'notes': [
            'Keep StyleConfig source-backed here instead of scattering renderer constants into page or component prompts.',
            'This file remains a renderer-facing support-model slice attached to the gesture-heavy todo lane.',
        ],
    },
    'raw_docs/phase06-ui-p14/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/pendingitems/src/main/cangjie/src/model/ToDo.cj': {
        'slice_id': 'phase06-ui-p14-pending-items-todo-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': ['gesture-component'],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P14 pending-items task model slice for observed todo identity, published completion state, and task-name ownership behind the todo page shell.',
        'notes': [
            'Keep the observed ToDo state source-backed here instead of re-inventing DTO or state-holder scaffolding in page/component prompts.',
            'This file stays attached to the todo lane as a support-model slice rather than a standalone UI component.',
        ],
    },

    'raw_docs/phase06-ui-p15/HarmonyOS-Examples/12-Pinwheel/entry/src/main/cangjie/index.cj': {
        'slice_id': 'phase06-ui-p15-pinwheel-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P15 Pinwheel host page slice for timer-driven windmill rotation, slider-owned angle/scale state, and page-shell composition around the reusable panel component.',
        'notes': [
            'Keep the Timer lifecycle, angle/imageSize state, and PanelComponent callback handoff source-backed in the page shell.',
            'Treat common/Constants.cj and view/PanelComponent.cj as explicitly frozen companions instead of flattening the sample into a fake single-file animation page.',
        ],
    },
    'raw_docs/phase06-ui-p15/HarmonyOS-Examples/12-Pinwheel/entry/src/main/cangjie/common/Constants.cj': {
        'slice_id': 'phase06-ui-p15-pinwheel-constants-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P15 Pinwheel constants support-model slice for slider ranges, rotate axes, resource-backed colors, and layout sizing behind the animation page and panel component.',
        'notes': [
            'Keep RotatePosition, SliderSpeed, SliderMode, and Constants source-backed here instead of scattering config literals across page and component prompts.',
            'This file remains a renderer-facing support-model slice rather than a standalone page/component boundary.',
        ],
    },
    'raw_docs/phase06-ui-p15/HarmonyOS-Examples/12-Pinwheel/entry/src/main/cangjie/view/PanelComponent.cj': {
        'slice_id': 'phase06-ui-p15-pinwheel-panel-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P15 Pinwheel panel component slice for slider-driven value display, mode-specific adornments, and callback-based control handoff behind the animation host page.',
        'notes': [
            'Keep the Slider onChange flow, outSetValue state, and mode-specific image/text rendering source-backed inside this component.',
            'This file is the honest reusable control companion behind the Pinwheel page shell, not a detached controller abstraction.',
        ],
    },
    'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/searchcomponent/src/main/cangjie/src/SearchComponent.cj': {
        'slice_id': 'phase06-ui-p15-search-component',
        'target_role': 'component',
        'slice_kind': 'primary-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P15 search component slice for foldable-width adaptation, geometry-transition wiring, and toast-backed disabled-search interaction inside one reusable component boundary.',
        'notes': [
            'Keep AppStorage foldable state, geometryTransition id ownership, and PromptAction toast behavior source-backed inside the component.',
            'Treat this file as a narrow reusable search interaction anchor instead of promoting it to a synthetic page shell.',
        ],
    },
    'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/functionalscenes/src/main/cangjie/src/FunctionalScenes.cj': {
        'slice_id': 'phase06-ui-p15-functional-scenes-component',
        'target_role': 'component',
        'slice_kind': 'primary-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P15 tabs-and-list orchestration component slice for TabsController ownership, menu/list coordination, and LazyForEach category filtering inside one controller-owned host component.',
        'notes': [
            'Keep tabsIndex ownership, scrollController coordination, and Router.push-facing item selection source-backed in the host component.',
            'Treat the model files as explicit companions instead of pretending FunctionalScenes.cj is self-contained.',
        ],
    },
    'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/functionalscenes/src/main/cangjie/src/model/ListDataSource.cj': {
        'slice_id': 'phase06-ui-p15-functional-scenes-data-source-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P15 functional-scenes data-source support-model slice for IDataSource ownership and list-data adaptation behind the host component.',
        'notes': [
            'Keep IDataSource plumbing and SceneModuleInfo list adaptation source-backed here instead of moving data-source behavior into the component shell.',
            'This file stays attached to the functional-scenes lane as a support-model slice.',
        ],
    },
    'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/functionalscenes/src/main/cangjie/src/model/SceneModuleInfo.cj': {
        'slice_id': 'phase06-ui-p15-functional-scenes-scene-module-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P15 functional-scenes support-model slice for route metadata, image resource ownership, and category payloads consumed by the host component.',
        'notes': [
            'Keep SceneModuleInfo payload shape source-backed here instead of re-inventing DTOs inside the component prompt context.',
            'This is a renderer-facing support-model slice rather than a standalone page/component boundary.',
        ],
    },
    'raw_docs/phase06-ui-p15/HarmonyOS-Cangjie-Cases/CangjieAppDevelopment/feature/functionalscenes/src/main/cangjie/src/model/TabsData.cj': {
        'slice_id': 'phase06-ui-p15-functional-scenes-tabs-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P15 functional-scenes tabs support-model slice for tab id/label ownership and category filter definitions behind the host component.',
        'notes': [
            'Keep TabDataModel plus TAB_DATA source-backed here instead of hard-coding category metadata into the component shell.',
            'This file remains a controller-facing support-model slice attached to the functional-scenes lane.',
        ],
    },

    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/BankUI/entry/src/main/cangjie/src/Page/search.cj': {
        'slice_id': 'phase06-ui-p16-bankui-search-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 BankUI host page slice for recent-search state ownership and search-chip composition across three explicit helper components.',
        'notes': [
            'Keep the recent-search array and page-owned composition boundary source-backed in the host page.',
            'Treat the three search helpers as explicit companions instead of pretending the search page is self-contained.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/BankUI/entry/src/main/cangjie/src/Component/searchInput.cj': {
        'slice_id': 'phase06-ui-p16-bankui-search-input-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 BankUI search-input component slice for SearchController binding, @Link state mutation, and Router.back handoff inside one bounded search control.',
        'notes': [
            'Keep SearchController usage and @Link-backed recent-search updates source-backed in the reusable input control.',
            'This helper stays attached to the BankUI search lane as an explicit support component.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/BankUI/entry/src/main/cangjie/src/Component/searchDelete.cj': {
        'slice_id': 'phase06-ui-p16-bankui-search-delete-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 BankUI search-delete component slice for conditional empty-state rendering and shared recent-search clearing inside the host search page.',
        'notes': [
            'Keep the empty-state branch and shared-list clear action source-backed inside this component.',
            'This file is a bounded search helper rather than a standalone page contract.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/BankUI/entry/src/main/cangjie/src/Component/searchLayout.cj': {
        'slice_id': 'phase06-ui-p16-bankui-search-layout-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 BankUI search-layout component slice for wrapped search-chip rendering over the shared recent-search array.',
        'notes': [
            'Keep the ForEach-based chip layout and shared recent-search binding source-backed here.',
            'This helper remains a support component behind the BankUI search host page.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/CanvasPoker/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p16-canvas-poker-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 CanvasPoker host page slice for slider-owned redraw state, canvas lifecycle setup, and button-triggered reshuffle orchestration.',
        'notes': [
            'Keep angle/basePoint state ownership and canvas redraw orchestration source-backed in the page shell.',
            'Treat the card renderer and constants as explicit helper companions instead of flattening the sample into a fake single-file canvas page.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/CanvasPoker/entry/src/main/cangjie/src/card/cards.cj': {
        'slice_id': 'phase06-ui-p16-canvas-poker-card-renderer-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 CanvasPoker card-renderer support-model slice for drawCard canvas rendering, deck generation, and shuffle behavior behind the interactive host page.',
        'notes': [
            'Keep drawCard geometry, deck initialization, and shuffle behavior source-backed here instead of rebuilding canvas math inside the page shell.',
            'This file remains a renderer-facing support-model slice attached to the CanvasPoker lane.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/CanvasPoker/entry/src/main/cangjie/src/card/const.cj': {
        'slice_id': 'phase06-ui-p16-canvas-poker-card-const-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 CanvasPoker constants support-model slice for suit/rank metadata, card dimensions, and color constants consumed by the canvas renderer.',
        'notes': [
            'Keep suit/rank naming and card-size constants source-backed here instead of hard-coding rendering metadata into prompts.',
            'This helper stays attached to the CanvasPoker renderer lane as a support-model slice.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/index.cj': {
        'slice_id': 'phase06-ui-p16-color-picker-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 ColorPicker host page slice for dialog-controller ownership and selected-color state handoff into the custom picker dialog.',
        'notes': [
            'Keep CustomDialogController ownership and selected-color state in the page shell.',
            'Treat the picker, palette, slider, and HSV helpers as explicit companions instead of reducing the sample to a single entry file.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/color_picker.cj': {
        'slice_id': 'phase06-ui-p16-color-picker-component',
        'target_role': 'component',
        'slice_kind': 'primary-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 ColorPicker primary component slice for dialog content composition, color-string hydration, and HSV-to-RGB handoff inside the bounded picker boundary.',
        'notes': [
            'Keep ColorPicker plus ColorPickerDialog source-backed in one primary component slice rather than splitting the dialog away from the picker state machine.',
            'This file remains the central rich-component anchor for the ColorPicker lane.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/color_slider.cj': {
        'slice_id': 'phase06-ui-p16-color-slider-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 ColorPicker slider support-component slice for hue-slider rendering, touch updates, and HSV mutation behind the dialog host component.',
        'notes': [
            'Keep the hue slider canvas layers and touch-driven HSV updates source-backed in this support component.',
            'This helper stays attached to the ColorPicker lane as an explicit rich-component companion.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/color_palette.cj': {
        'slice_id': 'phase06-ui-p16-color-palette-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 ColorPicker palette support-component slice for saturation/value gesture selection and layered gradient rendering behind the dialog host component.',
        'notes': [
            'Keep the palette background/picker layers and touch-driven HSV updates source-backed in this support component.',
            'This file remains an explicit companion behind the bounded ColorPicker dialog lane.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/color_utils.cj': {
        'slice_id': 'phase06-ui-p16-color-utils-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 ColorPicker support-model slice for RGB/HSV conversion and packed-color helpers consumed by the dialog and canvas components.',
        'notes': [
            'Keep ColorUtils conversion logic source-backed here instead of re-inventing color math inside prompts.',
            'This file is a renderer-facing support-model slice attached to the ColorPicker lane.',
        ],
    },
    'raw_docs/phase06-ui-p16/HarmonyOS-Examples/ColorPicker/entry/src/main/cangjie/color_picker/hsv.cj': {
        'slice_id': 'phase06-ui-p16-hsv-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P16 ColorPicker observed-state support-model slice for hue, saturation, and value ownership shared by the picker, palette, and slider components.',
        'notes': [
            'Keep the observed HSV state container source-backed here instead of replacing it with prompt-local tuples or map state.',
            'This helper stays attached to the ColorPicker lane as a controller-facing support-model slice.',
        ],
    },

    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/Game2048/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p17-game2048-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 Game2048 host page slice for swipe-direction handling, score ownership, and board-sync orchestration around explicit puzzle and score companions.',
        'notes': [
            'Keep touch coordinates, swipe-direction resolution, PromptAction game-over flow, and board sync source-backed in the page shell.',
            'Treat core/puzzle.cj and widget/common.cj as explicit companions instead of pretending the game page is self-contained.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/Game2048/entry/src/main/cangjie/src/core/puzzle.cj': {
        'slice_id': 'phase06-ui-p17-game2048-puzzle-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 Game2048 support-model slice for board mutation, merge/reverse logic, random tile generation, and score accumulation behind the interactive host page.',
        'notes': [
            'Keep board ownership, move/merge helpers, and score accumulation source-backed in this support model instead of re-inventing game logic in prompts.',
            'This file remains attached to the Game2048 controller-owned lane rather than becoming a standalone UI contract.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/Game2048/entry/src/main/cangjie/src/widget/common.cj': {
        'slice_id': 'phase06-ui-p17-game2048-score-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 Game2048 score-card support component slice for title-plus-score presentation over the shared @Link score state.',
        'notes': [
            'Keep the linked score presentation source-backed in this bounded display component instead of flattening it into the page shell.',
            'This file is the honest reusable score companion behind the Game2048 host page.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p17-pretty-calculator-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 PrettyCalculator host page slice for fold-aware layout branching, storage-backed theme selection, and composition around explicit calculator companions.',
        'notes': [
            'Keep fold-status branching, page-level layout composition, and background theme handoff source-backed in the page shell.',
            'Treat expression/history/keyboard/theme files as explicit companions instead of collapsing the calculator into a misleading single-file pick.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/components/expression.cj': {
        'slice_id': 'phase06-ui-p17-pretty-calculator-expression-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 PrettyCalculator expression support component slice for formatted expression display over the shared storage-backed calculator state.',
        'notes': [
            'Keep expression formatting and TextArea rendering source-backed in this bounded display component.',
            'This helper stays attached to the calculator lane as an explicit render-facing companion.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/components/history.cj': {
        'slice_id': 'phase06-ui-p17-pretty-calculator-history-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 PrettyCalculator history support component slice for list-backed expression history rendering and theme-aware item highlighting.',
        'notes': [
            'Keep history list rendering and theme-index-aware highlighting source-backed in this support component.',
            'This file remains a bounded display companion behind the calculator host page.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/components/keyboard.cj': {
        'slice_id': 'phase06-ui-p17-pretty-calculator-keyboard-component',
        'target_role': 'component',
        'slice_kind': 'primary-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 PrettyCalculator primary keyboard component slice for key-grid ownership, expression evaluation, and storage-backed calculator state mutation inside one interactive boundary.',
        'notes': [
            'Keep key definitions, expression parsing/evaluation, and storage-backed mutation source-backed inside this primary component.',
            'This file is the main interaction-heavy companion behind the calculator host page, not a synthetic controller layer.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/PrettyCalculator/entry/src/main/cangjie/src/components/theme.cj': {
        'slice_id': 'phase06-ui-p17-pretty-calculator-theme-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 PrettyCalculator theme support-model slice for theme palette ownership shared by the host page and calculator companions.',
        'notes': [
            'Keep Theme plus themes source-backed here instead of hard-coding palette data into page or component prompts.',
            'This file stays attached to the calculator lane as a renderer-facing support model.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p17-cube-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 Cube host page slice for sync orchestration, face-grid composition, and button-driven rotation/reset flow around explicit cube-algebra helpers.',
        'notes': [
            'Keep CubeFace composition, sync orchestration, and button-triggered transform/reset flow source-backed in the page shell.',
            'Treat cube.cj plus matrix/permutation/rotation helpers as explicit companions instead of flattening the sample into a single-page demo.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/cube/cube.cj': {
        'slice_id': 'phase06-ui-p17-cube-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 Cube support-model slice for mutable face-matrix ownership, permutation application, and reset/transform behavior behind the interactive host page.',
        'notes': [
            'Keep face-matrix ownership, rotate/permute logic, and transform sequencing source-backed in this support model.',
            'This file remains the controller-facing mutable model behind the Cube page shell.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/cube/matrix.cj': {
        'slice_id': 'phase06-ui-p17-cube-matrix-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 Cube matrix support-model slice for face-matrix creation plus row/column index helpers consumed by the mutable cube model.',
        'notes': [
            'Keep matrix/index helper semantics source-backed here instead of rebuilding them inside the page or cube model prompts.',
            'This helper stays attached to the cube-algebra lane as a renderer-facing support model.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/cube/permutation.cj': {
        'slice_id': 'phase06-ui-p17-cube-permutation-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 Cube permutation support-model slice for inverse-permutation derivation over face/index tuples consumed by the cube transform engine.',
        'notes': [
            'Keep permutation inversion semantics source-backed here instead of inventing tuple-mutation helpers in prompts.',
            'This helper remains an explicit algebra companion behind the Cube lane.',
        ],
    },
    'raw_docs/phase06-ui-p17/HarmonyOS-Examples/03-Cube/entry/src/main/cangjie/src/cube/rotation.cj': {
        'slice_id': 'phase06-ui-p17-cube-rotation-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P17 Cube rotation support-model slice for rotation algebra, composition operators, and Face typing consumed by the page and cube engine.',
        'notes': [
            'Keep rotation composition, exponentiation, and Face typing source-backed here instead of inventing symbolic algebra inside prompts.',
            'This file stays attached to the cube lane as an explicit algebra support model.',
        ],
    },





    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/index.cj': {
        'slice_id': 'phase06-ui-p18-calculator-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator host page slice for keypad-grid composition and DynamicParam-backed input orchestration around explicit button and evaluator helpers.',
        'notes': [
            'Keep keypad layout plus expression/result ownership source-backed in the page shell.',
            'Treat button/entity and evaluator files as explicit companions instead of flattening the sample into one page.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/service/dynamic_param.cj': {
        'slice_id': 'phase06-ui-p18-calculator-dynamic-param-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator observed-state model for expression/result ownership, text-size mutation, and derived evaluation updates behind the host page.',
        'notes': [
            'Keep @Observed and @Publish state mutation source-backed here.',
            'This file remains the controller-facing state companion behind the calculator page shell.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/entity/button_entity.cj': {
        'slice_id': 'phase06-ui-p18-calculator-button-entity-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator base button model for shared press hooks, text payload ownership, and button color styling behind the keypad page.',
        'notes': [
            'Keep beforePush/afterPush/onPress behavior source-backed in the base button type.',
            'This file is a controller-facing input model, not a standalone UI component contract.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/entity/ac_button_entity.cj': {
        'slice_id': 'phase06-ui-p18-calculator-ac-button-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator clear-button model for reset behavior and AC styling over the shared DynamicParam state.',
        'notes': [
            'Keep clear-action semantics source-backed here instead of reconstructing AC behavior from prompt heuristics.',
            'This subtype stays attached to the calculator input lane as a bounded button model.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/entity/eval_button_entity.cj': {
        'slice_id': 'phase06-ui-p18-calculator-eval-button-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator evaluate-button model for equals-button styling and result-size handoff against the shared DynamicParam state.',
        'notes': [
            'Keep equals-button mutation semantics source-backed here.',
            'This file remains a controller-facing button subtype behind the calculator page shell.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/entity/number_button_entity.cj': {
        'slice_id': 'phase06-ui-p18-calculator-number-button-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator number-button model for numeric input styling and expression/result size reset after successful pushes.',
        'notes': [
            'Keep numeric-button post-push behavior source-backed here.',
            'This subtype stays attached to the calculator controller-owned input lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/entity/operation_button_entity.cj': {
        'slice_id': 'phase06-ui-p18-calculator-operation-button-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator operator-button model for operator styling and expression/result size reset across the shared calculator state.',
        'notes': [
            'Keep operator-button mutation and styling source-backed in this subtype.',
            'This file remains a controller-facing companion behind the calculator host page.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/entity/keyboards.cj': {
        'slice_id': 'phase06-ui-p18-calculator-keyboards-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator keypad-definition model for explicit key ordering and concrete button-entity instantiation behind the page shell.',
        'notes': [
            'Keep keypad ordering and concrete button construction source-backed here.',
            'This file stays attached to the controller-facing calculator input lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/utils/calculate_utils.cj': {
        'slice_id': 'phase06-ui-p18-calculator-calculate-utils-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator evaluator model for tokenization, infix/postfix conversion, and arithmetic evaluation consumed by DynamicParam.',
        'notes': [
            'Keep expression parsing and evaluation helpers source-backed here.',
            'This file remains a renderer-facing utility companion behind the calculator lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/utils/collections.cj': {
        'slice_id': 'phase06-ui-p18-calculator-stack-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator stack model for bounded push/pop/peek collection behavior consumed by the evaluator helpers.',
        'notes': [
            'Keep stack semantics source-backed here instead of replacing postfix evaluation with prompt-local assumptions.',
            'This helper stays attached to the evaluator lane as a renderer-facing support model.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/04-Calculator/entry/src/main/cangjie/src/utils/string_utils.cj': {
        'slice_id': 'phase06-ui-p18-calculator-string-utils-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Calculator string helper model for float formatting, trim behavior, digit checks, and numeric parsing behind the evaluator flow.',
        'notes': [
            'Keep number-formatting helpers source-backed here.',
            'This file remains an explicit utility companion behind the calculator evaluator lane.',
        ],
    },


    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/10-Schedule/entry/src/main/cangjie/index.cj': {
        'slice_id': 'phase06-ui-p18-schedule-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Schedule host page slice for TabsController ownership, resource-backed schedule loading, and synchronized scroller composition around explicit course-grid companions.',
        'notes': [
            'Keep page-owned scroller wiring, tab state, and MainAbility context usage source-backed in the host page.',
            'Treat grid/header/data files as explicit companions instead of pretending the schedule is a standalone entry shell.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/10-Schedule/entry/src/main/cangjie/main_ability.cj': {
        'slice_id': 'phase06-ui-p18-schedule-main-ability-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Schedule ability-context model for fullscreen window setup and exported abilityContext consumed by the schedule host page.',
        'notes': [
            'Keep MainAbility window-stage setup and static abilityContext source-backed here.',
            'This file remains the controller-facing runtime companion behind the schedule page shell.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/10-Schedule/entry/src/main/cangjie/components/BackRow.cj': {
        'slice_id': 'phase06-ui-p18-schedule-back-row-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Schedule back-row support component for week-label and back-icon presentation above the timetable grid.',
        'notes': [
            'Keep the bounded header rendering source-backed in this component instead of absorbing it into the page shell.',
            'This file is the narrow display companion behind the schedule lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/10-Schedule/entry/src/main/cangjie/components/Course.cj': {
        'slice_id': 'phase06-ui-p18-schedule-course-component',
        'target_role': 'component',
        'slice_kind': 'primary-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Schedule primary course-grid component for builder-backed course-cell rendering and synchronized horizontal/vertical scroller orchestration.',
        'notes': [
            'Keep courseBuilder plus scroll-sync callbacks source-backed in this primary grid component.',
            'This file is the main interactive companion behind the schedule host page.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/10-Schedule/entry/src/main/cangjie/components/SectionRow.cj': {
        'slice_id': 'phase06-ui-p18-schedule-section-row-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Schedule section-row support component for weekday header rendering and horizontal scroller alignment above the course grid.',
        'notes': [
            'Keep weekday-header layout and linked scroller behavior source-backed in this support component.',
            'This file remains a controller-facing grid companion rather than a free-floating display snippet.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/10-Schedule/entry/src/main/cangjie/components/SectionTime.cj': {
        'slice_id': 'phase06-ui-p18-schedule-section-time-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Schedule section-time support component for linked time/index column rendering and vertical scroller synchronization beside the course grid.',
        'notes': [
            'Keep the paired scroller callbacks and time/index column composition source-backed in this support component.',
            'This file stays attached to the schedule controller-owned grid lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/10-Schedule/entry/src/main/cangjie/dataModel/CourseEntity.cj': {
        'slice_id': 'phase06-ui-p18-schedule-course-entity-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Schedule course-table model for course matrix ownership and deterministic row/column expansion consumed by the grid component.',
        'notes': [
            'Keep course-table construction and index-matrix semantics source-backed here.',
            'This file remains a renderer-facing model companion behind the schedule lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/10-Schedule/entry/src/main/cangjie/dataModel/CourseItem.cj': {
        'slice_id': 'phase06-ui-p18-schedule-course-item-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 Schedule course-item model for resource-name and background-color ownership consumed by the timetable renderer.',
        'notes': [
            'Keep CJResource plus Color pairing source-backed here instead of flattening course metadata into the UI layer.',
            'This file stays attached to the renderer-facing schedule model lane.',
        ],
    },


    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/17-CustomKeyboard/entry/src/main/cangjie/index.cj': {
        'slice_id': 'phase06-ui-p18-custom-keyboard-entry-page',
        'target_role': 'page',
        'slice_kind': 'entry-page',
        'structure_tag': 'page-shell',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 CustomKeyboard host page slice for AppStorage-backed license-plate flow and page-level builder orchestration around explicit keyboard companions.',
        'notes': [
            'Keep AppStorage/StorageLink wiring and top-level builder composition source-backed in the page shell.',
            'Treat builder components, constants, and keyboard model as explicit companions instead of flattening the flow into one page file.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/17-CustomKeyboard/entry/src/main/cangjie/components/FooterBuilder.cj': {
        'slice_id': 'phase06-ui-p18-custom-keyboard-footer-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 CustomKeyboard footer support component for payment-summary actions, dialog-controller ownership, and success-dialog presentation.',
        'notes': [
            'Keep CustomDialogController usage and detail-visibility state source-backed in this support component.',
            'This file remains a controller-facing payment footer companion behind the host page.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/17-CustomKeyboard/entry/src/main/cangjie/components/LicensePlateInputBuilder.cj': {
        'slice_id': 'phase06-ui-p18-custom-keyboard-license-plate-component',
        'target_role': 'component',
        'slice_kind': 'primary-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 CustomKeyboard primary input component for focused license-plate editing, custom keyboard ownership, and builder-backed key-grid mutation.',
        'notes': [
            'Keep StorageLink state, focused input index, and keyboardBuilder mutation flow source-backed inside this primary component.',
            'This file is the main interaction-heavy companion behind the custom-keyboard host page.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/17-CustomKeyboard/entry/src/main/cangjie/components/PaymentInfoBuilder.cj': {
        'slice_id': 'phase06-ui-p18-custom-keyboard-payment-info-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 CustomKeyboard payment-info support component for display-only license-plate and total-cost presentation over shared AppStorage state.',
        'notes': [
            'Keep the bounded summary rendering source-backed in this support component instead of duplicating payment display logic inside the page shell.',
            'This file remains a render-facing companion behind the custom-keyboard lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/17-CustomKeyboard/entry/src/main/cangjie/components/TitleBuilder.cj': {
        'slice_id': 'phase06-ui-p18-custom-keyboard-title-component',
        'target_role': 'component',
        'slice_kind': 'support-component',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 CustomKeyboard title-bar support component for header icon and title presentation above the payment workflow.',
        'notes': [
            'Keep the bounded title/header rendering source-backed in this component rather than absorbing it into the page shell.',
            'This file is the narrow display companion behind the custom-keyboard host page.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/17-CustomKeyboard/entry/src/main/cangjie/constants/KeyboardConstants.cj': {
        'slice_id': 'phase06-ui-p18-custom-keyboard-keyboard-constants-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 CustomKeyboard keyboard-constants model for key sizing, spacing, and layout constants consumed by the interactive input builder.',
        'notes': [
            'Keep keyboard sizing constants source-backed here instead of scattering numeric literals across prompts.',
            'This file remains a renderer-facing constants companion behind the custom-keyboard lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/17-CustomKeyboard/entry/src/main/cangjie/constants/StyleConstants.cj': {
        'slice_id': 'phase06-ui-p18-custom-keyboard-style-constants-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'view-model-renderer',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 CustomKeyboard style-constants model for shared layout, typography, divider, and dialog measurements across the page and builder companions.',
        'notes': [
            'Keep shared layout and typography constants source-backed here instead of re-inventing visual measurements inside prompts.',
            'This file stays attached to the render-facing custom-keyboard utility lane.',
        ],
    },
    'raw_docs/phase06-ui-p18/HarmonyOS-Examples/17-CustomKeyboard/entry/src/main/cangjie/model/Keyboard.cj': {
        'slice_id': 'phase06-ui-p18-custom-keyboard-keyboard-model',
        'target_role': 'viewmodel',
        'slice_kind': 'support-model',
        'structure_tag': 'rich-component',
        'ownership_tag': 'controller-owned-state',
        'interaction_tags': [],
        'exception_tags': [],
        'sample_scope_tags': [],
        'usage_goal': 'P18 CustomKeyboard keyboard-state model for keyboard-type selection, row/column template ownership, and key-array switching behind the input builder.',
        'notes': [
            'Keep KeyboardType branching and derived layout template state source-backed in this support model.',
            'This file remains the controller-facing model companion behind the custom-keyboard interaction lane.',
        ],
    },
}

# P19 regular mechanical-readiness overrides begin
FILE_SLICE_OVERRIDES.update({'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/index.cj': {'slice_id': 'phase06-ui-p19-slide-ui-entry-page',
                                                                                           'target_role': 'page',
                                                                                           'slice_kind': 'entry-page',
                                                                                           'structure_tag': 'page-shell',
                                                                                           'ownership_tag': 'controller-owned-state',
                                                                                           'interaction_tags': [],
                                                                                           'exception_tags': [],
                                                                                           'sample_scope_tags': [],
                                                                                           'usage_goal': 'P19 SlideUI '
                                                                                                         'host page '
                                                                                                         'slice for '
                                                                                                         'gesture-driven '
                                                                                                         'panel '
                                                                                                         'ownership, '
                                                                                                         'ability-context '
                                                                                                         'handoff, and '
                                                                                                         'same-package '
                                                                                                         'component/data '
                                                                                                         'composition.',
                                                                                           'notes': ['Keep panel '
                                                                                                     'open/close state '
                                                                                                     'and '
                                                                                                     'ability-context '
                                                                                                     'acquisition '
                                                                                                     'source-backed in '
                                                                                                     'the host page.',
                                                                                                     'Treat component '
                                                                                                     'and data files '
                                                                                                     'as explicit '
                                                                                                     'companions '
                                                                                                     'behind the '
                                                                                                     'SlideUI page '
                                                                                                     'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/main_ability.cj': {'slice_id': 'phase06-ui-p19-slide-ui-main-ability-model',
                                                                                                  'target_role': 'viewmodel',
                                                                                                  'slice_kind': 'support-model',
                                                                                                  'structure_tag': 'rich-component',
                                                                                                  'ownership_tag': 'controller-owned-state',
                                                                                                  'interaction_tags': [],
                                                                                                  'exception_tags': [],
                                                                                                  'sample_scope_tags': [],
                                                                                                  'usage_goal': 'P19 '
                                                                                                                'SlideUI '
                                                                                                                'ability '
                                                                                                                'model '
                                                                                                                'for '
                                                                                                                'globalAbilityContext '
                                                                                                                'capture '
                                                                                                                'and '
                                                                                                                'fullscreen '
                                                                                                                'window-stage '
                                                                                                                'setup '
                                                                                                                'behind '
                                                                                                                'the '
                                                                                                                'host '
                                                                                                                'page.',
                                                                                                  'notes': ['Keep '
                                                                                                            'globalAbilityContext '
                                                                                                            'lifecycle '
                                                                                                            'wiring '
                                                                                                            'source-backed '
                                                                                                            'here.',
                                                                                                            'This file '
                                                                                                            'remains '
                                                                                                            'the '
                                                                                                            'controller-facing '
                                                                                                            'ability '
                                                                                                            'companion '
                                                                                                            'behind '
                                                                                                            'the '
                                                                                                            'SlideUI '
                                                                                                            'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/components/BottomTab.cj': {'slice_id': 'phase06-ui-p19-slide-ui-bottom-tab-component',
                                                                                                          'target_role': 'component',
                                                                                                          'slice_kind': 'support-component',
                                                                                                          'structure_tag': 'rich-component',
                                                                                                          'ownership_tag': 'view-model-renderer',
                                                                                                          'interaction_tags': [],
                                                                                                          'exception_tags': [],
                                                                                                          'sample_scope_tags': [],
                                                                                                          'usage_goal': 'P19 '
                                                                                                                        'SlideUI '
                                                                                                                        'component '
                                                                                                                        'slice '
                                                                                                                        'for '
                                                                                                                        'bottom-tab '
                                                                                                                        'builder '
                                                                                                                        'composition '
                                                                                                                        'inside '
                                                                                                                        'the '
                                                                                                                        'same-package '
                                                                                                                        'panel '
                                                                                                                        'flow.',
                                                                                                          'notes': ['Keep '
                                                                                                                    'this '
                                                                                                                    'component '
                                                                                                                    'source-backed '
                                                                                                                    'inside '
                                                                                                                    'the '
                                                                                                                    'SlideUI '
                                                                                                                    'same-package '
                                                                                                                    'closure.',
                                                                                                                    'This '
                                                                                                                    'file '
                                                                                                                    'remains '
                                                                                                                    'an '
                                                                                                                    'explicit '
                                                                                                                    'UI '
                                                                                                                    'companion '
                                                                                                                    'behind '
                                                                                                                    'the '
                                                                                                                    'SlideUI '
                                                                                                                    'page '
                                                                                                                    'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/components/GroupItem.cj': {'slice_id': 'phase06-ui-p19-slide-ui-group-item-component',
                                                                                                          'target_role': 'component',
                                                                                                          'slice_kind': 'support-component',
                                                                                                          'structure_tag': 'rich-component',
                                                                                                          'ownership_tag': 'view-model-renderer',
                                                                                                          'interaction_tags': [],
                                                                                                          'exception_tags': [],
                                                                                                          'sample_scope_tags': [],
                                                                                                          'usage_goal': 'P19 '
                                                                                                                        'SlideUI '
                                                                                                                        'component '
                                                                                                                        'slice '
                                                                                                                        'for '
                                                                                                                        'group '
                                                                                                                        'card '
                                                                                                                        'rendering '
                                                                                                                        'inside '
                                                                                                                        'the '
                                                                                                                        'same-package '
                                                                                                                        'panel '
                                                                                                                        'flow.',
                                                                                                          'notes': ['Keep '
                                                                                                                    'this '
                                                                                                                    'component '
                                                                                                                    'source-backed '
                                                                                                                    'inside '
                                                                                                                    'the '
                                                                                                                    'SlideUI '
                                                                                                                    'same-package '
                                                                                                                    'closure.',
                                                                                                                    'This '
                                                                                                                    'file '
                                                                                                                    'remains '
                                                                                                                    'an '
                                                                                                                    'explicit '
                                                                                                                    'UI '
                                                                                                                    'companion '
                                                                                                                    'behind '
                                                                                                                    'the '
                                                                                                                    'SlideUI '
                                                                                                                    'page '
                                                                                                                    'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/components/MsgItem.cj': {'slice_id': 'phase06-ui-p19-slide-ui-msg-item-component',
                                                                                                        'target_role': 'component',
                                                                                                        'slice_kind': 'primary-component',
                                                                                                        'structure_tag': 'rich-component',
                                                                                                        'ownership_tag': 'view-model-renderer',
                                                                                                        'interaction_tags': [],
                                                                                                        'exception_tags': [],
                                                                                                        'sample_scope_tags': [],
                                                                                                        'usage_goal': 'P19 '
                                                                                                                      'SlideUI '
                                                                                                                      'component '
                                                                                                                      'slice '
                                                                                                                      'for '
                                                                                                                      'message '
                                                                                                                      'card '
                                                                                                                      'list '
                                                                                                                      'rendering '
                                                                                                                      'inside '
                                                                                                                      'the '
                                                                                                                      'same-package '
                                                                                                                      'panel '
                                                                                                                      'flow.',
                                                                                                        'notes': ['Keep '
                                                                                                                  'this '
                                                                                                                  'component '
                                                                                                                  'source-backed '
                                                                                                                  'inside '
                                                                                                                  'the '
                                                                                                                  'SlideUI '
                                                                                                                  'same-package '
                                                                                                                  'closure.',
                                                                                                                  'This '
                                                                                                                  'file '
                                                                                                                  'remains '
                                                                                                                  'an '
                                                                                                                  'explicit '
                                                                                                                  'UI '
                                                                                                                  'companion '
                                                                                                                  'behind '
                                                                                                                  'the '
                                                                                                                  'SlideUI '
                                                                                                                  'page '
                                                                                                                  'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/components/MyTop.cj': {'slice_id': 'phase06-ui-p19-slide-ui-my-top-component',
                                                                                                      'target_role': 'component',
                                                                                                      'slice_kind': 'primary-component',
                                                                                                      'structure_tag': 'rich-component',
                                                                                                      'ownership_tag': 'controller-owned-state',
                                                                                                      'interaction_tags': [],
                                                                                                      'exception_tags': [],
                                                                                                      'sample_scope_tags': [],
                                                                                                      'usage_goal': 'P19 '
                                                                                                                    'SlideUI '
                                                                                                                    'component '
                                                                                                                    'slice '
                                                                                                                    'for '
                                                                                                                    'top '
                                                                                                                    'bar '
                                                                                                                    'interaction '
                                                                                                                    'and '
                                                                                                                    'terminate-self '
                                                                                                                    'affordance '
                                                                                                                    'inside '
                                                                                                                    'the '
                                                                                                                    'same-package '
                                                                                                                    'panel '
                                                                                                                    'flow.',
                                                                                                      'notes': ['Keep '
                                                                                                                'this '
                                                                                                                'component '
                                                                                                                'source-backed '
                                                                                                                'inside '
                                                                                                                'the '
                                                                                                                'SlideUI '
                                                                                                                'same-package '
                                                                                                                'closure.',
                                                                                                                'This '
                                                                                                                'file '
                                                                                                                'remains '
                                                                                                                'an '
                                                                                                                'explicit '
                                                                                                                'UI '
                                                                                                                'companion '
                                                                                                                'behind '
                                                                                                                'the '
                                                                                                                'SlideUI '
                                                                                                                'page '
                                                                                                                'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/components/ShipDirection.cj': {'slice_id': 'phase06-ui-p19-slide-ui-ship-direction-component',
                                                                                                              'target_role': 'component',
                                                                                                              'slice_kind': 'support-component',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'view-model-renderer',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P19 '
                                                                                                                            'SlideUI '
                                                                                                                            'component '
                                                                                                                            'slice '
                                                                                                                            'for '
                                                                                                                            'ship '
                                                                                                                            'direction '
                                                                                                                            'rendering '
                                                                                                                            'inside '
                                                                                                                            'the '
                                                                                                                            'same-package '
                                                                                                                            'panel '
                                                                                                                            'flow.',
                                                                                                              'notes': ['Keep '
                                                                                                                        'this '
                                                                                                                        'component '
                                                                                                                        'source-backed '
                                                                                                                        'inside '
                                                                                                                        'the '
                                                                                                                        'SlideUI '
                                                                                                                        'same-package '
                                                                                                                        'closure.',
                                                                                                                        'This '
                                                                                                                        'file '
                                                                                                                        'remains '
                                                                                                                        'an '
                                                                                                                        'explicit '
                                                                                                                        'UI '
                                                                                                                        'companion '
                                                                                                                        'behind '
                                                                                                                        'the '
                                                                                                                        'SlideUI '
                                                                                                                        'page '
                                                                                                                        'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/components/ShipFact.cj': {'slice_id': 'phase06-ui-p19-slide-ui-ship-fact-component',
                                                                                                         'target_role': 'component',
                                                                                                         'slice_kind': 'support-component',
                                                                                                         'structure_tag': 'rich-component',
                                                                                                         'ownership_tag': 'view-model-renderer',
                                                                                                         'interaction_tags': [],
                                                                                                         'exception_tags': [],
                                                                                                         'sample_scope_tags': [],
                                                                                                         'usage_goal': 'P19 '
                                                                                                                       'SlideUI '
                                                                                                                       'component '
                                                                                                                       'slice '
                                                                                                                       'for '
                                                                                                                       'fact-panel '
                                                                                                                       'rendering '
                                                                                                                       'inside '
                                                                                                                       'the '
                                                                                                                       'same-package '
                                                                                                                       'panel '
                                                                                                                       'flow.',
                                                                                                         'notes': ['Keep '
                                                                                                                   'this '
                                                                                                                   'component '
                                                                                                                   'source-backed '
                                                                                                                   'inside '
                                                                                                                   'the '
                                                                                                                   'SlideUI '
                                                                                                                   'same-package '
                                                                                                                   'closure.',
                                                                                                                   'This '
                                                                                                                   'file '
                                                                                                                   'remains '
                                                                                                                   'an '
                                                                                                                   'explicit '
                                                                                                                   'UI '
                                                                                                                   'companion '
                                                                                                                   'behind '
                                                                                                                   'the '
                                                                                                                   'SlideUI '
                                                                                                                   'page '
                                                                                                                   'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/components/ShipImg.cj': {'slice_id': 'phase06-ui-p19-slide-ui-ship-img-component',
                                                                                                        'target_role': 'component',
                                                                                                        'slice_kind': 'support-component',
                                                                                                        'structure_tag': 'rich-component',
                                                                                                        'ownership_tag': 'controller-owned-state',
                                                                                                        'interaction_tags': [],
                                                                                                        'exception_tags': [],
                                                                                                        'sample_scope_tags': [],
                                                                                                        'usage_goal': 'P19 '
                                                                                                                      'SlideUI '
                                                                                                                      'component '
                                                                                                                      'slice '
                                                                                                                      'for '
                                                                                                                      'ship '
                                                                                                                      'image '
                                                                                                                      'and '
                                                                                                                      'slide-trigger '
                                                                                                                      'presentation '
                                                                                                                      'inside '
                                                                                                                      'the '
                                                                                                                      'same-package '
                                                                                                                      'panel '
                                                                                                                      'flow.',
                                                                                                        'notes': ['Keep '
                                                                                                                  'this '
                                                                                                                  'component '
                                                                                                                  'source-backed '
                                                                                                                  'inside '
                                                                                                                  'the '
                                                                                                                  'SlideUI '
                                                                                                                  'same-package '
                                                                                                                  'closure.',
                                                                                                                  'This '
                                                                                                                  'file '
                                                                                                                  'remains '
                                                                                                                  'an '
                                                                                                                  'explicit '
                                                                                                                  'UI '
                                                                                                                  'companion '
                                                                                                                  'behind '
                                                                                                                  'the '
                                                                                                                  'SlideUI '
                                                                                                                  'page '
                                                                                                                  'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/components/StatusHead.cj': {'slice_id': 'phase06-ui-p19-slide-ui-status-head-component',
                                                                                                           'target_role': 'component',
                                                                                                           'slice_kind': 'support-component',
                                                                                                           'structure_tag': 'rich-component',
                                                                                                           'ownership_tag': 'view-model-renderer',
                                                                                                           'interaction_tags': [],
                                                                                                           'exception_tags': [],
                                                                                                           'sample_scope_tags': [],
                                                                                                           'usage_goal': 'P19 '
                                                                                                                         'SlideUI '
                                                                                                                         'component '
                                                                                                                         'slice '
                                                                                                                         'for '
                                                                                                                         'status '
                                                                                                                         'header '
                                                                                                                         'rendering '
                                                                                                                         'inside '
                                                                                                                         'the '
                                                                                                                         'same-package '
                                                                                                                         'panel '
                                                                                                                         'flow.',
                                                                                                           'notes': ['Keep '
                                                                                                                     'this '
                                                                                                                     'component '
                                                                                                                     'source-backed '
                                                                                                                     'inside '
                                                                                                                     'the '
                                                                                                                     'SlideUI '
                                                                                                                     'same-package '
                                                                                                                     'closure.',
                                                                                                                     'This '
                                                                                                                     'file '
                                                                                                                     'remains '
                                                                                                                     'an '
                                                                                                                     'explicit '
                                                                                                                     'UI '
                                                                                                                     'companion '
                                                                                                                     'behind '
                                                                                                                     'the '
                                                                                                                     'SlideUI '
                                                                                                                     'page '
                                                                                                                     'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/datas/MiniData.cj': {'slice_id': 'phase06-ui-p19-slide-ui-mini-data-model',
                                                                                                    'target_role': 'viewmodel',
                                                                                                    'slice_kind': 'support-model',
                                                                                                    'structure_tag': 'rich-component',
                                                                                                    'ownership_tag': 'view-model-renderer',
                                                                                                    'interaction_tags': [],
                                                                                                    'exception_tags': [],
                                                                                                    'sample_scope_tags': [],
                                                                                                    'usage_goal': 'P19 '
                                                                                                                  'SlideUI '
                                                                                                                  'data '
                                                                                                                  'model '
                                                                                                                  'slice '
                                                                                                                  'for '
                                                                                                                  'mini '
                                                                                                                  'data '
                                                                                                                  'items '
                                                                                                                  'consumed '
                                                                                                                  'by '
                                                                                                                  'the '
                                                                                                                  'panel '
                                                                                                                  'cards.',
                                                                                                    'notes': ['Keep '
                                                                                                              'same-package '
                                                                                                              'data '
                                                                                                              'payloads '
                                                                                                              'source-backed '
                                                                                                              'here.',
                                                                                                              'This '
                                                                                                              'file '
                                                                                                              'remains '
                                                                                                              'a '
                                                                                                              'renderer-facing '
                                                                                                              'data '
                                                                                                              'companion '
                                                                                                              'behind '
                                                                                                              'the '
                                                                                                              'SlideUI '
                                                                                                              'page '
                                                                                                              'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/datas/MsgData.cj': {'slice_id': 'phase06-ui-p19-slide-ui-msg-data-model',
                                                                                                   'target_role': 'viewmodel',
                                                                                                   'slice_kind': 'support-model',
                                                                                                   'structure_tag': 'rich-component',
                                                                                                   'ownership_tag': 'view-model-renderer',
                                                                                                   'interaction_tags': [],
                                                                                                   'exception_tags': [],
                                                                                                   'sample_scope_tags': [],
                                                                                                   'usage_goal': 'P19 '
                                                                                                                 'SlideUI '
                                                                                                                 'data '
                                                                                                                 'model '
                                                                                                                 'slice '
                                                                                                                 'for '
                                                                                                                 'msg '
                                                                                                                 'data '
                                                                                                                 'items '
                                                                                                                 'consumed '
                                                                                                                 'by '
                                                                                                                 'the '
                                                                                                                 'panel '
                                                                                                                 'cards.',
                                                                                                   'notes': ['Keep '
                                                                                                             'same-package '
                                                                                                             'data '
                                                                                                             'payloads '
                                                                                                             'source-backed '
                                                                                                             'here.',
                                                                                                             'This '
                                                                                                             'file '
                                                                                                             'remains '
                                                                                                             'a '
                                                                                                             'renderer-facing '
                                                                                                             'data '
                                                                                                             'companion '
                                                                                                             'behind '
                                                                                                             'the '
                                                                                                             'SlideUI '
                                                                                                             'page '
                                                                                                             'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/09-SlideUI/entry/src/main/cangjie/datas/WeatherData.cj': {'slice_id': 'phase06-ui-p19-slide-ui-weather-data-model',
                                                                                                       'target_role': 'viewmodel',
                                                                                                       'slice_kind': 'support-model',
                                                                                                       'structure_tag': 'rich-component',
                                                                                                       'ownership_tag': 'view-model-renderer',
                                                                                                       'interaction_tags': [],
                                                                                                       'exception_tags': [],
                                                                                                       'sample_scope_tags': [],
                                                                                                       'usage_goal': 'P19 '
                                                                                                                     'SlideUI '
                                                                                                                     'data '
                                                                                                                     'model '
                                                                                                                     'slice '
                                                                                                                     'for '
                                                                                                                     'weather '
                                                                                                                     'data '
                                                                                                                     'items '
                                                                                                                     'consumed '
                                                                                                                     'by '
                                                                                                                     'the '
                                                                                                                     'panel '
                                                                                                                     'cards.',
                                                                                                       'notes': ['Keep '
                                                                                                                 'same-package '
                                                                                                                 'data '
                                                                                                                 'payloads '
                                                                                                                 'source-backed '
                                                                                                                 'here.',
                                                                                                                 'This '
                                                                                                                 'file '
                                                                                                                 'remains '
                                                                                                                 'a '
                                                                                                                 'renderer-facing '
                                                                                                                 'data '
                                                                                                                 'companion '
                                                                                                                 'behind '
                                                                                                                 'the '
                                                                                                                 'SlideUI '
                                                                                                                 'page '
                                                                                                                 'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/index.cj': {'slice_id': 'phase06-ui-p19-seat-selection-entry-page',
                                                                                                 'target_role': 'page',
                                                                                                 'slice_kind': 'entry-page',
                                                                                                 'structure_tag': 'page-shell',
                                                                                                 'ownership_tag': 'controller-owned-state',
                                                                                                 'interaction_tags': [],
                                                                                                 'exception_tags': [],
                                                                                                 'sample_scope_tags': [],
                                                                                                 'usage_goal': 'P19 '
                                                                                                               'SeatSelection '
                                                                                                               'host '
                                                                                                               'page '
                                                                                                               'slice '
                                                                                                               'for '
                                                                                                               'topRectHeight '
                                                                                                               'padding, '
                                                                                                               'seat-map '
                                                                                                               'composition, '
                                                                                                               'and '
                                                                                                               'same-package '
                                                                                                               'component '
                                                                                                               'wiring.',
                                                                                                 'notes': ['Keep '
                                                                                                           'AppStorage-backed '
                                                                                                           'top '
                                                                                                           'padding '
                                                                                                           'and '
                                                                                                           'seat-map '
                                                                                                           'composition '
                                                                                                           'source-backed '
                                                                                                           'in the '
                                                                                                           'host page.',
                                                                                                           'Treat '
                                                                                                           'component, '
                                                                                                           'constant, '
                                                                                                           'and '
                                                                                                           'view-model '
                                                                                                           'files as '
                                                                                                           'explicit '
                                                                                                           'companions '
                                                                                                           'behind the '
                                                                                                           'seat-selection '
                                                                                                           'page '
                                                                                                           'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/MainAbility.cj': {'slice_id': 'phase06-ui-p19-seat-selection-main-ability-model',
                                                                                                       'target_role': 'viewmodel',
                                                                                                       'slice_kind': 'support-model',
                                                                                                       'structure_tag': 'rich-component',
                                                                                                       'ownership_tag': 'controller-owned-state',
                                                                                                       'interaction_tags': [],
                                                                                                       'exception_tags': [],
                                                                                                       'sample_scope_tags': [],
                                                                                                       'usage_goal': 'P19 '
                                                                                                                     'SeatSelection '
                                                                                                                     'ability '
                                                                                                                     'model '
                                                                                                                     'for '
                                                                                                                     'fullscreen '
                                                                                                                     'layout '
                                                                                                                     'and '
                                                                                                                     'AppStorage '
                                                                                                                     'topRectHeight '
                                                                                                                     'injection '
                                                                                                                     'behind '
                                                                                                                     'the '
                                                                                                                     'entry '
                                                                                                                     'page.',
                                                                                                       'notes': ['Keep '
                                                                                                                 'AppStorage.setOrCreate '
                                                                                                                 'topRectHeight '
                                                                                                                 'source-backed '
                                                                                                                 'here.',
                                                                                                                 'This '
                                                                                                                 'file '
                                                                                                                 'remains '
                                                                                                                 'the '
                                                                                                                 'controller-facing '
                                                                                                                 'ability '
                                                                                                                 'companion '
                                                                                                                 'behind '
                                                                                                                 'the '
                                                                                                                 'seat-selection '
                                                                                                                 'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/MovieInfo.cj': {'slice_id': 'phase06-ui-p19-seat-selection-movie-info-component',
                                                                                                                'target_role': 'component',
                                                                                                                'slice_kind': 'support-component',
                                                                                                                'structure_tag': 'rich-component',
                                                                                                                'ownership_tag': 'view-model-renderer',
                                                                                                                'interaction_tags': [],
                                                                                                                'exception_tags': [],
                                                                                                                'sample_scope_tags': [],
                                                                                                                'usage_goal': 'P19 '
                                                                                                                              'SeatSelection '
                                                                                                                              'component '
                                                                                                                              'slice '
                                                                                                                              'for '
                                                                                                                              'movie '
                                                                                                                              'header '
                                                                                                                              'rendering '
                                                                                                                              'within '
                                                                                                                              'the '
                                                                                                                              'bounded '
                                                                                                                              'same-package '
                                                                                                                              'seat-selection '
                                                                                                                              'flow.',
                                                                                                                'notes': ['Keep '
                                                                                                                          'this '
                                                                                                                          'component '
                                                                                                                          'source-backed '
                                                                                                                          'inside '
                                                                                                                          'the '
                                                                                                                          'seat-selection '
                                                                                                                          'closure.',
                                                                                                                          'This '
                                                                                                                          'file '
                                                                                                                          'remains '
                                                                                                                          'an '
                                                                                                                          'explicit '
                                                                                                                          'UI '
                                                                                                                          'companion '
                                                                                                                          'behind '
                                                                                                                          'the '
                                                                                                                          'seat-selection '
                                                                                                                          'page '
                                                                                                                          'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/MyDialog.cj': {'slice_id': 'phase06-ui-p19-seat-selection-dialog-component',
                                                                                                               'target_role': 'component',
                                                                                                               'slice_kind': 'support-component',
                                                                                                               'structure_tag': 'rich-component',
                                                                                                               'ownership_tag': 'controller-owned-state',
                                                                                                               'interaction_tags': [],
                                                                                                               'exception_tags': [],
                                                                                                               'sample_scope_tags': [],
                                                                                                               'usage_goal': 'P19 '
                                                                                                                             'SeatSelection '
                                                                                                                             'component '
                                                                                                                             'slice '
                                                                                                                             'for '
                                                                                                                             'seat-confirm '
                                                                                                                             'dialog '
                                                                                                                             'state '
                                                                                                                             'and '
                                                                                                                             'LocalStorageLink '
                                                                                                                             'interaction '
                                                                                                                             'within '
                                                                                                                             'the '
                                                                                                                             'bounded '
                                                                                                                             'same-package '
                                                                                                                             'seat-selection '
                                                                                                                             'flow.',
                                                                                                               'notes': ['Keep '
                                                                                                                         'this '
                                                                                                                         'component '
                                                                                                                         'source-backed '
                                                                                                                         'inside '
                                                                                                                         'the '
                                                                                                                         'seat-selection '
                                                                                                                         'closure.',
                                                                                                                         'This '
                                                                                                                         'file '
                                                                                                                         'remains '
                                                                                                                         'an '
                                                                                                                         'explicit '
                                                                                                                         'UI '
                                                                                                                         'companion '
                                                                                                                         'behind '
                                                                                                                         'the '
                                                                                                                         'seat-selection '
                                                                                                                         'page '
                                                                                                                         'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/SeatCanvas.cj': {'slice_id': 'phase06-ui-p19-seat-selection-seat-canvas-component',
                                                                                                                 'target_role': 'component',
                                                                                                                 'slice_kind': 'primary-component',
                                                                                                                 'structure_tag': 'rich-component',
                                                                                                                 'ownership_tag': 'controller-owned-state',
                                                                                                                 'interaction_tags': [],
                                                                                                                 'exception_tags': [],
                                                                                                                 'sample_scope_tags': [],
                                                                                                                 'usage_goal': 'P19 '
                                                                                                                               'SeatSelection '
                                                                                                                               'component '
                                                                                                                               'slice '
                                                                                                                               'for '
                                                                                                                               'seat '
                                                                                                                               'canvas '
                                                                                                                               'rendering '
                                                                                                                               'and '
                                                                                                                               'local '
                                                                                                                               'seat '
                                                                                                                               'selection '
                                                                                                                               'interaction '
                                                                                                                               'within '
                                                                                                                               'the '
                                                                                                                               'bounded '
                                                                                                                               'same-package '
                                                                                                                               'seat-selection '
                                                                                                                               'flow.',
                                                                                                                 'notes': ['Keep '
                                                                                                                           'this '
                                                                                                                           'component '
                                                                                                                           'source-backed '
                                                                                                                           'inside '
                                                                                                                           'the '
                                                                                                                           'seat-selection '
                                                                                                                           'closure.',
                                                                                                                           'This '
                                                                                                                           'file '
                                                                                                                           'remains '
                                                                                                                           'an '
                                                                                                                           'explicit '
                                                                                                                           'UI '
                                                                                                                           'companion '
                                                                                                                           'behind '
                                                                                                                           'the '
                                                                                                                           'seat-selection '
                                                                                                                           'page '
                                                                                                                           'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/SeatMap.cj': {'slice_id': 'phase06-ui-p19-seat-selection-seat-map-component',
                                                                                                              'target_role': 'component',
                                                                                                              'slice_kind': 'primary-component',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'controller-owned-state',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P19 '
                                                                                                                            'SeatSelection '
                                                                                                                            'component '
                                                                                                                            'slice '
                                                                                                                            'for '
                                                                                                                            'seat '
                                                                                                                            'map '
                                                                                                                            'host '
                                                                                                                            'composition '
                                                                                                                            'within '
                                                                                                                            'the '
                                                                                                                            'bounded '
                                                                                                                            'same-package '
                                                                                                                            'seat-selection '
                                                                                                                            'flow.',
                                                                                                              'notes': ['Keep '
                                                                                                                        'this '
                                                                                                                        'component '
                                                                                                                        'source-backed '
                                                                                                                        'inside '
                                                                                                                        'the '
                                                                                                                        'seat-selection '
                                                                                                                        'closure.',
                                                                                                                        'This '
                                                                                                                        'file '
                                                                                                                        'remains '
                                                                                                                        'an '
                                                                                                                        'explicit '
                                                                                                                        'UI '
                                                                                                                        'companion '
                                                                                                                        'behind '
                                                                                                                        'the '
                                                                                                                        'seat-selection '
                                                                                                                        'page '
                                                                                                                        'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/SeatSelectionBar.cj': {'slice_id': 'phase06-ui-p19-seat-selection-seat-selection-bar-component',
                                                                                                                       'target_role': 'component',
                                                                                                                       'slice_kind': 'support-component',
                                                                                                                       'structure_tag': 'rich-component',
                                                                                                                       'ownership_tag': 'controller-owned-state',
                                                                                                                       'interaction_tags': [],
                                                                                                                       'exception_tags': [],
                                                                                                                       'sample_scope_tags': [],
                                                                                                                       'usage_goal': 'P19 '
                                                                                                                                     'SeatSelection '
                                                                                                                                     'component '
                                                                                                                                     'slice '
                                                                                                                                     'for '
                                                                                                                                     'bottom '
                                                                                                                                     'selection '
                                                                                                                                     'bar '
                                                                                                                                     'interaction '
                                                                                                                                     'within '
                                                                                                                                     'the '
                                                                                                                                     'bounded '
                                                                                                                                     'same-package '
                                                                                                                                     'seat-selection '
                                                                                                                                     'flow.',
                                                                                                                       'notes': ['Keep '
                                                                                                                                 'this '
                                                                                                                                 'component '
                                                                                                                                 'source-backed '
                                                                                                                                 'inside '
                                                                                                                                 'the '
                                                                                                                                 'seat-selection '
                                                                                                                                 'closure.',
                                                                                                                                 'This '
                                                                                                                                 'file '
                                                                                                                                 'remains '
                                                                                                                                 'an '
                                                                                                                                 'explicit '
                                                                                                                                 'UI '
                                                                                                                                 'companion '
                                                                                                                                 'behind '
                                                                                                                                 'the '
                                                                                                                                 'seat-selection '
                                                                                                                                 'page '
                                                                                                                                 'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/SelectedSeat.cj': {'slice_id': 'phase06-ui-p19-seat-selection-selected-seat-component',
                                                                                                                   'target_role': 'component',
                                                                                                                   'slice_kind': 'support-component',
                                                                                                                   'structure_tag': 'rich-component',
                                                                                                                   'ownership_tag': 'controller-owned-state',
                                                                                                                   'interaction_tags': [],
                                                                                                                   'exception_tags': [],
                                                                                                                   'sample_scope_tags': [],
                                                                                                                   'usage_goal': 'P19 '
                                                                                                                                 'SeatSelection '
                                                                                                                                 'component '
                                                                                                                                 'slice '
                                                                                                                                 'for '
                                                                                                                                 'selected-seat '
                                                                                                                                 'chip '
                                                                                                                                 'rendering '
                                                                                                                                 'within '
                                                                                                                                 'the '
                                                                                                                                 'bounded '
                                                                                                                                 'same-package '
                                                                                                                                 'seat-selection '
                                                                                                                                 'flow.',
                                                                                                                   'notes': ['Keep '
                                                                                                                             'this '
                                                                                                                             'component '
                                                                                                                             'source-backed '
                                                                                                                             'inside '
                                                                                                                             'the '
                                                                                                                             'seat-selection '
                                                                                                                             'closure.',
                                                                                                                             'This '
                                                                                                                             'file '
                                                                                                                             'remains '
                                                                                                                             'an '
                                                                                                                             'explicit '
                                                                                                                             'UI '
                                                                                                                             'companion '
                                                                                                                             'behind '
                                                                                                                             'the '
                                                                                                                             'seat-selection '
                                                                                                                             'page '
                                                                                                                             'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/card.cj': {'slice_id': 'phase06-ui-p19-seat-selection-card-component',
                                                                                                           'target_role': 'component',
                                                                                                           'slice_kind': 'support-component',
                                                                                                           'structure_tag': 'rich-component',
                                                                                                           'ownership_tag': 'controller-owned-state',
                                                                                                           'interaction_tags': [],
                                                                                                           'exception_tags': [],
                                                                                                           'sample_scope_tags': [],
                                                                                                           'usage_goal': 'P19 '
                                                                                                                         'SeatSelection '
                                                                                                                         'component '
                                                                                                                         'slice '
                                                                                                                         'for '
                                                                                                                         'movie '
                                                                                                                         'card '
                                                                                                                         'and '
                                                                                                                         'selected '
                                                                                                                         'seat '
                                                                                                                         'summary '
                                                                                                                         'rendering '
                                                                                                                         'within '
                                                                                                                         'the '
                                                                                                                         'bounded '
                                                                                                                         'same-package '
                                                                                                                         'seat-selection '
                                                                                                                         'flow.',
                                                                                                           'notes': ['Keep '
                                                                                                                     'this '
                                                                                                                     'component '
                                                                                                                     'source-backed '
                                                                                                                     'inside '
                                                                                                                     'the '
                                                                                                                     'seat-selection '
                                                                                                                     'closure.',
                                                                                                                     'This '
                                                                                                                     'file '
                                                                                                                     'remains '
                                                                                                                     'an '
                                                                                                                     'explicit '
                                                                                                                     'UI '
                                                                                                                     'companion '
                                                                                                                     'behind '
                                                                                                                     'the '
                                                                                                                     'seat-selection '
                                                                                                                     'page '
                                                                                                                     'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/tag.cj': {'slice_id': 'phase06-ui-p19-seat-selection-tag-component',
                                                                                                          'target_role': 'component',
                                                                                                          'slice_kind': 'support-component',
                                                                                                          'structure_tag': 'rich-component',
                                                                                                          'ownership_tag': 'view-model-renderer',
                                                                                                          'interaction_tags': [],
                                                                                                          'exception_tags': [],
                                                                                                          'sample_scope_tags': [],
                                                                                                          'usage_goal': 'P19 '
                                                                                                                        'SeatSelection '
                                                                                                                        'component '
                                                                                                                        'slice '
                                                                                                                        'for '
                                                                                                                        'tag '
                                                                                                                        'rendering '
                                                                                                                        'within '
                                                                                                                        'the '
                                                                                                                        'bounded '
                                                                                                                        'same-package '
                                                                                                                        'seat-selection '
                                                                                                                        'flow.',
                                                                                                          'notes': ['Keep '
                                                                                                                    'this '
                                                                                                                    'component '
                                                                                                                    'source-backed '
                                                                                                                    'inside '
                                                                                                                    'the '
                                                                                                                    'seat-selection '
                                                                                                                    'closure.',
                                                                                                                    'This '
                                                                                                                    'file '
                                                                                                                    'remains '
                                                                                                                    'an '
                                                                                                                    'explicit '
                                                                                                                    'UI '
                                                                                                                    'companion '
                                                                                                                    'behind '
                                                                                                                    'the '
                                                                                                                    'seat-selection '
                                                                                                                    'page '
                                                                                                                    'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/components/title.cj': {'slice_id': 'phase06-ui-p19-seat-selection-title-component',
                                                                                                            'target_role': 'component',
                                                                                                            'slice_kind': 'support-component',
                                                                                                            'structure_tag': 'rich-component',
                                                                                                            'ownership_tag': 'view-model-renderer',
                                                                                                            'interaction_tags': [],
                                                                                                            'exception_tags': [],
                                                                                                            'sample_scope_tags': [],
                                                                                                            'usage_goal': 'P19 '
                                                                                                                          'SeatSelection '
                                                                                                                          'component '
                                                                                                                          'slice '
                                                                                                                          'for '
                                                                                                                          'title/header '
                                                                                                                          'rendering '
                                                                                                                          'within '
                                                                                                                          'the '
                                                                                                                          'bounded '
                                                                                                                          'same-package '
                                                                                                                          'seat-selection '
                                                                                                                          'flow.',
                                                                                                            'notes': ['Keep '
                                                                                                                      'this '
                                                                                                                      'component '
                                                                                                                      'source-backed '
                                                                                                                      'inside '
                                                                                                                      'the '
                                                                                                                      'seat-selection '
                                                                                                                      'closure.',
                                                                                                                      'This '
                                                                                                                      'file '
                                                                                                                      'remains '
                                                                                                                      'an '
                                                                                                                      'explicit '
                                                                                                                      'UI '
                                                                                                                      'companion '
                                                                                                                      'behind '
                                                                                                                      'the '
                                                                                                                      'seat-selection '
                                                                                                                      'page '
                                                                                                                      'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/constants/AreaInfo.cj': {'slice_id': 'phase06-ui-p19-seat-selection-area-info-model',
                                                                                                              'target_role': 'viewmodel',
                                                                                                              'slice_kind': 'support-model',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'view-model-renderer',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P19 '
                                                                                                                            'SeatSelection '
                                                                                                                            'support '
                                                                                                                            'model '
                                                                                                                            'for '
                                                                                                                            'area '
                                                                                                                            'info '
                                                                                                                            'consumed '
                                                                                                                            'by '
                                                                                                                            'the '
                                                                                                                            'seat-map '
                                                                                                                            'components.',
                                                                                                              'notes': ['Keep '
                                                                                                                        'constants '
                                                                                                                        'and '
                                                                                                                        'static '
                                                                                                                        'seat '
                                                                                                                        'metadata '
                                                                                                                        'source-backed '
                                                                                                                        'here.',
                                                                                                                        'This '
                                                                                                                        'file '
                                                                                                                        'remains '
                                                                                                                        'a '
                                                                                                                        'renderer-facing '
                                                                                                                        'support '
                                                                                                                        'model '
                                                                                                                        'behind '
                                                                                                                        'the '
                                                                                                                        'seat-selection '
                                                                                                                        'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/constants/DataConstants.cj': {'slice_id': 'phase06-ui-p19-seat-selection-data-constants-model',
                                                                                                                   'target_role': 'viewmodel',
                                                                                                                   'slice_kind': 'support-model',
                                                                                                                   'structure_tag': 'rich-component',
                                                                                                                   'ownership_tag': 'view-model-renderer',
                                                                                                                   'interaction_tags': [],
                                                                                                                   'exception_tags': [],
                                                                                                                   'sample_scope_tags': [],
                                                                                                                   'usage_goal': 'P19 '
                                                                                                                                 'SeatSelection '
                                                                                                                                 'support '
                                                                                                                                 'model '
                                                                                                                                 'for '
                                                                                                                                 'data '
                                                                                                                                 'constants '
                                                                                                                                 'consumed '
                                                                                                                                 'by '
                                                                                                                                 'the '
                                                                                                                                 'seat-map '
                                                                                                                                 'components.',
                                                                                                                   'notes': ['Keep '
                                                                                                                             'constants '
                                                                                                                             'and '
                                                                                                                             'static '
                                                                                                                             'seat '
                                                                                                                             'metadata '
                                                                                                                             'source-backed '
                                                                                                                             'here.',
                                                                                                                             'This '
                                                                                                                             'file '
                                                                                                                             'remains '
                                                                                                                             'a '
                                                                                                                             'renderer-facing '
                                                                                                                             'support '
                                                                                                                             'model '
                                                                                                                             'behind '
                                                                                                                             'the '
                                                                                                                             'seat-selection '
                                                                                                                             'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/constants/SeatInfo.cj': {'slice_id': 'phase06-ui-p19-seat-selection-seat-info-model',
                                                                                                              'target_role': 'viewmodel',
                                                                                                              'slice_kind': 'support-model',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'view-model-renderer',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P19 '
                                                                                                                            'SeatSelection '
                                                                                                                            'support '
                                                                                                                            'model '
                                                                                                                            'for '
                                                                                                                            'seat '
                                                                                                                            'info '
                                                                                                                            'consumed '
                                                                                                                            'by '
                                                                                                                            'the '
                                                                                                                            'seat-map '
                                                                                                                            'components.',
                                                                                                              'notes': ['Keep '
                                                                                                                        'constants '
                                                                                                                        'and '
                                                                                                                        'static '
                                                                                                                        'seat '
                                                                                                                        'metadata '
                                                                                                                        'source-backed '
                                                                                                                        'here.',
                                                                                                                        'This '
                                                                                                                        'file '
                                                                                                                        'remains '
                                                                                                                        'a '
                                                                                                                        'renderer-facing '
                                                                                                                        'support '
                                                                                                                        'model '
                                                                                                                        'behind '
                                                                                                                        'the '
                                                                                                                        'seat-selection '
                                                                                                                        'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/constants/SeatType.cj': {'slice_id': 'phase06-ui-p19-seat-selection-seat-type-model',
                                                                                                              'target_role': 'viewmodel',
                                                                                                              'slice_kind': 'support-model',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'view-model-renderer',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P19 '
                                                                                                                            'SeatSelection '
                                                                                                                            'support '
                                                                                                                            'model '
                                                                                                                            'for '
                                                                                                                            'seat '
                                                                                                                            'type '
                                                                                                                            'consumed '
                                                                                                                            'by '
                                                                                                                            'the '
                                                                                                                            'seat-map '
                                                                                                                            'components.',
                                                                                                              'notes': ['Keep '
                                                                                                                        'constants '
                                                                                                                        'and '
                                                                                                                        'static '
                                                                                                                        'seat '
                                                                                                                        'metadata '
                                                                                                                        'source-backed '
                                                                                                                        'here.',
                                                                                                                        'This '
                                                                                                                        'file '
                                                                                                                        'remains '
                                                                                                                        'a '
                                                                                                                        'renderer-facing '
                                                                                                                        'support '
                                                                                                                        'model '
                                                                                                                        'behind '
                                                                                                                        'the '
                                                                                                                        'seat-selection '
                                                                                                                        'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/constants/StyleConstants.cj': {'slice_id': 'phase06-ui-p19-seat-selection-style-constants-model',
                                                                                                                    'target_role': 'viewmodel',
                                                                                                                    'slice_kind': 'support-model',
                                                                                                                    'structure_tag': 'rich-component',
                                                                                                                    'ownership_tag': 'view-model-renderer',
                                                                                                                    'interaction_tags': [],
                                                                                                                    'exception_tags': [],
                                                                                                                    'sample_scope_tags': [],
                                                                                                                    'usage_goal': 'P19 '
                                                                                                                                  'SeatSelection '
                                                                                                                                  'support '
                                                                                                                                  'model '
                                                                                                                                  'for '
                                                                                                                                  'style '
                                                                                                                                  'constants '
                                                                                                                                  'consumed '
                                                                                                                                  'by '
                                                                                                                                  'the '
                                                                                                                                  'seat-map '
                                                                                                                                  'components.',
                                                                                                                    'notes': ['Keep '
                                                                                                                              'constants '
                                                                                                                              'and '
                                                                                                                              'static '
                                                                                                                              'seat '
                                                                                                                              'metadata '
                                                                                                                              'source-backed '
                                                                                                                              'here.',
                                                                                                                              'This '
                                                                                                                              'file '
                                                                                                                              'remains '
                                                                                                                              'a '
                                                                                                                              'renderer-facing '
                                                                                                                              'support '
                                                                                                                              'model '
                                                                                                                              'behind '
                                                                                                                              'the '
                                                                                                                              'seat-selection '
                                                                                                                              'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/13-SeatSelection/entry/src/main/cangjie/view_model/SeatSelection.cj': {'slice_id': 'phase06-ui-p19-seat-selection-view-model',
                                                                                                                    'target_role': 'viewmodel',
                                                                                                                    'slice_kind': 'support-model',
                                                                                                                    'structure_tag': 'rich-component',
                                                                                                                    'ownership_tag': 'controller-owned-state',
                                                                                                                    'interaction_tags': [],
                                                                                                                    'exception_tags': [],
                                                                                                                    'sample_scope_tags': [],
                                                                                                                    'usage_goal': 'P19 '
                                                                                                                                  'SeatSelection '
                                                                                                                                  'state '
                                                                                                                                  'model '
                                                                                                                                  'for '
                                                                                                                                  'selected-seat '
                                                                                                                                  'ownership, '
                                                                                                                                  'availability '
                                                                                                                                  'checks, '
                                                                                                                                  'and '
                                                                                                                                  'LocalStorageLink-backed '
                                                                                                                                  'interaction '
                                                                                                                                  'state.',
                                                                                                                    'notes': ['Keep '
                                                                                                                              'seat-selection '
                                                                                                                              'mutation '
                                                                                                                              'and '
                                                                                                                              'derived '
                                                                                                                              'availability '
                                                                                                                              'state '
                                                                                                                              'source-backed '
                                                                                                                              'here.',
                                                                                                                              'This '
                                                                                                                              'file '
                                                                                                                              'remains '
                                                                                                                              'the '
                                                                                                                              'controller-facing '
                                                                                                                              'state '
                                                                                                                              'companion '
                                                                                                                              'behind '
                                                                                                                              'the '
                                                                                                                              'seat-selection '
                                                                                                                              'page '
                                                                                                                              'shell.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/index.cj': {'slice_id': 'phase06-ui-p19-chat-ui-entry-page',
                                                                                              'target_role': 'page',
                                                                                              'slice_kind': 'entry-page',
                                                                                              'structure_tag': 'page-shell',
                                                                                              'ownership_tag': 'controller-owned-state',
                                                                                              'interaction_tags': [],
                                                                                              'exception_tags': [],
                                                                                              'sample_scope_tags': [],
                                                                                              'usage_goal': 'P19 '
                                                                                                            'ChatUI '
                                                                                                            'host page '
                                                                                                            'slice for '
                                                                                                            'active '
                                                                                                            'tab '
                                                                                                            'ownership, '
                                                                                                            'page-shell '
                                                                                                            'composition, '
                                                                                                            'and '
                                                                                                            'same-package '
                                                                                                            'chat/friend/dynamic '
                                                                                                            'wiring.',
                                                                                              'notes': ['Keep active '
                                                                                                        'tab state and '
                                                                                                        'page-shell '
                                                                                                        'composition '
                                                                                                        'source-backed '
                                                                                                        'in the host '
                                                                                                        'page.',
                                                                                                        'Treat '
                                                                                                        'route-target '
                                                                                                        'pages, '
                                                                                                        'components, '
                                                                                                        'store, '
                                                                                                        'entity, mock, '
                                                                                                        'and util '
                                                                                                        'files as '
                                                                                                        'explicit '
                                                                                                        'companions '
                                                                                                        'behind the '
                                                                                                        'ChatUI '
                                                                                                        'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/pages/ChatView.cj': {'slice_id': 'phase06-ui-p19-chat-ui-chat-view-page',
                                                                                                       'target_role': 'page',
                                                                                                       'slice_kind': 'entry-page',
                                                                                                       'structure_tag': 'page-shell',
                                                                                                       'ownership_tag': 'controller-owned-state',
                                                                                                       'interaction_tags': [],
                                                                                                       'exception_tags': [],
                                                                                                       'sample_scope_tags': [],
                                                                                                       'usage_goal': 'P19 '
                                                                                                                     'ChatUI '
                                                                                                                     'route-target '
                                                                                                                     'page '
                                                                                                                     'slice '
                                                                                                                     'for '
                                                                                                                     'message-list '
                                                                                                                     'ownership, '
                                                                                                                     'CURRENT_CHAT/TARGET_USER '
                                                                                                                     'handoff, '
                                                                                                                     'and '
                                                                                                                     'chat '
                                                                                                                     'input '
                                                                                                                     'composition.',
                                                                                                       'notes': ['Keep '
                                                                                                                 'route-target '
                                                                                                                 'page '
                                                                                                                 'behavior '
                                                                                                                 'source-backed '
                                                                                                                 'instead '
                                                                                                                 'of '
                                                                                                                 'leaving '
                                                                                                                 'Router.push '
                                                                                                                 'without '
                                                                                                                 'its '
                                                                                                                 'destination '
                                                                                                                 'page.',
                                                                                                                 'This '
                                                                                                                 'file '
                                                                                                                 'remains '
                                                                                                                 'an '
                                                                                                                 'explicit '
                                                                                                                 'page '
                                                                                                                 'companion '
                                                                                                                 'inside '
                                                                                                                 'the '
                                                                                                                 'ChatUI '
                                                                                                                 'same-package '
                                                                                                                 'closure.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/avatar/Avatar.cj': {'slice_id': 'phase06-ui-p19-chat-ui-avatar-component',
                                                                                                                 'target_role': 'component',
                                                                                                                 'slice_kind': 'support-component',
                                                                                                                 'structure_tag': 'rich-component',
                                                                                                                 'ownership_tag': 'view-model-renderer',
                                                                                                                 'interaction_tags': [],
                                                                                                                 'exception_tags': [],
                                                                                                                 'sample_scope_tags': [],
                                                                                                                 'usage_goal': 'P19 '
                                                                                                                               'ChatUI '
                                                                                                                               'component '
                                                                                                                               'slice '
                                                                                                                               'for '
                                                                                                                               'avatar '
                                                                                                                               'rendering '
                                                                                                                               'inside '
                                                                                                                               'the '
                                                                                                                               'bounded '
                                                                                                                               'chat-route '
                                                                                                                               'same-package '
                                                                                                                               'closure.',
                                                                                                                 'notes': ['Keep '
                                                                                                                           'this '
                                                                                                                           'component '
                                                                                                                           'source-backed '
                                                                                                                           'inside '
                                                                                                                           'the '
                                                                                                                           'ChatUI '
                                                                                                                           'closure.',
                                                                                                                           'This '
                                                                                                                           'file '
                                                                                                                           'remains '
                                                                                                                           'an '
                                                                                                                           'explicit '
                                                                                                                           'UI '
                                                                                                                           'companion '
                                                                                                                           'behind '
                                                                                                                           'the '
                                                                                                                           'ChatUI '
                                                                                                                           'page '
                                                                                                                           'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/badge/Badge.cj': {'slice_id': 'phase06-ui-p19-chat-ui-badge-component',
                                                                                                               'target_role': 'component',
                                                                                                               'slice_kind': 'support-component',
                                                                                                               'structure_tag': 'rich-component',
                                                                                                               'ownership_tag': 'view-model-renderer',
                                                                                                               'interaction_tags': [],
                                                                                                               'exception_tags': [],
                                                                                                               'sample_scope_tags': [],
                                                                                                               'usage_goal': 'P19 '
                                                                                                                             'ChatUI '
                                                                                                                             'component '
                                                                                                                             'slice '
                                                                                                                             'for '
                                                                                                                             'badge/count '
                                                                                                                             'rendering '
                                                                                                                             'inside '
                                                                                                                             'the '
                                                                                                                             'bounded '
                                                                                                                             'chat-route '
                                                                                                                             'same-package '
                                                                                                                             'closure.',
                                                                                                               'notes': ['Keep '
                                                                                                                         'this '
                                                                                                                         'component '
                                                                                                                         'source-backed '
                                                                                                                         'inside '
                                                                                                                         'the '
                                                                                                                         'ChatUI '
                                                                                                                         'closure.',
                                                                                                                         'This '
                                                                                                                         'file '
                                                                                                                         'remains '
                                                                                                                         'an '
                                                                                                                         'explicit '
                                                                                                                         'UI '
                                                                                                                         'companion '
                                                                                                                         'behind '
                                                                                                                         'the '
                                                                                                                         'ChatUI '
                                                                                                                         'page '
                                                                                                                         'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/chat/ChatLine.cj': {'slice_id': 'phase06-ui-p19-chat-ui-chat-line-component',
                                                                                                                 'target_role': 'component',
                                                                                                                 'slice_kind': 'support-component',
                                                                                                                 'structure_tag': 'rich-component',
                                                                                                                 'ownership_tag': 'view-model-renderer',
                                                                                                                 'interaction_tags': [],
                                                                                                                 'exception_tags': [],
                                                                                                                 'sample_scope_tags': [],
                                                                                                                 'usage_goal': 'P19 '
                                                                                                                               'ChatUI '
                                                                                                                               'component '
                                                                                                                               'slice '
                                                                                                                               'for '
                                                                                                                               'chat '
                                                                                                                               'line '
                                                                                                                               'rendering '
                                                                                                                               'inside '
                                                                                                                               'the '
                                                                                                                               'bounded '
                                                                                                                               'chat-route '
                                                                                                                               'same-package '
                                                                                                                               'closure.',
                                                                                                                 'notes': ['Keep '
                                                                                                                           'this '
                                                                                                                           'component '
                                                                                                                           'source-backed '
                                                                                                                           'inside '
                                                                                                                           'the '
                                                                                                                           'ChatUI '
                                                                                                                           'closure.',
                                                                                                                           'This '
                                                                                                                           'file '
                                                                                                                           'remains '
                                                                                                                           'an '
                                                                                                                           'explicit '
                                                                                                                           'UI '
                                                                                                                           'companion '
                                                                                                                           'behind '
                                                                                                                           'the '
                                                                                                                           'ChatUI '
                                                                                                                           'page '
                                                                                                                           'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/chat/ChatList.cj': {'slice_id': 'phase06-ui-p19-chat-ui-chat-list-component',
                                                                                                                 'target_role': 'component',
                                                                                                                 'slice_kind': 'primary-component',
                                                                                                                 'structure_tag': 'rich-component',
                                                                                                                 'ownership_tag': 'controller-owned-state',
                                                                                                                 'interaction_tags': [],
                                                                                                                 'exception_tags': [],
                                                                                                                 'sample_scope_tags': [],
                                                                                                                 'usage_goal': 'P19 '
                                                                                                                               'ChatUI '
                                                                                                                               'component '
                                                                                                                               'slice '
                                                                                                                               'for '
                                                                                                                               'chat '
                                                                                                                               'list '
                                                                                                                               'ownership '
                                                                                                                               'and '
                                                                                                                               'Router.push '
                                                                                                                               'handoff '
                                                                                                                               'inside '
                                                                                                                               'the '
                                                                                                                               'bounded '
                                                                                                                               'chat-route '
                                                                                                                               'same-package '
                                                                                                                               'closure.',
                                                                                                                 'notes': ['Keep '
                                                                                                                           'this '
                                                                                                                           'component '
                                                                                                                           'source-backed '
                                                                                                                           'inside '
                                                                                                                           'the '
                                                                                                                           'ChatUI '
                                                                                                                           'closure.',
                                                                                                                           'This '
                                                                                                                           'file '
                                                                                                                           'remains '
                                                                                                                           'an '
                                                                                                                           'explicit '
                                                                                                                           'UI '
                                                                                                                           'companion '
                                                                                                                           'behind '
                                                                                                                           'the '
                                                                                                                           'ChatUI '
                                                                                                                           'page '
                                                                                                                           'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/chat/ChatListItem.cj': {'slice_id': 'phase06-ui-p19-chat-ui-chat-list-item-component',
                                                                                                                     'target_role': 'component',
                                                                                                                     'slice_kind': 'support-component',
                                                                                                                     'structure_tag': 'rich-component',
                                                                                                                     'ownership_tag': 'view-model-renderer',
                                                                                                                     'interaction_tags': [],
                                                                                                                     'exception_tags': [],
                                                                                                                     'sample_scope_tags': [],
                                                                                                                     'usage_goal': 'P19 '
                                                                                                                                   'ChatUI '
                                                                                                                                   'component '
                                                                                                                                   'slice '
                                                                                                                                   'for '
                                                                                                                                   'chat '
                                                                                                                                   'list '
                                                                                                                                   'item '
                                                                                                                                   'rendering '
                                                                                                                                   'inside '
                                                                                                                                   'the '
                                                                                                                                   'bounded '
                                                                                                                                   'chat-route '
                                                                                                                                   'same-package '
                                                                                                                                   'closure.',
                                                                                                                     'notes': ['Keep '
                                                                                                                               'this '
                                                                                                                               'component '
                                                                                                                               'source-backed '
                                                                                                                               'inside '
                                                                                                                               'the '
                                                                                                                               'ChatUI '
                                                                                                                               'closure.',
                                                                                                                               'This '
                                                                                                                               'file '
                                                                                                                               'remains '
                                                                                                                               'an '
                                                                                                                               'explicit '
                                                                                                                               'UI '
                                                                                                                               'companion '
                                                                                                                               'behind '
                                                                                                                               'the '
                                                                                                                               'ChatUI '
                                                                                                                               'page '
                                                                                                                               'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/dynamic/DynamicList.cj': {'slice_id': 'phase06-ui-p19-chat-ui-dynamic-list-component',
                                                                                                                       'target_role': 'component',
                                                                                                                       'slice_kind': 'primary-component',
                                                                                                                       'structure_tag': 'rich-component',
                                                                                                                       'ownership_tag': 'controller-owned-state',
                                                                                                                       'interaction_tags': [],
                                                                                                                       'exception_tags': [],
                                                                                                                       'sample_scope_tags': [],
                                                                                                                       'usage_goal': 'P19 '
                                                                                                                                     'ChatUI '
                                                                                                                                     'component '
                                                                                                                                     'slice '
                                                                                                                                     'for '
                                                                                                                                     'dynamic '
                                                                                                                                     'feed '
                                                                                                                                     'composition '
                                                                                                                                     'inside '
                                                                                                                                     'the '
                                                                                                                                     'bounded '
                                                                                                                                     'chat-route '
                                                                                                                                     'same-package '
                                                                                                                                     'closure.',
                                                                                                                       'notes': ['Keep '
                                                                                                                                 'this '
                                                                                                                                 'component '
                                                                                                                                 'source-backed '
                                                                                                                                 'inside '
                                                                                                                                 'the '
                                                                                                                                 'ChatUI '
                                                                                                                                 'closure.',
                                                                                                                                 'This '
                                                                                                                                 'file '
                                                                                                                                 'remains '
                                                                                                                                 'an '
                                                                                                                                 'explicit '
                                                                                                                                 'UI '
                                                                                                                                 'companion '
                                                                                                                                 'behind '
                                                                                                                                 'the '
                                                                                                                                 'ChatUI '
                                                                                                                                 'page '
                                                                                                                                 'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/friend/FriendBar.cj': {'slice_id': 'phase06-ui-p19-chat-ui-friend-bar-component',
                                                                                                                    'target_role': 'component',
                                                                                                                    'slice_kind': 'support-component',
                                                                                                                    'structure_tag': 'rich-component',
                                                                                                                    'ownership_tag': 'view-model-renderer',
                                                                                                                    'interaction_tags': [],
                                                                                                                    'exception_tags': [],
                                                                                                                    'sample_scope_tags': [],
                                                                                                                    'usage_goal': 'P19 '
                                                                                                                                  'ChatUI '
                                                                                                                                  'component '
                                                                                                                                  'slice '
                                                                                                                                  'for '
                                                                                                                                  'friend '
                                                                                                                                  'bar '
                                                                                                                                  'rendering '
                                                                                                                                  'inside '
                                                                                                                                  'the '
                                                                                                                                  'bounded '
                                                                                                                                  'chat-route '
                                                                                                                                  'same-package '
                                                                                                                                  'closure.',
                                                                                                                    'notes': ['Keep '
                                                                                                                              'this '
                                                                                                                              'component '
                                                                                                                              'source-backed '
                                                                                                                              'inside '
                                                                                                                              'the '
                                                                                                                              'ChatUI '
                                                                                                                              'closure.',
                                                                                                                              'This '
                                                                                                                              'file '
                                                                                                                              'remains '
                                                                                                                              'an '
                                                                                                                              'explicit '
                                                                                                                              'UI '
                                                                                                                              'companion '
                                                                                                                              'behind '
                                                                                                                              'the '
                                                                                                                              'ChatUI '
                                                                                                                              'page '
                                                                                                                              'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/friend/FriendList.cj': {'slice_id': 'phase06-ui-p19-chat-ui-friend-list-component',
                                                                                                                     'target_role': 'component',
                                                                                                                     'slice_kind': 'primary-component',
                                                                                                                     'structure_tag': 'rich-component',
                                                                                                                     'ownership_tag': 'controller-owned-state',
                                                                                                                     'interaction_tags': [],
                                                                                                                     'exception_tags': [],
                                                                                                                     'sample_scope_tags': [],
                                                                                                                     'usage_goal': 'P19 '
                                                                                                                                   'ChatUI '
                                                                                                                                   'component '
                                                                                                                                   'slice '
                                                                                                                                   'for '
                                                                                                                                   'friend '
                                                                                                                                   'list '
                                                                                                                                   'composition '
                                                                                                                                   'inside '
                                                                                                                                   'the '
                                                                                                                                   'bounded '
                                                                                                                                   'chat-route '
                                                                                                                                   'same-package '
                                                                                                                                   'closure.',
                                                                                                                     'notes': ['Keep '
                                                                                                                               'this '
                                                                                                                               'component '
                                                                                                                               'source-backed '
                                                                                                                               'inside '
                                                                                                                               'the '
                                                                                                                               'ChatUI '
                                                                                                                               'closure.',
                                                                                                                               'This '
                                                                                                                               'file '
                                                                                                                               'remains '
                                                                                                                               'an '
                                                                                                                               'explicit '
                                                                                                                               'UI '
                                                                                                                               'companion '
                                                                                                                               'behind '
                                                                                                                               'the '
                                                                                                                               'ChatUI '
                                                                                                                               'page '
                                                                                                                               'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/friend/FriendListItem.cj': {'slice_id': 'phase06-ui-p19-chat-ui-friend-list-item-component',
                                                                                                                         'target_role': 'component',
                                                                                                                         'slice_kind': 'support-component',
                                                                                                                         'structure_tag': 'rich-component',
                                                                                                                         'ownership_tag': 'view-model-renderer',
                                                                                                                         'interaction_tags': [],
                                                                                                                         'exception_tags': [],
                                                                                                                         'sample_scope_tags': [],
                                                                                                                         'usage_goal': 'P19 '
                                                                                                                                       'ChatUI '
                                                                                                                                       'component '
                                                                                                                                       'slice '
                                                                                                                                       'for '
                                                                                                                                       'friend '
                                                                                                                                       'list '
                                                                                                                                       'item '
                                                                                                                                       'rendering '
                                                                                                                                       'inside '
                                                                                                                                       'the '
                                                                                                                                       'bounded '
                                                                                                                                       'chat-route '
                                                                                                                                       'same-package '
                                                                                                                                       'closure.',
                                                                                                                         'notes': ['Keep '
                                                                                                                                   'this '
                                                                                                                                   'component '
                                                                                                                                   'source-backed '
                                                                                                                                   'inside '
                                                                                                                                   'the '
                                                                                                                                   'ChatUI '
                                                                                                                                   'closure.',
                                                                                                                                   'This '
                                                                                                                                   'file '
                                                                                                                                   'remains '
                                                                                                                                   'an '
                                                                                                                                   'explicit '
                                                                                                                                   'UI '
                                                                                                                                   'companion '
                                                                                                                                   'behind '
                                                                                                                                   'the '
                                                                                                                                   'ChatUI '
                                                                                                                                   'page '
                                                                                                                                   'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/friend/FriendTab.cj': {'slice_id': 'phase06-ui-p19-chat-ui-friend-tab-component',
                                                                                                                    'target_role': 'component',
                                                                                                                    'slice_kind': 'support-component',
                                                                                                                    'structure_tag': 'rich-component',
                                                                                                                    'ownership_tag': 'controller-owned-state',
                                                                                                                    'interaction_tags': [],
                                                                                                                    'exception_tags': [],
                                                                                                                    'sample_scope_tags': [],
                                                                                                                    'usage_goal': 'P19 '
                                                                                                                                  'ChatUI '
                                                                                                                                  'component '
                                                                                                                                  'slice '
                                                                                                                                  'for '
                                                                                                                                  'friend '
                                                                                                                                  'tab '
                                                                                                                                  'list '
                                                                                                                                  'composition '
                                                                                                                                  'inside '
                                                                                                                                  'the '
                                                                                                                                  'bounded '
                                                                                                                                  'chat-route '
                                                                                                                                  'same-package '
                                                                                                                                  'closure.',
                                                                                                                    'notes': ['Keep '
                                                                                                                              'this '
                                                                                                                              'component '
                                                                                                                              'source-backed '
                                                                                                                              'inside '
                                                                                                                              'the '
                                                                                                                              'ChatUI '
                                                                                                                              'closure.',
                                                                                                                              'This '
                                                                                                                              'file '
                                                                                                                              'remains '
                                                                                                                              'an '
                                                                                                                              'explicit '
                                                                                                                              'UI '
                                                                                                                              'companion '
                                                                                                                              'behind '
                                                                                                                              'the '
                                                                                                                              'ChatUI '
                                                                                                                              'page '
                                                                                                                              'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/components/index/TabBar.cj': {'slice_id': 'phase06-ui-p19-chat-ui-tab-bar-component',
                                                                                                                'target_role': 'component',
                                                                                                                'slice_kind': 'support-component',
                                                                                                                'structure_tag': 'rich-component',
                                                                                                                'ownership_tag': 'controller-owned-state',
                                                                                                                'interaction_tags': [],
                                                                                                                'exception_tags': [],
                                                                                                                'sample_scope_tags': [],
                                                                                                                'usage_goal': 'P19 '
                                                                                                                              'ChatUI '
                                                                                                                              'component '
                                                                                                                              'slice '
                                                                                                                              'for '
                                                                                                                              'tab '
                                                                                                                              'bar '
                                                                                                                              'interaction '
                                                                                                                              'and '
                                                                                                                              'tab '
                                                                                                                              'switching '
                                                                                                                              'affordance '
                                                                                                                              'inside '
                                                                                                                              'the '
                                                                                                                              'bounded '
                                                                                                                              'chat-route '
                                                                                                                              'same-package '
                                                                                                                              'closure.',
                                                                                                                'notes': ['Keep '
                                                                                                                          'this '
                                                                                                                          'component '
                                                                                                                          'source-backed '
                                                                                                                          'inside '
                                                                                                                          'the '
                                                                                                                          'ChatUI '
                                                                                                                          'closure.',
                                                                                                                          'This '
                                                                                                                          'file '
                                                                                                                          'remains '
                                                                                                                          'an '
                                                                                                                          'explicit '
                                                                                                                          'UI '
                                                                                                                          'companion '
                                                                                                                          'behind '
                                                                                                                          'the '
                                                                                                                          'ChatUI '
                                                                                                                          'page '
                                                                                                                          'shells.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/entity/Chat.cj': {'slice_id': 'phase06-ui-p19-chat-ui-chat-model',
                                                                                                    'target_role': 'viewmodel',
                                                                                                    'slice_kind': 'support-model',
                                                                                                    'structure_tag': 'rich-component',
                                                                                                    'ownership_tag': 'view-model-renderer',
                                                                                                    'interaction_tags': [],
                                                                                                    'exception_tags': [],
                                                                                                    'sample_scope_tags': [],
                                                                                                    'usage_goal': 'P19 '
                                                                                                                  'ChatUI '
                                                                                                                  'support '
                                                                                                                  'model '
                                                                                                                  'for '
                                                                                                                  'chat '
                                                                                                                  'entity '
                                                                                                                  'ownership '
                                                                                                                  'behind '
                                                                                                                  'the '
                                                                                                                  'page '
                                                                                                                  'shells '
                                                                                                                  'and '
                                                                                                                  'component '
                                                                                                                  'set.',
                                                                                                    'notes': ['Keep '
                                                                                                              'same-package '
                                                                                                              'data/store/helper '
                                                                                                              'files '
                                                                                                              'source-backed '
                                                                                                              'here.',
                                                                                                              'This '
                                                                                                              'file '
                                                                                                              'remains '
                                                                                                              'a '
                                                                                                              'support '
                                                                                                              'model '
                                                                                                              'companion '
                                                                                                              'behind '
                                                                                                              'the '
                                                                                                              'ChatUI '
                                                                                                              'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/entity/Group.cj': {'slice_id': 'phase06-ui-p19-chat-ui-group-model',
                                                                                                     'target_role': 'viewmodel',
                                                                                                     'slice_kind': 'support-model',
                                                                                                     'structure_tag': 'rich-component',
                                                                                                     'ownership_tag': 'view-model-renderer',
                                                                                                     'interaction_tags': [],
                                                                                                     'exception_tags': [],
                                                                                                     'sample_scope_tags': [],
                                                                                                     'usage_goal': 'P19 '
                                                                                                                   'ChatUI '
                                                                                                                   'support '
                                                                                                                   'model '
                                                                                                                   'for '
                                                                                                                   'group '
                                                                                                                   'entity '
                                                                                                                   'ownership '
                                                                                                                   'behind '
                                                                                                                   'the '
                                                                                                                   'page '
                                                                                                                   'shells '
                                                                                                                   'and '
                                                                                                                   'component '
                                                                                                                   'set.',
                                                                                                     'notes': ['Keep '
                                                                                                               'same-package '
                                                                                                               'data/store/helper '
                                                                                                               'files '
                                                                                                               'source-backed '
                                                                                                               'here.',
                                                                                                               'This '
                                                                                                               'file '
                                                                                                               'remains '
                                                                                                               'a '
                                                                                                               'support '
                                                                                                               'model '
                                                                                                               'companion '
                                                                                                               'behind '
                                                                                                               'the '
                                                                                                               'ChatUI '
                                                                                                               'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/entity/Message.cj': {'slice_id': 'phase06-ui-p19-chat-ui-message-model',
                                                                                                       'target_role': 'viewmodel',
                                                                                                       'slice_kind': 'support-model',
                                                                                                       'structure_tag': 'rich-component',
                                                                                                       'ownership_tag': 'view-model-renderer',
                                                                                                       'interaction_tags': [],
                                                                                                       'exception_tags': [],
                                                                                                       'sample_scope_tags': [],
                                                                                                       'usage_goal': 'P19 '
                                                                                                                     'ChatUI '
                                                                                                                     'support '
                                                                                                                     'model '
                                                                                                                     'for '
                                                                                                                     'message '
                                                                                                                     'entity '
                                                                                                                     'ownership '
                                                                                                                     'behind '
                                                                                                                     'the '
                                                                                                                     'page '
                                                                                                                     'shells '
                                                                                                                     'and '
                                                                                                                     'component '
                                                                                                                     'set.',
                                                                                                       'notes': ['Keep '
                                                                                                                 'same-package '
                                                                                                                 'data/store/helper '
                                                                                                                 'files '
                                                                                                                 'source-backed '
                                                                                                                 'here.',
                                                                                                                 'This '
                                                                                                                 'file '
                                                                                                                 'remains '
                                                                                                                 'a '
                                                                                                                 'support '
                                                                                                                 'model '
                                                                                                                 'companion '
                                                                                                                 'behind '
                                                                                                                 'the '
                                                                                                                 'ChatUI '
                                                                                                                 'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/entity/User.cj': {'slice_id': 'phase06-ui-p19-chat-ui-user-model',
                                                                                                    'target_role': 'viewmodel',
                                                                                                    'slice_kind': 'support-model',
                                                                                                    'structure_tag': 'rich-component',
                                                                                                    'ownership_tag': 'view-model-renderer',
                                                                                                    'interaction_tags': [],
                                                                                                    'exception_tags': [],
                                                                                                    'sample_scope_tags': [],
                                                                                                    'usage_goal': 'P19 '
                                                                                                                  'ChatUI '
                                                                                                                  'support '
                                                                                                                  'model '
                                                                                                                  'for '
                                                                                                                  'user '
                                                                                                                  'entity '
                                                                                                                  'ownership '
                                                                                                                  'behind '
                                                                                                                  'the '
                                                                                                                  'page '
                                                                                                                  'shells '
                                                                                                                  'and '
                                                                                                                  'component '
                                                                                                                  'set.',
                                                                                                    'notes': ['Keep '
                                                                                                              'same-package '
                                                                                                              'data/store/helper '
                                                                                                              'files '
                                                                                                              'source-backed '
                                                                                                              'here.',
                                                                                                              'This '
                                                                                                              'file '
                                                                                                              'remains '
                                                                                                              'a '
                                                                                                              'support '
                                                                                                              'model '
                                                                                                              'companion '
                                                                                                              'behind '
                                                                                                              'the '
                                                                                                              'ChatUI '
                                                                                                              'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/global/store.cj': {'slice_id': 'phase06-ui-p19-chat-ui-store-model',
                                                                                                     'target_role': 'viewmodel',
                                                                                                     'slice_kind': 'support-model',
                                                                                                     'structure_tag': 'rich-component',
                                                                                                     'ownership_tag': 'controller-owned-state',
                                                                                                     'interaction_tags': [],
                                                                                                     'exception_tags': [],
                                                                                                     'sample_scope_tags': [],
                                                                                                     'usage_goal': 'P19 '
                                                                                                                   'ChatUI '
                                                                                                                   'support '
                                                                                                                   'model '
                                                                                                                   'for '
                                                                                                                   'CURRENT_CHAT/TARGET_USER '
                                                                                                                   'store '
                                                                                                                   'ownership '
                                                                                                                   'behind '
                                                                                                                   'the '
                                                                                                                   'page '
                                                                                                                   'shells '
                                                                                                                   'and '
                                                                                                                   'component '
                                                                                                                   'set.',
                                                                                                     'notes': ['Keep '
                                                                                                               'same-package '
                                                                                                               'data/store/helper '
                                                                                                               'files '
                                                                                                               'source-backed '
                                                                                                               'here.',
                                                                                                               'This '
                                                                                                               'file '
                                                                                                               'remains '
                                                                                                               'a '
                                                                                                               'support '
                                                                                                               'model '
                                                                                                               'companion '
                                                                                                               'behind '
                                                                                                               'the '
                                                                                                               'ChatUI '
                                                                                                               'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/mock/dataMock.cj': {'slice_id': 'phase06-ui-p19-chat-ui-data-mock-model',
                                                                                                      'target_role': 'viewmodel',
                                                                                                      'slice_kind': 'support-model',
                                                                                                      'structure_tag': 'rich-component',
                                                                                                      'ownership_tag': 'view-model-renderer',
                                                                                                      'interaction_tags': [],
                                                                                                      'exception_tags': [],
                                                                                                      'sample_scope_tags': [],
                                                                                                      'usage_goal': 'P19 '
                                                                                                                    'ChatUI '
                                                                                                                    'support '
                                                                                                                    'model '
                                                                                                                    'for '
                                                                                                                    'mock '
                                                                                                                    'chat/friend/group '
                                                                                                                    'fixture '
                                                                                                                    'data '
                                                                                                                    'behind '
                                                                                                                    'the '
                                                                                                                    'page '
                                                                                                                    'shells '
                                                                                                                    'and '
                                                                                                                    'component '
                                                                                                                    'set.',
                                                                                                      'notes': ['Keep '
                                                                                                                'same-package '
                                                                                                                'data/store/helper '
                                                                                                                'files '
                                                                                                                'source-backed '
                                                                                                                'here.',
                                                                                                                'This '
                                                                                                                'file '
                                                                                                                'remains '
                                                                                                                'a '
                                                                                                                'support '
                                                                                                                'model '
                                                                                                                'companion '
                                                                                                                'behind '
                                                                                                                'the '
                                                                                                                'ChatUI '
                                                                                                                'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/util/dataSource.cj': {'slice_id': 'phase06-ui-p19-chat-ui-data-source-model',
                                                                                                        'target_role': 'viewmodel',
                                                                                                        'slice_kind': 'support-model',
                                                                                                        'structure_tag': 'rich-component',
                                                                                                        'ownership_tag': 'view-model-renderer',
                                                                                                        'interaction_tags': [],
                                                                                                        'exception_tags': [],
                                                                                                        'sample_scope_tags': [],
                                                                                                        'usage_goal': 'P19 '
                                                                                                                      'ChatUI '
                                                                                                                      'support '
                                                                                                                      'model '
                                                                                                                      'for '
                                                                                                                      'lazy '
                                                                                                                      'data '
                                                                                                                      'source '
                                                                                                                      'support '
                                                                                                                      'behind '
                                                                                                                      'the '
                                                                                                                      'page '
                                                                                                                      'shells '
                                                                                                                      'and '
                                                                                                                      'component '
                                                                                                                      'set.',
                                                                                                        'notes': ['Keep '
                                                                                                                  'same-package '
                                                                                                                  'data/store/helper '
                                                                                                                  'files '
                                                                                                                  'source-backed '
                                                                                                                  'here.',
                                                                                                                  'This '
                                                                                                                  'file '
                                                                                                                  'remains '
                                                                                                                  'a '
                                                                                                                  'support '
                                                                                                                  'model '
                                                                                                                  'companion '
                                                                                                                  'behind '
                                                                                                                  'the '
                                                                                                                  'ChatUI '
                                                                                                                  'lane.']},
 'raw_docs/phase06-ui-p19/HarmonyOS-Examples/05-ChatUI/entry/src/main/cangjie/src/util/variable.cj': {'slice_id': 'phase06-ui-p19-chat-ui-variable-model',
                                                                                                      'target_role': 'viewmodel',
                                                                                                      'slice_kind': 'support-model',
                                                                                                      'structure_tag': 'rich-component',
                                                                                                      'ownership_tag': 'view-model-renderer',
                                                                                                      'interaction_tags': [],
                                                                                                      'exception_tags': [],
                                                                                                      'sample_scope_tags': [],
                                                                                                      'usage_goal': 'P19 '
                                                                                                                    'ChatUI '
                                                                                                                    'support '
                                                                                                                    'model '
                                                                                                                    'for '
                                                                                                                    'shared '
                                                                                                                    'visual '
                                                                                                                    'constants '
                                                                                                                    'and '
                                                                                                                    'variables '
                                                                                                                    'behind '
                                                                                                                    'the '
                                                                                                                    'page '
                                                                                                                    'shells '
                                                                                                                    'and '
                                                                                                                    'component '
                                                                                                                    'set.',
                                                                                                      'notes': ['Keep '
                                                                                                                'same-package '
                                                                                                                'data/store/helper '
                                                                                                                'files '
                                                                                                                'source-backed '
                                                                                                                'here.',
                                                                                                                'This '
                                                                                                                'file '
                                                                                                                'remains '
                                                                                                                'a '
                                                                                                                'support '
                                                                                                                'model '
                                                                                                                'companion '
                                                                                                                'behind '
                                                                                                                'the '
                                                                                                                'ChatUI '
                                                                                                                'lane.']}})
# P19 regular mechanical-readiness overrides end

FILE_SLICE_OVERRIDES.update({'raw_docs/phase06-ui-p20/HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/index.cj': {'slice_id': 'phase06-ui-p20-slowfeet-entry-page',
                                                                                                  'target_role': 'page',
                                                                                                  'slice_kind': 'entry-page',
                                                                                                  'structure_tag': 'page-shell',
                                                                                                  'ownership_tag': 'view-model-renderer',
                                                                                                  'interaction_tags': [],
                                                                                                  'exception_tags': [],
                                                                                                  'sample_scope_tags': [],
                                                                                                  'usage_goal': 'P20 SlowFeet host page for the same-package '
                                                                                                                'tabbed shell and local route fan-out selected '
                                                                                                                'by the official scout.',
                                                                                                  'notes': ['Generated from the scout-selected P20 freeze set.',
                                                                                                            'Keep the tabbed host and direct route imports '
                                                                                                            'source-backed instead of collapsing the sample to '
                                                                                                            'one visual shell.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/Pages/chat.cj': {'slice_id': 'phase06-ui-p20-slowfeet-chat-route-page',
                                                                                                       'target_role': 'page',
                                                                                                       'slice_kind': 'entry-page',
                                                                                                       'structure_tag': 'page-shell',
                                                                                                       'ownership_tag': 'controller-owned-state',
                                                                                                       'interaction_tags': [],
                                                                                                       'exception_tags': [],
                                                                                                       'sample_scope_tags': [],
                                                                                                       'usage_goal': 'P20 SlowFeet route-target page for chat '
                                                                                                                     'state, back-navigation, and same-package '
                                                                                                                     'model wiring behind the tab host.',
                                                                                                       'notes': ['Generated from the scout-selected P20 freeze '
                                                                                                                 'set.',
                                                                                                                 'Keep the route-target page and local model '
                                                                                                                 'contract source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/Pages/user.cj': {'slice_id': 'phase06-ui-p20-slowfeet-user-route-page',
                                                                                                       'target_role': 'page',
                                                                                                       'slice_kind': 'entry-page',
                                                                                                       'structure_tag': 'page-shell',
                                                                                                       'ownership_tag': 'controller-owned-state',
                                                                                                       'interaction_tags': [],
                                                                                                       'exception_tags': [],
                                                                                                       'sample_scope_tags': [],
                                                                                                       'usage_goal': 'P20 SlowFeet route-target page for '
                                                                                                                     'profile rendering, collection state, and '
                                                                                                                     'same-package model wiring behind the tab '
                                                                                                                     'host.',
                                                                                                       'notes': ['Generated from the scout-selected P20 freeze '
                                                                                                                 'set.',
                                                                                                                 'Keep the route-target page and local model '
                                                                                                                 'contract source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/Pages/video.cj': {'slice_id': 'phase06-ui-p20-slowfeet-video-route-page',
                                                                                                        'target_role': 'page',
                                                                                                        'slice_kind': 'entry-page',
                                                                                                        'structure_tag': 'page-shell',
                                                                                                        'ownership_tag': 'controller-owned-state',
                                                                                                        'interaction_tags': [],
                                                                                                        'exception_tags': [],
                                                                                                        'sample_scope_tags': [],
                                                                                                        'usage_goal': 'P20 SlowFeet route-target page for '
                                                                                                                      'video feed state and same-package model '
                                                                                                                      'wiring behind the tab host.',
                                                                                                        'notes': ['Generated from the scout-selected P20 '
                                                                                                                  'freeze set.',
                                                                                                                  'Keep the route-target page and local model '
                                                                                                                  'contract source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/Model/ChatModel.cj': {'slice_id': 'phase06-ui-p20-slowfeet-chat-model',
                                                                                                            'target_role': 'viewmodel',
                                                                                                            'slice_kind': 'support-model',
                                                                                                            'structure_tag': 'rich-component',
                                                                                                            'ownership_tag': 'view-model-renderer',
                                                                                                            'interaction_tags': [],
                                                                                                            'exception_tags': [],
                                                                                                            'sample_scope_tags': [],
                                                                                                            'usage_goal': 'P20 SlowFeet support model for chat '
                                                                                                                          'item state consumed by the '
                                                                                                                          'route-target page.',
                                                                                                            'notes': ['Generated from the scout-selected P20 '
                                                                                                                      'freeze set.',
                                                                                                                      'Keep same-package support state files '
                                                                                                                      'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/KuaiShouUI/SlowFeet/src/main/cangjie/src/Model/VideoModel.cj': {'slice_id': 'phase06-ui-p20-slowfeet-video-model',
                                                                                                             'target_role': 'viewmodel',
                                                                                                             'slice_kind': 'support-model',
                                                                                                             'structure_tag': 'rich-component',
                                                                                                             'ownership_tag': 'view-model-renderer',
                                                                                                             'interaction_tags': [],
                                                                                                             'exception_tags': [],
                                                                                                             'sample_scope_tags': [],
                                                                                                             'usage_goal': 'P20 SlowFeet support model for '
                                                                                                                           'video card state consumed by the '
                                                                                                                           'route-target page.',
                                                                                                             'notes': ['Generated from the scout-selected P20 '
                                                                                                                       'freeze set.',
                                                                                                                       'Keep same-package support state files '
                                                                                                                       'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/index.cj': {'slice_id': 'phase06-ui-p20-adaptive-ui-entry-page',
                                                                                                  'target_role': 'page',
                                                                                                  'slice_kind': 'entry-page',
                                                                                                  'structure_tag': 'page-shell',
                                                                                                  'ownership_tag': 'controller-owned-state',
                                                                                                  'interaction_tags': [],
                                                                                                  'exception_tags': [],
                                                                                                  'sample_scope_tags': [],
                                                                                                  'usage_goal': 'P20 AdaptiveUI entry page for timer-backed '
                                                                                                                'progress, responsive layout orchestration, '
                                                                                                                'and local component composition.',
                                                                                                  'notes': ['Generated from the scout-selected P20 freeze set.',
                                                                                                            'Keep timer-driven page state and same-package '
                                                                                                            'component composition source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/main_ability.cj': {'slice_id': 'phase06-ui-p20-adaptive-ui-main-ability-model',
                                                                                                         'target_role': 'viewmodel',
                                                                                                         'slice_kind': 'support-model',
                                                                                                         'structure_tag': 'rich-component',
                                                                                                         'ownership_tag': 'controller-owned-state',
                                                                                                         'interaction_tags': [],
                                                                                                         'exception_tags': [],
                                                                                                         'sample_scope_tags': [],
                                                                                                         'usage_goal': 'P20 AdaptiveUI support model for '
                                                                                                                       'MainAbility device-type detection and '
                                                                                                                       'AppStorage handoff.',
                                                                                                         'notes': ['Generated from the scout-selected P20 '
                                                                                                                   'freeze set.',
                                                                                                                   'Keep MainAbility wiring source-backed '
                                                                                                                   'instead of treating the sample as '
                                                                                                                   'page-only.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/common/constants.cj': {'slice_id': 'phase06-ui-p20-adaptive-ui-constants-model',
                                                                                                             'target_role': 'viewmodel',
                                                                                                             'slice_kind': 'support-model',
                                                                                                             'structure_tag': 'rich-component',
                                                                                                             'ownership_tag': 'view-model-renderer',
                                                                                                             'interaction_tags': [],
                                                                                                             'exception_tags': [],
                                                                                                             'sample_scope_tags': [],
                                                                                                             'usage_goal': 'P20 AdaptiveUI support model for '
                                                                                                                           'local layout and playback '
                                                                                                                           'constants used by the entry page '
                                                                                                                           'and components.',
                                                                                                             'notes': ['Generated from the scout-selected P20 '
                                                                                                                       'freeze set.',
                                                                                                                       'Keep same-package constant helpers '
                                                                                                                       'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/component/content.cj': {'slice_id': 'phase06-ui-p20-adaptive-ui-content-component',
                                                                                                              'target_role': 'component',
                                                                                                              'slice_kind': 'primary-component',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'controller-owned-state',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P20 AdaptiveUI primary component '
                                                                                                                            'for responsive playlist/content '
                                                                                                                            'layout driven by AppStorage and '
                                                                                                                            'same-package state.',
                                                                                                              'notes': ['Generated from the scout-selected P20 '
                                                                                                                        'freeze set.',
                                                                                                                        'Keep the main responsive content '
                                                                                                                        'component source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/component/header.cj': {'slice_id': 'phase06-ui-p20-adaptive-ui-header-component',
                                                                                                             'target_role': 'component',
                                                                                                             'slice_kind': 'support-component',
                                                                                                             'structure_tag': 'rich-component',
                                                                                                             'ownership_tag': 'view-model-renderer',
                                                                                                             'interaction_tags': [],
                                                                                                             'exception_tags': [],
                                                                                                             'sample_scope_tags': [],
                                                                                                             'usage_goal': 'P20 AdaptiveUI support component '
                                                                                                                           'for the local header rendering '
                                                                                                                           'contract used by the entry page.',
                                                                                                             'notes': ['Generated from the scout-selected P20 '
                                                                                                                       'freeze set.',
                                                                                                                       'Keep same-package rendering components '
                                                                                                                       'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/component/pannel.cj': {'slice_id': 'phase06-ui-p20-adaptive-ui-panel-component',
                                                                                                             'target_role': 'component',
                                                                                                             'slice_kind': 'primary-component',
                                                                                                             'structure_tag': 'rich-component',
                                                                                                             'ownership_tag': 'controller-owned-state',
                                                                                                             'interaction_tags': [],
                                                                                                             'exception_tags': [],
                                                                                                             'sample_scope_tags': [],
                                                                                                             'usage_goal': 'P20 AdaptiveUI primary component '
                                                                                                                           'for playback controls and linked '
                                                                                                                           'progress state under the '
                                                                                                                           'timer-backed page shell.',
                                                                                                             'notes': ['Generated from the scout-selected P20 '
                                                                                                                       'freeze set.',
                                                                                                                       'Keep the linked control component '
                                                                                                                       'source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/utils/hilog.cj': {'slice_id': 'phase06-ui-p20-adaptive-ui-hilog-helper',
                                                                                                        'target_role': 'viewmodel',
                                                                                                        'slice_kind': 'support-model',
                                                                                                        'structure_tag': 'rich-component',
                                                                                                        'ownership_tag': 'view-model-renderer',
                                                                                                        'interaction_tags': [],
                                                                                                        'exception_tags': [],
                                                                                                        'sample_scope_tags': [],
                                                                                                        'usage_goal': 'P20 AdaptiveUI helper for local logging '
                                                                                                                      'support referenced by the ability and '
                                                                                                                      'layout utilities.',
                                                                                                        'notes': ['Generated from the scout-selected P20 '
                                                                                                                  'freeze set.',
                                                                                                                  'Keep same-package utility helpers '
                                                                                                                  'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/08-AdaptiveUI/entry/src/main/cangjie/src/utils/windows_manager.cj': {'slice_id': 'phase06-ui-p20-adaptive-ui-window-manager-helper',
                                                                                                                  'target_role': 'viewmodel',
                                                                                                                  'slice_kind': 'support-model',
                                                                                                                  'structure_tag': 'rich-component',
                                                                                                                  'ownership_tag': 'view-model-renderer',
                                                                                                                  'interaction_tags': [],
                                                                                                                  'exception_tags': [],
                                                                                                                  'sample_scope_tags': [],
                                                                                                                  'usage_goal': 'P20 AdaptiveUI helper for '
                                                                                                                                'window-size driven device '
                                                                                                                                'classification behind the '
                                                                                                                                'responsive page shell.',
                                                                                                                  'notes': ['Generated from the scout-selected '
                                                                                                                            'P20 freeze set.',
                                                                                                                            'Keep same-package utility helpers '
                                                                                                                            'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/index.cj': {'slice_id': 'phase06-ui-p20-order-ui-entry-page',
                                                                                            'target_role': 'page',
                                                                                            'slice_kind': 'entry-page',
                                                                                            'structure_tag': 'page-shell',
                                                                                            'ownership_tag': 'controller-owned-state',
                                                                                            'interaction_tags': [],
                                                                                            'exception_tags': [],
                                                                                            'sample_scope_tags': [],
                                                                                            'usage_goal': 'P20 OrderUI entry page for safe-area/AppStorage '
                                                                                                          'shell wiring and same-package home-tab '
                                                                                                          'composition.',
                                                                                            'notes': ['Generated from the scout-selected P20 freeze set.',
                                                                                                      'Keep the host page and safe-area wiring '
                                                                                                      'source-backed instead of collapsing the sample '
                                                                                                      'to one visual shell.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/main_ability.cj': {'slice_id': 'phase06-ui-p20-order-ui-main-ability-model',
                                                                                                   'target_role': 'viewmodel',
                                                                                                   'slice_kind': 'support-model',
                                                                                                   'structure_tag': 'rich-component',
                                                                                                   'ownership_tag': 'controller-owned-state',
                                                                                                   'interaction_tags': [],
                                                                                                   'exception_tags': [],
                                                                                                   'sample_scope_tags': [],
                                                                                                   'usage_goal': 'P20 OrderUI support model for '
                                                                                                                 'MainAbility window setup, breakpoint updates, '
                                                                                                                 'and avoid-area injection.',
                                                                                                   'notes': ['Generated from the scout-selected P20 '
                                                                                                             'freeze set.',
                                                                                                             'Keep MainAbility window/AppStorage wiring '
                                                                                                             'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/api/ShopApi.cj': {'slice_id': 'phase06-ui-p20-order-ui-shop-api-model',
                                                                                                  'target_role': 'viewmodel',
                                                                                                  'slice_kind': 'support-model',
                                                                                                  'structure_tag': 'rich-component',
                                                                                                  'ownership_tag': 'view-model-renderer',
                                                                                                  'interaction_tags': [],
                                                                                                  'exception_tags': [],
                                                                                                  'sample_scope_tags': [],
                                                                                                  'usage_goal': 'P20 OrderUI support model for local '
                                                                                                                'mock shop data loading behind the '
                                                                                                                'same-package home tab flow.',
                                                                                                  'notes': ['Generated from the scout-selected P20 '
                                                                                                            'freeze set.',
                                                                                                            'Keep same-package data-loader helpers '
                                                                                                            'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/home.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-tabs-component',
                                                                                                           'target_role': 'component',
                                                                                                           'slice_kind': 'primary-component',
                                                                                                           'structure_tag': 'rich-component',
                                                                                                           'ownership_tag': 'controller-owned-state',
                                                                                                           'interaction_tags': [],
                                                                                                           'exception_tags': [],
                                                                                                           'sample_scope_tags': [],
                                                                                                           'usage_goal': 'P20 OrderUI primary component for '
                                                                                                                         'home-tab state, tab switching, and '
                                                                                                                         'nested same-package component '
                                                                                                                         'composition.',
                                                                                                           'notes': ['Generated from the scout-selected P20 '
                                                                                                                     'freeze set.',
                                                                                                                     'Keep the tab-host component source-backed '
                                                                                                                     'here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/homeBanner.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-banner-component',
                                                                                                                 'target_role': 'component',
                                                                                                                 'slice_kind': 'support-component',
                                                                                                                 'structure_tag': 'rich-component',
                                                                                                                 'ownership_tag': 'view-model-renderer',
                                                                                                                 'interaction_tags': [],
                                                                                                                 'exception_tags': [],
                                                                                                                 'sample_scope_tags': [],
                                                                                                                 'usage_goal': 'P20 OrderUI support component '
                                                                                                                               'for responsive home banner '
                                                                                                                               'rendering within the home tab '
                                                                                                                               'closure.',
                                                                                                                 'notes': ['Generated from the scout-selected '
                                                                                                                           'P20 freeze set.',
                                                                                                                           'Keep same-package rendering '
                                                                                                                           'components source-backed for the '
                                                                                                                           'P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/homeContent.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-content-component',
                                                                                                                  'target_role': 'component',
                                                                                                                  'slice_kind': 'primary-component',
                                                                                                                  'structure_tag': 'rich-component',
                                                                                                                  'ownership_tag': 'controller-owned-state',
                                                                                                                  'interaction_tags': [],
                                                                                                                  'exception_tags': [],
                                                                                                                  'sample_scope_tags': [],
                                                                                                                  'usage_goal': 'P20 OrderUI primary component '
                                                                                                                                'for home-content state, mock '
                                                                                                                                'data loading, and shop list '
                                                                                                                                'orchestration.',
                                                                                                                  'notes': ['Generated from the scout-selected '
                                                                                                                            'P20 freeze set.',
                                                                                                                            'Keep the data-loading content '
                                                                                                                            'component source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/homeHeader.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-header-component',
                                                                                                                 'target_role': 'component',
                                                                                                                 'slice_kind': 'support-component',
                                                                                                                 'structure_tag': 'rich-component',
                                                                                                                 'ownership_tag': 'view-model-renderer',
                                                                                                                 'interaction_tags': [],
                                                                                                                 'exception_tags': [],
                                                                                                                 'sample_scope_tags': [],
                                                                                                                 'usage_goal': 'P20 OrderUI support component '
                                                                                                                               'for responsive home header '
                                                                                                                               'rendering within the home tab '
                                                                                                                               'closure.',
                                                                                                                 'notes': ['Generated from the scout-selected '
                                                                                                                           'P20 freeze set.',
                                                                                                                           'Keep same-package rendering '
                                                                                                                           'components source-backed for the '
                                                                                                                           'P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/homeMenu.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-menu-component',
                                                                                                               'target_role': 'component',
                                                                                                               'slice_kind': 'support-component',
                                                                                                               'structure_tag': 'rich-component',
                                                                                                               'ownership_tag': 'controller-owned-state',
                                                                                                               'interaction_tags': [],
                                                                                                               'exception_tags': [],
                                                                                                               'sample_scope_tags': [],
                                                                                                               'usage_goal': 'P20 OrderUI support component for '
                                                                                                                             'breakpoint-aware home menu '
                                                                                                                             'rendering within the home tab '
                                                                                                                             'closure.',
                                                                                                               'notes': ['Generated from the scout-selected P20 '
                                                                                                                         'freeze set.',
                                                                                                                         'Keep same-package rendering '
                                                                                                                         'components source-backed for the P20 '
                                                                                                                         'lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/homePosition.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-position-component',
                                                                                                                   'target_role': 'component',
                                                                                                                   'slice_kind': 'support-component',
                                                                                                                   'structure_tag': 'rich-component',
                                                                                                                   'ownership_tag': 'view-model-renderer',
                                                                                                                   'interaction_tags': [],
                                                                                                                   'exception_tags': [],
                                                                                                                   'sample_scope_tags': [],
                                                                                                                   'usage_goal': 'P20 OrderUI support component '
                                                                                                                                 'for local position/header '
                                                                                                                                 'rendering within the home tab '
                                                                                                                                 'closure.',
                                                                                                                   'notes': ['Generated from the scout-selected '
                                                                                                                             'P20 freeze set.',
                                                                                                                             'Keep same-package rendering '
                                                                                                                             'components source-backed for the '
                                                                                                                             'P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/homeSearch.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-search-component',
                                                                                                                 'target_role': 'component',
                                                                                                                 'slice_kind': 'support-component',
                                                                                                                 'structure_tag': 'rich-component',
                                                                                                                 'ownership_tag': 'view-model-renderer',
                                                                                                                 'interaction_tags': [],
                                                                                                                 'exception_tags': [],
                                                                                                                 'sample_scope_tags': [],
                                                                                                                 'usage_goal': 'P20 OrderUI support component '
                                                                                                                               'for the local search bar contract '
                                                                                                                               'within the home tab closure.',
                                                                                                                 'notes': ['Generated from the scout-selected '
                                                                                                                           'P20 freeze set.',
                                                                                                                           'Keep same-package rendering '
                                                                                                                           'components source-backed for the '
                                                                                                                           'P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/homeShopList.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-shop-list-component',
                                                                                                                   'target_role': 'component',
                                                                                                                   'slice_kind': 'primary-component',
                                                                                                                   'structure_tag': 'rich-component',
                                                                                                                   'ownership_tag': 'controller-owned-state',
                                                                                                                   'interaction_tags': [],
                                                                                                                   'exception_tags': [],
                                                                                                                   'sample_scope_tags': [],
                                                                                                                   'usage_goal': 'P20 OrderUI primary component '
                                                                                                                                 'for shop-list rendering, '
                                                                                                                                 'responsive layout, and product '
                                                                                                                                 'data binding within the home tab '
                                                                                                                                 'closure.',
                                                                                                                   'notes': ['Generated from the scout-selected '
                                                                                                                             'P20 freeze set.',
                                                                                                                             'Keep the main shop-list component '
                                                                                                                             'source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/home/homeShopRecommend.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-shop-recommend-component',
                                                                                                                        'target_role': 'component',
                                                                                                                        'slice_kind': 'primary-component',
                                                                                                                        'structure_tag': 'rich-component',
                                                                                                                        'ownership_tag': 'controller-owned-state',
                                                                                                                        'interaction_tags': [],
                                                                                                                        'exception_tags': [],
                                                                                                                        'sample_scope_tags': [],
                                                                                                                        'usage_goal': 'P20 OrderUI primary '
                                                                                                                                      'component for '
                                                                                                                                      'recommended-shop rendering '
                                                                                                                                      'and breakpoint-aware builder '
                                                                                                                                      'composition within the home '
                                                                                                                                      'tab closure.',
                                                                                                                        'notes': ['Generated from the '
                                                                                                                                  'scout-selected P20 freeze '
                                                                                                                                  'set.',
                                                                                                                                  'Keep the recommendation '
                                                                                                                                  'component source-backed here.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/me/me.cj': {'slice_id': 'phase06-ui-p20-order-ui-me-tab-component',
                                                                                                       'target_role': 'component',
                                                                                                       'slice_kind': 'support-component',
                                                                                                       'structure_tag': 'rich-component',
                                                                                                       'ownership_tag': 'view-model-renderer',
                                                                                                       'interaction_tags': [],
                                                                                                       'exception_tags': [],
                                                                                                       'sample_scope_tags': [],
                                                                                                       'usage_goal': 'P20 OrderUI support component for the '
                                                                                                                     'local Me tab content under the shared '
                                                                                                                     'tab host.',
                                                                                                       'notes': ['Generated from the scout-selected P20 '
                                                                                                                 'freeze set.',
                                                                                                                 'Keep same-package tab components '
                                                                                                                 'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/components/message/message.cj': {'slice_id': 'phase06-ui-p20-order-ui-message-tab-component',
                                                                                                                 'target_role': 'component',
                                                                                                                 'slice_kind': 'support-component',
                                                                                                                 'structure_tag': 'rich-component',
                                                                                                                 'ownership_tag': 'view-model-renderer',
                                                                                                                 'interaction_tags': [],
                                                                                                                 'exception_tags': [],
                                                                                                                 'sample_scope_tags': [],
                                                                                                                 'usage_goal': 'P20 OrderUI support component '
                                                                                                                               'for the local Message tab content '
                                                                                                                               'under the shared tab host.',
                                                                                                                 'notes': ['Generated from the scout-selected '
                                                                                                                           'P20 freeze set.',
                                                                                                                           'Keep same-package tab components '
                                                                                                                           'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/constants/baseConstants.cj': {'slice_id': 'phase06-ui-p20-order-ui-base-constants-model',
                                                                                                              'target_role': 'viewmodel',
                                                                                                              'slice_kind': 'support-model',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'view-model-renderer',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P20 OrderUI support model for '
                                                                                                                            'shared base constants used across '
                                                                                                                            'the home-tab closure.',
                                                                                                              'notes': ['Generated from the scout-selected P20 '
                                                                                                                        'freeze set.',
                                                                                                                        'Keep same-package constant helpers '
                                                                                                                        'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/constants/breakpointConstants.cj': {'slice_id': 'phase06-ui-p20-order-ui-breakpoint-constants-model',
                                                                                                                    'target_role': 'viewmodel',
                                                                                                                    'slice_kind': 'support-model',
                                                                                                                    'structure_tag': 'rich-component',
                                                                                                                    'ownership_tag': 'view-model-renderer',
                                                                                                                    'interaction_tags': [],
                                                                                                                    'exception_tags': [],
                                                                                                                    'sample_scope_tags': [],
                                                                                                                    'usage_goal': 'P20 OrderUI support model '
                                                                                                                                  'for breakpoint constants '
                                                                                                                                  'used by the responsive '
                                                                                                                                  'home-tab closure.',
                                                                                                                    'notes': ['Generated from the '
                                                                                                                              'scout-selected P20 freeze set.',
                                                                                                                              'Keep same-package constant '
                                                                                                                              'helpers source-backed for the '
                                                                                                                              'P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/constants/homeConstants.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-constants-model',
                                                                                                              'target_role': 'viewmodel',
                                                                                                              'slice_kind': 'support-model',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'view-model-renderer',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P20 OrderUI support model for '
                                                                                                                            'shared home-tab mock data and '
                                                                                                                            'constants referenced by the '
                                                                                                                            'same-package components.',
                                                                                                              'notes': ['Generated from the scout-selected P20 '
                                                                                                                        'freeze set.',
                                                                                                                        'Keep same-package constant helpers '
                                                                                                                        'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/models/homeMenuModel.cj': {'slice_id': 'phase06-ui-p20-order-ui-home-menu-model',
                                                                                                           'target_role': 'viewmodel',
                                                                                                           'slice_kind': 'support-model',
                                                                                                           'structure_tag': 'rich-component',
                                                                                                           'ownership_tag': 'view-model-renderer',
                                                                                                           'interaction_tags': [],
                                                                                                           'exception_tags': [],
                                                                                                           'sample_scope_tags': [],
                                                                                                           'usage_goal': 'P20 OrderUI support model for home '
                                                                                                                         'menu data consumed by the responsive '
                                                                                                                         'home-tab components.',
                                                                                                           'notes': ['Generated from the scout-selected P20 '
                                                                                                                     'freeze set.',
                                                                                                                     'Keep same-package support state files '
                                                                                                                     'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/models/productInfoModel.cj': {'slice_id': 'phase06-ui-p20-order-ui-product-info-model',
                                                                                                              'target_role': 'viewmodel',
                                                                                                              'slice_kind': 'support-model',
                                                                                                              'structure_tag': 'rich-component',
                                                                                                              'ownership_tag': 'view-model-renderer',
                                                                                                              'interaction_tags': [],
                                                                                                              'exception_tags': [],
                                                                                                              'sample_scope_tags': [],
                                                                                                              'usage_goal': 'P20 OrderUI support model for '
                                                                                                                            'product data consumed by the home '
                                                                                                                            'shop list.',
                                                                                                              'notes': ['Generated from the scout-selected P20 '
                                                                                                                        'freeze set.',
                                                                                                                        'Keep same-package support state files '
                                                                                                                        'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/models/shopInfoModel.cj': {'slice_id': 'phase06-ui-p20-order-ui-shop-info-model',
                                                                                                           'target_role': 'viewmodel',
                                                                                                           'slice_kind': 'support-model',
                                                                                                           'structure_tag': 'rich-component',
                                                                                                           'ownership_tag': 'view-model-renderer',
                                                                                                           'interaction_tags': [],
                                                                                                           'exception_tags': [],
                                                                                                           'sample_scope_tags': [],
                                                                                                           'usage_goal': 'P20 OrderUI support model for shop '
                                                                                                                         'data consumed by the home components '
                                                                                                                         'and ShopApi helper.',
                                                                                                           'notes': ['Generated from the scout-selected P20 '
                                                                                                                     'freeze set.',
                                                                                                                     'Keep same-package support state files '
                                                                                                                     'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/models/tab.cj': {'slice_id': 'phase06-ui-p20-order-ui-tab-model',
                                                                                                 'target_role': 'viewmodel',
                                                                                                 'slice_kind': 'support-model',
                                                                                                 'structure_tag': 'rich-component',
                                                                                                 'ownership_tag': 'view-model-renderer',
                                                                                                 'interaction_tags': [],
                                                                                                 'exception_tags': [],
                                                                                                 'sample_scope_tags': [],
                                                                                                 'usage_goal': 'P20 OrderUI support model for tab metadata '
                                                                                                               'consumed by the home-tab host component.',
                                                                                                 'notes': ['Generated from the scout-selected P20 freeze set.',
                                                                                                           'Keep same-package support state files '
                                                                                                           'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/models/temp.cj': {'slice_id': 'phase06-ui-p20-order-ui-temp-model',
                                                                                                  'target_role': 'viewmodel',
                                                                                                  'slice_kind': 'support-model',
                                                                                                  'structure_tag': 'rich-component',
                                                                                                  'ownership_tag': 'view-model-renderer',
                                                                                                  'interaction_tags': [],
                                                                                                  'exception_tags': [],
                                                                                                  'sample_scope_tags': [],
                                                                                                  'usage_goal': 'P20 OrderUI support model for local '
                                                                                                                'placeholder/tab data consumed by the home-tab '
                                                                                                                'host component.',
                                                                                                  'notes': ['Generated from the scout-selected P20 freeze set.',
                                                                                                            'Keep same-package support state files '
                                                                                                            'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/utils/BreakpointType.cj': {'slice_id': 'phase06-ui-p20-order-ui-breakpoint-type-helper',
                                                                                                           'target_role': 'viewmodel',
                                                                                                           'slice_kind': 'support-model',
                                                                                                           'structure_tag': 'rich-component',
                                                                                                           'ownership_tag': 'view-model-renderer',
                                                                                                           'interaction_tags': [],
                                                                                                           'exception_tags': [],
                                                                                                           'sample_scope_tags': [],
                                                                                                           'usage_goal': 'P20 OrderUI helper for '
                                                                                                                         'breakpoint-aware resource selection '
                                                                                                                         'inside the responsive home-tab '
                                                                                                                         'closure.',
                                                                                                           'notes': ['Generated from the scout-selected P20 '
                                                                                                                     'freeze set.',
                                                                                                                     'Keep same-package utility helpers '
                                                                                                                     'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/utils/ResourceUtil.cj': {'slice_id': 'phase06-ui-p20-order-ui-resource-util-helper',
                                                                                                         'target_role': 'viewmodel',
                                                                                                         'slice_kind': 'support-model',
                                                                                                         'structure_tag': 'rich-component',
                                                                                                         'ownership_tag': 'view-model-renderer',
                                                                                                         'interaction_tags': [],
                                                                                                         'exception_tags': [],
                                                                                                         'sample_scope_tags': [],
                                                                                                         'usage_goal': 'P20 OrderUI helper for shared resource '
                                                                                                                       'lookup used across the same-package '
                                                                                                                       'home-tab components.',
                                                                                                         'notes': ['Generated from the scout-selected P20 '
                                                                                                                   'freeze set.',
                                                                                                                   'Keep same-package utility helpers '
                                                                                                                   'source-backed for the P20 lane.']},
 'raw_docs/phase06-ui-p20/HarmonyOS-Examples/OrderUI/entry/src/main/cangjie/src/utils/WindowUtil.cj': {'slice_id': 'phase06-ui-p20-order-ui-window-util-helper',
                                                                                                       'target_role': 'viewmodel',
                                                                                                       'slice_kind': 'support-model',
                                                                                                       'structure_tag': 'rich-component',
                                                                                                       'ownership_tag': 'controller-owned-state',
                                                                                                       'interaction_tags': [],
                                                                                                       'exception_tags': [],
                                                                                                       'sample_scope_tags': [],
                                                                                                       'usage_goal': 'P20 OrderUI helper for window stage, '
                                                                                                                     'safe-area, and breakpoint state updates '
                                                                                                                     'behind the host shell.',
                                                                                                       'notes': ['Generated from the scout-selected P20 freeze '
                                                                                                                 'set.',
                                                                                                                 'Keep same-package utility helpers '
                                                                                                                 'source-backed for the P20 lane.']}})
# P20 regular mechanical-readiness overrides end

FILE_SLICE_OVERRIDES.update({
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/index.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-entry-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout entry page for the router-backed layout gallery selected by the official scout.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/pages/BadgeView.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-badge-view-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout route-target page for badge layout patterns, router navigation, and same-package badge components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/pages/ListView.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-list-view-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout route-target page for list pagination patterns and same-package list components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/pages/ScrollView.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-scroll-view-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout route-target page for scroll layout patterns and same-package scroll-band components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/pages/SimpleLayout.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-simple-layout-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout route-target page for row/column split layout patterns and same-package helper models.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/Badge/BadgeExamp.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-badge-examples-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component file for number and position badge examples inside the selected layout gallery.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/Badge/ChatAvatar.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-chat-avatar-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout badge component for avatar overlay rendering inside the badge page closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/Badge/PseudoBadgeExamp.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-pseudo-badge-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component file for pseudo-badge variants inside the badge page closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/List/ListBands.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-list-bands-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component file for simple/add-more/pagination list bands with local timed state updates.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/List/User.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-user-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout support model for synthetic user entities consumed by the list components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/List/UserList.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-user-list-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout component for rendering user-list items and item-level state inside the list page closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/ScrollLayout/HouseScrollBand.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-house-scroll-band-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout component file for scroll-band and fixed-band carousel behavior with local timer state.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/ScrollLayout/house.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-house-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout support model for house card data consumed by the scroll layout components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/SimpleLayout/BillExamp.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-bill-examples-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component file for billing/card layout examples inside the simple-layout page closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/SimpleLayout/ColumnExampBand.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-column-examples-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component for single-column layout examples inside the simple-layout closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/SimpleLayout/ColumnSplitExampBand.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-column-split-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component for split-column layout examples inside the simple-layout closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/SimpleLayout/IntroRecBand.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-intro-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component for intro/recommendation card layout examples inside the simple-layout closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/SimpleLayout/RowExampBand.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-row-examples-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component for row layout examples and builder-backed bands inside the simple-layout closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/SimpleLayout/RowSplitExampBand.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-row-split-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout primary component for split-row layout examples inside the simple-layout closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/SimpleLayout/product.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-product-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout support model for product/card data consumed by the simple-layout components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/entry/Item.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-entry-item-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout entry component for router-backed gallery item navigation from the host page.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/global/DescriptionText.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-description-text-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout shared description text component reused across the layout gallery pages.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/global/PageHeader.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-page-header-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout shared page-header component for router back-navigation and header composition across the gallery pages.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/global/Section.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-section-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout shared section-title component reused across the layout gallery pages.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/components/utils/BlackDivider.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-black-divider-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout shared divider component reused by the layout example bands.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/utils/color.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-color-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout helper for interpolated color utilities consumed by the simple-layout page and related components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/utils/counter.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-counter-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout helper for width/count calculations consumed by badge and simple-layout components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/02-UILayout/entry/src/main/cangjie/utils/format.cj': {
  'slice_id': 'phase06-ui-p21-ui-layout-format-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 UILayout helper for float formatting consumed by the simple-layout example components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/index.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-entry-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart entry page for AppStorage-backed chart mode switching and renderer composition selected by the official scout.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/main_ability.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-main-ability-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart support model for MainAbility window avoid-area wiring and AppStorage handoff.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/constants/DataConstants.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-data-constants-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart support model for local chart dataset constants consumed across the renderer stack.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/constants/StyleConstants.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-style-constants-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart support model for shared style constants consumed across the chart renderer stack.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/models/ChartData.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-chart-data-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart support model for timeline and K-line data structures consumed by the viewmodels and renderers.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/models/ChartDimensions.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-chart-dimensions-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart support model for chart dimension calculations used by the renderer stack.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/models/ChartDrawParams.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-chart-draw-params-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart support model for drawing contexts and render parameters used by the renderer stack.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/models/DisplayNumberData.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-display-number-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart support model for display-number state consumed by the chart header and axis components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/services/ChartDataService.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-chart-data-service-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart support service for local resource-backed chart data loading inside the selected closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/viewmodels/KLineViewModel.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-kline-view-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart controller-owned view model for K-line chart state and derived render data.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/viewmodels/TimeLineViewModel.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-timeline-view-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart controller-owned view model for timeline chart state and timer-backed refresh behavior.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/ChartDrawingHelper.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-chart-drawing-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart helper for chart drawing geometry shared by the renderer components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/Content.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-content-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart primary content component for coordinating chart mode selection, local data loading, and renderer composition.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/KLineRenderer.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-kline-renderer-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart helper renderer for K-line drawing logic consumed by the chart components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/KLineView.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-kline-view-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart primary component for rendering the K-line chart view against the local view model.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/Numbers.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-numbers-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart primary component for rendering axis and display-number values against the local view model.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/Quotes.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-quotes-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart primary component for rendering quote summaries against the local chart state.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/StyleExtensions.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-style-extensions-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart helper for style and path extension logic shared by the chart renderer stack.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/TimeLineRenderer.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-timeline-renderer-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart helper renderer for timeline drawing logic consumed by the chart components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/TimeLineView.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-timeline-view-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart primary component for rendering the timeline chart view against the local view model.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/16-StockChart/entry/src/main/cangjie/views/Title.cj': {
  'slice_id': 'phase06-ui-p21-stock-chart-title-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 StockChart primary component for rendering chart title and header metrics against the local chart state.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/index.cj': {
  'slice_id': 'phase06-ui-p21-waterfall-entry-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 WaterFall entry page for event-bus-driven waterfall composition, timer-backed refresh gating, and local mock data.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/component/card/CoverCard.cj': {
  'slice_id': 'phase06-ui-p21-waterfall-cover-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 WaterFall primary card component for media card rendering, delayed transitions, and local mock/video state.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/component/waterfall/WaterColumn.cj': {
  'slice_id': 'phase06-ui-p21-waterfall-water-column-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 WaterFall primary component for waterfall column orchestration, event-bus coordination, and local timer state.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/entity/media.cj': {
  'slice_id': 'phase06-ui-p21-waterfall-media-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 WaterFall support model for media entity data consumed by the mock layer and card components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/event/EventBus.cj': {
  'slice_id': 'phase06-ui-p21-waterfall-event-bus-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 WaterFall controller-owned event bus for coordinating waterfall state updates across the entry page and columns.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/mock/mock.cj': {
  'slice_id': 'phase06-ui-p21-waterfall-mock-data-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 WaterFall support model for locally generated image/video mock data consumed by the waterfall components.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
'raw_docs/phase06-ui-p21/HarmonyOS-Examples/WaterFall/entry/src/main/cangjie/src/utils/DataSource.cj': {
  'slice_id': 'phase06-ui-p21-waterfall-data-source-model',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P21 WaterFall controller-owned data-source helper for list/waterflow observer updates inside the selected closure.',
  'notes': ['Generated from the scout-selected P21 freeze set.', 'Keep the same-package closure source-backed for the P21 lane.']
},
})
# P21 regular mechanical-readiness overrides end

FILE_SLICE_OVERRIDES.update({
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/index.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-gallery-entry-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery entry page for the router-backed card host selected by the official reserve scout.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/IndexImage.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-image-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for image preview and route dispatch inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/global.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-index-global-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent helper for gallery-card styling and router redirect extensions reused across the selected index cards.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indexBadge.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-badge-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for badge previews and route dispatch inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indexButton.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-button-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for button previews and route dispatch inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indexCheckBox.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-checkbox-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for checkbox previews and route dispatch inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indexMusicPlayer.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-music-player-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for timer-backed slider and playback state inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indexSwiper.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-swiper-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for swiper previews and route dispatch inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indexTab.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-tab-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for tab previews and route dispatch inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indexText.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for text previews and route dispatch inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/index/indextTextInput.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-input-card-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent gallery card for text-input previews and route dispatch inside the selected index closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/utils/dataSource.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-data-source-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent helper for local IDataSource scaffolding imported by the selected gallery cards.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package gallery closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/pages/textSample.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-playground-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent text playground page for stateful text rendering and local control-panel composition inside the selected reserve closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/pages/global.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-page-global-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent helper for text-page container, section, and playground layout extensions reused by the selected reserve closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/text.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-shared-components',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent shared text-page components for page titles, descriptions, section headers, and code blocks inside the selected reserve closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/font/fontStyle.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-font-style-bar-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent support component for font-style selection and local state handoff inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/font/fontWeight.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-font-weight-bar-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent support component for font-weight slider state and local text-preview control inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/font/textAlign.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-align-bar-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent support component for text-alignment selection and local state handoff inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/font/textCase.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-case-bar-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent support component for text-case selection and local preview-state control inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/font/textDecoration.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-decoration-bar-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent support component for decoration-type and decoration-color control inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/utils/animations.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-playground-animation-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent helper for animation parameter constants reused across the selected text playground controls.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/utils/colorpicker.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-color-picker-controls-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent primary control component for swatch display, color-band toggling, and timer-backed color-picker visibility inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/utils/global.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-playground-global-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent helper for selected playground container, slider, toggle, label, and divider extensions reused across local controls.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/utils/selectBand.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-select-bar-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent support component for horizontal option selection, menu expansion, and callback dispatch inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/utils/sliderBar.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-slider-bar-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent support component for value-slider expansion and bound numeric state updates inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/utils/toggleBar.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-toggle-bar-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent support component for bound toggle state and label composition inside the selected text playground closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/utils/valueSlider.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-value-slider-builder',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent helper for overloaded slider builders reused across the selected text playground controls.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/components/playground/utils/variables.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-playground-variables-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent helper for local playground layout constants reused across the selected text playground controls.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/02-UIComponent/entry/src/main/cangjie/src/utils/variables.cj': {
  'slice_id': 'phase06-ui-p22-ui-component-text-variables-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'view-model-renderer',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 UIComponent helper for shared text-page colors, spacing, and card-style constants reused by the selected reserve closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package text playground closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/RouletteUI/entry/src/main/cangjie/src/public_page.cj': {
  'slice_id': 'phase06-ui-p22-roulette-ui-public-page',
  'target_role': 'page',
  'slice_kind': 'entry-page',
  'structure_tag': 'page-shell',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 RouletteUI routed public page for AppStorage-backed list/edit workflow selection inside the official reserve closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package public-page closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/RouletteUI/entry/src/main/cangjie/src/common/component/public_page_top.cj': {
  'slice_id': 'phase06-ui-p22-roulette-ui-public-page-top-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 RouletteUI support component for back/confirm routing controls inside the selected PublicPage workflow.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package public-page closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/RouletteUI/entry/src/main/cangjie/src/common/component/public_page_body.cj': {
  'slice_id': 'phase06-ui-p22-roulette-ui-public-page-body-component',
  'target_role': 'component',
  'slice_kind': 'support-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 RouletteUI support component for list-vs-edit body switching inside the selected PublicPage workflow.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package public-page closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/RouletteUI/entry/src/main/cangjie/src/common/component/global.cj': {
  'slice_id': 'phase06-ui-p22-roulette-ui-public-page-global-helper',
  'target_role': 'viewmodel',
  'slice_kind': 'support-model',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 RouletteUI helper for PublicPage back/redirect image extensions reused by the selected workflow.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package public-page closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/RouletteUI/entry/src/main/cangjie/src/common/component/found_and_edit.cj': {
  'slice_id': 'phase06-ui-p22-roulette-ui-found-edit-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 RouletteUI primary component for the create/edit workflow, AppStorage handoff, and option-list editing inside the selected PublicPage closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package public-page closure source-backed for the P22 lane.']
},
'raw_docs/phase06-ui-p22/HarmonyOS-Examples/RouletteUI/entry/src/main/cangjie/src/common/component/turntable_list.cj': {
  'slice_id': 'phase06-ui-p22-roulette-ui-turntable-list-component',
  'target_role': 'component',
  'slice_kind': 'primary-component',
  'structure_tag': 'rich-component',
  'ownership_tag': 'controller-owned-state',
  'interaction_tags': [],
  'exception_tags': [],
  'sample_scope_tags': [],
  'usage_goal': 'P22 RouletteUI primary component for local turntable-history/template list switching inside the selected PublicPage closure.',
  'notes': ['Generated from the scout-selected P22 freeze set.', 'Keep the same-package public-page closure source-backed for the P22 lane.']
},
})
# P22 regular mechanical-readiness overrides end

def read_json(path: Path) -> Dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, payload: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def normalize_tag_list(value: Any) -> List[str]:
    if not isinstance(value, list):
        return []
    return [str(item) for item in value if str(item).strip()]


def build_source_scan(repo_root: Path, repo_local_path: str) -> Dict[str, Any]:
    source_path = repo_root / repo_local_path
    text = source_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    declared_types: List[str] = []
    for line in lines:
        stripped = line.strip()
        if " class " in f" {stripped} " or stripped.startswith("class ") or stripped.startswith("public class "):
            declared_types.append(stripped)
        elif " struct " in f" {stripped} " or stripped.startswith("struct ") or stripped.startswith("public struct "):
            declared_types.append(stripped)
        if len(declared_types) >= 4:
            break
    return {
        "has_entry_decorator": any("@Entry" in line for line in lines[:80]),
        "has_component_decorator": any("@Component" in line for line in lines[:120]),
        "has_builder_decorator": any("@Builder" in line for line in lines[:200]),
        "declared_types_head": declared_types,
    }


def recommend_few_shot_entry_ids(
    *,
    target_role: str,
    structure_tag: str,
    ownership_tag: str,
    interaction_tags: List[str],
    exception_tags: List[str],
    sample_scope_tags: List[str],
    pack_payload: Dict[str, Any],
    limit: int = 2,
) -> List[str]:
    selection_policy = (
        pack_payload.get("selection_policy", {})
        if isinstance(pack_payload.get("selection_policy"), dict) else {}
    )
    cap = int(selection_policy.get("max_examples_per_prompt", limit) or limit)
    entries = pack_payload.get("entries", []) if isinstance(pack_payload.get("entries"), list) else []
    prepared: List[tuple[int, int, str]] = []
    interaction_set = set(interaction_tags)
    exception_set = set(exception_tags)
    sample_scope_set = set(sample_scope_tags)
    for index, item in enumerate(entries):
        if not isinstance(item, dict) or not str(item.get("source_excerpt", "")).strip():
            continue
        if str(item.get("structure_tag", "")).strip() != structure_tag:
            continue
        if str(item.get("ownership_tag", "")).strip() != ownership_tag:
            continue
        entry_interactions = set(normalize_tag_list(item.get("interaction_tags")))
        entry_exceptions = set(normalize_tag_list(item.get("exception_tags")))
        entry_scope = set(normalize_tag_list(item.get("sample_scope_tags")))
        if exception_set and not (exception_set & entry_exceptions):
            continue
        if entry_exceptions and not exception_set:
            continue
        if entry_interactions and not interaction_set:
            continue
        score = 200
        target_roles = {
            str(role).strip().lower()
            for role in (item.get("target_roles", []) if isinstance(item.get("target_roles"), list) else [])
            if str(role).strip()
        }
        if target_role in target_roles:
            score += 40
        score += 40 * len(interaction_set & entry_interactions)
        score += 50 * len(exception_set & entry_exceptions)
        score += 10 * len(sample_scope_set & entry_scope)
        if not interaction_set and not entry_interactions:
            score += 10
        if not exception_set and not entry_exceptions:
            score += 10
        priority = str(item.get("priority", "")).strip().upper()
        if priority == "P0":
            score += 20
        elif priority == "P1":
            score += 10
        if str(item.get("source_type", "")).strip() == "local_repo":
            score += 15
        selection_rank = int(item.get("selection_rank", index + 1) or index + 1)
        prepared.append((score, selection_rank, str(item.get("entry_id", "")).strip()))
    prepared.sort(key=lambda row: (-row[0], row[1], row[2]))
    return [entry_id for _, _, entry_id in prepared[:max(0, cap)] if entry_id]


def build_file_manifest(
    *,
    source_corpus_payload: Dict[str, Any],
    sample_manifest_payload: Dict[str, Any],
    few_shot_pack_payload: Dict[str, Any],
    repo_root: Path,
) -> Dict[str, Any]:
    tag_rules = sample_manifest_payload.get("tag_rules", {}) if isinstance(sample_manifest_payload.get("tag_rules"), dict) else {}
    structure_allowlist = set(normalize_tag_list(tag_rules.get("structure_tags")))
    ownership_allowlist = set(normalize_tag_list(tag_rules.get("ownership_tags")))
    interaction_allowlist = set(normalize_tag_list(tag_rules.get("optional_interaction_tags")))
    exception_allowlist = set(normalize_tag_list(tag_rules.get("optional_exception_tags")))
    scope_allowlist = set(normalize_tag_list(tag_rules.get("optional_sample_scope_tags")))

    entries: List[Dict[str, Any]] = []
    selection_rank = 1
    corpus_entries = source_corpus_payload.get("entries", []) if isinstance(source_corpus_payload.get("entries"), list) else []
    for sample in corpus_entries:
        if not isinstance(sample, dict):
            continue
        sample_id = str(sample.get("sample_id", "")).strip()
        repo_name = str(sample.get("repo_name", "")).strip()
        repo_local_paths = normalize_tag_list(sample.get("repo_local_paths"))
        source_paths = normalize_tag_list(sample.get("source_paths"))
        if len(repo_local_paths) != len(source_paths):
            raise ValueError(f"sample `{sample_id}` has mismatched repo_local_paths/source_paths length")
        for file_index, (repo_local_path, source_path) in enumerate(zip(repo_local_paths, source_paths), start=1):
            override = FILE_SLICE_OVERRIDES.get(repo_local_path)
            if override is None:
                raise ValueError(f"missing file-level override for `{repo_local_path}`")
            structure_tag = str(override["structure_tag"])
            ownership_tag = str(override["ownership_tag"])
            interaction_tags = normalize_tag_list(override.get("interaction_tags"))
            exception_tags = normalize_tag_list(override.get("exception_tags"))
            sample_scope_tags = normalize_tag_list(override.get("sample_scope_tags"))
            if structure_tag not in structure_allowlist:
                raise ValueError(f"invalid structure_tag `{structure_tag}` for `{repo_local_path}`")
            if ownership_tag not in ownership_allowlist:
                raise ValueError(f"invalid ownership_tag `{ownership_tag}` for `{repo_local_path}`")
            if not set(interaction_tags).issubset(interaction_allowlist):
                raise ValueError(f"invalid interaction_tags for `{repo_local_path}`")
            if not set(exception_tags).issubset(exception_allowlist):
                raise ValueError(f"invalid exception_tags for `{repo_local_path}`")
            if not set(sample_scope_tags).issubset(scope_allowlist):
                raise ValueError(f"invalid sample_scope_tags for `{repo_local_path}`")
            entry = {
                "slice_id": str(override["slice_id"]),
                "selection_rank": selection_rank,
                "sample_rank": file_index,
                "sample_id": sample_id,
                "priority": str(sample.get("priority", "P0")).strip(),
                "source_type": str(sample.get("source_type", "external_repo")).strip(),
                "adoption_decision": str(sample.get("adoption_decision", "primary")).strip(),
                "target_role": str(override["target_role"]).strip(),
                "slice_kind": str(override["slice_kind"]).strip(),
                "repo_name": repo_name,
                "source_path": source_path,
                "repo_local_path": repo_local_path,
                "source": sample.get("source", {}),
                "structure_tag": structure_tag,
                "ownership_tag": ownership_tag,
                "interaction_tags": interaction_tags,
                "exception_tags": exception_tags,
                "sample_scope_tags": sample_scope_tags,
                "ui_prompt_tags": {
                    "structure_tag": structure_tag,
                    "ownership_tag": ownership_tag,
                    "interaction_tags": interaction_tags,
                    "exception_tags": exception_tags,
                    "sample_scope_tags": sample_scope_tags,
                },
                "staging_target": str(sample.get("staging_target", "")).strip(),
                "verification_mode": str(sample.get("verification_mode", "")).strip(),
                "usage_goal": str(override["usage_goal"]).strip(),
                "notes": [str(item) for item in override.get("notes", [])],
                "source_scan": build_source_scan(repo_root, repo_local_path),
            }
            entry["recommended_few_shot_entry_ids"] = recommend_few_shot_entry_ids(
                target_role=entry["target_role"],
                structure_tag=structure_tag,
                ownership_tag=ownership_tag,
                interaction_tags=interaction_tags,
                exception_tags=exception_tags,
                sample_scope_tags=sample_scope_tags,
                pack_payload=few_shot_pack_payload,
            )
            entries.append(entry)
            selection_rank += 1

    role_counts = Counter(entry["target_role"] for entry in entries)
    structure_counts = Counter(entry["structure_tag"] for entry in entries)
    source_corpus_manifest_name = str(source_corpus_payload.get("manifest_name", "phase06-ui-source-corpus")).strip() or "phase06-ui-source-corpus"
    source_manifest_name = str(source_corpus_payload.get("source_manifest", "phase06_ui_sample_manifest.json")).strip() or "phase06_ui_sample_manifest.json"
    source_corpus_selection_policy = (
        source_corpus_payload.get("selection_policy", {})
        if isinstance(source_corpus_payload.get("selection_policy"), dict) else {}
    )
    selection_policy = {
        "priority": source_corpus_selection_policy.get("priority", "P0"),
        "adoption_decision": source_corpus_selection_policy.get("adoption_decision", "primary"),
        "source_type": source_corpus_selection_policy.get("source_type", "external_repo"),
        "expansion_rule": "expand repo_local_paths into file-level slices and refine per-file target_role/ui_prompt_tags",
    }
    role = str(source_corpus_selection_policy.get("role", "")).strip()
    if role:
        selection_policy["role"] = role
    return {
        "manifest_name": derive_file_manifest_name(source_corpus_manifest_name),
        "manifest_version": 1,
        "created_at": source_corpus_payload.get("created_at", ""),
        "phase": "Phase 06 UI Source Slicing / File-Level Workset",
        "status": "draft-ready",
        "source_corpus_manifest": manifest_name_to_filename(source_corpus_manifest_name),
        "source_manifest": source_manifest_name,
        "few_shot_pack": "phase06_ui_few_shot_pack.json",
        "intended_consumer": [
            "human-review",
            "future-phase06-prompt-pilot",
            "future-phase06-batch-curator",
        ],
        "notes": [
            "Expands the selected frozen source corpus into file-level slices with explicit ui_prompt_tags.",
            "This manifest is not consumed directly by scripts/pipeline_batch_runner.py; it is a file-level workset for prompt pilots, explicit tag injection, and later batch curation.",
            "Tag refinement is allowed at file level when a multi-file sample contains both page-shell and rich-component files.",
        ],
        "selection_policy": selection_policy,
        "summary": {
            "sample_count": len(corpus_entries),
            "slice_count": len(entries),
            "role_counts": dict(role_counts),
            "structure_counts": dict(structure_counts),
        },
        "entries": entries,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build a Phase06 UI file-level manifest.")
    parser.add_argument("--source-corpus", default=str(DEFAULT_SOURCE_CORPUS_PATH))
    parser.add_argument("--sample-manifest", default=str(DEFAULT_SAMPLE_MANIFEST_PATH))
    parser.add_argument("--few-shot-pack", default=str(DEFAULT_FEW_SHOT_PACK_PATH))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT_PATH))
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source_corpus_path = Path(args.source_corpus).resolve()
    sample_manifest_path = Path(args.sample_manifest).resolve()
    few_shot_pack_path = Path(args.few_shot_pack).resolve()
    output_path = Path(args.output).resolve()
    payload = build_file_manifest(
        source_corpus_payload=read_json(source_corpus_path),
        sample_manifest_payload=read_json(sample_manifest_path),
        few_shot_pack_payload=read_json(few_shot_pack_path),
        repo_root=PROJECT_ROOT,
    )
    write_json(output_path, payload)
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
