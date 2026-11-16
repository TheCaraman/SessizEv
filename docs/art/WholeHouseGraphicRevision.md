# Evin ortak çizim dili — mekân test sürümü

## Sahip isteği ve teslim

Sahip oturma odasını hedefe yakın buldu, kalan gerçekçi odaları ve dar/ruhsuz koridoru reddetti. Önce kapı açılışı, ardından koridor plan/yüzey/ışık geçişi ve 11 eksik oda yeniden çizildi. Böylece 13 ana oda arka planı oturma odasının aynı yerel üslup referansını kullanıyor. Bunlar özgün görsellerdir; başka oyunun sahne/varlığı kullanılmadı. Model referansları yalnız proje içindeki living_room.png ve ilgili eski oda kompozisyonudur.

## Üretilen ve bağlanan dosyalar

assets/rooms altında bathroom_ground, bathroom_upper, daniel_bedroom, dining, guest_a, guest_b, isolation, multipurpose, pantry, storage, utility PNG'leri yeniden üretildi. Kitchen önceki dilimde yenilendi, living_room kabul edilmiş master olarak korundu. Tümü 1672×941; merkez/ön plan figür katmanı için açık. Misafir odaları ikişer yatak, çok amaçlı oda iki yatma yeri, Daniel tek yatak içerir. Depo ve kiler penceresiz; izolasyon odasındaki eski pencere de mevcut planın penceresiz tanımıyla uyumlu kaldırıldı. Tesisat pano/tezgâh/jeneratör konumlarını korur. Bazı küçük mobilya oranları çizimle sadeleşti; piksel-piksel aynı geometri iddiası yoktur.

Eski kaynaklar docs/art/concepts/previous-<room>.png altında saklandı. Built-in imagegen özgün çıktıları kendi oluşturma dizininde kalır; prompt ve gerçek kaynak yolları docs/art/prompts/room_graphic_revisions.json içindedir. Asset manifest, eski iç içe value dizilerinden düz tekil path kayıtlarına temizlendi, mevcut boyut/SHA değerleri güncellendi; eski manifest ayrıca arşivlendi. Karakter kaynakları değiştirilmedi; Elena çizim adayı önceki ayrı inceleme durumundadır.

## Motor bağlantısı ve kurulum

Mevcut RoomView/RoomVisuals yol şeması aynı kaldığından sahne kaynaklarına kırık bağımlılık eklenmedi. 3D koridordaki kapı fiziksel açılır, eşik içinde doğru oda görseli görünür, sonra katmanlı oda görünümüne fade olur. Bu mekanik DoorOpeningTransition.md içinde; koridorun 2→3m genişlemesi ve yeni malzemeleri CorridorRebuild.md içinde belgelenir. Kat/oda kimlikleri ve oyun kayıtları korunur.

Godot 4.7.2 içe aktar, normal oyunu kapatıp yeniden aç. Mevcut masaüstü THE QUIET HOURS kısayolu aynı projeyi açar; yeni kurulum yoktur. Yeni geliştirici galerisi scenes/dev/room_style_review.tscn ve scripts/dev/room_style_review.gd gerçek RoomView kullanır; sağ/sol ile dolaşılır. --capture-all-rooms, 13 görüntüyü docs/art/previews/<room>_in_game.png olarak kaydeder. Bu galeri kayıt yazmaz veya gün çözmez; yeni autoload yoktur.

## Gerçek doğrulama

22 regresyon paketi / 6036 denetim geçti: tqh-tests-0448b73e123a4c7aa3eddb692bca93fe. Gerçek Forward+ galeri 13 oda ekran görüntüsü üretti ve PASS verdi. Üretilen 11 kaynak resim ayrı ayrı açılıp incelendi; motor ekranlarında Daniel/tesisat/üst banyo ayrıca kontrol edildi. Koridor alt/üst gündüz ve üst gece çekimleri önceki dilimde açıldı. Kapsül yeni geniş alanda durabiliyor, merdiven ve kapı testleri geçiyor. Bu programatik kontrol, baştan sona fare/klavyeyle elle oynandı iddiası değildir.

## Kesin sınırlar

Bu teslim, sahibin mekân görseli/koridor/kapı testini yapabileceği tutarlı bir revizyondur; tüm oyunun nihai sanat bitişi değildir. Living dışındaki odalarda ayrı çizilmiş gece/elektriksiz varyantlar henüz yok; mevcut renk fallback'i kullanılır. Boyalı lambaların kaynak içindeki ışığı bu fallback ile fiziksel olarak tamamen sönmez; özel varyant üretimi gerektirir. Hazırlanmış izolasyon dekoru, nihai koridor küçük eşyaları/çerçeve içleri ve karakter üslup uyumu hâlâ ayrı iştir. Koridor planı daha geniş olsa da bağlantı topolojisi korunur; açık dünya veya yeni odalar eklenmedi. Sahip incelemesi nihai görsel kabulün kaynağıdır.
