# Asistanlar arası devir günlüğü

## 2026-11-16 — Codex — COORD-001

- Başlangıç: main / 2169bad; çalışma ağacı temizdi, remote yoktu.
- Çalışma dalı: chore/agent-coordination.
- Kullanıcı ortak çalışmayı ve gerekçesi en güçlü kararın tercih edilmesini istedi.
- Eklenenler: AGENTS.md, görev sahipliği, durum ve karar karşılaştırma belgeleri,
  taşınabilir test ve kaynak+Git geçmişi aktarma betikleri.
- Oyun mantığı ve sanat varlıkları bu görevde değiştirilmedi.
- Doğrulama: `tools/Run-Tests.ps1`; kampanya 69, etkileşim 13, ev 90, hareket 6
  denetim geçti. Temiz geçici proje kopyası içe aktarıldı; kullanıcı kayıt alanı ayrıldı.
- İlk kısıtlı süreçte editör ayarlarına yazma engeli çıktı; izinli çalıştırmada geçti.
  PowerShell süreç çıkış kodu kontrolü gerçek test sırasında düzeltilip yeniden doğrulandı.
- `git diff --check` geçti. Kaynak ZIP ve tüm dalların BUNDLE çıktısı
  `tools/Export-Handoff.ps1` ile oluşturulur ve bundle verify ile kontrol edilir.
- Kısıt: diğer asistanın bu belgeleri okuduğu veya görev aldığı henüz doğrulanmadı.
  Bu günlüğü otomatik iletişim yapılmış gibi yorumlama.
- Sahibin tercihi: uzak depo açma; yerel depoyu hazırla.
- COORD-001 tamam; dosya sahipliği bırakıldı. Sonraki görev SAVE-002 veya
  DAY2-001 olabilir. Görevi alan kişi önce tabloyu güncellesin.

## 2026-11-16 — Claude — SAVE-002

- Tarih / asistan / görev / dal / dayanak commit: 2026-11-16 / Claude / SAVE-002 /
  feat/save-002-menu-continue / 7f36500. Dal, çalışma ağacı değişmeden bu klasörde açıldı;
  yani klasörün HEAD'i artık bu dalda. Codex aktif görünmüyordu (COORD-001 bırakılmıştı).
- Değişen dosyalar ve davranış:
  - Yeni: `scripts/ui/main_menu.gd`, `scenes/main/main_menu.tscn` — başlık ekranı. Kayıt varsa
    "Devam et — Gün N", her zaman "Yeni oyun" ve "Çık". Oyun artık bu sahneyle açılır
    (`project.godot` ana sahne).
  - Yeni: `scripts/ui/pause_menu.gd` — koridorda Esc oyunu duraklatır: devam, ana menü, çık.
    Esc artık fareyi serbest bırakmıyor; o geçici davranış kaldırıldı.
  - `scripts/narrative/campaign_director.gd`: Daniel'ın odasında "Oyunu kaydet" eylemi.
    Kapıda biri varken ya da konuşma sürerken sunulmaz.
  - `scripts/save/save_manager.gd`: `get_summary()` eklendi; okuma tek bir doğrulayan
    fonksiyonda toplandı. Bozuk kayıt artık motor hatası basmadan "kayıt yok" sayılır.
  - `scripts/dev/house_blockout.gd`, `scenes/main/house_blockout.tscn`: duraklatma menüsü bağlandı.
  - `localization/strings.csv`: menü ve kayıt metinleri (İngilizce ve Türkçe).
  - Yeni test: `tests/menu_test.gd`, `tests/menu_test.tscn`. `tools/Run-Tests.ps1` beş testi çalıştırır.
  - `scripts/dev/capture_screenshots.gd`: ana menü görüntüsü eklendi; `docs/screenshots/` yenilendi.
- Doğrulama komutu ve gerçek sonucu: `powershell -NoProfile -File tools/Run-Tests.ps1` —
  kampanya 69, menü 29, etkileşim 13, ev 90, hareket 6 denetim geçti (toplam 207).
  Ana menü gerçek pencerede render edilip `docs/screenshots/08_main_menu.png` olarak kaydedildi.
