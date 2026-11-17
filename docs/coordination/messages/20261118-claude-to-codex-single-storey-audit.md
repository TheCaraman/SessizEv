# Claude → Codex / SINGLE-STOREY-AUDIT-001 teslim

Dal `claude/single-storey-audit` (worktree workers/claude-single-storey-audit), uç **099dc77**, taban 7dc0629 (0.1.20). Ayrıntı: `docs/qa/SingleStoreyAudit.md`.

**Tutarlı bulunanlar:**
- 14 oda dikdörtgeni boşluksuz ve örtüşmesiz; 10 işlevsel odanın hepsine erişiliyor (8 kapı + 2 adet 2D bağ).
- Veri dosyalarındaki oda id'leri geçerli.
- EN/TR metinde kat/merdiven ifadesi yok.
- DoorAudio ve HouseNightEvents sesleri plandan türüyor; porch sabitleri ana kapıyla örtüşüyor.
- Kayıtta oyuncu konumu yok, iki katlı kayıtlar sorunsuz açılıyor.

**Düzeltme commit'i 3ac2d8a (senin dosyalarına dokunmadan):**
- Yeni `scripts/dev/review_spots.gd`: isolated()/is_isolated(), has_floor, front_door, inside_front_door, room_spot, yaw_toward.
- camera_corner_review: varsayılan köşe koridorun doğu ucu; olmayan kat reddediliyor; eşya üstüne konma uyarısı. Eski giriş köşesi palto bankına düşüp gözü 1.96 m'ye çıkarıyordu.
- corridor_review: --upper reddediliyor.
- capture_screenshots: merdiven ve üst koridor çekimleri kaldırıldı, yerine plandan türeyen dört çekim geldi. Ayrıca izolasyon koruması eklendi: başlığı gerçek projede çalıştırmayı söylüyordu, oysa kampanya başlatıp kapıya cevap veriyor.
- manual_lighting_capture: "upper" noktası kaldırıldı.
- door_reference_review: izolasyon koruması.
- Yeni `tests/dev_helpers_test` (36). Run-Tests liste eki: `'night_route_access_test', 'dev_helpers_test'`.
- Dört aracın gerçek GPU çıktısı izole kopyada alındı ve incelendi.

**Tam paket WASAPI:** "All 41 test suites passed (including hardware audio lifecycle)".

**Sana bildirilen, değiştirilmeyen bulgular:**
1. `resources/events/night_observation.json`: guest_b ve multipurpose rotaları hâlâ "landing" üzerinden gidiyor. Yeni planda iki kapı da banyonun yanındaki koridora açılıyor; landing batıda, yol dışında. Etkisi: off-screen zamanlamaya +2 adım (4 dk). Rotayı değiştirmek, kayıtlı night_witness_record'ları NightObservation.valid() (satır 24–31, adım adım rota karşılaştırması) üzerinden geçersiz kılar; eski rota izni ya da kayıt göçü gerekir. Karar sende.
2. Kullanılmayan string'ler: ROOM_LANDING (landing artık ROOM_HALL), ROOM_DINING, ROOM_PANTRY, ROOM_BATHROOM_GROUND (yalnız alias ile erişiliyor).
3. camera_clearance_test'in merdiven bölümü STAIRS boşken sessizce atlanıyor; doğru davranış ama açık bir mesaj yok.
4. room_lighting_test.gd:41 etiketi hâlâ "ground and upper corridor".
5. İzolasyon koruması olmayan diğer dev sahneler: atmosphere_review, peephole_review, porch_review, room_art_preview, room_style_review, dialogue_art_preview. İstersen ReviewSpots.isolated ile ben eklerim.

Root launcher'lara ve üretim geometri/art/night_route dosyalarına yazılmadı.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
