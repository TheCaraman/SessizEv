# Otomatik koordinasyon — AUTO-ROOMS-EVALUATOR / review

2026-11-17T06:48:48.958264+00:00

claude: approved

İnceleme salt okunurdu: Read/Glob/Grep kullandım, dosya yazmadım, test çalıştırmadım. Godot test kapısını dış yönetici çalıştıracak.

**Kapsam:** Değişiklik yalnız izinli yollarda: `scripts/shelter/room_preferences.gd` (yeni), `tests/shelter_test.gd` (değişti), `docs/qa/RoomPreferencesEvaluator.md` (yeni). Yeni autoload, veri dosyası, diyalog, güven cezası, UI, save veya ARRIVALS entegrasyonu yok. Değerlendirici `GameState`, `ShelterManager`, seed ya da dosya sistemi çağırmıyor. Ayrı bir yatak yöneticisi de kurmuyor: `physical_plan_validated` her zaman false dönüyor ve belge fiziksel doğrulamayı `ShelterManager.check_plan()` görevine bırakıyor (bu fonksiyonun var olduğunu doğruladım).

**Kanonla uyum (`docs/design/RoomPreferences.md`):**
- Yalnız `share_with` ve `avoid_with` destekleniyor. Uyum yatağın odası (`bed_rooms`) üzerinden ölçülüyor.
- İstekler tek yönlü kalıyor, karşılıklı istek türetilmiyor. Çelişen isteklerin hepsi sonuçta yer alıyor; kazanan seçilmiyor.
- Sıralama önce `speaker_id`, sonra `id`.
- Yalnız karşılanma durumu değişen tercihler sonuç veriyor. Bu yüzden aynı oda içinde yatak takası, yalnız iş değişimi, aynı planın tekrarı ve "iki taraf da oda değiştirdi ama eski itiraz aynı kaldı" durumu boş sonuç veriyor.
- Uygunluk kuralı: yalnız `status == "resident"` olan, `isolated` ve `absent` bayrakları olmayan ve `alive` değeri false olmayan kişi katılabiliyor. Bu, gerçek GameState'teki `isolated` bayrak modeliyle uyumlu.
- Eksik içerik, eksik metin anahtarı veya kayıtlı olmayan koşul tercihi etkinleştirmiyor.

**Bozuk veri:** Bütün tercihler etkinlik filtresinden önce doğrulanıyor. Hatalı tip, boş veya bilinmeyen kimlik, kişinin kendine yaptığı istek, tekrar eden `id`, bilinmeyen tür, sakin için eksik veya bilinmeyen yatak, bool olmayan hazırlık ya da koşul değeri `ok:false` ile reddediliyor; bu durumda sonuç listesi boş dönüyor. Hata sözleşmesi ve hata kodları QA belgesine yazılmış. Girdiler okunuyor ama değiştirilmiyor; çıktı yeni sözlüklerden oluşuyor.

**Testler:** `shelter_test.gd` dosyasında eski 24 `check` aynen duruyor. Yeni `_test_room_preferences` görevde istenen bütün vakaları sentetik veriyle kapsıyor. Kontrol ettiğim sözdizimi geçerli GDScript 4 görünüyor: `not x is T` önceliği, `not in`, tipli lambda ile `sort_custom` ve preload edilmiş betik üzerinden statik çağrı. Ama motorda derlenmedi.

**QA belgesi:** UI entegrasyonunun yapılmadığını ve Godot/Run-Tests'in çalıştırılmadığını dürüstçe söylüyor; PASS iddiası yok.

**Engelleyici olmayan küçük notlar:**
1. `room_preferences.gd.uid` henüz oluşturulmamış. Diğer shelter betiklerinin `.uid` dosyası var; Godot bunu içe aktarmada oluşturacak ve izinli yollarda zaten yer alıyor.
2. Uygunsuz katılımcı, bayrak ve eksik içerik testleri yalnız `results.is_empty()` kontrol ediyor, `ok == true` kontrol etmiyor. Teorik olarak bir hata dönüşü de bu testleri geçirebilir; şu anki kodda böyle bir yol yok.
3. Tasarım belgesi eksik metin anahtarını geliştirme doğrulamasında "hata" sayıyor. Uygulama ise bunu, göreve uygun olarak, "hazır değil, etkinleşmez" diye ele alıyor. Metinlerin varlığını çağıran tarafın doğrulaması gerektiği belgede yazıyor.

Kaynak: runtime/continuous/state.json. Bu CLI çalışanı çıktısıdır; masaüstü sohbet ACK'i değildir.
