# Koridor açık hol / V5 mekân uygulaması

## Hedef ve kapsam
Sahip koridorları daha geniş ve gerçek bir ev gibi, onayladığı direct-reference-v5 atmosferiyle yeniden tasarlamamızı istedi. Bu teslim geometri, yüzey, gerçek ışık ve açılış kadrajını birlikte değiştirir.3D yürüyüş ve2D odalar korunur. Tüm oda adları/kimlikleri/kapı sırası aynı; yeni mekanik, ekonomi, enfeksiyon veya save alanı eklenmez. Oturma odasının önceki8310c0f V5 dört ışık varyantı ve TV/radyo dönüşümü de bu kaynağın içindedir.0.1.16 kaynak checkpoint'i ayrı launcher yayını yapılmadan0.1.17 içine alındı.

## Dosyalar ve düğümler
- scripts/house/house_layout.gd: FOYER_VOID ve VOIDS; üst koridorun boşluk üstündeki rect'i kaldırıldı, alt alçak hol başlığı yerine yalnız doğu askılık duvarı bırakıldı; yeni galeri guard kaydı.
- scripts/house/house_builder.gd: mevcut slab/ceiling bölücüsü yeni boşluğu kullanır. _build_open_guard sürekli StaticBody3D/CollisionShape3D bariyer ve ayrı ince MeshInstance3D ray/dikmeler kurar; düşme/merdiven ayırımı sürer, görüş duvarla kapanmaz. Yeni giriş sarkıtı aynı elektrik/local_lamp gruplarıyla mevcut zaman/kesinti denetimine katılır.
- scripts/house/corridor_dressing.gd: yeni boşlukta havada kalacak üst kitaplık/radyatör kaldırıldı; kalan mobilyalar ana geçişi daraltmaz.
- scripts/art/house_materials.gd ve assets/textures/graphic_v5/{plaster,floorboards}.png: onaylı odanın paletinden üretilmiş daha sade sıva/ahşap dokular. World-space triplanar + lineer/mipmap süzme; piksel çözünürlüğü düşürülmez. Üretim istemi/hash docs/art/corridor-v5/ altında, dahili image_gen. Dikiş sürekliliği sayısal ölçülmedi; normal renderer tekrarları gözle incelendi.
- scenes/main/house_blockout.tscn: aynı destekli başlangıç konumu, pencereli galeriye bakan instance yaw180°. scripts/player ve scenes/player/player.tscn Claude sahipliğinde, değiştirilmedi.
- tests/house_layout_test.gd: çift yükseklik, döşemesiz gerçek boşluk, düşme bariyeri, eski başlığın yokluğu, kapsülün açık girişe yürümesi ve üst güvenli seyir alanı. Eski «pencere önü kapsül sığıyor» kontrolü havada da geçebiliyordu; artık yeni boşluğun gerçekten döşemesiz olduğu kontrol edilir. Merdiven testinin yönü spawn kadrajından bağımsız açıkça kuzeye ayarlanır; beklenen fizik sonuçları silinmedi.
- tests/stairs_test.gd: Claude563eb84'ün SADECE çapraz gerçek merdiven giriş düzeltmesi alındı; o commit'in koridor daraltması alınmadı. Önceki çapraz örnek koridora yürüyüp merdivene girmeden geçebiliyordu. Şimdi sahanlıktan250° ile gerçek iniş ve yükseklik kaybı denetlenir.
- scripts/dev/corridor_rebuild_review.gd + scenes/dev/corridor_rebuild_review.tscn: yalnız izole TheQuietHours-Tests/ altında gerçek13kamera renderı. İlk kadraj gerçek ana sahne spawn dönüşüdür; kalan4kamera×gündüz/gece/gece-kesinti.

Hiyerarşi: HouseBlockout/House/{Slabs,Ceilings,Wall_*/OpenGuardCollision,ray/dikme meshleri,Lamps,CorridorDressing}; mevcut Player/Head/Camera3D korunur. Yeni singleton/sinyal veya indirme bağımlılığı yok. Godot4.7.2 import dışında editör adımı gerekmez. Kaynak RoomDoor, RoomWorld ve gece erişim sorguları mevcut kapılardan aynı kimlikleri kullanır.

