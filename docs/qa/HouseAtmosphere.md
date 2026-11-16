# Ev atmosferi ve büyütme — HOUSE-ATMOS-001

2026-11-16 — Claude. Sahip önceki koridoru tamamen reddetti ("uzaktan yakından alakası yok"),
referans oyunun estetiğinin internetten araştırılmasını, evin genişletilmesini ve korkunç,
gerici bir ev atmosferi istedi. Bu belge araştırmayı, çıkarılan ilkeleri ve uygulamayı kaydeder.
Sahibin kabulü değildir.

## Araştırma

Kaynak: resmî Steam sayfası (store.steampowered.com/app/3180070) ve oradaki dokuz resmî ekran
görüntüsü, tarayıcıda tek tek açılıp incelendi. Hiçbir görüntü indirilmedi, kopyalanmadı veya
oyuna konmadı. Aşağıdakiler gözlem ve yorumdur; o oyunun teknik yöntemi hakkında iddia değildir.

Gözlemler:
- **Tek renkli ton:** gece ve kapı önü sahneleri neredeyse tamamen yeşil/turkuaz monokrom; gündüz
  oda sahneleri de soluk, hasta sarı-yeşile çekilmiş.
- **Kalın oval kenar kararması** ve **üstte/altta siyah sinema şeritleri**; görüntü bir mercekten
  ya da kapı deliğinden bakılıyormuş gibi.
- **Çizim gibi görüntü:** oda sahnelerinde mürekkep konturları, sıkıştırılmış siyahlar, posterli tonlar.
- **Koridor:** tavana kadar yoğun desenli (çiçek/damask) duvar kâğıdı, açık renk panelli kapılar ve
  kasalar, koyu parke, desenli halı, eski bir yazı dolabı üstünde şişe ve radyo.
- **Işık:** tek güçlü kaynak; jaluzi aralığından pusun içinden çapraz geçen görünür huzmeler.
  Tavan karanlık; köşeler gömülü.
- **Mekân:** eski Doğu Avrupa apartman/ev içi; eskimiş, yaşanmış, sıradan.

## Uygulanan ilkeler

| Gözlem | Bizdeki karşılığı |
|---|---|
| Tek renkli yeşil ton | `shaders/retro_post.gdshader`: parlaklığı koyu yeşil → soluk sarı-yeşil rampaya oturtan ton (%62), derin gölgeleri ezme |
| Mürekkep konturları | Aynı gölgelendiricide parlaklık farkından kontur (Sobel); 3D koridor çizilmiş odalarla aynı dilde okunur |
| Oval kararma, sinema şeritleri | Güçlü oval kenar kararması, ekran yüksekliğinin %6,5'i kadar üst/alt şerit, ince gren |
| Desenli duvar kâğıdı | Özgün, kodla üretilmiş koyu yeşil damask (`texture_generator._wallpaper`), tavana kadar; alt panel kaldırıldı |
| Açık renk kapılar | Kapılar soluk kirli krem boya, kasalar ve süpürgelik açık boya |
| Jaluzi ve huzme | Koridor pencerelerinde eğik çıtalı jaluzi; yandan, alçaktan vuran gün ışığı yerde çizgili gölge ve pus içinde huzme bırakır |
| Karanlık tavan, tek kaynak | Ortam ışığı ve tavan lambaları kısıldı; tavan koyulaştı; pus yoğunlaştı |
| Yaşanmış ev | Holde kitaplı yazı dolabı (şişe, radyo), pencere altlarında döküm radyatörler |

Kopyalanmayanlar: o oyunun görselleri, karakterleri, arayüzü, kapı deliği ekranı ve sahneleri.
Palet onaylı kararlar içinde kalır (yeşil/turkuaz baskın, kırmızı halı ve krem vurgular).

## Ev büyütmesi

- Kat planı bütünüyle ×1,25: ev 12 × 10 → **15 × 12,5 m**; hol 3 → **3,75 m** genişlik.
- Kat yüksekliği 2,8 → **3,3 m** (tavan 3,1 m); kapı yüksekliği 2,1 → 2,3 m. Kapı genişliği 0,9 m kaldı.
- Merdiven 1,5 × 5,6 m, 18 basamak. Pencereler ve geniş geçitler de ölçeklendi.
- Odaların 2D görselleri etkilenmez; oda kimlikleri, bağlantılar ve kapı sırası aynı.
- Kodda sabit koordinat kullanan yerler güncellendi: ev testi, etkileşim, kapı geçişi, kapı sesi testleri,
  oyuncu başlangıcı, inceleme araçları, dış manzara konumu, yolluk.

## Doğrulama

Gerçek GPU 1920×1080: `corridor-ground-{day,night}`, `foyer-day`, `corridor-upper-{day,night}`,
`hall-toward-windows`, `hall-bureau`. Tam regresyon sonucu HANDOFF.md'de.

## Sınırlar ve açık işler

- Ton, ekran filtresi ile verildi; ayarlar menüsünde yoğunluğu kısma seçeneği henüz bağlanmadı.
- Gece görünümü gündüzden yeterince ayrışmıyor; lambalar baskın.
- Merdivenin altı açık basamaklar; korkuluk ve basamak yanağı sade.
- Kodla üretilmiş desen ve eşyalar elle çizilmiş referans kalitesinde değil.
- Elle fare/klavye oynanışı yapılmadı.
