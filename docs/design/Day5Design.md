# Gün 5 — Broken Signal (tasarım önerisi)

DAY5-DESIGN-001 · 2026-11-17 · Claude · **Öneri belgesi; uygulanmış özellik değildir.** Yaratıcı yön ve "ÖNERİ"
işaretli her madde sahip onayı bekler. Kod, kayıt şeması, metin ya da sanat değişmedi.

İnceleme tabanı: `automation/continuous-development` @ ad6d7bd (radyo fc36917 + ARRIVALS a5043bf + oda değerlendiricisi).
Okunanlar: NarrativeBible §1–7, GDD (son koşulları), Day4Design, ArrivalSchedule, RoomPreferences, DecisionLog,
`campaign_director.gd` (`LAST_AUTHORED_DAY = 4`), mevcut radyo metinleri. Özgün uzun spesifikasyonun Gün 15 bölümü
depoda yok; bu belge onu görmüş sayılmaz.

## 1. Kanondan gelen sınır

- NarrativeBible §3: Gün 5'te oyuncunun öğrenebileceği tek yeni basamak: **sinyal röle tesisinden geliyor; konuşmaya
  benzemiyor.** Biyolojik malzeme (G7), sinir sistemleri arası bilgi (G8), ağın amacı (G13) bu günde AÇILMAZ.
- "Her basamağın en az iki bağımsız keşif yolu olur. Hiçbiri tek bir NPC'ye bağlı değildir."
- §4 yedeklilik: Sinyal → Maya → Sophie → Clara ile belgeler (en yavaş). Kesitte bunların hiçbiri oynanabilir değil;
  bu yüzden **Daniel'ın kendi yolu tek başına yetmeli.**
- §5 şablonu ve sağlamlık matrisi (aşağıda §7).
- Ton (§7): mahrem ve insani; dev olay yok, kusursuz çözüm yok, şüpheli ≠ enfekte.

## 2. Önkoşul: Gün 4 gecesi (bugün yazılmamış)

Gün 4 kapanışı bugün dürüst kesit sonudur ("next night is not included"). Gün 5 için önce Gün 4 gecesi gerekir.
**ÖNERİ (en küçük güvenli geçiş):** "sessiz gece" — mevcut uyku/tüketim kuralı (kişi başı 1 yiyecek + 1 su), yeni
saldırı ya da olay yok; Gün 3'ten kalan elektrik arızası olduğu gibi devralınır; nöbet sistemi mevcut kurallarıyla
isteğe bağlı. Gerekçe: Gün 4 zaten suçlama/karar günü; bir gece olayı eklemek ayrı tasarım ister.
Alternatif: Gün 4 gecesine küçük bir radyo/parazit olayı koyup Gün 5'i oradan açmak (daha sinematik, daha çok iş).

## 3. Gün 5 özeti (§5 şablonu)

| Alan | Öneri |
|---|---|
| Amaç | Gece duyulan/yayın arasındaki garip sinyalin ne olduğunu ve nereden geldiğini anlamaya çalışmak |
| Sabah durumu | Gün 4 sonrası sakinler, kaynaklar, güç durumu, kayıtlar aynen; yeni tüketim yalnız gece |
| Konuşulabilir | Evdeki uygun yetişkinler (bugün en çok Elena, Marcus, Arthur); Maya içerik yazılınca |
| Ana olay | Radyoda tahliye yayınının arasına giren, tekrar eden ama dilsiz bir desen |
| İsteğe bağlı | Ev belgelerinde röle tesisi kaydı; Marcus/Arthur'un yorumları; desenin kaydını dinletmek |
| Kaynak baskısı | Yeni kaynak yok; zaman bedeli (tarama, belge arama). ÖNERİ: güç yoksa radyo pilde, ek bedel yok |
| Olası kanıt | `SIGNAL_PATTERN` (doğa: konuşmaya benzemiyor), `RELAY_LOCATION` (yer: röle tesisi) |
| Gece koşulları | Gün 5 gecesi bu belgenin kapsamı dışında |
| Sonuçlar | Oyuncu basamağı öğrenir ya da kaçırır; ikisi de geçerli; kapanış engellenmez |
| Zorunlu geçiş | Yok. Gün 5 kapanışı Gün 4'teki gibi 20:00 sonrası açık onayla |
| Başarısızlık | Hiç taramamak/okumamak: basamak sonraki günlerde ikinci yoldan yine bulunabilir |

## 4. Keşif yolları (en az iki bağımsız; hiçbiri tek NPC'ye bağlı değil)

Basamak iki parçadır: **doğa** ("konuşmaya benzemiyor") ve **yer** ("röle tesisinden geliyor"). Basamak, ikisi de
bulununca tamamlanır.

| Yol | Kim | Ne verir | Bedel (ÖNERİ) | Koşul |
|---|---|---|---|---|
| A. Radyo taraması | Daniel | Doğa: tekrar eden, nefes gibi aralıklı, kelimesiz desen | 20 dk | Pilli radyo; her zaman |
| B. Ev belgeleri | Daniel | Yer: eski belediye bülteni / tesis haritası — röle tesisinin frekans ve yön bilgisi | 40 dk, depo/çalışma alanı | Her zaman; A'dan bağımsız bulunabilir |
| C. Marcus | Marcus | Yer (hızlı): kesintiyle eş zamanlı vınlama, "bu hat röleden gelir" | 10 dk konuşma | Sakin, evde, izole/etkisiz değil |
| D. Arthur | Arthur | Yer (kısmi): kasabaya röle kurulurken yaşananları hatırlar → B'yi 20 dk'ya indirir | 10 dk | Aynı koşullar |
| E. Maya (gelecek) | Maya | Doğa + yer birlikte, en hızlı | — | İçeriği yazılınca; zorunlu değil |

