# ARRIVALS-002 birleşik kayıt doğrulaması

## Hedef ve kaynak
Claude'un8fa1409 tesliminin aktif0.1.13 (1830de6) tabanına kontrollü entegrasyonu. Rastgele ziyaret üretimi yeniden tasarlanmadı; yalnız kayıt dosyası doğrulaması ve test koşucusu temizliği güçlendirildi. I11 mimari ve I07 çizim seçimine yazılmadı.

## Dosyalar ve düğüm bağlantısı
scripts/narrative/arrival_scheduler.gd: valid_schedule_for_version; v0 eski sabit takvimle tam eşleşme, v1 sabit kurallar. En fazla2ziyaret/gün, ziyaretler arası en az90dk;07:00–23:00 sınırı, gün/id eşleşmesi, benzersiz kişi/ziyaret, sabit Elena öğreticisi korunur. Mevcut havuz değişirse eski v1 kayıtlarını geçersiz kılmamak için bu kontroller havuz dosyasından okunmaz. İlk teslim erken gece02:00'yi kaçırıyordu; Codex V1_EARLIEST_START ve eksik öğretici/nonstr kimlik/boş diyalog kontrollerini ekledi.

scripts/save/save_manager.gd: mevcut _valid_state_shape takvim bölümüne bağlandı. Kapıda bekleyen kişi başlamış ziyarete ait olmalı; aynı ziyaret iki kez çözümlenemez. Yeni autoload/sinyal/düğüm yok; SaveManager→ArrivalScheduler saf doğrulayıcı çağrısı. Roster kimlikleri mevcut kaynaktan alınır. Save schema6 değişmedi. Enfeksiyon/seed/takvim yeniden çekilmez. Eski takvim alanı bulunmayan v5 kayıtları GameState migration ile sabit v0 takvimini korur.

tests/arrival_validation_test.gd ve .tscn: saf bozuk/geçerli takvim denetimleri;300seed, JSON sayısal roundtrip, sürüm, çakışma, kapı sakini, mükerrer çözümleme. Mevcut arrival_integration_test v5→v6 dosya yükleme, bekleyen kişi, reddet/kabul, eski takvimin yeniden çekilmemesi ve enfeksiyonun sabitliğini gerçek oturumla sınar. save_write_test yazma/publish hatasında eski kaydın korunmasını sınar.

tools/Run-Tests.ps1: iki dalda çakışan test listesi birleştirildi; arrival_validation ve stairs birlikte korunur, yalnız stairs süresi≥300s. Başarılı koşu yalnız kendi rastgele tqh-tests-<32hex>/project ve APPDATA/TheQuietHours-Tests/tqh-tests-<aynıid> dizinlerini temizler. Recursive silmeden önce bütün mutlak yollar beklenen kök/isimle karşılaştırılır. Diğer test dizinleri taranmaz. Loglar tutulur; hata koşusu silme bölümüne ulaşmaz; -KeepProjectCopy native inceleme için kopyayı tutar. Önceki toplu klasör silme davranışı eklenmedi.

## Kurulum ve test
Godot4.7.2/Forward+ mevcut proje, ek editör kurulumu veya varlık indirmesi yok. Normal kullanıcı kayıtlarına test yazılmaz. İlgili koşu:
Run-Tests.ps1 -SelectedTests arrival_scheduler_test,arrival_integration_test,arrival_validation_test,save_write_test,day12_integration_test -AudioDriver WASAPI

Seçili5paket+WASAPI PASS; runtime/arrival002-integration-focused.log. Takvim doğrulaması30, entegrasyon249, kayıt yazma58, Gün1–2 entegrasyonu997 kontrol. Diskte bu koşunun project kopyasının gerçekten silindiği ve arrival_validation stdout logunun kaldığı ayrıca kontrol edildi. Bunun tam regresyon olduğu iddia edilmez. Geniş32paket koşusu runtime/arrival002-integration-full.log; sonuç tamamlandığında aşağıya kaydedilir.

## Beklenen davranış ve sınırlar
Mevcut geçerli kayıt aynı ziyaret gün/saatleri ve enfeksiyonuyla açılır. Bilinmeyen sürüm/bozuk takvim sessizce yeniden üretilmez; mevcut yükleme başarısızlığı arayüzü kullanılır. Bu bütün olası elle değiştirilmiş JSON'ların anlamsal doğruluğunu ispatlayan genel model değildir; takvim/kapı tutarlılığıyla sınırlıdır. Tüm sürümlerin gelecekteki içerik değişiklikleri v1 kontratını değiştirmemeli, yeni algoritma sürümü tanımlanmalıdır.

## Bitti tanımı ve sonraki bağımlılık
İlgili testler, birleşik tam regresyon ve güvenli temizlik geçtiğinde entegrasyon teslimi tamamlanır. Oyun sanatının/14günün tamamlanması değildir. Aktif sürüm değişikliği ayrıca root launcher ve PrepareOnly doğrulamasıyla belgelenmeli. Sonraki bağımlılık I07 sahip çizim seçimi ve I11 oran teslimi; bu kayıt işi onları bekletmez.
## Son birleşik sonuç
32paket/7662raporlanmış kontrol WASAPI PASS, süreç0; runtime/arrival002-integration-full.log, tqh-tests-8aaa3fc3a95242229a4d1362f6bd69de. Merdiven30 gerçek yürüyüş kontrolü dahil. Tam koşu güncel tüm oyun/test koduyla yapıldı; sonrasında yalnız sürüm etiketi0.1.14 ve teslim belgeleri güncellendi. Görsel kaynaklar0.1.13 ile aynı, yeni GPU görüntüsü alındığı iddia edilmez. Geçerli v5→v6, yeni v1 takvim ve enfeksiyon korunumu geçti. Normal oyuncu kayıtları açılıp yeniden yazılmadı.
