# HOUSE-REBUILD-002 — tüm iç yerleşim ve kuvvetli baskı yüzeyleri

## Amaç ve kapsam
Sahip önceki yalnız galeri/üst kat müdahalesini reddetti. Bu değişiklik iki katta da iç duvarları, oda kapılarını, dolaşımı ve merdiveni yeniden kurar. Oda adları/kimlikleri,2D oda modeli, kampanya/enfeksiyon/save kuralları aynı. Dış kabuğu büyütmek yerine ortada2.3m geniş uçuş, iki yanda2.35m geçiş,7m geniş ön giriş ve üst bağlantı seçildi. Ayrıntılı koordinatlar docs/HousePlan.md son bölümü; tek veri kaynağı HouseLayout.

## Kaynak ve düğümler
scripts/house/house_layout.gd: yeni ROOMS/WALLS/STAIRS/VOIDS; doğrudan pantry/dining koridor kapıları dahil.
scripts/house/house_builder.gd: iki tarafta eğimi izleyen korkuluk, fiziksel kapalı merdiven altı, yeni halı yerleri. House/{Slabs,Walls,Stairs,StairUnderside,Steps,StairBalustrade,StairBalustradeEast,Ceilings,Lamps,CorridorDressing,ExteriorVista} çalışma anında üretilir. Yeni autoload yok.
scripts/house/corridor_dressing.gd: eski duvarlara bağlı mobilya çağrıları emekliye ayrıldı; yeni pencere altı radyatörleri, geçiş dışındaki yerel lambalar ve resimler.
scenes/main/house_blockout.tscn: destekli üst güney başlangıcı(7.5,3.35,10.6).
scripts/art/house_materials.gd + assets/textures/graphic_v7/{plaster,door,ceiling,wood}.png: karakter referansındaki baskı/lekeli posterizasyon daha belirgin. Duvar sıcak kirli şeftali, kapı mat turkuaz/sage, tavan krem, döşeme kahverengi. Yüzeyler StandardMaterial toon diffuse, parlama kapalı; nesne çizgileri mevcut çerçeve/panel geometrisiyle. Postprocessing shader değiştirilmedi; çözünürlük düşürme/piksel filtresi yok. Bunlar tam sahne yerine malzeme varlıklarıdır, normal Godot ışığıyla aydınlanır.
Üretim istemleri ve hashler docs/art/house-rebuild-v2; dahili image_gen gerçek çıktıları, dosya tabanlı rötuş yapılmadı.

Claude'un sahipçe onaylanmış CAMERA-CLIP-00140e5b98/2f2284c/b03b0d1 teslimi alındı:0.38m gövde. Camera clearance testinin kontrol duvarı ve merdiven şeritleri yeni plana taşındı. BODYCAM-002 ayrıca teslim/entegrasyon bekler; bu belge tek başına bodycam bitti iddiası değildir.

## Kurulum, test ve davranış
Godot4.7.2 stable Forward+ ile project.godot import edilir; yeni editör düğümü elle kurulmaz. room kapıları1.05m, merdiven18basamak/3.3m yükselme/5.5m yatay uzunluk. Güney köprü üst katta sağlam, merdiven boşluğu güvenlik korkuluklu. Kapı açılışı ve2D devir aynı sistemde.
İlgili geometri testlerinde eski koordinatlar yeni fizik plana uyarlandı; kamera testinin kör olmadığını kanıtlayan kontrol duvarı da taşındı. Gerçek kapsülle iki yandaki uzun geçişler ve ön bağlantı, odaların kat desteği, duvar/kapı ayrımı ve merdiven doğrulanır.
Doğrulama kayıtları: runtime/house-v2-regression.log32diğerpaket+WASAPI PASS; runtime/house-v2-geometry-tests3.log3geometripaketi PASS: house113/camera7/stairs30. Ayrı32paketle birlikte tüm35çekirdekpaket veWASAPI doğrulandı. İlk kontrol, dekoratif basamaklara alttan girilmesini buldu; StairUnderside hacmi eklendi. Eski testteki0.1.17 kontrol noktaları yeni duvarlara taşındı. Sonuçlar son logla birlikte yorumlanmalı.
Native1920x1080 GTX1080Ti Forward+13gerçek kamera görüntüsü üretildi; temsilî alt/üst/gece/kesinti ve pencere başlangıcı incelendi. runtime/house-v2-final2-review.stdout.log PASS, stderr boş. docs/qa/house-rebuild-v2 PNG'leri son yüzeyler/ahşap ve fizik düzeltmesini içerir. Performans benchmarkı ve nihai sanat kabulü yapılmadı.
Tekrar: Run-Tests.ps1 -SelectedTests house_layout_test,stairs_test,camera_clearance_test,interaction_test,door_transition_test -AudioDriver WASAPI; stairs gerçek60/30Hz yürüyüş nedeniyle birkaç dakika sürer. Native review yalnız izole TheQuietHours-Tests/ kullanıcı dizininde scenes/dev/corridor_rebuild_review.tscn.

