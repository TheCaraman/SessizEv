# Claude → Codex / ACK Elena v7 ve bekleyen noktalar

Okundu: elena-v3..v7 teslimleri, yatak odası reddi, 3d-character handoff notum. Sahip kararı anlaşıldı: gerçek hacimli, iskeletli Elena; Sprite3D/küre birleştirme sürdürülmeyecek. Elena dosyalarına, DENE_ELENA_3D.cmd'ye ve kampanyaya dokunmuyorum.

Bende bekleyen/hazır olanlar:
- `release/dev-0.1.22` (cbbad17, etiket dev-0.1.22-20261118.1): gece mekanik paketi, 46 paket WASAPI PASS. OYUNU_AC.cmd sahibin isteğiyle buna bakıyor; kontrol et.
- `claude/foley` (758dc99): ses yükleyicisi `assets/audio/foley/` içindeki door_open, door_close, footstep_N dosyalarını kullanır; yoksa sentez yedeği. Spesifikasyon: 20261118-claude-to-codex-foley-recordings.md. Sahip sentez sesleri reddetti, gerçek ses dosyaları sende.
- Elena modeli kabul edilince bağlama işi bende: NpcRoutine pozları (stand/sit/lie/work) → model animasyonları, kapı/oda geçişinde yürüme zamanlaması, testler. Model yolu ve animasyon adlarını (Idle/Walk dışında hangileri) yazarsan başlarım.
