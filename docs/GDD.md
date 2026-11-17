# THE QUIET HOURS — Oyun Tasarım Belgesi

Sürüm 0.1 · 2026-11-16 · Kararların kaynağı: `DecisionLog.md`

Bölüm durumları: **[Tam]** uygulanabilir · **[Taslak]** dengeleme bekliyor · **[Açık]** karar bekliyor

## 1. Yüksek konsept [Tam]

Evine aldığın her yabancı hayatta kalmanın hem şartı hem de en büyük tehdidi. Kimin kendisi olmadığını kanıtlayamazsın; yalnızca karar verebilirsin.

- Tür: psikolojik korku, sosyal çıkarım, barınak yönetimi.
- Bakış: birinci şahıs, tam 3D.
- Süre: 4–6 saat, 14 gün, 3 perde, 6 son.
- Platform: Windows. Motor: Godot 4.7.2.

## 2. Oyuncu fantezisi [Tam]

Kahraman değil, sıradan bir ev sahibi. Eksik bilgiyle adil olmaya çalışmanın ağırlığını taşır. Oyuncu "doğru kararı verdim mi?" sorusunu jenerik akana kadar taşımalıdır.

## 3. Sütunlar [Tam]

1. Güven gerekli ama tehlikeli.
2. Şüphe kanıt değildir.
3. Ev yaşayan bir sosyal sistemdir.
4. Gece her şeyi değiştirir.
5. Korku sonuçlardan gelir.

Yeni her mekanik bu beşinden en az birini güçlendirmek zorundadır; yoksa eklenmez.

## 4. Çekirdek döngü [Tam]

Sabah özeti → durum ve kaynak kontrolü → soruşturma ve konuşma → iş ve oda atama → kapıya gelenler → gece hazırlığı → uyu ya da nöbet tut → sonuçlar → yeni gün.

Her gün yeni bir sistem veya baskı tanıtır; iki gün aynı hissettirmemelidir.

## 5. Zaman [Tam]

- Serbest dolaşım saati ilerletmez. Anlamlı eylemler ilerletir.
- Fazlar: Sabah 07–12 · Öğleden sonra 12–18 · Akşam 18–23 · Gece 23–07.
- Geri dönüşsüz faz geçişinden önce uyarı gösterilir.

| Eylem | Süre (başlangıç değeri) |
|---|---|
| Kısa konuşma | 10 dk |
| Uzun sorgu | 20 dk |
| Kanıt inceleme | 10–20 dk |
| Onarım | 30–60 dk |
| Yönetim oturumu | 15 dk |
| Bekleme | seçilebilir |

**Gece (V-001):** dört blok — 23–01, 01–03, 03–05, 05–07. Her blokta oyuncu uyur ya da nöbet tutar. Nöbet bloğunda serbest dolaşılır, o bloğa atanmış olaylar gerçek zamanlı oynar, blok bitince saat ilerler. Her nöbet bloğu enerji harcar. Dört bloğun tamamında uyanık kalmak ertesi gün ağır yorgunluk getirir.

## 6. Barınak [Taslak]

**Kapasite:** yatak sayısına bağlıdır. Başlangıç 6 NPC, yükseltmeyle en çok 8. Yükseltme, onarım malzemesi ve marangozluk ya da onarım becerisi ister.

**Kaynaklar:** yiyecek, su, tıbbi malzeme, onarım malzemesi, yakıt. Tüketim saniye saniye değil, günlük çözümlemede olur. Açlık her zaman en az bir gün önceden uyarı verir. Su konusu açıktır (A-001).

**İşler:** yemek, temizlik, onarım, gece nöbeti, çocuk bakımı, envanter, güvenlik hazırlığı.
- Temizlik, korumaya alınmamış bir inceleme alanındaki kanıtı silebilir.
- NPC nöbet raporları yanlış olabilir; nedeni her zaman simülasyonda vardır (uyuyakalma, korku, yalan).
- NPC şu nedenlerle görevi reddedebilir: yaralanma, yorgunluk, korku, kişisel çatışma, beceri eksikliği, düşük güven.

**Odalar:** oda ataması kapasiteyi, mahremiyeti, gece gözlemini ve ilişkileri etkiler.

## 7. Sosyal sistemler [Taslak]

