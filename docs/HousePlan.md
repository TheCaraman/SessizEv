# THE QUIET HOURS — Ev Kat Planı

Sürüm 0.6 / HOUSE-ATMOS-004 / 2026-11-16. Önceki büyük galeri sahibi tarafından reddedilen atmosferle birlikte yeniden ele alındı. Kodun veri kaynağı scripts/house/house_layout.gd. Oda kimlikleri, ana hikâye bağlantıları, yatak/iş atamaları korunur.

Ev 15 × 12,5 m; katlar arası 3,3m, net tavan3,1m. Ana dolaşım iki katta da 3,75m. Yalnız merdiven boşluğu açık; holde atrium, dar galeri veya tepe penceresi yok. Kapılar 0,9 × 2,3m. Duvar dış0,2/iç0,1m. Oyuncu kapsülü0,6m çapındadır.

## Zemin kat — (x,z,genişlik,derinlik), metre

| Mekân | Dikdörtgen | Bağlantı / kullanım |
|---|---|---|
| Yemek | 0,0,5,5.625 | Oturma ve mutfak arasındaki 2D geçiş |
| Oturma | 0,5.625,5,6.875 | Holden kapı; TV/radyo/sakinler |
| Mutfak | 5,0,6.875,3.75 | Holden; yemek/kiler/tesisat |
| Kiler | 11.875,0,3.125,3.75 | Mutfaktan; penceresiz |
| Ana hol | 5,3.75,3.75,6.875 | Giriş, oturma, mutfak; sağda merdiven |
| Merdiven dibindeki uzantı | 8.75,9.375,1.5,1.25 | Banyo ve merdiven erişimi |
| Giriş | 5,10.625,5.25,1.875 | Ön kapı ve iki gerçek pencere |
| Tesisat | 10.25,3.75,4.75,5.625 | Yalnız mutfaktan; jeneratör/pano |
| Alt banyo | 10.25,9.375,4.75,3.125 | Merdiven dibindeki uzantıdan |
| Merdiven | 8.75,3.75,1.5,5.625 | Alt uç güneyde; fizik rampa, görsel basamak |

## Üst kat

| Mekân | Dikdörtgen | Bağlantı / kullanım |
|---|---|---|
| Misafir B | 0,0,5,3.75 | Sahanlıktan; 2 yatak |
| Misafir A | 0,3.75,5,3.75 | Koridordan; 2 yatak |
| Daniel | 0,7.5,5,5 | Koridordan; uyku/kayıt |
| İzolasyon | 5,0,5.25,2.25 | Sahanlıktan; penceresiz |
| Sahanlık | 5,2.25,5.25,1.5 | Merdiven üst ucu ve üç oda bağlantısı |
| Ana koridor | 5,3.75,3.75,6.875 | Tam genişlik ve kesintisiz döşeme |
| Banyo kapısı uzantısı | 8.75,9.375,1.5,1.25 | Üst banyo erişimi |
| Pencere önü | 5,10.625,3.5,1.875 | Gerçek ön cephe penceresi |
| Çok amaçlı | 10.25,0,4.75,8.125 | Sahanlıktan; 2 yatak, ileride +2 |
| Üst banyo | 10.25,8.125,4.75,4.375 | Koridordan |
| Depo | 8.5,10.625,1.75,1.875 | Pencere önünün doğusunda; penceresiz |

Pencereler ön dış duvar z12,5 üzerindedir: alt x5,9375/9,3125; üst x6,625. Perde aralığı dış çevreyi gösterir; jaluzi yalnız üst bölümde. Yol/çit ve özgün çizimsel sokak fonu erişilemez dekor, açık dünya değildir. Binaların ve odaların fiziksel planı dış çevrenin bağımsız arka plan çiziminde bire bir modellenmiş sayılmaz.

Kapasite değişmedi: MisafirA2 + MisafirB2 + çok amaçlı2 =6 NPC; Daniel hariç. +2 yükseltme ilk sürüm kapsamı dışındadır. İzolasyon bir yetişkinin mevcut yatağını rezerv tutar; kapasiteyi sihirli biçimde artırmaz.