- Çalıştırılmayan kontroller: Menü düğmelerine fareyle tıklama ve menüden oyuna gerçek sahne
  geçişi elle denenmedi; test, düğmelerin çağırdığı fonksiyonları ve durumu denetliyor,
  `change_scene_to_file` çağrısının kendisini değil. Gün 1 hâlâ elle baştan sona oynanmadı.
- Bilinen sorunlar ve sonraki bağımlılık: Tek kayıt yuvası var (`autosave`); elle kayıt da
  aynı yuvaya yazar. Oyuncunun koridordaki konumu kaydedilmez; devam edince başlangıç
  noktasında başlanır. Yeni sınıf eklendiği için başka bir kopyada önce `--import` gerekir.
  Sıradaki mantıklı görev DAY2-001 (önce `docs/Day2Design.md`).
- Görev sahipliği bırakıldı mı: Evet.
## 2026-11-16 — Codex — DAY2-001

- Günlük kontrolünde Claude'un SAVE-002 üzerinde aktif olduğu görüldü; bu yüzden
  ana menü işine girilmedi. Ayrı dosyalarda Gün 2 tasarımı çalışıldı.
- Dosyalar: docs/Day2Design.md, docs/coordination/claims/DAY2-001.md.
  Claude sahipliği bıraktıktan sonra TASKS.md, STATUS.md ve bu günlük güncellendi.
- Dayanak: 7f36500; teslim sırasında Claude'un ca900fe commit'i ve devir notları okundu.
- Tasarım: Marcus/Arthur ziyaretleri, beklemeyi kesen kapı olayı, özgün diyalog taslakları,
  radyo söylentisi, yataklar, tek işlemli atama, işler ve 14 kabul testi.
- Mevcut durum modeliyle karşılaştırıldı: beds/jobs için kayıt sürümü göçü gerekecek;
  enfeksiyon ataması göçte yeniden hesaplanmamalı. Uyku odası etkinlik konumu değildir.
- Doğrulama: belgeler kanon ve mevcut API'lerle karşılaştırıldı, git diff --check.
  Bu görev belge işi olduğu için yeni motor testi çalıştırılmadı. Claude'un 207 denetim
  sonucu kendi SAVE-002 teslimine aittir; burada tekrar çalıştırılmış sayılmaz.
- Gün 2 kodu yok; DAY2-002 ziyaret/diyalog uygulamasıyla başlanabilir.
- Dosya sahipliği bırakıldı. Ortak dal değiştirilmedi; yalnızca bu görevin dosyaları commit edildi.

## 2026-11-16 — Claude — DAY2-002

- Tarih / asistan / görev / dal / dayanak commit: 2026-11-16 / Claude / DAY2-002 /
  feat/day2-002-arrivals / 81bef27. Klasörün HEAD'i bu dalda.
- Kapsam: docs/Day2Design.md bölüm 2–6, 8, 9 ve 10'un ziyaret/yatak/kayıt kısmı.
  **Bölüm 7 (iş atama, activity_room) ve yönetim ekranı yapılmadı**; DAY2-003 olarak tabloda.
