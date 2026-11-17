# Otomatik koordinasyon — AUTO-ARRIVALS-CHAIN / worker

2026-11-17T07:05:47.920973+00:00

claude: Görev tamamlandı ve testler geçti. G3 Marcus ziyaretinden Gün 4 kapanışına kadar uzanan zincir testi yazıldı, Run-Tests.ps1'e -SelectedTests eklendi. Gerçek bir oyun kodu hatası bulunmadı, kapsam dışı yama yapılmadı. Yalnız izinli üç dosya değişti; commit yapılmadı ve dal değiştirilmedi.

1. tests/arrival_integration_test.gd: Mevcut 22 kontrol olduğu gibi duruyor. İlk bölümün CampaignDirector ve DialogueRunner düğümleri serbest bırakılıyor, böylece kapıyı ve saati tek yönetici dinliyor. Ardından Marcus'u Gün 3'e, Arthur'u Gün 2'ye koyan ilk seed aranıyor (0–3999) ve üç dal koşuyor.
   - Kurulum oturum sahnesiyle aynı: ShelterManager, DialogueRunner, CampaignDirector.
   - İzin verilen G3 başlangıç kurulumu: Elena G1'de yatağını almış, Arthur'un G2 ziyareti yanıtsız kalmış, gün 3 saat 07:00. G3 sonucu state bayrağıyla atlanmıyor.
   - Her adım gerçek eylemlerle atılıyor: önce eylemin o anda sunulduğu kontrol ediliyor, sonra perform_room_action ve gerçek marcus_arrival seçimleri kullanılıyor.
   - Dallar:
     - **Kabul:** work sorusu, ardından bed:guest_b_1 seçimi. Oda modülü kontrolü: apply_plan Marcus'u multipurpose odasına taşıyor (15 dakika, tek oda; aynı planın tekrarı süre harcamıyor). Gece sleep, saat 23:00'te kesinti, panel incelemesi ve onaylı onarım (Marcus yardımcı, 25 dakika). Gün 4'e gerçek sleep ile geçiliyor.
     - **Ret:** reject ve confirm. İzleme iki basışla onaylanıyor, kesinti oluyor, onarım erteleniyor. wait_watch döngüsü 07:00'ye kadar sürüyor (NightSession.finish). Gün 4 sabahı Daniel tek başına onarıyor (35 dakika).
     - **Kaçırma:** Kapı açılmıyor. Dinlenme bir kez uyarı veriyor, pencere bitince Marcus "left" oluyor ve kaçırılan ziyaret kaydediliyor. Gece sleep, kesinti, erteleme, sleep. Kesinti Gün 4 boyunca sürüyor.
   - Her dalda kontrol edilenler:
     - Kaydet/yükle sonrası to_dict birebir aynı (kapı kararından sonra, Gün 4 sabahı, kapanıştan sonra).
     - Takvim ve enfeksiyon baştan sona değişmiyor; d3_marcus ziyareti tam bir kez çözülüyor.
     - Gece yiyecek ve su yalnız bir kez, kişi sayısına göre tüketiliyor.
     - Fail uydurulmuyor.
     - Radyo 15 dakika sürüyor ve kaydediliyor; ikinci dinleme bedelsiz.
     - Kapanış: review_last_night, ardından day4:wait ×2 (20:00) ve day4:complete ×2. Özet gerçek güç durumunu gösteriyor; sonraki sleep yalnız NARR_END_OF_BUILD döndürüyor ve durumu değiştirmiyor.

2. tools/Run-Tests.ps1: İsteğe bağlı [string[]] -SelectedTests eklendi.
   - Yalnız 29 paketlik beyaz listeden ad kabul ediliyor. Virgüllü liste bölünüyor, çünkü -File ile tek dize olarak geliyor.
   - Boş, bilinmeyen ya da tekrarlanan ad; Godot yolu çözülmeden ve geçici klasör ya da dosya yazılmadan reddediliyor (çıkış 1).
   - Seçili modda da aynı izole proje kopyası, benzersiz kullanıcı klasörü ve import adımı kullanılıyor.
   - Seçili modun ayrı sonuç metni var ("Selected N test suites passed: ... This is a partial run, not the full suite.").
   - -AudioDriver verilirse audio_lifecycle_test ek olarak koşuyor; N'ye sayılmıyor ve ayrı satırda bildiriliyor. Adla seçilemiyor.
   - Parametre verilmezse eski davranış ve "All 30 test suites passed" metni değişmedi.

3. docs/qa/CombinedArrivals.md:
   - İçerik: gerçek sonuçlar, seçili paket komutu, WASAPI sayımı ve sınırlar.
   - Sınırlar: işlevsel NPC sayısı 3 (Elena, Marcus, Arthur; Noah/Lily ve Maya'nın diyaloğu yok, takvime girmiyor) ve mevcut dilim 4 gün.
   - Sınanmayanlar: sabotaj dalı, sahnesiz tanık kaydı, RoomPreferences değerlendiricisi.

Dürüstlük notları:
- **WASAPI 30 paket kapısını ben çalıştırmadım.**
- Tam çalıştırmada presentation_test için "Object lifetime warning" uyarısı çıktı. Bu paket değişmedi; uyarının daha önce de çıkıp çıkmadığını karşılaştırmadım.

Kaynak: runtime/continuous/state.json. Bu CLI çalışanı çıktısıdır; masaüstü sohbet ACK'i değildir.
