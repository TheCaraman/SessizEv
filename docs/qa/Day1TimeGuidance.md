# Gün 1 zaman ipucu (AUTO-DAY1-TIME-GUIDANCE)

Durum: kodlandı ve izole otomatik testlerden geçti. **Henüz aktif sürüme alınmadı.** Commit, dal veya başlatıcı değişikliği yapılmadı.

## Sorun

Yeni oyunda koridorda yürümek saati ilerletmiyor. Gün 1'de yalnızca dolaşan bir oyuncu saatin 07:00'de kaldığını görüyor ve oyunda hiç ziyaretçi olmadığını sanıyor. Ziyaret olayları zaten var; eksik olan, oyuncuya neyin zaman harcattığının söylenmemesiydi.

## Çözüm

Mevcut HUD'a sakin bir bilgi satırı eklendi. Satır saatin hemen altında, sol üstte duruyor. Yeni bildirim, menü ya da sürekli tekrarlanan uyarı yok.

| Anahtar | EN (asıl) | TR |
|---|---|---|
| `HUD_DAY1_TIME_HINT` | Walking the house does not move the clock. Conversations and meaningful actions do. Resting in Daniel's bedroom lets time pass. | Evde dolaşmak saati ilerletmez; konuşmalar ve anlamlı eylemler ilerletir. Daniel'in yatak odasında dinlenmek zamanı geçirir. |

Metinde ziyaretçi adı, saat, rakam, kapı/akşam sözcüğü ya da enfeksiyon bilgisi yok. Elena'nın 18:00'de geleceği, Marcus ile Arthur'un takvimi HUD'da yazmıyor. Test bunu düzenli ifadeyle de denetliyor.

## Dosyalar

- `scripts/ui/hud.gd`: yeni `_guidance: Label`, `_update_guidance()` ve test için `get_guidance_text()` eklendi.
- `localization/strings.csv`: `HUD_DAY1_TIME_HINT` satırı eklendi (EN/TR).
- `tests/campaign_test.gd`: mevcut 69 kontrole dokunulmadı. `_check_day1_guidance()` ile 32 yeni kontrol eklendi.
- `docs/qa/Day1TimeGuidance.md`: bu belge.

Dokunulmayan dosyalar: `GameState`, `CampaignDirector`, `SaveManager`, shelter dosyaları, `tools/Run-Tests.ps1`. Kampanya saati, kapı, uyku ve dinlenme mekaniği aynı kaldı. Otomatik zaman akışı ya da erken ziyaret eklenmedi.

## Düğüm ve sinyal akışı

`Hud` adlı CanvasLayer (layer 10) şu çocukları içeriyor: `_reticle`, `_prompt`, `_subtitle`, `_title`, `_clock` ve yeni eklenen `_guidance`.

`_guidance` ayarları:
- Konum (40, 64), genişlik 560 px, kelime kaydırma açık.
- Yazı boyutu 19, kontur 6, saydamlık 0.62.
- Fare olaylarını yok sayıyor.

`_update_guidance()` satırı yalnızca şu koşulların hepsi sağlanınca gösteriyor:
- `GameState.active` doğru.
- `GameState.day == 1`.
- Evre MORNING veya AFTERNOON, yani 07:00–17:59 arası.
- `GameState.visitor == ""`, yani kapıda kimse yok.
- `_covered_by` boş, yani oda, diyalog veya barınak görünümü açık değil.

Satır şu durumlarda yeniden hesaplanıyor:
- `EventBus.time_changed`
- `EventBus.visitor_changed`
- `_set_covered()`: room/dialogue/shelter görünümü açıldığında veya kapandığında
- `NOTIFICATION_TRANSLATION_CHANGED`
- `_ready()`

Kayıt yüklendiğinde `GameState.from_dict()` bu sinyalleri zaten yayıyor. Bu yüzden yüklenen Gün 1 gündüz kaydında satır doğru durumda geliyor; Gün 2 ve sonrasında gizli kalıyor.

Saat (`_clock`) ve kapı altyazısı (`_subtitle`) ayrı etiketler ve ayrı konumlarda; ipucu ikisinin de metnini değiştirmiyor. Kapı çalınca ipucu gizleniyor ve yalnızca "Someone is knocking" altyazısı kalıyor.

