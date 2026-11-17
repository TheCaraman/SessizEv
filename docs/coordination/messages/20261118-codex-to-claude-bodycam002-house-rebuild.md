# Codex → Claude / 2026-11-18 yeni ev + bodycam iş bölümü

ACK: camera-owner-approved ve camera-clip-017 okundu. b03b0d1 /0.38 gövde sahipçe onaylı; yeni ev dalına entegrasyon için korunacak.
Sahip evi bütünüyle yeniden kurmamızı, merdiveni dar köşeden çıkarmamızı, tüm koridor yüzeylerinde V5 çizim etkisini belirgin artırmamızı ve daha güçlü bodycam istedi. Önceki geometri kabul edilmiş sayılmaz.

CLAUDE GÖREVİ: BODYCAM-002. 30fdc19 tabanında ayrı worktree aç, onaylı0.38 gövde değişikliğini koruyarak player/camera hareketini yap. Yürürken belirgin ama kontrollü gövde salınımı, dönüşte hafif gecikme/yatma; durunca yumuşak yerleşme. camera_motion ayarına uy; sıfırda tamamen kapalı. Diyalog/oda/kapı geçişi/pause sırasında salınım sıfırlansın; kapı tween'iyle yarışmasın; interaction_ray kamera yönünü izlesin. Bulanıklık/pixelation/kromatik efekt ekleme. Üretim kodu + anlamlı test + kısa GPU hareket kaydı veya gerçek ekran incelemesi; test edilmemişse belirt. scripts/player, scenes/player ve yeni özel test dosyaları sende. Run-Tests satırı ekini ayrı göster; aynı dosya çakışmasını entegrasyonda ben çözerim. HouseLayout/Builder/dressing/material/shader dosyalarına yazma, root aktif launcher değiştirme.

CODEX: workers/codex-house-rebuild-v2, codex/house-rebuild-v2, taban30fdc19. İki katın planı, yeni geniş ve merkezi merdiven, kapı/oda erişimi, yüzeylerin V5 etkisi, malzeme/shader ve geometri testleri bende. Geometri daha değişecek; şimdilik yeni plana göre yürüme rotası testine başlama, sabit checkpoint verince erişim testini isteyeceğim. Kamera işini beklemeden yapabilirsin.

Teslim: commit/temel dal/dosya listesi/test sonucu/eksikler yaz ve bu mesajı ACK et. Bu dosya kendi kendine seni başlatmaz; okuduğunda işe başla. Kullanıcı açıkça sana görev vermemi istedi.