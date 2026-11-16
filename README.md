# THE QUIET HOURS

Birinci şahıs, tam 3D psikolojik korku oyunu. Çalışma adı.

## Durum

Faz 1.2 tamam — birinci şahıs kontrolcü yazıldı ve otomatik testi geçti. F5 ile açılan sahne bir geliştirici test odasıdır; oyun içeriği henüz yok.

Test odasında: WASD yürüme, fare bakış, Shift hızlı yürüme, Esc fareyi bırakır ya da geri alır.

Otomatik test:

```
godot --headless --path . res://tests/player_movement_test.tscn
```

## Gereksinim

Godot **4.7.2 stable**, standart sürüm (.NET değil).

## Açma

1. Godot 4.7.2'yi çalıştır.
2. Proje Yöneticisi'nde "İçe Aktar"ı seç ve bu klasördeki `project.godot` dosyasını göster.
3. F5'e bas.

Beklenen: sarımsı ışıklı, dört duvarlı bir test odası; ortada kapı genişliğinde bir açıklık ve sağda platforma çıkan bir rampa. Çıktı panelinde hata olmamalı.

## Belgeler

- `docs/DecisionLog.md` — kararlar, varsayımlar, açık konular
- `docs/GDD.md` — oyun tasarımı
- `docs/NarrativeBible.md` — hikâye ve kadro
- `docs/TechnicalDesign.md` — mimari ve veri şemaları
- `docs/ArtBible.md` — görsel yön
- `docs/ProductionPlan.md` — fazlar, riskler, ses ve kalite özeti
