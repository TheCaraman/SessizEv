# Claude → Codex: IMMERSION I-10 yaşanmışlık dekoru (inceleme için)

Tarih: 2026-11-17. Sahip: "gpt ile senkron ol ve devam et". Senden yanıt yoktu; I-10'u ImmersionBatchReview
§I-10 AGREE kapsamında aldım (claim: IMMERSION-I10-DECOR.md). Ev 3D dosyalarında açık Codex işi yoktu
(1830de6 zaten 0.1.14'te).

Dal: `claude/decor` (workers/claude-decor), taban 930b8c1 = claude/peephole-continue (porch + peephole üstüne yığılı).
Birleştirme sırası: claude/porch-street → claude/peephole-continue → claude/decor.

## Değişiklik
- `corridor_dressing.gd`: yalnız yeni `_build_lived_in()` (LivedIn düğümü). Var olan eşyalar/ışıklar değişmedi.
  - Zemin: hol arka köşesinde büyük saksı; mutfak duvarında 3 küçük fotoğraf; natürmortun altında sardunyalı
    saksı sehpası (tek katı gövde: PlantStand); doğu ön pencere yanında ikinci saksı.
  - Üst: sahanlık sürahisinde kuru çiçek; alçak kitaplıkta 2 ayaklı fotoğraf; yatak odası ucu lambasının yanında
    1 ayaklı fotoğraf; pencere köşesinde saksı.
- `prop_meshes.gd`: `photo_frame`, `standing_photo`, `potted_plant`, `flowers` (yalnız primitifler).
- `texture_generator.gd` + `scenes/dev/generate_photos.tscn`: `photo_garden`, `photo_seaside`
  (soluk baskı; insanlar küçük, arkadan, isimsiz — yeni akraba/olay icat edilmedi). Dokular izole kopyada
  üretildi; `house_materials.gd` iki türü tanıyor.
- `tests/decor_test.gd` (+ Run-Tests listesi): eşyalar var, fotoğraflar gerçek doku kullanıyor, tek katı gövde
  PlantStand, hiçbir I-10 parçası hol/giriş/sahanlık/üst koridor yürüme şeritlerine girmiyor.

Dokunulmayan: house_builder.gd, house_layout.gd, ışık grupları ve değerleri, house_blockout.gd.

## Doğrulama
Commit 90475fa. İzole tam paket `-AudioDriver WASAPI`: 35 paket PASS (DECOR 8, PORCH 12, PEEPHOLE 31, STAIRS 30, ROOM LIGHTING 150).
GPU görüntüleri: `docs/qa/decor/decor-*.png` (hol gündüz/gece, saksı sehpası, giriş, üst kitaplık, sahanlık gece).
Deneme başlatıcısı `E:TheQuietHoursDENE_KAPI_DELIGI.cmd` artık claude/decor dalını açıyor (PrepareOnly geçti).

## Senden istenen
1. İnceleme; kabul edersen resmî sürüme al (önce porch + peephole).
2. Fotoğraf yerleri/yoğunluğu sahibin görsel kabulüne bağlı; çok gelirse `_build_lived_in()` satır satır kısaltılabilir.
