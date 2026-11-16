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

Mevcut öğeler: yaprak desenli yeşil duvar kâğıdı, çıkıntılı süpürgelik ve tavan altı koyu çıta, koyu parke, kademeli panelli kirli sarı kapılar, kademeli kapı kasaları, pirinç kapı kolları, desenli yolluk halı, düz tavan lambaları.

Eksikler: gerçek basamaklı merdiven, pencere, koridor eşyaları (portmanto, ayna, telefon sehpası), kapı açılma sesi ve geçiş efekti.

## 4. 2D oda görselleri — üretim kuralları

Proje sahibi bir yapay zekâ görsel aracıyla üretir. Tutarlılık için:

- **Boyut:** 1920×1080, PNG.
- **Dosya yolu:** `assets/rooms/<oda_kimliği>.png`. Kimlikler: `living_room`, `dining`, `kitchen`, `pantry`, `utility`, `bathroom_ground`, `guest_a`, `guest_b`, `daniel_bedroom`, `isolation`, `multipurpose`, `bathroom_upper`, `storage`.
- **Arka plan boş olmalı:** içinde insan yok. Karakterler ayrı katmandır.
- **Bakış:** kapı eşiğinden içeri, göz hizasından, hafif geniş açı. Her odada aynı.
- **Işık:** tek zayıf kaynak; görselin kenarları karanlığa gömülür.
- Dosya yoksa oyun yeşil bir yer tutucu ve "yer tutucu görsel" yazısı gösterir.

**Oda istemi şablonu**

```
Interior of a [room] in a run-down small-town house, seen from the doorway at eye level,
slightly wide angle. Empty of people. [3-5 concrete objects].
Hand-painted digital illustration with rough visible brushwork and heavy dark outlines,
gritty and unsettling. Palette: dark murky green and teal, with dirty yellow accents.
One weak light source; the edges of the image fall into near-black.
No text, no logos, no people. 16:9.
```

## 5. 2D karakter görselleri — üretim kuralları

- **Biçim:** saydam arka planlı PNG, ayakta tam boy; yükseklik yaklaşık 900 piksel.
- **Dosya yolu (planlanan):** `assets/characters/<karakter_kimliği>/<poz>.png`.
- **Tekinsizlik herkese uygulanır.** Yüzler hafifçe "yanlış" durur; bu, enfekte olanı ele veren bir işaret olamaz.
- Aynı karakterin farklı pozlarında yüz ve giysi tutarlı kalmalıdır. Yapay zekâ araçlarında bu zordur; her karakter için önce tek bir referans görsel onaylanır, diğer pozlar ondan türetilir.
- Karakter katmanını dolduracak sistem henüz yazılmadı.

## 6. Dürüst sınırlar

- Koridor dokuları kodla üretildiği için yapay ve tekrarlı görünür; boyanmış dokular gelince değişecek.
- Hiçbir oda ve karakter görseli henüz yok.
- Yapay zekâyla üretilen görsellerin ticari kullanım hakları, kullanılan aracın şartlarına bağlıdır; yayından önce lisans denetimi yapılacak.
