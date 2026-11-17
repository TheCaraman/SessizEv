# THE QUIET HOURS

Birinci şahıs psikolojik korku oyunu. 3D koridorlar, katmanlı 2D odalar. Çalışma adı.

Ortak asistan çalışması için önce `AGENTS.md` ve `docs/coordination/STATUS.md` oku.
Görev paylaşımı `docs/coordination/TASKS.md`, teslim kayıtları `HANDOFF.md` içindedir.
Yerel Git ve aktarım adımları `docs/coordination/GIT_WORKFLOW.md` dosyasındadır.

## Durum

Gün 1–3 ve Gün4 inceleme/karar akışı oynanabilir dikey kesit. Koridorlar 3D ve yürünür; odalar kapıdan açılan
2D sahnelerdir. F5 ana menüyü açar; yeni oyun ve kayıttan devam vardır.

Windows'ta editörü açmadan: `OYUNU_AC.cmd` normal kampanyayı, `NOBETI_DENE.cmd`
ayrı proje/kayıt alanında taze Gün 3 20:00 denemesini başlatır. İkisi de eşleşen
Godot 4.7.2 motorunu ve varlık içe aktarımını kontrol eder. Bu başlatıcılar bağımsız
Windows export/build değildir; kurulu geliştirme motorunu kullanır.

Gün 1: televizyon/radyo, erzak kontrolü ve Elena'nın kabul/ret kararı. Gün 2:
Marcus/Arthur ziyaretleri, yatak ve iş atama. Gün 3: 23:00 elektrik kesintisi,
gerçek nedene uygun kanıtlar, onarım veya erteleme, Tab ile günlük. Kesinti ilk
uykuyu böler; sonraki uyku Gün 4 sabahına götürür. Gün 3 20:00–23:00'te uyanık
kalma seçilirse 01/03/05/07 bekleme, gece araştırması, kalan geceyi uyuma ve enerji
hesabı devreye girer. Boru sesi araştırılabilir masum bir olaydır; enfekte fail
uydurmaz. Kayıt v5 gece yarısını ve tek sabah tüketimini korur. Hikâye içeriği Gün 4
sabahında inceleme/karar akışına geçer. Gün4 için ilk kanıt incelemesi, kovma/izolasyon ve uygun yeni gecede gerçek harekete dayanan çelişkili ifadeler vardır; tam Gün4 senaryosu henüz tamamlanmadı. İncelemeden sonra ücretsiz erteleme, 20:00 saatine onaylı bekleme ve kayıtlı kapanış özeti vardır. Kapanıştan sonra keşif/kararlar devam eder; Gün5 açılmaz. Üç yetişkine ayrı suçlama ekranında toplanmış kayıtlarla veya boş dayanakla suçlama yöneltilebilir. Genel elektrik bulgusu kişiyi belirlemez; gerçek tanık iddiası da enfeksiyon kanıtı değildir.
Kaynak yetmezse onarım ertelenebilir; ilerleme tek bir NPC'ye bağlı değildir.

13 oda arka planı ve Elena/Marcus/Arthur figürleri var. Yalnızca varsayılan
pozlar mevcut. Oturma odası sahibin onayladığı sade çizimsel yönde; ayrı TV/radyo
katmanı ve gündüz/gece/kesinti görselleri var. Diğer12 oda da çizimsel yönde yeniden üretildi; nihai estetik kabul açık. Üç karakterin varsayılan figürleri eski geçici üsluptadır. Kapı/boru sesleri sentezlenmiş geçiciler; müzik, konuşma kayıtları,
nihai animasyon/ses ve bütün gecelerin olay bankası yok. 3D koridorun HOUSE-ATMOS-004 revizyonu aktif denemede; sahibin nihai görsel kabulü açık.

Kontroller: WASD yürüme, fare bakış, Shift hızlı yürüme, E etkileşim;
E/Esc odadan koridora dönüş, Tab günlük, koridorda Esc duraklatma menüsü.
Barınak yönetimi ve manuel kayıt Daniel'ın odasındaki eylemlerden açılır.
Ana menüden English/Türkçe seçilir. Ana/pause ayarlarında parlaklık, fare hassasiyeti, FOV ve ana ses düzeyi vardır; tercihler kampanyadan ayrı saklanır.

Fare/klavye ile baştan sona elle oynama henüz doğrulanmadı; otomatik pencere erişimi
reddedildi. Programatik testler ve gerçek motor renderları bu kontrolün yerine geçmez.

Kalıcı kurulumda proje klasörünün yanındaki tools/godot-4.7.2 motoru kullanılır.
Kaynak ve sanat/günlük/test kayıtları Git'tedir. Otomasyonun dış kuyruk ve çalışma
durumu bir üst klasördeki queue.json, runtime/ ve DURUM.txt içindedir.

Tüm testleri ayrı proje/kayıt alanında çalıştırmak (Windows PowerShell):

```powershell
powershell -NoProfile -File tools/Run-Tests.ps1 -GodotPath "C:\path\Godot_v4.7.2-stable_win64_console.exe" -AudioDriver WASAPI
```

Tek tek otomatik testler (kampanya testi kullanıcı verisine kayıt yazabilir):

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

Beklenen: sabah üst kat koridorunda başlarsın; saat, oda kapıları ve Gün 1 akışı çalışır.

## Belgeler

- `docs/DecisionLog.md` — kararlar, varsayımlar, açık konular
- `docs/GDD.md` — oyun tasarımı
- `docs/NarrativeBible.md` — hikâye ve kadro
- `docs/TechnicalDesign.md` — mimari ve veri şemaları
- `docs/ArtBible.md` — görsel yön
- `docs/ProductionPlan.md` — fazlar, riskler, ses ve kalite özeti

Gün4 radyo: pilli kanalda belirsiz tahliye duyurusu, ilk15dk ve sonra ücretsiz not; kaçırılan hafıza kaybı uyarısı alternatif yoldan korunur. Yeni radyo seslendirmesi yok. QA: docs/qa/Day4Broadcast.md.