- A + B tek başına, hiç NPC olmadan basamağı tamamlar (en yavaş yol, ~60 dk).
- C ve D yalnız hızlandırır; yokluklarında kayıp bilgi yoktur.
- Kanıt türleri mevcut sisteme uyar: radyo ve belge `fact`, NPC sözleri `claim` olarak kaydolur.

## 5. Enfekte NPC davranışı (ÖNERİ — sahip kararı)

Kanonda enfektelerin nedenlerinden biri "iletişim ekipmanını bozmak / ifşayı önlemek". Gün 5'te bunun en hafif,
şiddetsiz biçimi önerilir:
- Enfekte Marcus C yolunda "şebeke paraziti, önemli değil" der (`claim`, yanlış yönlendirme). Yer bilgisini vermez.
  B yolu bunu çürütebilir; çelişki günlüğe yazılır ama **teşhis sayılmaz** (Gün 4 ilkesi).
- Sağlıklı Marcus da yorgunluk/suçluluk nedeniyle kısa kesebilir (şüpheli ≠ enfekte); iki durumun metni ayırt
  ettirmeyecek kadar yakın olmalı.
- Sabotaj, saldırı, radyo kırma Gün 5'te YOK (sahip açıkça isterse ayrı tasarım).

## 6. Rastgele takvim etkisi

- Takvim (K-ARRIVALS-PARAMS-001): Marcus/Arthur G2–3'te gelir ya da reddedilir/kaçırılır; G5'te ikisi de evde
  olmayabilir → A+B yolu bunun için var.
- NarrativeBible taslağında G5 Grace, G4–8 Maya: içerikleri yazılmadığı için takvime girmezler (`requires_content`).
  Gün 5 tasarımı onların varlığını varsaymaz.
- Gün 5'te kapıya yeni ziyaretçi bu belgeyle eklenmez.

## 7. Sağlamlık matrisi

| Durum | Sonuç |
|---|---|
| Marcus sağlıklı & evde | C yolu açık (hız) |
| Marcus enfekte & evde | C yanlış yönlendirir (§5); B doğrusunu verir |
| Marcus yok / ölü / kovulmuş / reddedilmiş | C yok; A+B tam |
| Marcus izole | Yalnız kapı görüşmesi; ÖNERİ: C kapıdan da kullanılabilir (aynı sözler) |
| Arthur her durumda | D yalnız hızlandırır; yokluğu kayıp değil |
| Hiç sakin yok | A+B tam; Daniel yalnız |
| Daniel enfekte | Mevcut durum korunur; ÖNERİ: tarama sırasında kısa "tanıdıklık" satırı — yalnız sahip onayıyla |
| Güç onarılmış / onarılmamış | Radyo her iki durumda çalışır (pil); metin farkı yalnız atmosfer |
| A bulundu, B kaçırıldı | Doğa biliniyor, yer açık; sonraki günlerde ikinci yol (ileride Victor/Ruth/belgeler) |
| Hiçbiri bulunmadı | Kapanış serbest; basamak sonraki günlerde hâlâ bulunabilir |

## 8. Kayıt

Yeni alanlar `flags` içinde (şema v6 değişmez), Day4Broadcast gibi kendi `valid_state` doğrulamasıyla:
`day5_signal_scanned(_at)`, `day5_relay_document_read(_at)`, `day5_signal_claims` (kim, ne dedi, ne zaman),
`day5_review_completed(_at)`. Tüm eylemler `SaveManager.commit_candidate` ile önce kayıt, sonra canlı durum.
Eski kayıtlar: Gün 4'te kalmış kampanya sessiz geceyle Gün 5'e geçer; geçmiş günlere yeni kanıt eklenmez.

## 9. Sahibin karar vermesi gerekenler

1. Gün 4 gecesi: "sessiz gece" (öneri) mi, küçük bir gece sinyal olayı mı?
2. Keşif bedelleri (20 dk tarama, 40 dk belge, 10 dk konuşma) ve A+B'nin tek başına yeterli olması.
3. Enfekte Marcus'un şiddetsiz yanlış yönlendirmesi (§5) uygun mu?
4. Belgenin fiziksel yeri (depo kutusu mu, oturma odası çekmecesi mi) ve metin tonu.
5. Enfekte Daniel için "tanıdıklık" satırı açılsın mı?

## 10. Test planı (uygulama için)

- A+B yalnız Daniel ile, sıfır sakinle basamağı tamamlar; C/D/E olmadan kayıp yok.
- Her NPC durumu için (§7) çökme yok, yanlış kanıt yok, teşhis üretilmez; enfekte Marcus yalnız `claim` yazar.
- Bedeller tam; tekrar okuma ücretsiz; kayıt hatasında saat/kaynak/bayrak değişmez.
- Gün 4 gecesi tüketimi bir kez; Gün 3 güç durumu taşınır; eski Gün 4 kaydı Gün 5'e geçer.
- Rastgele takvimin G2/G3/kaçırma varyantlarında Gün 5 oynanabilir (ARRIVALS zincir testinin devamı).
- EN/TR metin sığması 720p/1080p/1440p; izole Run-Tests.
