# Birleşik ARRIVALS + ROOMS zinciri — AUTO-ARRIVALS-CHAIN QA

2026-11-17 — Claude (gözetimsiz worker). Taban `ad6d7bd` (ARRIVALS `a5043bf` + ROOMS `06d4e92` birleşik).
Oyun kodu, veri, diyalog, yerelleştirme ve hikâye değişmedi. Yalnız şu üç dosya değişti:

- `tests/arrival_integration_test.gd` — mevcut 22 kontrol aynen duruyor; sonuna üç dallı G3→G4 zinciri eklendi.
- `tools/Run-Tests.ps1` — isteğe bağlı `-SelectedTests` parametresi.
- `docs/qa/CombinedArrivals.md` — bu belge.

## Zincir testi ne yapıyor

Önce mevcut bölüm koşar (G2'de Marcus yok, G3 vuruşu, kapıda kaydet/yükle, takvim sahteciliği reddi, v5 göçü).
Onun `CampaignDirector`/`DialogueRunner` düğümleri serbest bırakılır. Böylece kapıyı ve saati tek bir yönetici dinler.

Sonra `_find_chain_seed()` 0–3999 arasında Marcus'u **G3'e**, Arthur'u **G2'ye** koyan ilk seed'i arar. Böylece
G3'te kapıda tek kişi Marcus olur. Her dal için aynı seed'le `GameState.new_campaign(seed)` çağrılır ve
oturum sahnesiyle aynı bağlantı kurulur: `ShelterManager`, `DialogueRunner`, `director.shelter = shelter`,
`director.setup(dialogue)` (`scripts/dev/house_blockout.gd` ile aynı).

**İzin verilen G3 başlangıç kurulumu (G3 sonucu içermez):** Elena G1'de `guest_a_1` yatağını almış, Arthur'un G2
ziyareti yanıtsız kalmış (`left`, `<id>_left_unanswered`). Ardından `day = 3`, `minutes = 07:00` atanır. Bundan sonra
hiçbir sonuç state bayrağıyla atlanmaz. Her adım `_act()` ile atılır: eylemin o anda `get_room_actions()` içinde
gerçekten sunulduğu kontrol edilir, sonra `perform_room_action()` çağrılır. Diyalog seçimleri gerçek
`marcus_arrival.json` üzerinden `choose_by_id` ile yapılır.

| Adım | admit | reject | miss |
|---|---|---|---|
| G3 sabah | `rest` tam seed dakikasında vuruşla kesilir | aynı | aynı |
| Kapı | `front_door_used` → `work` sorusu (+5 dk, beceri bayrağı) → `admit` → `bed:guest_b_1` | `reject` → `confirm` | Kapı açılmaz. `rest` bir kez uyarır, sonra pencere sonunda `left` + `d3_marcus_left_unanswered` |
| Kaydet/yükle | tam `to_dict()` eşitliği; takvim ve enfeksiyon değişmez | aynı | aynı |
| ROOMS | `apply_plan` Marcus'u `multipurpose_1`'e taşır: +15 dk, tek oda, Elena yerinde; aynı planın tekrarı 0 dk | — | — |
| G3 gece kararı | `sleep` → 23:00 `POWER_WAKE` | `watch` iki basış (onay) → izleme + kesinti | `sleep` → `POWER_WAKE` |
| Kesinti | `power:panel` (10 dk). `power:repair` önce teklif verir, ikinci basış onarır. Yardımcı Marcus, 25 dk, 1 birim | `power:defer`; yardımcı yok | `power:defer`; hiç onarılmaz |
| G3→G4 | gerçek `sleep` → `start_next_day` | `wait_watch` döngüsü 07:00'a kadar → `NightSession.finish` | gerçek `sleep` |
| G4 sabah | 07:00, `RADIO_D4_MORNING_GUIDE`, yiyecek/su tam bir kez × kişi sayısı, kaydet/yükle eşitliği | aynı + solo onarım 35 dk | aynı (kesinti sürüyor) |
| Radyo | `living_room/radio`: tahliye duyurusu, `minutes`+15, `HEARD/AT` kaydı; ikinci basış bedelsiz | aynı | aynı (pilli radyo kesintide çalışır, Day4Broadcast.md) |
| Kapanış | `review_last_night` → `day4:wait` ×2 (20:00) → `day4:complete` ×2 (20:00 kaydı) → özet: güç durumu, radyo iddiası, yapı sınırı → kaydet/yükle → `sleep` = `NARR_END_OF_BUILD`, durum değişmez | aynı | aynı; özet `D4_CLOSE_OUTAGE` |

Her dalda şunlar da kontrol edilir:
- `d3_marcus` tam bir kez çözülür.
- Marcus'un durumu gece boyunca korunur.
- G4'te kapıda kimse yoktur.
- Hafıza kaybı yayını duyulmadığı için sabotaj nedeni ya da fail uydurulmaz.
- Takvim ve enfeksiyon başlangıçtakiyle sona kadar aynıdır.

## Seçili paket çalıştırma

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run-Tests.ps1 -GodotPath "<Godot_v4.7.2-stable_win64_console.exe>" -SelectedTests arrival_integration_test
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run-Tests.ps1 -GodotPath "<...>" -SelectedTests "arrival_integration_test,shelter_test"
```

- Yalnız betikteki 29 paketlik beyaz listeden adlar kabul edilir. `-File` ile virgüllü liste tek dize gelir; betik virgülden böler ve boşlukları kırpar.
- Boş seçim (`""`, `" , "`), bilinmeyen ad ve tekrarlanan ad, Godot yolu çözülmeden, geçici klasör açılmadan ve dosya yazılmadan `throw` ile reddedilir (çıkış 1). Değersiz `-SelectedTests` PowerShell tarafından bağlamada reddedilir.
- Seçili paketler beyaz liste sırasıyla koşar. Her zaman aynı izole proje kopyası (`%TEMP%\tqh-tests-<guid>`), `override.cfg` ile benzersiz kullanıcı klasörü (`TheQuietHours-Tests/<guid>`) ve `--import` adımı kullanılır. Oyuncunun `app_userdata` klasörüne ve gerçek kayıtlara dokunulmaz.
- Sonuç metni ayrıdır: `Selected N test suites passed: <adlar>. This is a partial run, not the full suite.` Tam çalıştırma metni (`All 30 test suites passed (including hardware audio lifecycle).` / `All 29 core test suites passed...`) seçili modda hiçbir zaman yazılmaz.
- **WASAPI sayımı:** Seçili modda `-AudioDriver WASAPI` verilirse seçili paketler o sürücüyle koşar. Ayrıca `audio_lifecycle_test` her zaman eklenir ve sızıntı varsa çalıştırma düşer. Bu yaşam döngüsü paketi N'ye **sayılmaz**; metne ayrıca `Hardware audio lifecycle (WASAPI) also passed; it is not counted in the selected total.` eklenir. `audio_lifecycle_test` adla seçilemez. Sürücü verilmezse `Hardware audio lifecycle was NOT run.` yazılır.
- Parametre verilmezse tam davranış önceki gibidir: 29 paket, `-AudioDriver` ile 30 paket.

## Gerçek sonuçlar (bu worker'ın kendi çalıştırmaları)

- `-SelectedTests arrival_integration_test` (izole, sürücüsüz): `ARRIVAL INTEGRATION TEST: PASS (249 checks)`, ardından `Selected 1 test suites passed ...`. Logda uyarı, hata veya sızıntı yok.
- Reddetme denemeleri (çıkış 1, Godot başlamadan): `bogus_test`, `""`, `"shelter_test,shelter_test"`, değersiz `-SelectedTests`.
- Sürücüsüz tam çalıştırma (çıkış 0): 29 paketin tamamı PASS. Son satır: `All 29 core test suites passed. Hardware audio lifecycle was NOT run; ...`. `presentation_test` için mevcut "Object lifetime warning" uyarısı çıktı. Bu paket değiştirilmedi ve değişen dosyaları kullanmıyor. Ancak uyarının önceden var olup olmadığını bu worker karşılaştırmadı.
- **WASAPI 30 paket kapısını bu worker çalıştırmadı.** Dış yönetici çalıştıracak.

## Sınırlar

- **Mevcut dilim 4 günlüktür.** `LAST_AUTHORED_DAY = 4`. G4 gecesinde `sleep` yalnız `NARR_END_OF_BUILD` döndürür, gün ilerlemez. Zincir burada biter.
- **İşlevsel NPC sayısı 3'tür:** Elena Ward, Marcus Hale, Arthur Bell. `noah_lily` ve `maya` havuzda var, ama `noah_arrival`/`maya_arrival` diyalogları yazılmadığı için takvime hiç girmezler. Bu testte de G3–G4'te kapıya başka kimse gelmez.
- G1–G2 oynanmadı. Elena'nın kabulü ve Arthur'un kaçırılması G3 başlangıç kurulumu olarak atanır. G1/G2'nin gerçek akışı `day12_integration_test` ve `day2_test` içinde zaten var.
- Seed sabit değil, aranıyor. Havuz veya algoritma değişip uygun seed kalmazsa test `FAIL` verir, sessizce atlamaz.
- Elena'nın enfeksiyonu seed'e göre değişir. Sabotaj yalnız hafıza kaybı yayını duyulmuşsa mümkündür; bu zincirde G2 radyosu dinlenmediği için sabotaj dalı **sınanmadı** (`power_incident_test` sınıyor).
- G3 gece tanığı (`NightWitness`) sahne erişim ölçümü gerektirir. Bu sahnesiz zincirde kayıt üretmez, dolayısıyla G4 tanık görüşmesi sınanmadı.
- ROOMS tarafında yalnız gerçek `ShelterManager.apply_plan` yolu sınandı. `RoomPreferences` değerlendiricisi henüz UI veya veriyle bağlı değil, bu zincirde çağrılmadı. Regresyonu `shelter_test` içinde kalıyor.
- Bu çalışmada gerçek bir oyun kodu hatası bulunmadı; kapsam dışı yama yapılmadı.
