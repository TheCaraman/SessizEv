# THE QUIET HOURS — Sanat Kitabı

Sürüm 0.2 · 2026-11-16 · K-011 ve K-012'ye göre yeniden yazıldı. Önceki "kirli PS1" yönü geçersizdir.

## 1. Sunum biçimi (K-011)

| Alan | Biçim |
|---|---|
| Giriş, hol, merdiven, sahanlık, üst koridor | 3D, birinci şahıs yürünür |
| Diğer bütün odalar | Kapıdan açılan 2D katmanlı sahne |
| Karakterler | 2D çizim; oda sahnesinin üstüne katman olarak eklenir |

Bir 2D oda sahnesinin katmanları, arkadan öne: **arka plan** (boş oda) → **eşya** (kampanya boyunca değişenler: yatak, hasar, kanıt) → **karakter** → **arayüz**.

Bu yapı sayesinde aynı oda görseli, içine kim girerse girsin ve ne değişirse değişsin yeniden çizilmez; yalnızca katman eklenir.

## 2. Renk ve ton (K-012)

- Ana renkler: koyu kirli yeşil ve hafif turkuaz.
- Vurgu: kirli sarı (kapılar, desen, ışık).
- Tavanlar ve köşeler neredeyse siyah; ekran kenarlarında belirgin kararma.
- Görüntü pürüzsüz ve doygun (K-013): dokular 512–1024 piksel, yumuşak süzmeli; pikselleştirme ve renk kademelenmesi kapalı; kenar yumuşatma açık.
- Çok hafif gren ve kenar kararması var; ayarlardan kapatılabilecek.

**Esin ve sınır:** *No, I'm Not a Human* yalnızca yapı ve ton esinidir (3D koridor, 2D oda, tekinsiz çizim). O oyunun renk düzeni (turuncu duvar, mavi kapı), odaları, karakterleri, arayüzü ve görselleri kopyalanmaz. Bizim paletimiz yeşil/sarıdır.

## 3. 3D koridorlar

Koddan kurulur (`scripts/house/house_builder.gd`). Dokular `assets/textures/` altında PNG dosyalarıdır; şimdilik `scripts/art/texture_generator.gd` üretir. Aynı adla boyanmış bir doku koyulursa oyun onu kullanır.

Mevcut öğeler: sade, kirli sarı duvar kâğıdı (çok silik baklava deseni), çıkıntılı süpürgelik ve tavan altı koyu çıta, koyu parke, kademeli panelli koyu turkuaz kapılar, soluk kademeli kasalar, pirinç kapı kolları, desenli yolluk halı, tavan lambaları.

**Işık ve atmosfer (K-014, K-015):** hava soluk, nötr bir pusla doludur ve ışık bu pusun içinde görünür (hacimli sis). Tavan lambaları zayıf, sıcak ışık adacıkları yapar. Gün ışığı gerçek pencerelerden gelir: dışarıdaki ışık perdelerin aralığından ve pencere çıtalarının arasından geçip yere ve duvara düşer. Yumuşak gölge, köşelerde temas gölgesi ve hafif parlama açıktır. Duvarlar sade tutulur; görünümü taşıyan şey desen değil ışıktır.

**Palet dengesi:** kirli sarı duvar · koyu turkuaz kapı · koyu kırmızı yolluk · kahverengi parke · kirli beyaz tavan, kasa ve süpürgelik. Hiçbir renk bütün sahneyi boyamaz; ortam ışığı nötrdür.

**Pencereler:** giriş holünde ön kapının yanında bir pencere. Üst kat koridorları dış duvara değmediği için orada pencere yoktur. Odaların pencereleri 2D oda görsellerinde çizilir.

**Koridor eşyaları:** girişte paspas, askılık ve asılı paltolar, ayakkabı sehpası, şemsiye; holde lambalı ve telefonlu konsol, tablolar, duvar saati; üst katta sandalye, tablolar, küçük dolap. Her kapının yanında elektrik anahtarı. Merdiven on altı gerçek basamak ve trabzandır.

