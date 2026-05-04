from __future__ import annotations

import re
import unittest
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]


def read_text(*parts: str) -> str:
    return (PROJECT_ROOT.joinpath(*parts)).read_text(encoding="utf-8")


class AgentArchitectureDocsTests(unittest.TestCase):
    def test_agents_has_mode_and_soft_constraint_surfaces(self) -> None:
        text = read_text("AGENTS.md")
        self.assertIn("### 1.3 Lightweight Soft Constraints", text)
        self.assertIn("### 2.1 Collaboration Mode Matrix", text)
        self.assertIn("### 2.5 AGENT TEAM Capability Matrix", text)
        self.assertIn("### 2.8 Mode Boundary Rules", text)
        self.assertIn("默认全程使用中文", text)
        self.assertIn("先绑定绝对日期", text)
        self.assertIn("README`、解释文档、模板页、archive 与 legacy 页面都不是默认恢复入口", text)
        self.assertIn("不得以未加限定的 live header 暴露 `status: active`", text)

    def test_readme_is_demoted_and_points_to_live_truth(self) -> None:
        text = read_text("docs", "agent_system", "README.md")
        self.assertIn("`role`: `architecture_explainer`", text)
        self.assertIn("`resume_surface`: `false`", text)
        self.assertIn("`default_live_truth`:", text)
        self.assertNotIn("AGENTS.refactor.md", text)
        self.assertIn("在当前仓库里", text)

    def test_execution_routing_uses_collaboration_mode_language(self) -> None:
        text = read_text("docs", "agent_system", "execution_routing.md")
        self.assertIn("# Execution Routing / Collaboration Modes", text)
        self.assertIn("## 2. Collaboration Mode Routing", text)
        self.assertIn("Reviewer + Planner / Executor", text)
        self.assertIn("## 3. Mode Boundaries And AGENT TEAM Capability", text)
        self.assertIn("不是项目真值层", text)

    def test_prompts_share_resume_first_chain(self) -> None:
        expected_chain = [
            "docs/status/current_committed_plan.md",
            "docs/current_state.v2.md",
            "docs/status/INDEX.md",
            "docs/status/current_task_handoff.md",
        ]
        for relative_path in [
            ("docs", "agent_system", "prompts", "planner_reviewer.md"),
            ("docs", "agent_system", "prompts", "executor.md"),
            ("docs", "agent_system", "prompts", "conductor.md"),
        ]:
            text = read_text(*relative_path)
            indices = [text.index(item) for item in expected_chain]
            self.assertEqual(indices, sorted(indices), msg=str(relative_path))
            self.assertIn("全程使用中文", text)
            self.assertIn("README`、解释文档、模板页、archive 与 legacy 页面都不是默认真值面", text)
            self.assertIn("先绑定绝对日期", text)

    def test_executor_and_conductor_no_longer_reference_old_agent_team_labels(self) -> None:
        executor_text = read_text("docs", "agent_system", "prompts", "executor.md")
        conductor_text = read_text("docs", "agent_system", "prompts", "conductor.md")
        self.assertNotIn("AGENT TEAM Matrix", executor_text)
        self.assertNotIn("AGENT TEAM Working Flow", executor_text)
        self.assertIn("AGENT TEAM` 只是条件化协作能力", executor_text)
        self.assertIn("不自动把用户一句话升格成全面并行", conductor_text)

    def test_legacy_status_page_is_explicitly_historical(self) -> None:
        text = read_text(".claude", "status", "current-phase.md")
        self.assertIn("`resume_surface`: `false`", text)
        self.assertIn("`superseded_by`:", text)
        self.assertIn("legacy_phase:", text)
        self.assertIn("legacy_status:", text)
        self.assertIn("historical_focus:", text)
        self.assertIn("snapshot_tactical_objective_at_2026_04_18:", text)
        self.assertNotRegex(text, re.compile(r"^status:\s*`?active`?", re.MULTILINE))
        self.assertNotRegex(text, re.compile(r"^focus:", re.MULTILINE))
        self.assertNotRegex(text, re.compile(r"^tactical_objective:", re.MULTILINE))
        self.assertNotRegex(text, re.compile(r"^current_entry:", re.MULTILINE))

    def test_domain_review_rubric_has_state_semantics_layer(self) -> None:
        text = read_text("docs", "domain_review_rubric.v2.md")
        self.assertIn("## 0. Glossary / Object Model / State Semantics", text)
        self.assertIn("`consume_surface / evidence_only_surface / legacy_history_surface`", text)
        self.assertIn("`task_status / lane_status`", text)
        self.assertIn("`passed / accepted / archived`", text)
        self.assertIn("`planning_freeze_passed / execution_ready`", text)
        self.assertIn("`raw_truth / effective_truth / reviewer_truth`", text)
        self.assertIn("promotion 必须依赖的 authority", text)


if __name__ == "__main__":
    unittest.main()
