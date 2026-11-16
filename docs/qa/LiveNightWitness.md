# Canlı gece tanıklığı — NIGHT-WITNESS-002

## Hedef ve gerçek kapsam
Onaylı Day4Design içindeki masum banyo ziyareti ve çelişkili ifade bağımlılığını canlı oyuna bağlamak. Yeni sanatsal yön, enfeksiyon kuralı veya şiddet seçeneği yok. Tam Gün4 kampanyası, genel gece yönetmeni, görünür3D NPC yürümesi ve bütün18karakter tamamlanmış değildir.

## Dosyalar ve bağlantı
- scripts/narrative/night_witness.gd: sahne-yerel NightSession.witness, aday rota/uygunluk ve kayıt yayınlama; Gün4 oda eylemleri/ifadeleri.
- scripts/house/night_route_access.gd: HouseBlockout'a bağlı ölçüm; gerçek RoomDoor kilitleri ve fizik uzayında koridor güzergâhı/görüş çizgisi. Yeni autoload yok.
- scripts/time/night_session.gd: yeni nöbette protocol opt-in; bekleme öncesi teklif, gerçek zaman ilerlemesinden sonra güvenli yayın.
- scripts/dev/house_blockout.gd: RoomView açık ve Daniel odası, konuşma/pause kapalı koşulunu ve erişim Callable'ını enjekte eder.
- scripts/narrative/night_observation.gd: eski saf valid sözleşmesi korunur; üretim için valid_completed gözlemcinin gidiş/dönüşünü, uyanık aralığını ve konum ölçümünü ayrıca doğrular.
- scripts/core/game_state.gd ve scripts/save/save_manager.gd: iç içe kayıt sayı dönüşümü, semantik kayıt doğrulaması, tarihsel katılımcıların sonradan ayrılmasına izin. Save v5 değişmez.
- EvidenceManager.collect_into: aday evidence dizisine args içeren iddia, katalog/tekillik doğrulaması; journal_text çeviri formatlama. Eski args'sız kayıt çalışır; string args gibi bozuk veri reddedilir.
- resources/events/night_observation.json: üç üst kat rotası, zaman sınırları, adım ve görüşme süresi. resources/evidence/night_witness.json: yalnız claim anahtarları. localization/strings.csv: EN/TR.
- tests/night_witness_test.gd/.tscn; tools/Run-Tests.ps1 yeni paketi izole koşar.

Hiyerarşi: HouseBlockout→CampaignDirector→NightSession→HouseNightEvents(Node), witness(RefCounted). HouseBlockout→NightRouteAccess(RefCounted). Mevcut RoomView eylem düğmeleri ve günlük kullanılır. Godot4.7.2 ile import ve Start-Game yeterli; üçüncü taraf kaynak yok.

## Olayın koşulları
Yalnız yeni başlayan Gün3 nöbeti night_witness_enabled=true alır. Eski aktif nöbetin yüklenmesi bunu eklemez. Daniel 01:00 boru olayını gerçekten duyduktan sonra kendi oda görünümünde beklerken bütün gidiş/dönüşü bekleme aralığına sığan olay değerlendirilir. Yalnız23→01 bekleyip sonra uyumak bu kaydı üretmez. Daniel koridordayken simülasyon gizli hareket üretmez; görünür teleport yok.

Elena/Marcus/Arthur içinden en az iki resident, sağlıklı hareket edebilen, izole/absent/injured/incapacitated/busy olmayan ve bağlı üst kat yatak odasında bulunan kişi gerekir. Aynı gün devam eden iş veya night_watch atanmışsa katılmaz. Kişisel blocked_rooms ve gerçek oda/banyo kapı kilitleri dikkate alınır. Seçim ID sıralı ve deterministiktir; infected okunmaz.0–1uygun kişi varsa olay yok, eski inceleme akışı geçerli.

NightRouteAccess gerçek sahnedeki kapıları ve fizik engellerini ölçer. Oyuncunun oda arkasında kalan3D gövdesi ve kapı portal collider'ları ışınlardan hariç tutulur; kapının kullanılabilirliği locked üzerinden ayrı doğrulanır. Merkez hatları üst koridorda x7.5 üzerinden ilerler, güneyde z10'dan banyoya bağlanarak merdiven boşluğundan kaçınır. Bunlar onaylı HouseLayout'a özel kontrollü yollardır; genel NavMesh ajanı veya tam beden genişliği hareket simülasyonu değildir. Yeni planla yollar ve engel testi yeniden gözden geçirilmelidir.

