# Windows geliştirme başlatıcıları

## Hedef ve dosyalar

OYUNU_AC.cmd → tools/Start-Game.ps1 normal kampanyayı açar. NOBETI_DENE.cmd aynı betiği -NightDemo ile çağırır. Ana klasördeki ince yönlendiriciler project içindeki bu sürüm kontrollü dosyaları çağırır. Otomasyonun BASLAT.cmd dosyası oyun başlatıcısı değildir.

Motor varsayılanı proje yanındaki tools/godot-4.7.2 console.exe; GODOT_BIN veya -GodotPath ile eşleşen kurulum belirtilebilir. Tam 4.7.2.stable sürüm çıktısı doğrulanır. İçe aktarma arka planda çalışır, gerçek oyun etkileşimli pencere olarak başlatılır. İçe aktarma başarısızsa oyun açılmaz; log klasörü gösterilir.

## Kayıt ayrımı

Normal yol mevcut projeyi, tercihleri ve kampanya kayıtlarını kullanır. Nöbet yolu LocalAppData/TheQuietHours/playtests/<kimlik>/project altında taze kopya oluşturur; .git/.godot/docs/tools/build ve kaynak override.cfg kopyalanmaz. Bu kopyanın override.cfg dosyası farklı config/custom_user_dir_name atar. Her çağrının proje ve kayıt kimliği ayrıdır; deneme normal kaydı okumaz/yazmaz.

Deneme sahnesi tests/manual_night_watch.tscn, gerçek HouseBlockout üzerinde Gün 3 20:00 ve açık Daniel odasıyla başlar. İlk nöbet onayını seçerek ilerle. Taze boş ev QA koşuludur; tüm 14 günlük kampanya veya nihai Windows paket değildir. Başlatıcı kayıt silmez ve kendiliğinden geçici kopya temizlemez.

## Doğrulama

Start-Game.ps1 -NightDemo -PrepareOnly gerçek kopya, farklı kullanıcı yolu, sürüm ve import doğrulamasını geçti. Hazırlanan kopya gerçek motorla --headless --quit-after 30 ve demo sahnesi üzerinden çalıştı: çıkış 0, MANUAL NIGHT QA: READY day=3 time=20:00. Normal -PrepareOnly doğru kaynak proje/engine ile importu geçti. İlk uygulamada Windows süreç çıkış kodu null okunuyordu; test çalıştırıcısındaki gibi Process.Handle önceden alınarak düzeltildi. Başarısız ilk deneme başarılı sayılmadı.

Bu teslimde fiziksel çift tıklama/fare-klavye testi yapılmadı; programatik hazırlık ve motor açılışı doğrulandı. Önceki 16 paket/5595 denetimin tamamı yalnızca bu başlatıcı değişikliği nedeniyle tekrar çalıştırılmadı. Ürün mantığı değişmedi; QA sahnesine tek açılış satırı eklendi.

## Gereken kurulum ve sınırlar

Windows PowerShell ve kurulmuş Godot 4.7.2 gerekir. Önce varlıklar içe aktarılır; ilk çalıştırma sonraki açılıştan uzun sürebilir. Hata olursa betiğin gösterdiği import-stdout/import-stderr dosyalarını incele. Paketlenmiş oyun çalıştırıcısı, export template veya ticari dağıtım oluşturulduğu iddia edilmez.

Bitti tanımı: iki modun doğru proje/kayıt ayrımı, sürüm ve import kontrolü, ayrı deneme sahnesinin motor açılışı. Sonraki bağımlılık: kullanıcının gerçek girişle kesiti değerlendirmesi ve Windows export hattının ayrı kurulması.
