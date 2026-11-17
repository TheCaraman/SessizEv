# Mutfak V5 — 0.1.18

Hedef: onaylanan V5 görsel yönünü ikinci odaya taşımak. Mutfak kimliği, geçişleri, mobilya işlevleri ve NPC görev sistemi korunur. Bu teslim bütün evin sanatının bittiği anlamına gelmez.

## Dosyalar, kurulum ve hiyerarşi
- assets/rooms/graphic_v5/kitchen/{day,night,outage_day,outage_night}.png: dört gerçek üretilmiş görsel; eski assets/rooms/kitchen.png geri dönüş için korunur.
- resources/items/room_visuals.json: kitchen yolları ve dört aktör/nesne aydınlatma rengi.
- tests/room_lighting_test.gd: dört durum için kaynak seçimi, çift karartma olmaması, UI okunurluğu, nesne rengi/idempotans ve açık oda onarım yenilenmesi; --capture-kitchen-lighting ile gerçek ekran kaydı.
- docs/art/interior-v5/kitchen: üretim istemleri ve SHA256 dosya özeti. Yeni çizimler dahili image_gen çıktısı; sonradan piksel işlemi yapılmadı.

Godot4.7.2 ile project.godot açılır; import otomatik. Yeni düğüm/sinyal/eklenti yok. Mevcut RoomView/RoomWorld/{background,RoomProps,characters} ve fiziksel kapı önizlemesi aynı veri kaynağını kullanır. Yeni kayıt alanı veya bağımlılık eklenmedi.

## Beklenen davranış
Gündüz pencereyle okunur krem dolaplar, soluk sıcak duvar ve koyu turkuaz tezgâh. Gece sıcak yerel lambalar; kesintide hem tavan hem davlumbaz ışığı kapalı, pencere kaynaklı serin dış ışık kalır. UI karartılmaz. Varyantlar aynı kompozisyonun generatif yeniden çizimleridir; piksel piksel eş görüntü değillerdir.

## Doğrulama ve tekrar üretim
Seçili dört paket+WASAPI PASS: door_transition49, room_lighting176, presentation89, power_incident699, audio35. Tam35paket bu sanat değişikliği için tekrarlanmadı; taban b66b4d1 tam regresyonu daha önce geçmişti. Log: E:/TheQuietHours/runtime/kitchen-v5-tests.log.
Native Forward+/GTX1080Ti1920x1080 room_lighting180PASS, stderr boş: runtime/kitchen-v5-gpu.stdout.log ve stderr.log. Dört gerçek oyun içi ekran docs/qa/kitchen-v5 içinde görüldü. Bu koşu doğrudan RoomView açar; yeni mutfak kapısının özel kamera görüntüsü bu teslimde ayrıca çekilmedi. Genel fiziksel kapı ve çalışan NPC'nin yalnız mutfakta görünmesi mevcut door_transition testiyle doğrulanır; yeni NPC çizimi üretilmedi.
Tekrar: tools/Run-Tests.ps1 -SelectedTests room_lighting_test,door_transition_test,presentation_test,power_incident_test -AudioDriver WASAPI. Native yakalama yalnız izole test kullanıcı dizininde room_lighting_test.tscn -- --capture-kitchen-lighting. Oyuncunun normal kayıtları değiştirilmedi.

## Bitiş, hatalar ve sonraki iş
Dar bitiş ölçütü: dört görsel veriye bağlı, ilgili testler geçmiş, gerçek UI görüntüleri incelenmiş ve geliştirici başlatıcısı doğrulanmış. Eski açık oyun yeni varlıkları almaz; kapatıp tekrar açılmalıdır. Yanlış ışık kaynağı görülürse mevcut gün/saat/elektrik durumu ve aktif sürüm kontrol edilir. Performans benchmarkı yapılmadı.
Sonraki bağımlılık: kalan odaların aynı V5 dile dönüşümü; Elena'nın V5 tam-boy varlığı ve Claude'un kamera/bilek teslimlerinin ayrı incelenmesi. Koridor geometrisi bu işte değiştirilmedi; kamera çalışması b66b4d1 tabanına göre devam edebilir.