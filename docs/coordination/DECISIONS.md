# Karar karşılaştırmaları

Sahibin ölçütü: “Hanginizin verdiği karar daha optimal ve projeyi ileri götürür?”

Her öneriyi aynı koşullarda değerlendir. Puan uydurmak yerine kanıt ve maliyet yaz:

| Alan | Doldurulacak bilgi |
|---|---|
| Kimlik / öneren | Örn. TECH-001 / Claude veya Codex |
| Somut sorun | Oyuncunun veya geliştiricinin yaşadığı davranış |
| A / B seçenekleri | Aynı soruna uygulanabilir iki çözüm |
| Vizyon uyumu | Onaylı kararlarla çelişiyor mu? |
| Oyuncuya etkisi | Hangi deneyimi nasıl iyileştiriyor? |
| Üretim maliyeti | Kod, görsel, yazım, QA ve bakım yükü |
| Bağımlılık / risk | Kayıt uyumu, performans, geri alma |
| Kanıt | Test, profil, görüntü veya oynanış gözlemi |
| Seçim / gerekçe | En düşük maliyetle hedefi karşılayan çözüm |
| Onay | Teknik karar veya sahibin yaratıcı onayı |

Kabul edilen yaratıcı kararları ayrıca docs/DecisionLog.md'ye geçir.
Asistan kıdemi, model adı veya önce yazmış olmak karar gerekçesi değildir.

## Kayıtlar

Proje sahibi 2026-11-16'da rutin kararları asistanlara bıraktı ("siz karar verin").
Aşağıdaki kararlar bu yetkiyle alındı; sahibi istediği an değiştirebilir.

### ART-001 — Oda görsellerinin üslup referansı (öneren: Claude; kaynak iş: Codex)

| Alan | Bilgi |
|---|---|
| Somut sorun | 13 odanın görseli üretilecek; ortak bir üslup hedefi olmazsa odalar birbirini tutmaz. |
| A | Codex'in `assets/rooms/living_room.png` görselini referans almak: boyanmış gerçekçilik, sade kirli sarı duvar, perdeden gün ışığı, sıcak lamba, hafif pus. |
| B | ArtBible §4'teki ilk şablon: "kaba fırça, kalın koyu kontur" çizim üslubu. |
| Vizyon uyumu | A, K-013 (pürüzsüz, PS1 yok), K-014 (atmosfer ışıkla) ve K-015 (dengeli palet) ile birebir uyumlu. B'nin kalın konturu hiçbir onaylı kararda yok; benim eski bir tahminimdi. |
| Oyuncuya etkisi | A, proje sahibinin gönderdiği üçüncü referansın ışık ve atmosferine en yakın sonuç. |
| Üretim maliyeti | A zaten üretildi ve çalışıyor; B sıfırdan deneme gerektirir. |
| Bağımlılık / risk | A ile 3D koridorlar arasında belirgin kalite farkı var (ART-002). |
| Kanıt | `docs/art/previews/living_room_in_game.png`, `docs/screenshots/06_living_room_actions.png`; altı test geçti. |
| Seçim / gerekçe | **A.** Onaylı kararlara uyan ve kanıtı olan tek seçenek. ArtBible §4 şablonu buna göre güncellendi. |
| Onay | Sahibin devrettiği yetkiyle asistanlar; nihai sanat onayı sahibindedir. |

### ART-002 — Koridor ile oda arasındaki kalite farkı (öneren: Claude)

| Alan | Bilgi |
|---|---|
| Somut sorun | 3D koridorlar kodla üretilen kutular ve dokulardan oluşuyor; boyanmış oda görselinin yanında yapay duruyor. Oyuncu kapıdan her geçişte bu farkı görecek. |
| A | Şimdi koridoru yükseltmek: boyanmış dokular, daha iyi eşya. |
| B | Önce oynanışa görünen eksikleri kapatmak (diğer odalar, karakter figürleri, Gün 2 işleri), koridoru sonra ele almak. |
| Vizyon uyumu | İkisi de uyumlu. |
| Oyuncuya etkisi | Şu an 13 odanın 12'si ve bütün karakterler yer tutucu; bunlar koridor dokusundan çok daha fazla ekran süresi kaplıyor. |
| Üretim maliyeti | A: doku üretimi + döşeme (tiling) sorunları + yeniden ışık ayarı. B: ek maliyet yok. |
| Bağımlılık / risk | B'de fark bir süre görünür kalır; risk olarak kayıtlı. |
| Kanıt | Ekran görüntüleri 03 (koridor) ve 06 (oda). |
| Seçim / gerekçe | **B.** Aynı emekle daha çok yer tutucu kapanır. Koridor dokuları odalar ve ilk üç karakter bitince ele alınır. |
| Onay | Teknik/üretim sırası kararı. |

### TECH-001 — `main` dalı ve görev dalları (öneren: Claude)

| Alan | Bilgi |
|---|---|
| Somut sorun | `main` Gün 1'de (2169bad) kalmıştı; sonraki dört teslim birbirinin üstüne açılan görev dallarında birikti. Hangi durumun "doğrulanmış son sürüm" olduğu belirsizdi. |
| A | `main`'i, altı testi geçen son duruma ileri sarmak (fast-forward); yeni görev dallarını `main`'den açmak. |
| B | Olduğu gibi bırakmak; dalları zincirleme sürdürmek. |
| Vizyon uyumu | Etkilemez. |
| Oyuncuya etkisi | Dolaylı: bozuk durumun temel alınması riskini azaltır. |
| Üretim maliyeti | A: tek komut, geçmiş yeniden yazılmaz. B: sıfır, ama belirsizlik büyür. |
| Bağımlılık / risk | Ortak klasörde HEAD tektir; bu yüzden dal değiştirmeden `git fetch . HEAD:main` ile yalnızca `main` göstergesi ilerletildi. Çalışma ağacı değişmedi. |
| Kanıt | `git merge-base --is-ancestor main HEAD` = evet; `tools/Run-Tests.ps1` altı test geçti. |
| Seçim / gerekçe | **A.** Kural: `main` yalnızca tüm testler geçtikten sonra, ileri sarma ile ilerler; force yok. |
| Onay | Teknik karar. |

### NPC-ARRIVALS-ROOMS-001 — Sahibin onayladığı geliş/oda yönü
| Alan | Bilgi |
|---|---|
| Sorun | Sabit geliş günleri tekrar oynanışta ezberleniyor; oda kararlarında karakter tercihleri henüz yok. |
| A | Bütün ziyaretler sabit, yalnız mekanik yatak ataması. |
| B | Kampanya seed'ine bağlı geliş pencereleri ve ziyaretçi seçimi; oyuncu son oda kararını verirken NPC tercih/itiraz bildirir. |
| Oyuncuya etkisi | Belirsizlik ve tekrar oynanabilirlik; kişisel ilişki ve barınak kararları anlam kazanır. |
| Bağımlılık/risk | Eski kayıt takvimi, öğretici Elena gelişi, ret/eksik-NPC alternatifleri, gerçek yatak ve izolasyon kuralları. |
| Seçim | B; kesin parametreler henüz tasarlanmadı, uygulanmadı. |
| Onay | Sahip açıkça “onaylıyorum” dedi; önce Claude'a bildirilmesini istedi. |
| Kaynak | docs/NPC_ArrivalAndRooms.md, K-NPC-ARRIVALS-ROOMS-001. |
