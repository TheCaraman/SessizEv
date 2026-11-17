"""Bounded local task runner for Codex / Claude Code. Python standard library only."""
from __future__ import annotations

import argparse
import contextlib
import datetime as dt
import fnmatch
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import sys
import time


SCHEMA = {
    "type": "object", "additionalProperties": False,
    "properties": {
        "status": {"type": "string", "enum": ["done", "needs_owner"]},
        "summary": {"type": "string"},
        "tests": {"type": "array", "items": {"type": "string"}},
    }, "required": ["status", "summary", "tests"],
}


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def read_json(path: Path, default=None):
    return json.loads(path.read_text(encoding="utf-8-sig")) if path.exists() else default


def save_json(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".new")
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")
    os.replace(temporary, path)


def allowed_path(path: str, patterns: list[str]) -> bool:
    normalized = path.replace("\\", "/")
    if normalized.startswith("/") or ".." in normalized.split("/") or ":" in normalized:
        return False
    # These files belong to the supervisor / project owner, never workers.
    if normalized.startswith((".git/", ".codex/", ".claude/", "tools/automation/")):
        return False
    if normalized in ("AGENTS.md", "CLAUDE.md"):
        return False
    return any(fnmatch.fnmatchcase(normalized, pattern) for pattern in patterns)


def failure_kind(text: str) -> str:
    lowered = text.lower()
    if any(term in lowered for term in ("usage limit", "session limit", "rate limit", "rate_limit", "quota", "429", "hit your limit", "limit reached")):
        return "quota"
    if any(term in lowered for term in ("not logged in", "not authenticated", "authentication", "login required", "401", "please log in", "invalid api key")):
        return "auth"
    return "error"


def retry_time(text: str, timestamp: float | None = None) -> float:
    """Parse the local reset message we actually observed; otherwise back off 3h."""
    timestamp = time.time() if timestamp is None else timestamp
    match = re.search(r"resets\s+(\d{1,2}):(\d{2})\s*(am|pm)\s*\(Europe/Istanbul\)", text, re.I)
    if not match:
        return timestamp + 3 * 3600
    hour, minute = int(match[1]), int(match[2])
    if hour not in range(1, 13) or minute not in range(60):
        return timestamp + 3 * 3600
    hour = hour % 12 + (12 if match[3].lower() == "pm" else 0)
    local = dt.datetime.fromtimestamp(timestamp, dt.timezone(dt.timedelta(hours=3)))
    reset = local.replace(hour=hour, minute=minute, second=0, microsecond=0)
    if reset.timestamp() <= timestamp:
        reset += dt.timedelta(days=1)
    return reset.timestamp()


@contextlib.contextmanager
def exclusive_lock(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a+b") as handle:
        handle.seek(0)
        handle.write(b"0")
        handle.flush()
        handle.seek(0)
        if os.name == "nt":
            import msvcrt
            try:
                msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
            except OSError as exc:
                raise RuntimeError("Another supervisor is already running") from exc
        else:
            import fcntl
            fcntl.flock(handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        try:
            yield
        finally:
            handle.seek(0)
            if os.name == "nt":
                msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)
            else:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)