Eksikler: kapı açılma sesi ve geçiş efekti, pencereden görünen dış manzara, boyanmış dokular. Eşyalar kutulardan kuruludur; paltolar ve perdeler gibi kumaş nesneler kaba durur.

## 4. 2D oda görselleri — üretim kuralları

Proje sahibi bir yapay zekâ görsel aracıyla üretir. Tutarlılık için:

- **Boyut:** 1920×1080, PNG.
- **Dosya yolu:** `assets/rooms/<oda_kimliği>.png`. Kimlikler: `living_room`, `dining`, `kitchen`, `pantry`, `utility`, `bathroom_ground`, `guest_a`, `guest_b`, `daniel_bedroom`, `isolation`, `multipurpose`, `bathroom_upper`, `storage`.
- **Arka plan boş olmalı:** içinde insan yok. Karakterler ayrı katmandır.
- **Bakış:** kapı eşiğinden içeri, göz hizasından, hafif geniş açı. Her odada aynı.
- **Işık ve üslup:** referans `assets/rooms/living_room.png` (karar ART-001): perdeden soğuk gün ışığı, zayıf sıcak lamba, hafif pus, pürüzsüz boyanmış gerçekçilik.
- **Alt üçte bir sakin olmalı:** anlatı paneli ve düğmeler orayı örter.
- Dosya yoksa oyun yeşil bir yer tutucu ve "yer tutucu görsel" yazısı gösterir.

**Oda istemi şablonu**

```
Interior of a [room] in a run-down small-town house, seen from the doorway at eye level,
slightly wide angle. Empty of people. [3-5 concrete objects].
Smooth painted realism, high resolution, no pixelation, no outlines. Plain dirty-yellow
walls, off-white ceiling, brown wood, deep red rug, dark teal upholstery. Cool daylight
through a gap in the curtains, one weak warm lamp, light haze. Lower third kept calm.
Reference: assets/rooms/living_room.png (decision ART-001).
No text, no logos, no people. 16:9.
```

## 5. 2D karakter görselleri — üretim kuralları

- **Biçim:** saydam arka planlı PNG, ayakta tam boy; ilk üç kaynak 1024×1536.
- **Dosya yolu:** `assets/characters/<karakter_kimliği>/default.png`.
- **Tekinsizlik herkese uygulanır.** Yüzler hafifçe "yanlış" durur; bu, enfekte olanı ele veren bir işaret olamaz.
- Aynı karakterin farklı pozlarında yüz ve giysi tutarlı kalmalıdır. Yapay zekâ araçlarında bu zordur; her karakter için önce tek bir referans görsel onaylanır, diğer pozlar ondan türetilir.
- Karakter katmanı gerçek sakin durumundan doldurulur. İlk üç figür Elena, Marcus
  ve Arthur'dur. Oda ekranında ayaklar ortak zemin çizgisine oturur; konuşmada aynı
  kaynağın üst bölgesi yakın kadrajda gösterilir. Enfekte/sağlıklı ayrı resim yok.

## 6. Dürüst sınırlar

- Koridor dokuları kodla üretildiği için yapay ve tekrarlı görünür; boyanmış dokular gelince değişecek.
- 13 adet 2D odanın tamamında insan içermeyen arka plan var. Kaynaklar 1672×941;
  1920×1080 önizlemelerde yumuşak ölçeklenir, yapay büyütme kaynak dosyaya işlenmez.
- İlk üç karakterin yalnızca varsayılan pozu var; konuşma animasyonu ve ifade varyantları yok.
- Gece ve kesinti için ayrı boyanmış varyantlar henüz yok. Tek resmin modülasyonla
  karartılması, pencere ve lambaların ayrı fiziksel ışık katmanları olduğu anlamına gelmez.
- Tam üretim istemleri docs/art/prompts/, ölçü/saydamlık/SHA256 kayıtları asset_manifest.json içinde.
- Yapay zekâyla üretilen görsellerin ticari kullanım hakları, kullanılan aracın şartlarına bağlıdır; yayından önce lisans denetimi yapılacak.
