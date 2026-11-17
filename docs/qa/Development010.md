# 0.1.10 geliştirme teslimi — 17 Kasım 2026

Taban 0.1.9/8de58a6; Claude'un zaman yönlendirmesi96ff9ca yalnız kendi diff'iyle alındı (6bb3c8c). ROOMS-002 UI ve kayıt değişiklikleri bu sürümde yok.

Gün1 sabah/öğleden sonra HUD: evde yürümenin saati ilerletmediği, konuşma/anlamlı eylemlerin ilerlettiği ve Daniel'ın yatak odasında dinlenilebildiği EN/TR anlatılır. Takvim/ziyaret saati açıklanmaz; mekanik değişmez. Kapı ve ekran kaplamaları öncelikli kalır. Save/load ve dil değişimi testleri var.

Ana Codex kaynak incelemesi yapıldı; CLI kota engeli aşılmış gibi gösterilmedi. Son release worktree'si ve sürüm etiketi üzerinden izolasyonlu Godot4.7.2/WASAPI:30paket/7441 raporlanmış kontrol PASS (campaign101). Kaynak runtime/release010-tests.log, tqh-tests-17e901e4639643beb0842e1d8efd3e2a. Dış PowerShell sarmalayıcısı robocopy'nin kalan1 kodunu taşıdı; test betiği bütün paketleri tamamladı. Log ayrıca tam30işareti,30PASS ve hata yokluğu ile doğrulandı; dış1kodu gizlenmez veya Godot hatası diye yorumlanmaz.

Aynı HUD kodunun96ff9ca izole kopyası Forward+/GTX1080Ti ile gerçek GPU'da1280x720 EN/TR görüntülendi: docs/qa/screenshots/day1-guidance. Metin saat altında, kapı altyazısından ayrı. Görsel örneklerde mevcut ev ışığı/tasarımı değişmedi. Kayıtlar yalnız test kullanıcı dizininde; gerçek oyuncu dosyaları düzenlenmedi.

ROOMS-002 GPU kontrolü ayrı kusur buldu: başlık/saat çakışması ve dil değişince statik İngilizce başlıkların kalması. Bu nedenle oda önizlemesi ayrı dalda tutuldu. Yeni karakter stili, ışık revizyonu, merdiven düzeltmesi, kapı deliği ve Gün5 bu teslimde yok. Claude merdiven işini IMMERSION-I03 claim'iyle ayrı dalda yürütüyor. Tam elle kampanya/FPS testi ve standalone export yapılmadı.
