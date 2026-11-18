# Claude → Codex / FOLEY-001: ses dosyaları sende

Sahip sentez kapı/ayak seslerini reddetti ("gerçekçi değil") ve gerçek sesleri sana yaptıracağını söyledi. Mekanik hazır, yalnız dosyalar gerekiyor.

Dal: `claude/foley` (worktree `workers/claude-foley`, taban release/dev-0.1.22). Deneme: `E:\TheQuietHours\DENE_SES.cmd`.

## Dosyaları nereye koyacaksın
`assets/audio/foley/` — `.ogg` veya `.wav`, mono tercih, uzantısız adlar:

| Dosya | Ne zaman çalar | Kural |
|---|---|---|
| `door_open` | E ile oda kapısına basıldığı an; kanat 0.40 sn'de açılır (RoomDoor.OPEN_SECONDS) | 0.2–1.5 sn. Kol + mandal başta, kanat sesi 0.40 sn içinde |
| `door_close` | Oda görünümünden çıkınca kanat kapanmaya başladığı an | Kanadın kasaya çarptığı en yüksek an dosyanın **0.45. sn**'sinde (RoomDoor.CLOSE_SECONDS), toplam ≤1.8 sn |
| `footstep_0`, `footstep_1`, … | Ahşap zeminde her adım (0.75 m'de bir, yürüyüşte ~0.31 sn, hızlıda ~0.2 sn arayla) | Her biri tek adım, 0.05–0.6 sn, en az 2 farklı çekim; ses başta (gecikmesiz) |

- Oda kapısı sesi kapının önünde 3B konumlu çalar; ayak sesi oyuncunun kendisi (2B). Ses seviyesi kodda: kapı -9 dB, adım -21 dB (hızlı -17.5 dB), adımlarda ±%4 ton ve tekrar etmeyen rastgele sıra.
- Dosya varsa sentez kullanılmaz; yoksa sentez yedek olarak kalır. Dosya sayısı/süre kurallarını `foley_test` denetler (door_close .wav ise çarpma anını da ölçer).
- Lisans: ticari oyuna uygun (kendi üretimin veya CC0) olmalı; kaynağını docs'a not et.

## Mekanik (değişmiyor)
- Ayak sesi gerçekten yürünen mesafeye bağlı, BodyCam'in çöküş anıyla aynı fazda. Kontrol yokken (menü/oda/diyalog), duraklatmada, kapı geçişinde, havadayken, duvara itilirken ve 0.6 m/sn altında adım yok.
- Kapı açılış iptalinde (Esc) ses durur; kapanırken tekrar basmak ses çıkarmaz; ön kapı ses çıkarmaz.
- Testler: foley_test + ilgili 5 paket WASAPI PASS; önceki sentez haliyle tam paket 46/46 WASAPI PASS.
- player_movement_test son adımın bitmesini bekleyip çıkıyor (WASAPI sızıntı kapısı adım ortasında çıkışı yakalıyordu).
