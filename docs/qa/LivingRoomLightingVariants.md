# İlk odanın yazılmış ışık durumları

## Hedef ve dosyalar

İlk odada çizili lambanın kesintide hâlâ yanıyor görünmesini giderir. Onaylı gündüz kaynağı assets/rooms/living_room.png korunur. assets/rooms/variants altında living_room_night.png, living_room_outage_day.png, living_room_outage_night.png ayrı ışık düzenleridir; hepsi 1672×941. Yeni oda veya ayrı yürünebilir mekân değillerdir. Üretim istemleri docs/art/prompts altında tutulur.

resources/items/room_visuals.json dört durumun yollarını ve figür/eşya tonlarını tanımlar. scripts/art/room_visuals.gd bu veriyi yorumlar. RoomView._refresh saat/güç değişiminde doğru resmi seçer; resim değiştiğinde eşya katmanının referans ölçüsü yenilenir. Normal gece 20:00–07:00 arasındadır; gece yarısı modulo saat kullanılır. Arka plan hazır ışık taşıdığı için beyaz modulate ile çizilir; karanlık iki kez uygulanmaz. Figür/eşya ayrı tona uyar, UI beyaz kalır. Diğer odalar önceki kaynak ve tonlama yolunu korur.

## Kurulum ve beklenen davranış

Godot 4.7.2 ile projeyi içe aktar. İlk odayı gündüz/gece aç; kesinti ve onarımda doğru görüntüye geçmeli. Gece lambalı görünüm küçük sıcak bir ışık alanı taşır. Kesintide lamba nesnesi kalır fakat sıcak ışık lekesi yoktur. Gündüz kesintisi gece resmi kullanmaz; perde ışığı okunur kalır. TV/radyo ayrı katmandadır, arka plana yeniden çizilmedi.

## Gerçek doğrulama

15 paket toplam 5567 denetim geçti. RoomLighting 33 kontrol: dört durumun seçimi/dosya yolu, kaynak ölçüsü, çift karartma olmaması, eşya korunması, tekrar olayında ton kararlılığı, açık odada onarım sonrası geceye geçiş, 01:00/07:00 saatleri ve dönüştürülmemiş odanın geriye uyumu. Ek pencereli çağrıda dört gerçek 1080p PNG üretildi (37 kontrol); gece ve gece-kesinti görüntüleri incelendi.

Görüntülerde Gün 4 etiketi QA düzeneğinin saat/güç koşuludur; Gün 4 hikâyesinin yazıldığı iddia edilmez. Kaynaklar görsel olarak karşılaştırıldı; mimari/kompozisyon korunuyor görünür, piksel düzeyinde aynı geometri garantisi verilmez. Sistem keskin resim değişimi kullanır; kesintisiz geçiş/crossfade henüz yoktur.

## Sınırlar

Bu dört ışık durumlu 2D arka plan seçimidir; oda içi gerçek 3D aydınlatma değildir. Karakterlerde lokal gölge/yönlü ışık yok; katman tonu kullanılır. Diğer 12 oda aynı sanat ve ışık varyantlarına henüz sahip değil. Fare/klavye ile kontrol önceki otomatik pencere izni reddi nedeniyle hâlâ doğrulanmadı. Görsel onay kapsamı ilk oda yönüdür; tüm oyunun sanat kabulü değildir.

Bitti tanımı: gerçek dosyalar/importlar/veri bağlantısı, dört durumun doğru seçimi, güç onarımına açık oda tepkisi, ilgili regresyonlar ve incelenmiş motor renderları. Sonraki bağımlılık: yeni üsluplu karakter uyumu ve diğer odaların kontrollü üretimi.