Gözlemci gerçek boru olayına yazılmış tepkiyle uyanır, oda→landing gerekiyorsa→corridor→oda döner. Hedef kendi odası→koridor→banyo→oda döner. Zaman damgaları ve nedenleri saklanır. Gözlem hedefin ilk koridor geçişindedir; pano müdahalesi görülmez. İşlem tek bekleme içinde biter, son konumları değişmez; ayrı render edilen yürüme animasyonu varmış gibi sunulmaz.

## Kayıt ve hatalar
flags/night_witness_record: day,start,end,seen_at,subject,observer,reasons,steps,observer_steps,observer_returned_at,snapshot ve observation(awake interval, sightline, measured positions). Konumlar tam sayı milimetredir: Vector3 float32→JSON6haneli ondalık kayması nedeniyle ilk testin bulduğu eşitsizlik giderildi. İç içe tam sayılar yüklemede restore edilir. İlk denemelerde equality testleri başarısız oldu; bu hatalar gizlenmedi.

SaveManager.commit_candidate mevcut durumla karşılaştırır, önce diske yazar, sonra canlı uygular. Başarısız yayın kanıt üretmez; beklemenin önceden geçen zamanı geri alınmaz ve hata bildirimi gösterilir. Görüşmede yazma hatası ise zaman ve iddia dahil hiçbir şeyi değiştirmez. Kaydedilmiş hareket tekrar seçilmez. Geçmiş gözlemci sonradan kovulsa/ölse kayıt geçerli kalır; mevcut oda eylemleri onu konuşturmaz. Player/NPC infection sabit.

## Oyuncunun gördüğü
Gün4 uygun kişinin gerçek odasında 'Ask ... about last night'. Gözlemci koridorda gördüğünü söyler; hedef yatakta kaldığını iddia eder. İkisi dinlenince hedefe çelişki sorulabilir: banyo ihtiyacı ve suçlanma korkusunu anlatır. Her ilk görüşme veri dosyasındaki10dk; tekrar ücretsiz. Kaynak/trust/enfeksiyon değişmez. Yalnız claims kaydedilir; otomatik teşhis, suçlu etiketi veya Daniel'ın görmediği olgu eklenmez. Etiket maliyeti veriden biçimlenir. Konuşma bu ilk uygulamada mevcut oda anlatımıdır, yeni dallı seslendirilmiş sahne değildir.

## Test / bitti / sonraki
NIGHT WITNESS paketi: gerçek sahne+iki uygun kişi, tümü sağlıklı/enfekte eşdeğeri, boru öncesi, legacy, açık koridor, kısa bekleme, yok/yaralı/izole/meşgul, kilit, fiziksel koridor engeli, aynı kayıt, save/load, üretim kanıtı bozulması, sonraki sabah, write failure, ilk10dk/ücretsiz tekrar, iddia formatı, çelişki koşulu, EN/TR ve kovulma sonrası tarih. Tam regresyon eski nöbet/kayıt ve günlük akışını korumalı. GPU oda eylemleri ve iki dil anlatımı incelenmeli. Elle tam oynama veya ses dinleme yapıldığı iddia edilmez.

Sık hata: eski Gün3 kaydında olay çıkmaması beklenir; yeni nöbet başlat. Sadece01:00'e bekleyip uyumak yetmez; bir sonraki bekleme gerekir. En azikiuygun kişi, açık kapılar ve boş rota gerekir. Olay yoksa enfekte ataması değiştirme. Yeni UI anahtarı görünürse CSV import et.

Bitti ölçütü canlı olay+görüşme, tüm regresyon ve render kanıtı, launcher sürümü, Git/devir kaydı. Sonraki bağımlılık tam Gün4 değerlendirme/kapanışı ve ileriki günlerdir; genel gece olay bankası bu teslimde tamamlanmaz.

Sonuç:25paket/6291 gerçekWASAPI PASS. Son tamkoşudan sonra yalnız dakika etiketinin10.0→10 biçimi düzeltildi ve yeni çözünürlük denetimleri eklendi; son ilgili hedefli test83PASS, gerçekGPU85PASS, EN/TR görüntüler incelendi. Bu26ek kontrolü tamkoşu sayısına eklenmiş gibi raporlama. Kanıt: live-night-witness-last-run.json; günlük C:\Users\eyups\AppData\Local\Temp\tqh-tests-69700b48acbb4dd7bc050d6d0c7068b0. İlk başarısız sayısal/JSONgidiş-dönüş koşuları düzeltildi; eski testleri gevşetme yapılmadı.