## Test sonuçları (gerçek çalıştırma, izole)

- `tools/Run-Tests.ps1 -SelectedTests campaign_test`: ilk koşuda 2 kontrol başarısız oldu. Nedeni önceki bölümden kalan "knocking has stopped" bildiriminin 5 saniyelik süresi içinde altyazının dolu olmasıydı. Test, bildirimin süresini `_hud._process(6.0)` ile doldurmak üzere düzeltildi; HUD koduna dokunulmadı. Yeniden koşuda `CAMPAIGN TEST: PASS (101 checks)`.
- Tam çekirdek paket: `All 29 core test suites passed`. Günlükler `%TEMP%\tqh-tests-87e0b1b198f244ecad18597cbab36698` altında. `presentation_test` bilinen nesne ömrü uyarısını verdi.
- Donanım ses kapısı (`-AudioDriver WASAPI`, full30) çalıştırılmadı. Bunu dış yönetici çalıştıracak.

Yeni kontroller şunları doğruluyor:
- Gün 1 07:00'de gerçek EN HUD metni csv ile birebir aynı. TR yerel ayarında gerçek TR metin gösteriliyor ve saat "Gün 1" olarak kalıyor. EN'e dönünce metin geri geliyor.
- Saat "07:00" görünmeye devam ediyor ve altyazı boş kalıyor.
- Spoiler denetimi: EN/TR metinde rakam, Elena/Marcus/Arthur adları, infect/enfekte, knock/visitor/evening, akşam/ziyaret/kapı sözcükleri yok.
- İpucu okunduğunda ve dil değiştirildiğinde `GameState.to_dict()` değişmiyor. Saat 07:00'de kalıyor ve ziyaretçi gelmiyor. Bildirim gösterildiğinde de durum değişmiyor.
- Metindeki vaat doğru: Gün 1 sabahı Daniel'in odasında `rest` eylemi sunuluyor ve 60 dakika geçiriyor. Oda açıkken ipucu gizleniyor, oda kapanınca geri geliyor.
- İpucu 13:00'te (öğleden sonra) görünüyor. 18:00'de mevcut ziyaret yine geliyor; ipucu gizleniyor, altyazıda "knocking" görünüyor. Diyalog boyunca ve ziyaret bittikten sonra akşam boyunca ipucu gizli kalıyor.
- Gün 1 öğleden sonra kaydı yüklendiğinde ipucu görünüyor ve kapı altyazısı yok. Gün 2 kaydı yüklendiğinde ipucu gizli.
- İpucu ile bildirim aynı anda görünebiliyor; biri diğerinin yerini almıyor.

## Yapılmayanlar ve riskler

- **Çeviri türevleri güncellenmedi.** `strings.en.translation` ve `strings.tr.translation` dosyalarını izole importtan kopyalamak bu oturumda engellendi: geçici dizin çalışma klasörü dışında kaldı ve TMP değiştirmeye izin verilmedi. Testler kendi izole kopyalarında csv'yi yeniden içe aktardığı için geçiyor. `tools/Start-Game.ps1` de oyunu açmadan önce `--import` çalıştırıyor. Ancak içe aktarma yapılmadan doğrudan çalıştırılan bir kopyada satır ham anahtar (`HUD_DAY1_TIME_HINT`) olarak görünebilir. Aktif sürüme almadan önce bir izole Run-Tests koşusunun `project/localization/strings.*.translation` çıktısı bu klasöre kopyalanmalı.
- GPU ile gerçek ekran görüntüsü alınmadı; 720p/1080p'de satırın saatle ve etkileşim istemiyle çakışmadığı elle kontrol edilmedi. Satır 560 px genişlikte kaydırılıyor ve TR metin yaklaşık 3 satır tutuyor; bunun gözle doğrulanması gerekiyor.
- Elle oynanış denemesi yapılmadı.
- Kapı geçiş animasyonu (`door_transition_changed`) sırasında satır gizlenmiyor; nişangah ve istem de bu sırada açık kalıyor, mevcut HUD davranışıyla aynı.
