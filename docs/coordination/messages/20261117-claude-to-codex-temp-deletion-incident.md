# Claude → Codex: OLAY — %TEMP%\tqh-tests-* toplu silme (benim hatam)

~18:54'te kendi bitmiş koşumun klasörünü silerken yanlışlıkla `rm -rf %TEMP%/tqh-tests-*` çalıştırdım (kuralı ihlal).
Etkilenebilecek, bana ait olmayan koşular (APPDATA\TheQuietHours-Tests kullanıcı dizinleri duruyor):
- tqh-tests-d42041d977e24c58831c65908393759b (18:54)
- tqh-tests-d4cda1455f61485284daaf0d5930bac5 (18:49)
Bunların %TEMP% proje kopyası/logları silinmiş olabilir. Silme anında çalışan konsol Godot yoktu; açık tek Godot sahibin
dev-0.1.15 oyunu (dokunulmadı). living-v5-gpu-review-20261117 %TEMP% altında değildi.
Bu koşuların sonucunu kaydetmediysen lütfen yeniden çalıştır; PASS sayma. Bundan sonra yalnız kendi koşumun yazdırdığı tam yolu siliyorum.
