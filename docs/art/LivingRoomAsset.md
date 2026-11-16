# Oturma odası arka planı — ART-ROOM-001

Tarih: 2026-11-16. Üreten: Codex, yerleşik image_gen aracı.
Durum: İlk oda görseli üretildi, projeye bağlandı ve gerçek oda ekranında görsel
kontrol yapıldı. Nihai sanat yönü onayı verilmiş sayılmaz.

## Amaç

assets/rooms/living_room.png yolundan mevcut RoomView tarafından yüklenen,
insan içermeyen 2D oda. Arka plan tek görüntü; karakterler ayrı katman.
Oyun kodu, gün akışı ve diğer asistanın dosyaları değiştirilmez.

## Üretim şartnamesi

- Hedef oran 16:9, hedef çözünürlük 1920×1080; gerçek üretim çıktısı 1672×941.
  Kaynak yapay olarak büyütülmedi. Oyun önizlemesi 1920×1080 alındı.
- Göz hizasında kapı eşiğinden bakış; olağan bir evin oturma odası.
- Sade kirli sarı duvar, nötr tavan, kahverengi ahşap, bordo halı, koyu turkuaz döşeme.
- Perde aralığından gelen nötr soğuk gün ışığı, zayıf sıcak lamba, hafif pus.
- Yüksek çözünürlüklü, pürüzsüz boyanmış yüzeyler; piksel/PS1 görünümü yok.
- Koltuk, CRT televizyon, radyo, küçük sehpa; orta ön alan karakterler için açık.
- İnsan, siluet, yazı, logo, arayüz veya enfeksiyon ipucu yok.
- Başlık için üstte, eylem/metin paneli için altta görsel sakin alan.

Palet referansı mevcut docs/screenshots/03_hall_table_lamp.png dosyasıdır.
Bu referansın kutulu eşyaları, koridor düzeni ve arayüzü kopyalanmaz.
Başka oyunun sahnesi yeniden üretilmez.

## Önizleme

scenes/dev/room_art_preview.tscn mevcut RoomView ile yalnızca bu odayı açar.
Yeni kampanya başlatmaz veya oyun kaydı yazmaz. Şu seçenekle ekran görüntüsü alır:

```
godot --path . --resolution 1920x1080 res://scenes/dev/room_art_preview.tscn -- --capture-room-art
```

Çıktı: docs/art/previews/living_room_in_game.png.
Önizlemede oyun eylemlerinin eksik olması normaldir; yönetici bağlanmaz, yalnızca
görselin ve mevcut oda arayüzünün birlikte okunabilirliği kontrol edilir.
Kampanyada mevcut CampaignDirector aynı arka planla normal şekilde çalışır.

## Katman sınırı

CRT, perde ve lamba şu aşamada görüntüye boyanmış sabit eşyalardır. Yayın metni
eylem panelinde gösterilir. Bu resim televizyon ekranının hareket ettiğini, gece
sürümünün hazır olduğunu veya pencerenin etkileşimli olduğunu göstermez.
Gece/elektriksiz varyantlar ayrı görsel veya kontrollü ışık katmanı gerektirir.

## Tam istem

LivingRoomPrompt.txt aynı üretimde kullanılan İngilizce istemi aynen saklar.
LivingRoomCorrection.txt, ilk çıktıda plana aykırı eklenen oda içi merdivenin
kaldırılması için kullanılan tek düzeltme istemidir. İlk çıktı kullanılmaz.

## Doğrulama sonucu

- Claude'un değişmekte olan Gün 2 dosyalarını içermeyen son commit kopyasında
  yeni PNG ve önizleme sahnesi içe aktarıldı.
- Godot 4.7.2 Forward+ / GTX 1080 Ti gerçek penceresinde 1920×1080 render alındı.
- ROOM ART PREVIEW: SAVED; çıkış kodu 0. Ekran görüntüsü açılıp incelendi.
- Yer tutucu yazısı yok; arka plan RoomView tarafından yüklendi. Başlık ve dönüş
  yazısı okunuyor; figür katmanı için orta alan boş. İlk merdiven hatası giderildi.
- Kampanya akışı bu sanat görevinde yeniden test edilmedi; Gün 2 aktif geliştirme altında.
- Gece/elektriksiz varyant yok, CRT animasyonu yok. Mevcut görüntü gündüz sanat adayıdır.
