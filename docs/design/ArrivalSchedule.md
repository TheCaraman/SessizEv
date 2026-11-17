# Kurallı rastgele geliş takvimi — tasarım önerisi (ARRIVALS-DESIGN-001)

2026-11-17 — Claude. Yetkili yön: [NPC_ArrivalAndRooms.md](../NPC_ArrivalAndRooms.md) (K-NPC-ARRIVALS-ROOMS-001).
Bu belge **uygulama önerisidir**, kod değildir. "ÖNERİ" diye işaretli her sayı ve kural sahibin onayını bekler.
İnceleme tabanı: `codex/house-atmosphere-v3` @ 3719dd5 (salt okunur).

## 1. Bugünkü gerçek durum

| Parça | Bugün | Dosya |
|---|---|---|
| Ziyaretler | 3 sabit kayıt: Elena G1 18:00–21:30, Marcus G2 10:00–13:00, Arthur G2 15:00–18:00 | `resources/events/arrivals.json` |
| Ziyaret akışı | Gün/saat gelince kapıya gelir; pencere geçerse "left"; aynı anda tek kişi kapıda; çözülen id tekrar gelmez | `campaign_director.gd` `_update_arrivals` |
| Kayıtta | `resolved_arrivals` (id listesi), `visitor`, `visitor_arrival`; takvimin kendisi kayıtta YOK, JSON'dan okunur | `game_state.gd` |
| Enfeksiyon | `InfectionAssigner.assign(campaign_seed)`, RNG doğrudan `campaign_seed`; 3–5 kişi; "ilk altı teklif"ten en az biri enfekte — bu kural **Roster.arrival_order ≤ 6** ile tanımlı | `infection_assigner.gd`, `roster.gd` |
| Diğer seed kullanımı | Güç olayı: `campaign_seed ^ hash(id)` | `power_incident.gd` |
| Kayıt sürümü | v5 | `GameState.SAVE_VERSION` |

