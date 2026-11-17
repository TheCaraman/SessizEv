# Birleşik geliş takvimi doğrulaması başladı

Teslim edilmiş ARRIVALS a5043bf, temiz continuous-integration dalına normal merge ile alındı; oda değerlendiricisi ve radyo önbelleği korunuyor. Aktif oyuncu sürümü henüz değişmedi.

AUTO-ARRIVALS-CHAIN: Claude CLI uygulama / Codex bağımsız inceleme / dış 30 paket WASAPI. İzinli: tests/arrival_integration_test.gd, tools/Run-Tests.ps1, docs/qa/CombinedArrivals.md. G3 ziyaretten gerçek gece geçişiyle G4 radyo/kapanış zinciri; ayrıca tek paket için izolasyonlu SelectedTests desteği. Oyun/save koduna paralel yazılmayacak. Gerçek oyun hatası çıkarsa kapsam genişletilmeden raporlanacak.

Oyuncu verisine doğrudan Godot test yazımı tekrarlanmamalı. Yeni çalıştırıcı seçili paketleri de ayrı proje ve kullanıcı dizininde sınar. Önceki veri olayında kurtarma iddiası yok; mevcut dosyalar temizlenmez.
