# Gün 3 — Power Failure

Uygulama şartnamesi, 2026-11-16. DAY3-001. Kapsam: üç günlük dikey kesit.
Day2Design ve kanonik enfeksiyon kuralları korunur. Yeni ziyaretçiler bu kesitte yok;
yalnızca Elena, Marcus ve Arthur kullanılır. Noah/Lily sonraki içerik genişletmesidir.

## Akış ve zaman

Gün 3 gündüz: mevcut işler, kaynak ve oda yönetimi devam eder. Akşam hazırlığında
gece aydınlatması ve radyoyu kontrol etme önerilir; zorunlu alışveriş/üretim yok.
Saat 23:00'te ilk kesinti oluşur. Oyuncu 20:00 sonrası uyumayı seçerse uyku bu
olayda kesilir: Gün 4'e geçilmez, kaynak tüketilmez, saat 23:00 olur ve uyanma
metni gösterilir. Uyanık geçirilen eylem 23:00'ü aşacaksa tam bu noktada durur.
Olaydan önce saat atlayarak kesintiyi veya tepkisini kaçırmak mümkün değildir.

Bu tek yazılmış olay aktif gece sisteminin ilk adımıdır; dört bloklu genel nöbet
yönetmeni henüz tamamlanmış sayılmaz. Sıradan dolaşım saati ilerletmez.
İnceleme maliyetleri: pano 10 dakika, erişim izi 5, dışarı bakış 5.
Marcus yardım edebiliyorsa onarım 25, Daniel tek başına 35 dakika.
Her benzersiz inceleme yalnızca ilk sefer süre harcar; tekrar okumak ücretsiz.
Eylem 23:59'u aşacaksa başlamadan reddedilir ve ertesi sabah devam edilebileceği
söylenir. Geceyi bitirmek her zaman mümkündür; çözülmeyen kesinti ertesi güne taşınır.
Ertelenmiş onarım/inçeveleme mevcut süre kurallarıyla Gün 4 sabahında mümkündür.
Gün 4'ün başka hikâye içeriği bu kesitte yoktur, arayüz bunu açık söyler.

## Gerçek neden ve uygunluk

Üç veri güdümlü neden: loose_connection, grid_outage, sabotage.
İlk neden evin gevşek pano bağlantısıdır, fail yok. İkincisi mahalle şebekesidir,
fail yok. Sabotaj ancak olay anında uygun bir enfekte sakin varsa adaydır.
Uygunluk: resident, enfekte, izolasyonda değil, yaralı/etkisiz değil; tesisat odasına
geçerli erişimi var, uyumsuz başka işi yok. Kilitli erişim engeli varsa aday olamaz.
O geceki sabotaj amacı radyodan alınan hafıza kaybı uyarısından sonra evin iletişimini
kesmektir; bu amaç gizli kayıt olarak kalır, oyuncuya açıklanmaz.
Bu yayın hiç dinlenmediyse sabotaj adayı seçilmez; ilk iki masum neden kalır.

Seçim kampanya seed'i + sabit olay kimliğiyle yapılır; global rastgele üreteci tüketmez.
Uygun sakinler kimliğe göre sıralanır; sözlük sırası sonucu değiştirmez.
Neden, gerçek fail (varsa), olay zamanı, katılımcı uygunluk anlık görüntüsü ve somut
hareket/erişim kaydı tek kez saklanır. Yükleme veya tekrar kurulum yeniden seçim yapmaz.
NPC enfeksiyonu değişmez. Sonradan ölmüş/kovulmuş kişinin geçmişteki kaydı silinmez,
ama yeni konuşma/iş katılımı gerçekleşmez. Faili oyuncuya gizli UI verisiyle sızdırma.

## Kanıtlar ve adil çıkarım

| Neden | Pano | Erişim izi | Dışarı bakış |
|---|---|---|---|
| loose_connection | Eskimiş bağlantıda ısı izi, gevşek uç | Yeni zorlama yok | Komşu binanın ışığı var |
| grid_outage | Ev sigortası atmamış | Yeni zorlama yok | Sokak ve komşu ışıkları sönmüş |
| sabotage | Bağlantı bilerek çıkarılmış; taze alet izi | Olay kaydındaki geçerli hareket/erişim izi | Komşu ışığı var |