## Gerçek görüntü ve test kanıtı
İlk4paket (night_witness,door_transition,house_layout,player_movement)+WASAPI geçti; ilk layout104kontrol. Son doku/sarkıt/spawn/çapraz merdiven düzeltmeleri sonrası TAM35paket/7762raporlanmış kontrol WASAPI PASS, süreç0: runtime/corridor-rebuild-full-tests.log, tqh-tests-b46d362ad5f3442f8968c1c623bcf06d. ROOM LIGHTING151, POWER INCIDENT699, STAIRS30 dahildir. Oyun/test kodu bu tam koşuda sabit; sonrasında yalnız sürüm/teslim belgeleri ve art-only capture yardımcısının ilk kadraj kaydı güncellendi. Yardımcının son hali native koşuda doğrulandı.

Final native Forward+/GTX1080Ti1920×1080: CORRIDOR REBUILD REVIEW PASS13,stderr boş (runtime/corridor-rebuild-release-gpu.*). Aynı helper eski0.1.15 kopyasında da13kare üretir (corridor-before-gpu.*). before-* ve yeni dört sabit kameranın pozisyon/saat/FOV değerleri aynıdır. opening-view karelerinde ilk bakış yönü tasarım gereği farklıdır; onu aynı açı karşılaştırması sayma. UI sanat incelemesi için gizlenmiştir, sahne gerçek engine renderıdır, görseller rötuşlanmadı.

Deneysel bir luma basamak filtresi tavanda iri yapay lekeler yaptı; native görüntüyle reddedilip tamamen kaldırıldı. shaders/retro_post.gdshader release tabanıyla aynıdır. Görsel dönüşüm düşük çözünürlük, zorunlu balık gözü veya ağır filtreyle yapılmadı. Bu60FPS hedefi için ölçülmüş benchmark değildir.

## Deneme / beklenen davranış
Oyunu kapatıp merkezi masaüstü kısayolundan0.1.17 ile aç. İlk bakış galeri korkuluğundan dış pencere/alt girişe yönelir. Koridor içinde3.75m alan ve açık merdiven görüşü; aşağıda hol-giriş başlıksız bağlantı. E ile mevcut kapı→2D oda, Escape dönüş aynı; ahşap korkuluğun ince görsel aralıkları fiziksel geçit değildir. Sarkıt ve abajurlar gece sıcak yerel ışık verir, kesintide elektrik/emisyon söner, dış pencere ışığı sürer.

Save v6 değişmez; eski sakin/yatak/iş/takvim/enfeksiyon/kanıt kayıtları korunur. Normal kullanıcı kayıtlarına QA yazılmaz. Yeni oyun zorunlu değildir. Şu anda fiziksel oyuncu dünya konumu kayıttan restore edilmediği için eski pencere boşluğunda kayıtlı spawn sorunu yaratılmaz; destekli ana sahne spawn'ı kullanılır.

## Sınırlar ve sonraki işler
Bu açık hol/sahanlık ilk uygulamasıdır; bütün evin ve diğer NPC'lerin nihai sanat kabulü değildir. Kalan12oda hâlâ ayrı V5 dönüşümü bekler; B Elena figürleri henüz onaylı V5 tam-boy figüre çevrilmedi. Claude CAMERA-CLIP incelemesini yeni checkpoint üstünde ayrıca yapacak; onun I08 bilek ve I10 dekor dalları bu teslimde yok. Yeni plan, ek dekor ve sanat ayrıntıları ilerledikçe aynı fizik/görüş testleri korunmalı. Sürümün bitti ölçütü yeni geometri+varlıkların kaynakta bulunması, tam test, gerçek önce/sonra render ve launcher/PrepareOnly doğrulamasıdır; estetik değerlendirme kullanıcı denemesiyle sürer.