## 2026-11-17 — açık hol / sahanlık V5
Güncel HouseLayout dış kabuğu15×12.5m ve oda kimliklerini korur. Alt ana hol ve üst ana geçiş3.75m genişliktedir; I11'in1.65m daraltması uygulanmadı. Alt hol-giriş bağlantısında alçak başlık kaldırıldı; yalnız doğu askılık duvarı x8.875–10.25,z10.625 kalır.
Girişte üst kat döşemesinin FOYER_VOID=Rect2(5,10.625,3.5,1.875) alanı açıldı. Çift kat yüksekliğinde tavan yaklaşık6.4m; pencereler mevcut dış duvardadır. Üst koridor artık bu boşluğun kuzeyinde sonlanır; z10.625,x5–8.5 boyunca1.1m fiziksel korumalı, görsel olarak açık ahşap korkuluk vardır. Merdiven yan ve uç sahanlık korumaları da aynı açık korkuluk dilindedir. Her korkulukta sürekli axis-aligned fizik gövdesi ve ayrı ince görsel dikmeler bulunur.
Üst pencere önündeki artık döşemesiz alandan kitaplık/radyatör kaldırıldı; havada eşya yok. Mevcut alt pencere radyatörleri yerinde. Spawn(7.5,3.35,8.75) destekli zeminde kalır, ilk bakış180° ile pencereli galeriye dönüktür. Player sahnesi/kamera kontrol kodu değiştirilmedi; yalnız ana sahnenin instance dönüşü değişti. Oda kapıları, 2D bağlantılar, kapasite, yatak kimlikleri ve mevcut gece gözlem rotası noktaları korunur.
## HOUSE-REBUILD-002 / 2026-11-18 — yeni iki kat planı (önceki koordinatların yerini alır)
Dış kabuk15x12.5m ve kat aralığı3.3m korunur; iç duvarların/kapıların iki katta da yerleşimi yenidir. Merkezi merdiven Rect2(6.35,3.5,2.3,5.5); önceki doğu duvarındaki1.5m merdiven kaldırıldı.18basamak, yaklaşık18.3cm rıht ve30.6cm basış. İki tarafta eğimi izleyen güvenlik korkuluğu, kapalı çarpışmalı alt hacim var.

Alt giriş holü x4..11,z9..12.5:7m genişlik,3.5m derinlik. Merdiven ayağı doğrudan hole açılır. Batı ve doğu geçişleri x4..6.35 /8.65..11, z3.5..9;2.35m brüt, mobilya ana hat dışında. Kuzey bağlantısı x4..11,z2..3.5. Üstte aynı iki kanat ile güneyde tam genişlikte bağlantı; eski FOYER_VOID adı API uyumluluğu için kalsa da artık döşeme deliği değil. Tek kat boşluğu merkezi merdiven; galeri zemini fiziksel olarak destekli.

Alt kapılar: batı x4 üzerinde dining z3, living_room z7; kuzey z2 üzerinde kitchen x7.5; doğu x11 üzerinde pantry z2.75,utility z6,bathroom_ground z10.75. Üst kapılar: batı x4 üzerinde guest_b z3,guest_a z6,daniel_bedroom z10; kuzey z2 üzerinde isolation x7.5; doğu x11 üzerinde multipurpose z3,bathroom_upper z8.25,storage z11.5. Koridor kapıları1.05m. Ana giriş x7.5,z12.5; arka çıkış kimliği korunur. Ön cephede iki katta da perde/pencere vardır. Oda kimlikleri ve2D oda bağlantıları korunur.

Başlangıç üst güney bağlantısında(7.5,3.35,10.6). Normal kayıt şeması değişmez, oyuncu konumu zaten kaydedilmediğinden eski kayıtlar yeni destekli başlangıcı kullanır. Grafik yüzeyler graphic_v7: duvar, kapı/boya, krem tavan ve ahşap baskı dokuları; önceki V5 karakter referansının daha kuvvetli yorumu, nihai sanat kabulü henüz yok.
## SINGLE-STOREY-001 / 2026-11-18 — GEÇERLİ PLAN (eski iki kat planlarının yerini alır)
Tek kat15x12.5m; zemin0, kat/çatı yüksekliği3.3m, iç tavan3.1m. EskiSTAIRS/FOYER_VOID boş, VOIDS boş; üst kat üretilmez.
3D giriş x5..9,z10..12.5; ana hol x5..9,z5.5..10; köşe x5..9,z3..5.5; yatak koridoru x9..15,z3..5.5. Ana hol4m, yatak kanadı2.5m brüt. Spawn(7,0.05,11), kuzeye bakar. Ön kapı(7.5,0,12.5); pencere(6,1.6,12.5) ve doğu uçta(15,1.6,4.25).
Batı x0..5: servis z0..3; mutfak z3..8; oturma z8..12.5. Kuzey: izolasyon x5..9,z0..3; misafirA x9..12,z0..3; misafirB x12..15,z0..3. Güneydoğu: çok amaçlı x9..12,z5.5..9; banyo x12..15,z5.5..8; küçük dolap x12..15,z8..9; Daniel x9..15,z9..12.5.
Sekiz oda kapısı: living(x5,z10.2), kitchen(x5,z6.5), isolation(x7,z3),guestA(x10.5,z3),guestB(x13.5,z3),multipurpose(x10.5,z5.5),bathroom(x13.5,z5.5),Daniel(x9,z10.75). Servis mutfaktan2Dbağlantıyla, çamaşır/depo dolabı banyodan2Dbağlantıyla açılır. Arkakapı servis duvarında(2.5,0,0), kilitli. Bu iki iç bağlantı ekstra ulaşılmaz koridor kapısı yaratmaz. Kapı açıklıkları1.05m.
Oda10işlevsel+4dolaşım; canonicalkimlikler living_room,kitchen,utility,isolation,guest_a,guest_b,multipurpose,bathroom_upper,storage,daniel_bedroom. bathroom_upper legacykimliği korunur ama kat0 ve görünen adıBanyo. dining→kitchen,pantry→utility,bathroom_ground→bathroom_upper; tek eşleme RoomAliases. YatakID/kapasite aynı.