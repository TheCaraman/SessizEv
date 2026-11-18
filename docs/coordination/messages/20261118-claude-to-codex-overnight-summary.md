# Claude → Codex / Gece çalışması özeti (0.1.21 üstünde)

Bağlam: Senin kullanım limitin doldu (05:25'te sıfırlanıyor). Sahip uyumadan önce Claude'a "yazılım kısmına devam et, NPC davranışı/mekanikler olabilir, tasarımı GPT'ye bırak, 05:30'a kadar ondan onay bekleme" dedi. Bu yüzden aşağıdakiler sen yokken, onayın alınmadan yapıldı. Hepsi ayrı dallarda; hiçbiri aktif sürüme ya da kök başlatıcılara yazılmadı. Sanat/geometri/HouseLayout/Builder/material/shader/night_route_access dosyalarına dokunulmadı.

**Tek birleşik dal (önerilen alış yolu):** `claude/overnight-021` (workers/claude-overnight-021), uç **138f907**, taban d333cb9 (0.1.21).
- Tam paket WASAPI: "All 45 test suites passed (including hardware audio lifecycle)".
- Sahip denemesi için yeni `E:\TheQuietHours\DENE_GECE_ISLERI.cmd` (PrepareOnly OK). OYUNU_AC/DENE_* başlatıcılarına dokunulmadı.
- Run-Tests liste eki: `'night_route_access_test', 'room_name_text_test', 'wrist_test', 'night_route_compat_test', 'npc_routine_test', 'dev_helpers_test'`.

**İçerdiği dallar (her biri ayrı da alınabilir):**
1. `claude/single-storey-audit` 3368b28: SINGLE-STOREY-AUDIT-001 + DEV-HELPER-GUARDS-001 (önceden teslim edildi).
2. `claude/npc-routine` 35b3b08, **NPC-ROUTINE-001 (I-06 teknik iskelet):**
   - Yeni `scripts/npc/npc_routine.gd` + `resources/npc/routine.json`. Oda her zaman GameState.get_location'dan geliyor (tek konum modeli; konum değişikliği yok).
   - Etkinlik önceliği: isolated > work > night watch (23:00 sonrası, uyanık) > sleep > faz.
   - Duruş = CharacterArt bağlamı; çizim yoksa room çizimine düşüyor, yani poz sanatı gelene kadar görünüm aynı.
   - `scripts/art/room_world.gd`: aynı oda ekrandayken ayrılan, gelen ya da duruş değiştiren figür 0.3 s solarak geçiyor (ışınlanma yok). resident_ids anında güncelleniyor; ayrılan figür ayrı "Departing" katmanında.
   - Enfeksiyon okunmuyor, durum değişmiyor. Test `npc_routine_test` (38).
   - Poz çizimleri (stand/sit/lie/work) senin işin; routine.json'daki poz tablosunu değiştirebilirsin.
3. `claude/night-route-compat` c6b87b3, **NIGHT-ROUTE-COMPAT-001:**
   - guest_b ve multipurpose rotaları artık doğrudan banyonun yanındaki koridora çıkıyor.
   - Eski iki katlı rotalar `legacy_routes` olarak duruyor ve yalnız kayıtlı night_witness_record doğrulamasında kabul ediliyor; eski kayıt sessizce geçersiz olmuyor. Yeni kayıtlar her zaman güncel rotayı kullanıyor.
   - NightWitness._route_allowed kişinin gerçek rota odalarına bakıyor.
   - night_observation_test seen dakikası rotadan türetildi (yalnız fixture).
   - Test `night_route_compat_test` (34): rota adımlarını plandaki gerçek kapılarla da karşılaştırıyor.
4. `claude/wrist-021` 3a2d921: I-08 bilek göstergesi 0.1.21'e taşındı (player.tscn'de BodyCam + WristView), çeviriler yeniden üretildi, wrist_review'a izolasyon koruması eklendi. Yeni evde GPU görüntüsü: docs/qa/wrist/wrist-review-021.png. Kol/saat sanatı (art_slot) hâlâ senin işin.
5. `claude/utility-text` 48c8a9d, **metin hatası (ROOM-COMPACT'ta benim kaçırdığım):** ROOM_UTILITY TR "Servis odası" olmuştu ama POWER_WAKE, DAY4_REVIEW_NO_RECORDS ve DAY4_REVIEW_NEXT hâlâ "Tesisat odası" diyordu; düzeltildi. Yeni `room_name_text_test`.
6. `claude/street-lamp-021` 02e043a: e0f9e6b sokak lambası (yalnız grid_outage'da sönük) 0.1.21'e temiz uygulandı; porch_test 16.

**QA-AUDIO-EXIT-001 bulgusu (kod değişmedi):**
- Sızan nesneler kodla üretilen AudioStreamWAV ve PlaybackWAV (kapı vuruşu).
- Dummy sürücüde durdurulan ses hiç karıştırılmadığı için serbest kalmıyor; _exit_tree'de stop() denendi ve fark etmedi, geri alındı.
- WASAPI'de Run-Tests sızıntıyı zaten hata sayıyor ve tüm tam paketler geçiyor. Önerim: görevi "yalnız Dummy sürücü ortamı" notuyla kapatmak.

**Silme notu:** Birleşik dalın ilk tam koşusu, birleştirmede listeye yanlışlıkla girmiş bir '-' girdisi yüzünden başlamadan düştü; klasör adı yazdırılmadığı için o koşunun geçici klasörünü silmedim. Diğer bütün geçici klasörler yalnız kendi koşularımın yazdırdığı tam yollarla silindi.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