- Değişen dosyalar ve davranış:
  - `resources/events/arrivals.json` (yeni): ziyaretler veri olarak. Elena'nın Gün 1 ziyareti de
    buraya taşındı; yöneticide NPC adına özel kod kalmadı.
  - `scripts/narrative/campaign_director.gd`: veri güdümlü ziyaretler; aynı anda en çok bir kişi;
    ziyaret asla tekrarlanmaz; süresi dolan `left` olur. Süre harcayan eylem, gelecek ilk kapı
    çalınışında kesilir. Kapıda biri varken onu kaçıracak eylem önce uyarır, süre harcamaz;
    ikinci basışta uygulanır. Radyo Gün 2'den itibaren hafıza kaybı bildirimini bir kez verir
    (kaçırılırsa sonraki gün yine duyulur). Erzak sayımı bu gecenin tüketimini ve bir gün
    önceden kıtlık uyarısını gösterir. Son yazılı gün sabiti `LAST_AUTHORED_DAY = 2`.
  - `scripts/core/game_state.gd`: `beds`, `resolved_arrivals`, `visitor_arrival`; `admit(npc, bed)`
    artık yatak kimliği alır ve dolu yatağı reddeder; kıtlık bayrakla kaydedilir;
    `SAVE_VERSION = 2` ve v1 göçü.
  - `scripts/dialogue/dialogue_runner.gd`: `bed_choices` düğümü (boş yatakları listeler),
    `requires_free_bed`/`else_next`, seçeneklerde `args`, `cancel()`, `exists()`.
  - `scripts/ui/dialogue_view.gd`: seçenek metnini `args` ile biçimlendirir.
  - Yeni diyaloglar: `marcus_arrival`, `arthur_arrival`, `elena_resident_day2`,
    `marcus_resident_day2`, `arthur_resident_day2`. Ret onay ister; "Bana bir dakika ver"
    konuşmayı kapatır ama ziyaretçiyi göndermez. `elena_arrival` kabulü `guest_a_1` yatağını verir.
  - `localization/strings.csv`: Gün 2 metinleri, İngilizce ve Türkçe. Codex'in tablosundaki
    İngilizce satırlar aynen kullanıldı; kapı önü betimlemeleri, bekleme ve oda konuşmaları eklendi.
  - `tests/day2_test.gd`, `.tscn` (yeni); `tools/Run-Tests.ps1` altı testi çalıştırır.
- Doğrulama komutu ve gerçek sonucu: `powershell -NoProfile -File tools/Run-Tests.ps1` —
  kampanya 69, Gün 2 737, menü 29, etkileşim 13, ev 90, hareket 6 denetim geçti.
  Gün 2 testi tasarımın kabul maddelerinden 1–6, 10, 11 ve 12'yi kapsar (27 kabul/ret/kaçırma
  bileşimi dahil). Yatak seçimi ekranı gerçek pencerede render edildi:
  `docs/screenshots/09_marcus_bed_choice.png`.
- Çalıştırılmayan kontroller: kabul maddeleri 7–9 (yönetim ekranı ve işler; kod yok),
  13 (1080p/1440p taşma; yalnızca 720p görüntüye bakıldı) ve 14 (elle oynama).
  Gün 2 fare ve klavyeyle baştan sona oynanmadı.
- Tasarımdan bilinçli sapmalar (DecisionLog V-026):
  - Yatak, kabul konuşmasının içinde seçiliyor; ayrı yönetim ekranı yok.
  - Elena Gün 1'de yatak seçtirmeden `guest_a_1` alır (mevcut davranış korundu).
  - Uyarı ayrı bir onay penceresi değil: eylem ilk basışta uyarı metni döndürür.
- Bilinen sorunlar ve sonraki bağımlılık: Diyalog JSON'ları `res://` altında ham dosya olarak
  okunuyor; dışa aktarımda `*.json` filtresi gerekecek. Sakinler yalnızca yatak odalarında
  görünür (activity_room yok). Sıradaki: DAY2-003.
- Görev sahipliği bırakıldı mı: Evet.
## Her teslimde kullanılacak şablon

Tarih / asistan / görev / dal / dayanak commit:
Değişen dosyalar ve davranış:
Doğrulama komutu ve gerçek sonucu:
Çalıştırılmayan kontroller:
Bilinen sorunlar ve sonraki bağımlılık:
Görev sahipliği bırakıldı mı:

## 2026-11-16 / Codex / SAVE-SAFE-001
Dayanak 1555f81. SaveManager güvenli dosya yayın temeli, test paketi ve QA belgesi eklendi. 17 paket/5669 denetim geçti; tqh-tests-210be92b665f40d68a04773bd3c124d7. Gerçek disk arızası/elektrik kesintisi sınanmadı. Canlı durum transaction'ı ve Gün 4 uygulaması sonraki bağımlılık. Sahiplik bırakıldı.

## 2026-11-16 / Codex / SAVE-TXN-001
Dayanak 4b2887d. Aday kayıt ve ardından canlı uygulama API'si eklendi; yükleme davranışı varsayılanda korundu. 17 paket/5690 denetim geçti; tqh-tests-58a475ade0f2425c9583c0aebbd43cda. Mevcut eylemler topluca dönüştürülmedi. Gün 4 gerçek tanık/karar doğrulaması sonraki iş. Sahiplik bırakıldı.

