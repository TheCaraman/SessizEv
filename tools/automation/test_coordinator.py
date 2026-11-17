import copy
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from base_runner import allowed_path, read_json, save_json
from coordinator import Coordinator


class FakeCoordinator(Coordinator):
    def __init__(self, config):
        super().__init__(config)
        self.responses = []
        self.invocations = []
        self.integration_count = 0
        self.pass_tests = True
        self.mutate_review = False
        self.availability = {"codex": True, "claude": True}

    def git_run(self, *args, cwd=None):
        if args[:2] == ("branch", "--show-current"):
            return "automation/continuous-development"
        if args[:2] == ("rev-parse", "HEAD"):
            return "base"
        return ""

    def prepare(self, task):
        item = self.task_state(task)
        folder = self.root / "worker"
        folder.mkdir(exist_ok=True)
        (folder / "docs").mkdir(exist_ok=True)
        if not (folder / "docs/note.md").exists():
            (folder / "docs/note.md").write_text("candidate")
        item.update(workspace=str(folder), base="base", branch="automation/continuous-development")
        return folder

    def changed_paths(self, workspace, base):
        return ["docs/note.md"]

    def eligible(self, provider):
        return self.availability[provider["name"]]

    def agent(self, provider, workspace, prompt, tag, result_schema=None, read_only=False):
        self.invocations.append((provider["name"], read_only, prompt))
        if read_only and self.mutate_review:
            (workspace / "docs/note.md").write_text("unauthorized review edit")
        return self.responses.pop(0)

    def gate(self, task, workspace, tag):
        return self.pass_tests, "external test feedback"

    def integrate(self, task, workspace, item):
        self.integration_count += 1
        item["commit"] = "accepted"


DONE = {"status": "done", "summary": "worker finished", "tests": []}
APPROVED = {"status": "approved", "summary": "independent review", "tests": []}


class CoordinatorTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tqh-coord-tests-")
        self.root = Path(self.temp.name).resolve()
        self.assertEqual(self.root.parent, Path(tempfile.gettempdir()).resolve())
        self.assertTrue(self.root.name.startswith("tqh-coord-tests-"))
        self.task = {"id": "TEST-ONE", "instruction": "write docs", "allowed_paths": ["docs/*"],
                     "provider": "codex", "reviewer": "claude", "required_test_markers": ["PASS"]}
        self.config = {"project": str(self.root / "integration"), "expected_branch": "automation/continuous-development",
                       "providers": [{"name": "codex"}, {"name": "claude"}], "godot": "godot",
                       "tasks": [self.task]}
        self.path = self.root / "queue.json"
        save_json(self.path, self.config)
        self.runner = FakeCoordinator(self.path)

    def tearDown(self):
        # Only this freshly created, validated test directory is recursively removed.
        self.assertEqual(self.root.parent, Path(tempfile.gettempdir()).resolve())
        self.assertTrue(self.root.name.startswith("tqh-coord-tests-"))
        self.temp.cleanup()

    def run_with(self, *responses):
        self.runner.responses += [copy.deepcopy(response) for response in responses]
        self.runner.run_task(self.task)
        return self.runner.task_state(self.task)

    def test_two_different_agents_and_gate_before_integration(self):
        item = self.run_with(DONE, APPROVED)
        self.assertEqual(item["status"], "done")
        self.assertEqual([(name, readonly) for name, readonly, _ in self.runner.invocations], [("codex", False), ("claude", True)])
        self.assertEqual(self.runner.integration_count, 1)
        self.assertEqual(len(list((self.root / "project/docs/coordination/messages").glob("*.md"))), 3)
        self.runner.run_task(self.task)
        self.assertEqual(len(self.runner.invocations), 2)

    def test_review_feedback_returns_to_worker(self):
        item = self.run_with(DONE, {"status": "changes_requested", "summary": "Fix real issue", "tests": []})
        self.assertEqual(item["status"], "queued")
        self.assertEqual(self.runner.integration_count, 0)
        self.run_with(DONE, APPROVED)
        self.assertIn("Fix real issue", self.runner.invocations[2][2])
        self.assertEqual(self.runner.integration_count, 1)

    def test_missing_reviewer_does_not_rerun_worker(self):
        self.runner.availability["claude"] = False
        item = self.run_with(DONE)
        self.assertEqual(item["status"], "waiting_reviewer")
        self.runner.availability["claude"] = True
        self.run_with(APPROVED)
        self.assertEqual(len(self.runner.invocations), 2)

    def test_read_only_reviewer_mutation_blocks_merge(self):
        self.runner.mutate_review = True
        item = self.run_with(DONE, APPROVED)
        self.assertEqual(item["status"], "review_required")
        self.assertEqual(self.runner.integration_count, 0)

    def test_test_failure_prevents_integration(self):
        self.runner.pass_tests = False
        item = self.run_with(DONE, APPROVED)
        self.assertEqual(item["status"], "queued")
        self.assertFalse(item["worker_done"])
        self.assertEqual(self.runner.integration_count, 0)

    def test_owner_decision_stops_without_integration(self):
        item = self.run_with({"status": "needs_owner", "summary": "creative choice", "tests": []})
        self.assertEqual(item["status"], "needs_owner")
        self.assertEqual(self.runner.integration_count, 0)

    def test_call_limit_is_hard_boundary(self):
        self.task["max_agent_calls"] = 1
        item = self.run_with(DONE)
        self.assertEqual(item["status"], "review_required")
        self.assertEqual(len(self.runner.invocations), 1)

    def test_quota_preserves_worker_files(self):
        item = self.run_with({"error": "quota"})
        self.assertEqual(item["status"], "waiting_provider")
        self.assertTrue((Path(item["workspace"]) / "docs/note.md").exists())
        self.assertEqual(self.runner.integration_count, 0)

    def test_queue_reload_picks_new_task_without_restart(self):
        updated = copy.deepcopy(self.config)
        updated["tasks"].append({**self.task, "id": "TEST-TWO", "depends_on": ["TEST-ONE"]})
        save_json(self.path, updated)
        self.runner._reload()
        self.assertEqual(len(self.runner.config["tasks"]), 2)

    def test_started_task_cannot_be_rewritten(self):
        self.runner.prepare(self.task)
        updated = copy.deepcopy(self.config)
        updated["tasks"][0]["instruction"] = "other scope"
        save_json(self.path, updated)
        with self.assertRaises(RuntimeError):
            self.runner._reload()

    def test_invalid_dependencies_are_rejected(self):
        for dependency in ["MISSING", "TEST-ONE"]:
            updated = copy.deepcopy(self.config)
            updated["tasks"][0]["depends_on"] = [dependency]
            save_json(self.path, updated)
            with self.assertRaises(ValueError):
                self.runner._reload()

    def test_integration_target_is_immutable(self):
        updated = copy.deepcopy(self.config)
        updated["project"] = str(self.root / "other")
        save_json(self.path, updated)
        with self.assertRaises(RuntimeError):
            self.runner._reload()

    def test_stop_marker_is_shared_with_child_loop(self):
        self.assertFalse(self.runner.stop_requested())
        self.runner.stop_path.write_text("stop")
        self.assertTrue(self.runner.stopped())
        self.assertTrue(self.runner.stop_requested())

    def test_no_api_fallback_or_desktop_ipc_in_child(self):
        with patch.dict(os.environ, {"OPENAI_API_KEY": "test", "ANTHROPIC_API_KEY": "test", "CODEX_DESKTOP_TEST": "test"}):
            env = self.runner.provider_env()
        self.assertNotIn("OPENAI_API_KEY", env)
        self.assertNotIn("ANTHROPIC_API_KEY", env)
        self.assertNotIn("CODEX_DESKTOP_TEST", env)

    def test_worker_cannot_modify_controller_or_escape_scope(self):
        self.assertFalse(allowed_path("tools/automation/coordinator.py", ["*"]))
        self.assertFalse(allowed_path("../queue.json", ["*"]))
        self.assertFalse(allowed_path("AGENTS.md", ["*"]))
        self.assertTrue(allowed_path("docs/design/RoomPreferences.md", ["docs/*"]))


if __name__ == "__main__":
    unittest.main(verbosity=2)
