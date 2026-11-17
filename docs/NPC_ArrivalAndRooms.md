# NPC gelişleri ve oda ataması — sahip tarafından onaylandı

Karar: K-NPC-ARRIVALS-ROOMS-001
Tarih: 17 Kasım 2026
Durum: Yaratıcı yön ONAYLI; yeni sistem henüz UYGULANMADI.
Kaynak: Sahibin kurallı rastgele geliş + oyuncu oda ataması + NPC tercih/itiraz önerisine verdiği “onaylıyorum, şimdi bütün bunları önce Claude bildir” yanıtı.

## 1. Onaylanan geliş düzeni
- NPC gelişleri bütün oynayışlarda aynı sabit gün/saat çizelgesinden ibaret olmayacak. Kurallı rastgele seçim gerçek oynanış çeşitliliği sağlayacak.
- Her NPC için uygun geliş günleri/zaman pencereleri tanımlanacak. “Gün3–6” açıklayıcı örnekti; belirli bir karaktere kesin aralık atanmış sayılmıyor.
- Yeni kampanya başında ziyaretçi seçimi ve takvim kampanya seed'iyle belirlenecek ve kaydedilecek. Save/load veya kapıya bakma sonucu yeniden seçilmeyecek.
- Her oynayışta bütün18 karakterin gelmesi zorunlu olmayacak. Mevcut yalnız3 işlevsel NPC, bütün roster uygulanmış gibi anlatılmayacak.
- Ana hikâye ve temel bilgi bir tek isteğe bağlı karakterin gelmesine bağlı kalmayacak. Reddedilen/gelmeyen/ölü/kovulmuş/izole karakter için geçerli alternatif yol korunacak.
- Enfeksiyon gelişten önce atanmış olacak. Geliş takvimi veya olay ihtiyacı sağlıklı bir NPC'yi enfekte yapmayacak; önceki enfeksiyon kuralları aynen geçerli.

## 2. Onaylanan oda düzeni
- Son oda/yatak atama yetkisi oyuncuda kalacak.
- NPC istek bildirebilecek veya atamaya itiraz edebilecek; kendi başına oyuncunun düzenini değiştirip başka odayı sahiplenmeyecek.
- Örnek tercih: Noah kızı Lily ile aynı odada kalmak ister. Bu örnek gelecekteki roster içindir; ikisi şu an oynanabilir diye anlatılmayacak.
- Arası kötü iki kişinin aynı odaya yerleştirilmesi anlamlı itiraz/ilişki sahnesi doğurabilecek. Karakterler genel işçi etiketleri olarak ele alınmayacak.
- Kapasite gerçek yataklara bağlı kalacak; mevcut izolasyon rezerv yatağı, dolu yatak, günlük tüketim ve tek-konum kuralları bozulmayacak.

## 3. Henüz kararlaştırılmamış ayrıntılar
Kesin NPC geliş aralıkları, günlük ziyaretçi yoğunluğu, olasılıklar, bütün karakterlerin seçilme koşulları ve gündüz/akşam/gece dağılımı henüz belirlenmedi. Bu onay tek başına gece yarısı ziyaretçisi eklendiği anlamına gelmiyor. Öğretici Elena gelişi ve kritik olaylarla uyum uygulama tasarımında açıkça ele alınmalı; mevcut sabit üç ziyaret rastgele sistem tamamlandı diye sunulmamalı.

Oda tercihlerinin kesin kuralları, itiraz diyalogları ve sayısal güven/ilişki bedelleri henüz tanımlanmadı. Yeni büyüklükte bir sosyal simülasyon, otomatik oda taşıma veya tam18 karakter üretimi bu onayın uygulanmış sonucu değildir.

## 4. Mevcut gerçek durum
Elena Gün1 18:00–21:30, Marcus Gün2 10:00–13:00, Arthur Gün2 15:00–18:00 sabit veriyle geliyor. Kabulde boş yatak başlangıç ataması ve oyuncunun yönetimden değişiklik yapması var. Yeni rastgele takvim ve NPC tercih/itiraz sistemi bu karar yazılırken kodlanmadı.

## 5. Uygulama ve doğrulama sırası
1. Önce bu onayı Claude ile paylaş ve mevcut aktif dosya sahipliğini koru.
2. Geliş pencereleri/uygunluk/kampanya takvimi veri şemasını, mevcut üç ziyaret ve öğretici bağımlılıklarıyla tasarla.
3. Takvim ile enfeksiyon seçimini birbirinden ayır; seed, kayıt uyumu ve eski kayıtların yeniden takvimlenmemesi için açık geçiş kuralı yaz.
4. Sınırlı mevcut roster ile gerçek değişken gelişleri uygula; aynı seed tutarlılığı, farklı seed çeşitliliği, save/load, kapasite, ret ve eksik-NPC yollarını test et. Bu,18NPC tamamlandı demek değildir.
5. Oda tercihlerini veriyle tanımla; oyuncu ataması, NPC itirazı ve mevcut izolasyon/yatak kurallarını birlikte doğrula. Onaysız otomatik oda değiştirme ekleme.

Bu belge kabul edilmiş yönü kaydeder. Ayrıntılı uygulama görevi ayrıca sahiplenilmeli; aynı dosyalara iki asistan paralel yazmamalı.
