# SETTINGS-PLAYTEST-001 — Oynanabilir ayarlar ekranı

## Amaç ve kapsam

GDD'deki ilk temel PC ayarları: parlaklık, fare hassasiyeti ve görüş açısı. Yeni sanat yönü/oyun mekaniği eklenmez. Sahibi henüz HOUSE-ATMOS-004 sanatını kabul etmiş sayılmaz; bu ayarlar varsayılan görünümü değiştirmez. Sürüm0.1.3-dev.20261116.4; ses/görüntü testleri bu sürümle tekrar yapılır.

## Ayarlar ve kalıcılık

| Anahtar | Varsayılan | Aralık | Uygulama |
|---|---:|---:|---|
| brightness | 1.0 / %100 | .7–1.6 | 3D dünya shader RGB ve 2D oda/prop/karakter RGB |
| mouse_sensitivity | .0022 rad/piksel / %100 | .00055–.0066 | Aktif PlayerController.mouse_sensitivity |
| fov | 78° | 60–95° | Aktif Camera3D.fov |

Settings autoload user://settings.cfg içinde [interface] language ve [preferences] üç sayısal değeri tutar. Eski yalnız dil içeren dosya aynı dili ve yeni varsayılanları yükler. Bozuk tip/range güvenli varsayılana döner. Bool, String, null, NaN/Inf, range dışı ve bilinmeyen anahtar set_number API'sinde reddedilir; reddedilmiş istekte dosya değişmez. Başarılı ConfigFile.save sonrası canlı değer/sinyal uygulanır. Bu dosya kampanya kaydı değildir; save şeması5 korunur. Disk save işlemi için crash-safe atomiklik iddia edilmez.

Dil yazmak diğer tercihleri silmez. Varsayılanlara dön, üç sayısal ayarı sıfırlar; dili korur. Ayarlar ekranı slider değişimini anında kaydeder ve uygular. Yazma hatası genel kaydetme mesajı gösterir ve denetimleri gerçek canlı değere geri getirir.

## Düğümler ve sinyaller

scripts/core/settings.gd → preferences_changed sinyali.
MainMenu(Control) → SettingsView(CanvasLayer30) → SettingsPanel(VBox) → üç HBox/Label/HSlider/Value + RestoreDefaults + SettingsBack.
PauseMenu(CanvasLayer20, ALWAYS) → aynı SettingsView; içerik tekrarlanmaz. Modal input shade tam ekran; kapalı menü düğmelerine Tab kaçıramaz. İlk Esc ayarları kapatır, pause kalır; ikinci Esc normal oynamaya döner. Ana menü ayarları kampanyayı pause etmez.
RetroPostProcess(CanvasLayer) → world_presentation.gd → Screen.material'ın sahneye özel ShaderMaterial kopyası → brightness uniform.
PlayerController sinyali dinler, mouse_sensitivity ve Head/Camera3D.fov güncellenir.
RoomView arka plan/prop/karakter RGB'sini Settings.world_tint ile günceller. Alfa olduğu gibi kalır; az parlaklık oda görselini şeffaflaştırıp arkadaki koridoru göstermez. UI kök/yazı renklerine dokunulmaz. DialogueView figure RGB'si de güncellenir; diyalog metni etkilenmez.

## Dosyalar

scripts/core/settings.gd; scripts/ui/{settings_view,world_presentation,main_menu,pause_menu,room_view,dialogue_view}.gd; scripts/player/player_controller.gd; scenes/ui/retro_post_process.tscn; shaders/retro_post.gdshader; localization/strings.csv ve motorun ürettiği en/tr.translation dosyaları; tests/settings_test.gd/.tscn; tools/Run-Tests.ps1. Yeni autoload/eklenti/asset yok. settings_view ve world_presentation yeni sahne-yerel scriptlerdir.

## Kurulum ve deneme

Godot4.7.2 ile import et; ana menüde Ayarlar. Oyun içinde koridorda Esc → Ayarlar. Parlaklık/derece/yüzde değerleri anında değişir. Geri veya Esc kapatır; programı yeniden açıp tercihlerin kaldığını dene. Mevcut user://settings.cfg otomatik genişler; kampanya kaydını silme gereği yok.

Run-Tests.ps1 -GodotPath <console> -AudioDriver WASAPI bütün çekirdek paketleri ve gerçek ses yaşam döngüsü paketini çalıştırır. settings_test persistence/legacy/invalid-data, aktif kamera/shader/2D/diğer UI ayrımı, EN/TR ve720p/1080p/1440p sınırlarını, gerçek Tab tuşu ile modal odak dolaşımını, iki katmanlı Esc/pause ve kontrolün dönüşünü kapsar. Testte girdi hedef SubViewport'a push_input ile verilir; ilk yanlış root input fixture'ı düzeltilmiştir, ürün hatası diye raporlanmaz. Güncel test70denetim; --capture-settings GPU ile iki1080p yakalama ekler. Gerçek settings-en.png/settings-tr.png incelenmelidir.

## Bitti ölçütü ve sonraki bağımlılıklar

Üç ayar ana/pause menüsünden açılmalı; anında ve yeniden açılışta korunmalı; bozuk dosya/API değerleri güvenli davranmalı; UI okunabilir kalmalı; modal girdi oyuna sızmamalı; ilgili regresyon ve gerçek renderlar geçmeli. Bu üç ayarın tamamı teslim kapsamıdır. Tam ayarlar menüsü tamamlandı iddiası yok: ekran modu/çözünürlük/VSync/render ölçeği, ses bus sesleri, tuş atama, yazı boyutu ve kapatılabilir hareket/retro efekt kontrolleri sonraki iştir. Claude003 headbob/lens adayı bu dala bağlı değil; ona ait erişilebilirlik anahtarı varmış gibi sunulmaz.

## QA kapanış düzeltmesi

Yeni tam koşu presentation_test'in motoru sahne kaldırıldığı karede kapatması yüzünden WASAPI'de de aralıklı WAV/playback uyarısı verdi. Donanımlı testte artık weakref kaynaklarının bırakılması beklenip ölçülür; üç ardışık89kontrol uyarısız geçti. Önceki yalnızDummy açıklaması güncellenmiştir. Oyun ses kodunda anlamsız stop/null yaması yok. DefaultDummy araştırması ve negatif komutun önceki policy reddi açık kayıt olarak korunur; yeniden denenmedi.

Sonuç:24paket/6196denetim gerçekWASAPI ilePASS; stderr'deObjectDB/error yok. Güncel settings_test70; gerçekGPU72(iki yakalama dahil)PASS. EN/TR görüntüler incelendi. Kayıt dosyası settings-last-run.json. Start-Game -PrepareOnly0.1.3-dev.20261116.4 motor/konum zincirini doğruladı. İlk tamkoşu audio teardown nedeniyle durdu; ikinci doğru teardown koşusu temiz geçti, ilk hata gizlenmedi.

Sık hata: yeni menüde MENU_SETTINGS gibi anahtar görünürse strings.csv yeniden import edilmelidir. Ürün ayarları user://settings.cfg kullanır; testleri gerçek oyun dizinindeki userdata ile elle çalıştırma, Run-Tests izolasyonunu kullan. Parlaklık UI'nin kendi metnini değiştirmez; yalnız dünya katmanlarını etkiler. Görüş açısı yalnız3D kamera içindir,2D oda çizimini geometrik olarak esnetmez.
