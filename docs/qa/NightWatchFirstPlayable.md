Güncel ek: gece araştırmasından sonra katılma uygulandı; docs/qa/LateNightWatch.md son davranışı ve doğrulamayı kaydeder. Aşağıdaki erken sürüm sınırları tarihseldir.

# NIGHT-001 — ilk oynanabilir nöbet

## Amaç ve teslim

Gün 3 akşamı oyuncunun uyanık kalmayı seçebilmesi, gece yarısından sonra gerçek oda/koridor akışını kullanabilmesi ve kalan geceyi uyuyabilmesi. Bu, ilk sabit elektrik olayına dayanan nöbet temelidir; genel prosedürel gece yönetmeni veya tamamlanmış korku olay bankası değildir.

## Dosyalar ve hiyerarşi

- scripts/time/night_session.gd: HouseBlockout → CampaignDirector → NightSession; sahne-yerel, CampaignDirector.setup tarafından oluşturulur. Yeni autoload yok.
- scripts/time/night_timeline.gd ve resources/events/night_watch.json: mevcut veri güdümlü zaman/enerji hesabı.
- scripts/core/game_state.gd: night_session verisi, gece yarısı saat/faz hesabı, aktif gece için ertesi 07:00 sınırı, sabahın erken tüketilmesini engelleme.
- scripts/save/save_manager.gd: v5, gece cursor/gün/veri tutarlılığı; eski v1–v4 alan yokluğu göçü.
- scripts/narrative/campaign_director.gd: watch/wait_watch ve kalan uyku, iki basışla başlama onayı, sabah anlatımı.
- scripts/narrative/power_incident.gd: aktif gece onarım/inceleme üst sınırı.
- scripts/dev/house_blockout.gd: 00:00 sonrası pencere ışığı hesabında modulo saat.
- localization/strings.csv: en/tr seçenekler; POWER_WAKE artık uyanık Daniel'a uyandığını söylemez.
- tests/night_state_test.*, night_watch_test.*, night_watch_preview.* ve tools/Run-Tests.ps1.

## Kurulum ve oynama

Godot 4.7.2 ile projeyi içe aktar; başlangıç sahnesini normal çalıştır. Gün 3 20:00–23:00 aralığında Daniel'ın odasında “Stay awake tonight / Bu gece uyanık kal” seç. İlk basış açıklama ve azami 40 enerji bedelini gösterir; ikinci basış başlatır. Odayı kapatmak veya başka eylem onayı iptal eder. 23:00 olayı mevcut nedenini kullanır, gün/tüketim ilerlemez.

Odadan çıkıp 3D koridorda yürü; 2D odaları/kanıtları incele. Serbest yürüyüş zamanı ilerletmez. Daniel'ın odasına dönüp sonraki 01/03/05/07 sınırına kadar bekle veya kalan saatleri uyu. 07:00'de tek sabah çözümü çalışır; Gün 4 kesit-sonu bildirimi korunur. Nöbet seçilmezse önceki uyku yolu ve Gün 1–2 davranışı değişmez.

## Beklenen durum ve kayıt

01:00/03:00/05:00 hâlâ Gün 3'tür. Gece kaydı v5'te mutlak dakika olarak tutulur; saat/faz ve pencere ışığı modulo 1440 kullanır. Her bekleme sınırında otomatik kayıt alınır. İnceleme/onarım mevcut kayıtlarını korur. Yükleme enerji veya kaynak maliyetini yeniden uygulamaz. Sabah idempotans işareti kayıttadır.

Tam nöbet başlangıç 100 enerjiyi 60'a indirir. 01:00'de kalan geceyi uyumak 100'e, 05:00'de uyumak 86'ya getirir; bunlar açık dengeleme varsayımlarıdır. Uyanık dakikalar tek tek, uyku dakikaları ayrı hesaplanır. Nöbet tek başına suçlu/kanıt/otomatik tanık üretmez.

## Gerçek doğrulama

14 paket toplam 5504 denetim geçti. NightState 25 kontrol: 01:00 saati/fazı, gece kayıt turu, bozuk gece reddi, gece yarısından sonra onarım, şafak sınırı, erken sabah engeli, tek tüketim ve v1–v4 göçü. NightWatch 138 kontrol: gerçek kampanya/RoomView üzerinde yalnız ve üç sakinli altı tam/karma gece, onay iptali, kanıt inceleme, koridora kontrol dönüşü, her sınırda kayıt/yükle, enerji ve değişmeyen enfeksiyonlar.

İzole gerçek Forward+ 1920×1080 çıktıları: night-watch-01-actions.png, night-watch-01-living.png, night-watch-01-corridor.png. Üçü incelendi; saat 01:00/Gün 3/Gece doğru, bekleme ve uyku seçenekleri okunur. Daniel odası eski geçici gerçekçi sanatta; oturma odası onaylanan çizimsel arka plan/eşya katmanında. Hacimsel geçmişin yerleşmesi için 60 kare beklenir.

## Sınırlar ve sık hata kaynakları

Fare/klavye ile baştan sona geceyi elle oynama ve bu yeni seçeneklerin 1440p gerçek görüntüsü henüz yapılmadı. Oda içi gece resmi hâlâ tonlanmış tek kaynak; yanan lamba resmi ayrı güç katmanı değildir. NPC'ler koridorda görünür yürümüyor; gerçek tanıklık/kapı dinleme olayları üretilmedi. Nöbet başlangıcı 20:00–23:00 penceresiyle sınırlı; daha sonra legacy inceleme akışından sonradan nöbete dönme henüz yok.

Aktif geceyi eski 23:59 sınırıyla doğrulamak kaydı yanlış reddeder; v5 doğrulayıcısı birlikte dağıtılmalı. GameState.start_next_day aktif oturumun sabahı sahiplenilmeden çağrılırsa tüketmez; NightSession.finish kullanılmalıdır. Test önizlemesi otomatik kayıt üretir; kişisel kayıtları korumak için izole proje/kullanıcı dizininde çalıştırılır.

Bitti tanımı bu ilk uygulama için: kod/sahneler mevcut, normal kampanya seçenekleri çalışıyor, belirtilen regresyonlar ve gerçek 1080p render geçiyor. Tam NIGHT-001 kabulü için manuel kullanım, 1440p, gece ortası geçiş sınırları ve kalan hata durumları açık kalır. Sonraki bağımlılık: nöbet sınırlarının bu eksik QA'sı, ardından mevcut simülasyona bağlı yeni gece olayları; yeni olaylar ayrı yazılmış içerik olarak ele alınır.
