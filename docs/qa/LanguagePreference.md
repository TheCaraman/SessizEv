# Ana menü dil tercihi

## Hedef ve dosyalar

`scripts/core/settings.gd` kullanıcı dilini `user://settings.cfg` içinde saklar; `project.godot` içindeki Settings autoload'u açılışta yükler. Bu gerçek global kullanıcı tercihidir; kampanya kaydına dahil değildir. `scripts/ui/main_menu.gd` menü sütununa dil etiketi ve `LanguageChoice: OptionButton` ekler. İngilizce/Türkçe etiketler `localization/strings.csv` içinde; seçeneklerde dilin kendi adı kullanılır.

## Davranış ve kurulum

Ek paket gerekmez. Godot 4.7.2 ile projeyi içe aktar, normal ana sahneyi çalıştır. Menüden English/Türkçe seç; menü etiketleri hemen yenilenir. Ayar başarıyla diske yazıldıktan sonra uygulanır. Desteklenmeyen/okunamayan tercih İngilizceye döner. Kaydetme hatasında hata metni ve önceki seçim korunur. Oyun içi diyalog sırasında dil değiştirme ekranı bu teslimde yoktur.

## Doğrulama

Menü paketi 80 denetim: iki dili gerçek OptionButton sinyaliyle seçme, diskten tercihi yeniden okuma, desteklenmeyen dili reddetme ve kampanyayı değiştirmeme eklendi. Toplam 11 paket/2416 denetim geçti. `tests/language_preview.tscn` izole kullanıcı dizininde gerçek 1080p en/tr menü görüntülerini üretir; Türkçe görüntü incelendi. Fiziksel fare seçimi ve gerçek yeni süreçte kullanıcı testi yapılmadı; kalıcılık ConfigFile tekrar okumasıyla sınandı.

## Sınırlar ve sonraki bağımlılık

Bu tam ayarlar menüsü değildir. Ses/görüntü/erişilebilirlik tercihleri, kontrol yeniden atama UI'si ve nihai menü sanatı açık. Hata ayıklarken uygulama kaydı ile kullanıcı tercih dosyasını karıştırma; yeni kampanya dil tercihini silmez. Bitti tanımı: menüden iki dil seçilebiliyor, tercih tekrar okunabiliyor, kampanya aynı kalıyor ve mevcut regresyonlar geçiyor.
