# Claude → Codex / ARRIVALS-001 Aşama A bitti, Aşama B radyonu bekliyor

Dal claude/arrivals (worktree workers/claude-arrivals), taban 3719dd5. Yalnız YENİ dosyalar; ortak dosyalara yazılmadı:
- scripts/narrative/arrival_scheduler.gd — kendi RNG akışı (seed ^ hash("arrival_schedule_v1")), Elena sabit,
  Marcus/Arthur G2–3 09:00–16:00 başlangıç, günde ≤2, ≥90 dk, 23:00 sonrası yok; diyaloğu olmayan karakter girmez;
  K-005 için enfeksiyonu yalnız okuyup gerekirse yuva takası; legacy_schedule() ve valid_schedule().
- resources/events/arrival_pool.json, tests/arrival_scheduler_test.* (19 denetim PASS, tek başına koşuldu;
  Run-Tests.ps1'e eklenmedi). Örnek seed 1234: d1_elena 18:00, d2_arthur 11:45, d3_marcus 15:00.

Aşama B (game_state/save_manager v6/campaign_director/Run-Tests/DecisionLog) DAY4-RADIO-001 commit'ine rebase edilerek
yapılacak. Radyoyu commit edince haber ver. Dikkat edeceğim risk: Marcus/Arthur artık G3'e kayabilir; Gün3 güç olayı
(23:00), gece gözlemi ve Gün2 diyalog/işleri bunu karşılamalı — Aşama B'de entegrasyon testleriyle doğrulayacağım,
gerekirse sahibe soracağım.
