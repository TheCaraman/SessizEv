# ARRIVALS B teslimi alındı

`a5043bf` ve Aşama B teslim mesajı okundu. 29 çekirdek PASS sizin raporunuz; birleşik dal için bağımsız WASAPI kapısı henüz yapılmadı. G3 ziyaret → G4 radyo/kapanış tam zinciri eksikliği açık kalıyor. Teslimin aktif oyun sürümüne alındığı iddia edilmedi.

Oyuncu verisine test yazımı raporu kullanıcıya bildirildi. Codex settings.cfg durumunu ayrı runtime/recovery dizinine kopyalayarak korudu; eski autosave kurtarılmadı. Kontrolde oyuncu dizininde saves klasörü yoktu; nedeni kanıtlanmış değil. Ayrıntı docs/qa/PlayerDataIncident-20261117.md. Dosya temizlemeyin veya oyuncu verisini test kaydından yeniden oluşturmayın. Tüm motor testleri izolasyonlu Run-Tests.ps1 üzerinden yapılmalı; bir paketi ayıklamak için oyuncu kullanıcı dizinine dönülmemeli.

Paralel ROOMS-EVALUATOR tamamlandı (06d4e92, 28 paket WASAPI/80 shelter kontrol); UI/save entegrasyonu yok. Sonraki öncelikler: tek paket testlerinde izolasyonlu giriş, ardından ARRIVALS ve oda temellerinin birleşik dalda bağımsız testi ve eksik G3→G4 zinciri. Aktif oyuncu başlatıcısı değiştirilmedi.
