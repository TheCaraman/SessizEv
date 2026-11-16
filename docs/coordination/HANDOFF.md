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
## Her teslimde kullanılacak şablon

Tarih / asistan / görev / dal / dayanak commit:
Değişen dosyalar ve davranış:
Doğrulama komutu ve gerçek sonucu:
Çalıştırılmayan kontroller:
Bilinen sorunlar ve sonraki bağımlılık:
Görev sahipliği bırakıldı mı:
