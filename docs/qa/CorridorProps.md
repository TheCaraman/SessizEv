# Koridor eşyaları, perdeler ve resimler — CORRIDOR-REFERENCE-002 devamı

2026-11-16 — Claude. Codex'in devir notundaki 1. maddeyi kapsar: "boş/düz resim çerçeveleri,
sert düz şerit perdeler, kutu biçimli telefon/ayakkabı/diğer küçük eşyalar hâlâ prototip".
Sahibin estetik kabulü değildir; mekân incelemesine sunulan bir adımdır.

## Değişen davranış

- **Perdeler:** dikine kutu şeritler yerine tek parça, yumuşak dikey kıvrımlı kumaş yüzey
  (`PropMeshes.cloth_mesh`). Her perde konumundan türetilen tohumla farklı kıvrım ve etek
  düzensizliği alır. Malzeme çift yüzlü ve arkadan ışık geçirir (`curtain_cloth`): gündüz
  pencere ışığı kumaşın içinden sızar. Ray üstünde pirinç halkalar var. Perde aralığı,
  ölçüler ve gün ışığı spotu değişmedi.
- **Resimler:** boş renk kutuları yerine derinlikli çerçeve, açık renk paspartu ve gerçek görüntü.
  Üç özgün, kodla üretilmiş görüntü: kır manzarası, natürmort (vazoda çiçek), solmuş sepya
  ev fotoğrafı (`assets/textures/painting_landscape.png`, `painting_still_life.png`,
  `photo_house.png`). Üretim: `scenes/dev/generate_pictures.tscn`; yüzey dokularını yeniden
  üreten `generate_all()` bunlara dokunmaz. Hol batı duvarında iki, üst koridorda iki resim.
- **Giriş:** kutu paltolar yerine askıdan sarkan, yaka katmanlı kumaş paltolar; atkı; dört
  askı çivisi. Ayakkabı sehpasında taban/üst/topuk biçimli dört ayakkabı ve yerde bir çift.
  Köşede kapalı, sapı kıvrık şemsiye.
- **Hol masası:** silindir ayaklar; çevirmeli kadranlı, kordonlu, ahizeli telefon; kubbeli masa
  saati (kadran ve akrep/yelkovan); not defteri ve kalem; yuvarlak lamba ayağı.
- **Üst koridor:** iki resim, pencere ucunda kitap dolu alçak kitaplık, sandalyede kumaş battaniye,
  sahanlık dolabında sırlı testi. Daha önce bu kat neredeyse eşyasızdı.
- Kitaplar, raflar ve sehpa üstü bilerek kutu kaldı: gerçekte de kutu biçimliler.

## Dosyalar

- Yeni: `scripts/art/prop_meshes.gd` (kumaş yüzeyi ve eşya kurucuları), `scripts/dev/generate_pictures.gd`,
  `scenes/dev/generate_pictures.tscn`, üç resim PNG'si ve `.import` dosyaları.
- Değişen: `scripts/house/corridor_dressing.gd`, `scripts/house/house_builder.gd` (`_add_curtain`),
  `scripts/art/house_materials.gd` (curtain_cloth, coat_cloth, picture_frame, üç resim),
  `scripts/art/texture_generator.gd` (`generate_pictures` ve üç resim üreticisi),
  `scripts/dev/corridor_review.gd` (yakın çekim için `--view=x,y,z,yaw,pitch,dosya` seçeneği).
- Yeni autoload, eklenti, kayıt alanı veya oyun mantığı değişikliği yok. Kayıt şeması aynı.

## Doğrulama

- Gerçek GPU (Godot 4.7.2 Forward+, 1920×1080) görüntüleri alındı ve tek tek incelendi:
  `corridor-ground-{day,night}`, `foyer-{day,night}`, `corridor-upper-{day,night}` ve yakın
  çekimler `closeup-coats-front`, `closeup-coats-shoes`, `closeup-hall-table`, `closeup-hall-stairs`,
  `closeup-upper-end`.
- Tam regresyon: sonuç HANDOFF.md kaydında.

## Sınırlar

- Paltolar ve battaniye yakından hâlâ basit kumaş levhalar; omuz/kol biçimi yok.
- Ayakkabılar uzaktan ve karanlıkta okunuyor; yakından ilkel parçalı.
- Resimler kodla üretilmiş düz biçimler; oda görsellerinin çizim diliyle tam aynı değil. İstenirse
  aynı dosya adlarıyla elle çizilmiş/üretilmiş görsellerle değiştirilebilir.
- Perde kumaşı fizik simülasyonu değil; hareket etmez.
- Fare/klavye ile elle oynanış yapılmadı; bu görüntüler sabit kameradan alındı.
