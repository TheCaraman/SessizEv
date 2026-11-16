# Ana ses düzeyi — SETTINGS-AUDIO-001

Amaç: menü ve duraklatma ayarlarından tüm mevcut sesleri denetlenebilir kılmak.

Dosyalar: scripts/core/settings.gd (doğrulama, kalıcılık, Master uygulaması), scripts/ui/settings_view.gd (dördüncü kaydırıcı), localization/strings.csv (EN/TR anahtarı), tests/settings_test.gd. Düğüm: mevcut SettingsView/SettingsPanel içindeki master_volume HSlider; yeni sahne/autoload bağımlılığı yok. Motor: Godot4.7.2; projeyi import etmek yeterli.

master_volume doğrusal kazanç0..1, adım.01, varsayılan1. Master bus AudioServer.get_bus_index ile bulunur. set_bus_volume_linear kazancı uygular; set_bus_mute sıfırda tam sessizlik ve pozitif değerde yeniden açılma sağlar. Referans: https://docs.godotengine.org/en/4.6/classes/class_audioserver.html . İki mevcut ses kaynağı varsayılan Master çıkışındadır. Başarılı ConfigFile.save sonrası canlı uygulama; yanlış tip/aralık reddedilir. Dosyada eksik değer eski tercihlerle uyumludur. Kampanya şeması ve seed değişmez.

Deneme: ana menü→Ayarlar→Ana ses düzeyi;0%,25%,100%; yeniden açma; oyun içi Esc→Ayarlar; varsayılanlara dön. Ses sıfırda susmalı, artırılınca dönmeli. Altyazı/oyun metni değişmez. MENU_SETTINGS_MASTER_VOLUME gibi anahtar görünürse CSV yeniden import edilmeli. Master bulunamazsa bus çağrısı yapılmaz; mevcut projede Master motor tarafından sağlanır.

Test: settings_test gerçek AudioServer gain/mute, persist/reload, dil değişimiyle koruma, geçersiz1.01 reddi ve defaults unmute ölçer. Gerçek Tab odak zinciri6 kontrol, EN/TR720p/1080p/1440p taşma denetimleri korunur. İzole Run-Tests kullanıcı kayıtlarına yazmaz. Dinleyerek öznel ses kalitesi doğrulanmış sayılmaz.

Bitti ölçütü: tam regresyon, iki GPU ayar görüntüsünün incelenmesi, launcher sürüm doğrulaması. Sonraki bağımlılık: ses kategorileri ve nihai miksaj; mevcut başlık sadece ana düzeydir. Parlaklık/dünya görünümü bu işte değiştirilmez.

Sonuç:24 paket / 6219 denetim PASS (WASAPI); GPU92 PASS, EN/TR görüntüler incelendi. Günlük: C:\Users\eyups\AppData\Local\Temp\tqh-tests-c71983fa4e45443a982a9269acbae31f. Sürüm0.1.4-dev.20261116.5. Ses dinleme testi yapılmadı; motor gain/mute değerleri ölçüldü.
