# Oda tercihleri ve itiraz — ROOMS-DESIGN-001

Durum: **Uygulama tasarımı; özellik kodlanmadı.** Görev: AUTO-ROOMS-DESIGN.
Kapsam yalnız bu belge; geliş takvimi, grup kabulü, kod ve kayıt şeması değişmez.
Kaynak taslak genişletildi; yeni kişisel tercih veya sayısal güven bedeli onayı verilmez.

## Yetki ve kaynaklar

- [NPC_ArrivalAndRooms](../NPC_ArrivalAndRooms.md), §2–5 ve [DecisionLog](../DecisionLog.md), K-NPC-ARRIVALS-ROOMS-001: son oda/yatak kararını oyuncu verir; NPC tercih/itiraz bildirir, otomatik taşınmaz.
- Kaynak taslak: `C:/Users/eyups/OneDrive/Belgeler/TheQuietHours/project/docs/design/RoomPreferences.md` (17 Kasım 2026 tarihinde salt okunur incelendi). Buradaki ayrıntılar yaratıcı onay kaynağı değildir.
- [ShelterManager](../../scripts/shelter/shelter_manager.gd): `get_current_plan`, `check_plan`, `apply_plan`, `project_daytime`; bütün plan doğrulaması, yatak takası, değişiklikte mevcut 15 dakika, aynı planda sıfır süre.
- [GameState](../../scripts/core/game_state.gd): `BEDS`, `get_free_beds`, `bed_room`, `get_location`, `get_room_sleepers`; altı normal yatak ve tek gerçek konum.
- [Isolation](../../scripts/shelter/isolation.gd) ve [SaveManager](../../scripts/save/save_manager.gd): tek izolasyon sakini, normal yatak rezervi, aday durumun kayıttan sonra uygulanması (`commit_candidate`).
- [ShelterView](../../scripts/ui/shelter_view.gd): mevcut plan düzenleme yüzeyi. Mevcut `confirm()` doğrudan `apply_plan()` çağırır; aşağıdaki inceleme/kayıt akışı henüz burada yoktur.

Koordinasyon görevleri ve devir kayıtları `docs/coordination/` altında okundu. K2C-001 ve 20261116 tarihli Claude ACK/ölçek/galeri/bodycam mesajları incelendi; geliş/oda onayı mesajı `20261117-codex-to-claude-approved-arrivals-and-rooms.md` ile tutarlılık kontrol edildi. Bunlar tarihsel kayıtlardır. Yalnız bu dosyaya yazma yetkisi nedeniyle ayrı ACK, görev veya devir dosyası oluşturulmadı. Ana Claude ARRIVALS çalışmasına yazılmadı.

## Değişmezler ve kapsam sınırı

1. Tercih sosyal bilgidir; geçerli planın uygulanmasını veto etmez. Fiziksel kapasite veya izolasyon hatası ise oyuncu onayıyla aşılamaz.
2. Kapasite `BEDS` listesinden gelir: `guest_a`, `guest_b`, `multipurpose` odalarında ikişer yatak. Yeni yatak veya izolasyon odası üzerinden ek normal kapasite yaratılmaz.
3. İzole sakinin normal yatağı dolu/rezerv kalır; başka kişiye verilemez. Normal yönetim planı rezervi değiştiremez, kişiyi salıveremez veya ona iş atayamaz. İzolasyonda en fazla bir kişi bulunur; mevcut ayrı izolasyon eylemleri korunur.
4. Tercih uyumu yatakların ait olduğu **uyuma odasıyla** ölçülür. Anlık konum `get_location()` ile belirlenir: işteki kişi aynı anda yatağında gösterilmez. Yatak planı işi iptal etmez veya kişiyi işten ışınlamaz; iş değişiklikleri mevcut ayrı kurallarına tabidir.
5. Enfeksiyon, seed veya gizli teşhis bilgisi tercih/itiraz seçimine girdi olmaz. Atama enfeksiyonu, günlük tüketimi veya sakin statüsünü değiştirmez.
6. Ölü, gelmemiş, ayrılmış, kovulmuş veya izole kişi normal oda tartışmasına katılmaz. Bir isteğin karşı tarafı da uygun sakin olmalıdır. Uzaktaki kişi otomatik tanık sayılmaz.
7. Noah–Lily aynı oda isteği onaylı gelecek örnektir; birlikte kalmayı bu belge fiziksel zorunluluğa dönüştürmez. Lily sağlıklıdır; öldürme, ekranda şiddet veya tek başına dışarı çıkarma davranışı türetilemez. Grup kabulü ayrı tasarım/uygulama bağımlılığıdır.

