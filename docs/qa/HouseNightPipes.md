# İlk araştırılabilir masum gece olayı

## Amaç

Nöbetin elektrik olayından sonraki boşluğuna, gerçek insan dışı nedeni olan tek bir işitsel olay eklemek. Bu olay enfeksiyon testi veya gizli fail üretmez. Şüpheli ses ile araştırılmış açıklama ayrı olgulardır.

## Dosyalar ve hiyerarşi

HouseBlockout → CampaignDirector → NightSession → HouseNightEvents → PipeRattle:AudioStreamPlayer3D.

Mantık scripts/narrative/house_night_events.gd, tanım resources/events/house_night.json. Sabit kaynak üst banyonun boru desteği; sabit neden basınç değişiminde gevşek desteğin titremesi. Konum HouseLayout oda merkezinden türetilir. Bu görünür boru animasyonu veya fiziksel akış simülasyonu değildir. Özgün sentezlenmiş metalik ses geçici foley'dir; dinleme örneği pipe-rattle-placeholder.wav içinde.

resources/evidence/night_house.json ayrı kanıt kataloğudur; EvidenceManager mevcut güç kataloğuyla birlikte doğrular. CampaignDirector banyoda inceleme eylemi sunar; RoomView yeni gözlemi mevcut eylem anlatımına ekler. Oyun metinleri strings.csv içinde en/tr'dir.

## Koşullar ve davranış

Gün 3 aktif nöbetinde saat ilk kez 01:00 sınırını geçerken Daniel uyanıksa olay bir kez çalışır. Kişi koşulu yoktur; boş/sağlıklı/enfekteli evde aynı insan dışı kaynak geçerlidir. Ses yaklaşık üst kat yönünü belirtir; oyuncuya kesin oda/fail/enfeksiyon bilgisi vermez. Duvarlara yayılan tıkırtı günlüğe gözlem olarak eklenir; duyulamasa da yazıyla erişilebilir.

Üst banyonun kapısından girip boruları incelemek 10 dakika harcar; nedenin yeniden oluşturulabildiği ve destekte taze alet izi olmadığı ayrı olgu olur. İlk inceleme aynı sesi yeniden çalar. Yeniden okuma ücretsizdir. Süre sabah sınırını aşacaksa eylem başlamadan reddedilir. İnceleme ertesi sabaha bırakılabilir.

Olay bayrakları mevcut v5 flags içinde bool/tam sayı olarak saklanır; yeni sürüm gerekmiyor. Kayıt yüklenirken son saat eşlenir: geçmişteki 01:00'e dönük olay uydurulmaz, ses tekrar çalmaz, bekleyen UI gözlemi temizlenir. Uykuya geçerek 01:00'i atlayan Daniel'a kişisel duyma olgusu verilmez. Aynı olay birden fazla bildirimle yinelenmez.

## Gerçek doğrulama

16 paket toplam 5595 denetim geçti. Yeni 16 kontrol: boş ev, değişmeyen sakin/enfeksiyon/kaynak, gözlem ve açıklama ayrımı, tek sefer bildirim, kayıt turu, tekrar çalmama, inceleme maliyeti/idempotans, gizli neden kimliğinin günlüğe sızmaması, uyku/missed-legacy durumları ve geç inceleme atomikliği. Ses dışa aktarma çağrısında 17 kontrol geçti.

İzole gerçek kampanya sahnesinde 1080p night-pipes-heard/source/journal PNG'leri üretildi. Duyma ve günlük görüntüleri incelendi: kaynak açıklaması incelemeden sonra ayrı satırda, gizli neden kimliği gösterilmiyor. Odalar bu sahnelerde eski geçici sanattadır; yeni sanat teslimi değildir.

## Kurulum, sınırlar ve sonraki adım

Godot 4.7.2 ile içe aktar, Gün 3 nöbetinde 01:00'e bekle; üst banyo incelemesini ve günlüğü kullan. tests/house_night_events_preview.tscn görüntüyü izole proje kopyasında üretir. Eksik katalog/tanım dosyaları dağıtıma dahil edilmeli; JSON dışa aktarım filtresi ileride Windows paketinde doğrulanmalıdır.

Hoparlör/kulaklık dinleme, gerçek odalar arasında akustik sönümleme ve fiziksel giriş QA'sı yapılmadı. İlk ses bankası, genel olay yönetmeni veya bütün gecelerin içerik tamamlanması iddia edilmez. Sonraki bağımlılık: olay çeşitliliği öncesi dikey kesitin içerik/atmosfer tutarlılığı ve karakterlerin onaylanan çizimsel dile uyarlanması.
