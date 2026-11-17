# Oyuncu verisine test yazımı — açık olay

Kaynak: 20261117-claude-to-codex-arrivals-stage-b.md. Claude testleri bir kez izole çalıştırıcı dışında koşturduğunu, autosave/backup, ayarlar ve test slotlarına yazdığını bildirdi. Bildirim kullanıcıya açıklandı. Önceki oyuncu kaydının varlığı/içeriği bu teslimde doğrulanamıyor; kurtarıldığı iddia edilmez.

Codex kontrolü 17 Kasım 2026 09:52 TRT: `%APPDATA%/Godot/app_userdata/The Quiet Hours` içinde settings.cfg bulundu, `saves` klasörü bulunmadı. Bu gözlem önceki dosyaların kimin tarafından veya ne zaman kaldırıldığını kanıtlamaz. Runtime altında autosave adlı yedek bulunmadı. Önceki aktif sürüm checkpoint'i yalnız başlatıcı dosyaları içeriyor.

Mevcut settings.cfg, `TheQuietHours/runtime/recovery/player-data-20261117-095216` içine kopyalanarak korundu. Oyuncu klasöründen dosya silinmedi, taşınmadı, üzerine yazılmadı; yeni kampanya başlatılmadı. Bu koruma geçmiş ayarları geri getirmez.

Mevcut CLI otomasyon testleri yalnız Run-Tests.ps1 ile, ayrı proje kopyası ve benzersiz TheQuietHours-Tests kullanıcı dizini içinde çalışıyor. Oda değerlendiricisi kapısının günlüğü ayrı dizini açıkça kaydediyor. Manuel tek sahne testlerinin de aynı izolasyonu kullanması gerekir. Sonraki geliştirme önceliği: izole çalıştırıcıda seçili paket desteği ve belgelenmiş tek giriş; bu, keyfi doğrudan Godot komutunu teknik olarak engellediği iddiası değildir.

Olay açık: eski kullanıcı kaydı için doğrulanmış kurtarma kaynağı bulunmadı. Test verisi temizliği veya geçmiş durumun uydurma kayıttan yeniden oluşturulması yapılmaz.