## 2026-11-16 / Codex / DAY4-REVIEW-001
Dayanak 44578a2. İlk ücretsiz sabah değerlendirme eylemi/JournalView bağlantısı ve legacy fallback. 18 paket/5787 denetim; GPU capture 74. Tam Day4 sayılmaz. Sonraki: gerçek tanık ve nonlethal karar doğrulaması. Sahiplik bırakıldı.

## 2026-11-16 / Codex / DAY4-EXPEL-001
Dayanak 015c8fb. İlk nonlethal kovma akışı, gerçek oda ve iki basışlı anlık görüntü onayı. 19 paket/5834 denetim; GPU39. Başlangıçta Türkçe testte boş contains beklentisi hatası düzeltildi; ürün hatası değildi. Sosyal sahne/izolasyon henüz yok. Sahiplik bırakıldı.

## 2026-11-16 / Codex / DAY4-REACTION-001
Dayanak 2297898. Veriden kişisel sözler ve gerçek aynı-oda dinleyici hatırası; eski kayda geri doldurma yok. 19 paket/5867 denetim; GPU52; TR1440p bakıldı. Sahiplik bırakıldı. Sonraki: izolasyon/gece tanık kaydı; sanat aday onayı hâlâ ayrı.

## 2026-11-16 / Codex / DAY4-ISOLATE-001
Dayanak c62c66c. İlk tek günlük izolasyon hazırlama/yerleştirme/salıverme, yönetim/kayıt/konum bağlantıları. 20 paket/5946; GPU47 uyarısız son koşu. İlk testte sabit başlangıç güveni varsayımı relatif beklentiyle düzeltildi. Hazırlık dekoru/bakım ve tam Day4 hâlâ açık. Sahiplik bırakıldı.

## 2026-11-16 / Codex / DAY4-CARE-001
Dayanak d558a2d. Temel kontrol ve kişisel bakım yanıtları, ücretsiz aynı gün tekrar. 20 paket/5986; GPU73. Masaüstü kısayolu da kullanıcı isteğiyle gerçek Desktop dizinine yazıldı ve hedefi doğrulandı. Sahiplik bırakıldı; gerçek gece tanığı/nihai sanat/ileri gün bakımı açık.

## 2026-11-16 / Codex / NIGHT-WITNESS-001
Dayanak dc311d5. Yalnız veri/rota doğrulayıcısı; oyun olay üretimi tamamlanmadı. 21 paket/6024; observation38. Gelecek üretici gerçek kaynaklardan snapshot almalı, görünür teleport ve geçmiş tanık yok. Sahiplik bırakıldı.

## 2026-11-16 / Codex / VISUAL-REBUILD-001 ilk dilim
Sahip odaların tutarsızlığını, koridorun darlığını/atmosferini ve anlık resim geçişini reddetti; koridorun tamamen yeniden yapımına izin verdi. Menteşe ve eşik/fade çalışıyor, 22 paket/6033, GPU9. Mutfak yeni çizimsel üslupta gerçek RoomView'da incelendi. Görev AKTİF: koridor ve diğer odalar devam. Gece tanığı üretimine başlamadan öncelik değişti; o kod yazılmadı.

## 2026-11-16 / Codex / VISUAL-REBUILD-001 mekân teslimi
Dayanak a9b376b. Kalan11oda çizimsel yeniden üretildi ve bağlandı; 13anaoda artık ortak master. Özgün eski kaynaklar ve prompt/provenans saklandı, manifest temizlendi. 22paket/6036, GPUgaleri13 PASS. Kaynaklar incelendi, örnek gerçek RoomView'lar kontrol edildi. Kullanıcı bitince test edeceğini söyledi; bu revizyon test için hazırdır. Genel oyun hedefi devam eder. Nihai grafik kabulü ve ayrı gece/güç varyantları/karakterler açık.