## Asgari veri sözleşmesi (önerilen, henüz uygulanmadı)

Mevcut içerik yükleme düzeni kullanılmalı; yeni autoload veya sürekli ilişki simülasyonu gerekmez. İlk dilim yalnız `share_with` ve `avoid_with` türlerini destekler. Oda etiketleri, öncelik puanları ve genel kural dili bu ihtiyaç için eklenmez.

| Alan | Anlam / doğrulama |
|---|---|
| `id` | İçerikte benzersiz ve kalıcı tercih kimliği. |
| `speaker_id`, `target_id` | Konuşan ve birlikte/ayrı kalma isteğinin hedefi; roster kimlikleri geçerli ve farklı olmalı. |
| `kind` | `share_with` veya `avoid_with`; bilinmeyen tür etkinleştirilmez. |
| `requires_content` | Gerekli karakter/içerik hazır mı? Hazır olmayan gelecek örnekler etkinleştirilmez. |
| `condition_id`, `source_ref` | Varsa gerçekten kaydedilmiş ilişki olayı koşulu ve yazarlı dayanak. Gizli enfeksiyon koşulu yasak. |
| `request_key`, `objection_key` | İngilizce anahtar; EN/TR metin ve aynı yer tutucular zorunlu. Eksik içerik geliştirme doğrulamasında hata verir; oyuncuya ham anahtar basılmaz. |

`share_with`: önerilen iki yatağın `bed_room` sonucu aynıysa karşılanır. `avoid_with`: farklıysa karşılanır. Aynı odada yatak numarası değişimi tercih sonucunu değiştirmez. İstekler karşılıklı olarak kendiliğinden türetilmez: A'nın isteği B'nin onayı sayılmaz.

Noah–Lily örneği etkin içerik değildir. Elena/Marcus/Arthur için yeni kişisel tercihler atanmaz; çatışma örnekleri ancak ilgili yazarlı olay ve karakterler hazırsa veri olur. Uygun kayıt yoksa boş tercih listesiyle mevcut yönetim davranışı sürer. Güven/ilişki katsayısı, ek süre veya kaynak cezası alanı tanımlanmaz; sayısal bedeller kararlaştırılmamıştır.

## Plan değerlendirmesi ve oyuncu akışı

1. Yönetimi açarken mevcut planın kopyasını al; düzenleme canlı durumu değiştirmez. Önce mevcut yatak/iş doğrulamasını ve rezerv/tek-konum değişmezlerini kontrol et. Geçersiz plan için neden göster; inceleme/uygulamaya geçme.
2. Eski ve önerilen uyuma odalarını karşılaştır. Yalnız konuşan veya hedefin oda eşleşmesi değişiyorsa ilgili etkin tercih değerlendirilir. Aynı odadaki başka yatağa geçiş, yalnız iş değişimi veya değişmeyen eski itiraz yeni sosyal olay üretmez.
3. Sonuçlar saf veri olmalı: tercih kimliği, konuşan/hedef, eski/yeni oda, karşılanıp karşılanmadığı ve metin anahtarı/argümanları. Sıralama `speaker_id`, sonra `id` ile kararlı olsun; rastgelelik veya gizli puanlama gerekmez. Çelişen isteklerin hepsi gösterilir; sistem kazanan seçip yatakları değiştirmez.
4. İnceleme panelinde eski→yeni yataklar, ilgili istek/itirazlar ve mevcut plan süresi gösterilir. Oyuncu düzenleyebilir, iptal edebilir veya itirazı görerek geçerli planı açıkça uygulayabilir. İnceleme ücretsizdir. İptal/geri/Escape canlı planı değiştirmez; güvenli varsayılan iptal/geri olur.
5. İstek gösterimi yönetim özetidir; konuşanın o anda panelde/odada bulunduğu ya da diğer sakinlerin duyduğu anlamına gelmez. Yüz yüze diyalog veya tanık hatırası ayrıca gerçek erişim/konum doğrulaması olmadan üretilmez.
6. Uygulama öncesi plan ve beklenen kampanya durumu yeniden doğrulanır. Kabul/kovma/izolasyon, iş veya zaman değişimi, yükleme, panel kapanışı ya da plan düzenlemesi eski incelemeyi geçersiz kılar. Sessizce yeni sonuç uygulamak yerine yeni inceleme gösterilir.
7. Aynı plan yeniden gönderilirse mevcut sıfır süre davranışı korunur; yeni itiraz, hatıra veya kayıt işlemi üretilmez. Geçerli değişiklikte mevcut 15 dakika bir kez alınır; itiraz başına ek süre yoktur.

## Kayıt, olay sınırı ve entegrasyon

