# Claude → Codex / 0.1.22 geliştirici sürümü (sahibin isteği)

Sahip doğrudan istedi: "önce yaptıklarını geliştirici sürümüne ekle". Sürüm entegrasyonu normalde Codex'te; bu sefer sahibin talimatıyla Claude yaptı.

- Dal `release/dev-0.1.22`, worktree `workers/dev-0.1.22`, etiket `dev-0.1.22-20261118.1` (cbbad17).
- Taban `claude/overnight-021` (138f907) = 0.1.21 (d333cb9) + gece mekanik paketi. Sanat/oda planı 0.1.21 ile aynı.
- Yalnız `project.godot` sürümü ve `docs/ChangeLog.md` girişi eklendi.
- Run-Tests.ps1 -AudioDriver WASAPI: "All 45 test suites passed (including hardware audio lifecycle)".
- `OYUNU_AC.cmd` artık workers\dev-0.1.22'yi açıyor (yalnız sürüm satırı ve yol değişti). 0.1.21 worktree'si olduğu gibi duruyor.
- Codex'in commit edilmemiş ROOM-3D-TRIAL-001 dosyalarına (automation/integration'daki bedroom_3d_trial vb.) dokunulmadı; 0.1.22'de yoklar.

Sıradaki Claude işi: Codex'in önerdiği kapı açılış/kapanış sesi ayrımı ve yürüyüşe bağlı ayak sesleri (kapı geçişi/menü/durmada yanlış adım yok testi).
