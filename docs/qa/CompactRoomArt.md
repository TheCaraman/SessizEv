# Birleşen oda çizimleri — 0.1.21-dev.20261118.1

## Amaç ve kapsam
COMPACT-ROOM-ART-001; 7dc0629 tek kat temelinin görsel devamı. Mutfak yemek alanını, servis kileri görünür biçimde içerir. Kullanıcının depoda pencere istememe kararı korunur. Mutfak masası/iki sandalye/iki kupa ve servis gıda rafları statik çizimdir; yeni eşya etkileşimi, kaynak üretimi veya kanıt değildir. Eski arkaplanlar silinmez. Koridor geometrisi, hafif bodycam, kapı süreleri ve save v6 değişmez.

## Gerçek dosyalar ve bağımlılıklar
- assets/rooms/compact_v1/{kitchen,utility}/{day,night,outage_day,outage_night}.png: sekiz özgün 1672×941 bitmap. Tüm durumlarda kamera/yerleşim korunur. Elektrikli lamba kesintide söner; gündüz ışığı yalnız mevcut pencere/menfezden, gece sınırlı soğuk ortamdan gelir.
- resources/items/room_visuals.json: yalnız kitchen ve utility yolları değişir. Mevcut actor_tints korunur; arkaplan beyaz modulate ile çift karartılmaz.
- tests/room_lighting_test.gd: mutfak boyut denetimi ve isteğe bağlı --capture-compact-room-lighting; üretim mekanik koduna yeni bağımlılık yok.
- docs/art/compact-room-art/production-prompts.json: gerçek üretim istemleri ve kaynak yolları; asset-manifest.json SHA256 kayıtları. Kaynak referans kareleri dağıtılan oyun varlığı değildir.

Sahne ağacı değişmez: HouseBlockout/RoomView -> RoomWorld(background, props, actors) ve bağımsız başlık/eylem UI. RoomVisuals saate/elektriğe göre arkaplanı seçer; RoomDoor aynı RoomWorld'ü eşik ve oda görünümünde kullanır. UI yerleşimi ve görev sinyalleri yeniden bağlanmaz.

## Kurulum ve beklenen davranış
Godot 4.7.2 stable Forward+ ile project.godot import edilir. Elle düğüm veya kaynak ekleme gerekmez. Mutfak kapısı yeni birleşik çizimi gösterir; servis mevcut mutfak içi bağlantısından açılır. Elektrik onarılınca açık oda anında powered karşılığına geçer. Dil ve başlıklar aynı EN/TR verisinden gelir. Eski açık oyun dosyaları kendiliğinden yenilemez; aktif sürüm tekrar açılmalıdır.

## Doğrulama
tools/Run-Tests.ps1 -SelectedTests room_lighting_test,door_transition_test,presentation_test,power_incident_test,room_compact_test -AudioDriver WASAPI -KeepProjectCopy

İzole koşu: runtime/compact-room-art-tests.log. Door57, room lighting161, presentation93, power687, compact42; ayrıca audio lifecycle35. Bu dar koşu toplam 6 paket/1075 kontroldür; tam 40 paket yeniden çalıştırılmadı. Save/load kesinti durumu, onarımla anlık yenileme, aynı sinyalin tonu katlamaması, oda eşlemesi ve mevcut kapı davranışı sınanır. Normal oyuncu kayıtları değiştirilmez.

Native Forward+ 1920×1080 ekran üretimi: aynı izole kopyada tests/room_lighting_test.tscn -- --capture-compact-room-lighting. Sekiz gerçek RoomView ekranı docs/qa/compact-room-art altında. runtime/compact-room-native.stdout.log ve stderr.log koşu kaydıdır. Otomatik ekran üretimi elle oynama veya FPS benchmarkı değildir.

## Hatalar, bitiş ve açık iş
Eksik importta console --headless --path <project> --import çalıştırılır; eski sürüm açılıyorsa runtime/active-development.json ile kök launcher kaynağı karşılaştırılır. Kesintide çift kararma olmamalı, elektrik lambasının halesi kalmamalı. PNG yollarını eski tek görselle değiştirmek dört durumu bozar.

Bitti tanımı: sekiz gerçek kaynak mevcut, yollar bağlı, ilgili testler başarılı, native ekranlar okunabilir ve aktif geliştirme sürümü bu commit'i açıyor. Nihai sanat kabulü kullanıcıya aittir. Yeni Elena V5 tam figürü ve kalan oda çizimleri hâlâ uygulanmadı; Gün5–14/18NPC bu teslimin parçası değildir. İki odanın sadeleşmiş boyama dili referanstaki daha kaba yüz anlatımını tek başına çözmez; karakter çalışması ayrıca gerekir.
