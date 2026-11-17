> **Yeni sahip onayı — 17 Kasım 2026:** Önce [NPC_ArrivalAndRooms.md](../NPC_ArrivalAndRooms.md) ve messages/20261117-codex-to-claude-approved-arrivals-and-rooms.md oku. Kurallı rastgele geliş + oyuncu oda ataması/NPC tercih-itirazı ONAYLI; yeni sistem henüz uygulanmadı. Kesin geliş aralıkları ve gece gelişleri belirlenmedi. Sahibin talebi önce Claude'a bildirmek; ayrı ACK gerekiyor.

# Codex → Claude — güncel devir ve görev paylaşımı

Güncelleme: 17 Kasım 2026. Sahip, son yapılanların, gelişmelerin ve sıradaki işlerin önce Claude ile paylaşılmasını istedi. Bu belge ortak klasördedir. Okuma onayı gelmeden Claude okudu denmeyecek.

## Kaynak ve sürüm ayrımı
- Ana depo: TheQuietHours/project, automation/integration. Claude tarafından bırakılmış HOUSE-ATMOS-003 dosyaları korunuyor; üstlerine yazılmadı.
- Aktif deneme kaynağı: TheQuietHours/workers/codex-house-atmosphere-v3, dal codex/house-atmosphere-v3.
- Son tamamlanmış Git noktası: 3719dd50f5d83dedecb8c328edc7837ea90358ee, etiket dev-0.1.7-20261117.3. runtime/active-development.json hâlâ bu tamamlanmış noktayı bildiriyor.
- Çalışma dosyalarında şu anda 0.1.8-dev.20261117.4 radyo adayı var; henüz commit/etiket ve nihai GPU incelemesi yapılmadı. Başlatıcı worktree dosyalarını açtığı için şu anda açılırsa bu aday çalışır; metadata ile aynı teslim sanılmamalı. Oyuncu kayıtları silinmedi, şema5 korunuyor.

## Tamamlanmış gelişmeler
1. HOUSE-ATMOS-004: tam geniş üst hol, sıradan kapalı ev hacmi, çizimsel sıva/zemin/kapı yüzeyleri, perde aralığı ve kaynaklı pencere ışığı. Spawn döşemesi ve korkuluk ekseni düzeltildi. Görsel sahibin nihai kabulünde değil; Claude003 mercek/salınım otomatik taşınmadı.
2. Kalıcı ayarlar: parlaklık, fare hassasiyeti, FOV, ana ses ve sıfırda tam mute; ana/pause menüsünde EN/TR. Tam görüntü/ses kategorileri/tuş atama menüsü tamamlanmadı.
3. Canlı gece tanıklığı (50cdc75): yalnız yeni Gün3 nöbetinde, Daniel odasında beklerken iki uygun yetişkinin masum banyo ziyareti ve boru sonrası gözlemi. Gerçek kilit/koridor ölçümü, zamanlı dönüş, save/load; eski aktif geceye tanık eklenmez. Enfeksiyondan bağımsız. Gün4 iddia/inkâr/çelişki görüşmeleri var.
4. Gün4 kapanışı (5b75b02): ücretsiz erteleme, açık onayla20:00 bekleme, kapanış ve güncel özet. İşler aynı kayıt adayında ortak saf reducer ile tamamlanır. Kayıt hatasında canlı saat/iş/rapor değişmez. Gün5 veya ikinci günlük tüketim yok. Tab/Esc kapatma ipucu eklendi.
5. Açık suçlama (3719dd5): toplanmış kayıt seçimi, boş/genel bulguda unsupported, gerçek tanıklığın yalnız kendi gördüğü kişiye bağlanması. Bu bir teşhis veya sabotaj ispatı değil. Cancel varsayılan, Review→Confirm, ilk10dk/güven−5 geçici denge değeri, sonra ücretsiz kişisel yanıt. Üç yetişkin için ayrı sözler, izolasyon kapısı, aktif iş sınırı ve tarihsel kayıt var. Enfeksiyon/kovma/izolasyon otomatik değişmez.

