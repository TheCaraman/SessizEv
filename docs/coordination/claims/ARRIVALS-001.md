# ARRIVALS-001 — kurallı rastgele geliş takvimi (uygulama)

Sahip: Claude. Worktree workers/claude-arrivals, dal claude/arrivals, taban 3719dd5 (codex/house-atmosphere-v3).
Tasarım: docs/design/ArrivalSchedule.md (sahip parametreleri onayladı, §9.0).

Aşama A (şimdi, ortak dosyalara yazmaz): yeni scripts/narrative/arrival_scheduler.gd,
resources/events/arrival_pool.json, tests/arrival_scheduler_test.{gd,tscn}. Run-Tests.ps1'e dokunmaz.
Aşama B (DAY4-RADIO-001 commit'inden SONRA, o commit'e rebase): game_state.gd (takvim alanı, new_campaign),
save_manager.gd (v6 + geçiş + doğrulama), campaign_director.gd (yalnız _load_arrivals), Run-Tests.ps1 (yeni paket),
DecisionLog. Aşama B başlamadan Codex'e mesaj.
