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
