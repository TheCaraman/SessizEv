# V5 ev içi dönüşümü — ilk oda

Hedef: sahibin son beğendiği direct-reference-v5 karakterindeki sert posterize fotoğraf/3D hacim ve lekeli baskı dilini ev içine taşımak. Bu ilk teslim yalnız oturma odası; bütün evin bitişi değildir. Oda adları/kimlikleri/etkileşimler korunur. Önceki B çizgi-roman ve guaş yaklaşımları yeni referans değildir.

## Gerçek dosyalar ve kurulum
assets/rooms/graphic_v5/living_room/{day,night,outage_day,outage_night}.png: dört1672×941 gerçek araç çıktısı; aynı pencere/perde, solda bordo kanepe, sağda lamba/masa, kapı ve halı düzeni. Eski kaynaklar geri dönüş için korunur.
assets/props/graphic_v5/media_console.png: ayrı şeffaf TV/radyo/dolap, aynı nesne sırası ve normalize slot. İlk native görüntü eski çizgi roman TV'nin yeni oda ile uyuşmadığını gösterdi; bu yüzden ayrı katman da yeniden üretildi. Eşya kimliği media_console değişmedi.
resources/items/room_visuals.json ve room_props.json yalnız bu yeni yolları seçer. Actor tintleri ve diğer oda tanımları değişmedi. tests/room_lighting_test.gd yalnız isteğe bağlı --capture-living-lighting gerçek görüntü kaydını ekler; mevcut davranış denetimleri korunur.

Düğüm hiyerarşisi aynı: RoomView/RoomWorld/{background,RoomProps,characters}; fiziksel kapı önizlemesi de aynı RoomWorld'ü kullanır. Yeni singleton, shader, etkileşim düğümü veya save alanı yok. Godot4.7.2 import dışında editör kurulumu gerekmez. Üretim istemleri/hashler docs/art/interior-v5/living_room/ içinde; dahili image_gen, rötuş/bitmap işlem yapılmadı.

## Beklenen görünüm
Gündüz perdeden ışık ve kısık sıcak lamba; gece yalnız yerel amber lamba baskın ve dış pencere zayıf serin. Gündüz kesintisinde abajurun ışığı/halosu yok, pencere aydınlığı sürer. Gece kesintisinde lamba tamamen kapalı, oda şekilleri zayıf dış ışıkla okunur. Tavan nötr, kanepe bordo; tüm sahne tek yeşil yıkama değildir. Kamera ve mobilya yerleşimi varyantlarda korunur; generatif yeniden çizimler piksel-piksel aynı görüntü iddiası değildir.

## Doğrulama
Final seçili4paket+WASAPI PASS: door49/room_lighting150/presentation89/power699/audio35; runtime/interior-living-v5-final-tests.log. Son kod/TV varlığı bu koşuda. Tam35paket yeniden koşulmadı; mekanik kod değişmedi, bu dar koşu tam regresyon diye sunulmaz.
Native Forward+/GTX1080Ti1920×1080: room_lighting154 (4PNG dahil), door_transition54 (5capture dahil) PASS, her iki stderr boş. Güncel dört oda renderı + üç living-room kapı aralığı/yaklaşma/devir PNG'si docs/qa/living-v5 içinde incelendi. TV/radyo yeni prop ile aynı ekranda; nihai native koşular bu son prop kaynağını içerir. Kaynak runtime/living-v5-final-gpu.* ve living-v5-door-gpu.*. Yeni bitmapi sadece dosya olarak açmakla yetinilmedi; RoomVisuals seçimi ve gerçek kapı kompozisyonu kontrol edildi. Performans benchmarkı yapılmadı.

Tekrar üretim: Run-Tests.ps1 -SelectedTests room_lighting_test,door_transition_test,presentation_test,power_incident_test -AudioDriver WASAPI. Native yalnız izole QA kopyasında room_lighting_test.tscn -- --capture-living-lighting ve door_transition_test.tscn -- --capture-door. Normal oyuncu kayıtları değiştirilmedi. v6 kayıt şeması, seed, NPC takvimi/kimlikler ve diyalog sonuçları aynı.

## Açık iş ve bağımlılık
Kalan mutfak/yemek alanı/yatak odaları/banyolar/depo/servis/izolasyon odaları henüz bu V5 dilinde değil. Onaylı V5 Elena tam-boy üretim varlığı henüz bağlanmadı;0.1.15 B figürleri korunur. Sonraki kullanıcı isteği koridorların BAŞTAN tasarımı: oda adları/kimlikleri korunacak, dar tünel yerine açık hol ve sahanlık, dış pencere bağlantısı ve aynı yüzey dili. Bu oda teslimi koridorun yapıldığı anlamına gelmez. Koridor değişimi HouseLayout/Builder, ray/fizik/merdiven, spawn, gece görüş rotaları ve prop konumlarıyla birlikte doğrulanmalı.

Dar bitiş ölçütü:4ışık PNG'si ve prop kaynakta, veriye bağlı, gerçekUI/kapı renderı ve ilgili testler geçmiş, aktif launcher doğrulanmış. Genel ev/sanat bitti iddiası yok. Sık hata: eski açık süreç yeni kaynakları yüklemez;0.1.16 için kapatıp yeniden aç. Eski kayıt aynı yeni oda kaynaklarını kullanır; yeni oyun zorunlu değil.
Yayın notu:0.1.16 kaynak checkpoint'i launcher'a ayrı bağlanmadı; bu ilk oda dönüşümü yeni koridor düzeniyle0.1.17 içinde kullanıma alınıyor.
