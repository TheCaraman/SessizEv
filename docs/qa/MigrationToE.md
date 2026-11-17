# E: taşıma doğrulaması — 17 Kasım 2026

Hedef sahip tarafından E:\TheQuietHours seçildi. Claude duraklatıldıktan sonra proje kökü kopyalandı; kaynak silinmedi. 4,24GiB civarı kaynak/Git/worktree/araç/arşiv verisi. Copy:DAT/DCOPY:DAT, yeniden deneme sınırlı; robocopy çıkış3 (başarılı; hedefte denetim logu ek dosyadır).

İlk kopya, hedefte Git/yol düzeltmesi yapılmadan SHA-256 ile doğrulandı:12372 dosya,0fark. 15Git çalışma alanı git worktree repair ile hedefteki ana Git'e bağlandı; hepsinin common-dir'i E:/TheQuietHours/project/.git. Her worktree'nin kaydedilmemiş değişiklik listesi kaynakla aynı. Git fsck --full çıkış0. Manuel Claude ARRIVALS-002 değişiklikleri dahil korundu.

Makine yapılandırmaları: queue.json, queue.continuous.json, settings.local.json ve canlı runtime durum/aktif sürüm yolları E: olarak güncellendi. Önceki JSON kopyaları runtime/migration altında saklandı. Geçmiş commit/log/belge yolları yeniden yazılmadı. Uygulama kurulumları ve hesap girişleri C: üzerindeki normal kurulum yerinde; Godot proje aracı E:'ye taşındı. Windows kullanıcı kaydı konumu değiştirilmedi.

Masaüstü THE QUIET HOURS.lnk artık E:\TheQuietHours\OYUNU_AC.cmd hedefli. Aktif kaynak E:\TheQuietHours\workers\dev-0.1.9, commit8de58a6. Kök başlatıcılar göreli olduğu için kaynak metni değişmeden yeni konumda çalışır.

Yeni konumdan izolasyonlu seçili test: arrival_integration249, menu80, WASAPI audio lifecycle35 PASS. Kaynak kopya tqh-tests-9c138fbd3f0a403baeba210c9874a649. Bu iki seçili paket + ses kontrolüdür;30paket tekrar edildi denmez. İlk deneme ortak Godot editor_settings okuma hatasıyla importta durdu; dosya manuel değiştirilmedi, sonraki koşu geçti. Otomasyon15birim testi PASS.

CLI yönetici E: üzerinden yeniden başlatıldı. Yeni görev workspace'inin E: olması state.json ile ayrıca kontrol edilir. Eski C: STOP/STOP_CONTINUOUS işaretleri korundu; eski kopyaya bir taşınma notu bırakıldı. Masaüstü Claude oturumunun klasörü araçlarla otomatik değiştirilmedi; yeniden devamda E: altındaki mutlak yolları/klasörü kullanması gerekir. C: ve E: arasında çift yönlü senkronizasyon yapılmaz.

Makine kanıtları: runtime/migration/{copy-verification.json,git-worktrees.json,shortcuts-before.json,copy.log}. C: kopyası güvenlik için duruyor; disk alanı boşaltıldı denmez. Önceki oyuncu kaydı olayı bu taşımayla kurtarılmadı. Görev sürerken yazılmış bütün ilerleme Git ve ortak devir mesajlarında korunur.
