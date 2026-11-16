# THE QUIET HOURS — Üretim Planı, Ses ve Kalite

Sürüm 0.1 · 2026-11-16

Ses yönü ve kalite planı şimdilik bu belgede tutulur; içerik büyüdüğünde `AudioBible.md` ve `QAPlan.md` olarak ayrılacaktır.

## 1. Fazlar

| Faz | İçerik | Çıkış ölçütü |
|---|---|---|
| 0 Ön üretim | Belgeler, kararlar | Bu belge seti onaylı |
| 1 Birinci şahıs prototipi | Proje, kontrolcü, etkileşim, ev blockout'u, kapılar, ışıklar, görüntü hattı, kayıt temeli | Evin her odası gezilebiliyor; kaydet/yükle konumu koruyor |
| 2 İlk oynanabilir gün | Giriş, TV ve radyo, kaynaklar, Elena, diyalog, kabul/ret, ilk gece | Gün 1 baştan sona oynanıyor |
| 3 Sosyal sistemler | Üç NPC, işler, güven, oda atama, tüketim, programlar | Üç NPC bir günü hatasız yaşıyor |
| 4 Korku dikey kesiti | Gün 1–3, nöbet, elektrik kesintisi, kanıt, yargı | Dışarıdan bir oyuncu 30–40 dk oynayabiliyor |
| 5 Anlatı genişlemesi | 18 NPC, 14 gün, gizem, sonlar | Altı sonun hepsi ulaşılabilir |
| 6 Sanat ve ses | Yer tutucuların değişimi | Yer tutucu kalmadı |
| 7 Dengeleme ve kalite | Tam kampanya testleri, performans | Kritik hata yok |
| 8 Yayın hazırlığı | Windows derlemesi, yerelleştirme, lisans denetimi | Yayın denetim listesi tamam |

## 2. Faz 1 görevleri

| No | Görev | Durum |
|---|---|---|
| 1.1 | Proje kurulumu: `project.godot`, klasörler, `EventBus`, `InputSetup`, açılış sahnesi | **Tamam** — 4.7.2'de başsız çalıştırıldı, hata yok |
| 1.2 | Birinci şahıs kontrolcü | **Tamam** — otomatik test geçti (`tests/player_movement_test.tscn`); pencereli elle deneme yapılmadı |
| 1.3 | Etkileşim sistemi (ışın, `Interactable`, ipucu) | Bekliyor |
| 1.4 | Ev blockout'u (önce kat planı onayı) | Kat planı taslağı hazır (`HousePlan.md`); onay bekliyor |
| 1.5 | Kapılar, kilitler, ışık anahtarları | Bekliyor |
| 1.6 | Retro görüntü hattı, temel gösterge, `Settings` | Bekliyor |
| 1.7 | `TimeManager`, `GameState`, `SaveManager` temeli | Bekliyor |

**Not:** Sürüm kontrolü başladı (yerel depo, `main` dalı). Uzak yedek henüz yok.

## 3. Sürüm kontrolü ve takip

- Git; ana dal her zaman açılır durumda. Her faz için dal, faz sonunda etiket (`v0.1-faz1`).
- Commit biçimi: `alan: ne değişti` (örnek: `player: add first-person controller`).
- Görev listesi bu belgede; proje büyürse GitHub Issues'a taşınır.
- Kod ile belge çelişirse önce belge güncellenir.

## 4. Risk kaydı

| Risk | Olasılık | Etki | Önlem |
|---|---|---|---|
| 18 NPC'nin yazım yükü | Yüksek | Yüksek | Kademeler (K-006); önce dikey kesit |
| Karakter görsel kalitesi | Yüksek | Orta | Modüler kit; Faz 6 öncesi dış kaynak kararı |
| Animasyon kaynağı yok | Orta | Yüksek | A-004; Faz 3 öncesi karar |
| Ses varlıkları | Orta | Yüksek | CC0 kütüphaneleri ve lisans denetimi; özgün müzik kararı Faz 6'da |
| Çıkarımın ya çok kolay ya rastgele olması | Orta | Yüksek | V-004; erken oyuncu testi |
| Kapsam kayması | Yüksek | Yüksek | GDD §14; her yeni mekanik için gerekçe ve onay |
| Tek geliştirici, uzun proje | Yüksek | Orta | Küçük, test edilebilir adımlar; `CLAUDE.md` |

## 5. Ses yönü (özet)

- Ev inandırıcı bir akustik ortamdır: döşeme gıcırtısı, uzak adım, menteşe, rüzgâr, yağmur, radyo cızırtısı, elektrik vızıltısı, jeneratör, su boruları, kısık konuşma.
- Müzik seyrek ve özgündür: alçak drone, seyrek piyano, bozuk bant dokuları, analog synth. Sessizlik bilinçli kullanılır.
- Konumlu 3D ses yön ve yaklaşık uzaklık verir; imkânsız kesinlik vermez.
- Ses yolları: ana, müzik, efekt, diyalog, ortam.
- Kritik her ses ipucunun altyazı ya da görsel karşılığı vardır.
- **Şu an hiçbir ses dosyası yok.**

## 6. Kalite planı (özet)

**Otomatik:** enfeksiyon ataması kısıtları · son çözümleyici tablosu · kayıt gidiş-dönüş · olay ön koşulları (ölü ya da yok NPC seçilemez).

**Elle, her faz sonunda:** gezinme ve çarpışma · kapı erişimi · NPC programları · iş atama · kaynak tüketimi · diyalog bayrakları · kanıt tutarlılığı · gece olayları · kaydet/yükle (olağan oyun, karar sonrası, gün arası) · eksik NPC yedek yolları.

**Anlatı doğrulama (her büyük olaydan önce):** katılımcılar mevcut mu · önceki olgularla çelişiyor mu · kanıtın gerçek nedeni var mı · oyuncunun anlamlı seçimi var mı · sonuçlar kaydediliyor mu · oyuncu reddederse hikâye sürüyor mu · enfeksiyon kurallarına uyuyor mu.
