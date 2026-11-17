# Saf oda tercihi değerlendiricisi — AUTO-ROOMS-EVALUATOR

17 Kasım 2026, Codex; taban `d0a6199`, dal `auto/auto-rooms-evaluator-1794897837`.
Görev tamamlandı; bu teslim yalnız saf kod, sentetik testler ve bu belgedir.
UI, oyun, save ve ARRIVALS entegrasyonu **yapılmadı**. Yeni autoload,
kanonik tercih, diyalog, ceza, otomatik atama veya taşıma yoktur.

## Çağrı sözleşmesi

`RoomPreferences.evaluate(old_plan, proposed_plan, participants, bed_rooms,
preferences, ready_content, open_conditions) -> Dictionary` statiktir;
`RefCounted` sınıfı sahne veya editör adımı gerektirmez.

- Planlar mevcut `ShelterManager.get_current_plan()` biçimindedir:
  `beds: {npc_id: bed_id}`, isteğe bağlı `jobs: {npc_id: job_id}`.
- `participants` roster kimliğinden açık durum sözlüğüne eşlemedir. `status`
  zorunludur; `resident`, `unknown`, `rejected`, `left`, `expelled`, `dead`,
  `isolated`, `absent` kabul edilir. İsteğe bağlı `isolated`, `absent`, `alive`
  boolean olmalıdır. Yalnız resident, izole/yok olmayan, canlı kişi uygundur.
  Çağıran bütün roster kimliklerini ve iki plandaki bütün sakinleri vermelidir.
- `bed_rooms: {bed_id: room_id}` çağıranın mevcut BEDS/bed_room API'sinden
  oluşturacağı uyuma odası eşlemesidir; anlık iş konumu kullanılmaz.
- Tercih alanları tasarım belgesindeki `id`, `speaker_id`, `target_id`, `kind`,
  `requires_content`, `source_ref`, `request_key`, `objection_key` alanlarıdır.
  `requires_content` string kimlik dizisidir (boş olabilir); diğerleri boş
  olmayan String olmalıdır. İsteğe bağlı `condition_id` boş String olabilir.
  İki taraf roster içinde ve farklı olmalıdır; tercih kimlikleri benzersizdir.
- `ready_content: {id_or_text_key: bool}` içinde gerekli her içerik ve iki
  metin anahtarı açıkça true olmalıdır. Metin anahtarının true olması çağıranın
  EN/TR metinleri ve yer tutucularını doğruladığını bildirir; bu saf modül
  yerelleştirme dosyası okumaz. Kaynak dayanağının gerçek/yazarlı olması da
  içerik hazırlama sorumluluğudur. `source_ref` boş bırakılamaz.
- `open_conditions: {condition_id: bool}` yalnız kayıtlı açık olay olgularını
  içerir. Koşul kimliği verilmişse açık true gerekir. Gizli teşhis/enfeksiyon
  koşulu buraya aktarılmamalıdır. Modül seed/enfeksiyon alanı okumaz.

## Sonuç ve hata sözleşmesi

Başarılı çağrı `{ok: true, error: "", physical_plan_validated: false, results: [...]}`
döndürür. Bu yalnız girdilerin sosyal incelemeye uygun olduğunu belirtir;
**plan uygulama onayı değildir**. `ShelterManager.check_plan()` kapasite,
aynı yatağı paylaşma, izolasyon rezervi/taşıma ve iş uygunluğunun tek fiziksel
doğrulayıcısı olarak kalır. Değerlendirici paralel yatak yöneticisi değildir;
`physical_plan_validated` hiçbir çağrıda true dönmez.

