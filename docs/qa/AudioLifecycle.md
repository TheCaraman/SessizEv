# QA-AUDIO-EXIT-001 — Ses nesnesi yaşam döngüsü araştırması

## Sonuç ve sınır

Gözlenen iki ObjectDB nesnesi, boru olayının AudioStreamWAV ve AudioStreamPlaybackWAV kaynaklarıdır. İnceleme bunların gerçek oyunda kalıcı sızıntı olduğunu doğrulamadı. Aynı presentation_test, varsayılan headless/Dummy ile uyarı üretirken GPU/WASAPI ve headless/WASAPI ile88 denetimi ObjectDB uyarısı olmadan geçti. Kaynak/oynatım kimlikleri geçici probe ile eşleştirildi; probe ürün koduna eklenmedi.

[Godot AudioServer belgesi](https://docs.godotengine.org/en/stable/classes/class_audioserver.html#class-audioserver-method-get-driver-name), headless'ın sürücüyü Dummy yaptığını ve gerçek sürücünün get_driver_name ile okunabildiğini belirtir. Komut sırası yerel motorda ayrıca doğrulandı: --audio-driver WASAPI --headless çıktısı Dummy; --headless --audio-driver WASAPI çıktısı WASAPI. Test aracı bu nedenle açık sürücüyü headless'tan sonra geçirir. Belgeler bir sızıntı hatasını doğrulamaz; sürücüye bağlı bulgu bu kurulu motor/PC üzerindeki gözlemdir. Eşleşen upstream4.7.2 kaynak URL'leri alınamadı; motor kaynak sebebi kesinleşmiş gibi anlatılmaz.

## Yeni doğrulama

tests/audio_lifecycle_test.gd/.tscn gerçek backend'i şart koşar. Üç sök/tak döngüsünde DoorAudio gelişi ve gerçek gece boru olayı başlatılır. Sahne etkinken kaldırılır; weakref ile stream ve playback nesnelerinin azami1s içinde serbest kaldığı ölçülür. Yeni ziyaret/saat sinyallerinde eski sahnenin callback'inin yaşamadığı da kontrol edilir. Toplam35 denetim. Test sesi -80dB'dir. Bu dinleme veya mekânsal ses kalitesi incelemesi değildir.

tools/Run-Tests.ps1 -GodotPath <console.exe> -AudioDriver WASAPI: 22 çekirdek paketi seçilen ses sürücüsüyle çalıştırır; ardından23. yaşam döngüsü paketini ekler. Test, sürücünün adını gerçekten okur; beklenenden farklı veya Dummy ise exit2 tasarlanmıştır. İstenen sürücünün kullanılmadığı bir koşu başarı sayılmaz. Donanımlı koşuda ObjectDB uyarısı da başarısızlıktır. Her paket ayrı stdout/stderr tutar.

Parametresiz çalıştırmada eski22 headless çekirdek paketi korunur; hardware testinin çalışmadığı açıkça yazılır. ObjectDB uyarısı varsa raporlanır ve günlük yolu verilir. Bu koşu donanımlı ses temizliğini kanıtlamaz.

## Deneyler ve kanıt sınırı

- Sunum88: headless/Dummy ObjectDB2; GPU/WASAPI ve headless/WASAPI ObjectDB uyarısız.
- viewport free sonrası .06s bekleme, stop/streamnull sonrası .1s bekleme ve SubViewport3D listener açılması, Dummy uyarısını çözmedi. Geçici denemeler geri alındı.
- İlk araç denemesinde komut sırası yanlıştı: yaşam döngüsü35 gerçekWASAPI ile geçti, önceki22 paketDummy'deydi. Bu koşu bütün paketlerin donanımlı olduğu kanıtı değildir. Düzeltilmiş araçla tekrar koşu ayrıca kaydedilir.
- Dummy'nin hardware kapısından reddedildiğini çalıştırarak ölçmek için planlanan ek negatif komut otomatik onay incelemesinde blocked by policy ile reddedildi. Bu negatif deney çalıştırılmadı ve yeniden denenmedi. Koddaki guard varlığı, çalıştırılmış negatif test diye sunulmaz.

## Kalan işler

Oyun sesi, estetik, kaynak ekonomisi, enfeksiyon ve kayıt şeması değişmedi. Görsel sürüm0.1.2-dev.20261116.3 korunur. QA-AUDIO-DUMMY-002: Dummy kapanışındaki uyarının küçük upstream yeniden üretimi/motor araştırması açık; gerçek backend temizliğini bu uyarının giderildiği diye sunma. Elle ses dinleme incelemesi de açıktır.

Son doğru sıralı koşu:23paket/6107denetim PASS; gerçekAudioServer sürücüsüWASAPI. Tüm stderr dosyalarında ObjectDB/leaked instance/SCRIPT ERROR/ERROR/FAIL bulunmadı. Sonuçlar ve kaynak hash'i audio-lifecycle-last-run.json içinde; günlük kökü tqh-tests-e2a99cb10ee04d0cb4e67acea4534ead. Bu, Dummy uyarısının çözüldüğü iddiası değildir.

## Düzeltme — sonraki tam koşuda yeniden üretildi
Önceki "yalnızDummy" açıklaması fazla kesindi. Ayarlar tesliminin ilk tamWASAPI koşusunda presentation_test'in motoru sahneyi queue_free ettiği karede sonlandırması da aynı2nesne uyarısını zaman zaman üretti. Üç döngülü aktif sahne testi yine temizdi. presentation_test teardown artık gerçek sürücüde sahne kaldırıldıktan sonra weakref kaynaklarının bırakıldığını azami1s bekleyip doğrular; motoru aynı karede durdurmaz. Bu düzeltmeyle ardışık3donanımlı sunum koşusu89denetim ve ObjectDB uyarısı olmadan geçti. DefaultDummy için donanım temizliği iddiası eklenmedi. Bu bir ürün ses/estetik değişikliği değil, test ömrünün doğru kapatılmasıdır; önceki deney kanıtı tarihsel tutulur.
