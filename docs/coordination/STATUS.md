# Ortak durum — 2026-11-16

Kalıcı proje: TheQuietHours/project. Yerel Git dalı automation/integration; uzak depo yok.
Birleşik sanat ve Gün 3 kilometre taşı: 388dec6.

## Uygulanan ve doğrulanan

- Gün 1 Elena ziyareti, kabul/ret/kaçırma, ilk gece.
- Gün 2 Marcus/Arthur ziyaretleri, yatak/iş yönetimi, kaynak çözümü.
- Gün 3 koşullu elektrik kesintisi, inceleme, kanıt/günlük, onarım/erteleme ve kayıt v4.
- Menü, duraklatma, elle kayıt ve devam.
- Son birleşik regresyon: 11 paket, 2404 denetim; güncel ekler docs/qa/SaveValidation.md ve DoorAudio.md. İlk kapı çalma sesi geçici sentez olarak bağlandı; nihai ses tasarımı tamamlanmadı.
- 13 oda arka planı ve 3 karakter figürü dosya olarak mevcut. Bunlar nihai görsel kabul değildir.

## Sahibin son geri bildirimi ve mevcut iş

Sahip ART-REV-003 çizimsel yönünü ve ilk oda entegrasyonunu onayladı. Oturma odası yeni kaynak ve ayrı TV/radyo katmanı kullanıyor. Gündüz/gece ve her ikisinin elektrik kesintisi görselleri bağlandı; 15 paket/5567 denetim geçti. Güncel örnekler docs/qa/living-lighting-*.png ve LivingRoomLightingVariants.md. Diğer 12 oda eski geçici sanatta; yayın ekran animasyonu ve karakter üslup uyumu açık.

POLISH-SLICE-001 teknik uygulaması tamamlandı: istekli yardımcı, kesin süre/maliyet onayı, opak günlük, olay güdümlü elektrikli ışık, saate bağlı pencere, figür/eşya tonu ve en/tr 1080p/1440p mevcut tesisat eylemi sınaması. Otomatik işçi başlatılmadı; ana Codex uyguladı. Görsel yön hâlâ sahibin incelemesinde; ART-REV-003 çizimsel örneği üretime bağlanmadı. Tam elle oynama açık.

Gece nöbeti ilk oynanabilir: v5 saat/kayıt, Gün 3 20:00–23:00 nöbet seçimi, 01/03/05/07 bekleme, kalan geceyi uyuma, enerji ve tek sabah çözümü bağlandı. 14 paket/5534 denetim geçti. Nöbet UI'si en/tr 1080p/1440p sınandı; 1440p görüntüler incelendi. docs/qa/NightWatchFirstPlayable.md ve NightWatchResolution.md kapsamı kaydeder. Genel gece yönetmeni/yeni olaylar yok. Manuel giriş denemesi Godot pencere erişiminde otomatik izin reddi aldı; elle oynandı denmemeli.

Nöbette ilk masum araştırılabilir olay eklendi: üst kat boru tıkırtısı, duyma/inceleme olguları ve tek sefer ses. İnsan fail seçilmez, yüklemede geçmiş olay üretilmez. 16 paket/5595 denetim geçti; docs/qa/HouseNightPipes.md kapsamı kaydeder. Genel gece olay bankası hâlâ tamamlanmadı.

## Tamamlanmamış alanlar

Gün 4+ kampanya, kapsamlı gece nöbeti, yargılama, kalan karakterler, ses, nihai sanat ve tam ayarlar tamamlanmadı. Fare/klavye ile baştan sona elle oynama doğrulanmadı. Programatik testler ve gerçek motor görüntüleri bu kontrolün yerine geçmez.

## Koordinasyon

Görev sahipliği TASKS.md, devir HANDOFF.md, ayrıntılı kararlar DecisionLog.md içinde tutulur. Mesaj dosyası diğer asistanı kendiliğinden uyandırmaz; okuma onayı olmadan okundu denmez.

## Son teknik ek — geç nöbet
Gün 3 nöbetine 23:59'a kadar katılma, gerçek başlangıca göre enerji ve v5 yükleme uygulandı. Tam regresyon 16 paket/5632 denetim; son metinle gerçek GPU sunumu 100 denetim. docs/qa/LateNightWatch.md. Manuel oynama açık. Elena v2 adaydır; üretim default değişmedi. Gün 4 yalnızca incelenmiş tasarım, kod değil.

## Güvenli kayıt temeli
SAVE-SAFE-001 tamam: doğrulanmış pending dosya, backup rotasyonu, başarısız yayın rollback ve ana dosya yokken backup kurtarma. 17 paket/5669 denetim geçti. Ayrıntı docs/qa/SafeSaveWrite.md. Canlı karar transaction'ı henüz uygulanmadı; Gün 4 önkoşulu olarak açık.

## Aday durum işlemi
SAVE-TXN-001 tamam: beklenen durum kontrolü, adayın kaydı, ardından canlı uygulama; işlem kimliği ve çift uygulama engeli. Sahte gün başlangıcı yok. 17 paket/5690 denetim geçti (save write 58). docs/qa/CandidateTransactions.md. Gün 4'e henüz bağlanmadı; hedef/oda/tanık semantik doğrulaması ayrıca gerekli.

## Gün 4 ilk değerlendirme
Daniel odasında ücretsiz inceleme mevcut; yalnız toplanmış kanıt ve güncel sakin sayısı, kayıt yokluğu açık. Güvenli aday işlemle açılış kaydedilir. 18 paket/5787 denetim, GPU capture 74 geçti. docs/qa/Day4Review.md. Tam suçlama/izolasyon/kovma ve gerçek tanık sistemi henüz yok; kesit sınırı korunur.

## Gün 4 ilk evden çıkarma
Üç uygun yetişkin için bulunduğu odada iki basışlı kovma; 15 dakika/−20 hedef güveni, iş/yatak temizliği, kaynak iadesi yok, enfeksiyon sabit. 19 paket/5834 denetim; GPU capture 39. docs/qa/ResidentExpulsion.md. İzolasyon, tanık ve sosyal ayrılık sahneleri açık. Sanat defaultları korunur; aday onayı sayılmaz.