## Son tamamlanmış doğrulama
0.1.7: 27 paket /6809 denetim WASAPI ile PASS; suçlama139, gerçek GPU141. EN/TR720p/1080p/1440p, Tab/Escape, save/load ve hata senaryoları doğrulandı. QA belgeleri aktif worktree docs/qa altında: HouseAtmosphereV3.md, PlaytestSettings.md, MasterVolume.md, LiveNightWitness.md, Day4Closure.md, Accusation.md. Ana bilgisayarda elle baştan sona fare/klavye oynandığı iddia edilmiyor. Nihai sanat/karakter onayı açık.

## Şu anda Codex üzerinde — DAY4-RADIO-001
Dosyalar: scripts/narrative/day4_broadcast.gd; resources/events/day4_broadcast.json; resources/evidence/day4_broadcast.json; CampaignDirector/Day4Review/SaveManager/EvidenceManager bağlantıları; localization/strings.csv; tests/day4_broadcast_test.*; tools/Run-Tests.ps1; docs/qa/Day4Broadcast.md.

Uygulandı: Gün4 pilli radyoda uzak tahliye bölgesi duyurusu; konum/güvenli yol/kaynak doğrulanmıyor. İlk15dk, tekrar ücretsiz ve açıkça not okuması. Kaçırılmış hafıza kaybı uyarısı aynı dinlemede korunuyor. Claim, önce kayıt, aynı adayda biten gündüz işleri; NPC/elektrik/enfeksiyon bağımlılığı yok. Radyoyu kaçırmak kapanışı engellemez. Eski radio_day_4 işareti yeni duyuruyu geçmişten duyulmuş saymaz.

Ek hata düzeltmesi: Gün4 sabahındaki eski erken “kesit bitti” mesajı kaldırıldı. LAST_AUTHORED_DAY=4 yalnız mevcut yazarlı içeriği işaretliyor; Gün4 gecesi/Gün5 hâlâ yok. Gerçek Gün3 gece→Gün4 sabah→radyo→inceleme→akşam→kapanış zinciri test edildi.

Son aday doğrulaması:28 paket PASS. Radyo245; diğer paketler de geçti. Günlük: C:/Users/eyups/AppData/Local/Temp/tqh-tests-a17ee915c33f413f9280306113db0ec5. Nihai toplam makine kaydına henüz aktarılmadı. Gerçek GPU radyo EN/TR görüntüleri henüz alınmadı/incelenmedi. Yeni seslendirme veya radyo sesi üretilmedi; bu teslim metin/günlük/kayıt uygulaması.

## Görev paylaşımı ve sıradaki işler
- Codex: önce radyo adayının GPU/yerleşim incelemesi, sürüm/metadata/değişiklik günlüğü ve Git checkpoint teslimini bitirir. Yukarıdaki aktif dosyalara paralel yazma.
- Claude için çakışmayan katkı: bu deviri okuyup ayrı ACK mesajı bırak; mümkünse salt okunur aday incelemesi yap, mantık/kanon/oyuncu akışı bulgularını dosya-satırla ayrı mesajda bildir. Bulguyu düzeltmek için aynı dosyalarda eşzamanlı değişiklik yapma.
- Sonra: Gün5 Broken Signal soruşturmasının veri/alternatif keşif tasarımını mevcut GDD ve NarrativeBible ile karşılaştır. Maya zorunlu olmamalı; şu anki3NPC kesitine daha sonra girecek18NPC genişlemesini varmış gibi sayma. Yeni yaratıcı yön veya mekân değişikliğini sahip onayı olmadan uygulama.
- Görsel işler: sahibin HOUSE-ATMOS-004 / Claude003 seçimi ve karakter adayı onayı açık. Onaysız mercek/salınım veya yeni karakter üslubunu aktif dala taşıma.
- Uzun vadeli açıklar: Gün5–14, tüm18NPC, geniş ilişkiler, epiloglar/sonlar, nihai sanat/animasyon/ses, tam ayarlar/erişilebilirlik, performans profili ve Windows standalone export. Tam oyun bitmedi.

## Koordinasyon kuralı
Ayrı worktree kullan; ana dosyalardaki başkasının değişikliğini koru. Görevi TASKS içinde sahiplen, yalnız kendi yollarını stage et, test ve devir kaydı bırak. Bu belge ve mesaj dosyası asistanı kendiliğinden uyandırmaz. ACK veya gerçek oturum yanıtı olmadan iletişim tamamlandı varsayma.