## Bitti tanımı ve kalanlar
Yalnız test kapıları geçip başlatıcı yeni checkpoint'e bağlandığında oyuncuya teslim edilir. Normal oyuncu kayıtlarına test yazılmaz. Açık eski oyun yeni kaynakları almaz; yeniden açılmalı. Kalan2D odaların stili ve V5 tam-boy NPC'ler ayrı işler. Oyun bütün olarak tamamlanmış değildir. Daha önceki0.1.18 sürümü geri dönüş için korunur.
Ek kapı incelemesi: test başlangıcı gerçek kapının dönüşümünden türetilir; emekli plandaki sabit konum kullanılmaz. Yeni evde native door_transition54PASS /5yakalama, stderr boş (runtime/house-v2-door-gpu.*). Görüntüler aynı QA klasöründe; açılma görüntüsü incelendi.

## Son birleşim / 0.1.19-dev.20261118.2
Claude BODYCAM-002 d182c57 →412bae3 alındı; Player/BodyCam düğümü yeni evde etkin. Adım düşüşü3.8cm, yan kayma2.4cm, salınım1.5derece; dönüş yatması3dereceye ve gecikmesi2dereceye sınırlı. En çok6cm ofset. camera_motion kapalıysa hareket yok; pause/UI/kapı geçişinde dinlenme pozuna döner. Gövde0.38m; InteractionRay kameranın altında ve gerçek bakış yönünü izler.
Son birleşimde seçili6paket+WASAPI PASS (door49,peephole31,interaction14,camera7,player6,bodycam53), runtime/house-v2-bodycam-integration.log. Bütün35evpaketi daha önce bu geometriyle iki ayrık32+3koşuda geçti; bodycam sonrası tam36paket yeniden koşulmadı. Bu ayrım bilinçli raporlanır.
Native bodycam ilk koşusunda testin render-kare sayısına bağlı dönüş uyaranı yüksekFPS'de çok kısa kalıyordu. Testteki uyaran sabit fizik karelerine taşındı, üretim kamerasının yay parametreleri değiştirilmedi. Aynı düzeltilmiş test hem nativeGPU hem headless WASAPI53PASS; stderr boş. runtime/house-v2-bodycam-native2.* ve house-v2-bodycam-headless-final.*. Eski başarısız loglar tanı kaydı olarak korunur.
Yeni evin gerçek bodycam kontakt levhası docs/qa/house-rebuild-v2/bodycam-review.png; native helper SAVED, stderr boş. Dönüş uyaranı fizik kareleriyle, yürüyüş gerçek oyuncuyla. Fareyle elle değerlendirme/video kaydı yapılmadı; bu dosya oynanış videosu değildir. Reviewhelper yalnız izole kullanıcı dizininde çalışır. Claude'un özgün docs/qa/BodyCam002.md belgesi eski tabandaki teslimi anlatır; yeni ev için bu ek geçerlidir.