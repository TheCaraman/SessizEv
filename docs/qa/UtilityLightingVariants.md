# Tesisat odası — elektrik ve saat ışık varyantları

## Amaç

Gün 3'ün ana elektrik olayında, bütün resmi karartıp çizimdeki lambaları hâlâ yanar bırakmak tutarsızdı. Tesisat odasına ayrı night, outage_day ve outage_night kaynakları üretildi; day mevcut çizimsel ana kaynaktır. Kesinti çizimlerinde hem tavan ampulü hem tezgâh lambası sönüktür. Gündüz havalandırma ızgarasından soğuk gün ışığı, gece çok zayıf soğuk ışık ve kapı yönünden dolgu kullanılır. Yeni fener, mum veya kırmızı acil lamba nesnesi eklenmedi. Pano/tezgâh/jeneratör konumları korunur; piksel düzeyinde aynı fırça izi garantisi verilmez.

## Dosyalar ve motor bağlantısı

assets/rooms/utility.png ve assets/rooms/variants/utility_{night,outage_day,outage_night}.png. resources/items/room_visuals.json utility alanı dört durumu ayrı yollarla seçer. Mevcut RoomVisuals ve RoomView kodu kullanılır; yeni düğüm/autoload yok. Ayrı çizilmiş arka plana ikinci karartma uygulanmaz. Karakter/prop katmanının tonu ayrı kalır. Kapı eşiği aynı RoomVisuals çözümünü kullandığından oda açılmadan görünen resim de duruma uyar.

Godot 4.7.2 ile içe aktar ve oyunu yeniden aç; Gün 3'te tesisat odasını kesinti öncesi/sonrası ve onarımdan sonra incele. Kayıt sürümü değişmedi. Görsel seçim var olan power_incident.state ve dakikaya bağlıdır; yeni suçlu, enfeksiyon veya kaynak etkisi yoktur.

## Kontroller ve sınırlar

tests/room_lighting_test.gd dört utility durumunu, doğru kaynak yolunu, eşit 1672×941 çerçeveyi, UI'nin renklendirilmemesini, tekrarlı sinyalde ton birikmemesini, save/load ve açık odada onarım sonrası yenilenmeyi kapsar. --capture-room-lighting gerçek motor ekranlarını docs/qa/utility-lighting-<variant>.png olarak yazar. Diğer özel ışık varyantı bulunmayan odalar fallback kullanmayı sürdürür. Bu teslim bütün evin gece/elektrik sanatı veya manuel baştan sona oynama değildir.

Sonuç: 22 paket/6063 denetim PASS; bu dosyanın GPU ışık testi 64 denetim PASS ve dört utility renderı üretildi. Gece-kesinti gerçek RoomView ekranı incelendi. Kapıda artık eşik resmi gösterilmediği için önceki eşik resmi açıklaması tarihsel kalır; ışık seçimi gerçek RoomView'da çalışır.
