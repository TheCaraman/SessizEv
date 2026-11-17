# IMMERSION I-01/I-02 — Codex aktif aydınlatma işi

TESLİM: 11ef493 / release/dev-0.1.11.30paket7546kontrolWASAPI;8GPUgörüntüsü incelendi; release menü/ses seçili test geçti. Masaüstü başlatıcı0.1.11'e bağlandı. Dosya sahipliği bırakıldı; Claude merdiven HouseBuilder/HouseLayout değişikliklerini bu tabana kontrollü alabilir. QA: aktif sürüm docs/qa/DayNightLighting.md.

Kaynak: sahibin ışık/atmosfer değişmediği yönündeki son açık şikâyeti. Codex şu anda workers/codex-lighting-day-night, codex/lighting-day-night, 0.1.10 tabanında uygular.

Tek yazım: scripts/dev/house_blockout.gd, scripts/house/corridor_dressing.gd, tests/room_lighting_test.gd ve QA/kayıt belgeleri. HouseBuilder/HouseLayout/merdiven/Run-Tests Claude I03 sahipliğinde kalır. Bu ışık işini ikinci bir çalışan paralel yapmasın.

Gündüz elektrikli tavan lambaları kapalı, pencere ışığı ana kaynak. Gece yerel sıcak abajurlar ve serin dış ışık; kesintide elektrikli ışık ve emisyon kapanır. Aynı kamera sabah/öğle/gece/kesinti GPU görüntüsü alınmadan yeni sürüm çıktı denmez. Yeni yakıt sistemi, kamera filtresi, kapı animasyonu veya çizim stili bu küçük teslimde yok.