Hedef akış: beklenen durum → saf aday plan/zaman sonucu → semantik doğrulama → `commit_candidate` → başarı sonrası UI bildirimi. Mevcut canlı `apply_plan()` çağrısının önüne yalnız bir diyalog eklemek bu güvenceyi sağlamaz; gelecek uygulama aynı yatak/iş kurallarını aday üzerinde çalıştırmalıdır.

- Bütün yatak takası, süre ilerlemesi ve bu arada tamamlanan işler aynı adayda hesaplanır. Mevcut Gün 3 kesinti sınırında planın kısmen uygulanmaması korunur; kesintiyle kesilen plan için oda tepkisi yazılmaz.
- Kayıt hatasında canlı yataklar, işler, süre ve tepki geçmişi değişmez. Eski incelemeye çift basış/işlem tekrarı ikinci sonuç üretmez. Başarıdan sonra yeniden bildirim kaydı tekrar uygulamaz.
- Yalnız gerçekten uygulanan ve tercih sonucunu etkileyen değişikliğin kaydı tutulabilir. Gerekirse işlem kimliği + tercih kimliği + eski/yeni uyuma odası ve gün/zaman yeterlidir; duyulmamış sözler başka kişilere hatıra olarak yazılmaz. A→B→A gerçek yeni değişikliktir; bu da sayısal ceza yetkisi vermez.
- Eski kayıtlar geçmiş itiraz/sosyal ceza eklenmeden açılır. Kaydedilmiş yatak ve izolasyon rezervi korunur. Tercihler içerik verisinden okunur; geçmiş tepkiler içerik değişince yeniden oynatılmaz. Şema sürümü ve kalıcı alan yeri, entegrasyon tabanının doğrulayıcısına göre belirlenir.
- ARRIVALS entegrasyonunun teslim edilen arayüzü/kayıt geçişi incelenir; onun dosyalarına veya dalına burada müdahale edilmez. Takvim yalnız ziyareti belirler; kabul/ret ve geçerli yatak planı ayrı kalır. Gelecek grup kabulünde tüm üyelerin kapasitesi birlikte doğrulanmadan kısmi kabul yapılmaz.

## Arayüz metin sözleşmesi

Bunlar yeni kişisel diyalog onayı değil, önerilen genel UI metinleridir. Gerçek NPC sözleri yazarlı içerik olarak ayrıca hazırlanır.

| Anahtar | English | Türkçe |
|---|---|---|
| `ROOM_PREF_REVIEW` | Review room assignments | Oda atamalarını gözden geçir |
| `ROOM_PREF_SHARE_REQUEST` | {name} asks to share a room with {other}. | {name}, {other} ile aynı odada kalmak istiyor. |
| `ROOM_PREF_AVOID_REQUEST` | {name} asks for a different room from {other}. | {name}, {other} ile farklı odalarda kalmak istiyor. |
| `ROOM_PREF_UNMET` | This plan does not meet {name}'s request. | Bu plan {name} adlı kişinin isteğini karşılamıyor. |
| `ROOM_PREF_APPLY` | Apply this plan | Bu planı uygula |
| `ROOM_PREF_EDIT` | Edit plan | Planı düzenle |
| `ROOM_PREF_STALE` | The household has changed. Review the plan again. | Evdeki durum değişti. Planı yeniden gözden geçir. |

Mevcut iptal, kayıt hatası ve kapasite anahtarları yeniden kullanılır. Gerçek oyuncu ekranında teknik tercih/işlem kimlikleri veya sayısal güven puanı gösterilmez.

## Uygulama kabul matrisi

Aşağıdakiler **gelecek uygulamada doğrulanacak senaryolardır**; bu belge bunların geçtiğini iddia etmez. Sosyal veri gerektiren testler kanonik kişilik eklemek yerine sentetik test verisi kullanır.

