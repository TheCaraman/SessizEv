# SAVE-SAFE-001 — güvenli kayıt yazımı temeli

## Teslim ve davranış

scripts/save/save_manager.gd artık geçerli aday durumu bellekte doğrular, aynı dizindeki `<slot>.json.pending` dosyasına yazar, flush/hata kontrolü yapar, içeriği birebir okur ve şemayı yeniden doğrular. Ardından mevcut `.json` dosyasını `.json.backup` olarak taşır ve pending dosyasını boş hedef adına yayınlar. Yayın başarısızsa eski kayıt geri taşınır. Geri taşıma da başarısızsa yükleyici, ana dosya yokken backup üzerinden eski durumu açabilir. Pending hiçbir zaman yüklenmez. Başarılı kayıttan sonra bir önceki backup korunur; silme üç dosyayı birlikte kaldırır.

Yeni Node/autoload, kaynak veya kayıt sürümü yok. Mevcut SaveManager autoload kullanılır; Godot 4.7.2 ile normal içe aktarma yeterli. Slot adı boş, noktalı veya geçersiz dosya adı olamaz. Eski v1–v5 yükleme doğrulaması korunur. Var olan bozuk ana dosyadan otomatik backup seçilmez; bozuk dosya menüde hâlâ kullanılamaz sayılır.

## Neden doğrudan rename değil?

[Godot 4.7.2 Windows kaynak kodu](https://github.com/godotengine/godot/blob/4.7.2-stable/drivers/windows/dir_access_windows.cpp) rename işlevinde mevcut hedefi önce kaldırır. Bu nedenle yayınlama hedefi önceden boşaltılır ve önceki kayıt ayrı ad altında tutulur. Bu, donanım arızası veya elektrik kesintisine karşı kanıtlanmış dosya sistemi atomikliği iddiası değildir. İki oyun sürecinin aynı slota eşzamanlı yazması desteklenmez. İşletim sistemi önbelleği/disk bozulması ve gerçek disk-dolu deneyleri yapılmadı.

## Test

tests/save_write_test.gd/.tscn, gerçek dosya yazımı ve yüklemeyle ilk yayın, tekrar kayıt, retry ve silmeyi çalıştırır. Alt sınıf yalnız I/O sınırlarında yazma, kısa dosya, eski kaydı taşıma, yeni kaydı yayınlama ve rollback hata kodları enjekte eder. Her durumda önceki baytların korunduğu, eski durumun açılabildiği ve yazıcının canlı kampanyayı değiştirmediği kontrol edilir. 37 denetim geçti. Hata enjeksiyonu gerçek disk arızası diye sunulmaz.

Komut: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run-Tests.ps1`. Koşucu yeni paketi ilk sırada çalıştırır; kullanıcı kayıtları yerine ayrı test kopyası/veri dizini kullanır.

## Sınırlar ve sonraki bağımlılık

Mevcut oyun eylemleri önce canlı durumu değiştirebilir; bu teslim onları transaction sistemine dönüştürmez. Gün 4 geri alınamaz kararlarında aday kampanya → başarılı kayıt → canlı durum/sinyaller sırası ayrıca uygulanmalıdır. Üretim kodu _write_text/_move_file sınırları hata enjeksiyonuna uygun tutuldu; test dışı fault bayrağı yok. Bitti ölçütü: dosya hata yolları, eski kayıt uyumu ve Gün 1–3 regresyonu. Sonraki iş: aday durumla karar işleme ve gerçek gözleme dayanan Gün 4 hazırlığı.
