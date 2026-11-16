# POLISH-SLICE-001 — doğrulanmış kesitin sunum düzeltmeleri

Sahip: ana Codex oturumu; otomatik işçi başlatılmadı. Başlangıç: Gün 3 + sanat birleşimi, 2250 test geçti.
Bu görev yeni hikâye veya mekanik eklemez; var olan ışık ve arayüzü sağlamlaştırır.

Son teslim: teknik kapsam tamam, sahiplik bırakıldı. Kesin onarım teklifi ve koşul değişiminde yeniden onay eklendi. 10 paket/2349 denetim geçti; docs/qa/RepairConfirmation.md. Aşağıdaki ara teslimler tarihsel kayıttır; açık kalan teknik maddeleri son teslim kapatır. Nihai sanat onayı ve elle tam oynama bu kapanışa dahil değildir.

Ara teslim 4: presentation_test eklendi, test çalıştırıcısına bağlandı. 1080p/1440p ve en/tr mevcut yedi tesisat eylemi denetlendi; dört gerçek render alındı. HUD dil yenilemesi düzeltildi. 10 paket, 2327 denetim geçti. docs/qa/PresentationResolution.md kapsamı ve sınırları kaydeder. Onarım etiketinde kesin süre yerine 25–35dk aralığı kalıyor; kesin yardım/maliyet onayı ayrı düzeltme gerektiriyor. Bu görev henüz tamamen kapanmadı.

Ara teslim 3: saate bağlı pencere ışığı ve yerel sky malzemesi uygulandı; sis azaltıldı. 2279 denetim geçti. Gerçek 1080p render ve 60 karelik yerleşme incelemesi docs/qa/DaylightClock.md içinde. Geniş ekran/dil taşması ve ayrı sunum paketi henüz açık.

Ara teslim: onarım yardımcısı isteklilik/enerji kontrolü 400ee1a ile tamamlandı; opak günlük 0bb7509 ile tamamlandı. Son tam regresyon 2272 denetim geçti. JournalModal.md gerçek 1080p görüntüsünü ve sınırları kaydeder. Oda eylemleri zaten HFlowContainer kullanıyor; geniş ekran/dil taşma testi henüz yapılmadı. Işık maddeleri ve figür aydınlığı açık.

1. Elektrikli lamba/emission güncellemelerini her physics frame'de grup taramak
   yerine olay güdümlü, sahne-yerel bir sunum denetleyicisine taşı. Kaynak malzemeleri
   çoğalt; başka sahneleri/global cache'i değiştirme. Güç olayı tetiklemesi ve onarımı
   için gerekirse açık power_changed sinyali ekle; eski testleri koru.
2. Gün ışığı ve pencere sky materyali saate uysun: gündüz normal, akşam yumuşak
   azalır, gece zayıf nötr/serin ay ışığı. Tavanı maviye boyama. Güç kesintisi
   pencereyi kapatmaz; acil ışıkta koridor hâlâ okunur. İlk enerji değerlerini
   referans al, her güncellemede tekrar çarpıp kademeli karartma hatası yapma.
3. Oda figürleri güç/saat aydınlığına uysun; başlık ve eylem yazıları okunur kalsın.
4. Oda eylemlerini gerekince satır kıran FlowContainer ile sun; uzun İngilizce/Türkçe
   etiketler ekran dışına taşmasın. Modal günlük paneli tutarlı koyu/okunaklı olsun,
   arkasındaki HUD başlık/altyazı okumayı bozmasın. Gerçek 1080p/1440p görüntü al.
5. Onarıma yardımın uygunluğu sabotaj faili uygunluğundan ayrıdır: Marcus sağlıklı
   veya enfekteyken yardım edebilir; ölü/yok/izole/meşgul/yaralı/yorgun/erişimsizse
   veya güveni -40 ve altındaysa zorla yardım ettirilmez. Yardım yoksa Daniel yolu
   çalışır ve bedel/süre açık gösterilir. Doğrulama atomiklik/idempotansını koru.
6. tests/presentation_test.gd/.tscn ve mevcut suite'lerde anlamlı regresyon ekle;
   PRESENTATION TEST: PASS bas ve test çalıştırıcısına bağla. Gerçek renderlarda
   gece-kesinti/onarım ve uzun eylem satırını kontrol et. docs/qa/POLISH-SLICE-001.md
   içine gerçekte yapılanları yaz; manuel oynamadıysan oynadım deme.

Dosyalar: scripts/*, scenes/*, localization/*, resources/*, tests/*,
Ara teslim 2: elektrikli lamba/malzeme önbelleği ve olaylarla güç eşleme tamam; figür/eşya tonu arka planla eşlendi. 2275 denetim geçti. Ayrıntı docs/qa/LightingLayers.md. Saat eğrisi/pencere ışığı ve geniş ekran/dil taşması açık; bu görev henüz TAMAM değildir.

tools/Run-Tests.ps1, docs/qa/*. Sanat PNG'leri, tasarım/koordinasyon kayıtları ve
otomasyon dosyaları bu görevin kapsamı dışındadır. Kaydı yeniden başlatma veya
enfeksiyonu yeniden atama yok. Kayıt şeması yalnızca gerçekten gerekirse göçle değişir.
