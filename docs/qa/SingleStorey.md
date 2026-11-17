# Single Storey — 0.1.20-dev.20261118.1

## Hedef ve karar
Sahip tek kat ve video referansındaki ev hissini yetkilendirdi. Amaç: kısa dolaşım, yumuşak yüzey, mat koyu kapı, yaşanmış dekor, gerçek pencere kaynaklı ışık ve hızlı kapı eşiği. Önceki kuvvetli baskı duvarı reddedildi. Tek katın maliyeti: katlar arası ses gerilimi kaybolur; L köşesi ve iki ışık doğrultusu bu kaybı kısmen karşılar. Bütün sanatın tamamlandığı veya referansla eşit kaliteye ulaştığı iddia edilmez.

## Dosyalar ve yapı
- scripts/house/house_layout.gd: tek kat14alan(10işlevsel+4dolaşım),8koridorodakapısı+ana kapı, boşSTAIRS/VOIDS, RoomAliases'a tek eşleme delegasyonu. Kesin ölçü ve kapı koordinatları docs/HousePlan.md son bölümü.
- scripts/house/house_builder.gd: tek zemin/çatı, merdiven yok, iki gerçekpencere, FogVolume/WindowDust ve üçer WindowShaft. Işıklar aynı gün/elektrik gruplarını kullanır.
- scripts/house/corridor_dressing.gd: portmanto/palto, ayakkabı sehpası/şemsiye, kitaplı yazı dolabı, lambalı telefon konsolu/saat, tablolar, yatak kanadı dolabı/sürahi. Geçiş merkezleri açık.
- scripts/art/house_materials.gd + assets/textures/single_storey/wallpaper.png: özgün düşük kontrastlı duvar kâğıdı; daha sakin eski kapı/ahşap kaynakları, BURLEY ışık, ağırtoon/hatch yok. Üretim istemi docs/art/single-storey/wallpaper-prompt.txt. Referans video kareleri dağıtılan varlık değildir; yeni desen referansın kopyası değildir.
- scripts/house/exterior_vista.gd: doğu penceresi için mevcut özgün dış manzaranın ayrı yan görünümü.
- scripts/dev/house_blockout.gd ve shaders/window_shaft.gdshader: serin ortam, yerel sıcak lambalar, kaynakla zamanlanan yumuşak huzmeler. Huzmeler gerçek duvar derinliğinde gizlenen düşük maliyetli stilize yüzeylerdir; fiziksel olarak tam ışın izleme değildir. Shader kenarında negatif tabanlı pow kullanımı engellendi.
- shaders/retro_post.gdshader + scripts/core/settings.gd + scripts/ui/{settings_view,world_presentation}.gd: daha az kontur/grain,3Ddünyada vinyet0..0.6(varsayılan.34), ayardan kapanır,UI karartılmaz.720p taşması düzeltildi.
- scenes/main/house_blockout.tscn: başlangıç(7,0.05,11), kuzey yön; iki kat veya çatıda doğma yok.
- Claude83546e1: scripts/house/room_door.gd ve RoomView; yaprak ve yaklaşma paralel0.4sn, aynıRoomWorld devri. Azaltılmış harekette0.25sn yaprak+0.18sn kısa çözünme, kamera sabit. Hafif bodycam538e705 sahibin onayıyla korunur.
- Claude3f54956/c4f6024: RoomAliases, GameState, CampaignDirector, RoomWorld/View, ilgiliyargımodülleri, jobs.json, strings.csv ve testfixtureları. dining→kitchen,pantry→utility,bathroom_ground→bathroom_upper. Eski kayıt kopya üstünde idempotent göç eder; seed/enfeksiyon/yatak/resources korunur. Inventory/check_supplies artık serviste;8servisseçeneği.
- scripts/house/night_route_access.gd + tests/night_route_access_test.*: eski üst kat sabitleri yerine gerçek kapı yanları ve koridor merkezleriyle bağlantı arama;1.35m destekli gözlem; kilit/engel/duvar içi başlangıç reddi. NightWitness fizik engel testi yeni gerçek noktaya taşındı. Sağlıklı/enfekte davranış kuralları değişmedi.

Düğüm ağacı: HouseBlockout/{House(runtimeSlabs/Walls/Ceilings/Lamps/CorridorDressing/ExteriorVista),Player/{Head/Camera3D/InteractionRay,BodyCam},CampaignDirector,RoomView,DialogueView,Hud,RetroPostProcess}. Window düğümleri Daylight/WindowBounce/Moonlight/WindowDust/WindowShaft0..2 içerir. Yeni autoload yok; save şeması6.