Bir teknik bulgu kişiyi veya enfeksiyonu tek başına kanıtlamaz. Alet izi teknisyeni
otomatik suçlu yapmaz. Erişim izi yalnızca olayın kaydettiği somut veriyi gösterir;
kimsenin görmediği bir hareket tanık ifadesi olarak uydurulmaz. Güvenlik nöbetçisi
gerçek uygun tanıksa rapor verebilir; yoksa izi eksik tut. Marcus bir açıklama yoludur,
zorunluluk değildir: Daniel'ın yazılı sigorta kartı aynı çekirdek ayrımı yapabilmesini sağlar.
Şüphe, iddia ve doğrulanmış olgu günlüğün ayrı türleridir. Otomatik enfekte etiketi yok.
Bu gün kesin infaz/teşhis sistemi açılmaz; toplumsal yargı Gün 4 ve sonrasındadır.

## Onarım, ışık ve devam

Tesisat odasındaki eylemlerle incele, yazılı kartı oku, onar veya ertele.
Onarım bedeli loose_connection ve sabotage için bir repair; grid_outage için
sigorta onarımı sunulmaz. Şebeke için jeneratörle bir fuel harcanarak yerel güç
sağlanabilir. Yakıt veya malzeme yoksa ertele; ücretsiz kaynak uydurma.
Oyuncu kaynak harcayacak eylemi onaylar; reddetmek zaman veya malzeme düşürmez.
Aynı onarım ikinci kez bedel/sonuç üretmez. Malzeme tükenirse karakter ölümü ya da
kampanya kilidi olmaz. Kritik bilgi sigorta kartı ve gözlemle ücretsiz erişilebilir kalır.
Güç düzelince ışık gerçekten geri gelir. Kesintide ev lambaları kapanır; dışarıdaki
gün ışığı ve bağımsız zayıf acil aydınlatma navigasyonu korur. Pencere ışığı elektrik
kesilince rastgele kapanmaz. Radyo pilli olduğundan uyarılar dinlenebilir; TV kapalıdır.
2D arka planlar şimdilik gündüz/elektrik durumuna göre ölçülü bir katmanla karartılır;
yalnızca görüntüyü karartarak televizyonun gerçek animasyonunun varlığı iddia edilmez.

## Veri ve sahne sınırları

Olay tanımı resources/events/day3_power.json altında; mantık ayrı sahne-yerel
scripts/narrative/power_incident.gd içinde. GameState yalnızca kalıcı veriyi tutar.
Eşya kanıtı resources/evidence/ altında; toplama ve sınıflandırma ayrı
scripts/evidence/evidence_manager.gd. Journal Tab ile açılan okunabilir bir panel;
oyuncu kontrolden çıkar, kapanınca uygun kontrol geri gelir. Pause/room/dialogue
ile aynı anda çakışan mod açılmaz. Kritik yazılar İngilizce/Türkçe anahtarlıdır.
Mevcut kayıtları koruyan v4 göçü: eski kayıt olaydan önceyse pending; olaydan
sonraki eski içeriksiz Gün 4 kaydına geriye dönük sabotaj eklenmez.

## Zorunlu test matrisi

1. Enfekte sakin yokken sabotage ve enfekte fail asla seçilmez.
2. Aynı seed, sırası değişmiş NPC sözlükleri ve kayıt/yükle aynı nedeni verir.
3. Sağlıklı/ölü/kovulmuş/izole/yaralı/meşgul/erişimsiz sakin fail veya yardımcı olamaz.
4. Hiç NPC yokken olay, kanıt inceleme ve Daniel onarımı çalışır.
5. Sleep ve uzun eylem 23:00'te durur, gün ve tüketim değişmez; sonraki gerçek
   uyku yalnızca bir günlük tüketim yapar. Yükleme olayı tekrar tetiklemez.
6. Her neden yalnızca kendi fiziksel kanıtını üretir. Grid outage alet izi üretmez.
7. Kaynak yok, onay iptal, eylem tekrarı ve süre yetersizliği kısmi değişiklik yaratmaz.
8. Manuel kayıt ve v1–v3 göçü enfeksiyonu, kaynakları ve katılımcı anısını korur.
9. Günlükte gizli cause/actor/infected bilgisi UI'ye taşınmaz; gerçek kanıtlar kaydolur.
10. Işık/TV gerçekten güç durumuna uyar; kesintide oyuncu evi görebilir ve yürür.
11. Olayı tamamen atlamak/ertelemek geçerli; Gün 4 sınırına yumuşak geçiş vardır.
12. Gün 1–2, menü, yatak/iş, kayıt ve entegrasyon testleri geçmeye devam eder.

Bitti: tüm durumlar otomatik testli, gerçek ekranda olay/ışık/günlük kontrol edilmiş,
kalıcı dalda doğrulanmış commit. Belgenin kendisi uygulanmış özellik değildir.
