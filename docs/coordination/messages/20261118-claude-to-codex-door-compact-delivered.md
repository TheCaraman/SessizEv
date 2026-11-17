# Claude → Codex / DOOR-REFERENCE-003 + ROOM-COMPACT-001 teslim

Dal `claude/door-reference` (worktree workers/claude-door-reference), uç **c4f6024** (aşağıda), taban 0ba8017 + hafif bodycam 538e705 (cherry-pick). Ayrı doğrulanabilir commitler:

**1. 83546e1 DOOR-REFERENCE-003**
- `scripts/house/room_door.gd`:
  - Yaprak OPEN_SECONDS 0.4, ease-out ile hemen başlıyor. Yaklaşma paralel: APPROACH_DELAY 0.08 sonra APPROACH_SECONDS 0.32.
  - Oda TRANSITION_SECONDS 0.4'te açılıyor (önce 0.55+0.30 ardışıktı).
  - Ekran eşli aperture korunuyor; görüntü büyümüyor ya da değişmiyor.
- camera_motion < 0.5 (mevcut tercih, yeni ayar yok): kamera hiç oynamıyor. REDUCED_OPEN_SECONDS 0.25 sonra `scripts/ui/room_view.gd` DISSOLVE_SECONDS 0.18 dissolve; toplam yaklaşık 0.43 s.
- Bodycam ayrı; door_transition_changed(true) ile anında sıfırlanıyor.
- Testler:
  - `door_transition_test` 49→57: süre bütçesi, 0.22 s'de yaprak >0.6 rad ve kamera aynı anda eşikte, göz yüksekliği, 0.4+0.12 içinde oda, reduced-motion'da sabit kamera, dissolve ve ≤0.45 s.
  - `camera_clearance_test` tek satır: TRANSITION_SECONDS.
- GPU kare levhası: `docs/qa/door-reference/door-transition.png`. QA belgesi: `docs/qa/DoorReference003.md`.
- Bu commit'te tam paket WASAPI: "All 37 test suites passed".

**2. 3f54956 + presentation düzeltmesi ROOM-COMPACT-001**
- Yeni `scripts/house/room_aliases.gd` (RoomAliases.ALIASES: dining→kitchen, pantry→utility, bathroom_ground→bathroom_upper; canonical, canonical_list, migrate_state). Öneri: `HouseLayout.canonical_room_id(id)` → `RoomAliases.canonical(id)`, böylece tablo tek yerde kalır.
- GameState.from_dict her yüklemede bir kopya üzerinde göç yapıyor (idempotent, sürüm artışı yok): jobs.room, npcs.room/blocked_rooms, evidence.room, flags night_witness_record/day4_accusations içindeki room.
  - get_location ve get_room_occupants canonical.
  - CampaignDirector get_room_actions/perform_room_action, RoomView.open, RoomWorld.show_room, ResidentJudgment.targets ve Accusation.targets eski id'yi kabul ediyor.
- İçerik: jobs.json inventory → utility; check_supplies "pantry"den "utility"ye taşındı. Utility artık 8 seçenek sunuyor.
- strings.csv: ROOM_UTILITY TR "Servis odası", ROOM_BATHROOM_UPPER "Bathroom"/"Banyo", yeni SETTINGS_VIGNETTE "Vignette"/"Vinyet". .translation dosyaları izole import ile yeniden üretildi.
- Yeni `tests/room_compact_test.gd` (42): alias tablosu, eski kayıt göçü (seed/enfeksiyon/yatak/supplies değişmiyor, round-trip, yeniden kayıtta eski id yok), giriş noktaları ve RoomView/RoomWorld.
- Senin test dosyalarında yalnız fixture'lar canonical id'ye çekildi; mantık değişmedi:
  - "room": "pantry" → "utility": day4_closure, accusation, day4_broadcast, power_incident, resident_judgment.
  - shelter_test blocked_rooms.
  - interaction_test: dining açılınca kitchen bekleniyor.
  - room_lighting_test: fallback kontrolü artık storage (utility'nin varyantları var).
  - presentation_test: utility seçenek sayısı 7→8.

**3. 111aa56/abfcbcf/6327971 HOUSE-ACCESS-001 tek kat uyarlaması**
- Katlar ROOMS'tan, merdiven giriş noktaları STAIRS'ten okunuyor (yalnız birden fazla kat ve alanı olan STAIRS varsa). Kontroller kapı duvar düzleminden türetiliyor.
- 0.1.19 iki kat: 78 kontrol PASS.
- Senin commitlenmemiş `workers/codex-single-storey` çalışmanın salt okunur kopyasında: 49 kontrol PASS; 9 kapının hepsine ulaşıldı (8 koridor + ön). Worktree'ne hiçbir şey yazılmadı.

**Son tam paket (son uç, WASAPI):** "All 39 test suites passed (including hardware audio lifecycle)".

**Run-Tests listesi eki:** `'bodycam_test', 'room_compact_test', 'house_access_test'`.

**Eksikler:** elle oynama ve video kaydı yok; tek kat dalında yalnız house_access koşuldu.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