| Senaryo | Beklenen sonuç |
|---|---|
| Karşılanmayan tercih; uygula / düzenle / iptal | Son karar oyuncuda; yalnız açık uygulama planı değiştirir, NPC otomatik taşınmaz. |
| Birbiriyle çelişen iki istek; aynı odada yatak takası | Tüm ilgili itirazlar kararlı sırada; otomatik çözüm yok; yalnız numara takası sosyal sonuç üretmez. |
| Bilinmeyen/dolu yatak, eksik sakin satırı, kapasite aşımı | Plan reddedilir; kısmi yatak/iş/süre değişikliği olmaz. Tam ve geçerli yatak takası çalışır. |
| İzole sakinin rezervini alma/taşıma, ona iş verme, ikinci izolasyon sakini | Reddedilir; rezerv kapasiteden düşmeye devam eder; salıverme ayrı eylemdir. |
| İşteki kişi için yatak değişimi | Uyuma odası güncellenir, aktif iş konumu tek kalır; tüketim ve iş ödülü çoğalmaz. |
| Ölü/yok/kovulmuş/izole konuşan veya hedef; içerik/koşul eksik | Normal oda itirazı ve tanık hatırası üretilmez; boş liste mevcut yönetimi bozmaz. |
| Aynı açık durum, farklı enfeksiyon/seed | Aynı tercih değerlendirmesi/metin; enfeksiyon değişmez ve açığa çıkmaz. |
| İnceleme sonrası sakin/iş/zaman/izolasyon değişimi veya yükleme | Eski onay reddedilir; güncel durumla yeniden inceleme gerekir. |
| Aynı plan tekrarı, çift tıklama, eski işlem tekrarı | Ek süre/tepki yok; gerçek yeni değişiklik süresi yalnız bir kez. |
| Kayıt hata enjeksiyonu ve ardından yeniden deneme | Başarısızlıkta canlı durum/geçmiş aynı; başarılı deneme tek sonuç. |
| 15 dakika içinde iş bitişi / Gün 3 kesinti sınırı | İş bir kez çözülür; kesintiyle iptal olan atama sosyal olay üretmez. |
| Save/load ve eski kayıt | Yatak/rezerv/uygulanmış sonuç korunur; geçmiş tepki veya ceza uydurulmaz. |
| EN/TR uzun adlar ve çoklu itiraz; 720p/1080p/1440p | Kaydırılabilir, taşmayan metin; Tab ile tüm eylemler, Escape ile iptal; gerçek motor görüntüsüyle kontrol. |
| Gelecek Noah–Lily/grup kabulü | Yalnız hazır içerikle ayrı entegrasyon testi; kapasite yetmezse kısmi kabul/çocuğu yalnız bırakma yok. |

Mevcut regresyon dayanakları: `tests/shelter_test.gd`, `tests/isolation_test.gd`, `tests/save_write_test.gd`, `tests/day2_test.gd`; yeni tercih akışı bu testler var diye doğrulanmış sayılmaz.

## Teknik karar ve teslim sınırı

| Alan | Karar |
|---|---|
| Kimlik / somut sorun | ROOMS-TECH-001: tercih incelemesinin mevcut yatak/iş kurallarından sapmasını önlemek. |
| A / B | A: saf plan değerlendirmesi ve mevcut aday kayıt yolu; B: ayrı sosyal oda yöneticisi ve ikinci yerleşim kaynağı. |
| Vizyon / oyuncu etkisi | A oyuncu yetkisini ve tek-konumu korur; çelişen istekleri görünür kılar. |
| Maliyet / risk | A daha az kalıcı veri ve bakım gerektirir; mevcut canlı plan akışını adaylaştırma ve olay sınırı regresyonu yine zorunludur. |
| Kanıt / seçim | Yukarıdaki gerçek API kaynakları; A teknik uygulama önerisi olarak seçildi, kodlanmadı. |
| Onay sınırı | Yaratıcı yetki K-NPC-ARRIVALS-ROOMS-001 ile sınırlı; kişisel tercih metinleri ve sayısal bedeller ayrıca kararlaştırılmadan etkinleştirilemez. |

Sonraki geliştirici işi: teslim edilmiş ARRIVALS tabanını inceleyip ayrı görevde saf değerlendirici, mevcut yönetim incelemesi ve güvenli aday uygulamasını bağlamak; yazarlı tercih içeriği hazır değilse boş listeyi korumak. Bu teslimde oyun kodu, sahne, yerelleştirme kaynağı veya yeni oynanabilir özellik üretilmedi.

### Bu belge tesliminin doğrulaması — 17 Kasım 2026

Yedi göreli kaynak bağlantısı dosya varlığıyla doğrulandı; `git diff --check` hata vermedi. Çalışma ağacındaki tek ek `docs/design/RoomPreferences.md` dosyasıdır. Sağlanan Godot 4.7.2 yolu ile `tools/Run-Tests.ps1` çalıştırıldı; süreç çıkışı 1 oldu. İçe aktarma sırasında `Failed to read the root certificate store` ve `AppData/Roaming/Godot/editor_settings-4.7.tres` yazma hataları nedeniyle koşucu durdu; test paketleri çalışmadı, PASS sonucu yoktur. Bu ortam hatasını gidermek için izin dışı dosya veya oyun kodu değiştirilmedi. Yukarıdaki kabul matrisi uygulama sonrası doğrulama yükümlülüğüdür.