class Supervisor:
    def __init__(self, config_path: Path):
        self.config_path = config_path.resolve()
        self.config = read_json(self.config_path)
        self.root = self.config_path.parent
        self.project = Path(self.config["project"]).resolve()
        self.runtime = self.root / "runtime"
        self.runtime.mkdir(exist_ok=True)
        self.state_path = self.runtime / "state.json"
        self.state = read_json(self.state_path, {"tasks": {}, "providers": {}})
        self.git = self.config.get("git", "git")

    def log(self, event: str, **data):
        record = {"time": now(), "event": event, **data}
        with (self.runtime / "events.jsonl").open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(record, ensure_ascii=False) + "\n")
        print(json.dumps(record, ensure_ascii=False), flush=True)

    def persist(self):
        save_json(self.state_path, self.state)
        rows = ["THE QUIET HOURS — Otomatik çalışma", "Son güncelleme: " + now(), ""]
        for task in self.config["tasks"]:
            item = self.state["tasks"].get(task["id"], {})
            rows.append(f"{task['id']}: {item.get('status', 'queued')} — {item.get('detail', '')}")
        (self.root / "DURUM.txt").write_text("\n".join(rows), encoding="utf-8-sig")

    def command(self, args, cwd=None, timeout=90, input_text=None):
        return subprocess.run(args, cwd=cwd, input=input_text, capture_output=True,
                              text=True, encoding="utf-8", errors="replace", timeout=timeout)

    def git_run(self, *args, cwd=None):
        result = self.command([self.git, "-c", "core.quotepath=false", "-C", str(cwd or self.project), *args])
        if result.returncode:
            raise RuntimeError("Git failed: " + result.stderr[-3000:])
        return result.stdout.strip()

    def task_state(self, task):
        return self.state["tasks"].setdefault(task["id"], {"status": "queued", "attempts": 0})

    def prepare(self, task):
        item = self.task_state(task)
        if "workspace" in item:
            workspace = Path(item["workspace"])
            if not workspace.is_dir():
                raise RuntimeError("Saved workspace is missing; refusing to discard task progress")
            if self.git_run("branch", "--show-current", cwd=workspace) != item["branch"]:
                raise RuntimeError("Worker branch changed unexpectedly")
            return workspace
        if self.git_run("status", "--porcelain"):
            raise RuntimeError("Canonical project has uncommitted edits; worker will not overwrite them")
        identifier = task["id"].lower()
        if not identifier.replace("-", "").isalnum():
            raise ValueError("Task id must contain only letters, digits and hyphens")
        base = self.git_run("rev-parse", "HEAD")
        branch = "auto/" + identifier + "-" + str(int(time.time()))
        workspace = self.root / "workers" / branch.replace("/", "-")
        workspace.parent.mkdir(exist_ok=True)
        self.git_run("worktree", "add", "-b", branch, str(workspace), base)
        item.update(workspace=str(workspace), base=base, branch=branch)
        self.persist()
        return workspace

    def stop_requested(self):
        return (self.root / "STOP").exists()

    def eligible(self, provider):
        if not provider.get("enabled", True) or not Path(provider["executable"]).is_file():
            return False
        # Allows an external authenticated health check to update availability
        # without modifying the live task state or interrupting its worker.
        health = read_json(self.runtime / "provider-health.json", {}).get(provider["name"], {})
        current = self.state["providers"].get(provider["name"], {})
        if health.get("checked_at", 0) > current.get("checked_at", 0):
            self.state["providers"][provider["name"]] = health
        return self.state["providers"].get(provider["name"], {}).get("retry_after", 0) <= time.time()

    def provider_env(self):
        env = dict(os.environ)
        # Use existing subscription logins only. Never silently switch to paid API billing.
        for key in list(env):
            # Desktop IPC/registered-Core launch settings are scoped to this chat.
            # A standalone child must not inherit them. Keep only the auth home.
            if ((key.startswith("CODEX_") and key != "CODEX_HOME")
                    or key in ("OPENAI_API_KEY", "ANTHROPIC_API_KEY", "ANTHROPIC_AUTH_TOKEN", "CLAUDECODE")):
                env.pop(key)
        env["GODOT_BIN"] = self.config["godot"]
        env["TQH_PYTHON"] = sys.executable
        return env

    def agent(self, provider, workspace, prompt, tag, result_schema=None, read_only=False):
        name = provider["name"]
        output = self.runtime / (tag + ".result.json")
        schema = self.runtime / "result-schema.json"
        definition = result_schema or SCHEMA
        save_json(schema, definition)
        if output.exists():
            output.unlink()
        if name == "codex":
            mode = ["--sandbox", "read-only"] if read_only else ["--approve-for-me"]
            args = [provider["executable"], "exec", *mode, "--ephemeral",
                    "--json", "--cd", str(workspace), "--output-schema", str(schema),
                    "--output-last-message", str(output), "-"]
        elif name == "claude":
            args = [provider["executable"], "-p", "--output-format", "json",
                    "--json-schema", json.dumps(definition), "--permission-mode", "acceptEdits",
                    "--allowedTools", ("Read,Glob,Grep" if read_only else "Read,Edit,Write,Glob,Grep,Bash(git *),Bash(powershell *)"),
                    "--max-turns", str(provider.get("max_turns", 60))]
            if read_only:
                args += ["--tools", "Read,Glob,Grep"]
        else:
            raise ValueError("Unsupported provider: " + name)
        stdout_path, stderr_path = self.runtime / (tag + ".stdout.log"), self.runtime / (tag + ".stderr.log")
        with stdout_path.open("w", encoding="utf-8") as out, stderr_path.open("w", encoding="utf-8") as err:
            process = subprocess.Popen(args, cwd=workspace, stdin=subprocess.PIPE,
                                       stdout=out, stderr=err, env=self.provider_env())
            started = time.monotonic()
            first_input = prompt.encode("utf-8")
            while True:
                try:
                    process.communicate(first_input, timeout=2)
                    break
                except subprocess.TimeoutExpired:
                    first_input = None
                    if self.stop_requested():
                        self.kill(process)
                        return {"error": "stopped"}
                    if time.monotonic() - started >= self.config.get("agent_timeout_seconds", 1500):
                        self.kill(process)
                        return {"error": "timeout"}
        stdout = stdout_path.read_text(encoding="utf-8", errors="replace")
        stderr = stderr_path.read_text(encoding="utf-8", errors="replace")
        if process.returncode:
            return {"error": failure_kind(stdout + stderr), "retry_after": retry_time(stdout + stderr), "log": stdout_path.name}
        try:
            if name == "codex":
                response = read_json(output)
            else:
                envelope = json.loads(stdout)
                if envelope.get("is_error"):
                    return {"error": failure_kind(stdout), "retry_after": retry_time(stdout), "log": stdout_path.name}
                response = envelope.get("structured_output")
                if response is None:
                    response = json.loads(envelope.get("result", ""))
            if not isinstance(response, dict) or response.get("status") not in definition["properties"]["status"]["enum"]:
                return {"error": "invalid_response"}
            return response
        except (ValueError, TypeError):
            return {"error": failure_kind(stdout + stderr), "log": stdout_path.name}

    @staticmethod
    def kill(process):
        if os.name == "nt":
            subprocess.run(["taskkill", "/PID", str(process.pid), "/T", "/F"], capture_output=True)
        else:
            process.kill()
        process.wait()

    def changed_paths(self, workspace, base):
        paths = set()
        for args in (("diff", "--name-only", base), ("ls-files", "--others", "--exclude-standard")):
            paths.update(self.git_run(*args, cwd=workspace).splitlines())
        return sorted(path for path in paths if path)

    def validate_scope(self, task, workspace, item):
        changes = self.changed_paths(workspace, item["base"])
        outside = [path for path in changes if not allowed_path(path, task["allowed_paths"])]
        if outside:
            raise RuntimeError("Changes outside task scope: " + ", ".join(outside))
        for path in changes:
            full = workspace / path
            if full.is_symlink():
                raise RuntimeError("Symlink not allowed in automated change: " + path)
        self.git_run("diff", "--check", cwd=workspace)
        return changes

    def gate(self, task, workspace, tag):
        args = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                str(workspace / "tools/Run-Tests.ps1"), "-GodotPath", self.config["godot"]]
        if self.config.get("audio_driver"):
            args += ["-AudioDriver", self.config["audio_driver"]]
        process = subprocess.Popen(args, cwd=workspace, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            stdout, stderr = process.communicate(timeout=self.config.get("test_timeout_seconds", 600))
            text = (stdout + stderr).decode("utf-8", errors="replace")
            (self.runtime / (tag + ".tests.log")).write_text(text, encoding="utf-8")
            missing = [marker for marker in task["required_test_markers"] if marker not in text]
            passed = process.returncode == 0 and not missing and "FAIL:" not in text and "SCRIPT ERROR:" not in text
            return passed, text[-12000:] + ("\nMissing: " + ", ".join(missing) if missing else "")
        except subprocess.TimeoutExpired:
            self.kill(process)
            return False, "Test process timed out"

    def integrate(self, task, workspace, item):
        self.validate_scope(task, workspace, item)
        if self.git_run("status", "--porcelain"):
            raise RuntimeError("Canonical project changed during task; result preserved for review")
        if self.git_run("rev-parse", "HEAD") != item["base"]:
            raise RuntimeError("Canonical HEAD advanced during task; result preserved for review")
        if self.git_run("branch", "--show-current", cwd=workspace) != item["branch"]:
            raise RuntimeError("Worker changed branch")
        changes = self.git_run("status", "--porcelain", cwd=workspace)
        if changes:
            paths = self.changed_paths(workspace, self.git_run("rev-parse", "HEAD", cwd=workspace))
            if paths:
                self.git_run("add", "--", *paths, cwd=workspace)
                self.git_run("commit", "-m", "auto: " + task["id"], cwd=workspace)
        candidate = self.git_run("rev-parse", "HEAD", cwd=workspace)
        self.git_run("merge", "--ff-only", candidate)
        item["commit"] = candidate

    def prompt(self, task, workspace, item):
        previous = item.get("feedback", "")
        return ("THE QUIET HOURS: Read AGENTS.md, CLAUDE.md, coordination messages and task claims. "
                "You are an unattended worker in a dedicated worktree. Complete only the assigned task. "
                "Use Turkish for reports, English translation keys plus Turkish for game text. "
                "Do not wait for another assistant or ask the user routine implementation questions. "
                "Do not change branches, commit, install packages, spend money, create API keys, publish, "
                "edit supervisor files or change the approved creative direction. "
                "If a genuine owner decision is required, return needs_owner with the exact issue. "
                "Other worker attempts may have left partial edits: inspect and continue them. "
                "Treat design status claims as historical; the user has authorized takeover of paused Claude tasks. "
                "Run relevant tests and leave complete code, not placeholders. "
                "Respect allowed paths: " + json.dumps(task["allowed_paths"]) + "\n"
                + task["instruction"] + "\nPrevious attempt/test feedback:\n" + previous[-14000:]
                + "\nGodot executable: " + self.config["godot"]
                + "\nTest command: powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run-Tests.ps1 -GodotPath \""
                + self.config["godot"] + "\""
                + "\nReturn the required JSON result. A done claim will be checked by external tests.")

    def run_task(self, task):
        item = self.task_state(task)
        if item["status"] == "done":
            return
        if item["status"] in ("needs_owner", "review_required"):
            return
        workspace = self.prepare(task)
        limit = self.config.get("max_attempts_per_task", 4)
        while item["attempts"] < limit:
            if self.stop_requested():
                item.update(status="paused", detail="STOP requested; work is preserved")
                self.persist()
                return
            providers = [p for p in self.config["providers"] if self.eligible(p)]
            if not providers:
                item.update(status="waiting_provider", detail="No authenticated/available provider; resume later")
                self.persist()
                return
            provider = providers[item["attempts"] % len(providers)]
            item["attempts"] += 1
            tag = task["id"] + "-" + str(item["attempts"]) + "-" + provider["name"]
            item.update(status="running", detail=provider["name"] + ": " + tag)
            self.persist()
            self.log("task_started", task=task["id"], provider=provider["name"], workspace=str(workspace))
            response = self.agent(provider, workspace, self.prompt(task, workspace, item), tag)
            if "error" in response:
                kind = response["error"]
                if kind == "stopped":
                    item.update(status="paused", detail="STOP requested; partial work preserved")
                    self.persist()
                    return
                cooldown = 3 * 3600 if kind == "quota" else (24 * 3600 if kind == "auth" else 60)
                self.state["providers"][provider["name"]] = {
                    "retry_after": response.get("retry_after", time.time() + cooldown)
                    if kind == "quota" else time.time() + cooldown,
                    "reason": kind, "checked_at": time.time(),
                }
                item["feedback"] = "Provider stopped: " + kind + ". Continue partial work; see logs."
                self.log("provider_unavailable", provider=provider["name"], reason=kind)
                self.persist()
                continue
            if response["status"] == "needs_owner":
                item.update(status="needs_owner", detail=response.get("summary", "Owner decision needed"))
                self.persist()
                return
            try:
                self.validate_scope(task, workspace, item)
                passed, feedback = self.gate(task, workspace, tag)
                if not passed:
                    item["feedback"] = feedback
                    self.log("tests_failed", task=task["id"], log=tag + ".tests.log")
                    self.persist()
                    continue
                self.integrate(task, workspace, item)
                item.update(status="done", detail=response.get("summary", "Tests passed"), completed=now())
                self.persist()
                self.log("task_done", task=task["id"], commit=item["commit"])
                return
            except RuntimeError as exc:
                item.update(status="review_required", detail=str(exc))
                self.persist()
                return
        item.update(status="review_required", detail="Attempt limit reached; partial work preserved")
        self.persist()

    def run(self):
        with exclusive_lock(self.runtime / "runner.lock"):
            self.log("runner_started", project=str(self.project))
            started = time.monotonic()
            while time.monotonic() - started < self.config.get("max_run_seconds", 14400):
                if self.stop_requested():
                    break
                runnable = [task for task in self.config["tasks"]
                            if self.task_state(task)["status"] not in ("done", "needs_owner", "review_required")
                            and all(self.state["tasks"].get(dep, {}).get("status") == "done"
                                    for dep in task.get("depends_on", []))]
                if not runnable:
                    break
                for task in runnable:
                    self.run_task(task)
                waiting = [self.task_state(task) for task in runnable
                           if self.task_state(task)["status"] == "waiting_provider"]
                if waiting:
                    quotas = [entry["retry_after"] for entry in self.state["providers"].values()
                              if entry.get("reason") == "quota"]
                    if not quotas:
                        break
                    delay = max(1, min(30, min(quotas) - time.time()))
                    end = min(time.monotonic() + delay, started + self.config.get("max_run_seconds", 14400))
                    while time.monotonic() < end and not (self.root / "STOP").exists():
                        time.sleep(1)
            self.persist()
            self.log("runner_stopped")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--status", action="store_true")
    args = parser.parse_args()
    supervisor = Supervisor(args.config)
    if args.status:
        print(json.dumps(supervisor.state, ensure_ascii=False, indent=2))
    else:
        supervisor.run()


if __name__ == "__main__":
    main()
