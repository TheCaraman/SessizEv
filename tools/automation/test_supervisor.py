import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("supervisor", Path(__file__).with_name("supervisor.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class WorkerStub(module.Supervisor):
    def __init__(self, config):
        super().__init__(config)
        self.calls = []
        self.responses = []
        self.test_passes = True

    def agent(self, provider, workspace, prompt, tag):
        self.calls.append(provider["name"])
        (workspace / "scripts").mkdir(exist_ok=True)
        (workspace / "scripts" / "task.txt").write_text("partial work preserved", encoding="utf-8")
        return self.responses.pop(0) if self.responses else {"status": "done", "summary": "stub", "tests": []}

    def gate(self, task, workspace, tag):
        return self.test_passes, "deliberate test failure" if not self.test_passes else "PASS"


class Tests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tqh-supervisor-test-")
        self.root = Path(self.temp.name)
        self.git = shutil.which("git") or r"C:\Program Files\Git\cmd\git.exe"
        self.project = self.root / "project"
        self.project.mkdir()
        self.g("init", "-b", "main")
        self.g("config", "user.name", "Automation Test")
        self.g("config", "user.email", "test@example.invalid")
        (self.project / "base.txt").write_text("baseline")
        self.g("add", "base.txt")
        self.g("commit", "-m", "baseline")
        self.base = self.g("rev-parse", "HEAD")
        self.task = {"id": "TEST-1", "allowed_paths": ["scripts/*"], "instruction": "test", "required_test_markers": []}
        self.config_path = self.root / "queue.json"
        module.save_json(self.config_path, {
            "project": str(self.project), "git": self.git, "godot": "unused",
            "max_attempts_per_task": 2,
            "max_run_seconds": 1,
            "providers": [{"name": name, "executable": str(Path(os.__file__))} for name in ("codex", "claude")],
            "tasks": [self.task],
        })
        self.runner = WorkerStub(self.config_path)

    def tearDown(self):
        # Worktrees have read-only Git pack files on some Windows installations.
        self.temp.cleanup()

    def g(self, *args):
        result = subprocess.run([self.git, "-C", str(self.project), *args], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def test_scope_paths(self):
        self.assertTrue(module.allowed_path("scripts/player/a.gd", ["scripts/*"]))
        for path in ("../scripts/a", "C:/scripts/a", "tools/automation/x.py", "AGENTS.md", ".git/hooks/x"):
            self.assertFalse(module.allowed_path(path, ["*"]))

    def test_classification(self):
        self.assertEqual(module.failure_kind("429 rate limit exceeded"), "quota")
        self.assertEqual(module.failure_kind("Not logged in"), "auth")
        self.assertEqual(module.failure_kind("compiler error"), "error")

    def test_quota_handoff_preserves_progress(self):
        self.runner.responses = [{"error": "quota"}, {"status": "done", "summary": "done", "tests": []}]
        self.runner.run()
        self.assertEqual(self.runner.calls, ["codex", "claude"])
        self.assertEqual(self.runner.task_state(self.task)["status"], "done")
        self.assertEqual((self.project / "scripts/task.txt").read_text(), "partial work preserved")

    def test_failed_tests_never_integrate(self):
        self.runner.test_passes = False
        self.runner.run()
        self.assertEqual(self.g("rev-parse", "HEAD"), self.base)
        self.assertEqual(self.runner.task_state(self.task)["status"], "review_required")
        self.assertTrue(Path(self.runner.task_state(self.task)["workspace"]).joinpath("scripts/task.txt").exists())

    def test_both_unavailable_records_wait(self):
        self.runner.responses = [{"error": "auth"}, {"error": "quota"}]
        # Leave one additional attempt so the no-provider branch is reached.
        self.runner.config["max_attempts_per_task"] = 3
        self.runner.run()
        self.assertEqual(self.runner.task_state(self.task)["status"], "waiting_provider")
        self.assertEqual(self.g("rev-parse", "HEAD"), self.base)

    def test_user_changes_block_integration(self):
        workspace = self.runner.prepare(self.task)
        (workspace / "scripts").mkdir()
        (workspace / "scripts/task.txt").write_text("worker")
        (self.project / "base.txt").write_text("owner edit")
        with self.assertRaisesRegex(RuntimeError, "Canonical project changed"):
            self.runner.integrate(self.task, workspace, self.runner.task_state(self.task))
        self.assertEqual((self.project / "base.txt").read_text(), "owner edit")

    def test_restart_reuses_worktree(self):
        first = self.runner.prepare(self.task)
        another = WorkerStub(self.config_path)
        self.assertEqual(first, another.prepare(self.task))

    def test_out_of_scope_requires_review(self):
        workspace = self.runner.prepare(self.task)
        (workspace / "unrelated.txt").write_text("not allowed")
        with self.assertRaisesRegex(RuntimeError, "outside task scope"):
            self.runner.validate_scope(self.task, workspace, self.runner.task_state(self.task))

    def test_needs_owner_is_not_done(self):
        self.runner.responses = [{"status": "needs_owner", "summary": "creative decision", "tests": []}]
        self.runner.run()
        self.assertEqual(self.runner.task_state(self.task)["status"], "needs_owner")
        self.assertEqual(self.g("rev-parse", "HEAD"), self.base)

    def test_stop_does_not_call_provider(self):
        (self.root / "STOP").touch()
        self.runner.run()
        self.assertEqual(self.runner.calls, [])

    def test_api_billing_keys_are_removed(self):
        from unittest.mock import patch
        with patch.dict(os.environ, {"OPENAI_API_KEY": "test", "ANTHROPIC_API_KEY": "test", "CLAUDECODE": "1"}):
            env = self.runner.provider_env()
        self.assertNotIn("OPENAI_API_KEY", env)
        self.assertNotIn("ANTHROPIC_API_KEY", env)
        self.assertNotIn("CLAUDECODE", env)


if __name__ == "__main__":
    unittest.main()