## Kurulum ve beklenen davranış
Godot4.7.2stable Forward+ ile project.godot açılır,import tamamlanır; elle yeni düğüm yerleştirmek gerekmez. Yerel motor E:/TheQuietHours/tools/godot-4.7.2/. OYUNU_AC.cmd aktif kaynağı seçer. Eski açık oyun yeni kaynakları almaz; yeniden açılmalı. Üst kat/merdiven yoktur. Banyodaki küçükdolap ve mutfaktaki servis bağlantısı2Ddir, ulaşılmaz ekstra3Dkapı yoktur. Oda adlarındaki eskiüst/alt kat ifadeleri EN/TR düzeltildi; UI'de tek Banyo gösterilir.

## Doğrulama
Tam koşu runtime/single-storey-full-final.log: All40test suites passed(includingWASAPI),7913raporlanan kontrol. House98,camera7,stairs5(emekliye ayrılanmerdivenin yoklukregresyonu),house_access49(tüm9erişilebilirkapıya gerçek yürüyüş),door57,bodycam53,compact42,night_route7,settings115 dahil. Eski iki kat route/engel fixture'ı ilk koşuyu düşürdü; bu gerçek ray-kontrolünün duvar içinden başlayınca kaçırma sorununu da ortaya çıkardı. hit_from_inside ile reddediliyor; finaltam koşu bunu içerir.
Son kat sözcüklerinin EN/TR temizliğinden sonra ilgili4paket+WASAPI ayrıca PASS: runtime/single-storey-localization-final.log(day4radio249,nightwitness89,settings115,campaign101,audio35). Son yalnız-görsel huzme düşüşü ayarından sonra native13kameraçıktısı PASS,stderr boş: runtime/single-storey-final-composition.*. Bu görsel ayar için40paket yeniden çalıştırılmadı.
NativeForward+/GTX1080Ti1920x1080: docs/qa/single-storey içinde13gerçek ekran. Temsilî giriş, köşe ve yatak kanadı/gündüz/gece/kesinti incelendi. Son grafik kompozisyonu kullanılır. İlk yoğun/sorunlu ışık iterasyonları yayınlanmadı; eski tanı logları runtime'da korunur.
Kapı videosu: scripts/dev/single_storey_door_movie.gd + scenes/dev/single_storey_door_movie.tscn; gerçek üretim kapısı/RoomView, izole kullanıcı dizini, motor movie-mode60FPS,156kare/2.6sn. runtime/single-storey-door-final.stdout.log PASS,stderr boş. AVI ffmpeg ile docs/qa/single-storey/door-preview.mp4'e dönüştürüldü; door-frames.jpg yalnız inceleme karesidir. Görüntü motor içinde üretilmiştir; elle fare/klavye oynanmış test değildir. Movie-mode zamanları performans benchmarkı sayılmaz.
İki eşzamanlı nativeQA aynı cache dizininde ilk denemede shader cache oluşturma uyarısı verdi; seri ve ayrı izole kullanıcı dizinindeki doğrulanmış koşuların stderr'i boştur. Normal kullanıcı kayıtları değiştirilmedi.

## Tekrar üretim
Tam: tools/Run-Tests.ps1 -GodotPath <Godot-console.exe> -AudioDriver WASAPI.
Dar: -SelectedTests room_compact_test,night_witness_test,night_route_access_test,house_access_test,door_transition_test,bodycam_test,settings_test.
Native: izole TheQuietHours-Tests/... override.cfg ile scenes/dev/corridor_rebuild_review.tscn veya --write-movie <AVI> --fixed-fps60 scenes/dev/single_storey_door_movie.tscn. Normal kullanıcı dizininde review helper çalıştırma. Her araç kendi koşumunu yönetir; ortak geçici klasörlerde wildcard silme yok.

## Bitti tanımı ve açık iş
Bu artırımın bitişi: tek kat yürünür, eski kayıt fonksiyonları taşınır, geçiş0.4sn, ayarlar erişilebilir, ilgili/full testler ve native çıktı geçer, aktif launcher son checkpoint'i açar. Nihai sanat kabulü sahibi tarafından yapılmadı. Tüm2Doda arkaplanları veNPCfigürleri bu işte yeniden üretilmedi; birleşen mutfak/servisin masa/raf kompozisyonu ve diğeroda/karakter sanatını tek çizim diline eşitlemek sonraki sanat bağımlılığıdır. Gün5–14 ve tam18NPCkampanya işi bu teslimin parçası değildir. Yeni katta adım/pencere yakınlığı elle oynanış hissi ayrıca değerlendirilmeli; otomatikgeçiş testinin kalitesi insan kabulünün yerine geçmez.