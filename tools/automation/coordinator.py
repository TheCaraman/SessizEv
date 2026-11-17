"""Durable, bounded CLI work/review pipeline. Does not drive desktop chat windows."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import time

from base_runner import Supervisor, SCHEMA, exclusive_lock, now, read_json, save_json

REVIEW_SCHEMA = {
    "type": "object", "additionalProperties": False,
    "properties": {
        "status": {"type": "string", "enum": ["approved", "changes_requested", "needs_owner"]},
        "summary": {"type": "string"},
        "tests": {"type": "array", "items": {"type": "string"}},
    }, "required": ["status", "summary", "tests"],
}
TERMINAL = {"done", "needs_owner", "review_required"}


class Coordinator(Supervisor):
    def __init__(self, config_path: Path):
        super().__init__(config_path)
        self.runtime = self.root / "runtime" / "continuous"
        self.runtime.mkdir(parents=True, exist_ok=True)
        self.state_path = self.runtime / "state.json"
        self.state = read_json(self.state_path, {"tasks": {}, "providers": {}})
        self.stop_path = self.root / "STOP_CONTINUOUS"

    def persist(self):
        self.state["heartbeat"] = now()
        self.state["pid"] = os.getpid()
        save_json(self.state_path, self.state)
        lines = ["THE QUIET HOURS — Otomatik görev / inceleme", now(), ""]
        for task in self.config["tasks"]:
            item = self.task_state(task)
            lines.append(f"{task['id']}: {item['status']} — {item.get('detail', '')}")
        lines += ["", "Durdur: OTOMASYONU_DURDUR.cmd", "Kaynak: " + str(self.project)]
        (self.root / "DURUM_OTOMATIK.txt").write_text("\n".join(lines), encoding="utf-8-sig")

    def stopped(self):
        return self.stop_path.exists()

    def stop_requested(self):
        return self.stopped()

    def _snapshot(self, workspace, base):
        files = {}
        for name in self.changed_paths(workspace, base):
            path = workspace / name
            files[name] = hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else "deleted"
        return (self.git_run("rev-parse", "HEAD", cwd=workspace),
                self.git_run("branch", "--show-current", cwd=workspace), files)

    def _choose(self, preferred=None, excluding=None):
        providers = list(self.config["providers"])
        providers.sort(key=lambda p: p["name"] != preferred)
        return next((p for p in providers if p["name"] != excluding and self.eligible(p)), None)

    def _unavailable(self, provider, response):
        reason = response.get("error", "error")
        delay = 3 * 3600 if reason == "quota" else (24 * 3600 if reason == "auth" else 60)
        self.state["providers"][provider["name"]] = {
            "reason": reason, "checked_at": time.time(),
            "retry_after": response.get("retry_after", time.time() + delay) if reason == "quota" else time.time() + delay,
        }

    def _call(self, task, item, provider, workspace, prompt, review=False):
        if int(item.get("calls", 0)) >= int(task.get("max_agent_calls", 8)):
            raise RuntimeError("Task agent-call limit reached; partial work preserved")
        item["calls"] = int(item.get("calls", 0)) + 1
        self.persist()
        tag = task["id"] + "-" + str(item["calls"]) + ("-review-" if review else "-work-") + provider["name"]
        self.log("review_started" if review else "task_started", task=task["id"], provider=provider["name"])
        return self.agent(provider, workspace, prompt, tag,
                          result_schema=REVIEW_SCHEMA if review else SCHEMA, read_only=review)

    def _review_prompt(self, task, item):
        return ("Salt okunur bağımsız THE QUIET HOURS incelemesi. Kod/dosya/branch/commit değiştirme, "
                "Kaynakları salt okunur araçlarla incele. Claude için Read/Glob/Grep kullan; "
                "Codex için mevcut exec araçlarıyla yalnız dosya okuma ve git diff/status komutları kullan. "
                "Dosya yazan komutlar ve test çalıştırmak yasak. Türkçe raporla. "
                "Uygulamayı görev kapsamı ve kanonla karşılaştır; gerçek hata varsa changes_requested, "
                "yalnız sahibin kararı gerekirse needs_owner, aksi halde approved döndür. "
                "Testleri sen çalıştırmadıysan çalıştırdım deme; dış yönetici test kapısını çalıştırır. "
                "Başka asistanı veya kullanıcıyı rutin başlama onayı için bekleme.\nGörev: "
                + task["instruction"] + "\nİzinli yollar: " + json.dumps(task["allowed_paths"])
                + "\nTaban: " + item["base"])

    def prompt(self, task, workspace, item):
        previous = [{"id": identifier, "status": record["status"], "detail": record.get("detail", ""),
                     "review": record.get("review", {})} for identifier, record in self.state["tasks"].items()]
        return (super().prompt(task, workspace, item)
                + "\nKoordinasyon özeti (diğer asistanın incelemesi dahil): "
                + json.dumps(previous[-8:], ensure_ascii=False)
                + "\nAna manuel Claude ARRIVALS çalışmasına, onun worktree'sine ve aktif deneme başlatıcısına dokunma.")

    def _publish(self, task, item, stage, content):
        folder = self.root / "project" / "docs" / "coordination" / "messages"
        folder.mkdir(parents=True, exist_ok=True)
        filename = "auto-" + task["id"] + "-" + str(item.get("calls", 0)) + "-" + stage + ".md"
        path = folder / filename
        temporary = path.with_suffix(".md.pending")
        temporary.write_text("# Otomatik koordinasyon — " + task["id"] + " / " + stage
                             + "\n\n" + now() + "\n\n" + content
                             + "\n\nKaynak: runtime/continuous/state.json. Bu CLI çalışanı çıktısıdır; masaüstü sohbet ACK'i değildir.\n",
                             encoding="utf-8")
        os.replace(temporary, path)

    def run_task(self, task):
        item = self.task_state(task)
        if item["status"] in TERMINAL:
            return
        if int(item.get("calls", 0)) >= int(task.get("max_agent_calls", 8)):
            item.update(status="review_required", detail="Çağrı sınırı; çalışma ve günlükler korundu")
            self.persist()
            return
        try:
            if self.git_run("branch", "--show-current") != self.config["expected_branch"]:
                raise RuntimeError("Integration branch changed; refusing to write")
            workspace = self.prepare(task)
            if not item.get("worker_done"):
                provider = self._choose(task.get("provider"))
                if provider is None:
                    item.update(status="waiting_provider", detail="Kullanılabilir çalışan bekleniyor")
                    self.persist()
                    return
                item.update(status="running", attempts=item.get("attempts", 0) + 1,
                            detail=provider["name"] + " uyguluyor")
                result = self._call(task, item, provider, workspace, self.prompt(task, workspace, item))
                if "error" in result:
                    self._unavailable(provider, result)
                    item.update(status="waiting_provider", detail="Çalışan durdu: " + result["error"])
                    self.persist()
                    return
                if result["status"] == "needs_owner":
                    item.update(status="needs_owner", detail=result["summary"])
                    self.persist()
                    return
                item.update(worker_done=True, worker_provider=provider["name"], detail=result["summary"])
                self._publish(task, item, "worker", provider["name"] + ": " + result["summary"])
                self.persist()

            self.validate_scope(task, workspace, item)
            if not item.get("review_approved"):
                reviewer = self._choose(task.get("reviewer"), excluding=item["worker_provider"])
                if reviewer is None:
                    item.update(status="waiting_reviewer", detail="Diğer asistanın incelemesi bekleniyor; uygulama korunur")
                    self.persist()
                    return
                before = self._snapshot(workspace, item["base"])
                item.update(status="reviewing", detail=reviewer["name"] + " bağımsız inceliyor")
                result = self._call(task, item, reviewer, workspace, self._review_prompt(task, item), review=True)
                if self._snapshot(workspace, item["base"]) != before:
                    raise RuntimeError("Read-only reviewer modified candidate; integration blocked")
                if "error" in result:
                    self._unavailable(reviewer, result)
                    item.update(status="waiting_reviewer", detail="İnceleyici durdu: " + result["error"])
                    self.persist()
                    return
                item["review"] = {"provider": reviewer["name"], **result}
                self._publish(task, item, "review", reviewer["name"] + ": " + result["status"] + "\n\n" + result["summary"])
                self.log("review_completed", task=task["id"], provider=reviewer["name"], result=result["status"])
                if result["status"] == "needs_owner":
                    item.update(status="needs_owner", detail=result["summary"])
                    self.persist()
                    return
                if result["status"] == "changes_requested":
                    item.update(worker_done=False, status="queued", feedback=result["summary"], detail="İnceleme düzeltmesi isteniyor")
                    self.persist()
                    return
                item["review_approved"] = True
                self.persist()

            item.update(status="testing", detail="Dış test kapısı çalışıyor")
            self.persist()
            passed, feedback = self.gate(task, workspace, task["id"] + "-" + str(item.get("calls", 0)))
            if not passed:
                item.update(worker_done=False, review_approved=False, status="queued", feedback=feedback,
                            detail="Test başarısız; düzeltmeye dönüldü")
                self.persist()
                return
            self.integrate(task, workspace, item)
            item.update(status="done", completed=now(), detail="Bağımsız inceleme ve dış test kapısı geçti")
            self.log("task_done", task=task["id"], commit=item["commit"])
            self._publish(task, item, "done", "Bağımsız inceleme ve test geçti. Ayrı integration commit: " + item["commit"]
                          + ". Aktif oyuncu başlatıcısı değiştirilmedi.")
            self.persist()
        except (RuntimeError, ValueError, OSError) as error:
            item.update(status="review_required", detail=str(error))
            self.log("integration_blocked", task=task["id"], detail=str(error))
            self.persist()

    def _reload(self):
        candidate = read_json(self.config_path)
        if candidate["project"] != self.config["project"] or candidate["expected_branch"] != self.config["expected_branch"]:
            raise RuntimeError("Live configuration cannot redirect the integration target")
        identifiers = [task["id"] for task in candidate["tasks"]]
        if len(identifiers) != len(set(identifiers)):
            raise ValueError("Duplicate task id")
        if any(not identifier.replace("-", "").isalnum() for identifier in identifiers):
            raise ValueError("Invalid task id")
        edges = {task["id"]: task.get("depends_on", []) for task in candidate["tasks"]}
        visiting, visited = set(), set()

        def visit(identifier):
            if identifier in visiting:
                raise ValueError("Cyclic task dependency")
            if identifier in visited:
                return
            if identifier not in edges:
                if self.state["tasks"].get(identifier, {}).get("status") == "done":
                    return
                raise ValueError("Unknown task dependency: " + identifier)
            visiting.add(identifier)
            for dependency in edges[identifier]:
                visit(dependency)
            visiting.remove(identifier)
            visited.add(identifier)

        for identifier in identifiers:
            visit(identifier)
        for old in self.config["tasks"]:
            if old["id"] not in identifiers and self.state["tasks"].get(old["id"], {}).get("workspace") and self.state["tasks"][old["id"]]["status"] not in TERMINAL:
                raise RuntimeError("Cannot remove a started unfinished task")
        for task in candidate["tasks"]:
            old = next((t for t in self.config["tasks"] if t["id"] == task["id"]), None)
            if old is not None and task != old and self.state["tasks"].get(task["id"], {}).get("workspace"):
                raise RuntimeError("Started tasks are immutable; append a new task id")
        self.config = candidate

    def _wait(self, seconds):
        end = time.monotonic() + seconds
        while time.monotonic() < end and not self.stopped():
            time.sleep(min(1, max(0, end - time.monotonic())))

    def run(self):
        with exclusive_lock(self.runtime / "runner.lock"):
            self.log("coordinator_started", project=str(self.project), pid=os.getpid())
            started = time.monotonic()
            while not self.stopped():
                limit = int(self.config.get("max_run_seconds", 0))
                if limit > 0 and time.monotonic() - started >= limit:
                    break
                self._reload()
                for task in self.config["tasks"]:
                    if self.stopped():
                        break
                    if self.task_state(task)["status"] not in TERMINAL and all(
                        self.state["tasks"].get(dep, {}).get("status") == "done" for dep in task.get("depends_on", [])
                    ):
                        self.run_task(task)
                self.persist()
                self._wait(int(self.config.get("poll_seconds", 30)))
            self.log("coordinator_stopped")
            self.persist()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True, type=Path)
    parser.add_argument("--status", action="store_true")
    options = parser.parse_args()
    coordinator = Coordinator(options.config)
    if options.status:
        print(json.dumps(coordinator.state, ensure_ascii=False, indent=2))
    else:
        coordinator.run()
