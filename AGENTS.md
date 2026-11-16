# THE QUIET HOURS — Ortak asistan kuralları

Claude, ChatGPT ve Codex bu dosyayı çalışmaya başlamadan önce okur.
Ardından `CLAUDE.md`, `docs/coordination/STATUS.md`, `TASKS.md` ve `HANDOFF.md`
dosyalarını oku. Yaratıcı kararların kaynağı `docs/DecisionLog.md` dosyasıdır.
Her görev başında, kilometre taşı sonunda ve commit öncesinde
`docs/coordination/messages/` altındaki sana yöneltilen mesajları da oku.
Okuduğunda ayrı bir yanıt dosyasıyla mesaj kimliğini onayla; gönderenin dosyasını değiştirme.
Boş ve çakışmayan işleri aranızda seçin; rutin görev dağılımını kullanıcıya yaptırmayın.

## Karar yetkisi

Proje sahibi nihai yaratıcı yetkilidir. Asistan adı veya modeli üstünlük sağlamaz.
Kabul edilmiş vizyonu koruyan, oyuncu deneyimini iyileştiren, testle doğrulanabilen
ve daha az üretim/bakım maliyeti getiren çözüm tercih edilir. Ölçülemeyen bir
öneri otomatik kabul edilmez. `docs/coordination/DECISIONS.md` şablonunu kullan.
Kapsam, hikâye veya görsel yön değişikliklerini sahibine sor; rutin teknik kararları
gerekçesiyle kaydet. Çözülemeyen anlaşmazlıkta mevcut çalışan sürümü koru.

## Güncel ürün kuralları

- Türkçe iletişim; oyun metinleri İngilizce anahtarlar ve Türkçe çeviriyle.
- Godot 4.7.2 stable, GDScript, Forward+.
- 3D koridorlar ve kapıdan açılan katmanlı 2D odalar/karakterler.
- Pikselleştirme, PS1 estetiği ve düşük çözünürlüklü dokular reddedildi.
- Dengeli kirli sarı, turkuaz, kırmızı ve nötr palet; referanslı ışık tasarımı.
- FPS dövüşü yok. Enfeksiyon olağan temastan bulaşmaz, sonradan keyfî atanmaz.
- Lily sağlıklı; öldürülemez ve ekranda şiddet görmez.
- Ölü/yok NPC olaylara katılamaz. Her kanıtın gerçek nedeni olmalı.

## Eşzamanlı çalışma

1. `git status --short`, dal ve son commit'i kontrol et. Başkasının değişikliğini silme.
2. Görev kimliği ve düzenlenecek dosyaları `TASKS.md` içinde üzerine al.
3. Aynı fiziksel çalışma klasöründe dal değiştirmek herkesi etkiler. Diğer asistan
   aktifken dal değiştirme. Paralel kodlama için ayrı clone veya worktree kullan.
4. Görev tablosu danışma kaydıdır, otomatik kilit değildir. Çakışan sahiplik varsa
   aynı dosyada yazmayı bırak, ayrık dosyalarda çalış veya devir bekle.
5. Başlamadan önce dal/HEAD/dosya özetini yeniden kontrol et; eski içeriğin üzerine yazma.
6. Yalnızca kendi dosyalarını açık yollarla stage et; ortak çalışmada `git add -A` kullanma.
7. Force push, reset --hard ve başkasının commit'ini yeniden yazma yok.
8. İlgili testleri çalıştır; çalıştırılmayan şeyi test edildi diye bildirme.
9. Devir günlüğüne değişiklik, test sonucu, eksik ve sonraki adımı yaz. Görevi bırak.

Bu dosyalar asistanları kendiliğinden konuşturmaz. Her asistan bunları yeniden
okumalıdır; ayrı kopyalarda güncel commit'leri fetch/pull veya bundle ile almalıdır.

## Doğrulama

`powershell -NoProfile -File tools/Run-Tests.ps1 -GodotPath <godot-console.exe>`
Testler geçici kullanıcı verisi dizininde çalışır. Çıktıdaki PASS ve süreç çıkış
kodları kontrol edilir; yalnızca motorun açılması testin geçtiği anlamına gelmez.
