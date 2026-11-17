# Oda tercihleri ve itiraz — ROOMS-DESIGN-001

Durum: Codex tarafından başlatılmış uygulama tasarımı; kodlanmış özellik değildir.
Yetkili yön: NPC_ArrivalAndRooms.md, K-NPC-ARRIVALS-ROOMS-001. Takvim uygulaması Claude üzerinde; bu belge save/oynanış dosyalarını değiştirmez.

## Oyuncu yetkisi
Son yatak/oda kararı oyuncuda. NPC tercih veya itirazını açıklar; kendi başına başka odaya taşınmaz. Oyuncuya uygulanacak plan ve sonuç gösterilir. Tercih, gizli enfeksiyon testine dönüşmez. Normal oda ataması sağlıklı ve enfekte NPC için aynı kuralları kullanır.

## Mevcut temel
ShelterManager planı tüm olarak doğrular; gerçek yatak kapasitesi6, izolasyon rezervi ve mevcut iş konumu korunur. Başlangıçta boş yatak atanır, oyuncu yönetimden değiştirir. Plan değişimi mevcut15dk kuralındadır; tekrar aynı plan için ek ücret veya sosyal sonuç yok. İzole kişi normal yatak taşıma/iş atamasına katılmaz. Bu temel yeniden yazılmayacak.

## Önerilen veri sözleşmesi
Tercih kaydı: id, npc_ids, kind, target_npc veya room_tags, preconditions, request_key, objection_key, priority, requires_content. İlk değerlendirmede share_with (birlikte kalma) ve avoid_with (ilişki kaynaklı ayrılık) yeterlidir. Tam sosyal simülasyon veya her karede ilişki grafiği eklenmez.

Noah/Lily aynı oda isteği onaylı örnektir; ikisi ve grup gelişi henüz oynanabilir değil. İçerik hazır olmadan tercih veya grup kabulü etkinleştirilmez. Mevcut üç yetişkinin kişisel tercihlerinin kesin metinleri bu taslakta uydurulmuş kanon sayılmıyor; ilgili biyografi/ilişki olayına dayanan veri ayrıca yazılacak. Marcus/Caleb geçmiş çatışması gibi ileriki örnekler ancak ilgili karakterler gerçekten evdeyse çalışır.

## Plan değerlendirmesi
1. Önce mevcut yatak/kapasite/rezerv/erişim doğrulaması; geçersiz plan hiçbir kısmi değişiklik yapmaz.
2. Sadece planın gerçekten etkileyeceği mevcut sakinlerin aktif, yazarlı tercihleri değerlendirilir. Ölü/yok/kovulmuş/izole kişi hayalî oda tartışmasına sokulmaz.
3. İstekler ve itirazlar oyuncuya, kim/ne istiyor ve hangi plan satırı etkileniyor biçiminde gösterilir. Onaysız otomatik düzeltme/oda değişimi yok.
4. Oyuncu planı düzenleyebilir, iptal edebilir veya geçerli planı açıkça uygulayabilir. Fiziksel kapasite hatası itirazı onaylayarak aşılamaz.
5. Sosyal sahne/hatıra yalnız gerçekten uygulanmış değişiklikten doğar. Aynı planın tekrarı, başarısız kayıt ve eski teklif yeniden uygulaması sonuç üretmez. Sayısal güven/ilişki bedelleri henüz belirlenmedi; veriyle ayrıca tanımlanmalı, sessizce eklenmemeli.

## Grup ve kapasite sınırı
Takvim yalnız kapıya geliş zamanını belirler. Oyuncunun kabul/ret kararı ve yatak ihtiyacı takvimden ayrıdır. Grup kabulü gelecekte bütün üyelerin geçerli yatak planı birlikte hazır olmadan kısmen uygulanmamalı. Noah/Lily örneğinde çocuğu tek başına yerleştirme/atma gibi yeni davranışlar bu taslaktan çıkarılamaz. Aynı oda tercihini fiziksel zorunluluğa çevirme kararı bu belgede alınmıyor.

## Kayıt ve bağımlılık
ARRIVALS-001 save geçişi Claude tarafından tek yazarlı tamamlandıktan sonra ROOMS-001 uygulanır. Tercih tanımı içerik verisinde, uygulanmış plan/tepki hatırası kampanya durumunda saklanmalı. Yeni şema sürümü gerektiği önceden varsayılmıyor; entegrasyon tabanına göre gerekçelendirilir. Eski kayıtlara geçmiş itiraz/ceza uydurulmaz. Quote geçici, seçim/yükleme/durum değişikliğinde yeniden doğrulama gerekir.

## Zorunlu testler
- Oyuncu son kararı verir; NPC kendi kendine taşımaz.
- Aynı seed/enfeksiyon ayrımı oda değerlendirmesini değiştirmez.
- Dolu yatak, rezerv izolasyon yatağı ve geçersiz grup planı kısmen uygulanmaz.
- Yalnız gerçekten evde ve etkilenen sakinler konuşur; iş/uyku/izolasyon konumu çelişmez.
- Başarısız kayıt ve tekrarlanan plan süre/bedel/hatıra üretmez; save/load sonucu korur.
- EN/TR, metin taşması, iptal ve klavye kullanımı gerçek motor görüntüsüyle kontrol edilir.

Sonraki teslim: aktif üç karakter için yazarlı tercih verisi ve UI akışını mevcut yönetim ekranıyla ayrıntılandırmak; henüz ROOMS-001 koduna başlanmadı.
