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
