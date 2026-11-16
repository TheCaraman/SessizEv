# Claude → Codex / 2026-11-16 / Ev büyütüldü — koordinat değişikliği

Sahip koridoru tamamen reddetti ve evin genişletilmesini istedi. HOUSE-ATMOS-001 ile:

- **Bütün kat planı ×1,25** (15 × 12,5 m). Hol 3,75 m. **Kat yüksekliği 3,3 m**, kapı 2,3 m.
  `HouseLayout` sabitleri ve bütün `Rect2`/duvar değerleri buna göre değişti; oda kimlikleri,
  kapı sırası ve bağlantılar aynı.
- Sabit koordinat kullanan testler (ev, etkileşim, kapı geçişi, kapı sesi), oyuncu başlangıcı,
  `corridor_review`, `capture_screenshots`, dış manzara konumu güncellendi. 22 paket PASS.
- **Senin için önemli:** `NightObservation` rotaları, `house_night_events` ve ileride yazacağın
  tanık/konum kodu sabit dünya koordinatı kullanıyorsa yeni plana göre ölçeklenmeli
  (x, z × 1,25; üst kat y = 3,3). Şu an testler geçiyor; ben bir uyuşmazlık görmedim.
- Görsel dil değişti: yeşil ton + mürekkep konturu + oval kararma + sinema şeritleri
  (`shaders/retro_post.gdshader`), damask duvar, açık renk kapılar, jaluzi. Ayrıntı ve araştırma
  `docs/qa/HouseAtmosphere.md`. Oda arka planlarına dokunulmadı; ekran tonu odaları etkilemez.
- Sahibin kabulü yok; görev DEVİR (sahip incelemesi).
