# IMMERSION-I01/I02 — görünür gün/gece aydınlatması

Amaç: sahibin “ışık değişmedi” geri bildiriminin doğrudan karşılığı. Taban18df7f4/0.1.10; kaynak kodu ve sahnedeki ışık davranışı değiştirildi. Bu genel sanat yönü tamamlandı iddiası değildir.

## Dosyalar ve bağlantı

- scripts/dev/house_blockout.gd: gündüz/akşam/gece eğrisi, pencere dolgu ışığı, yerel lamba ve emisyon denetimi, kesinti destek ışığı.
- scripts/house/corridor_dressing.gd: üst katta iki küçük sehpa/abajur; local_lamp_lights ve local_lamp_fittings grupları. Mevcut alt kat abajuru aynı grupta.
- tests/room_lighting_test.gd:07:00, gündüz/gece ve güç var/yok; gerçek lamba görünürlüğü/emisyonu; mevcut2D varyant regresyonu.
- tests/power_incident_test.gd: sabah onarımında lambaların kapalı kalması, gece yerel lambaların dönmesi; kesinti ve oyun kontrolleri korunur.

Hierarchy: HouseBlockout → House → CorridorDressing → üç TableLampLight/abajur ağı; HouseBlockout → Player → EmergencyNavigation; HouseBuilder'ın tavan lambaları korunur fakat bu otomatik ışık düzeninde açık tutulmaz. HouseBuilder/HouseLayout/merdiven dosyalarına yazılmadı; Claude'un I03 işi korunur.

HouseBlockout kendi oturumundaki window_lights/moon_lights/electric_lights/electric_fittings gruplarını toplar. EventBus.time_changed/day_started ve PowerIncident.power_changed aynı güncel güç/saat durumunu uygular. Yerel gruplar aydınlık armatürü gerçek lambayla eşler. Başlangıç enerjileri bir kez önbelleğe alınır; sinyal tekrarında kararma birikmez. Save alanı, takvim, kaynak ekonomisi veya enfeksiyon değişmez. Yeni indirme/varlık bağımlılığı yok; mevcut PropMeshes ve HouseMaterials kullanılır.

## Görüntü ve davranış

Gündüz ışığın yönü pencerelerden; tavan ve abajur emisyonları kapalı.07:00 ışığı sıfıra yakın değil, sabah olarak okunur. Pencere yakınındaki geniş dolgu dış aydınlığı temsil eder. Akşam lambalar yumuşakça devreye girer; gece sıcak yerel havuzlar, zayıf serin dış ışık ve düşük dolgu kalır. Tamamen siyaha gömülme hedeflenmez. Elektrik kesilince yerel ışık ve emisyon söner; dış ışık sürer. Oyuncuya bağlı eski sürekli ışık artık yalnız karanlık kesintide kısa menzilli destek verir. Sis0.008→0.004; tavanı/duvarı tek renkle kaplayan boğukluk azaltıldı.

Üst koridor ve alt hol için aynı kamera, aynı görüntü ayarlarıyla07:00/12:00/23:00 ve23:00kesinti ekran görüntüleri alındı. Godot4.7.2 Forward+/GTX1080Ti1280x720; hiçbir görüntü sonradan aydınlatılmadı. Capture betiğinin ilk denemesinde HUD düğüm adı yanlıştı; yardımcı betik düzeltildi ve sonraki sekiz görüntülü koşu LIGHTING CAPTURE: PASS,stderrboş olarak tamamlandı. Oyun kaynak kodunda bu yardımcı hata yoktu.

Testler yalnız Run-Tests.ps1'in ayrı proje/kullanıcı dizinlerinde. İlk eski güç testi “onarımda bütün lambalar her saatte açık” varsaydığı için başarısız oldu. Beklenti silinmedi: sabah kapalı, gece yerel lambalar açık ve emisyonla eşleşmiş olmak üzere daha doğru denetimler eklendi. Güncel seçili kapı: room137/power693/house_layout99/audio35 PASS. Son küçük pencere dolgu ayarı bundan sonra tam regresyonda sınanır; son tam sonuç ayrıca kaydedilmeden geçmiş sayılmaz.

Son tam sonuç: güncel pencere dolgusu dahil30paket/7546raporlanmış kontrol WASAPI PASS. Kaynak runtime/lighting-full-tests.log; tqh-tests-aa51ba80fee1499fad8769f4fd155c7a. Sürüm etiketi ve teslim belgeleri sonradan güncellendi; oyun/ışık kodu değişmedi. Release menü açılışı ayrıca seçili paketle doğrulanır. Bu testler hedef60FPS veya tam elle kampanya kanıtı değildir.

## Deneme, sınırlar ve bitiş ölçütü

Editörde ek kurulum yok. Açılan kaynak 0.1.11 olarak yönlendirildiğinde aynı kayıt/yatak/karakterler korunur. Saat eylemlerle ilerler; ilk sabah aydınlığı yeni oyunda görülebilir. Akşam dinlenerek, gece uyku/nöbetle sınanır. Aynı kamera karşılaştırması ve tam regresyon geçmeden yayımlandı denmez.

2D oda çizimleri yeniden üretilmedi; var olan day/night/outage varyantları korunuyor. Yeni kapı animasyonu, kapı deliği, NPC stili, ek yakıt ekonomisi, üst kat planı ve merdiven hatası bu sürümün işi değildir. Merdiven Claude I03'te. Sıradaki bağımlılık kapı geçişi ve odaların sanat tutarlılığıdır. Görsel yönün nihai kabulü sahibindedir.
