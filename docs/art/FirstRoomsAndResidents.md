# İlk odalar ve sakinler — sanat üretim kaydı

Üslup: ART-001, mevcut living_room.png. Kod görevi ayrı worktree'de ilerliyor.
Bu dal sanat varlıkları ve yalnızca bağımsız sanat önizlemesiyle sınırlıdır.
Görsel kontrolde yeni figürün oda merkezinde havada kaldığı görüldü; bu yüzden
RoomView'in yalnızca figür çizimi ve sahneleme çapaları da bu dalda düzeltildi.
Yeni scripts/art/room_figure.gd kişi sayısı veya resim oranı değişse de ayakları
aynı zemin çizgisine hizalar; genişliği yuvaya uydurur. Backend ile birleştirmede
RoomView'deki güç/günlük değişiklikleri korunacak.
Konuşma ekranında aynı tam boy dosyanın üst %62'si kullanılır; bacaklar cevap
panelinin arkasında kalır ve küçük tam boy figürün havada durması önlenir.
Kaynak PNG kırpılmadı; AtlasTexture yalnızca arayüzün görüntüleme penceresidir.

## Üretim kuralları

- Yeni arka planlar oturma odasıyla aynı boyanmış gerçekçilikte. Piksel/PS1 yok.
- Odalarda insan/siluet yok; başlık ve alt anlatı paneli için sade alan korunur.
- Bütün odalar aynı sarıya boyanmaz; aynı malzemeler ve dengeli palet paylaşılır.
- Pencereler yalnızca dış duvara bakan odalarda. Merdiven oda içine eklenmez.
- Yatak sayısı: Daniel odası tek çift kişilik yatak; guest_a, guest_b ve
  multipurpose ikişer ayrı tek kişilik yatak. Kapasite kodda ayrıca sınanır.
- Karakterler saydam PNG, tam boy, tek figür; enfeksiyon görünüşten anlaşılmaz.
- Kamera göz hizasında; insanlar evin ölçeğiyle uyumlu olmalı.

## Karakter görünüş varsayımları

Elena: 35; alçak toplanmış koyu kahverengi saç, sade mavi-gri hırka, krem bluz,
koyu pantolon, kahverengi düz ayakkabı. Sakin ve yorgun; tıbbi üniforma yok.
Marcus: 47; kısa kırlaşmış saç, hafif sakal, yıpranmış iş gömleği, koyu iş pantolonu.
Arthur: 61; ince yapılı, kırlaşmış saç, gözlük, sıradan örme hırka ve kumaş pantolon.
Bunlar küçük görsel üretim varsayımlarıdır, gizli hikâye olgusu veya teşhis işareti değildir.

## Durum

13 odanın tamamı ve ilk üç sakin için gerçek PNG kaynakları var. living_room önceki
teslimden; kalan 12 oda ve 3 figür bu teslimde üretildi. Hepsi yerleşik image_gen
ile üretildi; her istem prompts/ altında aynen kayıtlıdır. Dışarıdan sanat paketi alınmadı.

Oda kaynakları 1672×941, karakterler 1024×1536. 16 dosyanın ölçüleri ve SHA256
değerleri asset_manifest.json içinde. Karakterlerin dört köşesi alpha=0 olarak
ölçüldü; saydam görüntü dosyası doğrulandı. Oda kaynakları pikselleştirilmedi.

Godot 4.7.2 Forward+ ile gerçek 1920×1080 oda/konuşma önizlemeleri alındı.
Önizleme sahneleri oda dosyası yoksa yer tutucuyla sessizce geçmek yerine hata verir.
Görsel kontrolde eski figür yerleşiminin havada durduğu görüldü ve zemin hizası
düzeltildi; tam boy figürün diyalog üstünde yüzmesinin yerine bel üstü kadraj kondu.
İlk sekiz regresyon paketi bu arayüz değişiklikleriyle geçti: 1524 denetim.
Gün 3 koduyla birleşik son ağaç ayrıca test edilecek; bu sonuç Gün 3 testi değildir.

Depo kullanıcının talebine göre penceresizdir. İzolasyon odası henüz yatak içermez;
misafir odaları ve çok amaçlı odadaki ikişer yatak ilk altı NPC kapasitesiyle tutarlıdır.
Tesisat görselinde pano kapalıdır; nedenlere özgü alet izi veya hasar resme işlenmedi.
Kilerdeki kutu ve kavanozlar dekoratif temsildir; tek tek kaynak sayısı göstermez.

Gece/elektriksiz varyantlar bu dosyaların tamamlanmasıyla otomatik var olmaz.
Karakter animasyonu, yüz ifadesi ve kesin nihai sanat onayı bu teslimin kapsamı değildir.
