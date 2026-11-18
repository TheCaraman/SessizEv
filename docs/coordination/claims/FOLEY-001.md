# FOLEY-001 — Claude

Sahibin onayıyla ("evet ses işine başla", 2026-11-18). Codex devri: 20261118-codex-to-claude-owner-bedroom-3d-trial.
Kapsam: oda kapısı açılış/kapanış sesi ayrımı, yürüyüşe bağlı ayak sesi zamanlaması; kapı geçişi, menü, oda görünümü ve durmada yanlış adım yok testi. Sentezlenmiş yer tutucu sesler (son foley değil).
Dal: claude/foley (taban release/dev-0.1.22 cbbad17), worktree workers/claude-foley.
Dosyalar: scripts/audio/foley.gd (yeni), scripts/player/footsteps.gd (yeni), scripts/house/room_door.gd (ses çağrıları), scenes/player/player.tscn (Footsteps düğümü), tests/foley_test.*, tools/Run-Tests.ps1 listesi.
