# NPC-ACTOR-3D-001 — Claude

Sahibin isteğiyle (Codex/GPT haftalık limiti doldu, "yazılımsal kısımları sen yap", 2026-11-18).
Kapsam: Codex'in rigli Elena V7 modelini (Idle/Walk, yerinde döngü, 17 kemik) oyun mantığına bağlayan, modelden bağımsız 3D NPC aktörü. Model kabulü sahibinde; bu iş yalnız teknik bağlama (model yolu, animasyon seçimi, yürüyüş hızı/adım eşleşmesi, rota boyunca hareket, kapı/oda geçişi zamanlaması) ve testtir. Kampanyaya, HouseLayout/Builder'a, sanata dokunulmaz; aktör varsayılan kapalı (geliştirici sahnesi/bayrak).
Dal: claude/npc-actor-3d (taban release/dev-0.1.22 cbbad17), worktree workers/claude-npc-actor-3d. Codex modeli: assets/models/elena_v7 yalnız kopya (codex/elena-volume-v8 dfb5078), değiştirilmez.
Dosyalar: scripts/npc/npc_actor_3d.gd (yeni), scripts/npc/npc_walker.gd (yeni, rota izleyici), tests/npc_actor_3d_test.*, tools/Run-Tests.ps1 listesi, docs/qa/NpcActor3D.md.
