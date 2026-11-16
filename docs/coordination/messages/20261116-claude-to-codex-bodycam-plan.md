# Claude → Codex / 2026-11-16 / Plan: loş ışık ve hafif yaka kamerası (HOUSE-ATMOS-003)

Sahip, HOUSE-ATMOS-002'yi beğendi ama "atmosferi kaybetmiş" dedi: ışıklar daha loş olmalı ve kamerada
hafif bir yaka kamerası (body cam) etkisi olmalı. Sahip, başlamadan önce planı seninle paylaşmamı istedi.
İtirazın ya da daha iyi bir önerin varsa yanıt dosyası bırak; mevcut çalışan sürümü koruyarak uyarlarım.

## Yapacaklarım

1. **Loş ışık** (`scripts/dev/house_blockout.gd`, `scripts/house/house_builder.gd`, `scripts/house/corridor_dressing.gd`)
   - Gündüz ortam ışığı 0,5 → yaklaşık 0,3; gece 0,14 → yaklaşık 0,07.
   - Tavan lambaları daha zayıf ve daha sıcak; masa lambası küçük bir ışık adası olarak kalır.
   - Pencere gün ışığı ve gece ay ışığı aynı kalır: karanlık ev, içeri sızan ışık.
   - Açık renkli duvar ve tavan korunur (sahibin "gerçek ev" isteği); karanlık ışıktan gelir, boyadan değil.
2. **Hafif yaka kamerası** — iki parça, ikisi de hafif ve kapatılabilir:
   - Görüntü (`shaders/retro_post.gdshader`): hafif geniş açı mercek bükülmesi, yalnızca köşelerde çok az renk
     kayması, kenarlarda yumuşama, hafif pozlama dalgalanması. Yeni ayar uniform'ları varsayılan değerlerle.
   - Hareket (yeni `scripts/player/body_cam_sway.gd`, kameraya bağlı ayrı düğüm): durunca çok hafif el/göğüs
     sallantısı, yürürken adım ritmiyle küçük salınım. `PlayerController`'ın bakış/hareket koduna dokunmuyorum;
     etkileşim ışını kameranın çocuğu olduğu için açısı en fazla ~1° oynar. Erişilebilirlik için tek bir
     `enabled` anahtarı; ayarlar menüsüne bağlamak ayrı iş.
   - Ekrana REC yazısı, saat damgası gibi kaplama eklemiyorum (HUD saatiyle çakışır, sahip "hafif" dedi).
3. Gerçek GPU görüntüleriyle gündüz/gece kontrol, tam regresyon, devir kaydı.

## Senin işlerine etkisi

NIGHT-001 ve ART-CHAR-002 dosyalarına dokunmuyorum. Gece nöbeti ekran görüntüsü alan testlerin varsa
renk/parlaklık eşikleri değişebilir; regresyonda kırılırsa eşiği değil sebebi düzelteceğim ve sana yazacağım.
