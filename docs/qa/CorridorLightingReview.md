# Koridor ışık kompozisyonu — 0.1.13

## Amaç ve gerçek kapsam
Sahibin «ışıklar değişmemiş» geri bildirimi üzerine aktif 0.1.12'nin gerçek sabah karesi tekrar incelendi. Geniş, gölgesiz pencere dolgusu/ortam ışığı düz bir görüntü bırakıyor; gündüz tamamen sönen abajurlar sıcak odak üretmiyordu. Bu teslim aynı onaylı paleti kullanarak bu iki sorunu düzeltir. Yeni oda çizimi, NPC çizimi veya mimari tamamlanması değildir; sahibi estetik kabulü henüz vermedi.

## Dosyalar, hiyerarşi ve bağımlılıklar
- scripts/dev/house_blockout.gd: DAY_AMBIENT .30→.18, NIGHT_AMBIENT .065→.075; pencere dolgu çarpanı 2.2→1.1, menzil 8→6.5 ve gölge açık; pencere spot çarpanı1.25. Abajurlar gündüz%55/gece%100, kesintide sıfır. Tavan armatürleri kapalı kalır.
- tests/room_lighting_test.gd: sabah kısık yerel lamba, gece/elektrik/kesinti görünürlüğü ve gerçek emisyon eşleşmesi.
- tests/power_incident_test.gd: sabah onarımında yalnız yerel abajurun dönmesi; gece onarımı, kesinti ve mevcut kampanya denetimleri korunur.
- tests/manual_lighting_capture.gd: yalnız TheQuietHours-Tests/ kullanıcı alanını kabul eden gerçek render yardımcı betiği; normal kayıt alanında çalışmayı reddeder.
- docs/qa/lighting-review/: 12 güncel ve 8 önceki gerçek PNG.

Düğümler: HouseBlockout → mevcut House/Window/Daylight + WindowBounce; HouseBlockout → mevcut CorridorDressing/TableLampLight. Yeni ışık/mesh/kaynak eklenmez. HouseBuilder/HouseLayout/CorridorDressing dosyalarına yazılmadı; Claude I11 sahipliği korunur. Önceden önbelleklenen temel ışıklar saat, gün ve PowerIncident.power_changed ile yeniden uygulanır. Tekrarlı olaylar güç çarpanını biriktirmez. Kayıt v6, seed, takvim, kaynak ve NPC durumları değişmedi. Yeni indirme veya ücretli varlık bağımlılığı yok.

## Kurulum ve beklenen davranış
Godot4.7.2 Forward+ ile mevcut proje yeterlidir; editörde ek düğüm kurma gerekmez. Gün1 sabah alt hol ve üst koridordaki abajur düşük güçte görünmeli; pencere dış ışığı yönlüdür. Gece abajur güçlenir, kesintide gerçek ışık ve kumaş emisyonu kapanır; dış ışık bağımsızdır. Genel parlaklık ayarı değiştirilmedi.

## Test ve kanıt
Run-Tests.ps1 -SelectedTests room_lighting_test,power_incident_test,presentation_test,door_transition_test -AudioDriver WASAPI: kapı49, oda ışığı140, sunum89, elektrik693 ve donanım ses35 PASS (runtime/lighting-review-tests.log). Bu4paket+ses koşusudur; tam31paket diye sunulmaz. 0.1.12 tam koşusu geçmiş tabanın kanıtıdır, bu yeni ışık sayıları için yeni tam koşu iddiası değildir.
Native Forward+/GTX1080Ti1280×720 capture: LIGHTING CAPTURE PASS, stderr boş. Kaynak runtime/lighting-final-capture.*.log. Üç sabit kamera (üst koridor, alt hol, girişe dönüş) ×07:00/12:00/23:00/23:00kesinti=12 gerçek görüntü; PNG'lere rötuş uygulanmadı. Aynı upper/hall kameralarına ait before-* dosyaları0.1.12'den taşındı. Geometri testleri kaynak değişmediği için yeniden koşulmadı. Yeni gölge maliyetinin60FPS hedefi ayrıca ölçülmedi.
Tekrarlamak için Run-Tests'in izole proje kopyasında: Godot --path <izole_proje> --script res://tests/manual_lighting_capture.gd --audio-driver WASAPI. Çıktı o kopyanın docs/qa/lighting-review dizinine yazılır. Normal ana projede doğrudan çalıştırma; koruma kontrolü hata verir.

## Sık sorunlar ve bitiş ölçütü
Açık eski oyun süreci yeni dosyaları yüklemez; kapatıp masaüstünden yeniden açılmalıdır. Ana menüde0.1.13 görünmeden bu sürüm denenmiş sayılmaz. Yeni kampanya zorunlu değil; önceki kayıt korunur. 2D oda ışıkları kendi authored varyantlarını kullanır; koridor değişimi bütün oda sanatını değiştirmez.
Bu dar teslimin bitişi: ilgili regresyonlar PASS, gerçek sabah/gece/kesinti kareleri görülmüş ve aktif kısayolun sürümü doğrulanmış olması. Genel ev atmosferi ve referansa sanat yakınlığı açık kalır. Sonraki bağımlılık Claude I11 üst kat oran incelemesi ve sanat tutarlılığı; yeni gün/sistem eklemek bu görsel eksikliği çözmüş sayılmaz.