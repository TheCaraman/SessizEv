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

## İkinci tur — HOUSE-ATMOS-002 (aynı gün)

Sahibin geri bildirimi: öncekinden iyi ama hâlâ basık ve boğucu; gerçek bir ev bu kadar koyu olmaz;
gece pencerelerden daha çok ışık sızmalı; odalar aynı kalabilir, yürünen alanlar yeniden şekillensin.

- **İki kat yüksekliğinde hol:** holün merdiven tarafı (x 6,8–8,75) ve merdiven boşluğu üst kata açık
  (`HouseLayout.VOIDS`). Üst koridor bu boşluğa bakan 1,8 m'lik korkuluklu **galeri** oldu; boşluğun üç
  kenarında 1,1 m korkuluk. Holde bu bölümde tavan 6,4 m.
- **Tepe penceresi** (`HouseLayout.SKYLIGHT`): çatıda çerçeveli cam; gündüz gün ışığı, gece ay ışığı huzmesi
  hole iner. Boşluğun ortasındaki lamba çatıdan uzun kabloyla sarkar.
- **Merdivenin açık yanı:** beyaz balüstrat ve eğim boyunca görünmez korkuluk; oyuncu merdivenden hole düşemez.
- **Gerçek ev renkleri:** açık bej, solmuş damask duvar kâğıdı; beyaza yakın tavan; açık krem kapılar,
  beyaz kasa ve süpürgelik; kapı boyasındaki kir azaltıldı. Ekran tonu %62 → %30, gölge ezme %25 → %8,
  kararma 0,85 → 0,55, sinema şeridi %6,5 → %4. Görüş açısı 70° → 78°.
- **Gece ışığı:** her koridor penceresinde ve tepe penceresinde gece güçlenen mavimsi ay/sokak ışığı
  (`moon_lights` grubu, saate bağlı; elektrik kesintisinden bağımsız). Ortam ışığı da saate bağlandı:
  gündüz 0,5, gece 0,14. Gündüz pencere ışığı ve testteki "gece zayıf" kuralı korundu.
- Üst kat yolluğu galeriye taşındı. Ev testi: eski "koridor / merdiven duvarı" denetimi "galeri korkuluğu"
  oldu. 22 paket PASS.

Görüntüler: `corridor-ground-{day,night}`, `foyer-day`, `corridor-upper-{day,night}`, `gallery-down`,
`hall-void-up`, `hall-void-night`, `foyer-night-shafts`, `hall-toward-entrance`.

Açık: ayarlardan ton yoğunluğu; gece holde elektrik açıkken ay ışığı lambaya göre zayıf kalıyor;
desen ve eşyalar kodla üretildi; elle oynanış yok.

## Üçüncü tur — HOUSE-ATMOS-003 (aynı gün)

Sahibin geri bildirimi: değişiklikler güzel ama atmosfer kaybolmuş; ışıklar daha loş olmalı ve
kamerada hafif bir yaka kamerası (body cam) hissi olmalı. Plan önce Codex'e yazıldı
(`messages/20261116-claude-to-codex-bodycam-plan.md`).

- **Loş ışık:** ortam ışığı gündüz 0,5 → 0,28, gece 0,14 → 0,06; tavan lambaları 0,42 enerji ve sıcak,
  eski akkor rengi (1,0 / 0,82 / 0,58). Pus 0,022. Açık duvar ve tavan renkleri korundu; karanlık
  ışıktan geliyor, boyadan değil.
- **Ton:** ekran tonu %30 → %36, gölge ezme %8 → %14, kararma 0,55 → 0,68.
- **Yaka kamerası merceği** (`retro_post.gdshader`): hafif fıçı bükülmesi (köşeler dolu kalacak kadar
  yakınlaştırılmış), köşelerde yumuşama ve çok hafif renk saçağı, yavaş otomatik pozlama nefesi.
  Hepsi ayrı uniform; sıfırlanınca kapanır. Ekranda REC/saat yazısı yok.
- **Kamera salınımı** (`scripts/player/body_cam_sway.gd`): durunca nefes gibi ±0,35°, yürürken adımla
  sallanma ve 1,8 cm iniş-kalkış. Yalnız Camera3D'nin kendi dönüşünü/konumunu değiştirir; bakış ve
  hareket aynı. `enabled = false` eski görüntüyü birebir geri verir.
- **Düzeltmeler (Codex'in bulduğu):** oyuncu başlangıcı hol boşluğunun üstündeydi, yeni oyunda zemine
  düşülüyordu → galeriye (5,9 / 3,35 / 8,0) taşındı ve ev testine "başlangıç boşlukta değil, altında
  zemin var" denetimi eklendi. x ekseninde uzanan korkulukların üst başlığı yanlış yöndeydi → düzeltildi.
- 22 paket PASS (ev testi 99 denetim).

Görüntüler: `corridor-ground-{day,night}`, `hall-void-up`, `hall-void-night`, `foyer-night-shafts`,
`hall-toward-entrance`, `gallery-down`.

Açık: mercek ve salınım oyuncu ayarlarından henüz kapatılamıyor (hareket hassasiyeti için gerekli);
elle oynanış yok. Not: Codex aynı sırada sahibin isteğiyle ayrı dalda (codex/house-atmosphere-v3,
HOUSE-ATMOS-004) galerisiz, filtresiz başka bir yön hazırladı; masaüstü başlatıcısı şu an o dalı açıyor.
Hangi yönün süreceği sahibin kararıdır; bu tur o dala uygulanmadı.