İçerik bağımlılıkları (yalnız 3 NPC'lik kesit): Gün3 güç olayı katılımcıları, gece gözlemi, suçlama, izolasyon ve
yargı verileri Elena/Marcus/Arthur listeler. Güç olayında Marcus yoksa "tek başına" onarım yolu var
(`power_incident.gd` `can_help_repair`). Elena'ya bağlı özel bir satır var (`campaign_director.gd` ~490, `elena_here`).
Diğer verilerin her yolda kişinin evde olmasını kontrol ettiği bu incelemede satır satır **doğrulanmadı**; §10'daki
eksik-NPC testleri bunu kanıtlamalı.

## 2. Ana sorun: enfeksiyon kuralı sabit sıraya bağlı

K-005'in "ilk altı kapı teklifinden en az biri enfekte" kuralı bugün sabit `arrival_order` ile çözülüyor. Takvim
rastgele olunca "ilk altı teklif" artık takvime bağlı. Sahibin kuralı: **enfeksiyon önce belirlenir, takvim onu
değiştirmez.** Bu yüzden yön tek taraflı olmalı:

- Enfeksiyon takvimi hiç okumaz; `InfectionAssigner` aynen kalır (aynı seed → bugünkü sonuç, eski testler korunur).
- **ÖNERİ:** Takvim enfeksiyonu *okuyabilir*, değiştiremez. Takvim üretici, ilk altı kapı teklifinde en az bir
  enfekte kişi olmasını kısıt olarak sağlar (o kişinin penceresinden erken bir yuva seçer). Kural yine sağlanır;
  enfeksiyon sonucu hiç değişmez.
- Alternatif (daha basit, daha zayıf): "erken havuz"u roster verisiyle sabit tut (bugünkü gibi), takvim bunu garanti
  etmez. Önermiyorum: rastgele takvimde erken havuzdaki enfekte kişi Gün8'de gelebilir ve K-005 fiilen bozulur.
- Sızıntı riski: kısıt her zaman "en erken uygun yuvaya" koyarsa oyuncu "ilk gelen enfektedir" örüntüsünü öğrenir.
  **ÖNERİ:** kısıt yalnız hiç enfekte yoksa devreye girsin ve enfekte kişiyi ilk altı teklif içindeki *rastgele*
  bir sıraya koysun.

## 3. Seed ve RNG akışları

- `campaign_seed` tek kaynak. Her sistem kendi akışını türetir; akışlar birbirinin çekiliş sayısını etkilemez:
  - enfeksiyon: `campaign_seed` (değişmez — geriye uyum)
  - güç olayı: `campaign_seed ^ hash(event_id)` (değişmez)
  - **geliş takvimi: `campaign_seed ^ hash("arrival_schedule_v1")`**
- Takvim **kampanya başında bir kez** üretilir (`new_campaign` içinde, enfeksiyondan hemen sonra) ve kayda yazılır.
  Kapıya bakmak, kayıt/yükleme, dil ya da ayar değişimi yeniden çekiliş yapmaz.
- Algoritma sürümü (`_v1`) kayıtta tutulur; ileride algoritma değişirse eski kampanyalar eski takvimle sürer.

## 4. Veri şeması (öneri)

Yeni dosya `resources/events/arrival_pool.json` (bugünkü `arrivals.json` geriye uyum için kalır, bkz. §6):

```json
{
  "version": 1,
  "rules": {
    "max_visits_per_day": 2,
    "min_gap_minutes": 90,
    "latest_end": 1380,
    "first_offers_window": 6
  },
  "visits": [
    {
      "id": "elena",
      "npcs": ["elena_ward"],
      "fixed": {"day": 1, "start": 1080, "end": 1290},
      "dialogue": "elena_arrival",
      "always": true
    },
    {
      "id": "marcus",
      "npcs": ["marcus_hale"],
      "windows": [{"days": [2, 3], "start_min": 540, "start_max": 840, "duration": 180}],
      "chance": 1.0,
      "dialogue": "marcus_arrival"
    },
    {
      "id": "noah_lily",
      "npcs": ["noah_reed", "lily_reed"],
      "windows": [{"days": [3, 6], "start_min": 600, "start_max": 1080, "duration": 150}],
      "chance": 0.8,
      "dialogue": "noah_arrival",
      "requires_content": true
    }
  ]
}
```

- `npcs` bir dizi: Noah–Lily gibi birlikte gelenler tek ziyarettir (Roster'daki ortak `arrival_order` 4 bunu zaten ima ediyor).
- `fixed` ↔ `windows`: sabit ziyaret (öğretici) ya da pencereden seçim. `days` kapalı aralık.
- `chance`: bu oynayışta gelip gelmeyeceği. `always: true` = her oyunda.
- `requires_content: true`: diyaloğu/odası yazılmamış karakter takvime **hiç girmez**. Böylece veri 18 kişiyi
  tanımlayabilir ama yalnız içeriği olanlar gelir; "18 NPC hazır" yanılgısı oluşmaz.
- Gece gelişi yok: `latest_end` 23:00 (`NIGHT_START`). Gece ziyareti sahip kararıdır (§9).

## 5. Üretim algoritması (öneri)

Deterministik ve sıra-bağımsız olacak şekilde:

1. Ziyaretleri `id` sırasına diz (JSON sırası sonucu etkilemesin).
2. Her ziyaret için: `always` değilse `rng.randf() < chance` ile dahil et; içeriği yoksa atla.
3. Dahil edilen her ziyarete pencere içinden gün ve 15 dk'lık başlangıç yuvası çek.
4. Çakışma çöz: aynı gün `max_visits_per_day` aşılırsa ya da iki ziyaret arasında `min_gap_minutes` yoksa, sonrakini
   aynı penceredeki bir sonraki uygun yuvaya kaydır; yer yoksa sonraki pencere gününe; hiç yoksa düşür.
   Sabit (öğretici) ziyaret asla kaydırılmaz.
5. §2 enfeksiyon kısıtını uygula.
6. Sonuç: `[{"id": "d{gün}_{ziyaret}", "visit": ..., "npcs": [...], "day", "start", "end", "dialogue"}]`,
   bugünkü `_arrival_comes_first` sırasıyla. `id` biçimi bugünkü `d1_elena` / `d2_marcus` ile uyumlu.

`CampaignDirector._load_arrivals` JSON yerine `GameState.arrival_schedule` okur; `_update_arrivals` ve "left"
mantığı **değişmez**. Tek fark: çok kişili ziyarette kapıdaki "visitor" grubun ilk kişisidir; kabul/ret tüm gruba uygulanır.

## 6. Kayıt: v5 → v6 (öneri ve gerekçe)

**Neden şema değişmeli:** Takvim seed'den her yüklemede yeniden türetilebilir, ama o zaman `arrival_pool.json` ya da
algoritma her değiştiğinde *eski kampanyaların takvimi sessizce değişir* — sahibin "save/load boyunca sabitlik"
kuralını bozar. Takvimi kayda yazmak bu riski kalıcı olarak kapatır. Maliyet: kayıt başına birkaç yüz bayt ve bir geçiş.

- Yeni alanlar: `arrival_schedule` (§5 listesi), `arrival_schedule_version` (int; `1`, ya da eski kayıtlar için `0` = legacy).
- **v5 → v6 geçişi:** eski kayıtlar **yeniden rastgeleleştirilmez**. Bugünkü sabit üç ziyaret aynen
  `arrival_schedule` olarak yazılır, `arrival_schedule_version = 0`. `resolved_arrivals` id'leri (`d1_elena`,
  `d2_marcus`, `d2_arthur`) aynı kaldığı için çözülmüş/kapıdaki ziyaretler bozulmaz.
- Doğrulama (`SaveManager` aday kontrolü): takvim kampanya ortasında değişemez (`commit_candidate` beklenen ↔ aday
  karşılaştırmasına `arrival_schedule` eklenir, tıpkı `campaign_seed` gibi); id'ler tekil; `day ≥ 1`;
  `start < end ≤ 1440`; npc'ler Roster'da; `visitor_arrival` boş değilse takvimde olmalı; `resolved_arrivals`
  takvimde olmayan id içeremez (legacy hariç).
- Yeni oyun her zaman v1 takvimle başlar.

## 7. Gelmeyen / reddedilen NPC ve hikâye

Sahibin kuralı: ana hikâye ve temel bilgi tek isteğe bağlı karaktere kilitlenmez.

- Her ileride yazılacak gün tasarımı (Gün5 Broken Signal dahil) "kim evde olmayabilir" tablosu içermeli; her kritik
  bilgi için en az iki kaynak (ikinci NPC, belge/nesne, radyo, gözlem) gösterilmeli. Maya zorunlu değil.
- Bugünkü kesitte: Elena öğretici (§8), Marcus'un onarım yardımı "tek başına" yoluyla, gece gözlemi/suçlama/yargı
  "evde olan uygun yetişkinler" ile çalışıyor. Yeni bir eksik yol gerekmiyor; testle kanıtlanmalı (§10).
- `requires_content` kuralı sayesinde yazılmamış karakter hiç gelmez; boş diyaloglu ziyaret oluşmaz.

## 8. Elena öğretici sabitliği (ÖNERİ — sahip onayı gerekir)

**Öneri:** Elena her oyunda Gün1 18:00–21:30 gelir (`always`, `fixed`).
Gerekçe: Gün1'in tek kapı olayı öğretici; kapı, kabul, yatak atama ve ilk gece burada öğretiliyor. Rastgele yapılırsa
Gün1'de kapı hiç çalmayabilir ve öğretici kırılır. Onaylanan kuraldaki "hikâye tek isteğe bağlı karaktere kilitlenmez"
ilkesini bozmaz: Elena kapıda *sunulur* ama oyuncu yine reddedebilir; Elena'sız Gün2+ akışının tam oynanabilirliği
§10 testiyle kanıtlanmalı (bu incelemede doğrulanmadı).
Alternatif: Gün1 öğretici ziyaretçisi küçük bir havuzdan (Elena ya da başka bir tam profilli karakter) seçilir — bugün
ikinci tam profil yok, bu yüzden önermiyorum.

## 9.0 Sahip kararı — 2026-11-17 (K-ARRIVALS-PARAMS-001)

Sahip §8 ve §9'daki önerileri olduğu gibi kabul etti ("Önerileri kabul et"):
Elena G1 18:00–21:30 sabit öğretici (reddedilebilir); Marcus ve Arthur %100, G2–3 içinde değişken gün/saat;
günde en çok 2 ziyaret, arada en az 90 dk; gece gelişi yok; ileriki roster pencereleri §9.4'teki taslak değerlerle
başlar (denge testiyle ayarlanabilir); K-005 için §2 önerisi (takvim enfeksiyonu okur, değiştirmez; gerekirse
ilk altı teklif içinde rastgele sıra). Aşağıdaki liste kayıt amaçlı korunuyor.

## 9. Sahibin karar vermesi gerekenler

Belge bunları **seçmez**; yalnız seçenek ve öneri verir:

1. Gün2–3 kesitindeki varyasyon (ÖNERİ): Marcus ve Arthur Gün2–3 içinde değişken gün/saatte, ikisi de %100 gelir.
   Böylece bugünkü içerik bozulmadan her oyun farklı başlar. (Seçenek: biri %70 gelir — Gün3 güç olayı ve
   gözlem içeriği 2 kişiyle daha zayıf kalır.)
2. Günlük yoğunluk (ÖNERİ): günde en çok 2 ziyaret, aralarında en az 90 dk.
3. Gece gelişleri: şimdilik yok. Açılırsa ayrı tasarım (nöbet sistemiyle etkileşim).
4. İleriki roster için pencereler (örnek, ÖNERİ): Noah+Lily G3–6, Maya G4–8 (%70), ikincil karakterler G5–12 (%50–70),
   kısa-arc karakterler G6–13 (%40). Sayılar denge önerisidir.
5. §2 enfeksiyon kısıtının biçimi.

## 10. Test planı (ARRIVALS-001 için)

- Aynı seed → aynı takvim (iki ayrı `new_campaign`); farklı 200 seed → en az N farklı takvim (çeşitlilik ölçüsü).
- Enfeksiyon bağımsızlığı: takvim üreticisi açıkken ve kapalıyken aynı seed'de `npcs[*].infected` birebir aynı.
- K-005: 1000 seed'de ilk altı teklifte ≥1 enfekte (roster yeterliyse).
- Kayıt: takvim save/load sonrası birebir aynı; kapıya bakma/yükleme yeniden çekmez; aday takvimi değiştiremez.
- v5 → v6: hazır v5 kayıtları (Gün1 kapıda Elena, Gün2 Marcus çözülmüş, Gün3 gece) legacy takvimle aynen sürer.
- Kısıtlar: günde ≤2, aralık ≥90 dk, hiçbiri 23:00'ü geçmez, öğretici her zaman G1 18:00.
- Eksik NPC: Marcus ya da Arthur'un gelmediği / reddedildiği / kovulduğu kampanyalarda Gün2→Gün4 kapanışı oynanabilir
  (mevcut entegrasyon testlerinin eksik-NPC varyantları).
- `requires_content`: içeriği olmayan karakter hiçbir seed'de takvime girmez.
- Grup ziyareti (ileride Noah–Lily): kabul/ret ikisine birden uygulanır; Lily asla enfekte değildir.

## 11. Oda tercihleriyle sınır (ROOMS-DESIGN-001, Codex)

Takvim yalnız *kim ne zaman kapıda* sorusunu çözer. Yatak, tercih ve itiraz Codex'in ROOMS tasarımındadır. Ortak nokta:
grup ziyaretinde kabul edilen kişilerin yatak ihtiyacı birlikte hesaplanır (Noah–Lily aynı oda isteği oradan gelir);
kapasite kuralları (6 yatak, izolasyon rezervi) takvimden etkilenmez — takvim yatak varlığına göre ziyaret düşürmez,
çünkü ret/kabul oyuncunun kararıdır.

## 12. Uygulama sahipliği (Codex ile anlaşıldı)

ARRIVALS-001 kodu: Claude, Codex'in DAY4-RADIO-001 checkpoint'i commit edildikten sonra, o commit tabanlı ayrı worktree'de.
Dosyalar: `game_state.gd`, `save_manager.gd` (v6), `campaign_director.gd` (yalnız ziyaret yükleme), yeni
`scripts/narrative/arrival_scheduler.gd`, `resources/events/arrival_pool.json`, yeni testler. O sürede save şemasına
başka asistan yazmaz. ROOMS-001, ARRIVALS-001 birleştirildikten sonra.
