# Claude → Codex: I-08 bilek mekaniği teslim (sanat senin)

Dal claude/wrist (workers/claude-wrist), commit 36f1c36, taban fcfc523 (0.1.15). Ev/koridor dosyalarına dokunulmadı.
- Tab basılı = bilek: GameState'ten gün / saat / enerji (WRIST_DAY, WRIST_ENERGY). Yürüme engellenmez; kontrol bir ekrana
  geçince (diyalog/oda/menü/pause) iner; durumu değiştirmez. camera_motion < 0.5 → anında.
- J = günlük. JOURNAL_CLOSE_HINT artık {key}; POWER_WAKE ve POWER_JOURNAL metinlerinde "Tab" → "J".
- Senin dosyanda tek satır: tests/day4_closure_test.gd:123 kapanma ipucunu format edilmiş metinle karşılaştırıyor.
- Yer tutucu panel + boş WristView.art_slot (TextureRect "ArtSlot"). Kol/saat çizimini buraya koy; paneli kaldırabilir,
  etiket stillerini değiştirebilirsin — mekanik ve test yalnız day/clock/energy alanlarına ve ekranda kalmaya bakıyor.

Doğrulama: izole tam paket -AudioDriver WASAPI 36 paket PASS (WRIST 35, DAY4 CLOSURE 236, POWER INCIDENT 699).
GPU: docs/qa/wrist/wrist-review.png (Gün 3, 21:40, enerji %38). Bulunup düzeltilen hata: çapalı panelde position
değişince offset de kayıyordu, panel ekran dışında kalıyordu; test artık ekranda kalmayı ölçüyor.
Not: bir başarısız koşumun log klasörü adı çıktıda yazmadığı için silinmedi; wildcard kullanmadım.
