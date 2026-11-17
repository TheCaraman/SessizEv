# Claude → Codex / BODYCAM-002 teslim

Dal `claude/bodycam-002` (worktree workers/claude-bodycam-002), uç **d182c57**. Taban 30fdc19 + onaylı 0.38 gövde (b03b0d1 cherry-pick = 36ece66).

**Dosyalar:**
- Yeni: `scripts/player/body_cam_motion.gd`, `tests/bodycam_test.gd/.tscn`, `scripts/dev/bodycam_review.gd/.tscn`, `docs/qa/BodyCam002.md`, `docs/qa/bodycam/bodycam-review.png`.
- Değişen: `scenes/player/player.tscn` (BodyCam düğümü, load_steps 5, ext_resource 3_bodycam), `scripts/player/player_controller.gd` (yeni `control_changed` sinyali; `get_look_direction()` artık kamera yönünü veriyor; kullanıcısı yok).
- Paylaşılan dosyalar: `tools/Run-Tests.ps1` liste satırına `'bodycam_test'` eklendi (player_movement_test'ten sonra). I08 ve CameraClip ile birleşirken listede `wrist_test`, `camera_clearance_test` ve `bodycam_test` birlikte kalmalı.
- 0.38 gövde değişikliği `tests/house_layout_test.gd:18` satırını da içeriyor.

**Davranış:**
- Hareket Head/Camera3D'nin yerel dönüşümünde. Yürürken adım başına dip 3.8 cm, yan kayma 2.4 cm, yatma 1.5°, baş sallama 0.55°. Hızlı yürüyüşte yaklaşık 1.6 kat; ofset 6 cm ile sınırlı.
- Dönüşte yatma en çok 3°, gecikme en çok 2°; yay ile yumuşak oturuyor. Durunca yaklaşık 0.5 s'de yerine yerleşiyor.
- camera_motion < 0.5 ise tamamen kapalı. Kontrol kaybında (diyalog/oda/barınak/günlük) control_changed ile anında sıfırlanıyor. Pause'da bir kare içinde sıfırlanıyor.
- Kapı geçişinde door_transition_changed(true) geldiğinde senkron olarak sıfırlanıyor; bu, room_door `_camera_start`'ı yakalamadan önce oluyor. Tween boyunca kameraya yazmıyor. room_door.gd değişmedi.
- Dururken kameraya hiç yazmıyor (peephole aiming korunuyor).
- Bulanıklık/pixelation/kromatik efekt yok.

**Test (Run-Tests, izole):**
- Tam paket WASAPI: "All 36 test suites passed (including hardware audio lifecycle)". Bu koşu ilk genliklerle yapıldı (dip 3.2 cm, roll 1.1°).
- Genlikler son değerlere yükseltildikten sonra seçili koşu geçti: bodycam 53, door_transition 49, peephole 31, player_movement 6. Bu kısmi koşuda (ses sürücüsü yok) peephole_test için "Object lifetime warning" çıktı; tabanla karşılaştırmadım.
- GPU 1280×720 kontak sayfası incelendi: yürüme karelerinde zıt yatma, dönüşte yatma görünüyor.

**Eksikler:**
- Video/GIF kaydı yok.
- Fareyle elle oynanmadı; testte dönüş rotate_y ile yapıldı.
- Yeni ev (house-rebuild-v2) kapsanmadı.
- `body_cam_motion.gd.uid` commitlenmedi; import'ta oluşur.

Sahip denemesi için `E:\TheQuietHours\DENE_BODYCAM.cmd` var (PrepareOnly OK). Kök aktif başlatıcılar değişmedi. Silinen geçici klasörler yalnız kendi koşularımın yazdırdığı üç tam yol.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
