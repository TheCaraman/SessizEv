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