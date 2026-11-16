# THE QUIET HOURS — Teknik Tasarım

Sürüm 0.1 · 2026-11-16

## 1. Motor

- Godot **4.7.2 stable**, standart sürüm. Yalnızca 4.7.x yama güncellemeleri alınır.
- GDScript, tipli. Görüntüleyici: Forward+.
- Hedef: 1080p, 60 FPS (Ryzen 5 5600G, GTX 1080 Ti, 16 GB sınıfı). Gerçek zamanlı küresel aydınlatmaya bağımlılık yok.

## 2. Görüntü hattı (Faz 1.6'da kurulacak)

```
Kök pencere (yerel çözünürlük)
├── SubViewportContainer (ekrana gerilir, en yakın komşu örnekleme)
│   └── SubViewport (iç çözünürlük, varsayılan 640×360)
│       └── 3D dünya
└── CanvasLayer — arayüz (yerel çözünürlükte, okunaklı)
```

Son işleme (renk derinliği azaltma, titreklik, gren) kapsayıcıya uygulanan tek bir gölgelendiricidedir ve ayarlardan kapatılabilir.

## 3. Sistemler

**Otomatik yüklenenler (global):**

| Ad | Görev | Durum |
|---|---|---|
| `EventBus` | Sistemler arası sinyaller | Çalışıyor |
| `InputSetup` | Girdi eylemlerini kaydeder, yeniden atamayı sağlar | Kayıt doğrulandı; yeniden atama henüz denenmedi |
| `GameState` | Kampanya yaşam döngüsü, seed | Faz 1.7 |
| `SaveManager` | Sürümlü kayıt | Faz 1.7 |
| `Settings` | Ayarların kalıcılığı | Faz 1.6 |
| `AudioManager` | Ses yolları ve geçişler | Faz 2 |

**Sahne-yerel (`Campaign` kökü altında):** `TimeManager`, `NarrativeManager`, `NPCManager`, `InfectionManager`, `EventDirector`, `ShelterManager`, `ResourceManager`, `DialogueManager`, `EvidenceManager`, `RelationshipManager`, `UIManager`.

Kural: sahne-yerel sistemler birbirini doğrudan aramaz. Bağımlılıklar `Campaign` tarafından verilir; haberleşme sinyalle olur.

## 4. Veri şemaları (taslak; Faz 2–3'te `Resource` sınıflarına dönüşür)

**NPC tanımı**
```
id: StringName            # "elena_ward"
display_name_key: String  # çeviri anahtarı
age: int
tier: int                 # 0 ana, 1 ikincil, 2 kısa yaylı
skills: Dictionary        # {"healthcare": 3, "cooking": 1}
weakness: StringName
secret_id: StringName
can_be_infected: bool     # Lily için false
can_be_killed: bool       # Lily için false
arrival_window: Vector2i  # ilk ve son gün
schedule_id: StringName
dialogue_id: StringName
```

**Olay tanımı**
```
id: StringName
phase: int                # sabah, öğleden sonra, akşam, gece bloğu
priority: int
preconditions: Array      # koşul kaynakları
participants: Array       # roller ve geçerlilik süzgeçleri
consequences: Array       # bayrak, güven, moral, kaynak etkileri
evidence_out: Array       # üretilen kanıt kimlikleri ve gerçek neden
follow_ups: Array
fallback_id: StringName   # katılımcı bulunamazsa
```

**Kanıt kaydı**
```
id: StringName
kind: int                 # fiziksel iz, ifade, erişim kaydı, kayıp malzeme...
true_cause: StringName    # simülasyondaki gerçek neden; boş olamaz
reliability: int          # güvenilir, eksik, yanıltıcı, kasıtlı yanlış
journal_class: int        # olgu, iddia, şüphe
day: int
room: StringName
```

**Kayıt dosyası**
```
save_version: int
campaign_seed: int
rng_states: Dictionary
day: int, phase: int, night_block: int
player: {energy, stress, condition, infection_state, position, inventory}
npcs: {id: {status, infected, location, trust, flags, job, room}}
relationships: {pair_key: value}
resources: {food, water, medical, repair, fuel}
rooms: {id: {locked, role, occupants}}
evidence: Array
narrative_flags: Dictionary
events: {completed: Array, pending: Array, tonight: Array}
ending_vars: Dictionary
```

Kayıt biçimi JSON'dur; `save_version` her şema değişikliğinde artar ve geçiş fonksiyonu yazılır.

## 5. Deterministiklik

- Kampanya seed'i yeni oyunda üretilir ve saklanır.
- Ayrı rastgele üreteçler: enfeksiyon ataması, olay seçimi, kozmetik. Kozmetik üreteç oynanışı etkilemez ve kaydedilmez.
- Gecenin olayları gün başında seçilir ve kayda yazılır; yükleme yeniden seçim yapmaz.

## 6. Yerelleştirme

Oyun içi her metin çeviri anahtarıyla yazılır. Kaynak dil İngilizce (`localization/en.csv`), ardından Türkçe (`localization/tr.csv`). Koda gömülü görünür metin olmaz. İstisna: açılış doğrulama sahnesindeki geçici geliştirici metni.

## 7. Test

- `tests/` altında başsız çalışan betikler.
- İlk testler: enfeksiyon ataması kısıtları (K-002, K-005), son çözümleyici tablosu (GDD §11), kayıt gidiş-dönüş eşitliği.
- Her faz sonunda elle oynanış denetim listesi (`QAPlan.md`).

## 8. Bilinen teknik riskler

| Risk | Önlem |
|---|---|
| 4.7'ye özgü API farkları | Her sistemde resmi belgeden doğrulama; ilk çalıştırmada uyarı temizliği |
| Merdivende NPC yol bulma | Blockout aşamasında tek NPC ile erken deneme |
| Düşük çözünürlükte metin | Arayüz ayrı katmanda, yerel çözünürlükte |
| Kayıt şeması kayması | Sürüm numarası ve geçiş testleri |
| Motor içi üretilen karakterlerin görsel sınırı | ArtBible §4; gerekirse dış kaynak kararı Faz 6 öncesi |
