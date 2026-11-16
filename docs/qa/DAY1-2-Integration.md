# Gün 1–2 entegrasyon doğrulaması

2026-11-16 · Codex · QA-DAY1-2 · dayanak `1b3ee8f` · dal `auto/qa-day1-2-1794829248`.

AGENTS.md, CLAUDE.md, DecisionLog, coordination STATUS/TASKS/HANDOFF ve tüm
claims dosyaları okundu. K2C-001 mesajının okunduğu bu ayrı dosyayla onaylanır;
C2C-001/C2C-002 de okundu. Bitişte mesaj dizini yeniden kontrol edildi; yeni mesaj yoktu.
Kullanıcının izin verilen yollar ve gözetmen dosyalarını değiştirmeme talimatı
nedeniyle görev/teslim kaydı burada tutuldu. Tarihsel DAY2-003 sahipliği, izin
verilen devralma kapsamında değerlendirildi. Başlangıç çalışma ağacı temizdi.

## Değişiklik ve sonuç

- `tests/day12_integration_test.gd` ve `.tscn`: SceneTree'nin gerçek mevcut
  sahnesini değiştirerek menü düğmesi sinyallerinden yeni oyun ve devam akışları.
- Bekleyen Elena ile kayıt, duraklatma menüsünden başlığa dönüş, devam sonrası
  tüm kampanya durumunun korunması ve kapı konuşmasının açılması doğrulandı.
  Bekleyen ziyaretçi kaydı test amacıyla SaveManager üzerinden alındı;
  normal elle kayıt yasağı mevcut kampanya/menü testlerinde korunuyor.
- İki yeniden başlatmada eski ziyaret durumunun temizlenmesi, tek geliş kaydı
  ve ziyaretçinin ayrılması doğrulandı.
- İngilizce ve Türkçe yerellerde yönetim taslağındaki yatak/iş değişikliklerini
  iptal etmek tüm kalıcı durumu ve saati korudu; oyuncu kontrolü geri geldi.
- Gün 1→2 ve Gün 2→3 geçişinde kişi başına bir yiyecek/bir su tüketildi.
  Sabah yinelenen uyku eylemi günü veya tüketimi yeniden ilerletmedi.
  Gün 3 için mevcut içerik sonu bildirimi doğrulandı; sonraki içerik eklenmedi.
- CSV'deki 177 anahtarın benzersizliği, üç sütun yapısı ve İngilizce/Türkçe
  metinlerin doluluğu kontrol edildi. Bu kontrol çeviri kalitesi veya görsel
  taşma değerlendirmesi değildir.
- `tools/Run-Tests.ps1` yeni testi otomatik çalıştırır. Bu kapsamda üretim
  kodunda düzeltme gerektiren bir hata saptanmadı.

## Gerçek doğrulama

Godot 4.7.2 console ile `powershell -NoProfile -File tools/Run-Tests.ps1
-GodotPath C:/Users/eyups/OneDrive/Belgeler/TheQuietHours/tools/godot-4.7.2/Godot_v4.7.2-stable_win64_console.exe`.

Son çalıştırma çıkış kodu **0**: shelter 24, campaign 69, day2 737, menu 29,
day12 integration 556, interaction 13, house layout 90, player movement 6;
**8 paket, 1524 denetim PASS**. `git diff --check` geçti.
Testler geçici proje ve ayrı kullanıcı kayıt dizininde çalıştı.
Günlük/kopya: `C:/Users/eyups/AppData/Local/Temp/tqh-tests-5f88d5c994704086b84b59a9c5de90c3`.

İlk kısıtlı çalıştırma sertifika deposu/editör ayarı erişiminde durdu;
izinli çalıştırma kullanıldı. Yeni test düzeneğinin ilk sürümündeki gereksiz
yeniden ebeveynleme motor hatası kaldırıldı ve tüm paketler yeniden geçti.

Yalnızca headless doğrulama yapıldı. Elle oynama, fare tıklaması, gerçek ekran
görüntüsü ve çözünürlük/taşma kontrolü yapılmadı. Dal değiştirilmedi, commit
oluşturulmadı. Görev tamamlandı; dosya sahipliği bırakıldı.