## 2026-11-16 / Codex / CORRIDOR-REFERENCE-002
Sahibin son eleştirisi önceliklidir: önceki koridor kabul edilmedi. Resmî referans araştırması ve uygulama docs/qa/CorridorReferenceRevision.md. Geometri/pencere/dış sokak/kapı geçişi ikinci revizyon yapıldı, 22paket6063PASS, GPU9/64PASS. Utility ışık varyantları bu arada tamamlandı. CORRIDOR-REFERENCE-002 açık: eşya/sanat ayrıntıları henüz referans kalitesinde değil, nihai kabul iddia etme. Yerel masaüstü kısayolu aynı kanonik projeyi açar; eski çalışan oyun yeniden başlatılmalı. Diğer asistan bu dosyayı okumadan haberdar sayılmaz.

## 2026-11-16 / Kullanıcı isteğiyle tam devir
Geliştirme sürümü 0.1.1-dev.20261116.2. docs/coordination/CLAUDE_HANDOFF.md güncel ayrıntılı kaynak; yapılanlar, eksikler, testler, gerçek dosyalar ve sınırlar listeli. START_HERE içindeki eski Gün2 yok bilgisi düzeltildi. CORRIDOR-REFERENCE-002 DEVİR, Codex sahipliği bıraktı. docs/coordination/messages/20261116-codex-to-claude-checkpoint.md Claude'a yöneltilen dosya mesajıdır; okunduğu iddia edilmez. Kullanıcının denemesi için ana menüde gerçek version alanı gösterilir; mevcut kampanya kayıtlarına dokunulmaz.

Devir sürüm doğrulaması: menu80PASS, Start-Game -PrepareOnly PASS, masaüstü kısayolu hedefi doğrulandı; gerçek menü sürüm görüntüsü alındı. Normal kampanya kayıtları değiştirilmedi.

## 2026-11-16 / Claude / CORRIDOR-REFERENCE-002 eşya ve kumaş devamı
Dayanak 2e760d1 (automation/integration). Devir okundu, ACK: messages/20261116-claude-to-codex-ack.md.
Devralınan sürümde ve değişiklik sonrasında tam regresyon: 22 paket / 6063 denetim PASS (son koşu tqh-tests-d07854bd7fb34191ad42b66e1cc6cba0).
Yapılan: perdeler tek parça kıvrımlı, ışık geçiren kumaş; resimlerde derinlikli çerçeve, paspartu ve üç özgün kodla üretilmiş görüntü; kumaş paltolar, atkı, biçimli ayakkabılar, kapalı şemsiye; çevirmeli telefon, masa saati, silindir masa ayakları; üst koridora iki resim, kitaplık, battaniye ve testi. Ayrıntı ve sınırlar docs/qa/CorridorProps.md.
Gerçek GPU 1920×1080 koridor/giriş/üst kat gündüz-gece ve yakın çekim görüntüleri alınıp incelendi. Elle fare/klavye oynanışı YOK. Sahibin estetik kabulü YOK; görev DEVİR (sahip incelemesi).
Eski oturum klasöründeki yarım DAY2-003 dosyalarım geçersiz ve dokunulmadı; o işi Codex işçisi 1b3ee8f ile bitirmişti.
Sonraki: devir notu madde 2 (kapı kapanış animasyonu) veya 3 (QA-AUDIO-EXIT-001); NIGHT-001 ve ART-CHAR-002 Codex'te AKTİF görünüyor, dokunulmadı.
## 2026-11-16 / Claude / DOOR-CLOSE-001
Dayanak 253d1da. CLAUDE_HANDOFF madde 2: çıkışta ters kapanış animasyonu. room_door.gd ve door_transition_test (8→15 denetim). Tam regresyon 22 paket PASS (tqh-tests-47a5d7470bd84bc3b2fbab05662f31bd). Yeni kart/zoom yok; giriş kilidi ve oyun zamanı korunuyor. Kapanış sesi ve elle his denemesi açık. Sahiplik bırakıldı.
## 2026-11-16 / Claude / HOUSE-ATMOS-001
Dayanak c0a453c. Sahip önceki koridoru tamamen reddetti; referans oyunun resmî Steam görselleri incelenip ilkeler çıkarıldı (docs/qa/HouseAtmosphere.md). Ev ×1,25 (15 × 12,5 m), kat 3,3 m. Yeşil tek renkli ton, mürekkep konturu, oval kararma, sinema şeritleri; damask duvar tavana kadar, alt panel kaldırıldı; açık renk kapı ve kasalar; jaluzi + pus içi huzme; ortam ve lambalar kısıldı; holde yazı dolabı, pencere altlarında radyatör; eşyalar yeni plana taşındı. Testlerdeki sabit koordinatlar güncellendi; ev testindeki "3 m hol" kuralı "en az 3,7 m" oldu. Tam regresyon 22 paket PASS (tqh-tests-751d6d9d176648948a3e1ef75d865683). Gerçek GPU görüntüleri incelendi. Elle oynanış ve sahip kabulü YOK. Codex'e koordinat değişikliği mesajı: messages/20261116-claude-to-codex-house-scale.md.

## 2026-11-16 / Claude / HOUSE-ATMOS-002
Dayanak ac00028. Sahip: hâlâ basık/boğucu, renkler gerçek ev gibi değil, gece daha çok ışık. Hol iki kat yüksekliğinde (galeri + tepe penceresi), açık ev renkleri, hafif ton, gece ay ışığı ve saate bağlı ortam ışığı, merdiven balüstradı. 22 paket PASS (tqh-tests-edb936fceae440c58f5f3813774219aa). Gerçek GPU gündüz/gece görüntüleri incelendi. Elle oynanış ve sahip kabulü YOK. Codex'e mesaj: messages/20261116-claude-to-codex-gallery.md.

## 2026-11-16 / Codex / HOUSE-ATMOS-004
Dayanak3f5fb32, dalcodex/house-atmosphere-v3. Sahip son evi yine reddetti ve yeniden tasarlama istedi. Geniş tam üst koridor, kapalı normal kat hacmi, özgün üç diffuse ve kaynak temelli okunur ışık; perde aralığıyla dış dünya. Başlangıçfloor ve xguard üst kapak hataları düzeltildi. 22paket6072PASS; sabitGPUgörüntüleri mevcut. Elle oyun hissi/sanat kabulü hâlâ açık. Canonicalproject003 uncommitted adayları değişmedi. Yeni deneme sürümü0.1.2-dev.20261116.3; source branch ile launcher seçimi ayrı kaydedilecek. Aynı dosyalara eşzamanlı entegrasyon yapma; ayrı dalla devam edildiğini dikkate al.

## 2026-11-16 / Codex / QA-AUDIO-EXIT-001
Yalnız test/araç/QA. Gerçek WASAPI ile etkin kapı+boru seslerinin sahne sökülünce stream/playback weakref temizliği3kez ölçüldü,35PASS. Doğru CLI sırasıyla23paket6107PASS; ayrı günlüklerdeObjectDB uyarısı yok. Default headless/Dummy uyarısı hâlâ ayrı açık araştırma. İşe yaramayan stop/null/wait ürün yamaları bırakılmadı. Ek negatif komut otomatikonay incelemesince blocked by policy reddedildi, tekrar denenmedi. Kullanıcı oynatma sürümü/görsel aynı; ses kalite/dinleme incelemesi ayrıca açık. Ayrı worktree görevi bırakıldı.

## 2026-11-16 / Codex / SETTINGS-PLAYTEST-001
Dayanaka4fdffa. Üç temel tercih ve ana/pause modalSettingsView, Settingsload/commit/signal, kamera ve sahne-yerelWorldPresentation, 2DRGB/alpha koruması. Localization6yeni anahtar, genel save hata cümlesi.70ayar denetimi; gerçekTab vepausegirdisi SubViewportpush_input. İlk rootinputfixture hatası düzeltildi. Son24paket6196WASAPIPASS, GPU72 ve EN/TR görselincelendi. İlkfullpassWASAPIsunumexit2ObjectDByarışı buldu; presentation testteardownayırtlıweakrefbekleme eklendi, üç89koşu ve sonfullpass temiz. Önceki Dummy-only açıklaması açıkça düzeltildi. Defaultartist/gamestate/schema aynı; sürüm0.1.3-dev.20261116.4. YeniMotion/lens hâlâ kapalı aday, varsayılıonay yok. Ayrı kalıcıdal, kanonik003dosyaları korunur.

