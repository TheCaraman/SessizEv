# Kapı/oda ortak kompozisyonu ve merdiven — 0.1.12

Bu teslim I04 prototipindeki somut eksiği kapatır: ayrı eşya ve NPC katmanları yalnız tam ekranda belirmemeli. Aktif sürüme alınmadan önce aynı görsel kaynağı ve tam regresyon doğrulanır. Genel oyun veya karakter sanatı tamamlandı iddiası değildir.

## Gerçek kaynaklar ve sorumluluk

`scripts/art/room_world.gd` arka plan, RoomProps ve karakter katmanını tek yerde kurar. RoomVisuals'ın gün/saat/güç seçimi; Settings dünya parlaklığı; GameState.get_room_occupants üzerinden gerçek konum/iş/izolasyon/sakin statüsü kullanılır. Dünya çizimi kampanya, seed, enfeksiyon, kaynak, saat veya kayıt değiştirmez. NPC görsel fabrikası da aynı kaynaktadır; RoomView'ın eski özel yardımcısı bu fabrikaya yönlendirir.

`scripts/ui/room_view.gd` içindeki World, bu bileşenin bir örneğidir. Başlık, kişi adları, konuşma ve eylem düğmeleri bunun dışında kalır. Eski `_background`, `_prop_layer` ve `_character_layer` alanları ortak bileşenin düğümlerine işaret ettiği için mevcut test/sahne bağımlılıkları korunur.

`scripts/house/room_door.gd` fiziksel RoomThreshold quad'ına RoomPreviewViewport dokusunu verir. Bu SubViewport yalnız2D çizer, ayrı World2D kullanır, girdi almaz; altında ikinci RoomWorld örneği vardır. Kaynaklar ortak olduğu için iki görünümde aynı eşya/karakter/sıra/renk kullanılır; ikinci UI veya CampaignDirector oluşturulmaz. Viewport yalnız açılma/kapanmada güncellenir; oda tam ekran açıkken veya kapı kapalıyken her kare tekrar çizilmez.

`shaders/door_room_preview.gdshader` SCREEN_UV ile kompozisyonu kapı aralığından gösterir. Küçük kartı esnetme veya ikinci siyah fade yoktur. Kamera kısa süre fiziksel kapıya yaklaşır, göz yüksekliği korunur; RoomView devrinde eski koridor transformuna geri alınır. Escape animasyonu iptal eder; camera_motion ayarı kapalıysa yalnız kapı kanadı hareket eder. SettingsView yeni ayarı otomatik kurar; EN/TR etiketler strings.csv'de. Kalıcılık mevcut settings.cfg'dedir, save şeması değişmez.

İzlenen sinyaller: zaman, sakinler, tercih/çözünürlük ve önizleme için doğrudan PowerIncident.power_changed. Değişim sırasında açık aralıktaki görüntü güncellenir; tam oda ekranı kendi dinleyicisini kullanır. Kapanırken o anki model yeniden alınır. Önizleme UI'dan eylem çalıştırmaz veya ikinci tüketim/iş ödülü üretmez.

## Merdiven entegrasyonu

Claude'un151e84e teslimi ayrı c9f6660 cherry-pick'iyle alındı. HouseBuilder'da eski eğik BoxShape köşeleri ayak/sahanlığa taşıyordu; dikey uçlu ConvexPolygonShape3D prizması yalnız merdiven izinde kalır. Görsel merdiven, oda kimlikleri ve plan değişmez. Claude'un stairs_test'i gerçek CharacterBody'yi üç şerit/iki yön, çıkış, dönüş ve çapraz girişte60/30Hz yürütür.

Bu fizik yürüyüşleri yaklaşık210s gerçek zaman ister. Test koşucusunda yalnız stairs_test sınırı en az300s yapıldı; simülasyon hızlandırılmadı, denetimler azaltılmadı. Diğer paketlerin varsayılan90s sınırı korunur. Run-Tests listesi bu paketle30çekirdek+WASAPI=31olur.

## Doğrulama kanıtı