- **Güven (NPC → Daniel):** iç değer −100…+100. Oyuncuya beş kademe olarak gösterilir: Düşman, Güvensiz, Nötr, İş birlikçi, Sadık. Sayı gösterilmez.
- **Moral:** tek topluluk değeri. Yiyecek, güvenlik, uyku, adalet, şiddet, ölüm, onarım ve çatışma çözümünden etkilenir. Düşük moral tartışma, görev reddi, ayrılma girişimi ve liderliğe meydan okuma üretir.
- **İlişkiler:** yalnızca yazılmış anlamlı çiftler izlenir (hedef 25–30 çift). Güncelleme olay güdümlüdür.
- **Hafıza:** NPC başına bayraklar — kabul etti, sevdiğini reddetti, suçladı, izole etti, birini öldürdü, korudu, paylaştı, sırrını öğrendi.
- **Diyalog:** yazılmış, deterministik, koşullu varyantlı. Üretken yapay zekâ diyaloğu yok.

## 8. Enfeksiyon ve çıkarım [Tam, dengeleme hariç]

Kanonik 17 kural özgün spesifikasyondaki gibidir ve değişmez. Uygulama kuralları:

- Atama kampanya başında, seed ile, bir kez yapılır (V-005).
- 17 uygun NPC içinde 3–5 enfekte; ilk altı ziyaretçi teklifinden en az biri enfekte (K-005). Lily atamaya girmez (K-002).
- Her enfekte NPC için en az üç bağımsız kanıt fırsatı; her sağlıklı NPC için gerçek açıklaması olan en az iki şüpheli davranış (V-004).
- Hiçbir tekil belirti kesin kanıt değildir. Görünüş güvenilir test değildir.
- Günlük, "doğrulanmış olgu", "iddia" ve "şüphe"yi ayrı tutar; kimseyi otomatik etiketlemez.

**Daniel'ın enfeksiyonu:** yalnızca yazılmış, işaretlenmiş, kaçınılabilir riskli kararlarla. İlk fırsat 7. gündür.

| Durum | Anlamı | Geçiş (taslak, A-003) |
|---|---|---|
| Sağlıklı | Başlangıç | Riskli maruziyet → Maruz |
| Maruz | Belirti yok; oyuncu maruziyeti bilir | 2 gün sonra → Enfekte |
| Enfekte | Baş ağrısı, kulak çınlaması, kısa hafıza boşlukları, ortak bilinç parçaları | Gün 13 ve sonrası, koşullara bağlı → Nörolojik bozulma |
| Nörolojik bozulma | Özerklik kaybı eşiği | Son kararda WE'yi tetikleyebilir |

Algı bozulursa nedeni her zaman keşfedilebilir; geçerli kanıt keyfi halüsinasyonla geçersiz kılınmaz.

## 9. Gece olay yönetmeni [Taslak]

- Gün başında o gecenin olayları seed ile seçilir ve kaydedilir (V-002).
- Seçim şunlara uyar: mevcut sakinler, enfeksiyon durumları, oda konumları, yaralar, ilişkiler, kilitli kapılar, nöbetçiler, hikâye günü.
- Her gece şiddet olmaz. Enfekte yoksa enfekte olayı seçilemez.
- Müdahale seçenekleri: müdahale et, kapıyı kilitle, birini çağır, geri çekil, izle, bekle. Sonuç koşullardan hesaplanır; zar atılmaz.

## 10. Yargı ve şiddet [Tam]

| Karar | Bedel | Not |
|---|---|---|
| Soruşturmaya devam | Zaman; yeni olay riski | Kanıt yetersizken geçerli bir seçimdir |
| İzole et | Güvenli oda, gözetim, ilişki hasarı | Kusursuz çözüm değildir |
| Evden çıkar | Suçluluk, kırgınlık, ileride sonuç | Kaynak tüketimini azaltır |
| Öldür | Geri dönüşsüz; güven, moral, son | Açık onay ister; kısa, ölçülü sahne; nişan alma yok |

- **Lily:** öldürme seçeneği hiçbir koşulda sunulmaz. "İzole et" yerine "Noah ile gözlem altında tut" vardır. Evden çıkarılırsa Noah onunla gider (K-001, V-008).
- **Ton:** kan değil; tereddüt, ses, sonrasındaki sessizlik, değişen ilişkiler ve çevresel iz.
- **Hedef derecelendirme:** PEGI 16 / ESRB M sınırının altında kalacak şekilde ölçülü şiddet. Çocuğa yönelik şiddet gösterilmez.

## 11. Sonlar [Tam]

Girdiler: son seçim (BOZ, KENDİNİ İZOLE ET, TAHLİYE, KAL), Daniel'ın durumu, `ozerklik_kaybi`, `role_hazir`, `tahliye_hazir`, `topluluk_yikildi`.