## 2026-11-16 / Codex / SETTINGS-AUDIO-001
Dayanak8034a5f. Mevcut Settings üzerinden Master gain/mute; yeniautoload yok. Ana/pause dördüncüslider, CSVEN/TR; settings90 ve tam24/6219 PASS, GPU92;720p/1080p/1440p sınırları/gerçekTab6kontrol ve pauseESC korundu. docs/qa/MasterVolume.md ve master-volume-last-run.json kanıtı. Eski ses miksajı varsayılan100%, kampanyadan ayrı. Sürüm0.1.4-dev.20261116.5; sahiplik bırakıldı. Nihai sesmikseri tamamlanmış sayılmaz.

## 2026-11-17 / Codex / NIGHT-WITNESS-002
Dayanak4de7e6c. NightSessionwitness+NightRouteAccess ölçümü, offscreenCallable, yeni protocolflag, valid_completedtrace ve args'lıclaimkataloğu. Eski aktifgece protokolsüz kalır. Subjectbathroom/observerpipechecking, enfeksiyonseçimdemaz; first10dk ve ücretsizreread. Flagrecord iç içe tam sayı ve konummm ile JSON eşitliği düzeltildi; SaveManagerevidenceargs sözlükvalidasyonu ve pipebeforewake.25/; finaldakikaetiketi/UI genişletme83target/85GPU, EN/TR720p/1080p/1440p. Tümkomutlar izoleuserdata. Olay yalnızDanielodasında tamamlanan beklemeye bağlı; genelNPCnavdeğil, partialGün4. YeniUIDler ve importedtranslations Git'e alınmalı. Görev bırakıldı.

## 2026-11-17 / Codex / DAY4-CLOSURE-001
Dayanak50cdc75 ayrıaktifdal. Day4Closure RefCounted/CampaignDirector injectedShelterManager; optionalflags,defer/wait/complete/summary. Öncekicomplete mantığı _complete_in(state,id,at) ortakreducer, project_daytime safcandidate; mevcutnormal/nightcomplete kuralları korunur. Onayquote tümstatecompare,roomclose/day_startedloadcancel, savedbeforelive. Timestampsemantics; summary currentpublicstate, fixedcompletiontime. JournalCloseHint ve actualpauseeventtest.26paket/; closure236 veGPU238, EN/TR720p/1080p/1440p. Kaynak/kampanya ayarları korunur. GüncelChangeLog oluşturuldu, README/CLAUDE_HANDOFF güncellendi. Görev bırakıldı; tamGün4/yayın/açık suçlama/ilişkiler eksik.

## 2026-11-17 / Codex / DAY4-ACCUSATION-001
Dayanak 5b75b02, ayrı aktif dal. Accusation (RefCounted), AccusationView (CanvasLayer24), EventBus isteği ve aynı RoomView içinde kişisel yanıt eklendi. Kurallar/yanıtlar/basis kataloğu veri dosyasında. Save v5 optional flags/day4_accusations[id] karar ve belleği tutar; record/claim eşliği, kaynak ve zaman doğrulanır, iç içe sayılar normalize edilir.

Gerçek NightWitness.subject ile eşleşen görüşülmüş iddia hareket dayanağıdır; enfeksiyon veya sabotaj kanıtı değildir. Genel güç bulgusu kişiyi belirlemez. Varsayılan Cancel, Review→Confirm, kayıttan önce canlı değişiklik yok; ilk10dk/güven−5, tekrarda ücretsiz yanıt. Hedef konumu/konuşabilirliği/işi kontrol edilir, izolasyonda kapıdan konuşulur. Diğer biten işler aynı adayda ortak reducer ile çözülür.

27 paket / 6809 denetim WASAPI, suçlama139 ve GPU141 geçti. EN/TR üç çözünürlük ve gerçek Tab/Escape eylemi doğrulandı. SVG ikon kontrastı iyileştirildi. Birleşik komutun policy reddi yürütülmüş test sayılmaz; ayrı apply_patch ve Run-Tests başarılı. Ayrıntı QA: Accusation.md, accusation-last-run.json. Görev sahipliği bırakıldı. Sonraki bağımlılık Gün4 tahliye yayınıdır; genel ilişkiler/tam kampanya ve sanat kabulü eksik.
