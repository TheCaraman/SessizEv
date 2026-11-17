# THE QUIET HOURS — Sanat Kitabı

Sürüm 0.2 · 2026-11-16 · K-011 ve K-012'ye göre yeniden yazıldı. Önceki "kirli PS1" yönü geçersizdir.

2026-11-18 geçerli yön: tek katlı 3D L koridor ve katmanlı2D odalar. Sahip videodaki loş ev hissini, koyu kapıları, pencere huzmelerini ve daha yumuşak yüzeyleri istedi. Kuvvetli duvar baskısı azaltıldı. Yeni koridor/dekor/ışık uygulandı; bütün oda ve karakter çizimleri bu son yöne henüz eşitlenmedi. Önceki13oda/kalın kontur revizyonu tarihçedir. Nihai görsel kabul sahibin denemesinden sonra; sahne veya varlıklar referanstan kopyalanmaz.

## 1. Sunum biçimi (K-011)

| Alan | Biçim |
|---|---|
| Giriş, ana hol ve L biçimli yatak koridoru | 3D, birinci şahıs yürünür |
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

**Palet dengesi:** soluk bordo/gül-kahverengi duvar · mat koyu turkuaz kapı · koyu kırmızı yolluk · kahverengi parke · nötr krem tavan. Sıcak lamba bölgeleri ve serin yeşil pencere/ortam ışığı dengelenir.

**Pencereler:** girişte ön kapının yanında ve L koridorun doğu ucunda iki gerçek pencere. Perdeler, jaluziler, dış manzara, kaynak ışığı, yerel hafif toz hacmi ve yumuşak huzmeler kullanılır. Oda içi pencereler2D çizimdir.

**Koridor eşyaları:** girişte paspas, askılık/paltolar, ayakkabı sehpası ve şemsiye; holde kitaplı yazı dolabı, lambalı telefon konsolu, tablolar ve saat; yatak kanadında küçük dolap, lamba ve sürahi. Orta geçişler açık kalır. Üst kat ve merdiven yoktur.

Kapı sesi, hızlı eşik geçişi ve dış manzara mevcut. Bazı mobilya ve karakterler hâlâ geçici üretim düzeyindedir; nihai sanat kabulü yapılmadı.

## 4. 2D oda görselleri — üretim kuralları

Proje sahibi bir yapay zekâ görsel aracıyla üretir. Tutarlılık için:

- **Boyut:** 1920×1080, PNG.
- **Dosya yolu:** `assets/rooms/<oda_kimliği>.png`. Kimlikler: `living_room`, `dining`, `kitchen`, `pantry`, `utility`, `bathroom_ground`, `guest_a`, `guest_b`, `daniel_bedroom`, `isolation`, `multipurpose`, `bathroom_upper`, `storage`.
- **Arka plan boş olmalı:** içinde insan yok. Karakterler ayrı katmandır.
- **Bakış:** kapı eşiğinden içeri, göz hizasından, hafif geniş açı. Her odada aynı.
- **Işık ve üslup:** güncel referans `assets/rooms/living_room.png` (ART-REV-003 sahibi onayı): sade çizimsel biçimler, koyu konturlar, kirli yeşil gölge, soluk sıcak duvar ve sınırlı sarı ışık. Fotogerçekçi/ayrıntılı yağlı boya görünümünden kaçın.
- **Alt üçte bir sakin olmalı:** anlatı paneli ve düğmeler orayı örter.
- Dosya yoksa oyun yeşil bir yer tutucu ve "yer tutucu görsel" yazısı gösterir.

**Oda istemi şablonu**

```
Interior of a [room] in a run-down small-town house, seen from the doorway at eye level,
slightly wide angle. Empty of people. [3-5 concrete objects].
Simplified graphic illustration, irregular dark contours, broad color shapes,
slightly uncanny perspective, no photorealism, no pixelation. Muted warm plaster,
neutral ceiling, brown wood, burgundy upholstery, deep green-teal shadows.
Dim curtain light and a small warm lamp. Lower third kept calm.
Reference: assets/rooms/living_room.png (owner-approved ART-REV-003 direction).
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
- Oturma odasında gündüz, gece, gündüz-kesinti ve gece-kesinti için ayrı arka planlar var.
  Bunlar yazılmış 2D ışık durumlarıdır; oda içi gerçek 3D ışık değildir. Diğer 12 oda
  hâlâ tek resim modülasyonu kullanır. docs/qa/LivingRoomLightingVariants.md kapsamı kaydeder.
- Tam üretim istemleri docs/art/prompts/, ölçü/saydamlık/SHA256 kayıtları asset_manifest.json içinde.
- Yapay zekâyla üretilen görsellerin ticari kullanım hakları, kullanılan aracın şartlarına bağlıdır; yayından önce lisans denetimi yapılacak.

2026-11-18 güncel yön: tek katlı L planı,iki pencere,duvar/kapıda hafif yüzey dili; eski üst kat ve merdiven açıklamaları tarihçedir. Ayrıntı docs/qa/SingleStorey.md.