Bozuk kayıtta `{ok: false, error: <teknik kod>, physical_plan_validated: false,
results: []}` döner; kısmi sosyal sonuç veya sessiz onay verilmez. Çağıran bu
durumda incelemeyi/uygulamayı durdurmalıdır. Kodlar `INVALID_READINESS`,
`INVALID_BED_ROOMS`, `INVALID_PARTICIPANT`, `INVALID_STATUS`,
`INVALID_PARTICIPANT_FLAG`, `INVALID_PLAN_BEDS`, `INVALID_PLAN_BED`,
`MISSING_BED`, `INVALID_PLAN_JOBS`, `INVALID_PLAN_JOB`, `INVALID_PREFERENCE`,
`INVALID_PREFERENCE_FIELD`, `DUPLICATE_PREFERENCE_ID`, `INVALID_KIND`,
`INVALID_PREFERENCE_PARTICIPANT`, `INVALID_REQUIRED_CONTENT`, `INVALID_CONDITION`.
Teknik kodlar oyun metni değildir. Fonksiyonun Dictionary/Array tipli üst düzey
parametreleri GDScript çağrı sınırında tip denetimine tabidir; iç içe bozuk
değerler yukarıdaki hata sonucunu üretir. Tüm tercihler, etkinlik filtresinden
önce doğrulanır; hazır olmayan bozuk içerik de hata verir. Geçerli fakat eksik
hazır içerik/koşul ise normal olarak etkinleşmez.

Sonuç satırı tercih kimliği, konuşan/hedef, tür, iki kişinin eski/yeni uyuma
odası, `old_satisfied`, `satisfied`, `key` ve kimlik argümanlarını taşır.
Anahtar karşılanmada `request_key`, itirazda `objection_key` olur. Argümanlar
`speaker_id`/`target_id` kimlikleridir; gelecek sunum katmanı bunları yazarlı
metnin yer tutucularına dönüştürmelidir. Ham kimlikler oyuncuya basılmaz.

Sıra `speaker_id`, ardından `id` şeklindedir. İstek karşılıklı türetilmez;
çelişen istekler korunur. Yalnız karşılanma sonucu değişen tercihler döner.
İki kişi farklı odalara taşınıp aynı eski uyumu/itirazı korursa yeni olay yoktur.
Aynı oda yatak takası, yalnız iş değişimi ve aynı plan boş sonuç verir.
Girdi sözlükleri, diziler ve GameState değiştirilmez; çıktı girdi konteyneri
paylaşmaz. Dünya/seed/enfeksiyon, dosya sistemi ve global API çağrısı yoktur.

## Doğrulama ve devir

Mevcut `tests/shelter_test.gd` testleri korunarak başına saf sentetik tercih
testleri eklendi: paylaş/ayrı kal, tek yönlü çatışma, sıra, değişmeyen sonuç,
yatak takası, iş değişimi, her iki tarafta uygunsuz durumlar/bayraklar, eksik
içerik/metin/koşul, bozuk tip/kimlik/tekrar/eksik yatak, girdi ve global durum
mutasyonu, farklı seed/enfeksiyon ek alanlarıyla aynı sonuç.

`git diff --check` çıkış kodu 0 ile geçti. Çalışma ağacında yalnız izinli
değerlendirici, shelter testi ve bu QA belgesi değişmiştir.
Godot ve Run-Tests **çalıştırılmadı**; kullanıcı Godot testlerini dış yöneticiye
ayırdı. Motor derleme/PASS iddiası yoktur. Dış test komutu:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run-Tests.ps1 -GodotPath "C:\Users\eyups\OneDrive\Belgeler\TheQuietHours\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe"
```

AGENTS, CLAUDE, STATUS, DecisionLog, coordination TASKS/HANDOFF, claim dosyaları
ve mesajlar okundu. Okuma onayı: 20261116 Claude ACK, bodycam-plan,
gallery, house-scale mesajları ve 20261117 oda/geliş onayı bu görevde incelendi.
Kök TASKS/HANDOFF yoktur; belgeler coordination altındadır. İzinli dosya sınırı
nedeniyle supervisor/görev/ayrı ACK dosyalarına yazılmadı; görev kaydı ve devir
bu belgeyle sınırlıdır. Manuel Claude alanı ve başlatıcı korunmuştur.
Sonraki adım dış motor test kapısıdır; UI/kayıt entegrasyonu ayrı görevdir.
