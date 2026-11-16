# THE QUIET HOURS

Birinci şahıs, tam 3D psikolojik korku oyunu. Çalışma adı.

## Durum

Faz 1.4 tamam — birinci şahıs kontrolcü ve iki katlı evin blockout'u çalışıyor. F5 evi açar; giriş holünde başlarsın. Kapı, pencere, mobilya ve oyun içeriği henüz yok.

Kontroller: WASD yürüme, fare bakış, Shift hızlı yürüme, Esc fareyi bırakır ya da geri alır.

Otomatik testler:

```
godot --headless --path . res://tests/player_movement_test.tscn
godot --headless --path . res://tests/house_layout_test.tscn
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