- `role_hazir`: çekirdek kanıt seti tamam + röle ekipmanı hazır + teknik yardım (Maya, Sophie veya yavaş belge yolu).
- `tahliye_hazir`: 12. gün yayını değerlendirildi + yol hazırlığı yapıldı.
- `topluluk_yikildi`: 14. günde evde en çok bir NPC kalmış **ve** Daniel en az üç kişiyi öldürmüş ya da kovmuş.
- Koşulu sağlanmayan seçenek oyuncuya hiç sunulmaz.

Aşağıdaki tablo yukarıdan aşağıya değerlendirilir; ilk eşleşen kazanır.

| Sıra | Koşul | Son |
|---|---|---|
| 1 | `ozerklik_kaybi` | WE |
| 2 | BOZ ve `role_hazir` | BEYOND SILENCE |
| 3 | KENDİNİ İZOLE ET ve Daniel enfekte | THE LAST WATCH |
| 4 | TAHLİYE ve Daniel enfekte ya da maruz | WE (K-004) |
| 5 | TAHLİYE, sağlıklı, `topluluk_yikildi` | EMPTY HOUSE (V-011) |
| 6 | TAHLİYE, sağlıklı, `tahliye_hazir` | DAWN |
| 7 | KAL ve Daniel enfekte ya da maruz | WE |
| 8 | KAL, sağlıklı, `topluluk_yikildi` | EMPTY HOUSE |
| 9 | KAL, sağlıklı | THE LONG QUIET (K-003) |

Bu tablo `tests/` altında otomatik testle doğrulanacaktır: her girdi bileşimi tam olarak bir son üretmelidir.

## 12. Ev — tek katlı plan (2026-11-18 sahip yönlendirmesi)

Giriş holü ve kısa L koridor 3D yürünür. Oturma odası, yemek köşeli mutfak, kiler/onarım işlevlerini birleştiren servis odası, Daniel'ın odası, iki misafir odası, çok amaçlı oda, izolasyon odası, tek banyo ve küçük depo/çamaşır dolabı katmanlı 2D'dir. Servise mutfaktan, küçük dolaba banyodan geçilir; sekiz oda kapısı ve ana giriş yürüyerek erişilir. Üst kat ve merdiven yoktur.

Dış kabuk15x12.5m; giriş/mainhol4m, yatak kanadı2.5m brüt, oda kapıları1.05m, tavan3.1m. İki yönde pencere dış dünya bağlantısı kurar. Oda isim/işlevleri kaynak verisinden alınır; eski dining/pantry/bathroom_ground kayıtları kitchen/utility/bathroom_upper kimliklerine taşınır. Tek banyonun dahili adı eski kayıt uyumu için korunur, oyuncuya sadece Banyo gösterilir. Ayrıntı docs/HousePlan.md son tek kat bölümü ve HouseLayout. Yatak kapasitesi/enfeksiyon kuralları aynı.
## 13. Arayüz ve erişilebilirlik [Taslak]

- Ekranda kalıcı gösterge yok; yalnızca bağlamsal etkileşim ipucu ve saat.
- Ekranlar: ana menü, ayarlar, duraklatma, envanter, günlük, kanıt panosu, NPC profilleri, barınak durumu, iş atama, oda atama, gün özeti, diyalog, karar onayı, son özeti, jenerik.
- Erişilebilirlik: metin boyutu, konuşmacı adlı altyazı, renkten bağımsız durum işaretleri, parlaklık, fare hassasiyeti, kamera hareketi azaltma, retro efektleri kapatma, tuş atama. Kritik ipucu yalnızca renkle ya da yalnızca sesle verilmez.

## 14. Kapsam dışı [Tam]

FPS dövüşü · açık dünya · crafting ağacı · çok oyunculu · prosedürel sonsuz mod · üretken yapay zekâ diyaloğu · fizikle nesne tutma · zıplama · koşu dayanıklılığı.

## 15. MVP — dikey kesit [Tam]

**İçeride:** Gün 1–3 · tam ev blockout'u · Elena, Marcus, Arthur · diyalog, kabul/ret · iş ve oda atama · yiyecek ve yakıt · güven · gece nöbet blokları · elektrik kesintisi olayı (üç olası neden) · günlük ve kanıt · izolasyon, kovma, öldürme · kaydet/yükle · retro görüntü hattı.

**Dışarıda:** diğer 15 NPC · oyuncu enfeksiyonu · sonlar · kapasite yükseltme · nihai model, animasyon, müzik · Türkçe içerik (altyapı hazır) · tam ayarlar menüsü · sinematikler.
