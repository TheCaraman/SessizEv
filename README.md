# THE QUIET HOURS

Birinci şahıs, tam 3D psikolojik korku oyunu. Çalışma adı.

## Durum

Gün 1 baştan sona oynanıyor. Koridorlar 3D ve yürünür; odalar kapıdan açılan 2D sahnelerdir. F5 ile başlarsın: üst kat koridorunda, sabah 07:00.

Gün 1'de yapılabilecekler: oturma odasında televizyon ve radyo, kilerde erzak sayımı, Daniel'ın odasında dinlenme. Saat 18:00'i geçince biri ön kapıyı çalar; kapıya gidip E ile aç, konuş, içeri al ya da reddet. 20:00'den sonra Daniel'ın odasında uyuyup 2. güne geçersin. İçerik şimdilik 2. günün sabahında biter.

Oda ve karakter görselleri henüz yer tutucudur; ses yok.

Kontroller: WASD yürüme, fare bakış, Shift hızlı yürüme, E kapıyı kullanır, E ya da Esc odadan koridora döner. Koridorda Esc fareyi bırakır ya da geri alır.

Otomatik testler:

```
godot --headless --path . res://tests/player_movement_test.tscn
godot --headless --path . res://tests/house_layout_test.tscn
godot --headless --path . res://tests/interaction_test.tscn
godot --headless --path . res://tests/campaign_test.tscn
```

Ekran görüntülerini yenilemek (pencere açar):

```
godot --path . --resolution 1280x720 res://scenes/main/capture_screenshots.tscn
```

## Gereksinim

Godot **4.7.2 stable**, standart sürüm (.NET değil).

## Açma

1. Godot 4.7.2'yi çalıştır.
2. Proje Yöneticisi'nde "İçe Aktar"ı seç ve bu klasördeki `project.godot` dosyasını göster.
3. F5'e bas.

Beklenen: sarımsı ışıklı, düz renkli duvarlardan oluşan ev; önünde hole açılan bir geçit. Oda değiştirdikçe çıktı panelinde odanın adı yazılır. Hata olmamalı.

## Belgeler

- `docs/DecisionLog.md` — kararlar, varsayımlar, açık konular
- `docs/GDD.md` — oyun tasarımı
- `docs/NarrativeBible.md` — hikâye ve kadro
- `docs/TechnicalDesign.md` — mimari ve veri şemaları
- `docs/ArtBible.md` — görsel yön
- `docs/ProductionPlan.md` — fazlar, riskler, ses ve kalite özeti
