# 0.1.9 geliştirme sürümü

17 Kasım 2026. Oyun tabanı ec15e36: Claude ARRIVALS a5043bf, saf oda değerlendiricisi 06d4e92, radyo önbelleği d0a6199 ve birleşik zincir testi.

## Oyuncuya yansıyan değişiklik

Yeni kampanyada Elena Gün 1 18:00–21:30; Marcus ve Arthur Gün 2–3 arasında kampanya seed'iyle belirlenen gündüz ziyaretlerinde gelir. Günlük en fazla iki ziyaret, aralarında en az 90 dakika vardır. Gece ziyaretçisi eklenmedi. Takvim kaydedilir; yüklemede tekrar seçilmez. v5 ve önceki kayıtlar eski sabit takvimi koruyarak v6'ya geçer.

Oyuncu mevcut yatak yönetimini kullanır. Yeni oda tercihi hesaplama modülü altyapıdır; NPC itiraz ekranı, yeni kişisel tercih ve güven cezası bu sürümde yoktur. Üç işlevsel NPC ve dört günlük mevcut dilim korunur. Yeni oda görseli, seslendirme veya Gün 5 içeriği üretilmedi.

## Gerçek doğrulama

ec15e36 tabanı: dış yöneticiyle Godot 4.7.2/WASAPI 30 paket PASS. ARRIVAL INTEGRATION 249 kontrol, SHELTER 80 kontrol. Marcus'un G3 ziyareti kabul/ret/kaçırma, gerçek gece ve kesinti, G4 sabah/radyo/kapanış üzerinden sınandı; takvim ve enfeksiyon değişmedi. Salt okunur bağımsız Codex incelemesi approved. Kaynak runtime/continuous/AUTO-ARRIVALS-CHAIN-2.tests.log.

Bu sürümde ilave değişiklik yalnız sürüm etiketi ve teslim belgeleridir. Sürüm etiketi değiştikten sonra bu worktree üzerinden izolasyonlu menu_test seçili paketi ayrıca çalıştırıldı: MENU 80 ve WASAPI AUDIO LIFECYCLE 35 kontrol PASS. Kaynak kopya tqh-tests-e65f1f4c6a0a43f399a88e8236d1c8a7; oyuncu verisinden ayrı kullanıcı dizini. Tam kapıda 30 paket/7406 raporlanmış kontrol PASS; seçili test tam kapı yerine sayılmaz. Tam elle oynama ve hedef donanım FPS ölçümü yapılmadı. Bu Godot kaynaklı geliştirme sürümüdür; standalone Windows export değildir.

## Deneme ve kalan işler

Masaüstü kısayolunun açtığı kök OYUNU_AC.cmd bu sürüme yönlendirildiğinde yeni sürüm kullanılabilir. Rastgele geliş için New Game; eski kampanyanın ziyaretleri değişmez. Takvim seed'e bağlıdır; aynı seed aynı sonucu verir.

Sonraki işler: oda planı önizleme/itiraz ve güvenli aday kayıt akışı; eksik karakter içeriği; kayıt takvimindeki bozuk alanların daha kapsamlı semantik testleri. Sanat kabulü ve BODYCAM dalı ayrı kalır. Oyuncu verisine önceki manuel test yazımı olayı ayrı kayıttadır; bu sürüm eski kullanıcı kaydını kurtarmış değildir. Testler yalnız izolasyonlu Run-Tests.ps1 ile yapılır; -SelectedTests kısmi sonuç üretir.