İlk ortak kompozisyon seçili testleri: kapı, oda ışığı, etkileşim/sunum ve ses geçti. Daha sonra30paket geniş regresyon geçti. Native GPU son50kontrol PASS,stderrboş;5görüntü: boş oda aralığı, yaklaşma, tam oda ve Elena'lı oda aralığı/tam ekran. Ortak dünya ilk kurulumda anchors/size uyarısı üretiyordu; yalnız önizleme kökü sabit üst-sol ankora alınarak uyarı giderildi. Native görüntüde artık TV/radyo eşyası ve Elena açılan kapının arkasında da bulunuyor. Gece/kesinti dokuları, görevli kişinin yatak odasında görünmemesi, izolasyon, kovulma ve çizimin kampanyayı değiştirmemesi testte doğrulandı.

Kamera tercihi testinde dilin istemeden değişmemesi için test TranslationServer'ı tek başına değil mevcut kalıcı Settings dilini kullanır ve bitişte önceki dilini geri yükler. Bu test verisidir; normal oyuncu dosyalarına yazılmaz.

Son birleşik31paket kapısı `runtime/door-stairs-release012-tests.log` içinde yürür; sonuç henüz burada tamamlandı sayılmaz. Kaynak kodu bu koşudan önce donduruldu. Geçtiğinde gerçek toplam ve süreç sonucu ayrıca kaydedilir. Son native kareler aynı renderer kodundan, görünmez merdiven çarpışması entegrasyonundan önce alındı; görünür geometri değişmedi. FPS hedefi ölçülmedi; 50native denetim bir performans benchmarkı değildir.

## Kurulum, deneme ve sınırlar

Yeni editör kurulumu gerekmez: Godot4.7.2/Forward+ ve mevcut proje. Normal E etkileşimi kapıyı açar; Escape açılırken iptal veya oda içindeyken dönüş. Ayarlardaki Kapıda kamera hareketi0/1 yaklaşmayı kapatır/açar. Aynı kampanya ve mevcut v6 kayıtları korunur. Testler yalnız izolasyonlu Run-Tests üzerinden; native kontrol E: altındaki açık override.cfg'li ayrı QA projesinde çalışır.

Görsel doğrulama kadrajı1920x1080; genel ayarlar720p/1080p/1440p yerleşimleri test edilir. Dar/ters kapılar ve farklı FOV için daha geniş elle oynama sürer; en az mevcut gerçek kapı/tekrar/iptal/işgaller doğrulandı. Yeni NPC çizimleri, yeni pozlar, üst kat oran revizyonu, kapı deliği ve Gün5 bu teslimde yok. Sonraki bağımlılık I07 sanat adayları ve I05 kapı deliği; kullanıcı tarafından seçilmemiş karakter stilini varmış saymayız.

## Son teslim doğrulaması
31 paket WASAPI PASS: runtime/door-stairs-release012-final.log. İlk birleşik koşuda kendi eklediğimiz üst sehpa sağ merdiven şeridini engelliyordu; x9.90 yerine x5.28 konumuna taşındı, gerçek yürüyüş testleri değiştirilmedi; ikinci tam koşu geçti. Sonrasında yalnız önizlemede çift parlaklık uygulanması düzeltildi; güncel son kod settings/door/room_lighting/presentation dört paketi ve WASAPI testini geçti (door-final-brightness-tests.log). Son kaynakla native Forward+ 54 kontrol PASS, stderr boş (door012-final-gpu.stdout.log). Beş PNG aynı native koşudan yenilendi. Tam31 koşu son dar parlaklık düzeltmesinden önce, dört paket ve native test sonrasındadır.

Sahibin son geri bildirimi: ışık/atmosfer hâlâ yetersiz. Bu sürüm genel sanat kabulü değildir. Sabah üst koridor gerçek görüntüsü düz ve cansız; referans atmosferine ulaşıldığı iddia edilmez. Sonraki görsel iş kaynak farkı değil aktif sürümden aynı kamera karşılaştırmasıyla doğrulanmalı.
